---
title: macOS / Homebrew での exenv / erlenv を用いた Elixir / Erlang のソースコードインストール
tags:
  - Elixir
private: false
updated_at: '2018-10-03T22:36:28+09:00'
id: 27676894a03fb881e160
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
ZACKYこと山崎進です。

ついでなんで macOS での Elixir / Erlang のソースコードインストールの手順も押さえておきたいと思います。exenv / erlenv を使うことで，バージョンを切り替えられるようにしました。

[Linux (Ubuntu 16.04) での exenv / erlenv を用いた Elixir / Erlang のソースコードインストールはこちら](https://qiita.com/zacky1972/items/338baab1ccde12dcfab2)

# 前準備

Homebrew をインストールします。Homebrew の新規インストールには最新版の1つ前以上のmacOSが必要です。2018年10月3日現在だと macOS Mojave (バージョン 10.14) もしくは High Sierra (バージョン10.13)である必要があります。それ以前のバージョンの場合には OS のアップデートをしてください。

次に Xcode をインストールします。その後，コマンドラインツールをインストールします。これらのインストール方法は割愛します。

Homebrew のインストールの仕方はこちらを参照ください。

https://brew.sh/index_ja

すでに Homebrew をインストールしていた人は下記のコマンドを実行してください。

```bash
$ brew update
```

Homebrew をインストールした後，どのソフトウェアをインストールしたらいいかは，残念ながら完全には覚えていません。Erlang のインストールのためには少なくとも下記をインストールする必要があります。

```bash
$ brew install openssl
```

**このとき表示されるメッセージに注意してください。** 初めてインストールしていた場合は次の `brew upgrade` で注意する必要はありません。

次のように「すでにインストールされている」と表示される時には，次の手順で `brew upgrade` した時のメッセージに気をつけてください。

次のコマンドを実行します。

`brew upgrade`

このときに次のように表示された時に気をつけましょう。(`@`ありのものとなしのものが複数表示されることがあります。)

```bash
==> Upgrading openssl@...
==> Downloading ...
==> Pouring openssl@...
==> Caveats
A CA file has been bootstrapped ,,,,

...

If you need to have openssl@... 
  echo 'export PATH="/usr/local/opt/openssl@.../bin:$PATH"' >> ~/.bash_profile

For compilers to find openssl@... you may need to set:
  export LDFLAGS="-L/usr/local/opt/openssl@.../lib"
  export CPPFILAGS="-I/usr/local/opt/openssl@.../include"

For pkg-config to find openssl@... you may need to set:
  export PKG_CONFIG_PATH="/usr/local/opt/openssl@.../lib/pkgconfig"

==> Summary
...
```

実際には `...` には何かメッセージが表示されており，とくに `@...` には `@1.1` のようにバージョン番号が入ります。

このときには，OpenSSL の古いバージョンと新しいバージョンが混在しています。以下の OpenSSL の設定のところで `@` で指定された新しいバージョンを指定した方が賢明です。

次のコマンドを実行して OpenSSL の設定をします。1行目のコマンドはあってもなくてもいいですが， .bashrc の設定を見直す時に役立つコメントになります

注意点としては '>>' を間違えて '>' としないようにしてください。.bash_profile という重要な設定ファイルが上書きされてしまいます。心配な人は後で紹介するバックアップの方法を使ってください。

```bash
$ echo '# for OpenSSL' >> ~/.bash_profile
$ echo 'export PATH="/usr/local/opt/openssl/bin:$PATH"' >> ~/.bash_profile
```

`@` で指定された新しいバージョンを設定する場合は次のようにします。

```bash
$ echo '# for OpenSSL' >> ~/.bash_profile
$ echo 'export PATH="/usr/local/opt/openssl@(バージョン番号)/bin:$PATH"' >> ~/.bash_profile
```

なお(バージョン番号)には 'brew upgrade' で表示されたバージョンを指定します。

.bash_profile のバックアップの取り方は下記の通りです。書き換え前に実行しましょう。

```bash
$ cp ~/.bash_profile ~/.bash_profile.bak
```

新しいターミナルを起動して確かめましょう。エラーなく表示されませんか？

次に新しいターミナルで次のコマンドを実行しましょう。

```bash
$ which openssl
```

次のように表示されればOKです。

```bash
/usr/local/opt/openssl/bin/openssl
```

`@`付きで指定した場合は次のように表示されればOKです。

```bash
/usr/local/opt/openssl@(バージョン番号)/bin/openssl
```

もしターミナルを起動した時にエラーが表示されるか，`which openssl` で意図した通りの結果が得られなかった時には，`.bash_profile` を戻してやり直してください。

戻し方ですが，バックアップを取っていた場合には次のようにします。

```bash
$ cp ~/.bash_profile.bak ~/.bash_profile
```

以後，新しいターミナルで実行しましょう。

もし古いターミナルで以後のコマンドを実行したい場合には次のように実行します。

```bash
$ source ~/.bash_profile
```

以下では .bash_profile の変更の仕方については詳述しません。

# erlenv の取得と設定

次に，下記コマンドを入力して，`erlenv` を取得します。

```bash
$ git clone https://github.com/talentdeficit/erlenv.git $HOME/.erlenv
```

次に下記のように .bash_profile に追記します。

```bash
$ echo '# for erlenv' >> ~/.bash_profile
$ echo 'export PATH="$HOME/.erlenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(erlenv init -)"' >> ~/.bash_profile
```

次に設定を反映させましょう。

```bash
$ source ~/.bash_profile
```

確認のため次のコマンドを実行してください。

```bash
$ which erlenv
```

次のように表示されればOKです。

```bash
/Users/(あなたのアカウント名)/.erlenv/bin/erlenv
```

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
$ ./configure --prefix=$HOME/.erlenv/releases/21.1 --enable-smp-support --enable-threads --enable-darwin-64bit --enable-kernel-poll --enable-hipe --without-javac --enable-dirty-schedulers --enable-sharing-preserving --enable-lock-counter --disable-sctp --with-ssl=/usr/local/opt/openssl --without-obdc 
```

`--with-ssl=/usr/local/opt/openssl` のところは，もし `@(バージョン番号)` つきだった場合には，`--with-ssl="/usr/local/opt/openssl@(バージョン番号)"` というように変えてください。二重引用符に注意。

性能上，特に重要なオプションは `--enable-smp-support`， `--enable-threads` `--enable-hipe` `--enable-dirty-schedulers` です。これらを忘れると Elixir や Erlang がせっかくの高いパフォーマンスを十分に発揮できなくなるので，注意してください。(いくつかのオプションは，古いバージョンだと存在しないかもしれません)

また `--enable-darwin-64bit` は macOS 固有の設定です。

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

エラーがなく無事終わったら，次のコマンドでインストールしましょう。

```bash
$ make install
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

```bash
Erlang/OTP 21 [erts-10.1] [source] [64-bit] [smp:36:36] [ds:36:36:10] [async-threads:1] [hipe] [sharing-preserving]
Eshell V10.1 (abort with ^G)
1> 
```

* `21` はOTPのバージョンの整数部分です。
* もし64ビットマシン/OSだった時には`[64-bit]`になるはずですが，もし`[32-bit]`になるようならば設定を見直す必要があります。
* `[smp:36:36]` のような表示は，マルチコアでの実行を有効にします。数字は論理コア数です。ハイパースレッディングが有効ならばコア数の倍，無効ならばコア数と同じになります。この表示が出ていない場合は，`configure` コマンドの実行で `--enable-smp-support` を忘れています。
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
$ echo '# for exenv' >> ~/.bash_profile
$ echo 'export PATH="$HOME/.exenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(exenv init -)"' >> ~/.bash_profile
$ source ~/.bash_profile
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
Erlang/OTP 21 [erts-10.1] [source] [64-bit] [smp:36:36] [ds:36:36:10] [async-threads:1] [hipe] [sharing-preserving]

Elixir 1.7.3 (compiled with Erlang/OTP 21)
$
```


