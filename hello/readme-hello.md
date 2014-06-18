Readme of hello
===============

android create project ����Ƃł��� Hello World �Ɠ������̂��Aassembler (smali) �������čČ����܂��B
Android SDK �� Command line tools �Ƃ��̎g�����Ƃ��̊w�K���܂߂āA���낢�늵���̂��ŏ��̖ڕW�B

�Ȃ��AWindows 7 �Ŏg���Ă�^�[�~�i���� git bash�Bgit bash ��ŁA*.bat �ȃR�}���h�c�[�������̂��A���\�o�b�h�m�E�n�E�I�ȉ����Ȋ����B

�ȉ��A���ׂ����ƃ����i���Ƃł܂Ƃ߂�H�j�F

## ../bin/avd

git bash ��ł������ʂ� android avd �Ƃ��Ǝ��s������̂ŁB
�Ȃ� //c �ɂ��Ȃ��Ƃ����Ȃ��H

## build.sh

Android SDK command line tools �̕��ʂ̂�肩������ ant debug �Ƃ��̂ł����A���̂Ƃ��ɍs����̂Ɠ����̂��Ƃ��V�F���X�N���v�g�ɏ����Ă݂܂����Ƃ�����B

�܂��A������ƁA����܂�Ȋ����ł����A�Ƃ肠�����ł����悤�ȋC������o�[�W�����B
�����A��������Ă�i����j�Ȃ̂��A���Ԃɏq�ׂĂ݂�B

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

### AndroidManifest.xml

    # TODO: How to create AndroidManifest.xml?

ant -v debug �݂������ł́A�ǂ������ AndroidManifest.xml ��������̂��킩��Ȃ������̂ŁA���܂� ant debug �łł������̂����̂܂܎g���Ă���B

### Android Manifest file �̃}�[�W

    # Merging Android Manifest file into one
    $aapt package -f -m -M bin/AndroidManifest.xml \
          -S bin/res \
          -S res \
          -I ${sdk_base}/platforms/android-19/android.jar \
          -J gen \
          --generate-dependencies \
          -G bin/proguard.txt

aapt �Ƃ����̂� Android Asset Packaging Tool �̗����������B

�I�v�V�����̈Ӗ�

+ -f : �����̃t�@�C�����㏑������
+ -m : -J �Ŏw�肳�ꂽ�f�B���N�g���Ƀp�b�P�[�W������
+ -M : AndroidManifest.xml �ւ� full path (���΂��Ⴞ�߂Ȃ�H�j
+ -S : ���\�[�X�̂���f�B���N�g��
+ -I : base include set �Ɋ����̃p�b�P�[�W��ǉ�����
+ -J : R.java resource constant ��`���ǂ��ɏo�͂����炢���̂����w��
+ -G : proguard options ���o�͂���t�@�C�����w�肷��

�悭�킩��Ȃ��񂾂��ǁA�����ł� bin/progurad.txt ������Ă�H

## class.dex

src/ �ɂ́AJava ����������ł� class.dex �� disassemble �����\�[�X������̂ŁA������ assemble ���Ă�B
�\�[�X�̒��ɂ́A�{���́A���\�[�X��` (xml) ���琶�����ׂ����̂�����Ǝv���Ă���B

���܂́A�Ƃ���������Ă݂�i�K

    # classes.dex
    java -jar $smalijar -o bin/classes.dex src/*.s
    
## crunch #�Ƃ́H

    # crunch
    $aapt crunch -v -S res -C bin/res

aapt �� help �ɂ��΁A"Do PNG preprocessing on one or several resource folders and store the result in the output folder" ���������B

+ -v : verbose 
+ -S : resource-sources
+ -C : output-folder

## �p�b�P�[�W

    # package-resource
    $aapt package --no-crunch -f --debug-mode \
          -M bin/AndroidManifest.xml \
          -S bin/res \
          -S res \
          -I ${sdk_base}/platforms/android-19/android.jar \
          -F bin/MyFirstApp.ap_ \
          --generate-dependencies

Android resources ���p�b�P�[�W���܂��B-M, -A, -S �ȂǂŎw�肳�ꂽ�A�Z�b�g/���\�[�X��ǂ�ŁA-J, -P, -F ����� -R �Ő��䂳�ꂽ�o�͐�ɏ����A�ƁB
�����ł́Abin/MyFirstApp.ap_ �ɏ������̂��ȁB���������A-F �Ŏw�肳���̂� apk-file �炵���B

## apkbuilder

���̐̂́Aapkbuilder �Ƃ��� command line tool ���������炵�����A���܂� obsoleted �ŁAant task �ɂȂ��Ă���B
�����ŁAapkbuilder task �����𔲂��o���� buil.xml �������āA�����ł͗p���Ă݂��B

    # apkbuilder
    ant

�ŁAapkbuilder ���������Ă���̂��A�܂��A�悭�킩��Ȃ��B�ʂ̌�����������ƁAMyFirstApp.ap_ �� MyFirstApp-debug-unaligned.apk �͂ǂ��Ⴄ�́H�Ƃ������Ƃ��ȁB

���ƂŒ��ׂ悤�B

## zipalign

    # zipalign
    cd bin
    $zipalign -f 4 MyFirstApp-debug-unaligned.apk MyFirstApp-debug.apk

�K�؂� padding ���āAapk �t�@�C�����̃R���|�[�l���g�����ׂ� 4-byte align �����悤�ɂ��܂��B

## ���̑�

������ƁA�o���オ���� apk �̒����݂���A�ւ�ȂƂ���� *.s ���]�����Ă�C�������B�Ȃ񂩕ς����B
  