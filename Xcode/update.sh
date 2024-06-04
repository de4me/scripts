#/bin/bash

set -e
  
shopt -s nocasematch

ROOT=$(pwd)
SUPPORTED_PLATFORMS=()
DTPLATFORMNAME=()
LSMINIMUMSYSTEMVERSION=()
DTPLATFORMVERSION=()
DTXCODE=()
CFBUNDLESHORTVERSIONSTRING=()
FRAMEWORK_DATE=()

function process_macos {
  PROJECT_NAME=$2
  local project_info="$1/Products/Library/Frameworks/${PROJECT_NAME}.framework/Versions/A/Resources/Info"
  local minimumsystemversion=$(defaults read "$project_info" "LSMinimumSystemVersion")
  local platformname=$(defaults read "$project_info" "DTPlatformName")
  local platformversion=$(defaults read "$project_info" "DTPlatformVersion")
  local dtxcode=$(defaults read "$project_info" "DTXcode")
  local cfbundleshortversionstring=$(defaults read "$project_info" "CFBundleShortVersionString")
#  MINIMUM_SYSTEM_VERSION=$(echo $LSMINIMUMSYSTEMVERSION | sed -r 's/[.]+/_/g')
  local framework_date="$3 $4"
  
  if [ ! -z $SUPPORTED_PLATFORMS ]
  then
    SUPPORTED_PLATFORMS+=( "," )
  fi
  
  SUPPORTED_PLATFORMS+=( ".macOS(\"$minimumsystemversion\")" )
  DTPLATFORMNAME+=( "$platformname" )
  LSMINIMUMSYSTEMVERSION+=( "$platformname($minimumsystemversion)" )
  DTPLATFORMVERSION+=( "$platformname($platformversion)" )
  DTXCODE+=( "$platformname($dtxcode)" )
  CFBUNDLESHORTVERSIONSTRING+=( "$platformname($cfbundleshortversionstring)" )
  FRAMEWORK_DATE+=( "$platformname($framework_date)" )
  
  echo "\nprocess: $PROJECT_NAME ($framework_date)"
  echo "$platformname: $minimumsystemversion - $platformversion\n"
}

function process_ios {
  PROJECT_NAME=${2%-iOS}
  local project_info="$1/Products/Library/Frameworks/${PROJECT_NAME}.framework/Info"
  local minimumsystemversion=$(defaults read "$project_info" "MinimumOSVersion")
  local platformname=$(defaults read "$project_info" "DTPlatformName")
  local platformversion=$(defaults read "$project_info" "DTPlatformVersion")
  local dtxcode=$(defaults read "$project_info" "DTXcode")
  local cfbundleshortversionstring=$(defaults read "$project_info" "CFBundleShortVersionString")
#  MINIMUM_SYSTEM_VERSION=$(echo $LSMINIMUMSYSTEMVERSION | sed -r 's/[.]+/_/g')
  local framework_date="$3 $4"
  
  if [ ! -z $SUPPORTED_PLATFORMS ]
  then
    SUPPORTED_PLATFORMS+=( "," )
  fi
  
  SUPPORTED_PLATFORMS+=( ".iOS(\"$minimumsystemversion\")" )
  DTPLATFORMNAME+=( "$platformname" )
  LSMINIMUMSYSTEMVERSION+=( "$platformname($minimumsystemversion)" )
  DTPLATFORMVERSION+=( "$platformname($platformversion)" )
  DTXCODE+=( "$platformname($dtxcode)" )
  CFBUNDLESHORTVERSIONSTRING+=( "$platformname($cfbundleshortversionstring)" )
  FRAMEWORK_DATE+=( "$platformname($framework_date)" )

  echo "\nprocess: $PROJECT_NAME ($framework_date)"
  echo "$platformname: $minimumsystemversion - $platformversion\n"
}

function process {
  local archive_file=${1##*/}
  local archive_name=${archive_file%.*}
  local array=($archive_name)
  case ${array[0]} in
    *iOS) process_ios "$1" ${array[*]} ;;
    *) process_macos "$1" ${array[*]} ;;
  esac
}

COMMAND=( "-create-xcframework" )

for arg in "$@"
do
  process "$arg"
  COMMAND+=( "-archive" )
  COMMAND+=( "$arg" )
  COMMAND+=( "-framework" )
  COMMAND+=( "$PROJECT_NAME.framework" )
done

XCFRAMEWORK_FOLDER="Library"
PACKAGE_PATH="$ROOT/${PROJECT_NAME}-package"
XCFRAMEWORK_PATH="$PACKAGE_PATH/$XCFRAMEWORK_FOLDER"
XCFRAMEWORK_BUNDLE_NAME="${PROJECT_NAME}.xcframework"
XCFRAMEWORK_ZIP_NAME="${PROJECT_NAME}.zip"

COMMAND+=( "-output" )
COMMAND+=( "$XCFRAMEWORK_BUNDLE_NAME" )

if [ ! -d "$PACKAGE_PATH" ]; then
  mkdir -p "$PACKAGE_PATH"
  cd "$PACKAGE_PATH"
  swift package init --type library --name $PROJECT_NAME
  sed -i "" -e "1s#.*#// swift-tools-version: 5.4#" Package.swift
  echo "\n//platforms: [\n//\t${SUPPORTED_PLATFORMS[*]}\n//]," >> Package.swift
  echo "\n//.binaryTarget(\n//\tname: \"${PROJECT_NAME}\",\n//\tpath: \"$XCFRAMEWORK_FOLDER/${XCFRAMEWORK_BUNDLE_NAME}\")" >> Package.swift
  echo "*.xcframework/" >> .gitignore
  rm -rf Sources Tests
else
  cd "$PACKAGE_PATH"
fi

if [ ! -d "$XCFRAMEWORK_PATH" ]; then
  mkdir -p "$XCFRAMEWORK_PATH"
fi

cd "$XCFRAMEWORK_PATH"

if [ -d "$XCFRAMEWORK_BUNDLE_NAME" ]; then
  rm -rf $XCFRAMEWORK_BUNDLE_NAME
fi

if [ -f $XCFRAMEWORK_ZIP_NAME ]; then
  rm "$XCFRAMEWORK_ZIP_NAME"
fi

xcodebuild "${COMMAND[@]}"

zip -9rqy $XCFRAMEWORK_ZIP_NAME $XCFRAMEWORK_BUNDLE_NAME

CHECKSUM=$(swift package compute-checksum $XCFRAMEWORK_ZIP_NAME)

echo "package: $PROJECT_NAME" > Package.txt
echo "platformname: ${DTPLATFORMNAME[*]}" >> Package.txt
echo "date: ${FRAMEWORK_DATE[*]}" >> Package.txt
echo "minimumversion: ${LSMINIMUMSYSTEMVERSION[*]}" >> Package.txt
echo "platformversion: ${DTPLATFORMVERSION[*]}" >> Package.txt
echo "sdkversion: ${DTXCODE[*]}" >> Package.txt
echo "bundleversion: ${CFBUNDLESHORTVERSIONSTRING[*]}" >> Package.txt
echo "checksum: $CHECKSUM" >> Package.txt

echo "checksum: $CHECKSUM"

cd $ROOT
