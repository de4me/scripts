#!/bin/bash
#
# Bash script to create a Bootable ISO from macOS disk image
# Download disk image: https://support.apple.com/en-us/HT211683

# case-insensitive compare
shopt -s nocasematch
# set strict and verbose modes for bash
set -e

if [ -z "$1" ] || ! [ -z "${1##*.dmg}" ]; then
    echo "using: ${0##*/} input.dmg [output.iso]"
    echo "  input.dmg:  macOS install disk image"
    echo "  output.iso: name for result ISO"
    exit 0
fi

NAMEEXT="${1##*/}"
NAME="${NAMEEXT%%.*}"
OUTPUT="${NAME}.iso"
TEMPEXT="tmp${RANDOM}"

if ! [ -z "$2" ]; then
    if [ -z "${2##*.iso}" ] || [ -z "${2##*.dmg}" ]; then
         OUTPUT="$2"
    else
         OUTPUT="$2.iso"
    fi
fi

# DMG size
case "${NAME}" in
    *sierra*) DMGSIZE="6100m";;
    *capitan*) DMGSIZE="7400m";;
    *yosemite*) DMGSIZE="6900m";;
    *mountain*lion*) DMGSIZE="5500m";;
    *lion*) DMGSIZE="5800m";;
    *) DMGSIZE="7900m";;
esac

# print commands
set -x

# mount the full installer
hdiutil attach "$1" -noverify -nobrowse -mountpoint "/Volumes/Install Mac OS X"

if [ -f "/Volumes/Install Mac OS X/InstallMacOSX.pkg" ]; then
    pkgutil --expand "/Volumes/Install Mac OS X/InstallMacOSX.pkg" "Install Mac OS X.${TEMPEXT}/"
elif [ -f "/Volumes/Install Mac OS X/InstallOS.pkg" ]; then
    pkgutil --expand "/Volumes/Install Mac OS X/InstallOS.pkg" "Install Mac OS X.${TEMPEXT}/"
else
    echo "TERMINATED: Unknown package name"
    exit 0;
fi

hdiutil detach "/Volumes/Install Mac OS X"

# mount DMG installer to macOS
if [ -d "Install Mac OS X.${TEMPEXT}/InstallMacOSX.pkg" ]; then
    hdiutil attach "Install Mac OS X.${TEMPEXT}/InstallMacOSX.pkg/InstallESD.dmg" -noverify -nobrowse -mountpoint "/Volumes/Mac OS X Install ESD"
elif [ -d "Install Mac OS X.${TEMPEXT}/InstallOS.pkg" ]; then
    hdiutil attach "Install Mac OS X.${TEMPEXT}/InstallOS.pkg/InstallESD.dmg" -noverify -nobrowse -mountpoint "/Volumes/Mac OS X Install ESD"
fi

# create a DMG disk
hdiutil create -o "${NAME}.${TEMPEXT}.dmg" -size "${DMGSIZE}" -volname output -layout SPUD -fs HFS+J

# mount disk to your macOS
hdiutil attach "${NAME}.${TEMPEXT}.dmg" -noverify -mountpoint "/Volumes/output"

# create macOS installer disk
asr restore -source "/Volumes/Mac OS X Install ESD/BaseSystem.dmg" -target "/Volumes/output" -noprompt -noverify -erase

if [ -d "/Volumes/OS X Base System" ]; then
    TARGET="/Volumes/OS X Base System"
elif [ -d "/Volumes/Mac OS X Base System" ]; then
    TARGET="/Volumes/Mac OS X Base System"
else
    echo "TERMINATED: Unknown volume name"
    diskutil list
    exit 0
fi

# required
rm "$TARGET/System/Installation/Packages"
cp -rp "/Volumes/Mac OS X Install ESD/Packages" "$TARGET/System/Installation/"
cp -rp "/Volumes/Mac OS X Install ESD/BaseSystem.chunklist" "$TARGET"
cp -rp "/Volumes/Mac OS X Install ESD/BaseSystem.dmg" "$TARGET"

# optional
if [ -f "/Volumes/Mac OS X Install ESD/boot.efi" ]; then
    cp -rp "/Volumes/Mac OS X Install ESD/boot.efi" "$TARGET"
fi

if [ -f "/Volumes/Mac OS X Install ESD/.disk_label" ]; then
    cp -rp "/Volumes/Mac OS X Install ESD/.disk_label" "$TARGET"
fi

if [ -f "/Volumes/Mac OS X Install ESD/.disk_label_2x" ]; then
    cp -rp "/Volumes/Mac OS X Install ESD/.disk_label_2x" "$TARGET"
fi

if [ -f "/Volumes/Mac OS X Install ESD/kernelcache" ]; then
    cp -rp "/Volumes/Mac OS X Install ESD/kernelcache" "$TARGET"
fi

if [ -f "/Volumes/Mac OS X Install ESD/mach_kernel" ]; then
    cp -rp "/Volumes/Mac OS X Install ESD/mach_kernel" "$TARGET"
fi

if [ -f "/Volumes/Mac OS X Install ESD/AppleDiagnostics.chunklist" ]; then
    cp -rp "/Volumes/Mac OS X Install ESD/AppleDiagnostics.chunklist" "$TARGET"
fi

if [ -f "/Volumes/Mac OS X Install ESD/AppleDiagnostics.dmg" ]; then
    cp -rp "/Volumes/Mac OS X Install ESD/AppleDiagnostics.dmg" "$TARGET"
fi

diskutil rename "$TARGET" "Install Mac OS X"
hdiutil detach "/Volumes/Install Mac OS X"
hdiutil detach "/Volumes/Mac OS X Install ESD"

# remove temporary directory
rm -rf "Install Mac OS X.${TEMPEXT}/"

if [ -z "${OUTPUT##*.iso}" ]; then
    # convert DMG Disk to ISO File
    hdiutil convert "${NAME}.${TEMPEXT}.dmg" -format UDTO -o "${NAME}.${TEMPEXT}.cdr"
    # rename
    mv "${NAME}.${TEMPEXT}.cdr" "${OUTPUT}"
    # remove temporary DMG
    rm "${NAME}.${TEMPEXT}.dmg"
else
    # rename
    mv "${NAME}.${TEMPEXT}.dmg" "${OUTPUT}"
fi
