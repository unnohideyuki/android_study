Readme of hello
===============

android create project するとできる Hello World と同じものを、assembler (smali) をつかって再現します。
Android SDK の Command line tools とかの使い方とかの学習も含めて、いろいろ慣れるのが最初の目標。

なお、Windows 7 で使ってるターミナルは git bash。git bash 上で、*.bat なコマンドツールつかうのが、結構バッドノウハウ的な何かな感じ。

以下、調べたことメモ（あとでまとめる？）：

## ../bin/avd

git bash 上でただ普通に android avd とやると失敗するもので。
なぜ //c にしないといけない？

## build.sh

Android SDK command line tools の普通のやりかただと ant debug とやるのですが、そのときに行われるのと同等のことをシェルスクリプトに書いてみましたというやつ。

まだ、ちょっと、あんまりな感じですが、とりあえずできたような気がするバージョン。
いか、何をやってる（つもり）なのか、順番に述べてみる。

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

ant -v debug みただけでは、どうやって AndroidManifest.xml がつくられるのかわからなかったので、いまは ant debug でできたものをそのまま使っている。

### Android Manifest file のマージ

    # Merging Android Manifest file into one
    $aapt package -f -m -M bin/AndroidManifest.xml \
          -S bin/res \
          -S res \
          -I ${sdk_base}/platforms/android-19/android.jar \
          -J gen \
          --generate-dependencies \
          -G bin/proguard.txt

aapt というのは Android Asset Packaging Tool の略だそうだ。

オプションの意味

+ -f : 既存のファイルを上書きする
+ -m : -J で指定されたディレクトリにパッケージをつくる
+ -M : AndroidManifest.xml への full path (相対じゃだめなん？）
+ -S : リソースのあるディレクトリ
+ -I : base include set に既存のパッケージを追加する
+ -J : R.java resource constant 定義をどこに出力したらいいのかを指定
+ -G : proguard options を出力するファイルを指定する

よくわからないんだけど、ここでは bin/progurad.txt を作ってる？

## class.dex

src/ には、Java からつくった版の class.dex を disassemble したソースがあるので、それらを assemble してる。
ソースの中には、本当は、リソース定義 (xml) から生成すべきものもあると思っている。

いまは、ともかくやってみる段階

    # classes.dex
    java -jar $smalijar -o bin/classes.dex src/*.s
    
## crunch #とは？

    # crunch
    $aapt crunch -v -S res -C bin/res

aapt の help によれば、"Do PNG preprocessing on one or several resource folders and store the result in the output folder" だそうだ。

+ -v : verbose 
+ -S : resource-sources
+ -C : output-folder

## パッケージ

    # package-resource
    $aapt package --no-crunch -f --debug-mode \
          -M bin/AndroidManifest.xml \
          -S bin/res \
          -S res \
          -I ${sdk_base}/platforms/android-19/android.jar \
          -F bin/MyFirstApp.ap_ \
          --generate-dependencies

Android resources をパッケージします。-M, -A, -S などで指定されたアセット/リソースを読んで、-J, -P, -F および -R で制御された出力先に書く、と。
ここでは、bin/MyFirstApp.ap_ に書かれるのかな。いちおう、-F で指定されるのは apk-file らしい。

## apkbuilder

その昔は、apkbuilder という command line tool があったらしいが、いまは obsoleted で、ant task になっている。
そこで、apkbuilder task だけを抜き出した buil.xml を書いて、ここでは用いてみた。

    # apkbuilder
    ant

で、apkbuilder が何をしているのか、まだ、よくわからない。別の言い方をすると、MyFirstApp.ap_ と MyFirstApp-debug-unaligned.apk はどう違うの？ということかな。

あとで調べよう。

## zipalign

    # zipalign
    cd bin
    $zipalign -f 4 MyFirstApp-debug-unaligned.apk MyFirstApp-debug.apk

適切に padding して、apk ファイル中のコンポーネントがすべて 4-byte align されるようにします。

## その他

ちらっと、出来上がった apk の中をみたら、へんなところに *.s が転がってる気がした。なんか変かも。
  