---
title: どうやら Erlang をコンパイルした時のCコンパイラによって Elixir の性能がかなり異なるようだ
tags:
  - Erlang
  - Elixir
  - Pelemay
private: false
updated_at: '2019-12-20T15:27:38+09:00'
id: 8ff9775d83062fd097be
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[「fukuoka.ex Elixir／Phoenix Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/fukuokaex)16日目です。

昨日の[「fukuoka.ex Elixir／Phoenix Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/fukuokaex)は @pojiro さんの[「作って学ぶPhoenix、IoTサーバー」](https://qiita.com/pojiro/items/ae53b46e4d9d66a4de69)でした。
 

前回は[「#NervesJP Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/nervesjp)12日目と13日目にそれぞれ[「Nerves の可能性は IoT だけじゃない(前編)〜ElixirとPelemayで世界の消費電力を抑える」](https://qiita.com/zacky1972/items/2c82a593fbb2e4c949d2)と[「Nerves の可能性は IoT だけじゃない(後編)〜Nervesで世界の消費電力を抑える」](https://qiita.com/zacky1972/items/ebdf9b3f048256b90c52)をお届けしました。

さて2019年11月の頭にこんなツイートをして反響を呼びました。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">今日知った衝撃の事実。Elixir は，Erlang を GCC でコンパイルするのか，Clang でコンパイルするのか，Apple Clang でコンパイルするのかによって，性能がかなり異なる。</p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1192259616236691456?ref_src=twsrc%5Etfw">November 7, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

今回はきちんと環境構築からやり直して，この問題について検証してみたいと思います。

# 環境構築

方針としては次の通りにしたいと思います。

1. Erlang は `kerl` で管理する (`asdf` では同じバージョンでビルド方法が違う Erlang を共存させることができない)
2. Elixir は `asdf` で管理する

## asdf でインストールした Erlang の削除

asdf でインストールした Erlang を次のような手順で削除します。

1. `asdf list` でインストールされている Erlang を調べる。
	* もし `erlang` という欄がなければ，そもそも Erlang プラグインをインストールしていないので，終了する
	* もし `erlang` とは表示されているが，インストールされている Erlang のバージョンが存在しない場合には，3 へ
2. `asdf uninstall erlang (バージョン番号)` で一つ一つバージョンを指定して削除する。全て無くなったら 3 へ
3. `asdf plugin-remove erlang` で Erlang プラグインを削除する

## kerl のインストール

asdf や kerl でビルドしたことがない場合には，次のドキュメントの Before asdf install の該当項目に沿って，必要なライブラリやツール等をインストールしておきます。

https://github.com/asdf-vm/asdf-erlang

kerl は Mac だと HomeBrew でインストールできます。


```
$ brew install kerl
```


Mac で HomeBrew を使わない場合や，Linux では次のような手順で　kerl をインストールします。

```
$ curl -O https://raw.githubusercontent.com/kerl/kerl/master/kerl
$ chmod +x ./kerl
$ sudo mv kerl (インストールしたいディレクトリ 例えば /usr/local/bin など)
```

どちらの場合も，最新のリストを取ってくるために次のコマンドを実行します。

```
$ kerl update releases
```

次のコマンドでインストールできる Erlang のバージョンを確認します。

```
$ kerl list releases
```

## Cコンパイラの確認

Mac の場合は，Apple Clang が次のディレクトリにインストールされています。

```
$ /usr/bin/clang
```

もし存在しない場合は，Xcode とコマンドラインツールのインストールが必要です。

HomeBrew を使ったりビルドしたりして GCC をインストールした場合には，次のディレクトリにあります。

```
$ ls /usr/local/bin/gcc*
```

同様に HomeBrew を使ったりビルドしたりして Clang をインストールした場合は，次のディレクトリにあります。

```
$ ls /usr/local/bin/clang*
```

次のようにするとバージョンが確認できます。

```
$ /usr/bin/clang --version
$ /usr/local/bin/gcc-9 --version
$ /usr/local/bin/clang --version
```

※**注意!** Cコンパイラをソースコードからビルドする時には，デバッグモードでビルドしていないかを確認しましょう。

Clangの場合には，`cmake` 実行時に `-DCMAKE_BUILD_TYPE=Release` とします。

最初に発表した時には，ビルド時にこのオプションをつけ忘れるという，痛恨に凡ミスをしていました。。。申し訳ないです。。。 

## ビルドスクリプトの作成

例えば `erlang-install.sh` のようなシェルスクリプトを作って，次のようにまとめてインストールできます。

```bash
#!/bin/sh

# 必要に応じて
export KERL_CONFIGURE_OPTIONS="--with-ssl=(OpenSSLへのパス)" # 例えば "--with-ssl=/usr/local/opt/openssl@1.1"

CC=/usr/bin/clang kerl build 22.1 22.1_apple_Clang_11
kerl install 22.1_apple_Clang_11 ~/kerl/22.1_apple_Clang_11

CC=/usr/local/bin/clang kerl build 22.1 22.1_clang_10.0.0_6c3f
kerl install 22.1_clang_10.0.0_6c3f ~/kerl/22.1_clang_10.0.0_6c3f

CC=/usr/local/bin/gcc-9 kerl build 22.1 22.1_gcc_9.2.0_1
kerl install 22.1_gcc_9.2.0_1 ~/kerl/22.1_gcc_9.2.0_1
```

ポイントは次の通りです。

* macOS の場合には，HomeBrew で OpenSSL をインストールした後，そのパスを 環境変数 `KERNEL_CONFIGURE_OPTIONS` の `--with-ssl` オプションで指定してやる必要があります。これを忘れると，後述する `mix deps.get` したときにエラーになります。
* 環境変数 `CC` にCコンパイラへのパスを設定して，`kerl build` すると，そのCコンパイラを使ってコンパイルしてくれる
* `kerl build` の第1引数はビルドしたい Erlang のバージョン番号です。
* `kerl build` の第2引数はこのビルドを管理するときのID (なので，今回は Erlangのバージョン番号_Cコンパイラの種類_Cコンパイラのバージョン みたいに命名しました)
* `kerl install` の第1引数は，`kerl build` の第2引数と同じにします。
* `kerl install` の第2引数は，アクティベートスクリプトの置き場を指定します。

このインストールスクリプトを走らせた後で，指定した Erlang を有効にするには次のようにします。

```
$ . (kerl install の第2引数のパス)/activate
```

私の例では次のようになります。

```
$ . ~/kerl/22.1_apple_Clang_11/activate     # Apple Clang を有効にする
$ . ~/kerl/22.1_clang_10.0.0_6c3f/activate  # Clang を有効にする
$ .  ~/kerl/22.1_gcc_9.2.0_1/activate       # GCC を有効にする
```

## Erlang ビルドに失敗した場合

次のようにして削除してからコンパイルします。

```
$ kerl delete build (ビルドを管理するときのID)
$ kerl delete installation (ビルドを管理するときのID)
```  

## Elixir の準備

普通に asdf でインストールします。OTP バージョンの指定に注意してください。

## Pelemay Sample

サンプルベンチマークプログラム
https://github.com/zeam-vm/pelemay_sample

```bash
$ git clone https://github.com/zeam-vm/pelemay_sample.git
$ cd pelemay_sample
```

1. ターゲットとなる Erlang をアクティベートします。Elixir もアクティベートします。
2. `mix deps.get` します。
3. `mix bench` でベンチマーク実行です。

# 今回準備した実行環境について 

## iMac Pro (2017)

* Processor: 2.3 GHz Intel Xeon W (プロセッサ数 1，物理コア18，論理コア36)
* Memory: 32 GB 2666 MHz DDR4
* Graphics: Radeon Pro Vega 64 16368MB (今回は使わない)
* SSD (BlackMagic)
  * Write 2980.3MB/s
  * Read 2465.1MB/s

* OS: macOS Mojave 10.14.6
* Cコンパイラ
  * Apple clang version 11.0.0 (clang-1100.0.33.12)
  * clang version 10.0.0 (https://github.com/llvm/llvm-project.git 6c3fee47a6492b472be2d48cee0a85773f160df0)
  * gcc-9 (Homebrew GCC 9.2.0_1) 9.2.0
* Erlang: OTP-22.1
* Elixir: 1.9.4

## Ryzen

* Processor: 3.0-4.2GHz AMD Ryzen Threadripper 2990WX (プロセッサ数 1 物理コア 32 論理コア 64)
* Memory: 32 GB 2666MHz DDR4
* Graphics: NVIDIA TITAN RTX x2 (今回は使わない)
* OS: Ubuntu (18.04)
* Cコンパイラ
    * clang version 10.0.0 (https://github.com/llvm/llvm-project.git 6c3fee47a6492b472be2d48cee0a85773f160df0)
    * gcc-9 (Ubuntu 9-20190428-1ubuntu1~18.04.york0) 9.0.1 20190428 (prerelease) [gcc-9-branch revision 270630]
* Erlang: OTP-22.1
* Elixir: 1.9.4


# 実行結果

## iMac Pro Apple Clang 11

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   605.33 µs/op
Enum           1000   1368.37 µs/op
Flow            500   4130.07 µs/op
```

## iMac Pro clang version 10.0.0 (6c3f build)

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   580.50 µs/op
Enum           1000   2247.02 µs/op
Flow            500   5444.19 µs/op
```

## iMac Pro clang version 10 (HomeBrew)

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   580.09 µs/op
Enum           1000   2270.06 µs/op
Flow            500   5644.25 µs/op
```

## iMac Pro clang version 9 (HomeBrew)

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   585.11 µs/op
Enum           1000   2103.46 µs/op
Flow            500   5321.46 µs/op
```

## iMac Pro gcc-9

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   610.76 µs/op
Enum           1000   1375.33 µs/op
Flow            500   4106.26 µs/op
```

## iMac Pro gcc-8

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   587.33 µs/op
Enum           1000   1351.15 µs/op
Flow            500   4094.78 µs/op
```


## Ryzen: clang version 10.0.0 (6c3f build)

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   514.60 µs/op
Enum           1000   2374.77 µs/op
Flow            100   13223.27 µs/op
```

## Ryzen: clang version 10 (Ubuntu)

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   517.48 µs/op
Enum           1000   2384.15 µs/op
Flow            100   12445.57 µs/op
```

## Rizen: clang version 9 (Ubuntu)

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   503.47 µs/op
Enum           1000   2251.20 µs/op
Flow            100   13024.80 µs/op
```

## Ryzen: gcc-9

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   516.56 µs/op
Enum           1000   1361.58 µs/op
Flow            100   10155.71 µs/op
```

## Ryzen: gcc-8

```
## LogisticMapBench
benchmar iterations   average time 
Pelemay        5000   491.38 µs/op
Enum           1000   1309.46 µs/op
Flow            100   10319.50 µs/op
```

# まとめ

今回は Erlang VM をどのコンパイラでコンパイルしたかによる速度の違いを見たいので，Enum ベンチマークに着目します。

* iMac Pro: Apple Clang version 11 や gcc-8, gcc-9 の方が，clang version 10 より1.63〜1.66倍程度速く，clang version 9 より1.53〜1.54倍程度速い。
* Ryzen: gcc-8, gcc-9 の方が，clang version 10 より1.74〜1.75倍速く，clang version 9 より1.65倍速い。

手軽には次のように asdf で Erlang をインストールすれば良いかと思います。

Mac の場合

```bash
$ CC=/usr/bin/clang asdf install erlang (バージョン番号)
```

Linux の場合

```bash
$ CC=gcc-9 asdf install erlang (バージョン番号)
```


# 今後の課題

* Clang についてはコミットIDを揃えてビルドしたので条件が同一ですが，gcc-9 については，パッケージ管理システムのバージョンに委ねたので厳密には条件が同一ではありません。条件を揃えて比較してみたいです。
* Clang と GCC について，歴代バージョンを取り揃えて評価することで，どのバージョンでどのくらいの性能なのかを可視化してみたいです。
* Microsoft のコンパイラ，Intel, AMD の各最適化コンパイラなどでも試してみたいです。
* コンパイルされた結果であるアセンブリコードを読むことで，どのようなコード最適化によって，これほど大きな差が生じたのかについて，分析をしてみたいです。
* Pelemay もバージョン0.0.5で Clang だけでなく GCC にも対応したので，コード最適化を充分に有効化するようなコード生成のあり方について研究してみたいです。

これらについては，論文を書きたいと思っています。コンパイラのコード最適化の研究に貢献できるものと思っています。

明日の[「fukuoka.ex Elixir／Phoenix Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/fukuokaex)は @masatam81 さんの[「Elixirで大規模データを扱う場合のメモリ管理」](https://qiita.com/masatam81/items/058f18d6716a4868ffdc)です。お楽しみに。

