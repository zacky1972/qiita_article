---
title: Verilator 5をGitHub Actionsで動かす方法〜self-hosted runnerで高速化
tags:
  - SystemVerilog
  - verilator
  - GitHubActions
private: false
updated_at: '2024-02-10T09:22:30+09:00'
id: 937d3ea671007a409160
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
SystemVerilogのCI環境の構築で，今度はself-hosted runnerを使ってみたいと思います．

Verilator 5 を使う利点について

https://qiita.com/zacky1972/items/5062e599a447ab529880

> Verilatorのいいところは，macOSでも使える点と，GitHub ActionsでCIを組める点です．
Verilator 5になって，--timingオプションが使えるようになり，テストベンチで #10; すなわち10クロック待つ，みたいな記述ができるようになり，SystemVerilogでテストベンチが完結できるみたいです．それ以前のVerilatorだとCプログラムでテストベンチを書く必要がありました．(とはいえ，記述できるのは，ディジタル回路設計とコンピュータアーキテクチャ第2版にあるような，自己点検テストベンチまでで，テストベクタファイル付きテストベンチは意図通りにファイルを読み込めなかったのですけど)

下記のようにDockerを使って高速化しましたが，CIで常用するにはまだまだ速度が足りないと思っていました．

https://qiita.com/zacky1972/items/d0054b6d8567162898dd

Self-hosted runnerを使うことで，プライベートネットワーク上のリソースを使うことができます．今回の場合だと，環境をあらかじめセットアップしてDockerイメージ取得の時間を削減するのと，CPU資源とメモリ資源を潤沢に使って並列コンパイルをすることで，ビルドを高速化できる期待を持っています．

Self-hosted runnerに関する公式ドキュメント

https://docs.github.com/en/actions/using-github-hosted-runners/connecting-to-a-private-network

今回参考にした記事はこちらです．

https://devops-blog.virtualtech.jp/entry/20220926/1664160391

GitHubレポジトリ上の Settings > Actions > Runners で`New self-hosted runner`ボタンを押し，その手順にしたがって，環境を構築します．

ただし，最後の `./run.sh` をするかわりに，次のコマンドを入力します．

```bash
sudo ./svc.sh install $USER
sudo ./svc.sh start $USER
```

これでバックグラウンドでランナーが起動します．

今回，Ubuntu20.04に環境を構築しました．Verilator 5をインストールする手順は基本的には次の手順です．

https://verilator.org/guide/latest/install.html

ただし，不足しているのは，まず`help2man`のインストールです．

```bash
sudo apt install help2man
```

それから，Clang 9を用いるようにしないとエラーになります．Clang 9のインストールは下記です．

```bash
sudo apt install clang-9
```

`./configure` を実行する際に，次のようにして Clang-9 を用いるように設定します．

```bash
CXX=clang++-9 LINK=clang++-9 ./configure
```

あとは前述の手順の通りです．

GitHub Actionsのymlは次のようにします．

```yaml:verilator_on_local.yml
# This is a basic workflow to help you get started with Actions

name: Verilator on Rigel

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the "main" branch
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  build:
    # The type of runner that the job will run on
    runs-on: self-hosted

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v3

      # Run compiling and testing
      - name: Run compiling and testing
        run: |
          make -j$(nproc) -f Makefile.verilator clean test
```

`make -j$(nproc)`とすることで，マシンのポテンシャルをめいいっぱい使い切って並列ビルドします．また，Verilator 5環境構築済みなので，Dockerイメージの取得が不要です．

この変更により，ビルドとテストが数倍高速化され，ほとんど待たずに終了するようになりました！

20240210追記:

本記事から大幅アップデートした手法について，[FPGAマガジン特別版No.2で紹介しております https://fpga.tokyo/no2-2/](https://fpga.tokyo/no2-2/)

大変光栄なことに，トップを飾っております．

> 第1章　Verilator 5とGitHub Actionsによるテストベンチ自動検証

他にも有用な記事が満載ですので，ぜひこの機会にInterfaceを定期購読ください！
