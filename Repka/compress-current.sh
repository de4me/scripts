#!/bin/sh

# Compress config and DTS
# version: 2025-02-15

if [ -z "$1" ]; then
  export UBOOTROOT=~/u-boot-repka
else
  export UBOOTROOT=$1
fi

echo "process: $UBOOTROOT"

mkdir ~/current/
cd ~/current/
mkdir configs/ dts/

cp $UBOOTROOT/configs/repka* configs/
cp $UBOOTROOT/arch/arm/dts/* dts/
rm dts/*.dtb

cd ~/
rm current.tar.gz
tar -czvf current.tar.gz current/
rm -r ~/current/

