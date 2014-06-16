MyFirstApp
==========

## やりたかったこと/やったこと

Getting Started にある MyFirstApp を、Java ではなく assembly で再現する。

Disassemble した結果を src/*.s に格納。
MainActivity.s 以外のものは、res/ の内容から生成すべきだと思われるが、
まずは、そのまま smali にかけて classes.dex とする。

それ以外は、ant -v debug 結果を参考に、build.sh を書いた。

apkbuilder は、ant task としてしかサポートされていないようだったので、
apkbuilder を呼ぶための build.xml を書いて、build.sh から ant を呼んでいる。

./build.sh した結果できあがった bin/MyFirstApp-debug.apk を
adb install bin/Hello-debug.apk したら、一応ちゃんと動いた。

## TODO

AndroidManifest.xml をつくる（いまは借り物）
MainActivity.s 以外のクラス定義を、（たぶん）リソース定義から生成する。

