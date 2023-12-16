---
title: Hastega / micro Elixir / ZEAM の実装戦略〜 Erlang VM からの円滑な移行を見据えて
tags:
  - Elixir
private: false
updated_at: '2019-01-05T19:05:32+09:00'
id: 73bd91489fd5e08bbf16
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
(この記事は[「Elixir Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/elixir)25日目です)

現在，Elixir は，**Erlang VM** (アーラン ブイエム) という仮想機械(VM)上で動作します。Erlang VM はもともと Erlang というプログラミング言語のために開発された並行処理が得意な VM で，Elixir の他にもいくつかのプログラミング言語が Erlang VM 上で動作します。

近年，Erlang VM を再実装しようという動きがにわかに盛んになってきたようです。

* AtomVM: https://github.com/bettio/atomvm : [AtomVM: how to run Elixir code on a 3 $ microcontroller](https://medium.com/@Bettio/atomvm-how-to-run-elixir-code-on-a-3-microcontroller-b414773498a6)
* Rustler の作者，hansihe の作りかけの Rust ベースの Erlang コンパイラ https://github.com/hansihe/core_erlang
* 時雨堂 最高技術責任者 鈴木 鉄也 さん: [「Rust で Erlang 処理系を実装してみている」](https://medium.com/@szktty/rust-で-erlang-処理系を実装してみている-d5e3edb25b82)
* [Enigma](https://github.com/archSeer/enigma)

私たち [fukuoka.ex](https://fukuokaex.fun) でも活動している高瀬先生 @takasehideki が，さっそく AtomVM を試しています。

[「ElixirでIoT#3.1：ESP32やSTM32でElixirが動く！AtomVMという選択肢」](https://qiita.com/takasehideki/items/847d3d8f9d255e01ce9c)
 
そんな中で，私たち [fukuoka.ex](https://fukuokaex.fun) は micro Elixir / ZEAM という処理系を研究開発していこうとしています。

おそらくみなさんは次のような疑問を持つことと思います。

* 現在主流の Erlang VM から円滑に移行することはできるのか？
* 優れた Erlang VM よりもさらに優れた処理系を作れる勝算はあるのか？
* すでにたくさんの Erlang VM 互換のプログラミング言語処理系が数多く提案されている中で，さらに micro Elixir / ZEAM を研究開発していくことに意義はあるのか？

この記事では「Hastega / micro Elixir / ZEAM の実装戦略〜 Erlang VM からの円滑な移行を見据えて」と題して，上記のような疑問に答えることをしたいと考えています。

また，これは他の Erlang VM を開発している/しようとしている方々へのエールの意味も込めています。Erlang VM に関する研究開発が盛り上がり，情報交換しながら切磋琢磨し合うことで，より優れた技術開発が達成できると考えています。

かつて，Java VM は1990年代〜2000年代にかけて，今は Oracle に吸収された Sun Microsystems が HotSpot を，IBM が IBM JIT や Jalapeno VM といった技術を，競うように研究開発を進めていったことで，現在の高速な JavaVM を実現するに至りました。同様の競争が，Javascript についても進められてきてウェブブラウザに搭載されてきています。

Erlang VM も Java や Javascript のように切磋琢磨し合うことで，より優れた技術領域を開拓できると私は考えています。

# micro Elixir / ZEAM の開発方針の変遷 〜 Erlang VM からの円滑な移行戦略

まず1つ目の疑問「現在主流の Erlang VM から円滑に移行することはできるのか？」に答えていきたいと思います。

私たち [fukuoka.ex](https://fukuokaex.fun) では，2018年2月から ZEAM に関する研究開発を進めてきました。

当初は，Erlang VM 全体を置き換えるようなプログラミング言語処理系を構築することを考えていたのですが，研究開発を進めていくうちに，ある時点から方針を大きく転換しました。

Erlang VM を全面的に置き換えるプログラミング言語処理系を最初から開発するというアプローチの最大の難点は，現行の優れた言語処理系である Erlang VM と両立しないことと，そのことにより Erlang VM を超えるパフォーマンスを安定して得られるようにならないと実務に投入することはできないことです。そのような状態になるまで，一体何年かかるのか。スピード感を考えたときにとても見合わないと考えるようになったのです。

そこで，私たち [fukuoka.ex](https://fukuokaex.fun) が採用した戦略は次の通りです。

* Elixir のサブセットのプログラミング言語である micro Elixir を新たに定義する
* ZEAM は，Elixir のプロジェクト中のコードの一部を，NIF (Native Implemented Function: ネイティブコードで実装された関数) にコンパイルして Erlang VM から呼び出せるようにする処理系として，当面研究開発を進める
* ZEAM は，与えられた Elixir コードの中で，micro Elixir の範囲で定義されているプログラムコードを NIF にコンパイルし，それ以外の部分は元の Elixir のコードを NIF を呼び出すように変換する
* ZEAM の解析部は，Elixir マクロを利用することで，パーサーを一から開発しないで済ませる
* ZEAM の生成部は，Rust 経由で LLVM を利用することで，対応可能な ISA を最大化し，かつ最適化器などのツールチェーンを活用できるようにする
* ZEAM の最初のアプリケーションは超並列高速実行処理系 Hastega (ヘイスガ) とすることで，最初から micro Elixir / ZEAM を利用する動機を作る

このことから分かるかもしれませんが，**私たち [fukuoka.ex](https://fukuokaex.fun) は Erlang VM 互換を目指すのではなく，Elixir に特化してより高度に最適化したプログラミング言語処理系を目指す**という戦略を採っています。Erlang VM 互換を捨てる代わりに，最初のうちは Erlang VM から利用しやすいような仕組みとして研究開発を進めることで，Erlang VM 互換戦略よりも早期に実務に投入できるようにしています。

# Erlang VM を超えていくロードマップ

次に「優れた Erlang VM よりもさらに優れた処理系を作れる勝算はあるのか？」という疑問に答えていきたいと思います。

すでにご紹介したように，最初のアプリケーションを Hastega としています。Hastega は，CPU の SIMD 命令の活用による高速並列処理や，GPU の活用による超並列処理，WebGL / WebGPU / WebAssembly の活用によるウェブクライアント側でのマルチコア SIMD / GPU 活用を目指しています。このような機能は，現行の Erlang VM には備わっていない機能であり，しかも現行の Erlang VM に機能追加する形で実現するので，実現した暁には，Elixir / Phoenix から Hastega の機能を自由に利用できるようになる予定です。この時点で，Erlang VM を超えることになると考えています。

また今期のアドベントカレンダー記事で一部については書いてきたように，例えば次のような技術を研究開発しようとしています。

* 省メモリ並行プログラミング機構 Sabotender (サボテンダー)
* 命令並列性に基づく静的命令スケジューリング
* 実行時間予測に基づく静的タスクスケジューリングとハードリアルタイム性の実現
* プロセス間通信を含む超インライン展開
* 超インライン展開や静的タスクスケジューリングを前提にした大域的なキャッシュメモリとI/Oの最適化
* ...

これらの野心的な研究開発により，現行の Erlang VM を超える優れた処理系に仕上げていくようにしたいと考えています。

実はこれらの研究構想について，[3月6日〜8日に岩手県花志戸平温泉 で開催される PPL 2019](https://jssst-ppl.org/workshop/2019/)で発表しようかと計画中です。もし論文の投稿が間に合い，かつ採択されれば，発表しにいけます。ご期待ください。

# 他の Erlang VM 互換のプログラミング言語処理系との関係性

「すでにたくさんの Erlang VM 互換のプログラミング言語処理系が数多く提案されている中で，さらに micro Elixir / ZEAM を研究開発していくことに意義はあるのか？」という疑問についても答えていきたいと思います。

まず最初に申し上げたいのは，私たち [fukuoka.ex](https://fukuokaex.fun) は，当分は既存の Erlang VM に機能を付加するような形で micro Elixir / ZEAM の研究開発を進めるという方針を改めて表明します。

これは他の Erlang VM 互換のプログラミング言語処理系についても同様に考えています。すなわち，他の Erlang VM 互換のプログラミング言語処理系の開発者と協力関係が築けるのであれば，それらの処理系に対しても，Hastega などの micro Elixir / ZEAM の機能を活用できるようにしたいと考えています。

もちろん，技術的な理由で micro Elixir / ZEAM のすべての機能を提供できないこともあろうかと思います。例えば，Sabotender を完全に実装しようと思うと，プロセスとI/Oアクセスの実装に相当手を入れないといけないだろうと見込んでいます。少なくとも Erlang VM ではそのような機能追加は極めて困難であると考えています。他の件についても同様のことが起こりえると思っています。

micro Elixir / ZEAM の最終形の1つとして，他の処理系に依存することのない，独立した処理系を提供するということもしようと思っています。その主な目的は，他の処理系では実現できないような研究開発の目標を達成するためです。

そういうわけで Erlang VM から独立した micro Elixir / ZEAM 独自の処理系は，実用性以上に，高いレベルの研究課題に取り組むという位置付けにしようと考えています。

# おわりに

この記事では，「Hastega / micro Elixir / ZEAM の実装戦略〜 Erlang VM からの円滑な移行を見据えて」と題して，「現在主流の Erlang VM から円滑に移行することはできるのか？」「優れた Erlang VM よりもさらに優れた処理系を作れる勝算はあるのか？」「すでにたくさんの Erlang VM 互換のプログラミング言語処理系が数多く提案されている中で，さらに micro Elixir / ZEAM を研究開発していくことに意義はあるのか？」という3つの問いに答えてみました。

研究開発成果物は，完全にオープンソース戦略で行くので，開発したソフトウェアはもちろん，技術資料に至るまで，基本的にオープンで行こうと考えています。また潜在的には競合となりうる Erlang VM 互換の技術についても，全面的に支援していく考えです。競合がどうこうというような，小さい話をするつもりは全くありません。人類の進歩に貢献していきましょう。


以上で，2018年のアドベントカレンダー記事，全14記事は完結しました。最後まで読んでいただき，誠にありがとうございました。2019年もよろしくお願いします。


**2018年アドベントカレンダー**
|> [ZEAM開発ログ2018ふりかえり第1巻(黎明編): 2017年秋の出会いから2018年2月にElixirを始めるに至った経緯について](https://qiita.com/zacky1972/items/236dea1013252b648eeb)
|> [ZEAM開発ログ2018年総集編その1: Elixir 研究構想についてふりかえる(前編)](https://qiita.com/zacky1972/items/c9865f59259303d5f53e)
|> [ZEAM開発ログ: Elixir マクロ + LLVM で超並列プログラミング処理系を研究開発中](https://qiita.com/zacky1972/items/cc88260a3c93c9f71317)
|> [ZEAM開発ログ番外編: Elixir で再帰とStreamのどちらが速いのか，素因数分解で比較してみた](https://qiita.com/zacky1972/items/d63903ff68f64e52b74a)
|> [並列プログラミング言語 Elixir (エリクサー) におけるソフトウェアテスト〜基礎から最新展望まで](https://qiita.com/zacky1972/items/c4ae3f34a4406ee99487)
|> [ElixirとRustをつなぐRustlerを使った事例紹介](https://qiita.com/zacky1972/items/ed87b91dbe7deb8747af)
|> [並列プログラミング言語 Elixir (エリクサー)を用いた機械学習ツールチェーン](https://qiita.com/zacky1972/items/c8eae19ea8c047dfc6f9)
|> [Elixir(エリクサー)で数値計算すると幸せになれる](https://qiita.com/zacky1972/items/c13706fa3f7bbf2b791b)
|> [ZEAM開発ログ2018年総集編その2: Elixir 研究構想についてふりかえる(後編)](https://qiita.com/zacky1972/items/a754a769ac7923edb79c)
|> [RISC-V on FPGA と Elixir で究極のマルチコアシステムを構築しよう！](https://qiita.com/zacky1972/items/05a1f4b340721605bfed)
|> [WebGL / WebGPU + Hastega / Elixir / Phoenix で分散／エッジ・コンピューティング](https://qiita.com/zacky1972/items/4c6fbd73a6fe7fd2265f)
|> [ZEAM で広がる Elixir と WebAssembly の未来](https://qiita.com/zacky1972/items/da4c423f328e26d4b569)
|> [Elixir での量子コンピューティングの研究の展望](https://qiita.com/zacky1972/items/8599450d125959f62132)
|> Hastega / micro Elixir / ZEAM の実装戦略〜 Erlang VM からの円滑な移行を見据えて
