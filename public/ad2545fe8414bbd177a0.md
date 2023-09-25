---
title: (Intel) Big Sur でErlangをビルドする方法(kerl/asdf編)
tags:
  - Erlang
  - Elixir
  - asdf
  - kerl
  - BigSur
private: false
updated_at: '2021-01-06T06:17:46+09:00'
id: ad2545fe8414bbd177a0
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
**追記: Erlang/OTP 23.2.1 では特に設定することなく Intel Big Sur でビルドできました。この記事も過去のものになったようです。ただし M1 Big Sur では別の原因でエラーになりますのでご注意ください**

Apple Silicon M1チップ搭載の Mac が話題です。私も予算を調整してMac miniを発注しました。2020年12月3日に届くそうです。楽しみ！

今日はIntel MacのiMac ProをBig Sur 11.0.1にアップグレードしました。Catalina 10.15.7のSSDの内容を引き継いでのアップデートだったので，**元からインストールされていたElixirやErlangは問題なく動作しました。**これについては想定内だったのですが，言及している記事があまりなかったので，明記しておきます。

さて問題はBig SurでErlangをビルドすることができるか？です。結論から言うと，スルッとは入らず，少し手間がかかります。

# 前提条件

前提ライブラリを全て HomeBrew などでインストールした後だと仮定します。

# asdfの場合の手順

出典: https://github.com/asdf-vm/asdf-erlang/issues/161

私の環境では未検証ですが，おそらく動くと思います。どなたか確かめてください。

1. たとえば 23.1.4 をビルドするとします。
2. `asdf install erlang 23.1.4` を実行します。ここで一旦エラーが出て終了します。
3. `cd ~/.asdf/plugins/erlang/kerl-home/archives`とします。
4. `tar zxvf OTP-23.1.4.tar.gz` を実行します。
5. エディタで `~/.asdf/plugins/erlang/kerl-home/archives/otp-OTP-23.1.4/make/configure.in` を編集します。
6. `tar cfz OTP-23.1.4.tar.gz otp-OTP-23.1.4` を実行します。
7. `rm -rf otp-OTP-23.1.4` とします。
8. もう一度 `asdf install erlang 23.1.4` を実行します。するとビルドできます！

2で出るエラーは次のようなものです。

```
configure: error: 

  You are natively building Erlang/OTP for a later version of MacOSX
  than current version (11.0.1). You either need to
  cross-build Erlang/OTP, or set the environment variable
  MACOSX_DEPLOYMENT_TARGET to 11.0.1 (or a lower version).
```

5では415行目の次の記述を

```config
#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ > $int_macosx_version
```

次のように編集します。

```config
#if __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ > $int_macosx_version && false
```

# kerlの場合の手順

2020/12/11追記: kerlのHEADで，OTP23.1.5だとうまくいくようです。

1. `kerl`をHomebrewですでにインストールしていたら，`brew unlink kerl`とします。
2. `brew install kerl --HEAD`とします。
3. たとえば 23.1.5 をビルドするとします。
4. HomeBrewでOpenSSL 1.1をインストールしている場合は，`export KERL_CONFIGURE_OPTIONS="--with-ssl=/usr/local/opt/openssl@1.1"`のようにSSLのライブラリを指定します。 
5. `kerl update releases`として，最新版を取り寄せます。
6. `kerl build 23.1.5 23.1.5` とします。
7. `kerl install 23.1.5 ~/kerl/23.1.5` とします。

# 将来展望

たぶん，近いうちに不具合修正して，通常のインストールフローでビルドできるようになると思います。それまでの暫定的な記事としてください。
