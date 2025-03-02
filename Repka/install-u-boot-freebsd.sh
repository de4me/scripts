#!/bin/sh

# Repka bootloader writer
# version: 2025-02-18


if [ -z "$HOST" ]; then
  export HOST=freebsd-vm
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
    if [ $? -ne 0 ]; then
      echo "error: download $HOSTUSER@$HOST:~/$HOSTSOURCE"
      exit
    fi
  fi
  if [ -f "$1" ]; then
    echo "$1" > "last-u-boot.txt"
    if [ -d "$DEVICEROOT" ]; then
      echo "* delete: $DEVICEROOT/"
      rm -r "$DEVICEROOT/"
    fi
    echo "* unarchive: $1"
    tar -xzf "$1"
    if [ $? -ne 0 ]; then
      exit
    fi
  else
    echo "error: not found $1"
    exit
  fi
fi

if [ ! -d "$DEVICEROOT" ]; then
  echo "error: not found $DEVICEROOT/"
  exit
fi

if [ -f "$DEVICEROOT/bootloader/$DEVICELOADER" ]; then
    sysctl kern.geom.debugflags=16
    echo "** write: $DEVICEROOT/bootloader/$DEVICELOADER"
    dd if=$DEVICEROOT/bootloader/$DEVICELOADER of=/dev/mmcsd0 bs=1024 seek=128 conv=notrunc
    sysctl kern.geom.debugflags=0
fi

if [ -f "$DEVICEROOT/dtb/$DEVICETREE" ]; then
  echo "*** write: $DEVICEROOT/dtb/$DEVICETREE"
  cp -vf $DEVICEROOT/dtb/$DEVICETREE /boot/dtb/allwinner/sun50i-h5-repka-pi3.dtb
fi


