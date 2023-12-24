---
title: B - Christmas TreesをElixirで解いた〜ユニークビジョンプログラミングコンテスト2023 クリスマス (AtCoder Beginner Contest 334)
tags:
  - AtCoder
  - Elixir
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
ユニークビジョンプログラミングコンテスト2023 クリスマス (AtCoder Beginner Contest 334)の B - Christmas Trees をElixirで解いたので，報告します．

## 問題

https://atcoder.jp/contests/abc334/tasks/abc334_b

## 最終的な解答例

https://atcoder.jp/contests/abc334/submissions/48810731

```elixir
defmodule Main do
  def main() do
    [a, m, l, r] =
      IO.read(:line)
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

  IO.puts(Integer.floor_div(r - a, m) - Integer.floor_div(l - 1 - a, m))
  end
end
```

[`Integer.floor_div/2`](https://hexdocs.pm/elixir/1.16.0/Integer.html#floor_div/2)という便利関数があったので，それを使用したら，こんなに簡潔なコードになりました．

`Enum.map(l..r, fn x -> Integer.floor_div(x - a, m) end)`として，プロットしてみると，動きがわかるのではないかと思います．

## １つ前の解答例

https://atcoder.jp/contests/abc334/submissions/48810596

```elixir
defmodule Main do
  def main() do
    [a, m, l, r] =
      IO.read(:line)
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    first_tree_pos = 
      case rem(l - a, m) do
        0 -> l
        rm when rm < 0 -> l - rm
        rm -> l + m - rm
      end  

    last_tree_pos =
      case rem(r - a, m) do
        0 -> r
        rm when rm < 0 -> r - rm - m
        rm -> r - rm
      end

  IO.puts(div(last_tree_pos - first_tree_pos, m) + 1)
  end
end
```

$L$に最も近い木の位置を`first_tree_pos`とします．同様に$R$に最も近い木の位置を`last_tree_pos`とします．`last_tree_pos - first_tree_pos`を`m`で割り，1を加えると，木の本数になります．

`rem/2`関数と`case`文を使ってそれぞれ求めます．`rem`関数は，あまりを求める関数ですが，負の値を割るときに結果も負になるという特性がありますので，注意が必要です．0の場合，正の場合，負の場合で場合わけをします．

## 素朴な解答例

https://atcoder.jp/contests/abc334/submissions/48810216

```elixir
defmodule Main do
  def main() do
    [a, m, l, r] =
      IO.read(:line)
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    l..r
    |> Enum.count(fn x ->
      rem(x - a, m) == 0
    end)
    |> IO.puts()
  end
end
```

愚直に範囲`l..r`の中で，`rem(x - a, m) == 0`となる数を数え上げています．TLE(実行時間制限超過)となりました．

## 素朴な解答の改良例

https://atcoder.jp/contests/abc334/submissions/48810360

```elixir
defmodule Main do
  def main() do
    [a, m, l, r] =
      IO.read(:line)
      |> String.trim()
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    [first_tree_pos] =
      Stream.unfold(l, fn x -> {x, x + 1} end)
      |> Stream.drop_while(fn x -> rem(x - a, m) != 0 end)
      |> Enum.take(1)

   [last_tree_pos] =
     Stream.unfold(r, fn x -> {x, x - 1} end)
     |> Stream.drop_while(fn x -> rem(x - a, m) != 0 end)
     |> Enum.take(1)

  IO.puts(div(last_tree_pos - first_tree_pos, m) + 1)
  end
end
```

$L$に最も近い木の位置を`first_tree_pos`とします．同様に$R$に最も近い木の位置を`last_tree_pos`とします．`last_tree_pos - first_tree_pos`を`m`で割り，1を加えると，木の本数になります．

`first_tree_pos`と`last_tree_pos`は地道に数え上げています．[`Stream.unfold/2`](https://hexdocs.pm/elixir/1.16.0/Stream.html#unfold/2)を使いました．

これでもまだTLE(実行時間制限超過)となりました．

