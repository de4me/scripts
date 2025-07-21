#!/usr/bin/bash

# Repka bootloader writer
# version: 2025-07-21


if [ -z "$HOST" ]; then
  export HOST=ubuntu-vm
fi

if [ -z "$HOSTUSER" ]; then
  export HOSTUSER=denis
fi

if [ -z "$HOSTSOURCE" ]; then
  export HOSTSOURCE=u-boot-repka-pi3.tar.gz
fi

if [ -z "$DEVICELOADER" ]; then
  export DEVICELOADER=u-boot-sunxi-with-spl.bin
fi

if [ -z "$DEVICETREE" ]; then
  export DEVICETREE=sun50i-h5-repka-pi3-1ghz.dtb
fi

if [ -z "$DEVICEROOT" ]; then
  export DEVICEROOT=u-boot-repka-pi3
fi


if [ -n "$1" ]; then
  if [ ! -f "$1" ]; then
    echo "* download: $HOSTUSER@$HOST:~/$HOSTSOURCE"
    scp $HOSTUSER@$HOST:~/$HOSTSOURCE "$1"
  fi
  if [ -f "$1" ]; then
    echo "$1" > "last.txt"
    if [ -d "$DEVICEROOT" ]; then
      echo "* delete: $DEVICEROOT/"
      rm -r "$DEVICEROOT/"
    fi
    echo "* unarchive: $1"
    tar -xzf "$1"
  else
    echo "error: download $HOSTUSER@$HOST:~/$HOSTSOURCE"
    exit
  fi
else
  if [ -f "last.txt" ]; then
    rm "last.txt"
  fi
fi

if [ ! -d "$DEVICEROOT" ]; then
  echo "error: not found $DEVICEROOT/"
  exit
fi

if [ ! -f "/boot/orangepiEnv.txt.bak" ]; then
  echo "** backup: /boot/orangepiEnv.txt"
  sudo cp /boot/orangepiEnv.txt /boot/orangepiEnv.txt.bak
  sudo sed -i '/overlays=/d' /boot/orangepiEnv.txt
  sudo echo overlays=1368GHz profile-ver1.4-1.6-passive >> /boot/orangepiEnv.txt
fi

if [ -d "/boot/dtb/allwinner/overlay" ]; then
  if [ ! -d "/boot/dtb/allwinner/overlay.bak" ]; then
    echo "** backup: /boot/dtb/allwinner/overlay"
    sudo cp -rf "/boot/dtb/allwinner/overlay/" "/boot/dtb/allwinner/overlay.bak/"
  fi
  sudo rm /boot/dtb/allwinner/overlay/sun50i-h5-*.dtbo
fi

if [ -f "$DEVICEROOT/bootloader/$DEVICELOADER" ]; then
  echo "*** write: $DEVICEROOT/bootloader/$DEVICELOADER"
  sudo dd if=$DEVICEROOT/bootloader/$DEVICELOADER of=/dev/mmcblk0 bs=1024 seek=8 conv=notrunc
fi

if [ -f "$DEVICEROOT/dtb/$DEVICETREE" ]; then
  echo "*** write: $DEVICEROOT/dtb/$DEVICETREE"
  sudo cp -vf $DEVICEROOT/dtb/$DEVICETREE /boot/dtb/allwinner/
fi

echo "**** write: overlays"

for file in $DEVICEROOT/dtb/*.dtbo; do
  filename=$(basename ${file} | sed s/repka-pi3-overlay-//)
  sudo cp -vf "$file" "/boot/dtb/allwinner/overlay/$filename"
done
