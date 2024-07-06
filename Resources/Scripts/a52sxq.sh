#!/bin/bash

# Build an Android kernel that is actually UEFI disguised as the Kernel
cat ./BootShim/AARCH64/BootShim.bin "./Build/a52sxqPkg/${_TARGET_BUILD_MODE}_CLANGPDB/FV/A52SXQ_UEFI.fd" > "./Build/a52sxqPkg/${_TARGET_BUILD_MODE}_CLANGPDB/FV/A52SXQ_UEFI.fd-bootshim"||exit 1
gzip -c < "./Build/a52sxqPkg/${_TARGET_BUILD_MODE}_CLANGPDB/FV/A52SXQ_UEFI.fd-bootshim" > "./Build/a52sxqPkg/${_TARGET_BUILD_MODE}_CLANGPDB/FV/A52SXQ_UEFI.fd-bootshim.gz"||exit 1
cat "./Build/a52sxqPkg/${_TARGET_BUILD_MODE}_CLANGPDB/FV/A52SXQ_UEFI.fd-bootshim.gz" ./Resources/DTBs/a52sxq.dtb > ./Resources/bootpayload.bin||exit 1

# Create bootable Android boot.img
python3 ./Resources/Scripts/mkbootimg.py \
  --kernel ./Resources/bootpayload.bin \
  --ramdisk ./Resources/ramdisk \
  --kernel_offset 0x00000000 \
  --ramdisk_offset 0x00000000 \
  --tags_offset 0x00000000 \
  --os_version 13.0.0 \
  --os_patch_level "$(date '+%Y-%m')" \
  --header_version 1 \
  -o boot.img \
  ||_error "\nFailed to create Android Boot Image!\n"

# Compress Boot Image in a tar File for Odin/heimdall Flash
tar -c boot.img -f Mu-a52sxq.tar||exit 1
mv boot.img Mu-a52sxq.img||exit 1