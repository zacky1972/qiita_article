---
title: ElixirとRustをつなぐRustlerを使った事例紹介
tags:
  - Rust
  - Elixir
private: false
updated_at: '2018-12-09T19:00:47+09:00'
id: ed87b91dbe7deb8747af
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
(この記事は[「Rust Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/rust)の8日目です)

[「Rust Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/rust)7日目は， @blackenedgold (κeen) さんの[「Rustのモジュールの使い方 2018 Edition版」](https://keens.github.io/blog/2018/12/08/rustnomoju_runotsukaikata_2018_editionhan/)でした。

[「Rust Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/rust)8日目の今日は，ElixirとRustをつなぐRustlerというライブラリについてと，私たちが開発したRustlerの事例を紹介したいと思います。

# 背景

Rust 推しのみなさんの前で喧嘩を売るようで恐縮ですが，私たち [fukuoka.ex](https://fukuokaex.fun) は **Elixir**(エリクサー) 推しです。なぜ Elixir に注目しているかというと，Elixir の持つ**並列処理性能**と**耐障害性**が高い上に，**文法が平易で記述が容易**であるから，そして **Phoenix**(フェニックス)という**最速のウェブフレームワーク**を持つからです。

しかしながら，現状の Elixir の実行時環境である **Erlang VM** (アーラン ブイエム) は，Rust や C/C++ などのネイティブコードにコンパイルするプログラミング言語処理系と比べて低速です。

そこで，Elixir (というか Erlang VM) には，**NIF**(Native Implemented Function)というネイティブコード実行に関わるAPIが整備されています。NIFは通常C/C++で書くのですが，Elixir では [**Rustler**](https://github.com/hansihe/rustler) (ラスラー)というライブラリによって NIF を記述するプログラミング言語として Rust を利用することができるようになります。

**Rustler によって Elixir と Rust は共存共栄の道を辿ることができます！**

そこで本記事では，Rustler と私たち [fukuoka.ex](https://fukuokaex.fun) が開発した Rustler の事例についてご紹介したいと思います。最後に，今後私たち [fukuoka.ex](https://fukuokaex.fun) が考えている展望について述べたいと思います。

# Rustler の事例紹介

私たち [fukuoka.ex](https://fukuokaex.fun) では，主に @twinbee (enぺだーし)さんと，私 @zacky1972，そして新進気鋭の @hisaway さんが Rustler を使った事例を開発し，記事やソースコードを公開しています。次のような感じです。

**@twinbee (enぺだーし)さんの事例**
|> [Elixirから簡単にRustを呼び出せるRustler #4 SHIFT-JIS変換を行う](https://qiita.com/twinbee/items/75415203e44daee16fcc)
|> [Elixirで一千万行のJSONデータで遊んでみた Rustler編](https://qiita.com/twinbee/items/e0878a21385b1576f479)
|> [mbcs_rs](https://hex.pm/packages/mbcs_rs)

**@zacky1972 の事例**
|> ロジスティック写像ベンチマーク
|> Hastega
|> micro Elixir / ZEAM

**@hisaway さんの事例**
|> ベクトル計算
|> [線形回帰](https://qiita.com/hisaway/items/dd785e81fa82b9924b67)

今回は次の事例について詳しく紹介します。

* 各種文字コード変換([mbcs_rs](https://hex.pm/packages/mbcs_rs), ついでに[Mojiex](https://github.com/enpedasi/Mojiex))
* ベクトル計算 / 線形回帰
* Hastega
* micro Elixir / ZEAM

## 各種文字コード変換(mbcs_rs, ついでにMojiex)

@twinbee (enぺだーし)さんが開発した事例です。

[mbcs_rs](https://hex.pm/packages/mbcs_rs)は，エンコーディングを変換します。

下記のようにすると，`"日本語"`という文字列をシフトJISに変換します。

```elixir
"日本語" |> MbcsRs.encode!("SJIS")
```

下記のようにすると，`"日本語"`という文字列をシフトJISに変換した後，元の文字列(UTF-8)に戻します。

```elixir
"日本語" |> MbcsRs.encode!("SJIS") |> MbcsRs.decode!("SJIS")
```

ちなみに Rust を使った事例ではありませんが enぺだーしさん作の [Mojiex](https://github.com/enpedasi/Mojiex)は，全角半角変換をします。

たとえば下記のようにすると半角カナを全角カナに変換して，`"ＡＢＣＤ　０１２３４あいうあいうABCD 01234あいう"` という結果を得ます。

```elixir
"ＡＢＣＤ　０１２３４あいうアイウABCD 01234ｱｲｳ" |> Mojiex.convert({:hk, :zk})
```

## ベクトル計算

@hisaway さんが研究開発した事例です。

**ベクトル計算**
|> [Elixir + Rustlerでベクトル演算を高速化しよう〜Rustler初級者編 1 〜](https://qiita.com/hisaway/items/1785615119bf4633567e)
|> [Elixir + Rustlerでベクトル演算を高速化しよう 〜初級者編 1.5〜](https://qiita.com/hisaway/items/bc7eab5e511adbebb308)

**線形回帰**
|> [RustElixirで線形回帰を高速化した話](https://qiita.com/hisaway/items/dd785e81fa82b9924b67)

## Hastega

@zacky1972 が研究開発している事例です。

**Hastega**(ヘイスガ)の名称はファイナルファンタジーに登場する最強のスピードアップ呪文に由来します。ちなみに Elixir や Phoenix もファイナルファンタジー由来の名称です。この研究プロジェクトが目標とするマルチコア CPU / GPU をフル活用して高速化する技術として Hastega は最もふさわしい名称ではないでしょうか。

Elixir では MapReduce に基づくプログラミングスタイルが広く普及しています。例えば次のようなコードです。

```elixir
1..1_000_000
|> Enum.map(foo)
|> Enum.map(bar)
```

* 1行目の`1..1_000_000`は，1から1,000,000までの要素からなるリストを生成します。なお，数字の間の`_`(アンダースコア)によって，数字を分割するコンマを表します。
* 2,3行目の先頭にある`|>`は**パイプライン演算子**で，パイプライン演算子の前に書かれている記述の値を，パイプライン演算子の後に書かれた関数の第1引数として渡します。すなわち，このような記述と等価です。`Enum.map(Enum.map(1..1_000_000, foo), bar)`
* 2,3行目に書かれている `Enum.map`は，第1引数に渡されるリスト(など)の要素1つ1つに，第2引数で渡される関数を適用します。ここでは関数 `foo` を各要素に適用した後，関数 `bar` を各要素に適用します。もし，`foo`が2倍する関数で，`bar`が1加える関数だった時には，これらの記述により，2倍してから1加える処理を1から1,000,000までの要素に適用したリスト，`[3, 5, 7, ...]` を生成します。

Hastega の原理としては，上記のコードは，**単純で均質で大量にあるデータ** `1..1_000_000` と **同じような命令列** `foo |> bar` で構成されます。したがって，これはGPUの基本アーキテクチャであるSIMDに適合します。次のようにOpenCLのネイティブコードで書いてみると，先ほどのコードから容易に変換できそうです。

```c
__kernel void calc(
  __global long* input,
  __global long* output) {
  size_t i = get_global_id(0);
  long temp = input[i];
  temp = foo(temp);
  temp = bar(temp);
  output[i] = temp;
}
```

このアイデアに基づいてプロトタイプを実装してみたところ，Python の NumPy ライクな GPU 実行系である CuPy での実行と比べて，3倍以上速度向上するという結果が得られました。

Hastega には SIMD 命令を用いた並列実行機能も備えようとしています。現時点では Rust によるループに対する SIMD 命令生成をそのまま利用しています。

整数演算ベンチマークについて，Elixir から，SIMD 命令を用いたマルチコアCPU駆動(rayon crate) のネイティブコードおよび OpenCL (ocl crate) による GPU 駆動のネイティブコードを呼び出す Hastega プロトタイプを開発しました。8月にプログラミング研究会とSWESTにて発表しました。当時得られた結果では Elixir からの速度向上は約4〜8倍，Pythonからの速度向上は3倍以上となりました。発表資料(論文，プレゼンテーション，ポスター)を下記に示します。

[![Hastega: Elixirプログラミングにおける超並列化を実現するためのGPGPU活用手法](https://qiita-image-store.s3.amazonaws.com/0/55223/b81d5c4c-f8d5-387f-571d-e8251ce4509e.png)](https://zeam-vm.github.io/papers/GPU-SWoPP-2018.pdf)

[![Hastega: Elixirプログラミングにおける超並列化を実現するためのGPGPU活用手法](https://qiita-image-store.s3.amazonaws.com/0/55223/2fb20104-f286-53ae-456f-58abbe7f3fc7.png)](https://zeam-vm.github.io/GPU-SWoPP-2018-pr/#/)

[![Hastega: Elixirプログラミングにおける超並列化を実現するためのGPGPU活用手法](https://qiita-image-store.s3.amazonaws.com/0/55223/95ec444a-889c-e0d2-9e1d-8b24d84cb485.png)](https://zeam-vm.github.io/papers/SWEST_Hastega.pdf)

その後，複数の研究助成を受けて数々のマシンでテストする機会が得られたり，研究室学生が研究に合流してくれたりして，研究が進みました。

今度，[Lonestar ElixirConf 2019 (2月28日〜3月2日 テキサス州 オースティン)](https://lonestarelixir.com/)でも発表してきます！
 
[![Presentation at Lonestar ElixirConf 2019](https://qiita-image-store.s3.amazonaws.com/0/55223/140a46a9-527b-66e2-a048-aee3d66a3ee0.png)
](https://lonestarelixir.com/2019/speakers/21#susumu-yamazaki)

## micro Elixir / ZEAM

**ZEAM**(ジーム) は ZACKY's Elixir Abstract Machine の略です。Erlang VM の BEAM (Bogdan/Björn's Erlang Abstract Machine)に対応するような形で命名しました。ZEAM という名称の初出は[2018年2月の「fukuoka.ex #5」](https://techjin.connpass.com/event/79311/)です。

[![fukuoka.ex ZEAM開発ログ 第1回: BEAMバイトコード・インサイド〜30年の歴史を誇るBEAMを超えるには](https://qiita-image-store.s3.amazonaws.com/0/55223/318b55bb-4b36-45ee-c9b9-b1ae7b80e55e.png)](https://zeam-vm.github.io/zeam-fukuoka.ex-20170223/#/)

ZEAM はその名の通り，Erlang VM に代わる Elixir ネイティブな処理系として構想されました。当初構想では BEAM バイトコードと互換性を持たせるつもりでいたのですが，BEAMバイトコードの解析に難儀したことと，その後の議論で，バイトコードレベルの互換性は不要で，Elixir のソースコードレベルの互換性があれば良いという結論に至り，当初構想から大きく方向転換することとなりました。

現在の構想では，Elixir のサブセットとなるプログラミング言語を策定し，その言語をコンパイル・実行する処理系として研究開発を始動しています。このサブセット言語を **micro Elixir** と呼んでいます。

micro Elixir / ZEAM 構想の初出は[fukuoka.ex#13：夏のfukuoka.ex祭＝技術のパラダイムシフト](https://fukuokaex.connpass.com/event/89472/)および[SWEST20](https://swest.toppers.jp/SWEST20/program/)です。下記のプレゼンテーションの後半で示されるように，かなり野心的な構想になっています。

[![耐障害性が高くマルチコア性能を最大限発揮できるElixir(エリクサー)を学んでみよう](https://qiita-image-store.s3.amazonaws.com/0/55223/75f39ef5-0517-509a-180e-095165054f4e.png)](https://swest.toppers.jp/SWEST20/program/pdfs/s2c_public.pdf)

micro Elixir の全ての仕様はまだ確定していませんが，まずは Elixir の**データ処理**の部分を抜き出して Hastega のコードを生成するという部分に集中することにしました。また，当面は NIFコードを生成することとし，Elixir / Erlang VM から呼び出すようにすることにしました。これを **Hastega / micro Elixir / ZEAM** と呼んでいます。このようにデザインすることで，すぐに既存のElixirのコードに組込むことが可能になります。

micro Elixir / ZEAM を開発するには，Elixir コードを解析して中間コードにする部分(解析部)と，中間コードを元に最適化・コード生成する部分(合成部)を開発する必要があります。

私たちが採用している基本構成は次のようにします。

* 解析部: Elixir の言語処理系をそのまま利用し **Elixir マクロ**を用いて拡張する
* 合成部: 近年のコンパイラで広く普及している **LLVM** を用いて，Elixir からコードを生成・実行できるようにする

それぞれを採用した理由は次の通りです。

* Elixirマクロは，簡潔な記述ながらとても強力な機能を有しています。また，既存の Elixir の文法であれば，とくに容易に記述できます。今回は，Elixir の文法を元に処理系を開発することから，Elixir マクロの採用により，開発効率が向上します。
* LLVMは，対応しているプロセッサが多く，最適化も充実しています。したがって LLVM のコードを生成することで，幅広いアーキテクチャに最適なコードを生成できる可能性が高まります。

今のところ，LLVM については，Elixir から Rustler 経由で Rust の LLVM バイディングである llvm-sys につなげて出力しています。

# Hastega / micro Elixir / ZEAM の詳細

2018年のアドベントカレンダーに Hastega / micro Elixir / ZEAM を特集しています。

**Hastega / micro Elixir / ZEAM**
|> [ZEAM開発ログ2018年総集編その1: Elixir 研究構想についてふりかえる(前編)](https://qiita.com/zacky1972/items/c9865f59259303d5f53e)
|> [ZEAM開発ログ: Elixir マクロ + LLVM で超並列プログラミング処理系を研究開発中](https://qiita.com/zacky1972/items/cc88260a3c93c9f71317)

今までの研究開発記録は下記目次から参照ください。

[ZEAM開発ログ 目次](https://qiita.com/zacky1972/items/70593ab2b70d192813df)


# 今後の展望

今回ご紹介した Rustler の最後の事例である micro Elixir / ZEAM ですが，完成すると Elixir コードから LLVM でネイティブコードを生成して実行できるようになります。すなわち，**Rustの最大のライバル**を私たち [fukuoka.ex](https://fukuokaex.fun) は作ろうとしているわけです...!!

しかしながら，もしそうなったとしても，micro Elixir / ZEAM の心臓部は，依然として Rust で記述する予定です。また，micro Elixir / ZEAM の研究開発に伴い，Rust の crate もいろいろ開発することでしょう。

また Elixir と Rust の得意分野は異なります。Elixir の強みは並列処理を簡単に扱えることやウェブインタフェースなどです。一方，Rust は堅牢な低レベルプログラミングシステムを構築するのに長けています。micro Elixir / ZEAM や Rustler を介して連携させることで，お互いの強みを発揮できます！

したがって，**micro Elixir / ZEAM と Rustler によって Elixir と Rust は共存共栄の道を辿ることができます！**

# Rustler や Elixir を使ってみたくなったら

**Rustler 入門記事**
|> [Elixirから簡単にRustを呼び出せるRustler #1 準備編](https://qiita.com/twinbee/items/aabc11d0d667800fc0bb)
|> [Elixirから簡単にRustを呼び出せるRustler #2 クレートを使ってみる](https://qiita.com/twinbee/items/54e8a4ec73bc27abd10e)
|> [Elixirから簡単にRustを呼び出せるRustler #3 いろいろな型を呼び出す](https://qiita.com/twinbee/items/f94eb7f74ff39c781da0)
|> [Elixirから簡単にRustを呼び出せるRustler #4 SHIFT-JIS変換を行う](https://qiita.com/twinbee/items/75415203e44daee16fcc)
|> [Elixirから簡単にRustを呼び出せるRustler #5 NIFからメッセージを返す
](https://qiita.com/twinbee/items/cd818fd509ace2ae0d0a)
|> [Elixir-NIF-Rustボイラープレート Ruster0.17.1の注意点](https://qiita.com/twinbee/items/e005939c1bab53e60f6e)

**Elixir 入門記事**
|> [Excelから関数型言語マスター1回目：行の「並べ替え」と「絞り込み」](https://qiita.com/piacere_ex/items/6714e1440e3f25fb46a1)
|> [Excelから関数型言語マスター2回目：「列の抽出」と「Web表示」](https://qiita.com/piacere_ex/items/b7787580fce5f148242f)
|> [Excelから関数型言語マスター3回目：WebにDBデータ表示【PostgreSQL or MySQL編】](https://qiita.com/piacere_ex/items/a7558adc6856e3577dc6)
|> [Excelから関数型言語マスター4回目：Webに外部APIデータ表示](https://qiita.com/piacere_ex/items/4c212615a4eb699dd109)
|> [Excelから関数型言語マスター5回目：Webにグラフ表示](https://qiita.com/piacere_ex/items/290b76b76d5ff8e019bf)
|> [Excelから関数型言語マスター6回目： Vue.js＋内部API（表示編）](https://qiita.com/piacere_ex/items/50d847170291c41fef64)
|> [Excelから関数型言語マスター7回目： Vue.js＋内部API（更新編）](https://qiita.com/piacere_ex/items/7cd1162ce6d66a334a07)

# おわりに

今回は Elixir と Rust をつなぐかけはしとなる Rustler について，事例とともに紹介しましたが，いかがだったでしょうか？ ぜひこの機会に Elixir に触れてみてください！

次にアドベントカレンダーの記事を書くのは，明日12/9公開予定の[「機械学習工学 / MLSE Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/mlse)9日目の[「並列プログラミング言語 Elixir (エリクサー)を用いた機械学習ツールチェーン」](https://qiita.com/zacky1972/items/c8eae19ea8c047dfc6f9)です。お楽しみに！

[「Rust Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/rust)9日目の明日は @termoshtt さんです。こちらもお楽しみに！
