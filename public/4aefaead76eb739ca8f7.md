---
title: RISC-V(リスク・ファイブ)について学ぶ意義
tags:
  - RISC-V
private: false
updated_at: '2019-04-09T00:32:59+09:00'
id: 4aefaead76eb739ca8f7
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
# はじめに

RISC-V(リスク・ファイブ) というインストラクション・セット・アーキテクチャ(ISA)は，知る人ぞ知るという感じで，最近急速に注目を集めています。え，聞いたことないですか？ そうですか。。。

ISA といえばx86とかARMとかが有名で，これらがデファクトスタンダード(事実上の標準)みたいな感じになっている中で，なぜ RISC-V なんていう，聞いたこともないようなISA について，わざわざこれから学ぶ必要があるんでしょう？

実は，私，RISC-Vの噂を聞きつけて，[RISC-V原典](https://amzn.to/2KfK5Ox)を読んで，軽く感動を覚えたんですよね！ この記事では私がなぜ RISC-V に対して感動を覚えたのかについて紹介することで，RISC-Vについて学ぶ意義について語ってみたいと思います。

# 感動理由その1: なぜこのように設計したのか，理由や意図が明示されているから

[RISC-V原典](https://amzn.to/2KfK5Ox)を読んでいくと，設計の概要から詳細まで1つ1つていねいに「なぜこのように設計したのか」理由や意図が明快に説明されていることにまず感動を覚えます。

それもそのはずです。[「RISC-V原典 (原書: RISC-V Reader)」](https://amzn.to/2KfK5Ox) の著者は，David Patterson と Andrew Waterman です。David Patterson という名前を聞いてピンときた人がいるかもしれませんが，CPUの仕組みについて学ぶ名著中の名著，いわゆる[「パタヘネ本」こと「コンピュータの構成と設計 (原書: Computer Organization and Design)」](https://amzn.to/2UoPdVd)の著者の1人なのです。

ちなみに「パタヘネ本」の由来は，Patterson & Hennesy の略ですね。ちなみに同じ著者で順番が逆になっている[「ヘネパタ本」こと「コンピュータアーキテクチャ定量的アプローチ(原書: Computer Architecture: Quantitative Approach)」という書籍もあります。こちらも名著中の名著です。

なお，RISC-V の研究開発を主導しているのは，Krste Asanović です。[RISC-V原典](https://amzn.to/2KfK5Ox)の帯にデカデカと「チューリング賞受賞パターソン教授 RISC研究40年の総決算 待望の邦訳！」とか書かれているので，つい私も Patterson 先生が RISC-V の生みの親かと誤解したのですが，実際には異なります。Patterson 先生もそのような誤解を受けていることを承知の上で RISC-V の広告塔の役割を担っているようです。

# 感動理由その2: ISAがシンプルなので

RISC-VはとてもシンプルなISAです。[RISC-V原典](https://amzn.to/2KfK5Ox)によると，RISC-V の ISA マニュアルと比べて，ARM-32は11倍以上，x86-32に至っては28倍以上もの語数があるそうです。ちなみに x86-64 はさらに巨大です。

全ての拡張機能を含む RISC-V ISA の要約は，なんとたったの2ページに収まります！[RISC-V原典](https://amzn.to/2KfK5Ox)の冒頭に「RISC-Vリファレンスカード」として表裏2ページに要約が掲載されています。

ISAがシンプルだと，プロセッサのサイズが小さくなり，性能も向上させやすくなります。また命令も追加しやすいです。

# 感動理由その3: なんとオープンソース！太っ腹！

x86 アーキテクチャは基本的に Intel のもので，勝手に使うことができません。AMD は Intel とクロスライセンスを締結することで利用権を得ています。

ARM も同様に Arm ホールディングスのもので，勝手に使うことができません。

しかし，RISC-V の ISA はオープンソースで，しかもBSDライセンスというゆるいライセンスで公開されています。RISC-V の実装も同様にオープンソースとして公開されているものがあります。ISAがBSDライセンスなので，商用ライセンスにしてもOKで，実際商用ライセンスの RISC-V 実装も多く存在します。

公開されている ISA やオープンソース実装をもとに，教育や研究を自由に行うことができ，それをもとにビジネスをすることも自由です。

RISC-V の仕様は RISC-V Foundation のもとで，科学的・民主的なプロセスを経て策定されます。これも理想的です。独自仕様を定義するための仕様も策定されています。

* [RISC-Vの仕様についてはこちら](https://riscv.org/specifications/)
* [RISC-Vの実装についてはこちら](https://riscv.org/risc-v-cores/)

# 感動理由その4: ツールが充実しているから

RISC-Vは，オープンソースであるという利点を備えているため，数多くの優れたオープンソースソフトウェアが RISC-V に対応しているので，とてもツールが充実しています。

* [RISC-Vのツール群についてはこちら](https://riscv.org/software-status/)

# おわりに

命令を追加しやすく，オープンソースかつツールが充実しているということは，独自の改造を施したCPUを提案し，それに対応した機械語コードを生成するプログラミング言語処理系を開発することも可能だということです。これは熱いですね！

こういう理由で，RISC-Vは教育にも研究にも向いています。RISC-Vに対応した，コンピュータアーキテクチャの書籍も充実しています(洋書ですけど)。

* [Computer Organization and Design RISC-V Edition: The Hardware Software Interface](https://amzn.to/2G7qUSW): パタヘネ本の最新刊の RISC-V 版です。
* [Computer Architecture, Sixth Edition: A Quantitative Approach](https://amzn.to/2Uoc978): ヘネパタ本の最新刊で RISC-V についても言及されています。
