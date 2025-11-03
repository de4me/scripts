#!/usr/bin/bash

# Repka bootloader writer
# version: 2025-07-20


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

#
# VARIABLES
#

if [ "$1" == "v" ]; then
  echo "HOST=$HOST"
  echo "HOSTUSER=$HOSTUSER"
  echo "HOSTSOURCE=$HOSTSOURCE"
  echo "DEVICELOADER=$DEVICELOADER"
  echo "DEVICETREE=$DEVICETREE"
  echo "DEVICEROOT=$DEVICEROOT"
  exit 0
fi

#
# RESTORE
#

if [ "$1" == "restore" ]; then
  if [ -f "/boot/u-boot-sunxi-with-spl.bin.bak" ]; then
    echo "* restore: /boot/u-boot-sunxi-with-spl.bin.bak"
    sudo dd if=/boot/u-boot-sunxi-with-spl.bin.bak of=/dev/mmcblk0 bs=1024 seek=8
  fi
  if [ -f "/boot/repka-pi.dtb.bak" ]; then
    echo "* restore: /boot/repka-pi.dtb.bak"
    sudo rm -f "/boot/repka-pi.dtb"
    sudo cp -fv "/boot/repka-pi.dtb.bak" "/boot/repka-pi.dtb"
  fi
  if [ -d "/boot/overlays.bak" ]; then
    echo "* restore: /boot/overlays.bak"
    sudo rm -rf "/boot/overlays/"
    sudo cp -rfv "/boot/overlays.bak" "/boot/overlays"
  fi
  exit 0
fi

#
# DOWNLOAD / UNPACK
#

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

#
# BACKUP
#

if [ ! -f "/boot/u-boot-sunxi-with-spl.bin.bak" ]; then
  echo "** backup: /boot/u-boot-sunxi-with-spl.bin.bak"
  sudo dd if=/dev/mmcblk0 of=/boot/u-boot-sunxi-with-spl.bin.bak bs=1024 skip=8 count=1017
fi

if [ ! -f "/boot/repka-pi.dtb.bak" ]; then
  echo "** backup: /boot/repka-pi.dtb"
  sudo mv -f "/boot/repka-pi.dtb" "/boot/repka-pi.dtb.bak"
fi

if [ ! -d "/boot/overlays.bak" ]; then
  echo "** backup: /boot/overlays/"
  sudo cp -rf "/boot/overlays/" "/boot/overlays.bak/"
fi

#
# WRITE
#

if [ -f "$DEVICEROOT/bootloader/$DEVICELOADER" ]; then
  echo "*** write: $DEVICEROOT/bootloader/$DEVICELOADER"
  sudo dd if=$DEVICEROOT/bootloader/$DEVICELOADER of=/dev/mmcblk0 bs=1024 seek=8
fi

if [ -f "$DEVICEROOT/dtb/$DEVICETREE" ]; then
  echo "*** write: $DEVICEROOT/dtb/$DEVICETREE"
  sudo cp -vf $DEVICEROOT/dtb/$DEVICETREE /boot/repka-pi.dtb
fi

if [ -d "/boot/overlays/" ]; then
  echo "*** write: overlays"
  sudo rm -f "/boot/overlays/*.dtbo"
  for file in $DEVICEROOT/dtb/*.dtbo; do
    filename=$(basename ${file} | sed s/sun50i-h5-repka-pi3-overlay-//)
    sudo cp -vf "$file" "/boot/overlays/$filename"
  done
fi
