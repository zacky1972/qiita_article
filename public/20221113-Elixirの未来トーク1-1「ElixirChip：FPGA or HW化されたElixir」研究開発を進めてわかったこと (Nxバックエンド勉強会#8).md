---
title: Elixirの未来トーク1-1「ElixirChip：FPGA or HW化されたElixir」研究開発を進めてわかったこと (Nxバックエンド勉強会#8)
tags:
  - Elixir
  - FPGA
  - Nerves
  - RISC-V
private: false
updated_at: '2022-12-06T12:35:26+09:00'
id: 6e1debd04798b01f36be
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[Nxバックエンド勉強会#8](https://pelemay.connpass.com/event/264838/)でお話しする内容のポジショントークです．

https://pelemay.connpass.com/event/264838/

シリーズ

* [Elixirの未来トーク2-1「全世界のスマホGPUをクラスタリング」研究開発を進めてわかったこと (Nxバックエンド勉強会#8)](https://qiita.com/zacky1972/items/9a080c90be00231dd863)

関連記事

* [Elixir Chipの鼓動① 君はElixir CPU＋リモートGPUの高速分散データ処理＆エッジコンピューティングによる未来を見る by piacerex](https://qiita.com/piacerex/items/b99baebf284243fb6d6b)


# はじめに

私が表題のようなことを言うのは今回が初出ではなくて，次のような記事で既に書いていました．

* [RISC-V on FPGA と Elixir で究極のマルチコアシステムを構築しよう！](https://qiita.com/zacky1972/items/05a1f4b340721605bfed) 並列処理に長けたElixirを，FPGA上に実装したマルチコア・メニーコアのRISC-VソフトコアCPUで走らせることで，究極のマルチコアシステムができるのではないかという技術ポエムです．
* [Hastega / micro Elixir / ZEAM の実装戦略〜 Erlang VM からの円滑な移行を見据えて](https://qiita.com/zacky1972/items/73bd91489fd5e08bbf16) Erlang VMを超えるにはどうするかについて検討した技術ポエムです．
* [10年後のために「私自身が」今勉強しておきたい技術〜Elixir, Nx, SIMD/ベクタ命令, GPU, FPGAプログラミングの高速化を極めたい！](https://qiita.com/zacky1972/items/16551040cc42696127fb) FPGAを含めて，将来に向けて勉強しておきたい技術を表明した技術ポエムです．

研究開発を進めていくにしたがって，これらの方向性がより具体性を帯びてきたので，改めてこの未来トークでお知らせしようとするものです．そのうち，この記事では研究を進めてわかってきたことをつらつらと書いてみたいと思います．

# 研究開発を進めてわかってきたこと

## 既存のオープンソースのRISC-VソフトコアCPUにはマルチコアのものがない模様

下記で探したのですが，既存のオープンソースのRISC-VソフトコアCPUにはマルチコアのものがない模様です(もちろんオープンソースではない商用ライセンスのものであれば存在します)．

https://riscv.org/exchange/#

https://github.com/riscvarchive/riscv-cores-list

※ 後者はアーカイブされたようです


## FPGAに合わせて設計を最適化しないとクロック周波数を高く駆動することができない

試しに，ある既存のオープンソースのシングルコアのRISC-VソフトコアCPUをFPGAで動かしてみたのですが，ボトルネックがあり，クロック周波数を高く駆動することができませんでした．クロック周波数を抜本的に向上させるには一から設計をやり直した方が早いのではないかという感触を得ました．


## ASICにしたときの性能はFPGA向けの論理合成から推定できる

ASICにしたときの性能はFPGA向けの論理合成をもとに推定できるのだそうです．

## 既存のErlang VMや互換VMの開発体制の中に入っていくことが難しかった

詳細は書きませんが，アプローチしてみて，私のような外部の人間が，これらの開発体制の中に入っていくのは難しいという感触を得ました．

## Erlang/Elixirの関数を使うとBEAMのバイトコードを容易に読み込むことができる

Erlang の [code モジュール](https://www.erlang.org/doc/man/code.html)と [beam_lib モジュール](https://www.erlang.org/doc/man/beam_lib.html)を使うと，簡単にBEAMのバイトコードを読むことができます．

https://www.erlang.org/doc/man/code.html

https://www.erlang.org/doc/man/beam_lib.html

参考記事

https://elixirforum.com/t/decompile-beam-files-to-elixir-source-code/14081


## ElixirからCコードを生成してJITコンパイルできる

Pelemayで確立した技術ですが，ElixirからCコードを生成してJITコンパイルすることができるようになりました．

## ElixirからのFPGA利用の性能を向上させるためには，ElixirとFPGAを接続するインタフェースを工夫する必要がある

安直にElixirのリスト構造をそのままFPGAに渡して大量データ処理をさせようとすると，ソフトウェアでリストを読み込むのにリストの長さに応じた時間がかかるので，性能が出ないということが明らかになりました．

Nxで行なっているような，バイナリでデータを扱うというようなことが必要だと考えられます．なので，Nxを基調とするとよいのでしょう．

## 現在のBEAMの仕組みでは，セキュリティとリアルタイム性に課題がある

Nerves ProjectのFrank Hunlethさんと意見交換したのですが，現状のBEAMの仕組みでは，軽量プロセスごとにセキュリティやリアルタイム性を設定することができません．

セキュリティについては，Dist Filteringという仕組みが提案されて，Erlang OTPにPull requestまで送られたのですが，OTPチームがいくつか理由を挙げてこのPRのマージを拒絶しています．

https://erlangforums.com/t/rfc-erlang-dist-security-filtering-prototype/1002

https://github.com/potatosalad/otp/pull/1


# まとめと次の話

以上のようなことを踏まえたとき，次のような基礎技術を自分で持っておくことが重要だと改めて認識しました．

* マルチコアのRISC-VソフトコアCPUをフルスクラッチで開発すること
* BEAM(Erlang VM)をフルスクラッチで開発すること
* RTOSを開発もしくは移植し，上記で動かすこと

つまり，自作CPU，自作OS，自作プログラミング言語処理系を開発できるようになっておかないといけないということですね．

ただ，これらが必要ですとは言うものの，私は研究者としてはアマチュアではなくプロフェッショナルであるため，この方向性の研究を単に自分の興味で進めるのではなく，研究費を調達して，新規性ある学術研究として，もしくは産業界に貢献する応用研究として，仕上げていくことが必要になってきます．

次のコラムでは，この方向性の研究について，出口となる応用領域は何か？について検討したいと思います．
