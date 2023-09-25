---
title: >-
  Apple Silicon M1チップ搭載Mac (Big Sur) に Elixir / Erlang
  をクリーンインストールする〜Elixir/Pelemayマイクロベンチマーク結果もあるよ！(2021.3.7現在版)
tags:
  - Erlang
  - Mac
  - Elixir
  - M1
  - Pelemay
private: false
updated_at: '2021-03-07T12:02:39+09:00'
id: f8f7734e9ab46aa74739
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[Elixir Advent Calendar 2020](https://qiita.com/advent-calendar/2020/elixir)の6日目です。

昨日は @ShozF さんの[「Elixir練習帳: .npyファイルの中を覗く」](https://qiita.com/ShozF/items/ef3629064f930e85c20f)でした。

追記(2021/3/7): 今日，M1 Mac mini をクリーンインストールし，公式の最短手順でErlangとElixirのリリース最新版をそれぞれインストールし，成功した模様です。

私のこのQiita記事は役目を終えたなと思いました。

後で，公式の最短手順の日本語版を記載したいと思います。



さて，今日はおまちかね，Apple Silicon M1チップ搭載のMacにElixirとErlangをクリーンインストールしてみたという記事です。Elixir/Pelemayのマイクロベンチマークも走らせてみました。そのパフォーマンスの高さに驚いてくださいませ。

# インストール状況について，結論から言うと

|インストール方法|Rosetta 2|ARM ネイティブ|
|:------------|:--------|:-----------|
|Homebrew     |○|○|
|`asdf`         |△?|×|
|`kerl`         |○?|×|

?がついているところは2020年12月4日現在で完全には確認できていないところです。そのうち追って確認します。

追記(2021/1/12): NervesプロジェクトのFrankによると，ARMネイティブでも`asdf`でのインストールでうまくいくようです。私は今バタバタしているので未検証ですが，是非試してください。

追記(2021/1/6): ARMネイティブの時の`asdf`でのインストールがうまくいかないことがわかりました。Homebrewでのインストールは大丈夫です。

追記(2020/12/7): ARMネイティブの時の`kerl`でのインストールがうまく動かないことがわかりました。引き続き検証します。

追記(2020/12/7): ARMネイティブで`asdf`でインストールした場合，Rosetta 2モードでターミナルを起動しても，Elixirを実行できることがわかりました。

追記(2020/12/8): しかし↑この場合(ARMネイティブで`asdf`をインストールしてRosetta2モードでターミナルを起動した場合)，今まで知られている方法でNIFをコンパイルして実行しようとすると，x86_64のバイナリでコンパイル・リンクしようとするため，不一致のためNIFをロード・実行できないという問題があることがわかりました。

# HomebrewでのElixirインストール手順

1. Xcodeをインストールする
2. Xcodeを起動してコンポーネントをインストールする
3. ターミナルで `xcode-select --install` を実行する
4. Homebrew をインストールする (Rosetta2の場合とArmネイティブの場合)
5. `brew install elixir`

# `asdf`でのElixirインストール手順

下記の記事通りです。

https://qiita.com/zacky1972/items/ad2545fe8414bbd177a0

注意点としては，原理上，Rosetta 2 モードと ARM ネイティブモードを両立できないという点です。`asdf`の抜本的な改造が必要でしょうね。というわけで，issue 書きました。 https://github.com/asdf-vm/asdf/issues/834

追記(2020/12/8): ↑issueに否定的なコメントがつきましたね。理解はできます。


# `kerl`でのElixirインストール手順

下記の記事通りです。

https://qiita.com/zacky1972/items/ad2545fe8414bbd177a0

ARMネイティブモードの場合，`export KERL_CONFIGURE_OPTIONS="--with-ssl=/opt/homebrew/opt/openssl@1.1 --enable-darwin-64bit"`とします。

`kerl build 23.1.4 23.1.4_Rosetta2`, `kerl build 23.1.4 23.1.4_ARM` みたいにすると，Rosetta 2 モードと ARM ネイティブモードを共存できます。

2020/12/11 追記: `kerl`の`--HEAD`で試したところ，Intel Big Surではうまく動きましたが，M1 Mac ARM モードではビルドでエラーが出たので，Issue 書きました。https://github.com/kerl/kerl/issues/357

# Xcodeを起動するときの注意点

https://zenn.dev/paraches/articles/m1-xcode-rosetta2 を参照のこと

要はリターンキーを押せば先に進みます。

# Rosetta2 の Homebrew のインストール方法

1. アプリケーション/ユーティリティ フォルダを開いてターミナルの「情報を見る」を開きます。
2. 「Rosettaを使用して開く」にチェックを入れます。
3. ターミナルを起動します。
4. あとは通常のHomebrewのインストール手順です。

通常と同じく`/usr/local`配下にインストールされます。

ちなみに，「Rosettaを使用して開く」にチェックを入れていても，`ssh`で外部からログインしたときには，そのシェルではRosettaは有効にならず，ARMネイティブモードになります。

# ARMネイティブのHomebrewのインストール方法

https://github.com/mikelxc/Workarounds-for-ARM-mac

1. アプリケーション/ユーティリティ フォルダを開いてターミナルの「情報を見る」を開きます。
2. 「Rosettaを使用して開く」のチェックを外します。
3. ターミナルを起動します。
4. `cd ~`
5. `mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew`
6. `sudo mv homebrew /opt/homebrew`
7. `cd /opt/homebrew/bin`
8. `./brew update`
9. .zshrc に `export PATH="/opt/homebrew/bin:$PATH"`を記述する
10. `source .zshrc`

通常と異なり，`/opt/homebrew`配下にインストールされます。

# おまけ: ベンチマーク結果

次のような自作のベンチマークプログラムを走らせてみました。

https://github.com/zeam-vm/pelemay_sample

Pelemay 0.0.14になってARMネイティブモードのM1 Macで動くようになりました。


## 参考: iMac Pro 2017 (CPU/GPU全部盛り) での実行結果

```
## FloatMultBench
benchmark name          iterations   average time 
Pelemay                      50000   38.77 µs/op
Enum                         10000   233.19 µs/op
Flow                           500   3368.38 µs/op
## LogisticMapBench
benchmark name          iterations   average time 
Pelemay                       5000   624.14 µs/op
Enum                          1000   2386.87 µs/op
Flow                           500   5600.73 µs/op
## StringReplaceBench
benchmark name          iterations   average time 
Pelemay String.replace    10000000   0.80 µs/op
Enum String.replace        1000000   2.61 µs/op
Flow String.replace           1000   1999.50 µs/op
```

## Mac mini (M1, 2020) ARM モードでの実行結果

```
benchmark name          iterations   average time 
Pelemay                     100000   28.60 µs/op
Enum                         10000   119.89 µs/op
Flow                          1000   1021.03 µs/op
## LogisticMapBench
benchmark name          iterations   average time 
Pelemay                       5000   377.24 µs/op
Enum                          2000   897.06 µs/op
Flow                          1000   2265.86 µs/op
## StringReplaceBench
benchmark name          iterations   average time 
Pelemay String.replace    10000000   0.66 µs/op
Enum String.replace        1000000   1.45 µs/op
Flow String.replace          10000   252.52 µs/op
```

## Mac mini (M1, 2020) Rosetta 2 モードでの実行結果 

Pelemay が，たとえバージョン0.0.14であっても，バグで動かなかったので，削除してあります。issueを立ててありますので，詳細をご覧になりたい方はどうぞ。
https://github.com/zeam-vm/pelemay/issues/154


```
## FloatMultBench
benchmark name       iterations   average time 
Enum                      10000   278.17 µs/op
Flow                       1000   1725.31 µs/op
## LogisticMapBench
benchmark name       iterations   average time 
Enum                       1000   2272.93 µs/op
Flow                        500   4115.19 µs/op
## StringReplaceBench
benchmark name       iterations   average time 
Enum String.replace     1000000   2.39 µs/op
Flow String.replace        5000   388.05 µs/op
```

## 結果

いずれも ARMモードの Mac mini (M1, 2020) の方が iMac Pro 2017 よりかなり高速でした。Pelemayの速度向上は大体C言語によるネイティブのコードの速度向上比と同程度と考えられます。一方，Enumの速度向上はシングルコアで動作する標準的なインタプリタの場合の速度向上比と考えられます。Flowの速度向上は，マルチコアで動作する標準的なインタプリタの場合の速度向上比と考えられます。シングルコア性能も高いですが，とくにマルチコア性能は高いですね！

|Pelemay |iMac Pro 2017|Mac mini (M1, 2020) ARM|倍率|
|:--|--:|--:|--:|
|整数演算       |624.14 µs/op|377.24 µs/op|1.65倍|
|浮動小数点数演算|38.77 µs/op |28.60 µs/op |1.36倍|
|文字列置換     |0.80 µs/op  |0.66 µs/op  |1.21倍|

|Enum |iMac Pro 2017|Mac mini (M1, 2020) ARM|倍率|
|:--|--:|--:|--:|
|整数演算       |2386.87 µs/op|897.06 µs/op|2.66倍|
|浮動小数点数演算|233.19 µs/op |119.89 µs/op|1.95倍|
|文字列置換     |2.61 µs/op   |1.45 µs/op  |1.80倍|


|Flow |iMac Pro 2017|Mac mini (M1, 2020) ARM|倍率|
|:--|--:|--:|--:|
|整数演算       |5600.73 µs/op|2265.86 µs/op|2.47倍|
|浮動小数点数演算|3368.38 µs/op|1021.03 µs/op|3.30倍|
|文字列置換     |1999.50 µs/op|252.52 µs/op |7.92倍|

Rosetta 2 モードの Mac mini (M1, 2020) と iMac Pro 2017 はEnumでほぼ互角，FlowではMac miniの方が速いです。この場合も，マルチコアであるFlowの場合の方が速度向上比が高かったです。

|Enum |iMac Pro 2017|Mac mini (M1, 2020) Rosetta 2|倍率|
|:--|--:|--:|--:|
|整数演算       |2386.87 µs/op|2272.93 µs/op|1.05倍|
|浮動小数点数演算|233.19 µs/op |278.17 µs/op|0.838倍|
|文字列置換     |2.61 µs/op   |2.39 µs/op  |1.09倍|


|Flow |iMac Pro 2017|Mac mini (M1, 2020) Rosetta 2|倍率|
|:--|--:|--:|--:|
|整数演算       |5600.73 µs/op|4115.19 µs/op|1.36倍|
|浮動小数点数演算|3368.38 µs/op|1725.31 µs/op|1.95倍|
|文字列置換     |1999.50 µs/op|388.05 µs/op |5.15倍|

Rosetta 2 より ARM ネイティブは1.6〜2.5倍程度高速であると言えそうです。

|Mac mini (M1, 2020) Enum |Rosetta 2|ARM|倍率|
|:--|--:|--:|--:|
|整数演算       |2272.93 µs/op|897.06 µs/op|2.53倍|
|浮動小数点数演算|278.17 µs/op |119.89 µs/op|2.32倍|
|文字列置換     |2.39 µs/op   |1.45 µs/op  |1.65倍|


|Mac mini (M1, 2020)　Flow |Rosetta 2| ARM|倍率|
|:--|--:|--:|--:|
|整数演算       |4115.19 µs/op|2265.86 µs/op|1.95倍|
|浮動小数点数演算|1725.31 µs/op|1021.03 µs/op|1.69倍|
|文字列置換     |388.05 µs/op |252.52 µs/op |1.54倍|



# おわりに

明日の[Elixir Advent Calendar 2020](https://qiita.com/advent-calendar/2020/elixir) 7日目の記事は @koyo-miyamura さんです。よろしくお願いします。

本研究成果は、科学技術振興機構研究成果展開事業研究成果最適展開支援プログラム A-STEP トライアウト JPMJTM20H1 の支援を受けた。
