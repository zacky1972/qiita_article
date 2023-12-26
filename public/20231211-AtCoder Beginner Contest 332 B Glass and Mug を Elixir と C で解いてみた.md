---
title: AtCoder Beginner Contest 332 B Glass and Mug を Elixir と C で解いてみた
tags:
  - C
  - AtCoder
  - Elixir
private: false
updated_at: '2023-12-11T20:20:36+09:00'
id: 183cb818403aacbef9ec
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
AtCoder Beginner Contest 332 B Glass and Mug を Elixir と C で解いてみたので，ご報告します．

## アルゴリズムの解説

アルゴリズムはごく単純で，問題に書かれている通りに組んだだけです．

Cの場合にはループにしたのですが，1点，注意点があって，グラスとマグの更新の順番に気をつける必要があります．まずい更新の順序だと，正しい結果を得られなくなります．

Elixirの場合には，素直に再帰で解きました．Elixir向きの問題だと思います．

## Cでの解答

https://atcoder.jp/contests/abc332/submissions/48427429

```c
#include <stdio.h>

int main()
{
  int k, g, m;
  int d1 = scanf("%d", &k);
  int d2 = scanf("%d", &g);
  int d3 = scanf("%d", &m);
  
  int p = 0, q = 0;
  for(int i = 0; i < k; i++) {
    if (p == g) {
      p = 0;
    } else if (q == 0) {
      q = m;
    } else if (g - p >= q) {
      p += q;
      q = 0;
    } else {
      q -= (g - p);
      p = g;
    }
  }
  printf("%d %d\n", p, q);
}
```

## Elixirでの解答

https://atcoder.jp/contests/abc332/submissions/48427107

```elixir
defmodule Main do
  def main() do
    [k, g, m] =
      IO.read(:line)
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    
    solve({k, g, m}, {0, 0})
    |> Enum.join(" ")
    |> IO.puts()
  end
  
  def solve({0, _, _}, {p, q}), do: [p, q]
  
  def solve({k, g, m}, {g, q}) do
    solve({k - 1, g, m}, {0, q})
  end
  
  def solve({k, g, m}, {p, 0}) do
    solve({k - 1, g, m}, {p, m})
  end
  
  def solve({k, g, m}, {p, q}) when g - p >= q do
    solve({k - 1, g, m}, {p + q, 0})
  end
  
  def solve({k, g, m}, {p, q}) do
    solve({k - 1, g, m}, {g, q - (g - p)})
  end
end    
```

