---
title: NervesでAutoconfを用いてNIFをビルドする方法
tags:
  - C
  - Elixir
  - autoconf
  - Nerves
private: false
updated_at: '2020-12-17T09:12:47+09:00'
id: f14ce06cebb71b00db20
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[#NervesJP Advent Calendar 2020](https://qiita.com/advent-calendar/2020/nervesjp)の16日目の記事です。

昨日は @torifukukaiou さんの[「グラフうねうね (動かし方 編) (Elixir/Phoenix)」](https://qiita.com/torifukukaiou/items/3926fe3740e229594c8f)でした。

今日はNervesでAutoconfを用いてNIFをビルドする方法をご紹介したいと思います。本当は[「Elixir から Swift 5.3のコードを呼び出す方法(Autotoolsを使って / Apple Silicon M1チップにも対応)」](https://qiita.com/zacky1972/items/4692e589bab7c84ef957)と同時にリリースするはずだった記事です。問題がなかなか解決しなかったので，公開に踏み切れませんでした。


# まずは mix nerves.new

まずは `mix nerves.new` でプロジェクトを作ります。プロジェクト名は `nerves_autoconf_test` とします。

```
❯ mix nerves.new nerves_autoconf_test
* creating nerves_autoconf_test/config/config.exs
* creating nerves_autoconf_test/config/target.exs
* creating nerves_autoconf_test/lib/nerves_autoconf_test.ex
* creating nerves_autoconf_test/lib/nerves_autoconf_test/application.ex
* creating nerves_autoconf_test/test/test_helper.exs
* creating nerves_autoconf_test/test/nerves_autoconf_test_test.exs
* creating nerves_autoconf_test/rel/vm.args.eex
* creating nerves_autoconf_test/rootfs_overlay/etc/iex.exs
* creating nerves_autoconf_test/.gitignore
* creating nerves_autoconf_test/.formatter.exs
* creating nerves_autoconf_test/mix.exs
* creating nerves_autoconf_test/README.md

Fetch and install dependencies? [Yn] 
* running mix deps.get
Your Nerves project was created successfully.

You should now pick a target. See https://hexdocs.pm/nerves/targets.html#content
for supported targets. If your target is on the list, set `MIX_TARGET`
to its tag name:

For example, for the Raspberry Pi 3 you can either
  $ export MIX_TARGET=rpi3
Or prefix `mix` commands like the following:
  $ MIX_TARGET=rpi3 mix firmware

If you will be using a custom system, update the `mix.exs`
dependencies to point to desired system's package.

Now download the dependencies and build a firmware archive:
  $ cd nerves_autoconf_test
  $ mix deps.get
  $ mix firmware

If your target boots up using an SDCard (like the Raspberry Pi 3),
then insert an SDCard into a reader on your computer and run:
  $ mix firmware.burn

Plug the SDCard into the target and power it up. See target documentation
above for more information and other targets.

```

書かれている指示に従って，進めます。(ターゲットは Raspberry Pi 3 であるものとします。それ以外の場合は，`rpi3`を適宜変更してください)

```
❯ export MIX_TARGET=rpi3
❯ cd nerves_autoconf_test
nerves_autoconf_test> mix deps.get
Resolving Hex dependencies...
Dependency resolution completed:
Unchanged:
  dns 2.2.0
  elixir_make 0.6.1
  gen_state_machine 2.1.0
  mdns_lite 0.6.6
  muontrap 0.6.0
  nerves 1.7.0
  nerves_pack 0.4.1
  nerves_runtime 0.11.3
  nerves_ssh 0.2.1
  nerves_system_bbb 2.8.1
  nerves_system_br 1.13.4
  nerves_system_osd32mp1 0.4.1
  nerves_system_rpi 1.13.1
  nerves_system_rpi0 1.13.1
  nerves_system_rpi2 1.13.1
  nerves_system_rpi3 1.13.1
  nerves_system_rpi3a 1.13.1
  nerves_system_rpi4 1.13.1
  nerves_system_x86_64 1.13.2
  nerves_time 0.4.2
  nerves_toolchain_aarch64_unknown_linux_gnu 1.3.2
  nerves_toolchain_arm_unknown_linux_gnueabihf 1.3.2
  nerves_toolchain_armv6_rpi_linux_gnueabi 1.3.2
  nerves_toolchain_ctng 1.7.2
  nerves_toolchain_x86_64_unknown_linux_musl 1.3.2
  one_dhcpd 0.2.5
  ring_logger 0.8.1
  shoehorn 0.7.0
  socket 0.3.13
  ssh_subsystem_fwup 0.5.1
  system_registry 0.8.2
  toolshed 0.2.17
  uboot_env 0.3.0
  vintage_net 0.9.2
  vintage_net_direct 0.9.0
  vintage_net_ethernet 0.9.0
  vintage_net_wifi 0.9.1
All dependencies are up to date

Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

==> elixir_make
Compiling 1 file (.ex)
Generated elixir_make app
==> nerves
cc -c -O2 -Wall -Wextra -Wno-unused-parameter -std=c99 -D_GNU_SOURCE -o /Users/zacky/github/nerves_autoconf_test/_build/rpi3_dev/lib/nerves/obj/port.o src/port.c
cc /Users/zacky/github/nerves_autoconf_test/_build/rpi3_dev/lib/nerves/obj/port.o  -o /Users/zacky/github/nerves_autoconf_test/_build/rpi3_dev/lib/nerves/priv/port
Compiling 41 files (.ex)
Generated nerves app
==> nerves_autoconf_test
Resolving Nerves artifacts...
  Resolving nerves_system_rpi3
  => Trying https://github.com/nerves-project/nerves_system_rpi3/releases/download/v1.13.1/nerves_system_rpi3-portable-1.13.1-671A096.tar.gz
|==================================================| 100% (146 / 146) MB
  => Success
  Cached nerves_toolchain_arm_unknown_linux_gnueabihf
nerves_autoconf_test❯　
```

`mix test`を実行します。

```
nerves_autoconf_test❯ mix test
==> toolshed
Compiling 11 files (.ex)
Generated toolshed app
==> ring_logger
Compiling 5 files (.ex)
Generated ring_logger app
==> shoehorn
Compiling 7 files (.ex)
Generated shoehorn app
==> elixir_make
Compiling 1 file (.ex)
Generated elixir_make app
==> nerves
cc -c -O2 -Wall -Wextra -Wno-unused-parameter -std=c99 -D_GNU_SOURCE -o /Users/zacky/github/nerves_autoconf_test/_build/test/lib/nerves/obj/port.o src/port.c
cc /Users/zacky/github/nerves_autoconf_test/_build/test/lib/nerves/obj/port.o  -o /Users/zacky/github/nerves_autoconf_test/_build/test/lib/nerves/priv/port
Compiling 41 files (.ex)
Generated nerves app
==> nerves_autoconf_test
Compiling 2 files (.ex)
Generated nerves_autoconf_test app
..

Finished in 0.03 seconds
1 doctest, 1 test, 0 failures

Randomized with seed 763939
nerves_autoconf_test❯ 
```

`iex -S mix` を実行してホストで確かめます。

```elixir
nerves_autoconf_test❯ iex -S mix
Erlang/OTP 23 [erts-11.1.1] [source] [64-bit] [smp:36:36] [ds:36:36:10] [async-threads:1] [hipe]

==> toolshed
Compiling 11 files (.ex)
Generated toolshed app
==> ring_logger
Compiling 5 files (.ex)
Generated ring_logger app
==> shoehorn
Compiling 7 files (.ex)
Generated shoehorn app
==> nerves_autoconf_test
Compiling 2 files (.ex)
Generated nerves_autoconf_test app
Interactive Elixir (1.11.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> NervesAutoconfTest.hello
:world
```

ここでCtrl+Cを押して`a`を押して終了します。

```elixir
iex(2)> 
BREAK: (a)bort (A)bort with dump (c)ontinue (p)roc info (i)nfo
       (l)oaded (v)ersion (k)ill (D)b-tables (d)istribution
 a
```

ターゲットで実行する場合，ホストとターゲットをどのように接続するか考えます。次の2通りがよくあります。

1. ホストとターゲットをUSBで接続する
2. ホストとターゲットを有線LANで直に接続する

2の場合は，`config/target.exs`の次の部分について，

```elixir:config/target.exs
config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :dhcp}
     }},
    {"wlan0", %{type: VintageNetWiFi}}
  ]
```

次のように変更します。

```elixir:config/target.exs
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"eth0", %{type: VintageNetDirect}},
    {"wlan0", %{type: VintageNetWiFi}}
  ]
```

Raspberry Pi 3 に挿入するMicro SDカードをホストに挿して，`mix firmware`と`mix firmware.burn`を実行します。

```
nerves_autoconf_test❯ mix firmware
==> nerves
==> nerves_autoconf_test

Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

Compiling 2 files (.ex)
Generated nerves_autoconf_test app
|nerves_bootstrap| Building OTP Release...

(中略)

Building /Users/zacky/github/nerves_autoconf_test/_build/rpi3_dev/nerves/images/nerves_autoconf_test.fw...
```

```
nerves_autoconf_test❯ mix firmware.burn
==> nerves
==> nerves_autoconf_test

Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

Compiling 2 files (.ex)

(中略)
Building /Users/zacky/github/nerves_autoconf_test/_build/rpi3_dev/nerves/images/nerves_autoconf_test.fw...
Use 14.48 GiB memory card found at /dev/rdisk4? [Yn] y
100% [====================================] 36.97 MB in / 39.51 MB out       
Success!
Elapsed time: 11.786 s
```

`/dev/rdisk4? [Yn]` で `y` と答えると，Macの場合はパスワード入力のウィンドウが立ち上がりますので，ログインパスワードを入れてください。

Micro SDカードをRaspberry Pi 3に挿して起動します。Raspberry Pi 3をホストに接続した状態で，次のコマンドを実行します。

```
nerves_autoconf_test❯ ssh nerves.local
The authenticity of host 'nerves.local (172.31.214.77)' can't be established.
RSA key fingerprint is SHA256:s6rDEVL9YH3LaEDRxRX4qStknwY3560Vs5wkQ4wQMmA.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'nerves.local,172.31.214.77' (RSA) to the list of known hosts.
Interactive Elixir (1.11.2) - press Ctrl+C to exit (type h() ENTER for help)
Toolshed imported. Run h(Toolshed) for more info.
RingLogger is collecting log messages from Elixir and Linux. To see the
messages, either attach the current IEx session to the logger:

  RingLogger.attach

or print the next messages in the log:

  RingLogger.next

iex(1)> 
```

初回はRSA鍵のフィンガープリントの確認があるので，リターンキーを押して認証します。

ここで次のようにして動作確認しましょう。

```elixir
iex(1)> NervesAutoconfTest.hello
:world
```

終了するときには `exit` とします。

```elixir
ex(2)> exit
Connection to nerves.local closed.
nerves_autoconf_test ❯ 
```

ここまでで`git`に登録しましょう。

```bash
nerves_autoconf_test ❯　git init
nerves_autoconf_test ❯　git add -A
nerves_autoconf_test ❯　git commit -m "initial commit"
```

# Autoconf の初期設定

ここではAutoconfを使ってビルド時の環境を認識するようにします。ただしAutoconfで生成した環境認識スクリプト`configure`は並列ビルドできないという欠点があるため遅いという難点があります。せっかく並列実行に強いElixirなので，将来はElixirで並列実行できるようにしたいですが，将来課題とします。

まず空の `configure.ac` を作成します。

```configure.ac
dnl Process this file with autoconf to produce a configure script

AC_INIT()
```

* `dnl`で始まる行はコメント行です。
* `AC_INIT()`は`autoconf`に初期化を指示します。パラメータを与えるのが普通なのですが，いったん無しで実行します。

この状態で`autoconf`を実行します。もしHomebrewを使っているならあらかじめ次のコマンドを実行しておきます。

```
nerves_autoconf_test % brew install autoconf
```

では`autoconf`を実行しましょう

```
nerves_autoconf_test % autoconf
```

そうすると次のファイルが生成されます。

```
autom4te.cache configure
```

`.gitignore`に下記を追記して`git`が追加ファイルを無視するようにしましょう。

```.gitignore
# For Autoconf
/autom4te.cache/

# For configure
/configure
```

`configure`を実行してみます。

```
nerves_autoconf_test % ./configure
```

すると `config.log`が生成されるので，これも`.gitignore`に下記を追記して無視するように設定します。

```.gitignore
# For configure
/config.log
/configure
```

# `elixir_make`で`configure`を呼ぶ

`elixir_make`を使うと`mix compile`をしたときに`make`を用いたビルドをしてくれます。Elixirの作者のJosé Valim(ジョゼ・ヴァリム)に`elixir_make`を使って`configure`を呼び出す方法を教えてもらいました( https://github.com/elixir-lang/elixir_make/issues/42 )ので，紹介したいと思います。

まず，`mix.exs`を書き換えて`elixir_make`をインストールします。`mix.exs`の下記の部分がインストールするライブラリを指定する部分です。

```elixir:mix.exs
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.7.0", runtime: false},
      {:shoehorn, "~> 0.7.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.0", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi, "~> 1.13", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.13", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.13", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.13", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.13", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi4, "~> 1.13", runtime: false, targets: :rpi4},
      {:nerves_system_bbb, "~> 2.8", runtime: false, targets: :bbb},
      {:nerves_system_osd32mp1, "~> 0.4", runtime: false, targets: :osd32mp1},
      {:nerves_system_x86_64, "~> 1.13", runtime: false, targets: :x86_64}
    ]
  end
```

これを次のように書き換えます。

```elixir:mix.exs
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.7.0", runtime: false},
      {:shoehorn, "~> 0.7.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},
      {:elixir_make, "~> 0.6.2", runtime: false},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.0", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi, "~> 1.13", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.13", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.13", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.13", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.13", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi4, "~> 1.13", runtime: false, targets: :rpi4},
      {:nerves_system_bbb, "~> 2.8", runtime: false, targets: :bbb},
      {:nerves_system_osd32mp1, "~> 0.4", runtime: false, targets: :osd32mp1},
      {:nerves_system_x86_64, "~> 1.13", runtime: false, targets: :x86_64}
    ]
  end
```

それから次のコマンドを実行します。

```zsh
nerves_autoconf_test % mix deps.get
```

これで`elixir_make`がインストールされました。

次に`mix.exs`に次のような関数を追加します。`System.cmd("#{File.cwd!()}/configure", []) で `./configure` を実行することになります。

```elixir:mix.exs
  defp configure(_args) do
    System.cmd("#{File.cwd!()}/configure", [])
  end
```

そして`mix.exs`の下記の部分がプロジェクト情報なのですが，これを書き換えます。

```elixir:mix.exs
  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end
```

次のようにします。

```elixir:mix.exs
  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host],
      compilers: [:elixir_make] ++ Mix.compilers,
      aliases: [compile: [&configure/1]]
    ]
  end
```

このようにすると，`make`を呼び出す代わりに`./configure`を呼び出します。`mix compile`を実行してエラーがないことを確認しましょう。(なお，この時点では `make`を呼んでいません)

# Automakeでライブラリを生成

次にAutomakeの設定をします。

ElixirからCプログラムを呼び出す方法は2通りあります。PortとNIFです。Portは独立したUNIXプログラムを呼び出す方法で，パイプで相互接続します。一方NIFはネイティブコードを直接リンクして呼び出します。今回はNIFを用います。NIFで呼び出すためには動的ライブラリとして生成しますので，Automakeで動的ライブラリを生成するように設定する必要があります。

Cのソースコードを`native/libnif.c`に配置しましょう。次のコマンドを実行します。

```zsh
nerves_autoconf_test % mkdir -p native
```

`native/libnif.c`を作成します。

```c:native/libnif.c
#include <erl_nif.h>
```

`erl_nif.h`というのはNIF APIのヘッダファイルです。

`Makefile.am`を次のように作成します。

```Makefile.am
AUTOMAKE_OPTIONS = subdir-objects
ACLOCAL_AMFLAGS = -I m4

lib_LTLIBRARIES = priv/libnif.la
priv_libnif_la_SOURCES = native/libnif.c

priv_libnif_la_CFLAGS = $(CFLAGS) $(ERL_CFLAGS)

priv_libnif_la_LDFLAGS = $(LDFLAGS) $(ERL_LDFLAGS) -shared -module -avoid-version -export-dynamic
```

説明は次のとおりです。

* `AUTOMAKE_OPTIONS = subdir-objects`でサブディレクトリにソースコード等を配置することを指定します。
* `ACLOCAL_AMFLAGS = -I m4`は`aclocal`で設定した値を読み込みます。
* `lib_LTLIBRARIES = priv/libnif.la`はビルドしたいライブラリを指定します。拡張子が`.la`ですが，Automakeでは一律にこのように指定するので，心配しないでください。
* `priv_libnif_la_`というのは`priv/libnif.la`に対応するオプションであることを示す接頭辞です。
    * `priv/libnif_la_SOURCES`でソースコードを指定します。ここでは`native/libnif.c`をコンパイルします。
    * `priv_libnif_la_CFLAGS`でコンパイルするときの`CFLAGS`の値を決めます。ここでは，`CFLAGS`の値と`ERL_CFLAGS`の値を設定します。`ERL_CFLAGS`は後で`configure.ac`の中で設定しますが，Erlangが提供するヘッダファイルの情報などを定義します。
    * `priv_libnif_la_LDFLAGS`で同様にリンクするときの`LDFLAGS`の値を決めます。ここでは`LDFLAGS`と`ERL_LDFLAGS`の値を設定します。`ERL_LDFLAGS`は`ERL_CFLAGS`と同様です。動的な共有ライブラリを生成するために`-shared` `-module` `-export-dynamic`を指定します。`.so`というようにバージョン番号を記載しないようにするために`-avoid-version`を指定します。

そして`configure.ac`を次のように変更します。

```configure.ac
dnl Process this file with autoconf to produce a configure script

AC_INIT([priv/.libs/libnif.so], [1.0])
AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_ARG_VAR([ELIXIR], [Elixir])
AC_ARG_VAR([ERL_EI_INCLUDE_DIR], [ERL_EI_INCLUDE_DIR])
AC_ARG_VAR([ERL_EI_LIBDIR], [ERL_EI_LIBDIR])
AC_ARG_VAR([CROSSCOMPILE], [CROSSCOMPILE])
AC_ARG_VAR([ERL_CFLAGS], [ERL_CFLAGS])
AC_ARG_VAR([ERL_LDFLAGS], [ERL_LDFLAGS])

AC_PROG_CC
AM_PROG_AR

AC_PATH_PROG(ELIXIR, $ELIXIR, elixir)

AC_MSG_CHECKING([setting ERL_EI_INCLUDE_DIR])
if test "x$ERL_EI_INCLUDE_DIR" = "x"; then
    AC_SUBST([ERL_EI_INCLUDE_DIR], [$(LC_ALL=en_US.UTF-8 $ELIXIR --eval ':code.root_dir |> to_string() |> Kernel.<>("/usr/include") |> IO.puts')])
fi
AC_MSG_RESULT([$ERL_EI_INCLUDE_DIR])

AC_MSG_CHECKING([setting ERL_EI_LIBDIR])
if test "x$ERL_EI_LIBDIR" = "x"; then
    AC_SUBST([ERL_EI_LIBDIR], [$(LC_ALL=en_US.UTF-8 $ELIXIR --eval ':code.root_dir |> to_string() |> Kernel.<>("/usr/lib") |> IO.puts')])
fi
AC_MSG_RESULT([$ERL_EI_LIBDIR])

AC_MSG_CHECKING([setting ERL_CFLAGS])
if test "x$ERL_CFLAGS" = "x"; then
    AC_SUBST([ERL_CFLAGS], [$(LC_ALL=en_US.UTF-8 $ELIXIR --eval '"-I#{System.get_env("ERL_EI_INCLUDE_DIR", "#{to_string(:code.root_dir)}/usr/include")}" |> IO.puts')])
fi
AC_MSG_RESULT([$ERL_CFLAGS])

AC_MSG_CHECKING([setting ERL_LDFLAGS])
if test "x$ERL_LDFLAGS" = "x"; then
    AC_SUBST([ERL_LDFLAGS], [$(LC_ALL=en_US.UTF-8 $ELIXIR --eval '"-L#{System.get_env("ERL_EI_LIBDIR", "#{to_string(:code.root_dir)}/usr/lib")}" |> IO.puts')])
fi
AC_MSG_RESULT([$ERL_LDFLAGS])

LT_INIT()
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
```

説明は次のとおりです。

* `AC_INIT`に生成するライブラリの情報を与えます。
* `AC_CONFIG_MACRO_DIRS([m4])`で`aclocal`で得られた設定を読むようにします。
* `AC_INIT_AUTOMAKE`でAutomakeの使用を宣言します。オプションでエラーや警告を表示するようにしています。
* `AC_ARG_VAR` で，`configure`に与える環境変数を定義します。第1引数に変数名，第2引数に`configure --help`の時に表示する説明を記載します。本当は第2引数をていねいにドキュメンテーションすべきところですが，手を抜いています。
* `AC_PROG_CC`と`AC_PROG_AR`はそれぞれ，`CC`と`AR`で指定されたコンパイラとリンカが存在することを確認します。
* `AC_PATH_PROG(ELIXIR, $ELIXIR, elixir)` で環境変数`ELIXIR`が設定されている場合にはそのパス上のプログラムが，設定されていない時には`elixir`が，`PATH`上に存在するかを確認してその結果を表示します。
* その後の`AC_MSG_CHECKING`から`AC_MSG_RESULT`の一塊は，それぞれErlangに関連する環境変数が設定されているかを確認します。
    * `AC_MSG_CHECKING([setting ERL...])` で確認中のメッセージを表示します。
    * `if test "x$ERL..." = "x"; then ... fi` で環境変数`ERL...`が設定されているかを確認します。このような書き方は，シェルで移植性の高い記述をするためのAutoconfでは定番の書き方です。
    * `AC_SUBST`は第1引数の環境変数に第2引数の値を代入します。
    * ここでは`elixir --eval` ワンライナープログラム とすることで，それぞれ少しずつ異なるElixirのワンライナーのプログラムを実行して設定に必要なパスを取得しています。
    * `LC_ALL=en_US.UTF-8` を設定しているのはLinux環境でロケールに関する警告を抑制するためです。
    * `AC_MSG_RESULT`で設定された結果を表示します。
* Elixirのワンライナーのプログラムは次のようになっています。
    * `:code.root_dir |> to_string()`とすることで実行する Erlang の処理系の存在するパスを表示します。この値を仮に`$1`としましょう。
    * `ERL_EI_INCLUDE_DIR`: `$1/usr/include`を設定します。
    * `ERL_EI_LIBDIR`: `$1/usr/lib`を設定します。
    * `ERL_CFLAGS`: `ERL_EI_INCLUDE_DIR`が設定されているならば `-I$ERL_EI_INCLUDE_DIR`を，そうでなければ`-I$1/usr/include`を設定します。
    * `ERL_LDFLAGS`: `ERL_EI_LIBDIR`が設定されているならば `-L$ERL_EI_LIBDIR`を，そうでなければ`-L$1/usr/lib`を設定します。
* `LT_INIT` でLibtoolの初期化をします。
* `AC_CONFIG_FILES([Makefile])`で`Makefile`を出力するように設定します。
* `AC_OUTPUT`で，以上の結果を出力します。

これらのファイルを記述した後，もしHomebrewを使っているならあらかじめ次のコマンドを実行しておきます。

```zsh
nerves_autoconf_test % brew install automake libtool
```

そして次のコマンドを実行します。

```zsh
nerves_autoconf_test % autoreconf -i
```

`.gitignore`に次を追記しましょう。

```.gitignore:.gitignore
# For Autoconf
/autom4te.cache/
/Makefile.in
/aclocal.m4
/libtool
/ar-lib
/compile
/install-sh
/ltmain.sh
/m4/
/missing
/depcomp

# For configure
/config.log
/config.status
/config.guess
/config.sub
/configure

# For build files
/native/.deps
/native/.dirstamp
/native/.libs
/native/*.o
/native/*.lo
/priv
Makefile
```

`mix.exs`の`project`情報を次のように変えます。

```elixir:mix.exs
  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host],
      compilers: [:elixir_make] ++ Mix.compilers,
      aliases: [
        compile: [&autoreconf/1, &configure/1, "compile"],
        clean: [&autoreconf/1, &configure/1, "clean"]
      ],
      make_clean: ["clean"]
    ]
  end
```

また，`autoreconf`を呼び出すように`mix.exs`に次の関数を足します。

```elixir:mix.exs
  defp autoreconf(_args) do
    System.cmd("autoreconf", ["-i"])
  end
```

これで`mix compile`を実行します。エラーなくビルドが終わりましたか？ 出来たら次のようにして動的ライブラリが出来上がっていることを確認します(Intel Macの場合)。

```zsh
nerves_autoconf_test % file priv/.libs/libnif.so 
priv/.libs/libnif.so: Mach-O 64-bit bundle x86_64
```

やった！

# ターゲット向けのクロスコンパイル

気を良くして`mix firmware`をしてみましょう。何と次のようにエラーになります。

```zsh
% mix firmware
==> nerves
==> nerves_autoconf_test

Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

configure: error: in `/Users/zacky/github/nerves_autoconf_test':
configure: error: cannot run C compiled programs.
If you meant to cross compile, use `--host'.
See `config.log' for more details
make: Nothing to be done for `all'.
Compiling 2 files (.ex)
Generated nerves_autoconf_test app
|nerves_bootstrap| Building OTP Release...

* skipping runtime configuration (config/runtime.exs not found)
* creating _build/rpi3_dev/rel/nerves_autoconf_test/releases/0.1.0/vm.args
Updating base firmware image with Erlang release...
scrub-otp-release.sh: ERROR: Unexpected executable format for '/Users/zacky/github/nerves_autoconf_test/_build/_nerves-tmp/rootfs_overlay/srv/erlang/lib/nerves_autoconf_test-0.1.0/priv/.libs/libnif.so'

Got:
 file:Mach-O 64-bit bundle x86_64

Expecting:
 readelf:ARM;0x5000400, Version5 EABI, hard-float ABI

This file was compiled for the host or a different target and probably
will not work.

Check the following:

1. Are you using a path dependency in your mix deps? If so, run
   'mix clean' in that directory to avoid pulling in any of its
   build products.

2. Did you recently upgrade to Elixir 1.9 or Nerves 1.5?
   Nerves 1.5 adds support for Elixir 1.9 Releases and requires
   you to either add an Elixir 1.9 Release configuration or add
   Distillery as a dependency. Without this, the OTP binaries
   for your build machine will get included incorrectly and cause
   this error. See
   https://hexdocs.pm/nerves/updating-projects.html#updating-from-v1-4-to-v1-5

3. Did you recently upgrade or change your Nerves system? If so,
   try cleaning and rebuilding this project and its deps.

4. Are you building outside of Nerves' mix integration? If so,
   make sure that you've sourced 'nerves-env.sh'.

If you're still having trouble, please file an issue on Github
at https://github.com/nerves-project/nerves_system_br/issues.

** (Mix) Nerves encountered an error. %IO.Stream{device: :standard_io, line_or_bytes: :line, raw: true}
```

ログを丹念に読むとわかるのですが，原因は`libnif.so`がターゲット向けにコンパイルされていないためです。

メッセージに書いてあるように，`mix clean`をしてから`mix firmware`をしてみましょう。

```zsh
nerves_autoconf_test % mix clean                             
==> nerves
==> nerves_autoconf_test

Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

test -z "priv/libnif.la" || rm -f priv/libnif.la
rm -f priv/so_locations
rm -rf .libs _libs
rm -rf native/.libs native/_libs
rm -rf priv/.libs priv/_libs
rm -f *.o
rm -f native/*.o
rm -f native/*.lo
rm -f *.lo
```

```zsh
nerves_autoconf_test % mix firmware
==> nerves
==> nerves_autoconf_test

Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

configure: error: in `/Users/zacky/github/nerves_autoconf_test':
configure: error: cannot run C compiled programs.
If you meant to cross compile, use `--host'.
See `config.log' for more details
/bin/sh ./libtool  --tag=CC   --mode=compile gcc -DPACKAGE_NAME=\"priv/.libs/libnif.so\" -DPACKAGE_TARNAME=\"priv--libs-libnif-so\" -DPACKAGE_VERSION=\"1.0\" -DPACKAGE_STRING=\"priv/.libs/libnif.so\ 1.0\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DPACKAGE=\"priv--libs-libnif-so\" -DVERSION=\"1.0\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -DLT_OBJDIR=\".libs/\" -I.    -g -O2 -I/Users/zacky/.asdf/installs/erlang/23.1.2/usr/include -g -O2 -MT native/priv_libnif_la-libnif.lo -MD -MP -MF native/.deps/priv_libnif_la-libnif.Tpo -c -o native/priv_libnif_la-libnif.lo `test -f 'native/libnif.c' || echo './'`native/libnif.c
libtool: compile:  gcc -DPACKAGE_NAME=\"priv/.libs/libnif.so\" -DPACKAGE_TARNAME=\"priv--libs-libnif-so\" -DPACKAGE_VERSION=\"1.0\" "-DPACKAGE_STRING=\"priv/.libs/libnif.so 1.0\"" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DPACKAGE=\"priv--libs-libnif-so\" -DVERSION=\"1.0\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -DLT_OBJDIR=\".libs/\" -I. -g -O2 -I/Users/zacky/.asdf/installs/erlang/23.1.2/usr/include -g -O2 -MT native/priv_libnif_la-libnif.lo -MD -MP -MF native/.deps/priv_libnif_la-libnif.Tpo -c native/libnif.c  -fno-common -DPIC -o native/.libs/priv_libnif_la-libnif.o
libtool: compile:  gcc -DPACKAGE_NAME=\"priv/.libs/libnif.so\" -DPACKAGE_TARNAME=\"priv--libs-libnif-so\" -DPACKAGE_VERSION=\"1.0\" "-DPACKAGE_STRING=\"priv/.libs/libnif.so 1.0\"" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DPACKAGE=\"priv--libs-libnif-so\" -DVERSION=\"1.0\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -DLT_OBJDIR=\".libs/\" -I. -g -O2 -I/Users/zacky/.asdf/installs/erlang/23.1.2/usr/include -g -O2 -MT native/priv_libnif_la-libnif.lo -MD -MP -MF native/.deps/priv_libnif_la-libnif.Tpo -c native/libnif.c -o native/priv_libnif_la-libnif.o >/dev/null 2>&1
mv -f native/.deps/priv_libnif_la-libnif.Tpo native/.deps/priv_libnif_la-libnif.Plo
/bin/sh ./libtool  --tag=CC   --mode=link gcc -g -O2 -I/Users/zacky/.asdf/installs/erlang/23.1.2/usr/include -g -O2  -L/Users/zacky/.asdf/installs/erlang/23.1.2/usr/lib -shared -module -avoid-version -export-dynamic  -o priv/libnif.la -rpath /usr/local/lib native/priv_libnif_la-libnif.lo  
libtool: link: gcc -Wl,-undefined -Wl,dynamic_lookup -o priv/.libs/libnif.so -bundle  native/.libs/priv_libnif_la-libnif.o   -L/Users/zacky/.asdf/installs/erlang/23.1.2/usr/lib  -g -O2 -g -O2  
libtool: link: ( cd "priv/.libs" && rm -f "libnif.la" && ln -s "../libnif.la" "libnif.la" )
Compiling 2 files (.ex)
Generated nerves_autoconf_test app
|nerves_bootstrap| Building OTP Release...

* skipping runtime configuration (config/runtime.exs not found)
* creating _build/rpi3_dev/rel/nerves_autoconf_test/releases/0.1.0/vm.args
Updating base firmware image with Erlang release...
Copying rootfs_overlay: /Users/zacky/github/nerves_autoconf_test/_build/rpi3_dev/nerves/rootfs_overlay
Copying rootfs_overlay: /Users/zacky/github/nerves_autoconf_test/rootfs_overlay
Pseudo modify file "lib/firmware/brcm/brcmfmac43430a0-sdio.ONDA-V80" does not exist in source filesystem.  Ignoring.
Parallel mksquashfs: Using 6 processors
Creating 4.0 filesystem on /Users/zacky/github/nerves_autoconf_test/_build/_nerves-tmp/combined.squashfs, block size 131072.

Exportable Squashfs 4.0 filesystem, gzip compressed, data block size 131072
	compressed data, compressed metadata, compressed fragments,
	compressed xattrs, compressed ids
	duplicates are removed
Filesystem size 38367.19 Kbytes (37.47 Mbytes)
	57.40% of uncompressed filesystem size (66839.99 Kbytes)
Inode table size 20561 bytes (20.08 Kbytes)
	28.27% of uncompressed inode table size (72730 bytes)
Directory table size 23894 bytes (23.33 Kbytes)
	41.77% of uncompressed directory table size (57206 bytes)
Number of duplicate files found 14
Number of inodes 2193
Number of files 1796
Number of fragments 227
Number of symbolic links  167
Number of device nodes 0
Number of fifo nodes 0
Number of socket nodes 0
Number of directories 230
Number of ids (unique uids + gids) 4
Number of uids 3
	root (0)
	zacky (501)
	_appstore (33)
Number of gids 3
	wheel (0)
	staff (20)
	_appstore (33)
Building /Users/zacky/github/nerves_autoconf_test/_build/rpi3_dev/nerves/images/nerves_autoconf_test.fw..
```

今度は成功したようです。

# ホストとターゲットのビルドの両立

でもホストとターゲットを切り替えるたびに，いちいち`mix clean`してビルドし直すのは面倒ですよね。

そこで，次のような方策を取ります。

1. ビルドしたファイルを `priv`ディレクトリに配置するのではなく，`_build`以下のアプリケーションごとの領域に配置することにします。アプリケーションからは`Application.app_dir(:nerves_autoconf_test, "priv")`でアクセスできる領域，`mix`からだと`"#{Mix.Project.app_path()}/priv"でアクセスできる領域にビルドしたファイルを配置すると，`priv`ディレクトリと同様にNervesがファームウェアに記録してくれます。
2. そのために，`configure`を実行する時に`--prefix`オプションをつけてインストール先を指定し，`make clean`, `make`後に`make install`で目的のディレクトリにインストールするようにします。
3. ビルドするディレクトリを`priv`から`build`に変更します。

ではやってみましょう。

まず`Makefile.am`を次のようにします。

```Makefile.am
AUTOMAKE_OPTIONS = subdir-objects
ACLOCAL_AMFLAGS = -I m4

lib_LTLIBRARIES = build/libnif.la
build_libnif_la_SOURCES = native/libnif.c

build_libnif_la_CFLAGS = $(CFLAGS) $(ERL_CFLAGS)

build_libnif_la_LDFLAGS = $(LDFLAGS) $(ERL_LDFLAGS) -shared -module -avoid-version -export-dynamic
```

次に`mix.exs`の`project`のところを次のようにします。

```elixir:mix.exs
  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host],
      compilers: [:elixir_make] ++ Mix.compilers(),
      aliases: [
        compile: [&autoreconf/1, &configure/1, "clean",  &install/1, "compile"],
        clean: [&autoreconf/1, &configure/1, "clean"]
      ],
      make_clean: ["clean"]
    ]
  end
```

注: コンパイルとインストールの順番が逆じゃないかと思った人は，Joseのこの解説をご覧ください。 https://github.com/elixir-lang/elixir_make/issues/45


さらに`autoreconf`以下を次のようにします。

```elixir:mix.exs
  defp autoreconf(_args) do
    System.cmd("autoreconf", ["-i"])
  end

  defp configure(_args) do
    System.cmd(
      "#{File.cwd!()}/configure",
      ["--prefix=#{Mix.Project.app_path()}/priv"]
    )
  end

  defp install(_args) do
    System.cmd("make", ["install"])
  end
```

これで `iex -S mix`と`mix firmware`をそれぞれしたときにエラーがなくなることを確認してください。

`.gitignore`に`build`を足しておきます。

```.gitignore
# For build files
/native/.deps
/native/.dirstamp
/native/.libs
/native/*.o
/native/*.lo
/priv
Makefile
/build/
```

# `--host`の指定

`mix firmware`したときのログを丹念に読むと次のようなエラーが出ていることに気づきます。

```
configure: error: in `/Users/zacky/github/nerves_autoconf_test':
configure: error: cannot run C compiled programs.
If you meant to cross compile, use `--host'.
See `config.log' for more details
configure: error: in `/Users/zacky/github/nerves_autoconf_test':
configure: error: cannot run C compiled programs.
If you meant to cross compile, use `--host'.
See `config.log' for more details
```

これは，`configure`を実行する時に`--host`オプションを指定することで解消できます。

`--host`オプションに何を指定すべきかわからなかったので，Nervesの作者の1人のFrank Hunlethに聞いてみました。

> I think this needs some thought and perhaps some experimentation. I don’t like the word “buildroot” in what Buildroot sets for --target and --host, but I bet it doesn’t matter. Try setting --target and --host to $REBAR_TARGET_ARCH. I’m not sure about --build. Maybe try not setting it and see if you get an error.

とのことでした。

そこで，もし環境変数`$REBAR_TARGET_ARCH`が指定されている場合には`--host`に指定するようにしてみましょう。`mix.exs`の`configure`を次のように変えます。

```elixir:mix.exs
  defp configure(_args) do
    host = System.get_env("REBAR_TARGET_ARCH")
    if is_nil(host) do
      System.cmd(
        "#{File.cwd!()}/configure",
        ["--prefix=#{Mix.Project.app_path()}/priv"]
      )
    else
      System.cmd(
        "#{File.cwd!()}/configure",
        ["--prefix=#{Mix.Project.app_path()}/priv", "--host=#{host}"]
      )
    end      
  end
```

これで`mix firmware`すると，今度はエラーが解消されました。

# NIF関数を定義する

長々とお膳立てしましたが，いよいよNIF関数を定義してみたいと思います。

```c:native/libnif.c
#include <stdlib.h>
#include <erl_nif.h>

static ERL_NIF_TERM test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
	return enif_make_atom(env, "ok");
}

static ErlNifFunc nif_funcs[] =
{
	{"test", 0, test}
};

ERL_NIF_INIT(Elixir.NervesAutoconfTest, nif_funcs, NULL, NULL, NULL, NULL)
```

シンプルにtestを呼び出すと`:ok`というアトムを返すという関数を定義しています。

```lib/nerves_autoconf_test.ex
defmodule NervesAutoconfTest do
  require Logger

  @moduledoc """
  Documentation for NervesAutoconfTest.
  """

  @on_load :load_nif

  def load_nif do
    nif_file = '#{Application.app_dir(:nerves_autoconf_test, "priv/lib/libnif")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.warn("Failed to load NIF: #{inspect(reason)}")
    end
  end

  def test(), do: raise("NIF test/0 not implemented")

  @doc """
  Hello world.

  ## Examples

      iex> NervesAutoconfTest.hello
      :world

  """
  def hello do
    :world
  end
end
```

NIFのロードとtest関数のスタブを足しています。

これで `iex -S mix`と`mix firmware`それぞれでエラーが出ないことを確認してください。また，`NervesAutoconfTest.test`を実行すると`:ok`が返ってくることを確認してください。

なお，`mix firmware`の時，次のような警告が出ます。

```
18:02:11.690 [warn]  Failed to load NIF: {:load_failed, 'Failed to load NIF library: \'dlopen(/Users/zacky/github/nerves_autoconf_test/_build/rpi3_dev/lib/nerves_autoconf_test/priv/lib/libnif.so, 2): no suitable image found.  Did find:\n\t/Users/zacky/github/nerves_autoconf_test/_build/rpi3_dev/lib/nerves_autoconf_test/priv/lib/libnif.so: unknown file type, first eight bytes: 0x7F 0x45 0x4C 0x46 0x01 0x01 0x01 0x00\n\t/Users/zacky/github/nerves_autoconf_test/_build/rpi3_dev/lib/nerves_autoconf_test/priv/lib/libnif.so: stat() failed with errno=35\''}
```

# おわりに

Autoconfを用いてNIFをビルドしているので，ヘッダファイルや関数が存在するかどうかを判定して，その結果に応じて適切に動作するように`#ifdef`等を用いて定義できるようなNIFプログラムを自在に書くことができるようになったと思います。

Nervesの場合だと，使用するIoTボードの種類によってNIFコードを書き分けたい場合が多々あると思います。この記事で紹介した方法を用いることで，移植性の高いNIFコードを書くことができるようになるんじゃないかと思います。

明日の[#NervesJP Advent Calendar 2020](https://qiita.com/advent-calendar/2020/nervesjp) 17日目の記事は，@nishiuchikazuma さんの[「NervesとPhonenix(Gigalixir)とGCP Cloud PubSubを使ってBBG CapeのLEDをチカした話〜Phoenix/GCPでPub編〜（1/2）」](https://qiita.com/nishiuchikazuma/items/6c537342f8815728f69d#_reference-2cc7c6d0f743b646600b)です。

本研究成果は、科学技術振興機構研究成果展開事業研究成果最適展開支援プログラム A-STEP トライアウト JPMJTM20H1 の支援を受けた。

