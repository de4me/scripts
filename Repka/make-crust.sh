#!/bin/sh

# Make SCP firmware for sunxi SoCs
# version: 2025-02-15


if [ -z "$CRUSTROOT" ]; then
  export CRUSTROOT=~/crust
fi

if [ -z "$CROSS_COMPILE" ]; then
  export CROSS_COMPILE=or1k-elf-
fi

cd "$CRUSTROOT"
echo "crust: $CRUSTROOT"
echo "cross-compile: $CROSS_COMPILE"
sleep 2

make clean
make scp

cd ~/

