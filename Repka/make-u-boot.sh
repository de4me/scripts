#!/bin/sh

# Make "Das U-Boot" Source Tree
# version: 2025-02-15

if [ -z "$1" ]; then
  if [ -z "$UBOOTROOT" ]; then
    export UBOOTROOT=~/u-boot-repka
  fi
else
  export UBOOTROOT=$1
fi

if [ -z "$CRUSTROOT" ]; then
  export CRUSTROOT=~/crust
fi

if [ -z "$ARMFIRMWAREROOT" ]; then
  export ARMFIRMWAREROOT=~/arm-trusted-firmware
fi

if [ -z "$SCP" ]; then
  export SCP=$CRUSTROOT/build/scp/scp.bin
fi

if [ -z "$BL31" ]; then
  export BL31=$ARMFIRMWAREROOT/build/sun50i_a64/release/bl31.bin
fi

cd "$UBOOTROOT"
echo "U-BOOT: $UBOOTROOT"
echo "BL31: $BL31"
echo "SCP: $SCP"
sleep 2

make clean
make

cd ~/

