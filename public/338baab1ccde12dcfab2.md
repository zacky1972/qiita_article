---
title: Linux (Ubuntu 16.04) での exenv / erlenv を用いた Elixir / Erlang のソースコードインストール
tags:
  - Elixir
private: false
updated_at: '2018-10-03T22:37:24+09:00'
id: 338baab1ccde12dcfab2
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
ZACKYこと山崎進です。

Linux (Ubuntu 16.04) に Elixir をソースコードインストールしたので，やり方をまとめておこうと思います。exenv / erlenv を使うことで，バージョンを切り替えられるようにしました。

[macOS / Homebrew での exenv / erlenv を用いた Elixir / Erlang のソースコードインストールはこちら](https://qiita.com/zacky1972/items/27676894a03fb881e160)

# 事前準備

まず Ubuntu 16.04 (日本語)をインストールします。この手順は省略させてください。

次に左上の「コンピュータを検索」から「端末」もしくは terminal で検索し，端末を選択して，起動します。端末は頻繁に使うので，左下の端末アイコンを右クリックして，「Launcherへの登録」をしておきましょう。ドラッグすれば場所も移動できます。

前提となるソフトウェアをインストールするために，端末アイコンに下記のコマンドを入力します。(行頭の `$` はコマンドプロンプトなので，入力する必要はありません)

```bash
$ sudo apt-get install build-essential git wget libssl-dev libreadline-dev libncurses5-dev zlib1g-dev m4 curl g++ fop xsltproc libxml2-utils
```

するとパスワードの入力を求められるので，ログインした時のパスワードを入れます。途中で `続行しますか? [Y/n]` と聞かれるので，Y と答えます。

`sudo` コマンドは，管理者権限でコマンドを実行するというものです。不用意に用いないことが大事です。

`apt-get` はパッケージを管理するソフトウェアです。Ubuntu は `apt-get` でさまざまなツールをインストールしたり削除したりします。

# erlenv の取得と設定

次に，下記コマンドを入力して，`erlenv` を取得します。

```bash
$ git clone https://github.com/talentdeficit/erlenv.git $HOME/.erlenv
```

erlenv を有効にするには ~/.bashrc もしくは ~/.bash_profile に設定を記述する必要があります。どちらに記載するべきかわからない場合は，~/.bashrc に追記しましょう。下記のコマンド3つで追記できます。(1つ目は無くても大丈夫ですが，あとで .bashrc の設定を見直す時に役立つコメントになります)

注意: `>>` を間違えて `>` としてしまうと，初期設定ファイルを上書きして消してしまうので，注意してください！ 不安な人は，`cp` コマンドでバックアップを作っておくといいでしょう(後述)。

```bash
$ echo '# for erlenv' >> ~/.bashrc
$ echo 'export PATH="$HOME/.erlenv/bin:$PATH"' >> ~/.bashrc
$ echo 'eval "$(erlenv init -)"' >> ~/.bashrc
```

.bashrc のバックアップの作り方はこちら。

```bash
$ cp ~/.bashrc ~/.bashrc.bak
```

復元の仕方はこちら(エラーが起きたら実行してください)

```bash
$ cp ~/.bashrc.bak ~/.bashrc
```

新しい端末を起動して，エラーなく起動することを確認しましょう。新しい端末の起動のしかたは，左側の端末のアイコンを右クリックして「新しい端末」をクリックします。

次に新しい端末で次のコマンドを打ちましょう。

```bash
$ which erlenv
```

次のように表示されればOKです。`(あなたのアカウント名)`には実際にはあなたのアカウント名が入ります。

```
/home/(あなたのアカウント名)/.erlenv/bin/erlenv
```

うまくいかなかったら，古い端末でバックアップから復元してから再度試みてください。うまくいったら，古い端末は閉じて，以後新しい端末で作業しましょう。

なお，古い端末をそのまま使いたい場合には次のコマンドを入力すれば，新しい環境が反映されます。

```bash
$ source ~/.bashrc
```

以後，~/.bashrc については，ここまでていねいな説明なく進めていきたいと思います。

# Erlang のビルドとインストール

Erlang はソースコードからインストールします。まず[Erlang のダウンロードページ](http://www.erlang.org/downloads)を見て，ダウンロードすべきバージョンを見定めます。2018年10月3日現在の最新版はOTP21.1です。あえて古いバージョンをダウンロードしても構いません。

ダウンロードは次のように行います。今回はOTP21.1を対象として説明します。もし他のバージョンにしたい場合は，コマンド中の `21.1` を適宜変更してください。

```bash
$ curl -O http://erlang.org/download/otp_src_21.1.tar.gz
```

それなりに時間がかかります。

ダウンロードが終わったら次のコマンドで展開します。

```bash
$ tar xzf otp_src_21.1.tar.gz
```

展開が終わったらソースコードのディレクトリに移動します。

```bash
$ cd otp_src_21.1
```

次にErlangのビルドオプションを設定するのですが，実に多彩なオプションがあります。下記コマンドでオプションを概観することができます。(が，初心者の人は見なくていいです)

```bash
$ ./configure --help
```

21.1 の場合の私のおすすめ設定は下記の通りです。間違わないように入力してくださいね。

```bash
./configure --prefix=$HOME/.erlenv/releases/21.1 --enable-smp-support --enable-threads --enable-kernel-poll --enable-hipe --without-javac --enable-dirty-schedulers --enable-sharing-preserving --enable-lock-counter --disable-sctp --without-obdc 
```

性能上，特に重要なオプションは `--enable-smp-support`， `--enable-threads` `--enable-hipe` `--enable-dirty-schedulers` です。これらを忘れると Elixir や Erlang がせっかくの高いパフォーマンスを十分に発揮できなくなるので，注意してください。(いくつかのオプションは，古いバージョンだと存在しないかもしれません)

configure コマンドを実行するとまあまあ時間がかかります。

無事終了したら，次のように入力します。

```bash
$ touch lib/wx/SKIP lib/odbc/SKIP
```

これらは，wx と odbc を無効にするという意味です。`touch`コマンド自体は，現在の時刻でファイルを作成するというものです。

次にいよいよビルドです。次のコマンドを入力して，かなり待ちます。

```bash
$ make
```

エラーがなく無事終わったら，次のコマンドでインストールしましょう。再びパスワードが聞かれるかもしれませんね。

```bash
$ sudo make install
```

これで，Erlang がインストールできたのですが，あとは今インストールしたバージョンを有効にする必要があります。次の2つのコマンドを続けて入力します。

```bash
$ erlenv global 21.1
$ erlenv rehash
```

次のコマンドを入力してバージョン等を確認しましょう。

```bash
$ erl
```

次のように表示されます。

```
Erlang/OTP 21 [erts-10.1] [source] [64-bit] [smp:40:40] [ds:40:40:10] [async-threads:1] [hipe] [sharing-preserving]

Eshell V10.1 (abort with ^G)
1> 
```

* `21` はOTPのバージョンの整数部分です。
* もし64ビットマシン/OSだった時には`[64-bit]`になるはずですが，もし`[32-bit]`になるようならば設定を見直す必要があります。
* `[smp:40:40]` のような表示は，マルチコアでの実行を有効にします。数字は論理コア数です。ハイパースレッディングが有効ならばコア数の倍，無効ならばコア数と同じになります。VirtualBox などのVMでの実行では1になっているかもしれません。この表示が出ていない場合は，`configure` コマンドの実行で `--enable-smp-support` を忘れています。
* `[hipe]`という文字がありますか？ HiPE は High Performance Erlang の略で，ネイティブコードにコンパイルして実行します。これが表示されない場合は，`configure` コマンドの実行で `--enable-hipe` を忘れています。

コマンドプロンプトが Eshell に取られているので，終了します。終了するには，コントロールキー＋C (^C) を押して，a を押します。

最後に `cd` コマンドでホームディレクトリに戻っておきましょう。

```bash
$ cd
```

# exenv のインストール

erlenv と同じ要領で次のようなコマンドを順に入力して行きます。注意点は erlenv と同様ですので，コマンドのみ羅列します。

```bash
$ git clone https://github.com/mururu/exenv.git $HOME/.exenv
$ git clone https://github.com/mururu/elixir-build.git $HOME/.exenv/plugins/elixir-build
$ echo '# for exenv' >> ~/.bashrc 
$ echo 'export PATH="$HOME/.exenv/bin:$PATH"' >> ~/.bashrc
$ echo 'eval "$(exenv init -)"' >> ~/.bashrc
$ source ~/.bashrc
```

次のコマンドで動作を確かめます。

```bash
$ which exenv
```

次のように表示されればOKです。

```bash
/home/(あなたのアカウント)/.exenv/bin/exenv
```

# Elixir のインストール

Elixir のインストールは Erlang に比べたらはるかに楽です。

まず，インストール可能なバージョンを下記のコマンドで確認します。

```bash
$ exenv install -list
```

2018年10月3日現在の最新版は 1.7.3 です。以下，1.7.3 の場合について説明します。他のバージョンを入れる場合にはバージョン番号を適宜修正してください。

インストールは次のように行います。

```bash
$ exenv install 1.7.3
$ exenv global 1.7.3
```

成功したら次のように確認します。

```bash
$ elixir -v
```

次のような表示が出ればOKです。

```bash
$ elixir -v
Erlang/OTP 21 [erts-10.1] [source] [64-bit] [smp:40:40] [ds:40:40:10] [async-threads:1] [hipe] [sharing-preserving]

Elixir 1.7.3 (compiled with Erlang/OTP 21)
$
```

