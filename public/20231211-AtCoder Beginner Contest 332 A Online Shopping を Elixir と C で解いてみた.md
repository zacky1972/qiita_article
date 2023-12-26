---
title: AtCoder Beginner Contest 332 A Online Shopping を Elixir と C で解いてみた
tags:
  - C
  - AtCoder
  - Elixir
private: false
updated_at: '2023-12-11T17:11:37+09:00'
id: 61f8dcefc71cb6d0117b
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
AtCoder Beginner Contest 332 A Online Shopping を Elixir と C で解いてみたので，ご報告します．

## アルゴリズムの解説

アルゴリズムはごく単純です．

1. $\Sigma_i^n P_i Q_i$ を求める
2. 1の値が$s$以上であれば，1の値をそのまま出力し，$s$未満であるならば，1の値に$k$を足した値を表示する

## Cでの解答

https://atcoder.jp/contests/abc332/submissions/48423359

```c
#include <stdio.h>
#include <stdint.h>

int main()
{
  int n, s, k;
  int d1 = scanf("%d", &n);
  int d2 = scanf("%d", &s);
  int d3 = scanf("%d", &k);
  
  uint64_t a = 0;
  for(int i = 0; i < n; i++) {
    uint64_t p, q;
    int d4 = scanf("%lu", &p);
    int d5 = scanf("%lu", &q);
    a += p * q;
  }
  
  a = (a >= s) ? a : (a + k);
  
  printf("%lu\n", a);
}
```

ポイントとしては，$i$番目の行の値 $P_i, Q_i$ を読み込んだら，即座に積和を行ない，入力した値を配列として記憶することはしないという点です．これにより，計算時間を1ミリ秒以下に，メモリ消費量もごく最小限にすることができます．

## Elixirでの解答(Stream)

https://atcoder.jp/contests/abc332/submissions/48423119

```elixir
defmodule Main do
  @bl 65536

  def main() do
    [n, s, k] = 
      IO.read(:line)
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      
    IO.stream(:stdio, @bl)
    |> Stream.transform({[], "", n}, &st/2)
    |> Stream.transform({0}, &s1/2)
    |> Enum.at(-1)
    |> then(& if &1 >= s, do: &1, else: &1 + k)
    |> IO.puts()
  end
  
  defp s1([p, q], {acc}) do
    acc = acc + p * q
    
    {[acc], {acc}}
  end
  
  defp st(_h, {l1, l2, 0}), do: {:halt, {l1, l2, 0}}
  
  defp st(h, {l1, l2, n}) when n > 0 do
    h = Enum.join(l1 ++ ["#{l2}#{h}"], " ")
    
    if String.match?(h, ~r/\n/) do
      l = String.split(h, "\n")
      c = Enum.count(l)

      last = 
        Enum.take(l, -1) 
        |> hd()

      l = 
        Enum.take(l, c - 1)
        |> Enum.map(&String.split(&1, " "))
        |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)

      n = n - (c - 1)
      
      if String.match?(last, ~r/ /) do
        l1 = String.split(last, " ")
        c = Enum.count(l1)
        l2 = (Enum.take(l1, -1) |> hd())
        l1 = Enum.take(l1, c - 1)
        {l, {l1, l2, n}}
      else
        {l, {[], last, n}}
      end
    else
      {[], {l1, h, n}}
    end
  end
end
```

以前の記事(下記)で開発した，Streamを使って各行の値を読み込む方法を再利用しています．

https://qiita.com/zacky1972/items/810a7e8567dbd1688ae3

Streamを使って積和を累積する方法は，`Stream.transform`関数に`s1`関数を与え，得られるリストの最後の要素を`Enum.at(-1)`として取り出すことで実現します．

結果として，実行時間を800ミリ秒以下に，メモリ消費を160MB前後に抑えることができました．

## Elixirでの解答(GeekMasahiroさんのテンプレート使用)

GeekMasahiroさんの下記のテンプレートを使用してみました．

https://qiita.com/GeekMasahiro/items/ab5e3fdc9488e6bb4e72


https://atcoder.jp/contests/abc332/submissions/48423970

```elixir
defmodule Main do
  def next_token(acc \\ "") do
    case IO.getn(:stdio, "", 1) do
      " " -> acc
      "\n" -> acc
      x -> next_token(acc <> x)
    end
  end
  
  def input(), do: IO.read(:line) |> String.trim()
  
  def ii(), do: next_token() |> String.to_integer()
  
  def li(), do: input() |> String.split(" ") |> Enum.map(&String.to_integer/1)
  
  def main() do
    n = ii()
    s = ii()
    k = ii()
    
    1..n
    |> Enum.reduce(0, fn _, acc -> 
      [p, q] = li()
      
      acc + p * q
    end)
    |> then(& if &1 >= s, do: &1, else: &1 + k)
    |> IO.puts()
  end
end    
```

とてもシンプルに，Stream版と同等の性能を出せました．

