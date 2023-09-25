---
title: Elixirと宇宙の話でもしますか〜Elixirを使った宇宙利用を実践していこう
tags:
  - Elixir
  - 宇宙
  - Axon
  - nx
  - evision
private: false
updated_at: '2022-12-13T19:55:22+09:00'
id: 5fced3392af5746c6a9f
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
現在，私は大きく分けて，並列プログラミング言語Elixirに関する研究と，宇宙利用・宇宙開発におけるコンピュータの研究を行っています．この2つは，まるで関連がないように思うかもしれませんが，私はこの2つの研究を，一貫性を持って研究しているつもりでいます．この記事は[「Elixirと宇宙の話でもしますか〜Elixirと宇宙利用の関係」](https://qiita.com/zacky1972/items/6c98bb91c7c076f92988)の続きを書きます．

なお，この記事は，[A-STEPトライアウト「SAR衛星観測データ解析・伝送・共有による費用対効果の高い土砂災害検出システムの実現可能性検証」](https://zacky1972.github.io/blog/2022/03/29/sar-apps.html)と，[北九州産業学術推進機構(FAIS)の旭興産グループ研究支援プログラム「ARM CPUとApple Silicon向け機械学習・画像処理の高速化・並列化・コード最適化とプログラムコードに含まれる不具合・脆弱性の検出と排除に関する研究開発」](https://zacky1972.github.io/blog/2022/03/03/nx-accel.html)をつなぐ導線の紹介でもあります．

https://zacky1972.github.io/blog/2022/03/29/sar-apps.html

https://zacky1972.github.io/blog/2022/03/03/nx-accel.html

また[科研費基盤C「MPSoCとSAR衛星によるリアルタイム土砂災害情報提供システムの実現可能性検証」](https://zacky1972.github.io/blog/2022/03/04/sar-data-processing-satellites.html)の一環でもあります．

https://zacky1972.github.io/blog/2022/03/04/sar-data-processing-satellites.html

# 前回のおさらい

[前回の記事](https://qiita.com/zacky1972/items/6c98bb91c7c076f92988)では，衛星データはとてつもない量にのぼる可能性があり，処理するのも通信するのも保存するのも大変であることを示しました．その上で，Elixirの並列処理がしやすいという特性により，処理と通信を抜本的に改善できるのではないかという期待があること，巨大な画像を扱った画像処理や機械学習は実行に長時間かかることがあり，この処理が途中で異常終了してしまうと困るので，ElixirのもつSupervisorに期待していることを紹介しました．

その方向性で，次のような研究開発をしてきたことを紹介しました．

https://youtu.be/9H0AsmAsxgk

https://youtu.be/RkMzCQm-Ws4

この研究開発を共同で行なった企業の1つである株式会社オーイーシーの @RyoWakabayashi さんが次のようなQiita記事に仕上げてくださいました．

https://qiita.com/RyoWakabayashi/items/60d0aec59d7d6cc65f9c

# Elixirで衛星画像処理を行う基盤について

Pythonでは，NumPyとOpenCVによって画像処理を行うスクリプトを，Jupyter Notebook上で途中経過や結果を見ながら編集するというのが一般的だと思います．さらに様々な機械学習やディープラーニングのライブラリを使って解析していくものと思います．Pandasでデータ分析をしていくことでしょう．

現在では同様のことをElixirで行うことができます．Nx(エヌエックス)は，NumPyやTensorFlowに相当することができます．Evision(イー・ヴィジョン)はOpenCVをElixirから使うためのライブラリです．Axon(アクソン)で機械学習やディープラーニングを扱えます．LivebookではJupyter Notebook相当のことをElixirで行えます．Explorer(エクスプローラー)はPandas相当のデータ分析を行えます．

Pythonで行う場合に比べて，Elixirでこれらを行うことで，分散並列処理を容易に行えます．また，Supervisorの活用で異常終了することなく最後まで確実に処理することもできるでしょう．

# 衛星データ活用のヒントとなる記事

@RyoWakabayashi さんがElixirでの衛星データ活用のヒントとなる記事を精力的に執筆しています．

## 環境構築

https://qiita.com/RyoWakabayashi/items/113b94866780c7646af1

## 画像処理

https://qiita.com/RyoWakabayashi/items/60d0aec59d7d6cc65f9c

https://qiita.com/RyoWakabayashi/items/ef858baebecf84028a14

https://qiita.com/RyoWakabayashi/items/1a83c962ae03791a988c

https://qiita.com/RyoWakabayashi/items/45a7daccf064b8720ad0

https://qiita.com/RyoWakabayashi/items/ae6264a38897ecea7dc2

## 機械学習

https://qiita.com/RyoWakabayashi/items/696f19559dd20fe5e5a7

## データ分析

https://qiita.com/RyoWakabayashi/items/f3636171dee22c8305fa

https://qiita.com/RyoWakabayashi/items/dfb5495b9c25eff710a2

https://qiita.com/RyoWakabayashi/items/a06ae639337726be2e9d

https://qiita.com/RyoWakabayashi/items/167d6b8c9215ade42346

https://qiita.com/RyoWakabayashi/items/94d8f6af5fd4cfc9c7ef

https://qiita.com/RyoWakabayashi/items/840bc865bf0222a7e2e7


## オープンデータの利用応用事例

### 地域経済分析システムRESAS

https://qiita.com/RyoWakabayashi/items/fdc0efa99f35ffb0829f

https://qiita.com/RyoWakabayashi/items/2c9d208e5055fe20f1e3

## 衛星データプラットフォームTellus

https://qiita.com/RyoWakabayashi/items/af11cc82101223fe248d

https://qiita.com/RyoWakabayashi/items/e884ca99f74cd05717ea

https://qiita.com/RyoWakabayashi/items/3c78ad939f83a2eb14c4

# 慣れてきたら宙畑の事例をElixirでやってみよう

宙畑にはたくさんの衛星データ利用の事例が載っています．

https://sorabatake.jp

例えば2022年12月に公開になったばかりの記事として次の記事があります．

https://sorabatake.jp/29892/

この事例はPythonを使っていると思いますが，同じことをElixirでやってみてはいかがでしょうか？ 良い練習題材になると思います．

他にもいろいろ事例がありますよ．

https://sorabatake.jp/22161/

https://sorabatake.jp/13778/


# 基盤となるNxを高速化するために

基盤となるNxを高速化するために現在進めているのが，Pelemay Backend(ペレメイ・バックエンド)の研究開発です．Nxを分散並列に処理し，かつ確実に行えるようにするものです．

https://zacky1972.github.io/blog/2022/03/03/nx-accel.html

https://qiita.com/zacky1972/items/9a080c90be00231dd863


