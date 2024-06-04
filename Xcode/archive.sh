#/bin/bash

#
# Xcode Archive script
#

if [ -z "$1" ] || [ -z "$2" ]
then
    echo
    echo "use: ${0##*/} project.xcodeproj scheme_base_name"
    echo
    echo "where:"
    echo "  scheme_base_name        for macOS"
    echo "  scheme_base_name-iOS    for iOS, iphoneSimulator, macCatalyst"
    echo
    exit -1
fi

ROOT=$(pwd)
ARCHIVE_ROOT="${ROOT%/*}/Archives/$(date '+%Y-%m-%d')"

if [ ! -d "$ARCHIVE_ROOT" ]; then
  mkdir -p "$ARCHIVE_ROOT"
fi

ARRAY=()

ARCHIVE_PATH="$ARCHIVE_ROOT/$2 $(date '+%d.%m.%Y, %H.%M.%S').xcarchive"

xcodebuild archive -project $1 -scheme $2 -destination "generic/platform=macOS" -archivePath "$ARCHIVE_PATH"

if [ "$?" -eq "0" ]; then
  ARRAY+=( "\"$ARCHIVE_PATH\"" )
fi

ARCHIVE_PATH="$ARCHIVE_ROOT/$2-iOS $(date '+%d.%m.%Y, %H.%M.%S').xcarchive"

xcodebuild archive -project $1 -scheme $2-iOS -destination "generic/platform=iOS" -archivePath "$ARCHIVE_PATH"

if [ "$?" -eq "0" ]; then
  ARRAY+=( "\"$ARCHIVE_PATH\"" )
fi

ARCHIVE_PATH="$ARCHIVE_ROOT/$2-iOS $(date '+%d.%m.%Y, %H.%M.%S').xcarchive"

xcodebuild archive -project $1 -scheme $2-iOS -destination "generic/platform=iOS Simulator" -archivePath "$ARCHIVE_PATH"

if [ "$?" -eq "0" ]; then
  ARRAY+=( "\"$ARCHIVE_PATH\"" )
fi

ARCHIVE_PATH="$ARCHIVE_ROOT/$2 $(date '+%d.%m.%Y, %H.%M.%S').xcarchive"

xcodebuild archive -project $1 -scheme $2-iOS -destination "generic/platform=macOS,variant=Mac Catalyst" -archivePath "$ARCHIVE_PATH"

if [ "$?" -eq "0" ]; then
  ARRAY+=( "\"$ARCHIVE_PATH\"" )
fi

echo "\n\nresult ${#ARRAY[@]}/4: ${ARRAY[*]}"

echo ${ARRAY[*]} | pbcopy
