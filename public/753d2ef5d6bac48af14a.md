---
title: Apple M1チップ搭載MacでNervesを動かす方法(2020.12.8暫定版)
tags:
  - Mac
  - Elixir
  - Nerves
  - M1
private: false
updated_at: '2020-12-11T16:16:45+09:00'
id: 753d2ef5d6bac48af14a
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[Nerves JP Advent Calendar 2020](https://qiita.com/advent-calendar/2020/nervesjp)の10日目の記事です。



# 結論

2020年12月8日現在，NervesはRosetta 2モードでは動作しますが，ARMネイティブモードでは動作しません。

また，ARMネイティブモードで`asdf install elixir (バージョン番号)`としてインストールした後，ターミナルをRosetta 2モードにして起動しなおしたときにElixirは正常に動作するのですが，Nervesを使おうとするとARMネイティブモードとみなされて動作しません。

# Elixirのインストール方法について

現時点でApple Silicon M1チップ搭載Macで推奨されるElixirのインストール方法は，`brew install elixir`でインストールする方法です。

`asdf install elixir (バージョン番号)`によるインストール方法では，ARMネイティブモードとx86_64/Rosetta 2モードのバイナリを共存できない問題があります。Nervesは現時点で後者のモードでしか動作しないので，前者でElixirをインストールしてしまうと Nerves が動作しないという不具合に見舞われます。

Elixirのインストール方法については，こちらを参照ください。Rosetta 2モードのHomebrewでのインストール方法に従ってください。

https://qiita.com/zacky1972/items/f8f7734e9ab46aa74739

# Nervesのインストール

公式ライブラリに沿ってインストールします。

https://hexdocs.pm/nerves/installation.html

ただし，HomebrewでインストールしたElixirはアンインストールせずそのままにして，`asdf`は使わずにしておきます。

手順を上げておきます。

1. アプリケーション/ユーティリティ フォルダを開いてターミナルの「情報を見る」を開きます。
2. 「Rosettaを使用して開く」にチェックを入れます。
3. ターミナルを起動します。
4. Homebrew をインストールします。
5. `brew install elixir`としてElixirをインストールします。
6. `brew update`
7. `brew install fwup squashfs coreutils xz pkg-config`として前提ライブラリをインストールします。
8. `mix local.hex` とします。
9. `mix local.rebar` とします。
10. `mix archive.install hex nerves_bootstrap` としてNervesがインストールできました。

# Hello Nervesをやってみる

https://hexdocs.pm/nerves/getting-started.html

に沿ってファームウェアを作ってみましょう。

1. 試しに`mix nerves.new hello_nerves`としてNervesプロジェクトを作りましょう。
2. 次に，`cd hello_nerves`とします。
3. もし Raspberry Pi 3用にファームウェアを作るのであれば，`export MIX_TARGET=rpi3`とします。
4. `mix deps.get`とします。(もし，ARMネイティブモードになっている場合には，ここでコケます)
5. `iex -S mix`を実行してホストで実行してみます。
    1. `HelloNerves.hello`を実行すると `:world`と出ることを確かめます。
    2. Ctrl-Cとaを押して終了します。 
6. 次のいずれかでターゲット(例えばRaspberry Pi 3)と接続します。
    1. ホストとターゲットをUSBで接続する (今回，未検証です)
    2. ホストとターゲットを有線LANで直に接続する
7. 2の場合は，`config/target.exs`を編集します(後述)。
8. Micro SDをアダプタを介してMacに挿します。
9. `mix firmware.burn`とします。
    1. `/dev/rdisk4? [Yn]` で `y` と答えます
    2. パスワード入力のウィンドウが立ち上がりますので，ログインパスワードを入れてください
10. Micro SDを外して，ターゲットに挿入します。
11. ターゲットを起動します。
12. 接続方法で2を選んだ場合には，`ping nerves.local`として接続を確認します。  
13. 接続されていたら`ssh nerves.local`とします。
    1. `HelloNerves.hello`を実行すると `:world`と出ることを確かめます。
    2. `exit`として終了します。

これで動作が確認できました！

# ARMネイティブモードでNervesを動かすために

NervesをM1 Macで動作させようとして，Rosetta 2モードでは成功したことと，ARMネイティブモードでは動作しなかったことを，世界で初めて私が報告しました。 https://github.com/nerves-project/toolchains/issues/66

Nervesの作者の1人のJustin Schneck氏もM1 Mac入手に動いているのですが，到着するのに4-5週間かかるということなので，私が協力してARMネイティブモードで動かすべく作業を続けています。

方向性としては，M1 Macで`build_release.sh`というスクリプトを使用して，イメージを作成しGitHubに登録すれば良いのですが，なかなか正常に動作せずに苦戦しています。

# おわりに

明日の[Nerves JP Advent Calendar 2020](https://qiita.com/advent-calendar/2020/nervesjp)の11日目は @mnishiguchi さんの[「Elixir/Nervesでパルス幅変調 (PWM) Lチカ」](https://qiita.com/mnishiguchi/items/4bdf88acf0ab0e8e2c7e#_reference-0c91492f373c01c5d98c)です。

本研究成果は、科学技術振興機構研究成果展開事業研究成果最適展開支援プログラム A-STEP トライアウト JPMJTM20H1 の支援を受けた。
