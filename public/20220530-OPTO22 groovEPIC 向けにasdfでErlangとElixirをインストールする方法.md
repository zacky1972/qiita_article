---
title: OPTO22 groovEPIC 向けにasdfでErlangとElixirをインストールする方法
tags:
  - Erlang
  - Elixir
  - IoT
private: false
updated_at: '2023-10-22T10:09:42+09:00'
id: 9fd84f5103e3e5f6a6ca
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[OPTO22 の groovEPIC](https://www.aec.co.jp/solution/opto22/opto22.html)でErlangとElixirを動作させることに成功しましたので報告します。

追記 20220601: 詳細な手順を記述しました。
追記 20220623: OpenSSLとErlangの最新版に追従しました．
追記 20220708: OpenSSLを最新版に追従しました．
追記 20221102: OpenSSL, Elixir, Erlangを最新版に追従しました．
追記 20221113: Elixirを最新版に追従しました．
追記 20230209: OpenSSL, Elixir, Erlangを最新版に追従しました．
追記 20230330: Erlang/OTP 25.1以降ではOpenSSL3.0系列を用いるように修正しました．
追記 20230612: OpenSSL, Elixir, Erlangを最新版に追従しました．
追記 20230701: Elixir, Erlangを最新版に追従しました．
追記 20230930: Elixir, Erlang, OpenSSL, asdfを最新版に追従しました．
追記 20231022: Elixir, Erlangを最新版に追従しました．

![groovEPIC](https://zacky1972.github.io/assets/images/groovEPIC.jpg)

```zsh
$ elixir -v
Erlang/OTP 26 [erts-14.1.1] [source] [32-bit] [smp:4:4] [ds:4:4:10] [async-threads:1]

Elixir 1.15.7 (compiled with Erlang/OTP 26)
$ uname -a
Linux opto-04-88-28 4.1.15-rt18-nxtio-2.1.0+g28bea2e #2 SMP PREEMPT RT Thu Sep 1 18:49:10 PDT 2022 armv7l GNU/Linux
```

# 手順

1. SSH使用のライセンスを申請し，設定します
1. `apt-get`で`ncurses-dev`をインストールします
1. OpenJDKの`jar`のシンボリックリンクを`/usr/bin`に作ります
1. OpenSSLをソースコードからビルドし，インストールします。
1. 環境変数`KERL_CONFIGURE_OPTIONS`に`--with-ssl=(OpenSSLをインストールしたディレクトリ)`を指定します。
1. GitHubから`asdf`をインストールします
1. ErlangとElixirの`asdf`プラグインをインストールします
1. `asdf install erlang (インストールしたいバージョン)` とします。最新版の時には `asdf install erlang latest`とします
1. `asdf install elixir (インストールしたいバージョン)` とします。最新版の時には `asdf install elixir latest`とします
1. `asdf global erlang (インストールしたバージョン)` `asdf global elixir (インストールしたバージョン)`として，ErlangとElixirを選択する

後で詳しい手順を書きます。

## 1. SSH使用のライセンスを申請し，設定します

詳しくはマニュアルを参照ください。

## 2. `apt-get`で`ncurses-dev`をインストールします

```bash
sudo apt-get update
sudo apt-get install ncurses-dev
```

## 3. OpenJDKの`jar`のシンボリックリンクを`/usr/bin`に作ります．なお，インストールされているopenjdkのバージョンの確認をする必要があります．

```bash
sudo ln -s /usr/lib/jvm/zulu-openjdk-8.0.332/bin/jar /usr/bin/jar
```

## 4. OpenSSLをソースコードからビルドし，インストールします。

たとえば `/usr/local/src` にソースコードを配置し， `/usr/local/openssl`にインストールするとします。

インストールするErlang/OTPのバージョンによって異なります．Erlang/OTP 25.0系列以前ではOpenSSL 1.1系列が，Erlang/OTP 25.1系列以降では OpenSSL 3系列がそれぞれ推奨です．

### OpenSSL 3系列をインストールする場合(Erlang/OTP 25.1系列以降の推奨)

2023年9月時点での OpenSSL 3系列の最新版はOpenSSL 3.1.3です．ソースコードは`https://www.openssl.org/source/openssl-3.1.3.tar.gz`にあります．

```bash
sudo mkdir /usr/local/src
sudo su
cd /usr/local/src
curl -OL https://www.openssl.org/source/openssl-3.1.3.tar.gz
tar xvzf openssl-3.1.3.tar.gz
cd openssl-3.1.3
./config -fPIC shared --prefix=/usr/local/openssl
make
make install_sw
exit
```

### OpenSSL 1.1系列をインストールする場合(Erlang/OTP 25.0系列以前の推奨)

2023年9月時点での OpenSSL 1.1.1 の最新版のソースコードは，`https://www.openssl.org/source/openssl-1.1.1w.tar.gz` にありました。
これらを適宜変更する必要があります。

```bash
sudo mkdir /usr/local/src
sudo su
cd /usr/local/src
curl -OL https://www.openssl.org/source/openssl-1.1.1w.tar.gz
tar xvzf openssl-1.1.1w.tar.gz
cd openssl-1.1.1w
./config -fPIC shared --prefix=/usr/local/openssl
make
make install_sw
exit
```

## 5. 環境変数`KERL_CONFIGURE_OPTIONS`に`--with-ssl=(OpenSSLをインストールしたディレクトリ)`を指定します。

前述のように設定した場合，次のように設定します

```bash
export KERL_CONFIGURE_OPTIONS="--with-ssl=/usr/local/openssl"
```

## 6. GitHubから`asdf`をインストールします

2023年9月時点での`asdf`の最新版はv0.13.1です。適宜指定します。

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
```

`~/.bashrc` に下記を追記します。

```bash
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
```

その後，`source ~/.bashrc`を実行しておきます。

## 7. ErlangとElixirの`asdf`プラグインをインストールします

```bash
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git
```

## 8. `asdf install erlang (インストールしたいバージョン)` とします。最新版の時には `asdf install erlang latest`とします

最新版をインストールする時には次のようにします。

```bash
asdf install erlang latest
```

インストール可能なバージョンを知るには次のようにします。

```bash
asdf list-all erlang
```

例えば26.1.2をインストールするには次のようにします。

```bash
asdf install erlang 26.1.2
```

## 9. `asdf install elixir (インストールしたいバージョン)` とします。最新版の時には `asdf install elixir latest`とします

最新版をインストールする時には次のようにします。

```bash
asdf install elixir latest
```

インストール可能なバージョンを知るには次のようにします。

```bash
asdf list-all elixir
```

例えば1.15.7-otp-26をインストールするには次のようにします。

```bash
asdf install elixir 1.15.7-otp-26
```

### 10. `asdf global erlang (インストールしたバージョン)` `asdf global elixir (インストールしたバージョン)`として，ErlangとElixirを選択する

略

# 苦労したところ

groovEPICにインストールされているOpenSSLでは，`libcrypto.so`がなぜか入っていません。`libcrypt.so`ならあるのですけど。これを指定するようにしてErlangをビルドすると，一見動くかのように見えるのですが，Elixirで`mix deps.get`すると，OpenSSLを正常にリンクできないエラーで異常終了します。

ソースコードからOpenSSLをビルドすることで，この問題を解決することができました。その代わりOpenSSLのビルドには，Erlangのビルド以上に時間がかかります。

# 謝辞

本研究成果は[北九州産業学術推進機構(FAIS)の旭興産グループ研究支援プログラムの助成](https://zacky1972.github.io/blog/2022/03/03/nx-accel.html)をいただき，実施しました。ありがとうございます。
