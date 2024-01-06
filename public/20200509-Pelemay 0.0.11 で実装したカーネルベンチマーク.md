---
title: Pelemay 0.0.11 で実装したカーネルベンチマーク
tags:
  - Elixir
  - Nerves
  - Pelemay
private: false
updated_at: '2020-05-09T14:47:05+09:00'
id: 892d8dbf54dd9ad8eab7
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
Pelemay 0.0.11 をリリースしました。

https://github.com/zeam-vm/pelemay/releases/tag/v0.0.11

> [New feature] Extract calculation kernel
> [New feature] `mix pelemay.bench` and `mix pelemay.nerves.bench`
> [Bug fix] Suppress error logs in case of mix test on Pelemay app

計算カーネルを分離し，`mix pelemay.bench` および `mix pelemay.nerves.bench` でカーネルの実行時間を計測して最小二乗法で出力することができます。

# x86での実行例

例えば `mix new np` の後，次のようなコードを書きます。

```elixir:mix.exs
defmodule Np.MixProject do
  use Mix.Project

  def project do
    [
      app: :np,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:pelemay, "~> 0.0.11"}
    ]
  end
end
```

```elixir:lib/np.ex
defmodule Np do
  require Pelemay
  import Pelemay

  defpelemay do
    def map_mult_2(list) do
      list |> Enum.map(& &1 * 2)
    end
  end
end
```

ここで，`mix pelemay.bench Np` を実行すると，次のような出力結果が得られます。

```elixir
[
  [
    function: :map_elem1_mult_2_nif_driver_lsm_double,
    result: [r: 0.9918441034780148, a: 0.2963925671873642, b: 20.96983422139911]
  ],
  [
    function: :map_elem1_mult_2_nif_driver_lsm_i64,
    result: [
      r: 0.9896871109828315,
      a: 0.30485363074644567,
      b: 22.47533563729091
    ]
  ]
]
```

Clang もしくは x86 アーキテクチャで動作させた時には，$t$ を所用クロック数，$n$ をリスト長とした時に，$t = an + b$ で表されるクロック数かかるということになります。(rは相関係数)

# Nerves (target) での動作例

`mix nerves.new np` とした後，


```elixir:mix.exs
...
  defp deps do
    [
      # Dependencies for all targets
      ...
      {:pelemay, "~> 0.0.11"},
      ...
    ]
  end
...
```


```elixir:lib/np.ex
defmodule Np do
  require Pelemay
  import Pelemay

  defpelemay do
    def map_mult_2(list) do
      list |> Enum.map(& &1 * 2)
    end
  end
end
```

ここで，`mix firmware`, `mix burn` もしくは `./upload.sh` とします。

さらに，`mix pelemay.nerves.bench Np` を実行すると，次のような出力結果が得られます。

```elixir
[
  [
    function: :map_elem1_mult_2_nif_driver_lsm_double,
    result: [
      r: 0.9999701332269993,
      a: 15.135247668929917,
      b: 296.24489268939215
    ]
  ],
  [
    function: :map_elem1_mult_2_nif_driver_lsm_i64,
    result: [r: 0.9999544021113032, a: 6.791865425419216, b: 296.8161688166135]
  ]
]
```

GCC かつ Linux かつ x86 アーキテクチャでないプロセッサで動作させた時には，$t$ を所用時間(ns)，$n$ をリスト長とした時に，$t = an + b$ で表される時間かかるということになります。(rは相関係数)

バージョン 0.0.10 から 0.0.11 の変更点はこちらです。

https://github.com/zeam-vm/pelemay/compare/v0.0.10...v0.0.11

取り急ぎ，こんなところで。
