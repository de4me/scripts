#!/usr/bin/bash

# Repka bootloader writer
# version: 2015-02-15


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
  export DEVICETREE=sun50i-h5-repka-pi3-v1.4.dtb
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

if [ -f "/boot/repkaEnv.txt" ]; then
  if [ -f "/boot/repkaEnv.txt.bak" ]; then
    sudo rm -f "/boot/repkaEnv.txt"
  else
    echo "** backup: /boot/repkaEnv.txt"
    sudo mv -f "/boot/repkaEnv.txt" "/boot/repkaEnv.txt.bak"
  fi
fi

if [ ! -f "/boot/repka-pi.dtb.bak" ]; then
  echo "** backup: /boot/repka-pi.dtb"
  sudo mv -f "/boot/repka-pi.dtb" "/boot/repka-pi.dtb.bak"
fi

if [ -f "$DEVICEROOT/bootloader/$DEVICELOADER" ]; then
  echo "*** write: $DEVICEROOT/bootloader/$DEVICELOADER"
  sudo dd if=$DEVICEROOT/bootloader/$DEVICELOADER of=/dev/mmcblk0 bs=1024 seek=8 conv=notrunc
fi

if [ -f "$DEVICEROOT/dtb/$DEVICETREE" ]; then
  echo "*** write: $DEVICEROOT/dtb/$DEVICETREE"
  sudo cp -vf $DEVICEROOT/dtb/$DEVICETREE /boot/repka-pi.dtb
fi

