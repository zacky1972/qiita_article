---
title: AtCoder Beginner Contest 332 C T-shirts を Elixir と C で解いてみた
tags:
  - C
  - AtCoder
  - Elixir
private: false
updated_at: '2023-12-12T15:39:12+09:00'
id: 40b738408520362624ae
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
AtCoder Beginner Contest 332 C T-shirts を Elixir と C で解いてみたので，ご報告します．

## アルゴリズムの解説

1. 変数$a, b, c, d$を用意します．$a$は洗濯された無地のTシャツの数，$b$は洗濯されたロゴ入りTシャツのストック数，$c$は着用済みの無地のTシャツの数，$d$は着用済みのロゴ入りTシャツの数です．
2. 初期値として，$a = m$とし，$b = c = d = 0$とします．
3. 文字列を先頭から順番に走査します．
    * '0'の時: 洗濯するので，$a = a + c$, $b = b + d$, $c = 0$, $d = 0$とします． 
    * '1'の時:
        * $a = b = 0$の時: ロゴ入りのTシャツを購入して着るので，$d = d + 1$とします．
        * そうでなくて$a = 0$の時: 洗濯されたロゴ入りのTシャツのストックを着るので，$b = b - 1$. $d = d + 1$とします．
        * そうでない場合: 洗濯された無地のTシャツを着るので，$a = a - 1$, $c = c + 1$とします．
    * '2'の時:
        * $b = 0$の時: ロゴ入りのTシャツを購入して着るので，$d = d + 1$とします．
        * そうでない場合: 洗濯されたロゴ入りのTシャツのストックを着るので，$b = b - 1$, $d = d + 1$とします．
4. 最後に$b + d$を表示します．

## Elixirでの解答

https://atcoder.jp/contests/abc332/submissions/48441471

文字列はあらかじめタプルにしておきます．関数パターンマッチと`Enum.reduce`で素直に実装できます．

```elixir
defmodule Main do
  @zero "0" |> String.to_charlist() |> hd()
  @one "1" |> String.to_charlist() |> hd()
  @two "2" |> String.to_charlist() |> hd()
  
  def main() do
    [n, m] =
      IO.read(:line)
      |> String.trim()
      |> String.split()
      |> Enum.map(&String.to_integer/1)
      
    s = 
      IO.read(:line)
      |> String.trim()
      |> String.to_charlist()
      |> Enum.map(fn
        @zero -> 0
        @one -> 1
        @two -> 2
      end)
      |> List.to_tuple()
      
    0..n-1
    |> Enum.reduce({m, 0, 0, 0}, fn i, acc -> plan(s, i, acc) end)
    |> then(&elem(&1, 1) + elem(&1, 3))
    |> IO.puts()
  end
  
  defp plan(s, i, state), do: plan(elem(s, i), state)
  
  defp plan(0, {m, l, wm, wl}) do
    {m + wm, l + wl, 0, 0}
  end
  
  defp plan(1, {0, 0, wm, wl}) do
    {0, 0, wm, wl + 1} 
  end
  
  defp plan(1, {0, l, wm, wl}) do
    {0, l - 1, wm, wl + 1}
  end

  defp plan(1, {m, l, wm, wl}) do
    {m - 1, l, wm + 1, wl}
  end
  
  defp plan(2, {m, 0, wm, wl}) do
    {m, 0, wm, wl + 1}
  end
  
  defp plan(2, {m, l, wm, wl}) do
    {m, l - 1, wm, wl + 1}
  end
end
```

## Cでの解答

https://atcoder.jp/contests/abc332/submissions/48441846

```c
#include <stdio.h>

int main()
{
  int n, m;
  int d1 = scanf("%d", &n);
  int d2 = scanf("%d", &m);
  
  char s[1001];
  int d3 = scanf("%s", &s);
  
  int a = m, b = 0, c = 0, d = 0;
  
  for (int i = 0; i < n; i++) {
    switch (s[i]) {
      case '0':
        a += c;
        b += d;
        c = 0;
        d = 0;
        break;
      case '1':
        if (a == 0 && b == 0) {
          d++;
        } else if (a == 0) {
          b--;
          d++;
        } else {
          a--;
          c++;
        }
        break;
      case '2':
        if (b == 0) {
          d++;
        } else {
          b--;
          d++;
        }
        break;
      default:
    }
  }
  printf("%d\n", b + d);
}
```

