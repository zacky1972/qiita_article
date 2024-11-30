---
title: M1/M2 Mac への ElixirとErlang インストール2024年11月決定版
tags:
  - Erlang
  - homebrew
  - Elixir
  - asdf
  - M1
private: false
updated_at: '2024-11-30T09:36:26+09:00'
id: c94baef2ee9379c21fa1
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
# はじめに

[fukuoka.ex Elixir/Phoenix Advent Calendar 2021](https://qiita.com/advent-calendar/2021/fukuokaex)の6日目の記事です。 5日目は @kn339264 さんの[Elixir女子部のオーガナイザーをやってみた話](https://qiita.com/kn339264/items/397a35386fddb4e60048)でした。

M1 Mac の初期状態からElixirとErlangを Homebrew と`asdf`でインストールする完全手順をご紹介します。

```zsh
% elixir -v
Erlang/OTP 27 [erts-15.1.2] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit]

Elixir 1.17.3 (compiled with Erlang/OTP 27)
```

なお，Erlang/OTPのインストールの最新の方法は[Community-maintained pre-compiled Erlang/OTP for macOS を使ってErlangをインストールする](https://qiita.com/zacky1972/items/ddb5f99464dd10339e52)と思います．コンパイル時間が不要かつバージョン指定できるので，便利です！


2021.12.16 追記: Erlang/OTP 24.2でOpenSSL 3.0に対応したので，その場合のインストール手順を追記しました。
2022.12.3 追記: Ventura対応版を書きました
2023.2.18 追記: Erlang/OTP 26.0 Release Candidate 1にも対応していることを確認しました
2023.3.2 追記: セグメンテーション・フォールトに見舞われる場合のトラブルシューティングを追記しました．
2023.3.30 追記: Erlang/OTP 25.1 からOpenSSL 3.0を本採用して大丈夫という情報を得たので，追記しました．
2023.3.30 追記: Erlang/OTP 26.0 Release Candidate 2にも対応していることを確認しました
2023.6.23 追記: Xcode，Erlang/OTP，Elixirのバージョンを最新にしました．最初にインストールされるOpenSSLのバージョンが3系統になっていたのを確認しました．
2023.7.1 追記: Erlang/OTP, Elixirのバージョンを最新にしました．
2023.9.26 追記: Xcodeのバージョンを最新にしました．Elixirのバージョンを明記しました．
2023.9.28 追記: Erlangのバージョンアップをしました．
2023.10.21 追記: Erlangのバージョンアップをしました．
2023.11.27 追記: OpenSSL 1.1系列がサポート外になったことを踏まえて，記述を見直しました．
2023.12.14 修正: 1箇所，PATHをベタガキしていたところを修正しました．これでIntel Macでもこの手順でいけると思います．
2024.2.15 追記: Erlang/OTP 27に対応しました．
2024.9.23 追記: Xcode 16.0に対応しました。
2024.11.30 追記: Community-maintained pre-compiled Erlang/OTP for macOS について言及しました．


# 1. macOSアップグレード

最初にmacOSを最新版にアップグレードしましょう．

# 2. Xcode インストール (オプション)

Xcode をインストールしなくても Homebrew はインストールできるのですが，Xcodeをインストールするとしたら，この段階でしておきます。

# 2.5. 要チェック！

Finderでアプリケーション＞ユーティリティを開いて，`ターミナル.app`を右クリックし，「情報を見る」とします．一般情報で，もし「Rosettaを使用して開く」にチェックが入っていたら，チェックを外してください．そうしないと，インストールしたElixir/Erlangがセグメンテーション・フォールトで異常終了するようになってしまいます．

# 3. Homebrewインストール

ターミナルを起動し，[Homebrew公式サイト](https://brew.sh/ja/)の手順に則ってインストールした後，コマンドラインで表示されるインストール後の手順をします。

ここにコマンドを転載しておきますが，↑と照合して確認して使用してくださいね。(途中，`sudo`によるmacOSログインのパスワード入力が求められます)

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${ZDOTDIR:-~}/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

# HomebrewでElixirをインストールする場合

ここで次のコマンドを入力すれば完了です。

```zsh
brew update
brew install elixir
``` 

最近はこのインストール手順で最新版かつ完全版のElixirとErlangがインストールされます。常に最新版を使うという人は，Homebrewでのインストールの方が簡単かつ保守しやすいですね。

# HomebrewでErlangのみをインストールする場合

```zsh
brew update
brew install erlang
```

# `asdf`でElixirをインストールする場合

公式の手順だと不完全版がインストールされます。どう不完全かというと，wxとリンクされなかったりとか，odbcとリンクされなかったりとか，Erlangのドキュメントが欠落したりとかします。

## Homebrewで`asdf`をインストール

[公式サイトの手順](http://asdf-vm.com/guide/getting-started.html#_1-install-dependencies)にのっとります。下記にコマンドを記載しますが，必ず照合して確認して使用してくださいね。

```zsh
brew install asdf
echo -e "\n. $(brew --prefix asdf)/libexec/asdf.sh" >> ${ZDOTDIR:-~}/.zshrc
source ${ZDOTDIR:-~}/.zshrc
```

## `asdf`でErlangをインストール

この手順がポイントです。まず前提となるライブラリ群をインストールします。なお，OpenSSLは`asdf`を入れる際に3系統が入る模様です。

2023.6.23 追記: 最初にインストールされるOpenSSLのバージョンが3系統になっていたのを確認しました．
2023.12.14 修正: 1箇所，PATHをベタガキしていたところを修正しました．これでIntel Macでもこの手順でいけると思います．
2024.2.15 追記: Erlang/OTP 27に対応しました．

Erlang/OTP 26以前は，下記のようにインストールの準備をします．

```zsh
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
brew install wxwidgets
brew install openjdk
echo 'export PATH="$(brew --prefix openjdk)/bin:$PATH"' >> ${ZDOTDIR:-~}/.zshrc
source ${ZDOTDIR:-~}/.zshrc
brew install fop
```

Erlang/OTP 27をインストールする時には，ドキュメントの生成に`ex_doc`コマンドを使用するので，上記に加えて，一旦，Erlang/OTP 26以前をインストールし，最新版のElixirもインストールした後で，次の手順を行います．

```zsh
mix escript.install hex ex_doc
```

すると例えば次のように表示されます．

```zsh
* creating .../.asdf/installs/elixir/1.16.1-otp-26/.mix/escripts/ex_doc
```

このディレクトリ(最後の`ex_doc`を抜いたパス)を`PATH`に追加します．

2021.12.16 追記: Erlang/OTP 24.2以降はOpenSSL 3.0に対応したので，その場合には次のようにします。
2023.3.30 追記: Erlang/OTP 25.1 からOpenSSL 3.0を本採用して大丈夫という情報を得たので，追記しました．

Erlang/OTP 25.1以降をインストールする場合には，次のようにしてOpenSSL 3.0以降を用いるように環境変数を設定します．

```zsh
export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@3) --with-odbc=$(brew --prefix unixodbc)" CC="/usr/bin/gcc -I$(brew --prefix unixodbc)/include" LDFLAGS=-L$(brew --prefix unixodbc)/lib
```

2023.11.27 追記: OpenSSL 1.1系列がサポート外になったことを踏まえて，記述を見直しました．

もしErlang/OTP 25.0以前をインストールする場合には，次のようにしてOpenSSL 1.1系列を用いるように環境変数を設定します．ただし，OpenSSL 1.1系列は2023年9月にサポート外になりましたので，Erlang/OTP 25.0系列以前の使用を推奨されません．．

```zsh
brew install openssl@1.1
export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@1.1) --with-odbc=$(brew --prefix unixodbc)" CC="/usr/bin/gcc -I$(brew --prefix unixodbc)/include" LDFLAGS=-L$(brew --prefix unixodbc)/lib
```

なお，ODBCを有効にするための手順は次のIssueを参考にしました。

https://github.com/asdf-vm/asdf-erlang/issues/191

2024.9.23 追記: Xcode 16.0に対応しました。

その後，最新版をインストールするなら次の手順です。結構時間がかかります。

```zsh
ulimit -n 65536
asdf install erlang latest
asdf global erlang latest
```

現在インストール可能なバージョンを確認するのは次の方法で行います。

```zsh
asdf list-all erlang
```

ただし，21以前のメジャーバージョンや各バージョンのリビジョン古めのものは，M1に対応していないことが多く，インストールできないことがあります。

22バージョンの新しめリビジョンをインストールするときには次のIssueを参考にしてください。(現時点で未解決？)

https://github.com/asdf-vm/asdf-erlang/issues/221

インストールが終わったら他に影響を与える環境設定を解除しておきます。Elixirインストール後にターミナルを閉じるのであれば，この手順は不要です。

```zsh
unset CC LDFLAGS
```

## `asdf`でElixirをインストールする

Elixirのインストールは公式の手順でOKです。

```zsh
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
```

その後，最新版をインストールするなら次の手順です。

```zsh
asdf install elixir latest
asdf global elixir latest
```

現在インストール可能なバージョンを確認するのは次の方法で行います。

```zsh
asdf list-all elixir
```

# おわりに

以上でElixirとErlangの完全版をM1 Macにインストールできます。

明日は @koyo-miyamura さんの[Elixir + SendGrid でメール送信してみる](https://qiita.com/koyo-miyamura/items/34e369200fe1aeafb0af)ですね。お楽しみに。
