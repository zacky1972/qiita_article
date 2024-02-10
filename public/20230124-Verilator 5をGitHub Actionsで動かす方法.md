---
title: Verilator 5をGitHub Actionsで動かす方法
tags:
  - SystemVerilog
  - verilator
  - GitHubActions
private: false
updated_at: '2024-02-10T09:22:30+09:00'
id: 5062e599a447ab529880
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

Verilatorのいいところは，macOSでも使える点と，GitHub ActionsでCIを組める点です．
Verilator 5になって，`--timing`オプションが使えるようになり，テストベンチで `#10;` すなわち10クロック待つ，みたいな記述ができるようになり，SystemVerilogでテストベンチが完結できるみたいです．それ以前のVerilatorだとCプログラムでテストベンチを書く必要がありました．(とはいえ，記述できるのは，ディジタル回路設計とコンピュータアーキテクチャ第2版にあるような，自己点検テストベンチまでで，テストベクタファイル付きテストベンチは意図通りにファイルを読み込めなかったのですけど)

そういうわけで，メインをVivadoのような商用のツールを使うにしても，Verilator 5を使えるようになっておくと良さそうに思います．

ただし，GitHub Actionsで用いられるUbuntuでは，`apt install verilator`でインストールされるのがVerilator 4であるため，GitHub Actionsで用いるためには，Verilator 5をカスタムビルドする必要があります．

次のような`main.yml`を書くことで，Verilator 5をビルドしてCIすることができましたので，ご報告します．(けっこう苦労しました)

```yaml:main.yml
# This is a basic workflow to help you get started with Actions

name: CI

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
    strategy: 
      matrix: 
        verilator: ["5.006"]

    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Run apt update
      - name: Run apt update
        run: sudo apt update 2>/dev/null

      # Install Verilator
      #- name: Install Verilator
      #  run: |
      #    sudo apt install verilator 2>/dev/null
      #    verilator --version

      # Install prerequisites
      - name: Run apt install prerequisites
        run: |
          sudo apt install -y tzdata git perl python3 make g++ ccache\
            autoconf automake autotools-dev \
            curl python3 libmpc-dev libmpfr-dev libgmp-dev \
            gawk build-essential bison flex texinfo gperf \
            libtool patchutils bc \
            zlib1g-dev libexpat-dev libfl-dev \
            numactl perl-doc help2man \
            2>/dev/null
      - name: Run pip3 install prerequisites
        run: sudo pip3 install sphinx sphinx_rtd_theme breathe
      - name: Run cpan install prerequisites
        run: |
          sudo cpan install Pod::Perldoc
          sudo cpan install Parallel::Forker

      # Build Verilator
      - name: Cache Verilator ${{ matrix.verilator }}
        uses: actions/cache@v3
        id: cache-verilator
        with:
          path: verilator-${{ matrix.verilator }}
          key: verilator-${{ matrix.verilator }}
      - name: Compile Verilator ${{ matrix.verilator }}
        if: steps.cache-verilator.outputs.cache-hit != 'true'
        run: |
          wget https://github.com/verilator/verilator/archive/refs/tags/v${{ matrix.verilator }}.tar.gz
          tar xvf v${{ matrix.verilator }}.tar.gz
          cd verilator-${{ matrix.verilator }}
          autoconf
          ./configure
          make -j2
      - name: Install Verilator ${{ matrix.verilator }}
        run: |
          cd verilator-${{ matrix.verilator }}
          sudo make install
          verilator --version

      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v3

      # Runs test (To be continued)
```

ただし，1つ欠点がありまして，Verilator 5のビルドに結構な時間がかかるのです...

そこで，Dockerイメージを使って改善したいなと思っています．ただし，Verilatorの公式のDockerイメージの最新版は，`4.211`なのですよね...

https://hub.docker.com/r/verilator/verilator

```zsh
$ sudo docker run -ti verilator/verilator:latest --version
Unable to find image 'verilator/verilator:latest' locally
latest: Pulling from verilator/verilator
16ec32c2132b: Pull complete 
21fdebe4356e: Pull complete 
c91d12c2dad8: Pull complete 
f074ffd5b99f: Pull complete 
285d27e2ff2d: Pull complete 
Digest: sha256:1442a3eced00a292581bc03f8c6ada25f0b8c29e04b413ff5c19645e78cb0a42
Status: Downloaded newer image for verilator/verilator:latest
Verilator 4.211 devel rev v4.210-59-g3ec3c2c2
```


20240210追記:

本記事から大幅アップデートした手法について，[FPGAマガジン特別版No.2で紹介しております https://fpga.tokyo/no2-2/](https://fpga.tokyo/no2-2/)

大変光栄なことに，トップを飾っております．

> 第1章　Verilator 5とGitHub Actionsによるテストベンチ自動検証

他にも有用な記事が満載ですので，ぜひこの機会にInterfaceを定期購読ください！
