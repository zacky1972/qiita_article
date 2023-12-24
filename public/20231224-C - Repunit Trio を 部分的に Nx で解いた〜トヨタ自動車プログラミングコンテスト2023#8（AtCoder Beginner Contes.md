---
title: >-
  C - Repunit Trio を 部分的に Nx で解いた〜トヨタ自動車プログラミングコンテスト2023#8（AtCoder Beginner
  Contest 333）
tags:
  - AtCoder
  - Elixir
  - nx
private: false
updated_at: '2023-12-24T18:31:09+09:00'
id: 3b09269ad4e7709df7ca
organization_url_name: null
slide: false
ignorePublish: false
---
トヨタ自動車プログラミングコンテスト2023#8（AtCoder Beginner Contest 333）の C - Repunit Trio を部分的にNxを用いて解いたので報告します．

## 問題

https://atcoder.jp/contests/abc333/tasks/abc333_c

## 部分的にNxを用いた解答例

https://atcoder.jp/contests/abc333/submissions/48822235

```elixir
defmodule Main do
  import Nx.Defn

  @s64_max Bitwise.bsl(1, 63) - 1

  def main() do
    n =
      IO.read(:line)
      |> String.trim()
      |> String.to_integer()

    a =
      0..333
      |> Stream.map(fn n -> repunit(n) end)
      |> Enum.take_while(& &1 <= @s64_max)

    t =
      a
      |> Enum.map(fn x ->
        a
        |> Enum.map(fn y ->
          a
          |> Enum.map(fn z ->
            x + y + z
          end)
        end)
      end)
      |> Nx.tensor(type: {:s, 64})

    1..n
    |> Enum.reduce(0, fn _, acc ->
      reduce_min_greater_than_n(t, acc, @s64_max)
    end)
    |> Nx.to_number()
    |> IO.puts()
  end

  def repunit(0), do: 1
  def repunit(n) when n > 0, do: 1 + 10 * repunit(n - 1)

  defn reduce_min_greater_than_n(t1, t2, t3) do
    t3 = Nx.multiply(Nx.less_equal(t1, t2), t3)
    t1 = Nx.multiply(Nx.greater(t1, t2), t1)
    Nx.add(t1, t3) |> Nx.reduce_min()
  end
end
```

考えられる全てのRepunit trioを求め，`Enum.reduce`と`reduce_min_greater_than_n`で小さいものから順に取り出すというアルゴリズムです．

`reduce_min_greater_than_n`は，次のようなロジックです．

1. 第1引数`t1`のテンソルで，第2引数`t2`の値より小さいものを，第3引数`t3`で置き換えて，それ以外はそのままにする
2. 1に`Nx.reduce_min`を適用して，テンソル中の最小の値を取り出す

1を実現する方法は，Nxでは割とお決まりのパターンです．

