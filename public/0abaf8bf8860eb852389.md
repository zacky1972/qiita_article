---
title: Elixir のドキュメント ex_doc で数式を表示したい
tags:
  - Elixir
private: false
updated_at: '2021-09-12T10:56:38+09:00'
id: 0abaf8bf8860eb852389
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
今日は，Elixirの作者 José Valim に教わった「Elixirのドキュメント `ex_doc` で数式を表示する方法」をお話ししたいと思います。

手順

1. プロジェクトを作る
1. `mix.exs`を修正して`ex_doc` をインストールする
1. KaTeXの設定を `mix.exs` に追記する
1. 数式を入れたい部分のドキュメント開始部分の `@doc """`を `@doc ~S"""`にする
1. ドキュメント中に数式を書く
1. `mix docs` を実行し， `doc/index.html` をブラウザで開いて確認する

GitHub にサンプルを置きました。

https://github.com/zacky1972/doc_math/

では行ってみましょう。

# 1. プロジェクトを作る

`mix new (プロジェクト名)` を使ってプロジェクトを作ります。

ここでは仮に `mix new doc_math` としておきます。

この後は，`cd doc_math` として，プロジェクトのディレクトリで作業します。

# 2. `mix.exs`を修正して`ex_doc` をインストールする

下記にしたがって，`mix.exs` を変更します。

https://github.com/elixir-lang/ex_doc#using-exdoc-with-mix

`mix.exs` で指定している Elixir のバージョンによって異なります。Elixirのバージョン指定は `def project do ... end` の項目の中の `elixir: "~> (version番号)"` で書かれています。

私の場合には，Elixir 1.10 以降のバージョンだったので，下記のようにしました。

```elixir
def deps do
  [
    {:ex_doc, "~> 0.24", only: :dev, runtime: false},
  ]
end
```

その後，`mix deps.get` します。

ちなみに他のバージョンの場合に動作するかどうかは試しておりませんので，試してみてどうだったか報告してくれると助かります。

# 3. KaTeXの設定を `mix.exs` に追記する

次のように `mix.exs` を書き換えていきます。

```elixir
defmodule DocMath.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/zacky1972/doc_math"

  def project do
    [
      app: :doc_math,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "DocMath",
      source_ref: "v#{@version}",
      source_url: @source_url,
      before_closing_body_tag: &before_closing_body_tag/1
    ]
  end

  defp before_closing_body_tag(:html) do
    """
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.13.0/dist/katex.min.css" integrity="sha384-t5CR+zwDAROtph0PXGte6ia8heboACF9R5l/DiY+WZ3P2lxNgvJkQk5n7GPvLMYw" crossorigin="anonymous">
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.13.0/dist/katex.min.js" integrity="sha384-FaFLTlohFghEIZkw6VGwmf9ISTubWAVYW8tG8+w2LAIftJEULZABrF9PPFv+tVkH" crossorigin="anonymous"></script>
    <script defer src="https://cdn.jsdelivr.net/npm/katex@0.13.0/dist/contrib/auto-render.min.js" integrity="sha384-bHBqxz8fokvgoJ/sc17HODNxa42TlaEhB+w8ZJXTc2nZf1VgEaFZeZvT4Mznfz0v" crossorigin="anonymous"
        onload="renderMathInElement(document.body);"></script>
    """
  end

  defp before_closing_body_tag(_), do: ""
end
```

要点を次に述べます。

* 冒頭に `@version` として，このプロジェクト(ここでは `doc_math`) のバージョン番号を入れます。Elixirの流儀では，初期バージョンでは `"0.1.0"` です。
* 次に `@source_url` として，このプロジェクト(ここでは `doc_math`) の GitHub URL を入れます。
* `def project do ... end` の `version: (バージョン番号)` のバージョン番号の部分を `@version` と書き換えます。
* `def project do ... end` に `docs: docs()` という記述を足します。順番はこの中であればどこでも良いです。
* `defp docs do ... end` の記述を足します。
    * `main:` には，このプロジェクト名をCamel Caseで書きます。ここでは `DocMath` と書きます。
    * `source_ref: "v#{@version}"` とします。これでドキュメントとソースコードのバージョン番号が同期します。
    * `source_url: @source_url` とします。
    * そして，**ここが肝ですが** `before_closing_body_tag: &before_closing_body_tag/1` とします。
* **ここも肝ですが** `defp before_closing_body_tag(:html) do ... end` を足します。
    * この部分は KaTeX をインストールしています。差し当たりコピペして入力してください。
* その後，`defp before_closing_body_tag(_), do: ""` とします。

# 4. 数式を入れたい部分のドキュメント開始部分の `@doc """`を `@doc ~S"""`にする

`lib` 以下のElixirソースコード，たとえば `lib/doc_math.ex` を開きます。

数式を入れたい部分のドキュメント開始部分の `@doc """` を `@doc ~S"""` にします。

たとえば次のような感じです。

```elixir
defmodule DocMath do
  @moduledoc """
  Documentation for `DocMath`.
  """

  @doc ~S"""
  Hello world.

  ## Examples

      iex> DocMath.hello()
      :world

  """
  def hello do
    :world
  end
end
```

※同様の方法で，`@moduledoc` を変えることもできます。

# 5. ドキュメント中に数式を書く

ドキュメント中に `$$ (数式のLaTeX表現) $$` と記述すると数式が入れられます。

例として三角関数`sin`のマクローリン展開の公式を入れてみました。

```elixir
defmodule DocMath do
  @moduledoc """
  Documentation for `DocMath`.
  """

  @doc ~S"""
  Hello world.

  $$sin x = x - \dfrac{1}{3!}x^3 + \dfrac{1}{5!}x^5 - \dfrac{1}{7!}x^7 + \cdots $$

  ## Examples

      iex> DocMath.hello()
      :world

  """
  def hello do
    :world
  end
end
```

# 6. `mix docs` を実行し， `doc/index.html` をブラウザで開いて確認する

後は，`mix docs`を実行して， `doc/index.html` をブラウザで開いてください。

![DocMath.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/31b90c2b-e2bb-9bb9-5e60-addde64f0d7b.png)

やったぜ！

