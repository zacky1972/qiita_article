---
title: WebGL / WebGPU + Hastega / Elixir / Phoenix で分散／エッジ・コンピューティング
tags:
  - Elixir
private: false
updated_at: '2018-12-24T10:58:41+09:00'
id: 4c6fbd73a6fe7fd2265f
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
(この記事は[「WebGL Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/webgl)22日目です)

[「WebGL Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/webgl)21日目は @ukeyshima さんでした。

**WebGL** を使った応用の1つとして，**GPGPU** (General-Purpose computing on Graphics Processing Units: 画面表示以外の汎用的な用途で GPU を用いた計算を行うこと) があります。また，ウェブ上で3Dグラフィクスを扱う新しい API である **WebGPU** が提案されています。

一方，私たち [fukuoka.ex](https://fukuokaex.fun) は **Hastega** (ヘイスガ) という，並列プログラミング言語 **Elixir** (エリクサー) で GPGPU を行うための処理系を研究開発しています。Hastega / Elixir は，CuPy / Python による GPGPU と比べて **整数演算で3倍以上の性能** を達成しました。

また Elixir にはウェブサイト構築フレームワークである **Phoenix** (フェニックス) があります。Elixir / Phoenix は，他のプログラミング言語によるウェブサイト構築フレームワークに比べて，**HTTP/2 や WebSocket で高速にクライアント・サーバー間で通信できる**という特徴があります。

この記事は，**WebGL / WebGPU による GPGPU 環境と サーバー上の Hastega による GPGPU 環境を，それぞれ Elixir による統一されたプログラミングスタイルで記述し，Phoenix で提供する WebSocket / HTTP/2 で通信しあうような分散/エッジ・コンピューティング環境**(下図)の実現性と将来性を検討します。本当はプロトタイプを実装して検証したかったのですが，開発が全く間に合わなかったので，技術ポエムとして書きました。

![Hastega/Elixir Distributed/Edge Computing Environment](https://qiita-image-store.s3.amazonaws.com/0/55223/aa11b09f-20e2-395a-b61f-f9f8044cc3a2.png)

# WebGL 2.0 による GPGPU

[「JavaScriptのWebGL 2.0でGPGPU」](https://qiita.com/teatime77/items/e867d7d462cb553b373d)によると，WebGL 2.0 を用いた場合，次のように GPGPU を行います。

1. 頂点シェーダを用いて計算を行う
2. WebGL 2.0 からサポートされた Transform Feedback を用いて頂点シェーダーの出力をアプリ側で受け取る
3. 通常はフラグメントシェーダーで表示を行うが，フラグメントシェーダーによる出力をあらかじめ無効にしておくことで，画面表示なしに計算だけを行うことができる

この記事による実装方法では，Javascript のプログラムコードを GPU で実行するような感じになります。

また，[「次世代のWebGPUの可能性 – コンピュートシェーダーで高速並列計算」](https://ics.media/entry/18467)によると，WebGL を使ったもう1つの GPGPU アプローチとして，テクスチャーへのオフスクリーンレンダリングを用いる方法があります。

さらに，@9ballsyndrome さんの[「WebGLのCompute shaderを試してみた」](https://qiita.com/9ballsyndrome/items/7bae4f4cec8d26692d29)によると，コンピュートシェーダーを用いるアプローチが提供されつつあるようです。この点については WebGPU の節で後述します。

一方，[「Using WebGL shaders in WebAssembly」](https://medium.freecodecamp.org/how-to-use-webgl-shaders-in-webassembly-1e6c5effc813)によると，WebGL のシェーダーを WebAssembly から使うことができます。この記事では C++ のプログラムコードを WebAssembly にコンパイルし，WebGL を呼び出してレンダリングしています。

ちなみに Chrome には[「WebAssembly SIMD」](https://www.chromestatus.com/feature/6533147810332672)というのがあり，WebAssembly から CPU の SIMD 命令を使うことができます。

WebAssembly へは LLVM からもコード生成することができます。[「Using LLVM from Rust to generate WebAssembly binaries」](https://medium.com/@jayphelps/using-llvm-from-rust-to-generate-webassembly-93e8c193fdb4)によると，Hastega で使っている Rust の LLVM バインディングである llvm-sys を使って WebAssembly を生成することができます。

これらをうまく組合わせることで，Hastega で目指しているような CPU と GPU が協調して並列計算する処理系を WebAssembly と WebGL 2.0 でクライアントサイドでも実現することができそうです。 

# WebGPU による GPGPU

[「次世代のWebGPUの可能性 – コンピュートシェーダーで高速並列計算」](https://ics.media/entry/18467)によると， WebGPU の場合にはコンピュートシェーダーによって直接的に GPGPU を行うことができます。

この記事による実装方法では，Javascript のプログラムコードを GPU で実行するような感じになります。

@9ballsyndrome さんの[「WebGLのCompute shaderを試してみた」](https://qiita.com/9ballsyndrome/items/7bae4f4cec8d26692d29)によると，Chromium では WebGL でもコンピュートシェーダーが提供されようとしているようです。しかし残念ながら現在は Windows のみのサポートです。しかも macOS で OpenGL のサポートを打ち切ることを表明しているので，macOS 上の WebGL でコンピュートシェーダーが使えるようになる期待が持てません。macOS 上では WebGPU を使わざるを得ないでしょう。

WebAssembly から WebGPU を扱うような技術文書は，今のところ見出していません。しかし， [WebAssembly JavaScript API](https://www.w3.org/TR/wasm-js-api-1/) によって，WebAssembly から任意の Javascript のコードを呼び出せるようなので，原理的には WebAssembly から WebGPU による GPGPU を行えるように思います。

# WebGL 2.0 / WebGPU / WebAssembly が有効か無効かを判定する方法

@piacere_ex さんのアイデアですが，WebGL 2.0 / WebGPU / WebAssembly が有効か無効かを判定するには，簡単な整数演算などのごく軽量な GPGPU のプログラムを送り込んで実行してみて，タイムアウトせずに演算結果を受け取ることができたら有効である，と判定すれば良いでしょう。

# Hastega on Client

私たち [fukuoka.ex](https://fukuokaex.fun) は，以上を踏まえて Hastega on Client を研究開発したいと考えています。

Hastega では次のような Elixir の MapReduce スタイルのプログラムコードを GPU で駆動します。 

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

GPU が採用する **SIMD** (単一命令列／複数データ) アーキテクチャは，**単純で均質で大量にあるデータ**を**同じような命令列**で処理する場合に適合するように設計されているので，このような場合に最も高速化できます。先ほどのプログラム例だと，`1..1_000_000` の部分が**単純で均質で大量にあるデータ**に，`foo` と `bar` が**同じような命令列**に，それぞれ該当します。したがって，このような **Elixir の MapReduce スタイルのプログラムコードは，GPUで並列化しやすい**ということになります。

先ほどのプログラムコードは，Elixir の内部的には次のようなデータ構造で表されます。

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

これは iex で次のように実行すれば得られます。

```elixir
iex(1)> quote do 
...(1)> 1..1_000_000 |> Enum.map(foo) |> Enum.map(bar) |> IO.inspect
...(1)> end
```

Hastega では，このような Elixir プログラムコードの内部構造をもとにして，LLVM を用いてコード生成します。

そこで，「WebAssembly から WebGL / WebGPU / WebAssembly SIMD による並列計算を行いやすくする統合された API」は，基本的には次のような性質を持つプログラムとすれば要望を満たせます。

1. Elixir プログラムコードの内部構造を LLVM で WebAssembly にコンパイルする処理系を WebAssembly で記述したもの
2. 並列処理に関わる部分を WebAssembly にコンパイルする際に WebGL / WebGPU / WebAssembly SIMD の API を呼び出すコードを生成する

すなわち Hastega on Client は次の機能を提供したいと考えています。

1. サーバーから送られてくる Elixir や WebAssembly のコードを蓄積・実行する仕組み
2. WebAssembly から WebGL / WebGPU / WebAssembly SIMD による並列計算を行いやすくする統合された API 

システムとして統合したときには次のようになるでしょう。

* Hastega に関する並列処理のコードは，クライアントサイドもサーバーサイドも，共通して Elixir で記述する
* Hastega のコードを，クライアントサイドに配置するのかサーバーサイドに配置するのかは，アノテーションによって行う。将来的には負荷分散や通信容量を推定して自動で配置する
* Phoenix は，クライアントサイドで実行する Hastega のコードを，Elixir コードの内部表現の形式で，HTTP/2 や WebSocket を通じて送信する
* Hastega on Client は送られてきたコードを WebAssembly にコンパイルして蓄積・実行する

# 将来展望

GPGPU と Hastega の主なアプリケーションは，画像処理，機械学習などです。したがって，Hastega on Client もこれらのアプリケーションを実現することが求められます。

一方，レスポンス性の高いウェブアプリケーションを構築するためには，クライアントとサーバーの間の通信をできるだけ少なくすることが大事です。通信が全く無くても動作させることができるのであれば，オフライン化することもできます。

以上のことから，Hastega on Client の有望なアプリケーションとしては，例えばユーザーインタフェースに直接関わるような画像処理や機械学習が考えられます。今までの方式では，いちいちサーバーと通信してサーバーサイドで画像処理や機械学習を行うしかなくレスポンス性を悪化させていたのですが，Hastega on Client により画像処理や機械学習をクライアントサイドに配置することができ，サーバーと通信を行う必要性が減ります。これにより，**知的なユーザーインターフェースを持つレスポンス性の高いウェブアプリケーションを構築できる**のではないかと期待します。

# おわりに

今回は「WebGL / WebGPU + Hastega / Elixir / Phoenix で分散／エッジ・コンピューティング」というタイトルでお送りしましたが，いかがだったでしょうか？ 新たな分散／エッジ・コンピューティングの可能性を感じていただければ幸いです。

私たち [fukuoka.ex](https://fukuokaex.fun) では，このような OSS を一緒に研究・開発してくれる人を常時募集しています！ 我こそはと思う方は，ぜひコンタクトを取っていただければ幸いです。 Twitter で #fukuokaex のハッシュタグをつけて名乗りをあげてください！

次に私がアドベントカレンダーの記事を書くのは12/24公開予定の[「WebAssembly Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/wasm)24日目，[「ZEAM で広がる Elixir と WebAssembly の未来」](https://qiita.com/zacky1972/items/da4c423f328e26d4b569)です。今日のこの記事に関連する話を書きますので，お楽しみに！

明日の[「WebGL Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/webgl)23日目は @emadurandal さんの[「趣味から仕事へ。GLBoostの教訓とこれから」](https://qiita.com/emadurandal/items/ea8c8aa96bda8ded7431)です。こちらもお楽しみに！
