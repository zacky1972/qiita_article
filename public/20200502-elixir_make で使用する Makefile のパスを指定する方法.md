---
title: elixir_make で使用する Makefile のパスを指定する方法
tags:
  - Elixir
private: false
updated_at: '2020-05-03T10:29:22+09:00'
id: 1459619fb4d0193c3ff7
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
備忘録的に。

`mix.exs` の `project` の記述のところに，`make_makefile: "path/to/Makefile"` と記述すると，elixir_make で使用する `Makefile` のパスを指定することができます。

```elixir:mix.exs
defmodule MakeTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :make_test,
      version: "0.1.0",
      elixir: "~> 1.10",
      compilers: [:elixir_make] ++ Mix.compilers,
      start_permanent: Mix.env() == :prod,
      make_makefile: "path/to/Makefile", # ← ここに Makefile へのパスを記述する
      deps: deps()
    ]
  end

  ...

end
```

`Application.app_dir` を使って指定したい場合ですが，この中に `Application.app_dir` を記述しても見つからない (アプリケーションが読み込まれる前なので) ため，例えば `Application.app_dir(:app, "priv/Makefile")` としたい場合には， `make_makefile: "_build/#{Mix.env()}/lib/app/priv/Makefile"` とします。

```elixir:mix.exs
defmodule MakeTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :make_test,
      version: "0.1.0",
      elixir: "~> 1.10",
      compilers: [:elixir_make] ++ Mix.compilers,
      start_permanent: Mix.env() == :prod,
      make_makefile: "_build/#{Mix.env()}/lib/app/priv/Makefile", # ← app にアプリケーション名を入れる
      deps: deps()
    ]
  end

  ...

end
```

# 追記

`_build/$(MIX_TARGET)_dev/lib/$(app)` は次のように書くと少しスッキリします。

`#{Mix.Project.build_path()}/lib/$(app)`

```elixir:mix.exs
defmodule MakeTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :make_test,
      version: "0.1.0",
      elixir: "~> 1.10",
      compilers: [:elixir_make] ++ Mix.compilers,
      start_permanent: Mix.env() == :prod,
      make_makefile: "#{Mix.Project.build_path()}/lib/app/priv/Makefile", # ← app にアプリケーション名を入れる
      deps: deps()
    ]
  end

  ...

end
```
