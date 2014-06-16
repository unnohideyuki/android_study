#!/bin/sh

#### From Environment Variables ####
smalijar=$SMALI_JAR

#### derived from adb's path ####
adb_path=`which adb`
adb_dir=`dirname $adb_path`
sdk_base="${adb_dir}/.."

aapt="${sdk_base}/build-tools/android-4.4.2/aapt"
zipalign="${sdk_base}/tools/zipalign"
sdklib="${sdk_base}/tools/lib/sdklib.jar"

# build-setup
mkdir -p bin
mkdir -p bin/res
mkdir -p bin/rsObj
mkdir -p bin/rsLibs
mkdir -p gen
mkdir -p bin/classes
mkdir -p bin/dexedLibs

# TODO: How to create AndroidManifest.xml?

# Merging Android Manifest file into one
$aapt package -f -m -M bin/AndroidManifest.xml \
      -S bin/res \
      -S res \
      -I ${sdk_base}/platforms/android-19/android.jar \
      -J gen \
      --generate-dependencies \
      -G bin/proguard.txt

# classes.dex
java -jar $smalijar -o bin/classes.dex src/*.s

# crunch
$aapt crunch -v -S res -C bin/res

# package-resource
$aapt package --no-crunch -f --debug-mode \
      -M bin/AndroidManifest.xml \
      -S bin/res \
      -S res \
      -I ${sdk_base}/platforms/android-19/android.jar \
      -F bin/MyFirstApp.ap_ \
      --generate-dependencies

# apkbuilder
ant

# zipalign
cd bin
$zipalign -f 4 MyFirstApp-debug-unaligned.apk MyFirstApp-debug.apk
