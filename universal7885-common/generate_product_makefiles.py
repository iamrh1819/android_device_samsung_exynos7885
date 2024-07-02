import os
from os.path import isfile as exists
from os.path import dirname, basename

debug = True
DEVICE_BASE = 'device/samsung'
HD_DEVICES=['a10dd', 'a10', 'a20', 'a20e']
EX_RUNTIME_STR = 'Vendor config makefile was not found'

def log(x):
  if (debug):
     print(x)

def writeln(f, txt = ''):
    print(txt, file=f)

class GenerateMK():
    def __init__(self, vendor):
        self.config_mk_path = None
        self.vendor = vendor

    def check_exist_mk(self, path, mk):
        if self.config_mk_path is None and exists(path):
            self.set_config_path(path)

    def set_config_path(self, path: str):
        self.config_mk_path = path

    def write_one_dev_makefile(self, device):
        device_path = f'{DEVICE_BASE}/{device}'
        vendor = self.vendor
        log(f'Write entry => {device_path}')
        with open(f'{device_path}/AndroidProducts.mk', 'w') as ap:
            writeln(ap, f'# Auto-Generated by {__file__}')
            writeln(ap, f'PRODUCT_MAKEFILES += $(LOCAL_DIR)/{vendor}_{device}.mk')
        with open(f'{device_path}/{vendor}_{device}.mk', 'w') as mk:
            writeln(mk, f'# Auto-Generated by {__file__}')
            writeln(mk, f'$(call inherit-product, {device_path}/full_{device}.mk)')
            existed = False
            if self.config_mk_path is None:
                self.check_exist_mk(f'vendor/{vendor}/config/common_full_phone.mk', mk)
                self.check_exist_mk(f'vendor/{vendor}/config/common.mk', mk)
                if self.config_mk_path is None:
                    raise RuntimeError(EX_RUNTIME_STR)
            writeln(mk, f'$(call inherit-product, {self.config_mk_path})')
            writeln(mk)
            writeln(mk, f'PRODUCT_NAME := {vendor}_{device}')
            writeln(mk)
            
            if device in HD_DEVICES:
                writeln(mk, 'TARGET_BOOT_ANIMATION_RES := 1080')
            else:
                writeln(mk, 'TARGET_BOOT_ANIMATION_RES := 1440')
                writeln(mk, 'SYSTEM_OPTIMIZE_JAVA := true')
                writeln(mk, 'SYSTEMUI_OPTIMIZE_JAVA := true')
                writeln(mk, 'TARGET_ENABLE_BLUR := false')
                writeln(mk, 'TARGET_USES_PICO_GAPPS := true')
            log(f'Write entry <= {device_path}')

    def write_makefiles(self):
         devices = os.listdir(DEVICE_BASE)
         for i in devices:
            if not i[:1] == 'a':
                log(f'Skip entry: {i}')
                continue
            self.write_one_dev_makefile(i)

    def check_makefile(self, mk):
        log(f'Check MK => {mk}')
        if exists(mk):
            log(f'Check MK <= {mk} exist')
            self.write_makefiles()
            return True
        return False

# Hardcode paths for certain ROMs
class VendorFixer():
    def __init__(self, makefile_path, vendor_folder):
        self.mkpath = makefile_path
        self.vfolder = vendor_folder

    def check(self):
        mkpath = f'vendor/{self.vfolder}/{self.mkpath}'
        if exists(mkpath):
            log(f'APPLY VF: Overriding to path: {mkpath}')
            g_mk = GenerateMK(self.vfolder)
            g_mk.set_config_path(mkpath)
            g_mk.write_makefiles()
            return True
        return False


MikuVF = VendorFixer('build/product/miku_product.mk', 'miku')
TestVF = VendorFixer('config/my_ss.mk', 'ss')

def main():
    vendors = os.listdir('vendor')
    ok = False

    for vf in [MikuVF, TestVF]:
        if vf.check():
            return

    for vendor in vendors:
        mk = f'vendor/{vendor}/config/common.mk'
        ok |= GenerateMK(vendor).check_makefile(mk)
        if ok:
            break
    if not ok:
       raise RuntimeError(EX_RUNTIME_STR)

if __name__ == '__main__':
   main()
