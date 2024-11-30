---
title: Community-maintained pre-compiled Erlang/OTP for macOS を使ってErlangをインストールする
tags:
  - Erlang
  - macOS
private: false
updated_at: '2024-11-30T10:26:05+09:00'
id: ddb5f99464dd10339e52
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
Community-maintained pre-compiled Erlang/OTP for macOS というのが出ました．これは，macOSにErlang/OTPをインストールする，コンパイル時間がかからず，かつ指定したバージョンをインストールできる，新しい方法です．

https://elixirforum.com/t/new-community-maintained-otp-builds-for-macos/67338

https://github.com/erlef/otp_builds?tab=readme-ov-file

インストールスクリプトもあるみたいですが，READMEで紹介されていないのと，整合性チェックをしていないみたいだったので，自分でスクリプトを作りました．

https://gist.github.com/zacky1972/f5ff14bb3b4630f2f2e4e59329dd85a0

Rawを押して適切なディレクトリ(たとえば`$HOME/bin`)に保存し，`chmod +x $HOME/bin/erl_install.sh`としてから`.zshrc`等を編集して`PATH`に`$HOME/bin`を追加します．

最新版のErlang/OTPをインストールするには次のようにします．

```zsh
erl_install.sh latest
```

指定したバージョン(たとえば27.1.2)のErlang/OTPをインストールするには次のようにします．

```zsh
erl_install.sh 27.1.2
```

インストールしたErlang/OTPを使うには`PATH`に`$HOME/.erl/(バージョン番号)/bin`を追加します．

