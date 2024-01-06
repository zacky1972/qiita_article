---
title: ZEAM で広がる Elixir と WebAssembly の未来
tags:
  - Elixir
private: false
updated_at: '2018-12-24T10:56:41+09:00'
id: da4c423f328e26d4b569
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
(この記事は[「WebAssembly Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/wasm)24日目です)

[「WebAssembly Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/wasm)23日目は @jerrywdlee さんの[「【直書き！】AssemblyScriptの(ほぼ)最小構成を作る(環境構築)」](https://qiita.com/jerrywdlee/items/b8b7bd6e4d5cc88c18ce)でした。

さて，12/22に公開した[「WebGL Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/webgl)22日目の[「WebGL / WebGPU + Hastega / Elixir / Phoenix で分散／エッジ・コンピューティング」](https://qiita.com/zacky1972/items/4c6fbd73a6fe7fd2265f)で考察した Hastega on Client は「WebAssembly から WebGL / WebGPU / WebAssembly SIMD による並列計算を行いやすくする統合された API」を提供します。

この Hastega on Client は次の機能を提供したいと考えています。

1. サーバーから送られてくる Elixir や WebAssembly のコードを蓄積・実行する仕組み
2. WebAssembly から WebGL / WebGPU / WebAssembly SIMD による並列計算を行いやすくする統合された API 

この記事では，主に 1 について掘り下げて考察したいと思います。プロトタイプ実装までは間に合わなかったので，技術ポエムです，ご了承ください。

# Javascript の位置付けについて

現在，Javascript の需要が極めて高い最大の理由は，唯一 Javascript だけが，ウェブクライアント用のプログラミング言語として採用されてきていたからです。

近年になって，ようやく風穴を開ける状況になってきました。**AltJS** と **WebAssembly** の台頭です。

AltJS はオブジェクト言語(コンパイル変換によって生成するプログラミング言語)が Javascript であるようなプログラミング言語の総称です。AltJS の元祖は CoffeeScript です。他にもたくさん数の AltJS が生み出されています。

一方 WebAssembly (wasm)はウェブクライアントで実行できる低水準言語として開発・標準化されました。Javascript や AltJS と比べて，高速に実行できるという触れ込みで普及が始まっているのはご存知のことと思います。

この他に，**Javascript トランスパイラ**という，既存のプログラミング言語を Javascript に変換するアプローチもあります。

# Javascript の抱える問題点

Javascript は1990年代にリリースされたプログラミング言語であり，互換性を重視されてきたことから，**歴史的な技術的負債を多く抱えている**と私は考えています。

たとえば Node.js 登場以前の古いプログラミングスタイルで書かれた資産がいまだに多く存在し，著しく保守性を下げています。

また Node.js 登場後は，**ソフトウェア資産の開発が盛んすぎて，統一感のない世界観が広がる混沌とした状況になっています。**

これらの要因で **Javascript の習得が年々難しくなってきています。**

ウェブシステム全体に目を広げると，**クライアントサイドとサーバーサイドでプログラミング言語が統一されていない**という問題もあります。Node.js により，Javascript をサーバーサイドプログラミングに採用することもできるようになりましたが，広く普及する決定打に欠けます。私たち [fukuoka.ex](https://fukukaex.fun) が推す Elixir / Phoenix と比べると，性能面と開発効率に難があると考えています。

# Elixir によるクライアントサイドプログラミングの提案

Node.js とは逆に，**Elixir でクライアントサイドとサーバーサイドのプログラミング言語を統一する**ことは出来ないでしょうか？

そこで私が研究開発しようとしているのが，**Elixir のコードを Javascript や WebAssembly に変換する**技術です。すなわち，**Elixir からの Javascript トランスパイラと WebAssembly コンパイラ**を作って，ウェブブラウザ側の WebAssembly のサポート状況に合わせて自動的に使い分けるというアプローチを提案します。

たとえば，私たち [fukuoka.ex](https://fukuokaex.fun) が推している Vue.js を前提として，Vue.js のコンポーネントを接続するようなクライアントサイドプログラミングを Elixir で記述するというようなことを考えています。

さらにウェブアプリケーションだけでなく， Flutter のような感じで，ネイティブアプリケーションとして Elixir / Phoenix ごとパッケージングすることができれば，さらに応用範囲が広がります！

そこで，私たちが研究開発を進めているプログラミング言語処理系 **ZEAM** (ジーム) で，Elixir からの Javascript トランスパイラと WebAssembly コンパイラを提供することを考えています。

# Elixir のプログラミング上の利点

私たち [fukuoka.ex](https://fukuokaex.fun) は，Elixir をたとえば**データ変換パラダイム**とでもいうような，新しいプログラミングパラダイムとして捉えています。

Elixir のプログラム例を次に示します。

```elixir
1..1_000_000
|> Enum.map(foo)
|> Enum.map(bar)
|> IO.inspect
```

* 1行目の`1..1_000_000`は，1から1,000,000までの要素からなるリストを生成します。なお，数字の間の`_`(アンダースコア)によって，数字を分割するコンマを表します。
* 2,3行目の先頭にある`|>`は**パイプライン演算子**で，パイプライン演算子の前に書かれている記述の値を，パイプライン演算子の後に書かれた関数の第1引数として渡します。すなわち，このような記述と等価です。`Enum.map(Enum.map(1..1_000_000, foo), bar)`
* 2,3行目に書かれている `Enum.map`は，第1引数に渡されるリスト(など)の要素1つ1つに，第2引数で渡される関数を適用します。ここでは関数 `foo` を各要素に適用した後，関数 `bar` を各要素に適用します。
* もし，`foo`が2倍する関数で，`bar`が1加える関数だった時には，これらの記述により，2倍してから1加える処理を1から1,000,000までの要素に適用したリスト，`[3, 5, 7, ...]` を生成します。

最初の `1..1_000_000` で表されるデータが，パイプライン演算子 `|>` を経るごとに次々と変換されて，最終的な出力である `IO.inspect` にまで至るプロセスが理解できるかと思います。こういう点で，Elixir は**データ変換パラダイム**であると捉えると理解しやすいです。

このようなデータ変換パラダイムで記述すると，並列処理を容易に記述することができ，パフォーマンスが向上しやすくなります。しかもプログラムの見通しが良く，保守性も高くなります。

# Elixir / Phoenix によるサーバーサイド/クライアントサイド統合プログラミング

考えているプログラミングスタイルはこんな感じです。

## 表示

コンテンツを表示するために Ecto でデータベースクエリーを発行する
|> データ変換を行なってコンテンツに整形する
|> 対応する Vue.js コンポーネントに渡して表示する

## 入力

Vue.js コンポーネントから入力が与えられる
|> データ変換を行なってデータベースクエリーに変換する
|> Ecto でデータベースからデータを取得する
|> データ変換を行なってコンテンツに整形する
|> 対応する Vue.js コンポーネントに渡して表示する

## Hastega on Client との連携例

Hastega on Client でクライアントサイドの画像処理や機械学習を高速化できます。

コンテンツを表示するために Ecto でデータベースクエリーを発行する
|> データ変換を行なってコンテンツに整形する
|> 対応する Vue.js コンポーネントに渡して表示する
|> Vue.js の操作を Hastega on Client に渡して計算する
|> Vue.js コンポーネントに再度渡す

# コード生成をクライアントサイドで行うか，サーバーサイドで行うか？

どちらも試そうと思います。

クライアントサイドでコード生成する場合は，Elixir コードの内部表現(下記)を圧縮して送ります。

```elixir
{:|>, [context: Elixir, import: Kernel],
 [
   {:|>, [context: Elixir, import: Kernel],
    [
      {:|>, [context: Elixir, import: Kernel],
       [
         {:.., [context: Elixir, import: Kernel], [1, 1000000]},
         {{:., [], [{:__aliases__, [alias: false], [:Enum]}, :map]}, [],
          [{:foo, [], Elixir}]}
       ]}, 
      {{:., [], [{:__aliases__, [alias: false], [:Enum]}, :map]}, [],
       [{:bar, [], Elixir}]}
    ]},
   {{:., [], [{:__aliases__, [alias: false], [:IO]}, :inspect]}, [], []}
 ]}
```

サーバーサイドでコード生成する場合は，クライアントサイドで WebAssembly などが使用できるかどうかを判定した後，WebAssembly が使用できる場合は基本的に WebAssembly，使用できない場合は Javascript を送信します。

# Elixir からのコード生成をどの言語で記述するか？

Elixir からのコード生成器を記述する方針として，大きく分けて Elixir で記述する場合と，Rust のような LLVM 経由で WebAssembly を生成できるプログラミング言語で記述する場合があります。

Elixir で実装した場合の利点は，Elixir コードの内部表現をネイティブに扱えるので，実装が容易である可能性が高い点が挙げられます。その代わり，Javascript の生成や LLVM 経由での WebAssembly 生成のためのライブラリを整備する必要があるのと，クライアントサイドでコード生成できるようにするために**自己反映的(self-reflective)な処理系**，すなわち Elixir から Javascript や WebAssembly に変換する Elixir コード自体を Javascript や WebAssembly に変換できるようにする必要があります。

一方，Rust で実装した場合の利点は，既存の LLVM バインディングを利用できるので，WebAssembly へのコード生成が容易である点と，それによって WebAssembly によるコード変換器を実装しやすい点です。しかし，Elixir コードの内部表現をパースするプログラムを Rustler を使って実装する必要がある点と，Javascript 生成系は自分で実装する必要がある点が難点です。

双方の利点・欠点を総合して判断すると，Elixir で記述した方が利点が大きいのではないかと考えています。

# Javascript と WebAssembly の使い分けと最適化戦略

ネットに流れている情報を見る限りでは，WebAssembly の方が Javascript よりも必ず高速化されるとは限らないようです。

また，現行の WebAssembly では表現できないプログラムもあるようです。

ブラウザごとに対応状況も速度も異なるようです。たとえば Firefox では Javascript と WebAssembly の速度差が極めて大きいのに対し，Chrome ではそうでもないようです。

そこで，研究開発にあたり，入念にパフォーマンス評価を行ないます。また，どのように使い分けるのが最適なのかを自動でチューニングする機構の研究開発にも取り組もうと考えています。

# おわりに

この記事では「ZEAM で広がる Elixir と WebAssembly の未来」と題して，近未来のクライアントサイドとサーバーサイドの統合されたプログラミングスタイルのイメージをお伝えしようとしましたが，いかがだったでしょうか？ 今後，このようなプログラミングスタイルを実現するための技術の研究開発に取り組んでいきますので，Elixir にご注目いただければ幸いです。

次に私がアドベントカレンダー記事を書くのは，最終日クリスマスの明日12/25公開予定の[「量子コンピュータ Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/quantum)25日目の「Elixirでの量子コンピューティングのGPU実装について，展望を紹介します！」と，[「Elixir Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/elixir)25日目の「Hastega / micro Elixir / ZEAM の実装戦略〜 Erlang VM からの円滑な移行を見据えて」の豪華2本立てです。お楽しみに！

また明日の[「WebAssembly Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/wasm)25日目最終日は， @3846masa さんの「Rust で書いた WASM を WebWorker で使うときに有益な話」です。こちらもお楽しみに！


