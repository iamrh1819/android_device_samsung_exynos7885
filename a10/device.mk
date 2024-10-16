TARGET_LOCAL_ARCH := arm64

$(call inherit-product, vendor/samsung/a10/a10-vendor.mk)

PRODUCT_PACKAGES += \
   android.hardware.sensors@1.0-service

include device/samsung/a10/common.mk
