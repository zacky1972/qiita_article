---
title: Elixir / Pelemay 研究の背景と意義
tags:
  - Elixir
  - Pelemay
private: false
updated_at: '2019-12-04T00:01:59+09:00'
id: a3dedc0cdacbeed21b6d
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[「言語実装 Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/lang_dev) 3日目です。

昨日は[「Elixir Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/elixir)2日目にて[「Elixir Zen スタイル講座: ループを Enum.reduce/3 で表す方法」](https://qiita.com/zacky1972/items/6181ab1ea917469a8080)という記事を書きました。

今日の本記事では，[第123回プログラミング研究発表会](https://sigpro.ipsj.or.jp/pro2018-5/program/)で2019年3月に既発表の「SumMag: Elixir マクロのメタプログラミングを用いた並列プログラミング拡張機構 Hastega の解析部の設計と実装」で述べた研究背景をベースに，徐々に書き足してきたものです。

現在の最新版，[第61回プログラミング・シンポジウム](http://www.ipsj.or.jp/prosym/61/61program.html)にて2020年1月に発表予定の「Elixir におけるC言語コード生成・最適化の試み」から背景部分を転載し一部改変して紹介します。

# 並列化が求められる背景

Cisco[1]によると，インターネット全体のIPトラフィックは，2017年に毎月122エクサバイト増加している．この増加率は年々増大しており，2022年には毎月396エクサバイト増加すると見込んでいる．この増加のほとんどは動画によるものであるが，接続デバイス数で見るとM2Mが急速に増加している．また，IDC[2]によると，インターネット上のデータの総量は2013年に4.4ゼタバイトであるが，2020年には44ゼタバイトに増加すると見込まれている．これらが示すように世界に流通する情報量は急速に増大している．

また，第5世代移動通信システム(5G)により通信速度も飛躍的に向上する．NTTドコモが2019年9月から提供する5Gプレサービスの最大通信速度はミリ波の受信時で3.2Gbpsに及ぶ[3]．実証実験の段階では，ニューヨークでの事例[4]，シカゴでの事例[5]で，500Gbps以上の通信速度を達成したと言われている．また遅延に対する要求も厳しく，要求条件としては無線区間の遅延を1ms以下にすることが求められる[6]．

これらの問題に対処するためには，情報を処理する計算能力を情報量の流通量・流通速度と同等以上に高める必要がある．しかし，Hennesy と Patterson [7] によると，2003年までは年々順調にクロック周波数が増加していたのに対し，2003年ごろから頭打ちとなってしまっている．これはクロック周波数が増大すると消費電力と発熱量も増大するが，電源供給量と熱伝導率および冷却能力が追いつかなくなり，常温の環境下で安定して動作させることが不可能になってしまうためである．

2003年以降のプロセッサの進化はクロック周波数の増加ではなくコア数の増加によっている．Intel が2006年に販売した Core シリーズの最上位プロセッサである Intel Core 2 Extreme X6800 は，クロック周波数が2.93GHz，物理コア数は2，論理コア数は4である．一方，2017年に販売した Core シリーズの最上位プロセッサである Intel Core i9 7980XE は，クロック周波数が2.6GHz，物理コア数は18，論理コア数は36である．

この方向性をもっと極端に推し進めたのが，GPUや，KiloCore[8]，The Cerebras Wafer-Scale Engine (WSE)[9]である．現代的な GPU は SIMD 方式で設計されることが一般的であり，MIMD方式と比べて単純化されることから，極めて大きいコア数が実現されている．たとえば NVIDIA TITAN RTX では，SIMDコアが4000以上にも及ぶ．KiloCore[8]は，MIMD方式のコアで初めて1000以上を達成したプロセッサである．WSE[9]はウェハーサイズの巨大なプロセッサであり，AI処理に最適化されたコアが40万にも及ぶ．

クロック数が順調に伸びていた時代ではソフトウェアを何も変えなくても順調に性能が向上していたであろう．一方，クロック周波数が伸びずにコア数が増加する状況下で性能を向上させるためには，並列プログラミングが求められる．そこで，近年次々と，さまざまな並列プログラミングモデルに基づいたプログラミング言語が提案されている．Elixir や Pelemay Super-Parallelism は，その中の1つに位置付けられる．

# Elixir と Pelemay Super-Parallelism

Elixir (エリクサー) [10] は2012年に José Valim が開発した並列プログラミング言語である．Elixir は関数型言語 Erlang [11] を母体としており，並列プログラミングのための数々の優れた特長を有する．

Elixir を用いることで，たとえばウェブシステムのレスポンス性能を大きく改善することができる．Fedrecheski ら[12]によると，Java では毎秒1,200リクエスト程度で急速にレスポンス性能が悪化してしまったのに対し，Elixir では毎秒1,800リクエスト程度まで耐えられる．

我々はElixirのもつ並列プログラミングの特長をさらに活かすために，2018年からHastega(ヘイスガ)を研究開発した[13][14][15][16][17][18]．ただしHastegaという名称はファイナルファンタジーに由来するもので，スクエアエニックスに著作権があると考えられるものであることから，2019年8月にPelemay(ペレメイ)に改称した[19]．現在では，より包括する概念として Pelemay ファミリーとして研究提案をしようとしており，従来の Hastega に対応するものは，Pelemay Super-Parallelism と呼んでいる．

Pelemay Super-Parallelism は，ウェブのサーバー・エッジ・クライアント上にあるマルチコアCPUやGPUに負荷分散しつつSIMD並列計算を行うコードを生成することを目指した処理系である．2019年11月現在ではCPUコアの1つを使ったSIMD計算のコードを生成する[19]．

# 次回予告

次は[「#NervesJP Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/nervesjp)4日目[「Pelemayを開発している時にわかった Nerves 対応のコツ」](https://qiita.com/zacky1972/items/b2beeeb5fd8689faba84)と5日目に連続投稿します。よろしくお願いします。

# 利用上の注意事項

ここに掲載した著作物の利用に関する注意: 本著作物の著作権は情報処理学会に帰属します。本著作物は著作権者である情報処理学会の許可のもとに掲載するものです。ご利用に当たっては「著作権法」ならびに「情報処理学会倫理綱領」に従うことをお願いいたします。

Notice for the use of this material: The copyright of this material is retained by the Information Processing Society of Japan (IPSJ). This material is published on this web site with the agreement of the author (s) and the IPSJ. Please be complied with Copyright Law of Japan and the Code of Ethics of the IPSJ if any users wish to reproduce, make derivative work, distribute or make available to the public any part or whole thereof. 
All Rights Reserved, Copyright (C) Information Processing Society of Japan. 
Comments are welcome. Mail to address editj＠ipsj.or.jp, please.

# 参考文献

[1] Cisco: Cisco Visual Networking Index: Forecast and Trends, 2017–2022 (2018). White Paper.
[2] Turner, V., Gantz, J., Reinsel, D. and Minton, S.: The digital universe of opportunities: Rich data and the increasing value of the internet of things (2014). White Paper.
[3] NTT ドコモ: NTT ドコモ、「5G プレサービス」を9月20日(金曜)より開始(2019). [https://www.nttdocomo.co.jp/info/news_release/2019/09/18_00.html](https://www.nttdocomo.co.jp/info/news_release/2019/09/18_00.html).
[4] Segan, S.: T-Mobile’s LAA Creates Screaming Fast Speeds in NYC, PC Magagine (2018). [https://www.pcmag.com/news/359649/t-mobiles-laa-creates-screaming-fast-speeds-in-nyc](https://www.pcmag.com/news/359649/t-mobiles-laa-creates-screaming-fast-speeds-in-nyc).
[5] smartmobtech: Testing The First Ever 5G Network & Phone in USA (2019). [https://smartmobtech.com/news/testing-the-first-ever-5g-network-phone-in-usa/](https://smartmobtech.com/news/testing-the-first-ever-5g-network-phone-in-usa/).
[6] 岸山祥久，ベンジャブールアナス，永田 聡，奥村幸彦，中村武宏: ドコモの 5G に向けた取組み ― 2020年での5Gサービス実現に向けて―， Vol. 23, No. 4, pp. 6–17 (2016).
[7] Hennessy, J. L. and Patterson, D. A.: Computer Architecture: A Quantitative Approach, Morgan Kaufmann, 6th edition (2017).
[8] Bohnenstiehl, B., Stillmaker, A., Pimentel,
J. J., Andreas, T., Liu, B., Tran, A. T., Adeagbo, E. and Baas, B. M.: KiloCore: A 32-nm 1000-Processor Computational Array, IEEE Journal of Solid-State Circuits, Vol. 52, No. 4, pp. 891–902 (online), DOI: 10.1109/JSSC.2016.2638459 (2017).
[9] Cerebras Systems: The Cerebras Wafer-Scale Engine (2019). [https://www.cerebras.net](https://www.cerebras.net).
[10] Valim, J.: Elixir: Elixir is a dynamic, functional language designed for building scalable and maintainable applications. (2013). [https://elixir-lang.org](https://elixir-lang.org).
[11] Ericsson: Erlang Programming Language (1998). [https://www.erlang.org](https://www.erlang.org).
[12] Fedrecheski, G., Costa, L. C. P. and Zuffo, M. K.: Elixir programming language evaluation for IoT, 2016 IEEE International Symposium on Consumer Electronics (ISCE), pp. 105–106 (online), DOI: 10.1109/ISCE.2016.7797392 (2016).
[13] 山崎 進，森 正和，上野嘉大，高瀬英希: Hastega: Elixir プログラミングにおける 超並列化を実現するための GPGPU 活用手法，第 120 回情報処理学会プログラミング研究会, 熊本，情報処理学会プログラミング研究会 (PRO)，Vol. 2018, No. 2, 東京，p.(8) (2018). The paper and the presentation are available at [https://zeam-vm.github.io/papers/GPU-SWoPP-2018.pdf](https://zeam-vm.github.io/papers/GPU-SWoPP-2018.pdf) and [https://zeam-vm.github.io/GPU-SWoPP-2018-pr/](https://zeam-vm.github.io/GPU-SWoPP-2018-pr/), respectively.
[14] 山崎 進:ZEAM 開発ログ 目次 (2018). available at [https://qiita.com/zacky1972/items/70593ab2b70d192813df](https://qiita.com/zacky1972/items/70593ab2b70d192813df).
[15] 久江雄喜，山崎 進: Hastega: Elixir プログラミングにおける線形回帰の SIMD 命令による並列化，第122回情報処理学会プログラミング研究会, 福山, 広島，情報処理学会プログラミング研究会 (PRO)，Vol. 2018, No. 4, 東京，p.(5) (2019).
[16] 山崎 進，久江雄喜: SumMag:Elixir マクロ のメタプログラミングを用いた並列プログ ラミング拡張機構 Hastega の解析部の設計と実装，情報処理学会論文誌プログラミング
(PRO)，Vol. 12, No. 3, pp. 7–7 (2019). https: //ci.nii.ac.jp/naid/170000180471/.
[17] Yamazaki, S.: Hastega: Challenge for GPGPU on Elixir, Lonestar ElixirConf 2019, Austin, TX, USA (2019). The movie and the slides of this presentation are available at [https://youtu.be/lypqlGlK1So](https://youtu.be/lypqlGlK1So) and [https://speakerdeck.com/zacky1972/hastega-challenge-for-gpgpu-on-elixir-at-lonestar-elixirconf-2019](https://speakerdeck.com/zacky1972/hastega-challenge-for-gpgpu-on-elixir-at-lonestar-elixirconf-2019), respectively.
[18] Yamazaki, S.: Hastega: Challenge for GPGPU on Elixir (intend to apply it to machine learning) (2019). available at [https://link. medium.com/ThF3Y8pbXU](https://link. medium.com/ThF3Y8pbXU).
[19] Yamazaki, S. and Hisae, Y.: Return of Wabi-Sabi: Hastega Will Bring More and More Computational Power to Elixir, ElixirConf US 2019, Denver, CO, USA (2019). The movie and of the slides of this presentation are available at [https://youtu.be/uCkPyfFhPxI](https://youtu.be/uCkPyfFhPxI) and [https://speakerdeck.com/zacky1972/return-of-wabi-sabi-hastega-will-bring-more-and-more-computational-power-to-elixir](https://speakerdeck.com/zacky1972/return-of-wabi-sabi-hastega-will-bring-more-and-more-computational-power-to-elixir), respectively.
