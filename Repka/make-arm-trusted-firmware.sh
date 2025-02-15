#!/bin/sh

# Make Trusted Firmware-A
# version: 2025-02-15


if [ -z "$ARMFIRMWAREROOT" ]; then
  export ARMFIRMWAREROOT=~/arm-trusted-firmware
fi

cd "$ARMFIRMWAREROOT"
echo "arm-trusted-firmware: $ARMFIRMWAREROOT"
sleep 2

make clean
make PLAT=sun50i_a64 bl31

