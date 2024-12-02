---
title: Community-maintained pre-compiled Erlang/OTP for macOS を使ってErlangをインストールする
tags:
  - Erlang
  - macOS
  - Elixir
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

## クリーンインストールからのElixir/Erlangインストール手順

1. macOSをアップデートします．
2. (オプション)Xcodeをインストールして起動し，指示通りにインストールしていきます．起動してインストールが終わったら終了して良いです．
3. Homebrewをインストールします(後述)．
4. `brew doctor` を実行してエラー等が出ないことを確認します．
5. `brew update` を実行します．
6. `mkdir ~/bin` を実行します．
7. Webブラウザでこちらの[リンク](https://gist.github.com/zacky1972/f5ff14bb3b4630f2f2e4e59329dd85a0)を開き，Rawボタンを押します．
8. エディタを起動し，`~/bin/erl_install.sh` を作成して，7の内容をコピペして保存します．
9. `chmod +x ~/bin/erl_install.sh`を実行します．
10. エディタを起動し，`$HOME/bin`にPATHを通します．
11. `erl_install.sh latest` もしくは `erl_install.sh (任意のバージョン番号)`を実行して，Erlangを実行します．
12. `brew install asdf` を実行します．
13. 最後に表示された指示の通りに，設定をします．
14. ターミナルを再起動します．
15. `$HOME/.erl/バージョン番号/bin`にPATHを通します．
16. `asdf plugin add elixir` を実行します．
17. `asdf install elixir latest` もしくは `asdf install elixir (任意のバージョン番号)`を実行します．
18. `asdf global elixir (17で指定したlatest もしくはバージョン番号)`を実行します．
19. `elixir -v`でバージョン番号が出ることを確認します．

### Homebrew インストール

https://brew.sh/ja/

1. ターミナルを起動して，リンク先のインストールスクリプトをコピペして実行し，指示に従います．
2. 途中でログインパスワードを入れます．
3. 最後に表示されるコマンド列をコピペして実行します．

