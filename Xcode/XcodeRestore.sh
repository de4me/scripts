#!/bin/bash

# Restore Xcode UserData directory from TAR archive
# version: 2025-02-27

export USERDATADIR="/Users/${USER}/Library/Developer/Xcode"
me=$(basename "$0")

if [ -z "$1" ]; then
  echo "Use: $me XcodeUserDate.tar.gz"
  exit
fi

if [ ! -f "$1" ]; then
  echo "Use: $me XcodeUserDate.tar.gz"
  exit
fi

mkdir -p "$USERDATADIR"
tar -xf "$1" -C "$USERDATADIR"
echo "completed"
