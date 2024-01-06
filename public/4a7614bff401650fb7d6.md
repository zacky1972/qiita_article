---
title: GitHub ActionsでElixirとNervesのクロスプラットフォームCIを組む
tags:
  - Erlang
  - CI
  - Elixir
  - Nerves
  - GitHubActions
private: false
updated_at: '2023-07-01T05:05:31+09:00'
id: 4a7614bff401650fb7d6
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
GitHubでソフトウェア開発をするときに，GitHub Actionsを用いてCIを組むことで，複数のプラットフォーム上で自動テストを走らせることができます．

今回，下記のNxとEvisionを参考に，ElixirとNervesのシンプルなクロスプラットフォームのCIを組みましたので，その方法について紹介します．

https://github.com/elixir-nx/nx

https://github.com/cocoa-xu/evision

[作成したCIは，自作のPelemayBackend(二代目)に組み込みました(リンク先参照のこと)．](https://github.com/zeam-vm/pelemay_backend)

20230525追記: macOSで`asdf`を使って任意のバージョンで実行できるようにしました．しかもキャッシュしてくれます．
20230525追記: Ubuntuで`setup-beam`が失敗した時に`asdf`でインストールするようにしました．
20230525追記: 同じOSのバージョン違いでキャッシュの衝突が起こっていたのを解消しました．
20230526追記: Erlang/OTP25.1以降でOpenSSL@3を用いるようにした根拠
20230701追記: Elixir, Erlangのバージョンを最新にしました



# GitHub Actionsのホステッドランナーで利用できるプラットフォーム

下記に説明があります．

https://docs.github.com/ja/actions/using-github-hosted-runners/about-github-hosted-runners

2023年5月現在では次のプラットフォームが利用できます．

* Windows
    * Windows Server 2022 (`windows-latest`または`windows-2022`)
    * Windows Server 2019 (`windows-2019`)
* Ubuntu
    * Ubuntu 22.04 LTS (`ubuntu-latest`または`ubuntu-22.04`)
    * Ubuntu 20.04 LTS (`ubuntu-20.04`)
    * Ubuntu 18.04 (`ubuntu-18.04` **非推奨**)
* macOS
    * macOS 13 Ventura (`macos-13`または`macos-13-xl`)
    * macOS 12 Monterey (`macos-latest`, `macos-12`, `macos-latest-xl` または `macos-12-xl`)
    * macOS 11 Big Sur (`macos-11`)

# Elixir/Erlang環境の構築

## `setup-beam`のみを用いる場合(Windows, Ubuntu)

WindowsとUbuntuでは，`setup-beam`を用いることで，バージョンを指定してElixir/Erlang環境を構築できます．

https://github.com/erlef/setup-beam

macOSではエラーになってしまいます．

次のように設定することで，macOS以外の場合でElixir 1.14.5 とErlang/OTP 24.3.4.13の環境を構築できます．

```yaml
    - name: Set up Elixir (Ubuntu, Windows)
      if: ${{ !startsWith(runner.os, 'macos') }}
      uses: erlef/setup-beam@v1
      with:
        elixir-version: '1.14.5'
        otp-version: '24.3.4.13'
```

## `setup-beam`で失敗した時に`asdf`を用いる場合(Ubuntu)

`setup-beam`は最新版に追従するのが遅いようです．Ubuntuの場合は，`setup-beam`に失敗した時に`asdf`を使うようにすることができます(ついでにmacOSの場合も載せています)．`actions-system-info`を使って，バージョン違いの同一OSのキャッシュが衝突しないようにしています．

```yaml
    - uses: actions/checkout@v3
    - uses: kenchan0130/actions-system-info@master
      id: system-info
    - name: Set up OTP MAJOR and MINOR VERSION
      run: |
        echo "OTP_MAJOR_VERSION=$(echo ${{ matrix.otp-version }} | sed -e 's/^\([^\.]*\)\.\(.*\)$/\1/')" >> $GITHUB_ENV
        echo "OTP_MINOR_VERSION=$(echo ${{ matrix.otp-version }} | sed -e 's/^\([^\.]*\)\.\([^\.]*\).*$/\2/')" >> $GITHUB_ENV
    - name: Set versions Elixir and OTP
      run: |
        echo "erlang ${{ matrix.otp-version }}" >> ${{ github.workspace }}/.tool-versions
        echo "elixir ${{ matrix.elixir-version }}-otp-${{ env.OTP_MAJOR_VERSION }}" >> ${{ github.workspace }}/.tool-versions
    - name: Set up Elixir
      continue-on-error: true
      id: set_up_elixir_by_setup-beam
      uses: erlef/setup-beam@v1
      with:
        elixir-version: ${{ matrix.elixir-version }}
        otp-version: ${{ matrix.otp-version }}
    - name: Install asdf
      continue-on-error: true
      if: ${{ steps.set_up_elixir_by_setup-beam.outcome == 'failure' }}
      id: install_asdf
      uses: asdf-vm/actions/setup@v2
    - name: Restore .asdf
      if: ${{ steps.install_asdf.outcome == 'success' }}
      id: asdf-cache
      uses: actions/cache@v3
      with:
        path: |
          ~/.asdf/
        key: ${{ runner.os }}-${{ steps.system-info.outputs.release }}-asdf-${{ hashFiles('**/.tool-versions') }}
        restore-keys: ${{ runner.os }}-${{ steps.system-info.outputs.release }}-asdf-
    - name: Set up Elixir by asdf (Ubuntu)
      if: ${{ steps.asdf-cache.outcome == 'success' && steps.asdf-cache.outputs.cache-hit != 'true' && startsWith(runner.os, 'linux') }}
      uses: asdf-vm/actions/install@v2.1.0
      with:
        before_install: |
          sudo apt -y install build-essential automake autoconf git squashfs-tools ssh-askpass pkg-config curl libmnl-dev
    - name: Set up Elixir by asdf (macOS)
      if: ${{ steps.asdf-cache.outcome == 'success' && steps.asdf-cache.outputs.cache-hit != 'true' && startsWith(runner.os, 'macos') }}
      uses: asdf-vm/actions/install@v2.1.0
      with:
        before_install: |
          brew install wxwidgets openjdk fop openssl@3
          export CC="/usr/bin/gcc -I$(brew --prefix unixodbc)/include"
          export LDFLAGS="-L$(brew --prefix unixodbc)/lib"
          echo 'setup CC and LDFLAGS'
          if [ ${{ env.OTP_MAJOR_VERSION }} -eq 25 ]; then 
            if [ ${{ env.OTP_MINOR_VERSION }} -ge 1 ]; then
              export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@3) --with-odbc=$(brew --prefix unixodbc)"
            else
              export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@1.1) --with-odbc=$(brew --prefix unixodbc)"
            fi
          elif [ ${{ env.OTP_MAJOR_VERSION }} -ge 26 ]; then
            export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@3) --with-odbc=$(brew --prefix unixodbc)"
          else
            export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@1.1) --with-odbc=$(brew --prefix unixodbc)"
          fi
          echo "KERL_CONFIGURE_OPTIONS=$KERL_CONFIGURE_OPTIONS"
```

## macOSの場合

### Homebrewを用いる場合

macOSでは次のように，Homebrewを用いてHomebrewで保持しているバージョンのElixirとErlangの環境を構築する方法があります．ElixirとErlangのバージョンは指定できません．

```yaml
    - name: Set up Elixir (macOS)
      if: ${{ startsWith(runner.os, 'macos') }}
      run: |
        brew install erlang elixir
        mix local.hex --force
        mix local.rebar --force
```

HomebrewでインストールされるElixirとErlangのバージョンに注意してください．

### `asdf`を用いる場合

コメントいただいて，`asdf`を用いる方法を試行錯誤し，成功しました！

Erlang/OTP25.1以降では`openssl@3`を使い，それ以前のバージョンでは`openssl@1.1`を使うようにしています．その根拠はこちら:

https://www.erlang.org/patches/otp-25.1#highlights

> OTP-18153
> Application(s):
> crypto
> Crypto is now considered to be usable with the OpenSSL 3.0 cryptolib for production code.



```yaml
    - uses: kenchan0130/actions-system-info@master
      id: system-info
    - name: Set up OTP MAJOR and MINOR VERSION
      run: |
        echo "OTP_MAJOR_VERSION=$(echo ${{ matrix.otp-version }} | sed -e 's/^\([^\.]*\)\.\(.*\)$/\1/')" >> $GITHUB_ENV
        echo "OTP_MINOR_VERSION=$(echo ${{ matrix.otp-version }} | sed -e 's/^\([^\.]*\)\.\([^\.]*\).*$/\2/')" >> $GITHUB_ENV
    - name: Install asdf (macOS)
      if: ${{ startsWith(runner.os, 'macos') }}
      uses: asdf-vm/actions/setup@v2
    - name: Set versions Elixir and OTP (macOS)
      if: ${{ startsWith(runner.os, 'macos') }}
      run: |
        echo "erlang ${{ matrix.otp-version }}" >> ${{ github.workspace }}/.tool-versions
        echo "elixir ${{ matrix.elixir-version }}-otp-${{ env.OTP_MAJOR_VERSION }}" >> ${{ github.workspace }}/.tool-versions
    - name: Restore .asdf (macOS)
      if: ${{ startsWith(runner.os, 'macos') }}
      id: asdf-cache
      uses: actions/cache@v3
      with:
        path: |
          ~/.asdf/
        key: ${{ runner.os }}-${{ steps.system-info.outputs.release }}-asdf-${{ hashFiles('**/.tool-versions') }}
        restore-keys: ${{ runner.os }}-${{ steps.system-info.outputs.release }}-asdf-
    - name: Set up Elixir (macOS)
      if: ${{ steps.asdf-cache.outputs.cache-hit != 'true' && startsWith(runner.os, 'macos') }}
      uses: asdf-vm/actions/install@v2.1.0
      with:
        before_install: |
          brew install wxwidgets openjdk fop openssl@3
          export CC="/usr/bin/gcc -I$(brew --prefix unixodbc)/include"
          export LDFLAGS="-L$(brew --prefix unixodbc)/lib"
          echo 'setup CC and LDFLAGS'
          if [ ${{ env.OTP_MAJOR_VERSION }} -eq 25 ]; then 
            if [ ${{ env.OTP_MINOR_VERSION }} -ge 1 ]; then
              export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@3) --with-odbc=$(brew --prefix unixodbc)"
            else
              export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@1.1) --with-odbc=$(brew --prefix unixodbc)"
            fi
          elif [ ${{ env.OTP_MAJOR_VERSION }} -ge 26 ]; then
            export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@3) --with-odbc=$(brew --prefix unixodbc)"
          else
            export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@1.1) --with-odbc=$(brew --prefix unixodbc)"
          fi
          echo "KERL_CONFIGURE_OPTIONS=$KERL_CONFIGURE_OPTIONS"
```

# Nervesでのビルド確認

GitHub Actionsのホステッドランナーでは次のようにしてNervesでビルドできることを確認できます．

```yaml
name: nerves-build

on:
    pull_request:
      branches: [ "main" ]
      paths-ignore:
        - '*.md'
        - '**/*.md'
        - '*.cff'
        - 'LICENSE*'
    workflow_dispatch:
  
permissions:
    contents: read
  
jobs:
    build:
  
      name: Nerves Build on ${{ matrix.working-directory }}, ${{ matrix.target }}
      runs-on: ubuntu-20.04
      env:
        MIX_ENV: prod
        NERVES_LIVEBOOK_VER: "v0.9.1"
        OTP_VERSION: "25.2.3"
        ELIXIR_VERSION: "1.14.5"

      strategy:
        fail-fast: false
        matrix:
          working-directory: ["pelemay_backend"]
          target: [rpi4, rpi3a, rpi3, rpi2, rpi0, rpi, bbb, osd32mp1, npi_imx6ull, grisp2, mangopi_mq_pro]
      defaults:
        run:
          working-directory: ${{ matrix.working-directory }}
      steps:
      - uses: actions/checkout@v3
      - name: Set up Elixir (Ubuntu, Windows)
        uses: erlef/setup-beam@v1
        with:
          elixir-version: ${{ env.ELIXIR_VERSION }}
          otp-version: ${{ env.OTP_VERSION }}
      - name: Install SSH key
        uses: shimataro/ssh-key-action@v2
        with:
            key: ${{ secrets.SSH_KEY }}
            name: id_rsa
            known_hosts: localhost
      - name: Install system dependencies
        run: |
            sudo apt update && sudo apt install -y  build-essential automake autoconf pkg-config bc m4 unzip zip curl git libssl-dev libncurses5-dev python3 ca-certificates squashfs-tools ssh-askpass libmnl-dev
            mix local.hex --force
            mix local.rebar --force
      - name: Restore dependencies cache
        uses: actions/cache@v3
        with:
          path: ${{ github.workspace }}/${{ matrix.working-directory }}/deps
          key: ${{ runner.os }}-Elixir-v${{ env.ELIXIR_VERSION }}-OTP-${{ env.OTP_VERSION }}-${{ hashFiles(format('{0}/{1}/mix.lock', github.workspace, matrix.working-directory)) }}
          restore-keys: ${{ runner.os }}-Elixir-v${{ env.ELIXIR_VERSION }}-OTP-${{ env.OTP_VERSION }}-
      - name: Install dependencies
        run: mix deps.get
      - name: Create a Nerves project
        run: |
            mix archive.install hex nerves_bootstrap --force || true
            wget -k https://github.com/fwup-home/fwup/releases/download/v1.10.0/fwup_1.10.0_amd64.deb -O ./fwup_1.10.0_amd64.deb
            sudo dpkg -i ./fwup_1.10.0_amd64.deb
            cd ../
            git clone https://github.com/livebook-dev/nerves_livebook.git
            cd nerves_livebook
            git checkout "${NERVES_LIVEBOOK_VER}"
            git checkout mix.exs
            LINE="$(grep -n 'toolshed' mix.exs | awk -F: '{print $1+1}')"
            head -n "${LINE}" mix.exs > mix.exs.tmp
            echo "      {:$(basename ${{ matrix.working-directory }}), path: \"../$(basename ${{ matrix.working-directory }})\"}," >> mix.exs.tmp
            tail -n "+${LINE}" mix.exs >> mix.exs.tmp
            mv mix.exs.tmp mix.exs
            cat mix.exs
            export MIX_TARGET=${{ matrix.target }}
            mix deps.get
            mix deps.update nx
            mix deps.update kino
            export MAKE_BUILD_FLAGS="-j$(nproc)"
            mix deps.compile
            mix firmware
```

ポイントを説明していきます．

## SSHの設定

GitHubのレポジトリのSettings > Security > Secrets and variables > Actionsで，Secretsを登録します．

`SSH_KEY`という名前で適当な秘密鍵を登録しましょう．

GitHub Actionsのワークフローの下記記述によりSSH鍵を使用できます．

```yaml
      - name: Install SSH key
        uses: shimataro/ssh-key-action@v1
        with:
            private-key: ${{ secrets.SSH_KEY }}
            name: id_rsa
```

## Nervesの前提ライブラリ類のインストール

下記のようにします．

```yaml
      - name: Install system dependencies
        run: |
            sudo apt update && sudo apt install -y  build-essential automake autoconf pkg-config bc m4 unzip zip curl git libssl-dev libncurses5-dev python3 ca-certificates squashfs-tools ssh-askpass libmnl-dev
            mix local.hex --force
            mix local.rebar --force
```

さらに下記のようにするとNervesと`fwup`をインストールできます．

```yaml
      - name: Create a Nerves project
        run: |
            mix archive.install hex nerves_bootstrap --force || true
            wget -k https://github.com/fwup-home/fwup/releases/download/v1.10.0/fwup_1.10.0_amd64.deb -O ./fwup_1.10.0_amd64.deb
            sudo dpkg -i ./fwup_1.10.0_amd64.deb
```

## Nerves Liveviewのビルド

次のような流れになります．

1. Nerves Liveviewを`clone`, `checkout`する
1. `mix.exs`にテストしたいライブラリを追記する
1. 環境変数`MIX_TARGET`を設定する
1. ビルドする

詳しくは前述のコードを見てください．

# GitHub上のREADMEにCIの状態を表すアイコンをつける

たとえばGitHubユーザー`user`レポジトリ`repository`のワークフロー`.github/workflows/ci.yml`があったときに，そのワークフローが成功したか失敗したかをREADMEに記載するには次のようにします．

```markdown
[![CI status](https://github.com/user/repository/actions/workflows/ci.yml/badge.svg)](https://github.com/user/repository/actions/workflows/ci.yml/badge.svg)
```

