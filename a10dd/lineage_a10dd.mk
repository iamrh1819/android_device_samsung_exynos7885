# Copyright (C) 2018 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/product_launched_with_p.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit device configuration
$(call inherit-product, device/samsung/a10dd/device.mk)

# Inherit some common rom stuff
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Rom Specific Flags
TARGET_SUPPORTS_QUICK_TAP := true
TARGET_BOOT_ANIMATION_RES := 1080
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true

# Maintainer
RISING_MAINATAINER := Ʀᴀ㉿ɪƁ
PRODUCT_BUILD_PROP_OVERRIDES += \
    RISING_MAINTAINER="Ʀᴀ㉿ɪƁ"

# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := a10dd
PRODUCT_NAME := lineage_a10dd
PRODUCT_MODEL := SM-A105F
PRODUCT_BRAND := samsung
PRODUCT_MANUFACTURER := samsung
PRODUCT_GMS_CLIENTID_BASE := android-samsung
