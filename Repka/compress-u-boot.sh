#!/bin/sh

# Compress u-boot bootloader
# version: 2025-02-15

if [ -z "$1" ]; then
  export UBOOTROOT=~/u-boot-repka
else
  export UBOOTROOT=$1
fi

echo "process: $UBOOTROOT"

cd ~/
mkdir u-boot-repka-pi3/
cd u-boot-repka-pi3/
mkdir dtb/ bootloader/

cp $UBOOTROOT/u-boot-sunxi-with-spl.bin bootloader/
cp $UBOOTROOT/arch/arm/dts/*repka*.dtb dtb/

cd dtb/

if [ -f "sun50i-h5-repka-pi3-allwinner.dtb" ]; then
  rm sun50i-h5-repka-pi3-allwinner.dtb
fi

if [ -f "sun50i-h5-repka-pi3.dtb" ]; then
  rm sun50i-h5-repka-pi3.dtb
fi

if [ -f "sun50i-h5-repka-pi3-alt.dtb" ]; then
  rm sun50i-h5-repka-pi3-alt.dtb
fi

cd ~/
rm u-boot-repka-pi3.tar.gz
tar -czvf u-boot-repka-pi3.tar.gz u-boot-repka-pi3/
rm -r u-boot-repka-pi3/

