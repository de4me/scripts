#!/bin/sh

# Install freebsd kernel
# Version: 2025-07-14


if [ -z "$HOST" ]; then
  export HOST=freebsd-vm
fi

if [ -z "$HOSTUSER" ]; then
  export HOSTUSER=denis
fi

if [ -z "$HOSTSOURCE" ]; then
  export HOSTSOURCE=kernel-freebsd.tar.gz
fi

cd ~/

if [ -n "$1" ]; then
  if [ ! -f "$1" ]; then
    echo "* download: $HOSTUSER@$HOST:~/$HOSTSOURCE"
    scp $HOSTUSER@$HOST:~/$HOSTSOURCE "$1"
  fi
  if [ -f "$1" ]; then
    echo "$1" > last-kernel.txt
    if [ -d kernel/ ]; then
      echo "* delete: kernel"
      rm -r kernel/
    fi
    echo "* unarchive: $1"
    tar -xzvf "$1"
    if [ $? -ne 0 ]; then
      exit
    fi
  fi
fi

if [ ! -d kernel/ ]; then
  echo "error: directory kernel/ not found";
  exit
fi

if [ -d /boot/kernel.bak ]; then
  echo "** backup kernel: /boot/kernel"
  cp -r /boot/kernel/ /boot/kernel.bak/
fi

if [ -d /boot/kernel/ ]; then
  echo "*** delete: /boot/kernel/"
  rm -rf /boot/kernel/
fi

echo "*** install: kernel/"
cp -rv kernel/ /boot/kernel/

if [ $? -ne 0 ]; then
  exit
fi

echo "completed"

