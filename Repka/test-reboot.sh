#!/bin/sh

# Reboot counter
# version: 2025-02-15


if [ -f ~/count.txt ]; then
  COUNT=`cat ~/count.txt`
else
  COUNT=0
fi

if [ -z "$1" ]; then
  TIMEOUT=60
else
  TIMEOUT=$1
fi

COUNT=$((COUNT+1))

echo $COUNT > ~/count.txt

sleep $TIMEOUT

reboot 

