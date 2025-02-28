#!/bin/sh

# Convert DTB to DTS
# version: 2025-02-25


if [ -z "$1" ]; then
  exit
fi

if [ -z "$2" ]; then
  export FILENAME="$(basename "$1")"
  export OUTPUTFILE=${FILENAME%.*}.dts
else
  export FILENAME="$2"
  export OUTPUTFILE="$2"
fi

~/u-boot-repka/scripts/dtc/dtc -I dtb -O dts "$1" -o "$OUTPUTFILE"

if [ $? -ne 0 ]; then
  exit
fi

grep -v "handle =" "$OUTPUTFILE" > "${OUTPUTFILE%.*}-nohandle.${OUTPUTFILE##*.}"

echo "INPUTFILE: $1"
echo "OUTPUTFILE: $OUTPUTFILE"
echo "completed"

