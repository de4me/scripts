#!/bin/bash

# Backup Xcode UserData directory
# version: 2025-02-27

export CURRENTDATE=$(date +"%Y%m%d")
export USERDATADIR="/Users/${USER}/Library/Developer/Xcode"
export BACKUPDIR=UserData
export TARGETFILE="XcodeBackup-${USER}-${CURRENTDATE}.tar.gz"

if [ ! -d "$BACKUPDIR" ]; then
  echo "* create directory: $BACKUPDIR"
  mkdir -p "$BACKUPDIR"
fi

cd "$BACKUPDIR"
echo "** create backup: $TARGETFILE"
tar --no-xattrs --directory "$USERDATADIR" --exclude="IB Support" --exclude="Previews" -czvf "$TARGETFILE" "UserData"

if [ $? -ne 0 ]; then
  echo "failed"
  exit
fi

echo "completed"