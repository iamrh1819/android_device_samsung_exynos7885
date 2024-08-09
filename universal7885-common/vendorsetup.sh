#!/bin/bash

echo 'Starting Cloning repos for exynos7885'
echo 'Cloning Kernel tree [1/7]'
# Kernel for exynos7885
rm -rf kernel/samsung/exynos7885

git clone https://github.com/eurekadevelopment/Eureka-Kernel-Exynos7885-Q-R-S -b R15_rom kernel/samsung/exynos7885


echo 'Cloning Device Tree [2/7]'
# Device tree for exynos7885
rm -rf device/samsung

git clone https://github.com/iamrh1819/android_device_samsung_exynos7885 -b A14-F device/samsung


echo 'Cloning Vendor Trees [3/7]'
# Vendor blobs for exynos7885
rm -rf vendor/samsung

git clone https://github.com/eurekadevelopment/android_vendor_samsung_exynos7885 -b android-14 vendor/samsung


echo 'Cloning Hardware Samsung [4/7]'
# Hardware OSS parts for Samsung
mv hardware/samsung/nfc .
rm -rf hardware/samsung
git clone https://github.com/Roynas-Android-Playground/android_hardware_samsung -b fourteen hardware/samsung
mv nfc hardware/samsung


echo 'Cloning Hardware Samsung [5/7]'
# Samsung Extra Interfaces
#rm -rf hardware/lineage/interfaces
#git clone https://github.com/LineageOS/android_hardware_lineage_interfaces -b lineage-21.0 hardware/lineage/interfaces
git clone https://github.com/Roynas-Android-Playground/hardware_samsung-extra_interfaces -b lineage-21 hardware/samsung-ext/interfaces


echo 'Cloning Lineage-CP [6/7]'
# Lineage-CP
rm -rf hardware/samsung_slsi/libbt
rm -rf hardware/samsung_slsi/scsc_wifibt/wifi_hal
rm -rf hardware/samsung_slsi/scsc_wifibt/wpa_supplicant_lib

git clone https://github.com/LineageOS/android_hardware_samsung_slsi_libbt -b lineage-21 hardware/samsung_slsi/libbt
git clone https://github.com/LineageOS/android_hardware_samsung_slsi_scsc_wifibt_wifi_hal -b lineage-21 hardware/samsung_slsi/scsc_wifibt/wifi_hal
git clone https://github.com/LineageOS/android_hardware_samsung_slsi_scsc_wifibt_wpa_supplicant_lib -b lineage-21 hardware/samsung_slsi/scsc_wifibt/wpa_supplicant_lib


echo 'Cloning Samsung_Slsi and Linaro BSP repos [7/7]'
# SLSI Sepolicy
rm -rf device/samsung_slsi/sepolicy
git clone https://github.com/Roynas-Android-Playground/android_device_samsung_slsi_sepolicy -b lineage-21 device/samsung_slsi/sepolicy
# Linaro BSP
rm -rf hardware/samsung_slsi-linaro

git clone https://github.com/linux4-bringup-priv/android_hardware_samsung_slsi-linaro_graphics.git hardware/samsung_slsi-linaro/graphics
git clone https://github.com/linux4-bringup-priv/android_hardware_samsung_slsi-linaro_config.git hardware/samsung_slsi-linaro/config
git clone https://github.com/linux4-bringup-priv/android_hardware_samsung_slsi-linaro_exynos.git hardware/samsung_slsi-linaro/exynos
git clone https://github.com/linux4-bringup-priv/android_hardware_samsung_slsi-linaro_exynos5.git hardware/samsung_slsi-linaro/exynos5
git clone https://github.com/linux4-bringup-priv/android_hardware_samsung_slsi-linaro_openmax.git hardware/samsung_slsi-linaro/openmax
git clone https://github.com/linux4-bringup-priv/android_hardware_samsung_slsi-linaro_interfaces.git hardware/samsung_slsi-linaro/interfaces


echo 'Completed, Now proceeding to lunch'


if [ ! -e .repo/local_manifests/eureka_deps.xml ]; then
	git clone https://github.com/iamrh1819/local_manifests .repo/local_manifests
	echo "Run repo sync again"
fi

python3 device/samsung/universal7885-common/generate_product_makefiles.py
