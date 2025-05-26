---
title: >-
  Apple Silicon Mac + Rosetta 2 + Dockerで arm64(aarch64)/x86_64
  とmacOS/Linuxの組み合わせで自動テストする方法(Elixirだけじゃなく汎用の方法も紹介するよ)
tags:
  - テスト
  - Elixir
  - Docker
  - M1
  - AppleSilicon
private: false
updated_at: '2025-05-27T06:19:46+09:00'
id: c8410e6cc3bb76b4b437
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

[Docker for Mac](https://docs.docker.jp/docker-for-mac/toc.html)がバージョン4.3.0になって，Apple Siliconで Rosetta 2 不要になったという知らせを受けて，いろいろ試して，ARMバイナリであればトラブルなく動くことに感心しました。

[なお，Log4jの脆弱性の問題により，Docker for Mac 4.3.1以降を推奨します。詳しくはこちらを参照ください。](https://www.docker.com/blog/apache-log4j-2-cve-2021-44228/)

いろいろいじってみてふと思いついたのが，「Dockerがあれば，macOSとLinuxの自動テストを1台でできるのでは？」「Rosetta 2があれば，Apple Siliconであれば，arm64(aarch64)とamd64(x86_64)の自動テストを同時にできるのでは？」というアイデアでした。さっそく試してみたところ，一定の成果を得たので，公開します。これを，[JaSST'21 Kyushu](http://www.jasst.jp/symposium/jasst21kyushu.html)でLTすることにしました。この記事は，その成果物を公開するものです。

この記事は [fukuoka.ex Elixir／Phoenix Advent Calendar 2021](https://qiita.com/advent-calendar/2021/fukuokaex) 19日目の記事です。昨日は @Yoosuke さんの[LiveViewを使って簡単にステートフルなタイピングゲームアプリを作ろう！後編](https://qiita.com/Yoosuke/items/e6a211e12ee31f90ae24)でした。

# macOSで動作しているかの確認方法

シェルだと次のような感じです。

```zsh
uname -s
```

もし，`Darwin`が返ってくればmacOSです。

Elixirだと次のような感じです。

```zsh
:os.type()
```

もし，`{:unix, :darwin}`が返ってくればmacOSです。

# CPUのアーキテクチャの確認

シェルだと次のような感じです。

```zsh
uname -m
```

macOSのときにもし，`arm64`が返ってくればmacOSのApple Siliconです。

Elixirだと次のような感じです。

```zsh
:erlang.system_info(:system_architecture)
|> List.to_string()
|> String.split("-")
|> hd
```

macOSのときにもし，`aarch64`が返ってくればApple Siliconです。

# Rosetta 2のインストール確認

シェルだと次のような感じです。

```sh
if test "`pkgutil --files com.apple.pkg.RosettaUpdateAuto`" != ''; then
        # 条件成立
fi
```

Elixirだと次のような感じです。

```elixir
    case System.find_executable("pkgutil") do
      nil ->
        # インストールされていない
        :ok

      _ ->
        case System.cmd("pkgutil", ["--files", "com.apple.pkg.RosettaUpdateAuto"]) do
          {"", 0} ->
            # インストールされていない
            :ok

          {_, 0} ->
            # 条件成立
            :ok

          _ ->
            # インストールされていない
            :ok
        end
    end
```

# Rosetta 2を起動してのx86_64上でのテスト実行

シェルだと次のような感じです。

```sh
env /usr/bin/arch -x86_64 /bin/sh test.sh # test.sh はテストスクリプト
```

Elixirだと次のような感じです。

```elixir
System.cmd("env", ["/usr/bin/arch", "-x86_64", "mix", "test"] ++ args)
```

`arg` には `mix test` に渡すパラメータをリストで与えます。

# Docker が存在かつ起動しているかの確認

シェルだと次のような感じです。

```sh
    if test "`which docker`" != ''; then
        docker ps > /dev/null 2>&1 && \
        # 存在かつ起動している
    fi
```

Elixirだと次のような感じです。

```elixir
    case System.find_executable("docker") do
      nil ->
        # 存在しない
        :ok

      _ ->
        case System.cmd("docker", ["ps"], stderr_to_stdout: true) do
          {_, 1} ->
            # 存在しているが起動していない
            :ok

          _ ->
            # 存在かつ起動している
            :ok

        end
    end
```

# 1台のMacで，複数の環境をテストするテスティングスクリプト

次のようなシェルスクリプトを使うと，自動でElixirと1台のMacで，複数の環境をテストすることができます。

```sh
#!/bin/sh

function call_test () {
    /bin/sh test.sh
}

function call_test_by_x86_64 () {
    if test "`pkgutil --files com.apple.pkg.RosettaUpdateAuto`" != ''; then
        env /usr/bin/arch -x86_64 /bin/sh test.sh
    fi
}

function call_test_by_docker () {
    if test "`which docker`" != ''; then
        docker ps > /dev/null 2>&1 && \
        docker build -t astesting . && \
        docker run -it --rm astesting test.sh && \
        docker rmi astesting
    fi
}

case `uname -s` in 
    Darwin)
        case `uname -m` in
        arm64)
            call_test
            call_test_by_x86_64
            call_test_by_docker
            ;;
        x86_64)
            call_test
            call_test_by_docker
            ;;
        esac 
        ;;
    *) ;;
esac
```

# Elixirと1台のMacで，複数の環境をテストする `mix test.astesting` を提供するhexライブラリAstesting

Hexに公開しました。

https://hex.pm/packages/astesting

GitHubレポジトリはこちらです。

https://github.com/zeam-vm/astesting

ドキュメントはこちらです。

https://hexdocs.pm/astesting/Mix.Tasks.Test.Astesting.html

インストール方法はREADMEに書いてあります。

実行するには次のようにします。

```zsh
mix test.astesting
```

Apple Silicon Mac で Rosetta 2 をインストールしていて，かつ Docker Desktop for Macを起動していると次のように自動で arm64 macOS, x86_64 macOS, aarch64 Linux の3つの環境で `mix test` を実行してくれます。

```
% mix test.astesting
make: Nothing to be done for `all'.
...

Finished in 0.03 seconds (0.00s async, 0.03s sync)
1 doctest, 2 tests, 0 failures

Randomized with seed 723087
testing on x86_64
==> elixir_make
Compiling 1 file (.ex)
Generated elixir_make app
==> astesting
Compiling 2 files (.ex)
Generated astesting app
==> test_astesting
make: Nothing to be done for `all'.
Generated test_astesting app
...

Finished in 0.05 seconds (0.00s async, 0.05s sync)
1 doctest, 2 tests, 0 failures

Randomized with seed 999685
testing on Docker
[+] Building 3.6s (7/7) FINISHED                                                
 => [internal] load build definition from Dockerfile336                    0.4s
 => => transferring dockerfile: 206B                                       0.0s
 => [internal] load .dockerignore                                          0.7s
 => => transferring context: 2B                                            0.0s
 => [internal] load metadata for docker.io/library/elixir:1.13.0-alpine    2.4s
 => [auth] library/elixir:pull token for registry-1.docker.io              0.0s
 => [1/2] FROM docker.io/library/elixir:1.13.0-alpine@sha256:3745a095bd61  0.0s
 => CACHED [2/2] RUN apk update &&     apk add alpine-sdk &&     mix loca  0.0s
 => exporting to image                                                     0.3s
 => => exporting layers                                                    0.0s
 => => writing image sha256:0b11cae0f80c7eb500f525382e1598917ab2fb69831d8  0.1s
 => => naming to docker.io/library/astesting429                            0.1s
Resolving Hex dependencies...
Dependency resolution completed:
Unchanged:
  astesting 0.1.5
  elixir_make 0.6.3
* Getting astesting (Hex package)
* Getting elixir_make (Hex package)
==> elixir_make
Compiling 1 file (.ex)
Generated elixir_make app
==> astesting
Compiling 2 files (.ex)
Generated astesting app
==> test_astesting
mkdir -p /work/_build/test/lib/test_astesting/priv
mkdir -p /work/_build/test/lib/test_astesting/obj
cc -I/usr/local/lib/erlang/usr/include -fPIC -std=c11 -O3 -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers c_src/libnif.c -MM -MP -MF /work/_build/test/lib/test_astesting/obj/libnif.d
CC libnif.o
cc -c -I/usr/local/lib/erlang/usr/include -fPIC -std=c11 -O3 -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers -o /work/_build/test/lib/test_astesting/obj/libnif.o c_src/libnif.c
LD libnif.so
g++ -o /work/_build/test/lib/test_astesting/priv/libnif.so /work/_build/test/lib/test_astesting/obj/libnif.o -L/usr/local/lib/erlang/usr/lib -fPIC -shared  
Compiling 1 file (.ex)
Generated test_astesting app
...

Finished in 0.02 seconds (0.00s async, 0.02s sync)
1 doctest, 2 tests, 0 failures

Randomized with seed 968834
Untagged: astesting429:latest
Deleted: sha256:0b11cae0f80c7eb500f525382e1598917ab2fb69831d8db8662e3d9ba8ecf124
```

# 将来課題

なお，このテストは，`elixir_make`を入れてNIFをコンパイルする場合を示していますが，x86_64 macOSの場合でも，arm64のNIFを生成してリンクしています。arm64向けのErlang VMをHomebrewや`asdf`でインストールしている場合は，そうしないとリンクエラーになってしまうのです。

なぜそうなるかというと，Rosetta2を起動してx86_64モードで起動しているにもかかわらず，インストールされているErlangがarm64バイナリなので，arm64モードで実行することになるからです。これを解決するには，x86_64バイナリのErlangをインストールする必要があります。

その確実な方法をいろいろ調べたところ，`asdf`を使ってインストールするのが良さそうでした。`asdf`では，環境変数の設定次第でx86_64バイナリとarm64バイナリが共存できそうです。ただし，OpenSSLなど，Erlangからリンクするライブラリもx86_64バイナリにする必要がありそうで，それを確実にインストールするにはHomebrewを使ってx86_64バイナリを共存させる必要があるという感じになり，結構な大ごとになります。

別のアイデアとしては，前述の問題の解決で`asdf`を使うのですから，バージョンの異なるElixirやErlangで自動テストするようにも発展できそうです。

# おわりに

この記事では，Rosetta 2 と Docker により，1台のMacで，複数の環境をテストする方法を紹介しました。

明日は @iyanayatudaze さんの["phx.server"コマンドの実装を追い掛ける](https://zenn.dev/ito_shigeru/articles/96f8ac8ca6e5a1)です。お楽しみに。
