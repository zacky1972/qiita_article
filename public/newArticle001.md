---
title: DRP-AI日記その6 DRP-AIシリーズの研究の今後の展望についての技術的ポエム
tags:
  - Elixir
  - OpenBLAS
  - DRP-AI
  - Kakip
  - 技術的ポエム
private: false
updated_at: ''
id: null
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
DRP-AIシリーズの研究の今後の展望について技術的ポエムを書いてみました．

DRP-AIシリーズ・Kakip

- [DRP-AI日記その1 なぜDRP-AIシリーズに取り組むのか](https://qiita.com/zacky1972/items/3ebf021cab1e972890f8)
- [DRP-AI日記その2 Kakipを起動してみた](https://qiita.com/zacky1972/items/438ddc192fc499fb697c)
- [DRP-AI日記その3 Kakipネットワーク等初期設定](https://qiita.com/zacky1972/items/ab6a176f0ad481473f71)
- [DRP-AI日記その4 Elixirのインストール](https://qiita.com/zacky1972/items/922176433e54046b8338)
- [DRP-AI日記その5 OpenBLASを実行してみる](https://qiita.com/zacky1972/items/02be10d1acc013a499d2)

## DRP-AIシリーズについて

DRP-AIシリーズは，ルネサスエレクトロニクスのAIアクセラレータです．高い電力あたり性能が売りです．

## DRP-AIシリーズに特化したBLASを構築する

DRP-AIシリーズに特化したBLASを構築すると，様々なOSSをアクセラレートできるので良いと思います．可能ならば，OpenBLASにコードを寄贈するのが良いのですが，ルネサスエレクトロニクス次第かなとも思います．

コード最適化の研究者としても，DRP-AIシリーズに特化したBLASを構築することは大変興味をそそられます．

## Apple Accelerate Frameworkを参考にしてDRP-AIシリーズに特化した高速化ライブラリを構築する

Apple Accelerate Frameworkというものがあります．

https://developer.apple.com/jp/accelerate/

これを参考にしながら，DRP-AIシリーズに特化した高速化ライブラリを構築するのは，コード最適化の研究者として大いに興味をそそられます．

なお，BLASはApple Accelerate Frameworkの一部を形成しています．

## DRP-AIシリーズに特化したNxバックエンドを構築する

NxはElixirの機械学習基盤ライブラリです．Nxでは，Nxバックエンドを各種アクセラレータ向けに定義することができます．

前述の高速化ライブラリを活用して，DRP-AIシリーズに特化したNxバックエンドを構築できると良いですね．

## DRP-AIシリーズに特化したONNXライブラリを構築する

Elixirの標準ONNXライブラリであるOrtexでは，どうもNxバックエンドの機能を活用してくれないっぽいです．そこで，DRP-AIシリーズに特化したONNXライブラリを構築すると良いかなと思いました．

## DRP-AIシリーズ向けのBumblebeeアクセラレーションを検討する

BumblebeeはHugging Faceの機械学習ライブラリをElixirで使えるようにしたものです．前述のNxバックエンドとONNXのアクセラレーションに加えて，さらなるBumblebeeのアクセラレーションを検討します．

## DRP-AIシリーズ向けVulkanライブラリを構築する

Vulkanは汎用3Dグラフィックライブラリです．VulkanでDRP-AIシリーズを活用することを検討してみても良いかと思いました．

## 謝辞

本研究は北九州産業学術推進機構(FAIS)の令和6年度宇宙関連機器新技術開発事業の助成を受けた．

