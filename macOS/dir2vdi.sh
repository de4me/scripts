#!/bin/bash

if [ -z "$1" ]; then
    echo "using: ${0##*/} source_folder [output.vdi]"
    echo "  source_folder: copies file-by-file the contents of source into image"
    echo "  output.vdi: result VDI"
    exit 0
fi

NAME="${1##*/}"
OUTPUT="${NAME}.vdi"
TEMPEXT="tmp${RANDOM}"

if ! [ -z "$2" ]; then
    if [ -z "${2##*.vdi}" ]; then
         OUTPUT="$2"
    else
         OUTPUT="$2.vdi"
    fi
fi

# set strict and verbose modes for bash
set -e
set -x

# create temporary DMG
hdiutil create -srcfolder "$1" -align 4k -fs HFS+J -volname "${NAME}" -format UDRW -noatomic -o "${NAME}.${TEMPEXT}.dmg"

# convert DMG to VDI
VBoxManage convertdd --format VDI --variant Fixed "${NAME}.${TEMPEXT}.dmg" "${OUTPUT}"

# remove temporary DMG
rm "${NAME}.${TEMPEXT}.dmg"
