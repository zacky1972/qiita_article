---
title: TOPPERSカーネルのコンフィギュレータをHomebrew最新版のBoostでビルドする
tags:
  - homebrew
  - boost
  - TOPPERS
private: false
updated_at: '2023-01-29T07:49:15+09:00'
id: aa4507d6613a0e8bbf11
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[TOPPERSカーネルをビルドするときに必要なコンフィギュレータ(バージョン1.9.6)](https://www.toppers.jp/cfg.html)をApple Silicon Macでビルドしたときに，つまづいてしまい，@mitsu48さんに助けていただきました．

https://github.com/toppers/users-forum/discussions/98

コンフィギュレータのビルドにはBoostを必要とするのですが，今回私はHomebrewでインストール済みのBoostを使おうとしたところ，Boost 1.67.0 以降では`boost/utility.hpp`に`boost::next`と`boost::prior`が含まれておらず，`boost/next_prior.hpp`をインクルードする必要があるというのが原因でした．

他にも，C++11でコンパイルするというオプションをつける必要があります．

というわけで，手順をまとめてみました．

1. `cfg-1.9.6.tar.gz` (2023年1月現在最新版)を　https://www.toppers.jp/cfg.html からダウンロード
1. `tar xvfz cfg-1.9.6.tar.gz`
1. `cd cfg`
1. `./configure`の改行コードを`CR/LF`から`LF`に変更
    1. ファイルの文字コードがISO-8859-1である点に注意
1. `./configure`の31行目と48行目を`configure`の`diff`のように変更
1. `./configure`を実行
1. `Makefile.config`の末尾の`OPTIONS=`の部分を`OPTIONS="-std=c++11"`に変更
1. `toppers/cpp.hpp`の47行目に`#include <boost/next_prior.hpp>`を追記(`toppers/cpp.hpp`を参考にしてください)
1. `toppers/text.hpp`の57行目に`#include <boost/next_prior.hpp>`を追記(`toppers/text.hpp`を参考にしてください)
1. `make -j$(nproc)`

これでビルドできると思います．

```diff:configure
@@ -28,7 +28,7 @@
 done
 
 # Boost C++ Libraries?Υإå??ե????뤬????ǥ??쥯?ȥ?򥵡???
-for dir in $include_path "/usr/local/include" "/opt/local/include" "/opt/include" "/usr/include" "/mingw/include"
+for dir in $include_path "/usr/local/include" "/opt/local/include" "/opt/include" "/usr/include" "/mingw/include" "`brew --prefix boost`/include"
 do
 	ls $dir/boost* 2> /dev/null > /dev/null
 	if test $? -eq 0
@@ -45,7 +45,7 @@
 done
 
 # Boost C++ Libraries?Υ饤?֥??ե????뤬????ǥ??쥯?ȥ?򥵡???
-for dir in $library_path "/usr/local/lib" "/opt/local/lib" "/opt/lib" "/usr/lib" "/lib" "/mingw/lib"
+for dir in $library_path "/usr/local/lib" "/opt/local/lib" "/opt/lib" "/usr/lib" "/lib" "/mingw/lib" "`brew --prefix boost`/lib"
 do
 	ls $dir/libboost* 2> /dev/null > /dev/null
 	if test $? -eq 0
```

```diff:toppers/cpp.hpp
@@ -44,6 +44,7 @@
 #include "toppers/codeset.hpp"
 #include "toppers/diagnostics.hpp"
 #include <boost/utility.hpp>
+#include <boost/next_prior.hpp>
 #include <boost/filesystem/path.hpp>
 #include <boost/filesystem/operations.hpp>
 #include <boost/filesystem/exception.hpp>
```

```diff:toppers/text.hpp
@@ -54,6 +54,7 @@
 #include "toppers/text_line.hpp"
 #include "toppers/misc.hpp"
 #include <boost/utility.hpp>
+#include <boost/next_prior.hpp>
 #include <boost/iterator/iterator_facade.hpp>
 #include <boost/format.hpp>
```



