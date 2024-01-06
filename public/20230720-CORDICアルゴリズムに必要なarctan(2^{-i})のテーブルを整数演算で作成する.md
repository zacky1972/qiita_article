---
title: 'CORDICアルゴリズムに必要なarctan(2^{-i})のテーブルを整数演算で作成する'
tags:
  - Elixir
  - 三角関数
  - CORDIC
private: false
updated_at: '2023-07-20T07:23:01+09:00'
id: b62baa0d74221ad51fb8
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
前回の記事ではCORDICアルゴリズムで三角関数を求めたのですが，定数として$\arctan 2^{-i}$の表が必要になりますので，本記事では$\arctan 2^{-i}$の表の計算をElixirで記述しました．

https://qiita.com/zacky1972/items/ee14dc7ae4bfe941119e

ソースコードは下記です．

https://github.com/zacky1972/nx_atan_table

実装にあたり，下記の公式集を参考にしました．

https://円周率.jp/formula/arctan.html

## 実装の方針

下記のTaylor展開式を用います．

$$\arctan\frac{1}{n} = \sum_{k=0}^{\infty}\frac{(-1)^k}{2k+1}\frac{1}{n^{2k+1}}=\frac{1}{n}-\frac{1}{3}\frac{1}{n^3}+\frac{1}{5}\frac{1}{n^5}-\frac{1}{7}\frac{1}{n^7}+\cdots$$

$n$が小さい時には収束が遅いので，下記の公式を使います．

$$\arctan 1 = 12\arctan\frac{1}{49} + 32\arctan\frac{1}{57} - 5\arctan\frac{1}{239} + 12\arctan\frac{1}{110443}$$

$$\arctan\frac{1}{2} = \arctan\frac{1}{3} + \arctan\frac{1}{7}$$

$$\arctan\frac{1}{3} = \arctan\frac{1}{5} + \arctan\frac{1}{8}$$

$$\arctan\frac{1}{7} = \arctan\frac{1}{8} + \arctan\frac{1}{57}$$

$$\arctan\frac{1}{57} = \arctan\frac{1}{32} - \arctan\frac{1}{73}$$

また次の式も用います．

$$\lim_{i \rightarrow 0}\arctan \frac{1}{i} = \frac{\pi}{2} = 2\arctan 1$$

$$ \lim_{i \rightarrow \infty}\arctan \frac{1}{i} = \arctan 0 = 0 $$

## 実装

$0 \leq x \leq 1$ の実数を`n`ビットの固定小数点数表記として，$2^{n-2}$を乗じて表現します．

まず全体をGenServerで構成してキャッシュを形成します．

```elixir
defmodule NxAtanTable do
  use GenServer

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  def start_link(initial_state \\ %{}) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  @impl true
  def handle_call({:atan_of_reciprocal, n, b}, _from, state) do
    cache_atan_of_reciprocal({n, b}, state, Map.get(state, {n, b}))
  end

  def atan_of_reciprocal(n, b), do: GenServer.call(__MODULE__, {:atan_of_reciprocal, n, b})

  defp cache_atan_of_reciprocal({n, b}, state, nil) do
    r = atan_of_reciprocal_s(n, state, b)
    {:reply, r, Map.put(state, {n, b}, r)}
  end

  defp cache_atan_of_reciprocal(_, state, r) do
    {:reply, r, state}
  end
```

表の生成は次のように`Stream.unfold`と`Stream.map`，`Enum.reverse`を用います．

```elixir
  def table(n, b) do
    Stream.unfold(n, fn
      0 -> nil
      n -> {n - 1, n - 1}
    end)
    |> Stream.map(fn n -> Bitwise.bsl(1, n) end)
    |> Stream.map(&atan_of_reciprocal(&1, b))
    |> Enum.reverse()
    |> Nx.tensor(type: {:s, b})
  end
```

前述のTaylor展開式は次のように`Stream.unfold`と`Enum.reduce`で実装します．

```elixir
  defp atan_of_reciprocal_s(n, _state, bit) when n > 0 and n < Bitwise.bsl(1, bit - 1) do
    n2 = n * n

    Stream.unfold({0, 0, n, Bitwise.bsl(1, bit - 2), bit, n2}, &atan_of_reciprocal_body/1)
    |> Enum.reduce(fn
      {_, a, _, _, _, _}, _acc -> a
    end)
  end

  defp atan_of_reciprocal_body({k, a, b, c, bit, n2}) do
    if c > 0 do
      c = div(Bitwise.bsl(1, bit - 2), b * (Bitwise.bsl(k, 1) + 1))
      b = b * n2

      a =
        case Bitwise.band(k, 1) do
          0 -> a + c
          1 -> a - c
        end

      {
        {k + 1, a, b, c, bit, n2},
        {k + 1, a, b, c, bit, n2}
      }
    end
  end
```

あとは前述の公式に沿って，関数パターンマッチで`atan_of_reciprocal_s`を実装していきます．

```elixir
  defp atan_of_reciprocal_s(0, state, b) do
    {:reply, r1, _state} = cache_atan_of_reciprocal({1, b}, state, Map.get(state, {1, b}))
    Bitwise.bsl(r1, 1)
  end

  defp atan_of_reciprocal_s(1, state, b) do
    {:reply, r1, state} = cache_atan_of_reciprocal({49, b}, state, Map.get(state, {49, b}))
    {:reply, r2, state} = cache_atan_of_reciprocal({57, b}, state, Map.get(state, {57, b}))
    {:reply, r3, state} = cache_atan_of_reciprocal({239, b}, state, Map.get(state, {239, b}))

    {:reply, r4, _state} =
      cache_atan_of_reciprocal({110_443, b}, state, Map.get(state, {110_443, b}))

    12 * r1 + 32 * r2 - 5 * r3 + 12 * r4
  end

  defp atan_of_reciprocal_s(2, state, b) do
    {:reply, r1, state} = cache_atan_of_reciprocal({3, b}, state, Map.get(state, {3, b}))
    {:reply, r2, _state} = cache_atan_of_reciprocal({7, b}, state, Map.get(state, {7, b}))
    r1 + r2
  end

  defp atan_of_reciprocal_s(3, state, b) do
    {:reply, r1, state} = cache_atan_of_reciprocal({5, b}, state, Map.get(state, {5, b}))
    {:reply, r2, _state} = cache_atan_of_reciprocal({8, b}, state, Map.get(state, {8, b}))
    r1 + r2
  end

  defp atan_of_reciprocal_s(7, state, b) do
    {:reply, r1, state} = cache_atan_of_reciprocal({8, b}, state, Map.get(state, {8, b}))
    {:reply, r2, _state} = cache_atan_of_reciprocal({57, b}, state, Map.get(state, {57, b}))
    r1 + r2
  end

  defp atan_of_reciprocal_s(57, state, b) do
    {:reply, r1, state} = cache_atan_of_reciprocal({32, b}, state, Map.get(state, {32, b}))
    {:reply, r2, _state} = cache_atan_of_reciprocal({73, b}, state, Map.get(state, {73, b}))
    r1 - r2
  end

  defp atan_of_reciprocal_s(n, _state, bit) when n > 0 and n < Bitwise.bsl(1, bit - 1) do
    n2 = n * n

    Stream.unfold({0, 0, n, Bitwise.bsl(1, bit - 2), bit, n2}, &atan_of_reciprocal_body/1)
    |> Enum.reduce(fn
      {_, a, _, _, _, _}, _acc -> a
    end)
  end

  defp atan_of_reciprocal_s(n, _state, bit) when n >= Bitwise.bsl(1, bit - 1) do
    0
  end
```

最初に実装する時には浮動小数点数表記で動くものを作ってから固定小数点数表記に少しずつ改めていきました．
