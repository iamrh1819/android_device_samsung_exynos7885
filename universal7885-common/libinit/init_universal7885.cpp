/*
   Copyright (c) 2021, The LineageOS Project
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of The Linux Foundation nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
   THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
   WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
   ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
   BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
   IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <vector>

#include <sys/sysinfo.h>
#include <sys/stat.h>

#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>

#include <android-base/logging.h>
#include <android-base/properties.h>

#include "property_service.h"
#include "vendor_init.h"

using android::base::GetProperty;

const static std::vector<std::string> ro_props_default_source_order = {
    "", "odm.", "product.", "system.", "system_ext.", "vendor.", "vendor_dlkm.",
};

void property_override(char const prop[], char const value[], bool add = true) {
  prop_info *pi;

  pi = (prop_info *)__system_property_find(prop);
  if (pi)
    __system_property_update(pi, value, strlen(value));
  else if (add)
    __system_property_add(prop, strlen(prop), value, strlen(value));
}

void set_ro_build_prop(const std::string &prop, const std::string &value,
                       bool product = true) {
  std::string prop_name;

  for (const auto &source : ro_props_default_source_order) {
    if (product)
      prop_name = "ro.product." + source + prop;
    else
      prop_name = "ro." + source + "build." + prop;

    property_override(prop_name.c_str(), value.c_str());
  }
}

static inline bool hasEnding(const std::string& str, char suffix)
{
  return !str.empty() && str.back() == suffix;
}

static void setLowRamProp(void) {
  static constexpr auto GB_3 = 3ull * 1024 * 1024 * 1024;
  struct sysinfo sys {};

  sysinfo(&sys);
  if (sys.totalram <= GB_3)
    property_override("ro.config.low_ram", "true");
}

void vendor_load_properties() {
  std::string model;
  bool isNFC = false;
  struct stat statbuf{};
  char errbuf[40] = {};

  model = GetProperty("ro.boot.product.model", "");
  if (model.empty()) {
    model = GetProperty("ro.boot.em.model", "");
  }

  // We check the sec-nfc node and if it is a character device
  isNFC = stat("/dev/sec-nfc", &statbuf) == 0 && S_ISCHR(statbuf.mode);
  // Set the NFC property, if NFC is present.
  if (isNFC) {
    property_override("ro.boot.product.hardware.sku", "NFC");
  } else {
    snprintf(errbuf, sizeof(errbuf), "stat failed: error -%d", errno);
    property_override("ro.boot.product.hardware.sku_failed_reason", errbuf);
  }

  // Set Low ram prop based on HW ram size
  setLowRamProp();

  // Set model based on bootloader supplied model
  set_ro_build_prop("model", model);
  set_ro_build_prop("product", model, false);
}
