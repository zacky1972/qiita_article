---
title: Elixir から Swift 5.3のコードを呼び出す方法(Autotoolsを使って / Apple Silicon M1チップにも対応)
tags:
  - Objective-C
  - Mac
  - Elixir
  - Swift
  - autotools
private: false
updated_at: '2020-12-11T16:15:23+09:00'
id: 4692e589bab7c84ef957
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[Elixir Advent Calendar 2020](https://qiita.com/advent-calendar/2020/elixir)の10日目です。

昨日は @kobae964 さんの[「Rustler で行儀の良い NIF を書く」](https://qiita.com/kobae964/items/9b8e78b8b0f3ca0f7e19)でした。

さて，Apple Silicon M1チップの性能が明らかになるにつれて，今後，ElixirエコシステムからMacの潜在能力をフル活用することが求められてくるように思います(というか，是非活用したい)。そこで，この記事はElixirからSwift 5.3のコードを呼び出す方法について紹介しています。

Autotoolsを使ってObjective-CやSwiftのヘッダファイルや関数の存在判定などもできるようにする方法も示していますので，Elixir開発者だけでなく，iOSネイティブアプリやMacアプリの開発者にも部分的には有用かと思います。しかも，Apple Silicon M1チップ搭載のMacでも動作検証をしています！

この記事のGitHubレポジトリは https://github.com/zacky1972/swift_elixir_test です。下記に同様のもののつくりかたを詳説しています。

注意点: この記事はApple Silicon M1チップ搭載のMacに概ね対応していますが，(1)ErlangをARMネイティブでビルドして(2)かつRosetta 2モードでターミナルを起動した場合には，NIFのロード時にアーキテクチャの不一致によるエラーが発生し，NIFを実行できないという問題があります。この問題は，従来のNIFプログラム全般で発生する可能性のある問題だと認識しています。現在，さらに調査を進めて問題の解決に当たっているところです。

# まずは `mix new`

まずは`mix new`でプロジェクトを作ります。プロジェクト名は`swift_elixir_test`としました。

```zsh
% mix new swift_elixir_test
* creating README.md
* creating .formatter.exs
* creating .gitignore
* creating mix.exs
* creating lib
* creating lib/swift_elixir_test.ex
* creating test
* creating test/test_helper.exs
* creating test/swift_elixir_test_test.exs

Your Mix project was created successfully.
You can use "mix" to compile it, test it, and more:

    cd swift_elixir_test
    mix test

Run "mix help" for more commands.
% 
```

書かれている指示に従って，進めます。

```zsh
% cd swift_elixir_test
swift_elixir_test % mix test
Compiling 1 file (.ex)
Generated swift_elixir_test app
..

Finished in 0.03 seconds
1 doctest, 1 test, 0 failures

Randomized with seed 231147
swift_elixir_test % 
```

ここで自動生成されたコードを修正しておきます。

```elixir:lib/swift_elixir_test.ex
defmodule SwiftElixirTest do
  @moduledoc """
  Documentation for `SwiftElixirTest`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SwiftElixirTest.hello()
      :world

  """
  def hello do
    :world
  end
end
```

これを次のようにします。(`hello`関数を削除)

```elixir:lib/swift_elixir_test.ex
defmodule SwiftElixirTest do
  @moduledoc """
  Documentation for `SwiftElixirTest`.
  """
end
```

そして自動生成されたテストコードも修正します。

```elixir:test/swift_elixir_test_test.exs
defmodule SwiftElixirTestTest do
  use ExUnit.Case
  doctest SwiftElixirTest

  test "greets the world" do
    assert SwiftElixirTest.hello() == :world
  end
end
```

これを次のようにします。

```elixir:test/swift_elixir_test_test.exs
defmodule SwiftElixirTestTest do
  use ExUnit.Case
  doctest SwiftElixirTest
end
```

ここで，`mix test`を実行して，テストが0個になることを確認します。

```zsh
swift_elixir_test % mix test
Compiling 1 file (.ex)


Finished in 0.02 seconds
0 failures

Randomized with seed 71756
swift_elixir_test % 
```

ここまでできたら，`git`に登録しましょう。

```zsh
swift_elixir_test % git init
swift_elixir_test % git add -A
swift_elixir_test % git commit -m "initial commit"
swift_elixir_test % git branch -M main
```

# Autoconf の初期設定

ここではAutoconfを使ってビルド時の環境を認識するようにします。ただしAutoconfで生成した環境認識スクリプト`configure`は並列ビルドできないという欠点があるため遅いという難点があります。せっかく並列実行に強いElixirなので，将来はElixirで並列実行できるようにしたいですが，将来課題とします。

まず空の`configure.ac`を作成します。

```configure.ac
dnl Process this file with autoconf to produce a configure script

AC_INIT()
```

* `dnl`で始まる行はコメント行です。
* `AC_INIT()`は`autoconf`に初期化を指示します。パラメータを与えるのが普通なのですが，いったん無しで実行します。

この状態で`autoconf`を実行します。もしHomebrewを使っているならあらかじめ次のコマンドを実行しておきます。

```zsh
swift_elixir_test % brew install autoconf
```

では`autoconf`を実行しましょう。

```zsh
swift_elixir_test % autoconf
```

そうすると次のファイルが生成されます。

```zsh
autom4te.cache configure
```

`.gitignore`に下記を追記して`git`が追加ファイルを無視するようにしましょう。

```.gitignore:.gitignore
# For Autoconf
/autom4te.cache/

# For configure
/configure
```

`configure`を実行してみます。

```zsh
swift_elixir_test % ./configure
```

すると`config.log`が生成されるので，これも`.gitignore`に下記を追記して無視するように設定します。

```.gitignore:.gitignore
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
```

これを次のように書き換えます。

```elixir:mix.exs
  defp deps do
    [
      {:elixir_make, "~> 0.6.2", runtime: false}
    ]
  end
```

それから次のコマンドを実行します。

```zsh
swift_elixir_test % mix deps.get
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
      app: :swift_elixir_test,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end
```

次のようにします。

```elixir:mix.exs
  def project do
    [
      app: :swift_elixir_test,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:elixir_make] ++ Mix.compilers,
      aliases: [compile: [&configure/1]]
    ]
  end
```

このようにすると，`make`を呼び出す代わりに`./configure`を呼び出します。`mix compile`を実行してエラーがないことを確認しましょう。(なお，この時点では `make`を呼んでいません)

# Automakeでライブラリを生成

次にAutomakeの設定をします。

ElixirからSwiftを呼ぶために，ElixirからCで生成したネイティブコードをリンクして呼出すNIFを利用します。NIFで呼出すためには動的ライブラリとして生成しますので，Automakeで動的ライブラリを生成するように設定する必要があります。

Cのソースコードを`native/libnif.c`に配置しましょう。次のコマンドを実行します。

```zsh
swift_elixir_test % mkdir -p native
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

* `AUTOMAKE_OPTIONS = subdir-objects` でサブディレクトリにソースコード等を配置することを指定します。
* `ACLOCAL_AMFLAGS = -I m4` は `aclocal` で設定した値を読み込みます。
* `lib_LTLIBRARIES = priv/libnif.la` はビルドしたいライブラリを指定します。拡張子が `.la` ですが，Automakeでは一律にこのように指定するので，心配しないでください。
* `priv_libnif_la_` というのは `priv/libnif.la` に対応するオプションであることを示す接頭辞です。
    * `priv_libnif_la_SOURCES` でソースコードを指定します。ここでは `native/libnif.c` をコンパイルします。
    * `priv_libnif_la_CFLAGS` でコンパイルする時の `CFLAGS` の値を決めます。ここでは，`CFLAGS` と `ERL_CFLAGS` の値を設定します。`ERL_CFLAGS` は後で `configure.ac`の中で設定しますが，Erlang が提供するヘッダファイルの情報などを定義します。
    * `priv_libnif_la_LDFLAGS` で同様にリンクする時の `LDFLAGS` の値を決めます。ここでは，`LDFLAGS` と `ERL_LDFLAGS` の値を設定します。`ERL_LDFLAGS`は，`ERL_CFLAGS`と同様です。動的な共有ライブラリを生成するために，`-shared` `-module` `-export-dynamic` を指定します。`.so` というようにバージョン番号を記載しないようにするために `-avoid-version` を指定します。


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

* `AC_INIT` に生成するライブラリの情報を与えます。
* `AC_CONFIG_MACRO_DIRS([m4])`で`aclocal`で得られた設定を読むようにします。
* `AC_INIT_AUTOMAKE` で Automake の使用を宣言します。オプションでエラーや警告を表示するようにしています。
* `AC_ARG_VAR` で，`configure`に与える環境変数を定義します。第1引数に変数名，第2引数に`configure --help`の時に表示する説明を記載します。本当は第2引数をていねいにドキュメンテーションすべきところですが，手を抜いています。
* `AC_PROG_CC`と`AC_PROG_AR`はそれぞれ，`CC`と`AR`で指定されたコンパイラとリンカが存在することを確認します。
* `AC_PATH_PROG(ELIXIR, $ELIXIR, elixir)` で環境変数`ELIXIR`が設定されている場合にはそのパス上のプログラムが，設定されていない時には`elixir`が，`PATH`上に存在するかを確認してその結果を表示します。
* その後の `AC_MSG_CHECKING` から `AC_MSG_RESULT` の一塊は，それぞれErlangに関連する環境変数が設定されているかを確認します。
    * `AC_MSG_CHECKING([setting ERL...])` で確認中のメッセージを表示します。
    * `if test "x$ERL..." = "x"; then ... fi` で環境変数`ERL...`が設定されているかを確認します。このような書き方は，シェルで移植性の高い記述をするためのAutoconfでは定番の書き方です。
    * `AC_SUBST`は第1引数の環境変数に第2引数の値を代入します。
    * ここでは`elixir --eval ワンライナープログラム` とすることで，それぞれ少しずつ異なるElixirのワンライナーのプログラムを実行して設定に必要なパスを取得しています。
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
swift_elixir_test % brew install automake libtool
```

そして次のコマンドを実行します。

```zsh
swift_elixir_test % autoreconf -i
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
      app: :swift_elixir_test,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:elixir_make] ++ Mix.compilers(),
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

これで `mix compile` を実行します。エラーなくビルドが終わりましたか？ 出来たら次のようにして動的ライブラリが出来上がっていることを確認します。

```zsh
swift_elixir_test % file priv/.libs/libnif.so 
priv/.libs/libnif.so: Mach-O 64-bit bundle x86_64
```

やった！

# `elixir_make`でNIFのビルド

うまくいったので，`native/libnif.c` を仮実装します。

```c:native/libnif.c
#include <stdlib.h>
#include <erl_nif.h>

static ERL_NIF_TERM test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
	ERL_NIF_TERM atom_error = enif_make_atom(env, "error");
	return enif_make_tuple(env, 2, atom_error, enif_make_atom(env, "not_implemented"));
}

static ErlNifFunc nif_funcs[] =
{
	{"test", 0, test}
};

ERL_NIF_INIT(Elixir.SwiftElixirTest, nif_funcs, NULL, NULL, NULL, NULL)
```

この段階で `mix compile` してエラーがなくビルドできることを確認します。

説明は次のとおりです。

* `NULL`を使うために，`#include <stdlib.h>`としました。
* `#include <erl_nif.h>` はErlang の NIF API を定義しているヘッダファイルをインクルードします。もしここでエラーになるようならば，Automakeの設定のところが間違えていますので，見直してください。
* `test`関数の定義はNIF APIに沿っています。第1引数が実行時環境，第2引数と第3引数で可変長の引数を形成しています。`ERL_NIF_TERM`型はElixir/Erlangの変数のインタフェースです。
* `enif_make_atom`でアトムを生成します。第1引数が実行時環境，第2引数がアトムの名前です。
* `enif_make_tuple`でタプルを生成します。第1引数が実行時環境，第2引数から可変長の引数を形成していて，第2引数が要素数，第3引数以下が各要素です。
* 仮に`{:error, :not_implemented"}`を返しています。
* `nif_funcs`で関数を登録します。この場合の意味としてはElixirのtest関数の引数の数(アリティ)が0であるような`test`という名称の関数を定義しています。
* `ERL_NIF_INIT`でモジュールを登録します。第1引数がモジュール名，第2引数が`nif_funcs`，第3〜6引数は初期化やリロード時の設定をする関数を登録します。ここでは仮に第3〜6引数には`NULL`を登録します。

次に`lib/swift_elixir_test.ex`を変更します。

```elixir:lib/swift_elixir_test.ex
defmodule SwiftElixirTest do
  require Logger

  @moduledoc """
  Documentation for `SwiftElixirTest`.
  """

  @on_load :load_nif

  def load_nif do
    nif_file = '#{:code.priv_dir(:swift_elixir_test)}/.libs/libnif'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.warn("Failed to load NIF: #{inspect(reason)}")
    end
  end

  def test(), do: raise("NIF test/0 not implemented")
end
```

説明は次のとおりです。

* `require Logger`とすることで，デバッグ等のログ出力を行うモジュールを呼び出せるようにします。
* `@on_load :load_nif`とすることで，このモジュールを読み込む時，`load_nif`関数を呼び出します。
* `nif_file`に読み込むNIFライブラリの情報を与えます。
    * `nif_file='...'`のようにシングルクォーテーションであるのに注意してください。Erlangに直接渡す文字列なので，char listにしてあります。
    * `:code_priv_dir`は，第1引数で指定したモジュールの`priv`ディレクトリを参照する関数です。
    * `SwiftElixirTest`モジュールの`priv/.libs/libnif.so`を読み込むので，`.so`を取って`:code_priv_dir(:swift_elixir_test)/.libs/libnif`とします。 
* `:erlang.load_nif`はNIFをロードする関数です。
* `:ok`もしくは`{:error, {:reload, ...}}`が返ってきた時には正常終了します。
* それ以外の`{:error, ...}`が返ってきた時には，`...`を`reason`に代入して，`Logger`を使って警告表示をします。
* `test`関数の定義がNIF関数へのスタブです。NIFを定義する場合の定番で，呼び出した時に例外を発生するようにしています。NIFライブラリが正常に読み込めると上書きされて，NIFを呼び出すようになります。

ここまで出来たら `iex -S mix` を実行してみましょう。少し待った後に，次のように正常に起動しましたか？

```elixir
swift_elixir_test % iex -S mix 
Erlang/OTP 23 [erts-11.1.2] [source] [64-bit] [smp:6:6] [ds:6:6:10] [async-threads:1] [hipe]

make: Nothing to be done for `all'.
Interactive Elixir (1.11.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> 
```

もし実際にビルドしている時には次のように表示されます。

```elixir
swift_elixir_test % iex -S mix 
Erlang/OTP 23 [erts-11.1.2] [source] [64-bit] [smp:6:6] [ds:6:6:10] [async-threads:1] [hipe]

/bin/sh ./libtool  --tag=CC   --mode=compile gcc -DPACKAGE_NAME=\"priv/.libs/libnif.so\" -DPACKAGE_TARNAME=\"priv--libs-libnif-so\" -DPACKAGE_VERSION=\"1.0\" -DPACKAGE_STRING=\"priv/.libs/libnif.so\ 1.0\" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DPACKAGE=\"priv--libs-libnif-so\" -DVERSION=\"1.0\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -DLT_OBJDIR=\".libs/\" -I.    -g -O2 -I/Users/zacky/.asdf/installs/erlang/23.1.2/usr/include -g -O2 -MT native/priv_libnif_la-libnif.lo -MD -MP -MF native/.deps/priv_libnif_la-libnif.Tpo -c -o native/priv_libnif_la-libnif.lo `test -f 'native/libnif.c' || echo './'`native/libnif.c
libtool: compile:  gcc -DPACKAGE_NAME=\"priv/.libs/libnif.so\" -DPACKAGE_TARNAME=\"priv--libs-libnif-so\" -DPACKAGE_VERSION=\"1.0\" "-DPACKAGE_STRING=\"priv/.libs/libnif.so 1.0\"" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DPACKAGE=\"priv--libs-libnif-so\" -DVERSION=\"1.0\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -DLT_OBJDIR=\".libs/\" -I. -g -O2 -I/Users/zacky/.asdf/installs/erlang/23.1.2/usr/include -g -O2 -MT native/priv_libnif_la-libnif.lo -MD -MP -MF native/.deps/priv_libnif_la-libnif.Tpo -c native/libnif.c  -fno-common -DPIC -o native/.libs/priv_libnif_la-libnif.o
libtool: compile:  gcc -DPACKAGE_NAME=\"priv/.libs/libnif.so\" -DPACKAGE_TARNAME=\"priv--libs-libnif-so\" -DPACKAGE_VERSION=\"1.0\" "-DPACKAGE_STRING=\"priv/.libs/libnif.so 1.0\"" -DPACKAGE_BUGREPORT=\"\" -DPACKAGE_URL=\"\" -DPACKAGE=\"priv--libs-libnif-so\" -DVERSION=\"1.0\" -DSTDC_HEADERS=1 -DHAVE_SYS_TYPES_H=1 -DHAVE_SYS_STAT_H=1 -DHAVE_STDLIB_H=1 -DHAVE_STRING_H=1 -DHAVE_MEMORY_H=1 -DHAVE_STRINGS_H=1 -DHAVE_INTTYPES_H=1 -DHAVE_STDINT_H=1 -DHAVE_UNISTD_H=1 -DHAVE_DLFCN_H=1 -DLT_OBJDIR=\".libs/\" -I. -g -O2 -I/Users/zacky/.asdf/installs/erlang/23.1.2/usr/include -g -O2 -MT native/priv_libnif_la-libnif.lo -MD -MP -MF native/.deps/priv_libnif_la-libnif.Tpo -c native/libnif.c -o native/priv_libnif_la-libnif.o >/dev/null 2>&1
mv -f native/.deps/priv_libnif_la-libnif.Tpo native/.deps/priv_libnif_la-libnif.Plo
/bin/sh ./libtool  --tag=CC   --mode=link gcc -g -O2 -I/Users/zacky/.asdf/installs/erlang/23.1.2/usr/include -g -O2  -L/Users/zacky/.asdf/installs/erlang/23.1.2/usr/lib -shared -module -avoid-version -export-dynamic  -o priv/libnif.la -rpath /usr/local/lib native/priv_libnif_la-libnif.lo  
libtool: link: gcc -Wl,-undefined -Wl,dynamic_lookup -o priv/.libs/libnif.so -bundle  native/.libs/priv_libnif_la-libnif.o   -L/Users/zacky/.asdf/installs/erlang/23.1.2/usr/lib  -g -O2 -g -O2  
libtool: link: ( cd "priv/.libs" && rm -f "libnif.la" && ln -s "../libnif.la" "libnif.la" )
Compiling 1 file (.ex)
Generated swift_elixir_test app
Interactive Elixir (1.11.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> 
```

では次のように`SwiftElixirTest.test`関数を呼び出して，仮の実装である`{:error, :not_implemented}`が返ってくることを確かめましょう。

```elixir
iex(1)> SwiftElixirTest.test
{:error, :not_implemented}
iex(2)> 
```

# Autoconf/AutomakeでMacかどうかを判別するには

まず`configure.ac`を次のように書き換えて，OSを認識するようにしましょう。さしあたり，macOSとLinuxで動くようにします。

```configure.ac
dnl Process this file with autoconf to produce a configure script

AC_INIT([priv/.libs/libnif.so], [1.0])

AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_ARG_VAR([ELIXIR], [Elixir])
AC_ARG_VAR([ERL_EI_INCLUDE_DIR], [ERL_EI_INCLUDE_DIR])
AC_ARG_VAR([ERL_EI_LIBDIR], [ERL_EI_LIBDIR])
AC_ARG_VAR([CROSSCOMPILE], [CROSSCOMPILE])
AC_ARG_VAR([ERL_CFLAGS], [ERL_CFLAGS])
AC_ARG_VAR([ERL_LDFLAGS], [ERL_LDFLAGS])

AC_ARG_VAR([OBJC_FLAGS], [OBJC_FLAGS])

AC_PROG_CC

build_linux=no
build_mac=no
all_mac=no

case "${host_os}" in
	linux*)
		build_linux=yes
		;;
	cygwin*|mingw*)
		AC_MSG_ERROR([OS $host_os on Windows is not supported])
		;;
	darwin*)
		case "${build_os}" in
			darwin*)
				case "${target_os}" in
					darwin*)
						all_mac=yes
						AC_PATH_PROG(XCRUN, xcrun)
						;;
					*)
						;;
				esac
				;;
			*)
				;;
		esac
		build_mac=yes
		;;
	*)
		AC_MSG_ERROR([OS $host_os is not suppurted])
		;;
esac

AM_CONDITIONAL([LINUX], [test "x$build_linux" = "xyes"])
AM_CONDITIONAL([OSX], [test "x$build_mac" = "xyes"])
AM_CONDITIONAL([ALLOSX], [test "x$all_mac" = "xyes"])

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

追加分を説明します。

* `AC_CANONICAL_BUILD`, `AC_CANONICAL_HOST`, `AC_CANONICAL_TARGET` を指定することで，それぞれ，ビルド時，ホスト，ターゲットのCPU，ベンダー，OSの情報を得ることが出来るようになります。これらは，`AC_INIT`の直後に置くのが賢明です。
* `OBJC_FLAGS`という変数を足しました。
* `build_linux=no`から`AM_CONDITIONAL([ALLOSX], [test "x$all_mac" = "xyes"])`までがOSの種類の判別です。さしあたり，私が準備できる検証環境であるLinuxの場合とmacOSの場合にのみビルドができるようにしています。macOSの場合は，さらにビルド時，ホスト，ターゲットがいずれもmacOSの場合でのみ，`ALLOSX`という条件を成立させるようにしています。
* また，この条件が成立した時にのみ，Xcodeのコマンドラインツールである`xcrun`がパス上に存在するかを確認しています。

次に`Makefile.am`を次のように変更します。

```Makefile.am
AUTOMAKE_OPTIONS = subdir-objects
ACLOCAL_AMFLAGS = -I m4

lib_LTLIBRARIES = priv/libnif.la
priv_libnif_la_SOURCES = native/libnif.c

if ALLOSX
priv_libnif_la_CFLAGS = -DALLOSX $(CFLAGS) $(ERL_CFLAGS)
else
priv_libnif_la_CFLAGS = $(CFLAGS) $(ERL_CFLAGS)
endif

priv_libnif_la_LDFLAGS = $(LDFLAGS) $(ERL_LDFLAGS) -shared -module -avoid-version -export-dynamic
```

`ALLOSX`が成立している場合，すなわちビルド時，ホスト，ターゲットがいずれもmacOSの場合に，マクロ`ALLOSX`を定義して`native/libnif.c`をコンパイルするようにしています。

これで，`native/libnif.c`中で `#ifdef ALLOSX`とすれば，ビルド時，ホスト，ターゲットがいずれもmacOSの場合か，それ以外かを判別してプログラムコードを書き分けることが可能になります。

# NIFからObjective-Cのコードを呼び出す

では，ビルド時，ホスト，ターゲットがいずれもmacOSの場合に，次のようなObjective-Cのコードを呼び出してみましょう。

```objc:caller.m
#import <Foundation/Foundation.h>
#import "caller.h"

void caller()
{
	NSLog(@"Hello world from Objective-C.");
}
```

```objc:caller.h
#ifndef CALLER_H
#define CALLER_H

void caller();

#endif // CALLER_H
```

Objective-Cのコードと言いつつ，ほぼCのコードですが，このcaller関数を起点に任意のObjective-Cのコードを呼び出せると思ってください。さしあたり，`Foundation`に定義されている`NSLog`を用いて，Hello, worldしたいと思います。

ビルド・リンクするには，`Makefile.am`を次のようにします。

```Makefile.am
AUTOMAKE_OPTIONS = subdir-objects
ACLOCAL_AMFLAGS = -I m4

lib_LTLIBRARIES = priv/libnif.la
priv_libnif_la_SOURCES = native/libnif.c

if ALLOSX
priv_libnif_la_LIBADD = $(LIBOBJS) native/caller.lo
native/caller.lo: native/caller.m native/caller.h
	$(LIBTOOL) --mode=compile xcrun clang -c $(OBJC_FLAGS) $(CFLAGS) -o $@ $<
endif

if ALLOSX
priv_libnif_la_CFLAGS = -DALLOSX $(CFLAGS) $(ERL_CFLAGS)
else
priv_libnif_la_CFLAGS = $(CFLAGS) $(ERL_CFLAGS)
endif

priv_libnif_la_LDFLAGS = $(LDFLAGS) $(ERL_LDFLAGS) -shared -module -avoid-version -export-dynamic
```

追加分の説明は次のとおりです。

* `priv_libnif_la_LIBADD`として，`priv/.libs/libnif.so`に`native/caller.lo`を追加するようにしています。`$(LIBOBJS)`は，それまでのオブジェクトファイル群を登録している変数です。
* `native/caller.lo: native/caller.m native/caller.h`として依存関係を定義しています。
* `$(LIBTOOL) --mode=compile xcrun clang -c $(OBJC_FLAGS) $(CFLAGS) -o $@ $<`とすることで，XcodeのClangを明示的に呼び出してコンパイルし，Libtoolを使って`.lo`形式に変換しています。XcodeのClangを明示的に呼び出すことで，`Framework`をリンクしてくれますし，Swiftコードをリンクした時にもバージョンの不一致を避けられます。

# Foundation と `NSLog` の動作確認(Objective-C)

せっかくAutotoolsを使っているので，試しにFoundationと`NSLog`が動作するかをチェックするスクリプトを導入してみましょう。`configure.ac`を次のようにします。

```configure.ac
dnl Process this file with autoconf to produce a configure script

AC_INIT([priv/.libs/libnif.so], [1.0])

AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_ARG_VAR([ELIXIR], [Elixir])
AC_ARG_VAR([ERL_EI_INCLUDE_DIR], [ERL_EI_INCLUDE_DIR])
AC_ARG_VAR([ERL_EI_LIBDIR], [ERL_EI_LIBDIR])
AC_ARG_VAR([CROSSCOMPILE], [CROSSCOMPILE])
AC_ARG_VAR([ERL_CFLAGS], [ERL_CFLAGS])
AC_ARG_VAR([ERL_LDFLAGS], [ERL_LDFLAGS])

AC_ARG_VAR([OBJC_FLAGS], [OBJC_FLAGS])

AC_PROG_CC

build_linux=no
build_mac=no
all_mac=no

case "${host_os}" in
	linux*)
		build_linux=yes
		;;
	cygwin*|mingw*)
		AC_MSG_ERROR([OS $host_os on Windows is not supported])
		;;
	darwin*)
		case "${build_os}" in
			darwin*)
				case "${target_os}" in
					darwin*)
						all_mac=yes
						AC_PATH_PROG(XCRUN, xcrun)
						;;
					*)
						;;
				esac
				;;
			*)
				;;
		esac
		build_mac=yes
		;;
	*)
		AC_MSG_ERROR([OS $host_os is not suppurted])
		;;
esac

AM_CONDITIONAL([LINUX], [test "x$build_linux" = "xyes"])
AM_CONDITIONAL([OSX], [test "x$build_mac" = "xyes"])
AM_CONDITIONAL([ALLOSX], [test "x$all_mac" = "xyes"])

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

working_foundation=no
working_nslog=no
if test "x$all_mac" = "xyes"; then
	AC_MSG_CHECKING([whether Foundation Framework exists])
	cat>_framework.m<<EOF
#import <Foundation/Foundation.h>
int main() {
	return 0;
}
EOF
	if xcrun clang _framework.m -o _framework > /dev/null 2>&1 && ./_framework > /dev/null 2>&1 ; then
		working_foundation=yes
	fi
	rm -f _framework.m _framework.o _framework
	AC_MSG_RESULT([$working_foundation])

	AC_MSG_CHECKING([whether NSLog works])
	cat>_nslog.m<<EOF
#import <Foundation/Foundation.h>
int main() {
	NSLog(@"hello world");
	return 0;
}
EOF
	if xcrun clang _nslog.m -o _nslog -framework Foundation > /dev/null 2>&1 && ./_nslog  > /dev/null 2>&1 ; then
		working_nslog=yes
	fi
	rm -f _nslog.m _nslog.o _nslog
	AC_MSG_RESULT([$working_nslog])
fi

AM_CONDITIONAL([EXIST_FOUNDATION], [test "x$working_foundation" = "xyes"])
AM_CONDITIONAL([WORK_NSLOG], [test "x$working_nslog" = "xyes"])

LT_INIT()
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
```

追加分を説明します。

* `working_foundation=no` と `working_nslog=no`でそれぞれのフラグを初期化します。
* `if test "x$all_mac" = "xyes"; then`で，ビルド時，ホスト，ターゲットが全てmacOSのときのみ動作するようにします。
* `AC_MSG_CHECKING([whether Foundation Framework exists])`でFoundationが存在するかチェックしますと表示します。
* 次の`cat`から2つ目の`EOF`までがテストするプログラムコードです。
* 次の`if`でこのプログラムコードをコンパイルして実行し，正常終了することを確認します。標準出力とエラー出力をまとめてリダイレクトする点に注意してください。
* `rm`で生成したファイルを削除します。
* `AC_MSG_RESULT([$working_foundation])`で検証結果を表示します。
* 同様に`NSLog`についても動作確認します。
* `AM_CONDITIONAL`で判定結果を`Makefile.am`で利用できるようにします。それぞれ，`EXIST_FOUNDATION`と`WORK_NSLOG`で真偽値を取り出せるようにしています。

Foundationと`NSLog`は標準の機能なので，存在をチェックしてコードに反映するのはナンセンスだと思いますが，例としてやってみましょう。

```Makefile.am
AUTOMAKE_OPTIONS = subdir-objects
ACLOCAL_AMFLAGS = -I m4

if EXIST_FOUNDATION
OBJC_FLAGS += -DEXIST_FOUNDATION
endif
if WORK_NSLOG
OBJC_FLAGS += -DWORK_NSLOG
endif

lib_LTLIBRARIES = priv/libnif.la
priv_libnif_la_SOURCES = native/libnif.c

if ALLOSX
priv_libnif_la_LIBADD = $(LIBOBJS) native/caller.lo
native/caller.lo: native/caller.m native/caller.h
	$(LIBTOOL) --mode=compile xcrun clang -c $(OBJC_FLAGS) $(CFLAGS) -o $@ $<
endif

if ALLOSX
priv_libnif_la_CFLAGS = -DALLOSX $(CFLAGS) $(ERL_CFLAGS)
else
priv_libnif_la_CFLAGS = $(CFLAGS) $(ERL_CFLAGS)
endif

priv_libnif_la_LDFLAGS = $(LDFLAGS) $(ERL_LDFLAGS) -shared -module -avoid-version -export-dynamic
```

追加分の説明です。

* `if EXIST_FOUNDATION`から`endif`までは`EXIST_FOUNDATION`が真の時に`OBJC_FLAGS`に`-DEXIST_FOUNDATION`を追加することで，マクロ`EXIST_FOUNDATION`を定義しています。`OBJC_FLAGS`の行をインデントしない点に注意してください。インデントすると変数の更新が読まれなくなってしまいます。
* 同様に`if WORK_NSLOG`から`endif`までは`WORK_FOUNDAION`が真の時に`OBJC_FLAGS`に`-DWORK_NSLOG`を追加しています。
 
```objc:caller.m
#ifdef EXIST_FOUNDATION
#import <Foundation/Foundation.h>
#endif

#import "caller.h"

void caller()
{
#ifdef WORK_NSLOG
	NSLog(@"Hello world from Objective-C.");
#endif
}
```

マクロ `EXIST_FOUNDATION`と`WORK_NSLOG`が定義されているかをみて，それぞれ`#import <Foundation/Foundation.h>`と`NSLog(...)`をスイッチしています。

# Objective-CからSwiftのコードを呼び出す


[Swift 5.3のコードをObjective-Cから呼び出す方法](https://qiita.com/zacky1972/items/6c88b26be2c2659b9d15)で既に紹介しましたが，Autoconfに対応させましょう。

次のようなSwiftのコードを呼び出します。このコードの出典はhttps://docs.swift.org/swift-book/LanguageGuide/Methods.html です。

```swift:native/ExampleClass.swift
import Foundation

@objc class ExampleClass: NSObject {
    var count = 0
    @objc func increment() {
        count += 1
        NSLog("Hello world from Swift.")
    }
    @objc func increment(by amount: Int) {
        count += amount
    }
    @objc func reset() {
        count = 0
    }
}
```

Objective-Cから呼び出せるようにするためには，次の2つのことを行います。

* `import Foundation`として，`NSObject`から派生するようにクラスを定義する
* `@objc`をクラスと，Objective-Cから呼び出したいメソッドに付記する

このようなクラスを足がかりとして，任意のSwiftコードを呼び出せば良いというわけです。

Objective-Cの次のように変更します。

```objc:native/caller.m
#import <Foundation/Foundation.h>
#import "ExampleClass-Swift.h"
#import "caller.h"

void caller()
{
	ExampleClass *obj = [[ExampleClass alloc] init];
	[obj increment];
	NSLog(@"Hello world from Objective-C.");
}
```

ポイントは次のとおりです。

* クラス名が`ExampleClass`である場合には，`import "ExampleClass-Swift.h"`とする(クラス名に`-Swift.h`をつけたヘッダファイルをインポートする)
* あとはSwiftのコードをObjective-Cに読み替えて呼び出す。

`configure.ac`を次のようにします。

```configure.ac
dnl Process this file with autoconf to produce a configure script

AC_INIT([priv/.libs/libnif.so], [1.0])

AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_ARG_VAR([ELIXIR], [Elixir])
AC_ARG_VAR([ERL_EI_INCLUDE_DIR], [ERL_EI_INCLUDE_DIR])
AC_ARG_VAR([ERL_EI_LIBDIR], [ERL_EI_LIBDIR])
AC_ARG_VAR([CROSSCOMPILE], [CROSSCOMPILE])
AC_ARG_VAR([ERL_CFLAGS], [ERL_CFLAGS])
AC_ARG_VAR([ERL_LDFLAGS], [ERL_LDFLAGS])

AC_ARG_VAR([OBJC_FLAGS], [OBJC_FLAGS])
AC_ARG_VAR([SWIFT_FLAGS], [SWIFT_FLAGS])

AC_PROG_CC

build_linux=no
build_mac=no
all_mac=no

case "${host_os}" in
	linux*)
		build_linux=yes
		;;
	cygwin*|mingw*)
		AC_MSG_ERROR([OS $host_os on Windows is not supported])
		;;
	darwin*)
		case "${build_os}" in
			darwin*)
				case "${target_os}" in
					darwin*)
						all_mac=yes
						AC_PATH_PROG(XCRUN, xcrun)
						;;
					*)
						;;
				esac
				;;
			*)
				;;
		esac
		build_mac=yes
		;;
	*)
		AC_MSG_ERROR([OS $host_os is not suppurted])
		;;
esac

AM_CONDITIONAL([LINUX], [test "x$build_linux" = "xyes"])
AM_CONDITIONAL([OSX], [test "x$build_mac" = "xyes"])
AM_CONDITIONAL([ALLOSX], [test "x$all_mac" = "xyes"])

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

working_foundation=no
working_nslog=no
if test "x$all_mac" = "xyes"; then
	AC_MSG_CHECKING([whether Foundation Framework exists])
	cat>_framework.m<<EOF
#import <Foundation/Foundation.h>
int main() {
	return 0;
}
EOF
	if xcrun clang _framework.m -o _framework > /dev/null 2>&1 && ./_framework > /dev/null 2>&1 ; then
		working_foundation=yes
	fi
	rm -f _framework.m _framework.o _framework
	AC_MSG_RESULT([$working_foundation])

	AC_MSG_CHECKING([whether NSLog works])
	cat>_nslog.m<<EOF
#import <Foundation/Foundation.h>
int main() {
	NSLog(@"hello world");
	return 0;
}
EOF
	if xcrun clang _nslog.m -o _nslog -framework Foundation > /dev/null 2>&1 && ./_nslog  > /dev/null 2>&1 ; then
		working_nslog=yes
	fi
	rm -f _nslog.m _nslog.o _nslog
	AC_MSG_RESULT([$working_nslog])
fi

AM_CONDITIONAL([EXIST_FOUNDATION], [test "x$working_foundation" = "xyes"])
AM_CONDITIONAL([WORK_NSLOG], [test "x$working_nslog" = "xyes"])

LT_INIT()
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
```

変更点は次のとおりです。

* `AC_ARG_VAR([SWIFT_FLAGS], [SWIFT_FLAGS])`を追加する

本題の`Makefile.am`を次のようにします。

```Makefile.am
AUTOMAKE_OPTIONS = subdir-objects
ACLOCAL_AMFLAGS = -I m4

lib_LTLIBRARIES = priv/libnif.la
priv_libnif_la_SOURCES = native/libnif.c

if ALLOSX
priv_libnif_la_LIBADD = $(LIBOBJS) native/caller.lo native/ExampleClass.lo

native/caller.lo: native/caller.m native/caller.h native/ExampleClass-Swift.h
	$(LIBTOOL) --mode=compile xcrun clang -c $(OBJC_FLAGS) $(CFLAGS) -o $@ $<

native/ExampleClass.lo: native/ExampleClass.swift
	$(LIBTOOL) --mode=compile ./swiftc_wrapper $(SWIFT_FLAGS) -emit-object -parse-as-library $< -o $@ 

native/ExampleClass-Swift.h: native/ExampleClass.swift
	xcrun swiftc $(SWIFT_FLAGS) $< -emit-objc-header -emit-objc-header-path $@
endif

if ALLOSX
priv_libnif_la_CFLAGS = -DALLOSX $(CFLAGS) $(ERL_CFLAGS)
else
priv_libnif_la_CFLAGS = $(CFLAGS) $(ERL_CFLAGS)
endif

if ALLOSX
priv_libnif_la_LDFLAGS = $(LDFLAGS) $(ERL_LDFLAGS) -shared -module -avoid-version -export-dynamic -L`xcrun --show-sdk-path`/usr/lib/swift -undefined dynamic_lookup
else
priv_libnif_la_LDFLAGS = $(LDFLAGS) $(ERL_LDFLAGS) -shared -module -avoid-version -export-dynamic
endif
```

変更点は次のとおりです。

* `priv_libnif_la_LIBADD` に `native/ExampleClass.lo`を加える
* `native/caller.lo`を生成するルールの依存関係に `native/ExampleClass-Swift.h`を加える
* `native/ExampleClass.lo` を生成するルールを加える
    * 依存ファイルは`native/ExampleClass.swift`
    * Libtoolで`swiftc`を呼び出すのですが，そのまま呼び出すとオプションのエラーになるので，ラッパー`swiftc_wrapper`を介して呼び出す(後述)
    * `-emit-object`をつけることでオブジェクトファイルを生成する
    * `-parse-as-library`をつけることでライブラリとしてリンクできるようにする
* `native/ExampleClass-Swift.h`を生成するルールを加える
    * `xcrun swiftc`でSwiftのコンパイラを呼び出す
    * `-emit-objc-header` でObjective-Cのヘッダファイルを生成させる
    * `-emit-objc-header-path` で生成先を指定する
    * (残課題) `ExampleClass{,.swift{doc,module,sourceinfo}}`を生成してしまうのだけど，生成を抑制する方法がわからない
* `ALLOSX`のとき，`priv_libnif_la_LDFLAGS`に以下を加えることで，Swiftのライブラリをリンクする

```
 -L`xcrun --show-sdk-path`/usr/lib/swift -undefined dynamic_lookup
```

`swiftc_wrapper`は次のようなシェルスクリプトです。

```bash
#!/bin/sh

echo "xcrun swiftc $@" | sed -e 's/-fno-common//g' | sed -e 's/-DPIC//g' > _swiftc_wrapper
chmod +x _swiftc_wrapper
./_swiftc_wrapper
rm _swiftc_wrapper
```

やっていることは，Libtoolがコンパイルモードでコンパイラを起動する時につけるオプションである `-fno-common`と `-DPIC` は `swiftc` では認識されないので，外す，ということです。

もうちょっとスマートに書けそうに思います。良い方法があったら教えてください。

以上で`mix clean` と `iex -S mix`を実行してコンパイルエラーがないことを確認してください。さらに次のように実行すると，SwiftとObjective-Cからそれぞれ`NSLog`でメッセージを表示してくれるはずです。

```elixir
iex(1)> SwiftElixirTest.test
2020-12-01 06:45:06.883 beam.smp[97578:5144991] Hello world from Swift.
                                                                       2020-12-01 06:45:06.883 beam.smp[97578:5144991] Hello world from Objective-C.
                                                                    :ok
iex(2)> 
```

Linuxで実行すると次のようになります。

```elixir
iex(1)> SwiftElixirTest.test
{:error, :not_implemented}
iex(2)> 
```

# Foundation と `NSLog` の動作確認(Swift)

Foundationと`NSLog`の動作確認をSwiftでも行いましょう。

```configure.ac
dnl Process this file with autoconf to produce a configure script

AC_INIT([priv/.libs/libnif.so], [1.0])

AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET

AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])

AC_ARG_VAR([ELIXIR], [Elixir])
AC_ARG_VAR([ERL_EI_INCLUDE_DIR], [ERL_EI_INCLUDE_DIR])
AC_ARG_VAR([ERL_EI_LIBDIR], [ERL_EI_LIBDIR])
AC_ARG_VAR([CROSSCOMPILE], [CROSSCOMPILE])
AC_ARG_VAR([ERL_CFLAGS], [ERL_CFLAGS])
AC_ARG_VAR([ERL_LDFLAGS], [ERL_LDFLAGS])

AC_ARG_VAR([OBJC_FLAGS], [OBJC_FLAGS])
AC_ARG_VAR([SWIFT_FLAGS], [SWIFT_FLAGS])

AC_PROG_CC

build_linux=no
build_mac=no
all_mac=no

case "${host_os}" in
	linux*)
		build_linux=yes
		;;
	cygwin*|mingw*)
		AC_MSG_ERROR([OS $host_os on Windows is not supported])
		;;
	darwin*)
		case "${build_os}" in
			darwin*)
				case "${target_os}" in
					darwin*)
						all_mac=yes
						AC_PATH_PROG(XCRUN, xcrun)
						;;
					*)
						;;
				esac
				;;
			*)
				;;
		esac
		build_mac=yes
		;;
	*)
		AC_MSG_ERROR([OS $host_os is not suppurted])
		;;
esac

AM_CONDITIONAL([LINUX], [test "x$build_linux" = "xyes"])
AM_CONDITIONAL([OSX], [test "x$build_mac" = "xyes"])
AM_CONDITIONAL([ALLOSX], [test "x$all_mac" = "xyes"])

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

working_foundation=no
working_nslog=no
if test "x$all_mac" = "xyes"; then
	AC_MSG_CHECKING([whether Foundation Framework exists in Objective C])
	cat>_framework.m<<EOF
#import <Foundation/Foundation.h>
int main() {
	return 0;
}
EOF
	if xcrun clang _framework.m -o _framework > /dev/null 2>&1 && ./_framework > /dev/null 2>&1 ; then
		AC_MSG_CHECKING([and Swift])
		cat>_framework.swift<<EOF
import Foundation
import Darwin

exit(0)
EOF
		if xcrun swiftc _framework.swift -o _framework > /dev/null 2>&1 && ./_framework > /dev/null 2>&1 ; then
			working_foundation=yes
		fi
	fi
	rm -f _framework.swift _framework.m _framework.o _framework
	AC_MSG_RESULT([$working_foundation])

	AC_MSG_CHECKING([whether NSLog works in Objective-C])
	cat>_nslog.m<<EOF
#import <Foundation/Foundation.h>
int main() {
	NSLog(@"hello world");
	return 0;
}
EOF
	if xcrun clang _nslog.m -o _nslog -framework Foundation > /dev/null 2>&1 && ./_nslog  > /dev/null 2>&1 ; then
		AC_MSG_CHECKING([and Swift])
		cat>_nslog.swift<<EOF
import Foundation
import Darwin

NSLog("hello world")
exit(0)
EOF
		if xcrun swiftc _nslog.swift -o _nslog > /dev/null 2>&1 && ./_nslog  > /dev/null 2>&1 ; then
			working_nslog=yes
		fi
	fi
	rm -f _nslog.swift _nslog.m _nslog.o _nslog
	AC_MSG_RESULT([$working_nslog])
fi

AM_CONDITIONAL([EXIST_FOUNDATION], [test "x$working_foundation" = "xyes"])
AM_CONDITIONAL([WORK_NSLOG], [test "x$working_nslog" = "xyes"])

LT_INIT()
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
```

```Makefile.am
AUTOMAKE_OPTIONS = subdir-objects
ACLOCAL_AMFLAGS = -I m4

if EXIST_FOUNDATION
OBJC_FLAGS += -DEXIST_FOUNDATION
SWIFT_FLAGS += -DEXIST_FOUNDATION
endif
if WORK_NSLOG
OBJC_FLAGS += -DWORK_NSLOG
SWIFT_FLAGS += -DWORK_NSLOG
endif

lib_LTLIBRARIES = priv/libnif.la
priv_libnif_la_SOURCES = native/libnif.c

if ALLOSX
priv_libnif_la_LIBADD = $(LIBOBJS) native/caller.lo native/ExampleClass.lo

native/caller.lo: native/caller.m native/caller.h native/ExampleClass-Swift.h
	$(LIBTOOL) --mode=compile xcrun clang -c $(OBJC_FLAGS) $(CFLAGS) -o $@ $<

native/ExampleClass.lo: native/ExampleClass.swift
	$(LIBTOOL) --mode=compile ./swiftc_wrapper $(SWIFT_FLAGS) -emit-object -parse-as-library $< -o $@ 

native/ExampleClass-Swift.h: native/ExampleClass.swift
	xcrun swiftc $(SWIFT_FLAGS) $< -emit-objc-header -emit-objc-header-path $@
endif

if ALLOSX
priv_libnif_la_CFLAGS = -DALLOSX $(CFLAGS) $(ERL_CFLAGS)
else
priv_libnif_la_CFLAGS = $(CFLAGS) $(ERL_CFLAGS)
endif

if ALLOSX
priv_libnif_la_LDFLAGS = $(LDFLAGS) $(ERL_LDFLAGS) -shared -module -avoid-version -export-dynamic -L`xcrun --show-sdk-path`/usr/lib/swift -undefined dynamic_lookup
else
priv_libnif_la_LDFLAGS = $(LDFLAGS) $(ERL_LDFLAGS) -shared -module -avoid-version -export-dynamic
endif
```

```swift:native/ExampleClass.swift
#if EXIST_FOUNDATION
import Foundation
#endif

@objc class ExampleClass: NSObject {
    var count = 0
    @objc func increment() {
        count += 1
#if WORK_NSLOG
        NSLog("Hello world from Swift.")
#endif
    }
    @objc func increment(by amount: Int) {
        count += amount
    }
    @objc func reset() {
        count = 0
    }
}
```

だいたいObjective-Cの場合と同様ですが，いくつか違いがあります。

* `swiftc`では`-framework Foundation`は不要です。
* Cでの`#ifdef`はSwiftでは`#if`です。


# おわりに

この記事ではElixirからObjective-CやSwift 5.3のコードを呼び出す方法について詳説しました。またAutotoolsを使ってObjective-CやSwiftのヘッダファイルや関数が存在するかどうかを確認する方法も示しています。

将来課題としては，Autotoolsを使うとビルドに時間がかかるようになってくるので，`make -j`による並列コンパイルをしたり，必要な時だけ`autoreconf`や`./configure`をするように改めたいのと，もっと長期的にはAutotoolsの代わりをするElixirベースのビルドツールを構築したいなと思っています。

あと，M1 Macだったときにはユニバーサルバイナリを生成するようにしてみたいですね。

* ユニバーサルバイナリの生成方法は[Building a Universal macOS Binary]( https://developer.apple.com/documentation/xcode/building_a_universal_macos_binary)に書かれています。
* また，`system_profiler SPSoftwareDataType`とすると`System Version`の項目にmacOSのバージョンが出ます。

以上を利用して，Big Surは macOS 11.0なので，それ以降だったらx86_64とarm64のユニバーサルバイナリを生成するというロジックでも良いかと思います。この方法はまた後日試してみたいと思います。

明日のElixir Advent Calendar 2020 11日目の記事は @pojiro さんの[「Elixirで並行コマンド実行サーバーを作ったら感動した話」](https://qiita.com/pojiro/items/050da725dde4d05fed9e)です。よろしくお願いします。

本研究成果は、科学技術振興機構研究成果展開事業研究成果最適展開支援プログラム A-STEP トライアウト JPMJTM20H1 の支援を受けた。
