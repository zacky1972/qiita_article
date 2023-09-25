---
title: ElixirでGitHubに公開されているがHexには公開されていないパッケージを読み込みたい
tags:
  - Elixir
private: false
updated_at: '2023-02-08T11:18:02+09:00'
id: 68e18cefdb2959b1931b
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
意外と初学者にわかりにくくなっていたので，急遽書きました．

# パターン1 Livebookなどで `Mix.install` を用いる場合で，かつ`README.md`に説明が書かれている場合．

例としては拙作のPelemayBackendです．

https://github.com/zeam-vm/pelemay_backend


`README.md`にはたいてい次のような記述があります．

```elixir
## Installation

To use `PelemayBackend`, describe the following `deps` in `mix.exs`.

def deps do
  [
    {:pelemay_backend, "~> 0.1.0-dev", github: "zeam-vm/pelemay_backend", branch: "main"}
  ]
end
```

Livebookでインストールする場合には，次のようにします．

```elixir
Mix.install([
    {:pelemay_backend, "~> 0.1.0-dev", github: "zeam-vm/pelemay_backend", branch: "main"}
])
```

# パターン2 `mix new`で作ったプロジェクトに組込む場合で，かつ`README.md`に説明が書かれている場合．

`mix new`で作ったプロジェクトの`mix.exs`に次のような記述があると思います．

```elixir
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
```

PelemayBackendの場合，ここに次のように入れます．

```elixir
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:pelemay_backend, "~> 0.1.0-dev", github: "zeam-vm/pelemay_backend", branch: "main"}
    ]
  end
```

その後，`mix deps.get`を実行します．

# パターン3 `README.md`が存在しない場合

まず該当のGitHubの`mix.exs`の`def project`と書かれているところを読んでいきます．

`app: :(アプリ名)` みたいに書かれているところはないでしょうか？

例えば拙作のPelemayBackendでは次のようになっています．

```elixir:mix.exs
defmodule PelemayBackend.MixProject do
  use Mix.Project

  @version "0.1.0-dev"
  @source_url "https://github.com/zeam-vm/pelemay_backend"

  def project do
    [
      app: :pelemay_backend,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      compilers: [:pelemay_backend, :elixir_make] ++ Mix.compilers(),
      aliases: [
        "compile.pelemay_backend": &compile/1
      ]
    ]
  end
...
```

`app: :pelemay_backend`と書かれていますね．

実はこの `app:`の後のアトム`:pelemay_backend`はアプリ名を表します．

これは前述の

```elixir
    {:pelemay_backend, "~> 0.1.0-dev", github: "zeam-vm/pelemay_backend", branch: "main"}
```

のタプルの第1要素に入れるものです．

タプルの第2要素には `version:` で指定されているバージョン番号を元にして入れます．
PelemayBackendの場合では，`version: @version`とありますので，その前にある`@version "0.1.0-dev"`から`"0.1.0-dev"`を拾ってきます．

そのバージョン以降をインストールする場合には，`~> 0.1.0-dev`のように指定します．

タプルの第3要素には，`github: "ユーザー名/レポジトリ名"`を入れます．

PelemayBackend では https://github.com/zeam-vm/pelemay_backend なので，`github: zeam-vm/pelemay_backend`を入れます．

タプルの第4要素には`branch: "ブランチ名"`を入れます．

これでどのように入れたらいいかわかると思うので，あとは，`Mix install`を使うのか，`mix new`で作ったプロジェクトに入れるのかで，前述のやり方を用います．
