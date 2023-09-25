---
title: Nerves の可能性は IoT だけじゃない(後編)〜Nervesで世界の消費電力を抑える
tags:
  - Elixir
  - Nerves
  - sdgs
  - Pelemay
private: false
updated_at: '2020-01-25T01:05:05+09:00'
id: ebdf9b3f048256b90c52
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[「#NervesJP Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/nervesjp)13日目の記事です。

昨日は[「Nerves の可能性は IoT だけじゃない(前編)〜ElixirとPelemayで世界の消費電力を抑える」](https://qiita.com/zacky1972/items/2c82a593fbb2e4c949d2)をお送りしました。今日はその続きです。

# スライド

[![slide.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/9ad19330-78b7-65eb-9f53-0cc29ffb43be.png)
](https://speakerdeck.com/zacky1972/di-qiu-wen-nuan-hua-toelixir)

# コンピュータの消費電力を抑えるためにソフトウェアでできること (おさらい)

クロック周波数を抑えてもCPUの計算能力をソフトウェアの力で維持・向上させるには，次の3つのアプローチがあるのでしたね。

* **目的を達成するのに必要なクロック数を削減する。**このためには，無駄な命令を実行しないことが肝要です。**コンパイル・最適化されたネイティブコード**で実行する方が，最適化されていないインタプリタ実行よりも，同じことをするのに必要な電力消費を抑えられます。
* **並列処理を最大限に生かして計算能力を高め，かつできるだけ同期・排他制御で計算が停止しないようにする。**コアが複数ある場合，1つのコアだけに処理を集中させてクロック周波数を上げて処理するよりも，複数のコアに処理を分散させてクロック周波数を下げた方が，消費電力あたりの計算能力を向上させることが容易です。
* **使わないモジュールのクロックを停止するなど電源コントロールをこまめに行うようにする。**使わないモジュールのクロックを停止すれば，理想的にはそのモジュールの消費電力を0にできます。実際には待機電力があるので，少し消費しますけどね。組込みソフトウェアではこの辺りをかなり頑張っていますね。

# Nerves で消費電力の問題に貢献できること

Nerves を形成している技術の本質を3つあげます。

* **イミュータブルなファイルシステム**: Nervesのファイルシステムはイミュータブル，すなわち書き換えができないようになっています。これにより，Reproducebility: 再現性を担保しています。
* **ミニマムなメモリ・ストレージ**: Nervesでは，使用するメモリやストレージの容量を最小限にするように，不要なモジュールを柔軟に切り離すことができるようにしています。
* **I/O制御**: Nerves が IoT を実現できるように，I/O制御に関する機能が充実しています。

これらにより，次のように消費電力の削減に貢献できます。

* **イミュータブルなファイルシステム**: まず，並列処理を最大限に生かして計算能力を高め，かつできるだけ同期・排他制御で計算が停止しないようにすることに貢献します。イミュータブルであることでファイルシステムに関する同期・排他制御の必然性を排除することができます。次に，イミュータブルであることで，メモリやストレージが少なくても機能するようにできるので，メモリやストレージに回す消費電力を減らすことができます。さらに，イミュータブル性によって生み出される再現性により，必要な処理能力に応じてモジュールごとの起動・停止を確実に行えるようになるので，不要なモジュールを停止させて待機させることも容易になります。
* **ミニマムなメモリ・ストレージ**: メモリやストレージが少なくても機能するようにできるので，メモリやストレージに回す消費電力を減らすことができます。
* **I/O制御**: アプリケーションから柔軟に電源制御を行えるようにできます。

このような特性を持つ Nerves を IoT だけでなく，インフラストラクチャ側でも積極的に使用したらいいんじゃないかと思っています。特に再現性による効果は絶大で，クラウドサーバーで必要になる負荷に応じた起動・停止が容易にできるようになります。これにより，必要十分なだけの計算能力を提供する電力効率の良いシステムを構築できます。

今後の課題としては，Nerves においても目的を達成するのに必要なクロック数を削減することを地道に行えば良いと考えています。それを Pelemay ファミリーの研究開発で行なっていきたいです。

# 最後に，SDGsについて

私たちは持続可能な開発目標(SDGs)を支援しています。

![SDGs_poster.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/fc60555c-9bf9-3e55-d894-901cbc60b5be.png)

SDGsは国連が中心となって今まで取り組んできた平和・環境・人権などの問題について，2030年までに全ての人を置き去りにせずに抜本的な改善を図ることを掲げた17の目標です。

私たちがElixirやPelemay，そして Nerves で解決しようとしている目標は，このうち次の2つです。

![sdg_icon_07_ja_2.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/27746b6b-f734-7251-37c7-8d4dee75d6ce.png)

ターゲット
7.3 2030年までに、世界全体のエネルギー効率の改善率を倍増させる。
By 2030, double the global rate of improvement in energy efficiency.

指標
7.3.1 エネルギー強度(GDP当たりの一次エネルギー)
Energy intensity measured in terms of primary energy and GDP

![sdg_icon_09_ja_2.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/d86a4348-25c5-e303-aeb2-40331dfcc32e.png)

ターゲット

9.4 2030年までに、資源利用効率の向上とクリーン技術及び環境に配慮した技術・産業プロセスの導入拡大を通じたインフラ改良や産業 改善により、持続可能性を向上させる。全ての国々は各国の能力に応じた取組を行う。
By 2030, upgrade infrastructure and retrofit industries to make them sustainable, with increased resource-use efficiency and greater adoption of clean and environmentally sound technologies and industrial processes, with all countries taking action in accordance with their respective capabilities.

指標
9.4.1 付加価値の単位当たりのCO2排出量
CO2 emission per unit of value added

※なお，みなさんがSDGsのロゴ等を使用する場合は，[SDGsのポスター・ロゴ・アイコンおよびガイドライン](https://www.unic.or.jp/activities/economic_social_development/sustainable_development/2030agenda/sdgs_logo/)にしたがってください。当ページはしたがっています。

# おわりに

2日間に渡って，Elixir, Nerves, Pelemay によって，消費電力あたりの計算能力を高められる可能性があることを紹介しました。これにより地球温暖化を食い止めることはできなくても，地球温暖化の進行を抑える時間稼ぎには貢献できると期待しています。これらの技術で生み出されたありあまる計算能力を地球温暖化を根本的に食い止めるための技術研究開発に用いることができるようにもしていきたいなと思っています。具体的には，Elixirによる数値計算や機械学習，シミュレーションなどのためのライブラリの整備です。

明日は @shaga さんの[「Nerves Training Add-on Boardを自分で作る」](https://qiita.com/shaga/items/8f93c347ba3f1dd43638)です。お楽しみに。

次は[「fukuoka.ex Elixir／Phoenix Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/fukuokaex)16日目の[「どうやら Erlang をコンパイルした時のCコンパイラによって Elixir の性能がかなり異なるようだ」]
(https://qiita.com/zacky1972/items/8ff9775d83062fd097be)です。こちらもお楽しみに。
