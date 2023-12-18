---
title: >-
  アルゴリズム編: B - Minimize Abs 1 を Elixir で解いた〜トヨタシステムズプログラミングコンテスト2023(AtCoder
  Beginner Contest 330)
tags:
  - AtCoder
  - Elixir
private: true
updated_at: '2023-12-18T19:12:16+09:00'
id: da168a93427d173ea057
organization_url_name: null
slide: false
ignorePublish: false
---
トヨタシステムズプログラミングコンテスト2023(AtCoder Beginner Contest 330)の B - Minimize Abs 1 を Elixir で解きましたので，ご報告します．

## 問題

https://atcoder.jp/contests/abc330/tasks/abc330_b

## 簡易ローカルテスト環境の構築

次のようなMakefileを書きました．

```make:Makefile
.phony: all clean

test: test_ex

test_ex:
	elixir test.exs < in1.txt | diff - out1.txt
	elixir test.exs < in2.txt | diff - out2.txt
```

```elixir:test.exs
Code.eval_file("main.exs")
Main.main()
```

入力例1を`in1.txt`，出力例1を`out1.txt`のように与え，`main.exs`に解答を書きます．その後，`make`コマンドを実行します．

## アルゴリズム上の工夫$O(n^3)$から　$O(n)$へ

下記のプログラムをもとにアルゴリズム上の工夫を検討します．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      l..r
      |> Enum.map(fn x ->
        b = Enum.reduce(l..r, true, fn y, acc ->
          abs(x - a) <= abs(y - a) and acc
        end)

        {x, b}
      end)
      |> Enum.filter(fn {_, b} -> b end)
      |> Enum.map(fn {x, _} -> x end)
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

まず，絶対値を展開してみましょう．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      l..r
      |> Enum.map(fn x ->
        b = Enum.reduce(l..r, true, fn y, acc ->
          p =
            if x >= a do
              x - a
            else
              a - x
            end

          q =
            if y >= a do
              y - a
            else
              a - y
            end

          p <= q and acc
        end)

        {x, b}
      end)
      |> Enum.filter(fn {_, b} -> b end)
      |> Enum.map(fn {x, _} -> x end)
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

ローカルで実行して，結果が変わらないことを確認します．以後，プログラムを修正するたびに，結果が変わらないことを確認します．

Enum.reduceをEnum.mapとEnum.reduceに分解します．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      l..r
      |> Enum.map(fn x ->
        b =
          l..r
          |> Enum.map(fn y ->
            p =
              if x >= a do
                x - a
              else
                a - x
              end

            {y, p}
          end)
          |> Enum.map(fn {y, p} ->
            q =
              if y >= a do
                y - a
              else
                a - y
              end

            {y, p, q}
          end)
          |> Enum.reduce(true, fn {_y, p, q}, acc ->
            p <= q and acc
          end)

        {x, b}
      end)
      |> Enum.filter(fn {_, b} -> b end)
      |> Enum.map(fn {x, _} -> x end)
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

`p`の計算は`y`と関わりがないので，一つ外のループに出すことができます．このようなコード最適化を「ループ不変式の削除」といいます．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      l..r
      |> Enum.map(fn x ->
        p =
          if x >= a do
            x - a
          else
            a - x
          end

        b =
          l..r
          |> Enum.map(fn y ->
            q =
              if y >= a do
                y - a
              else
                a - y
              end

            {y, q}
          end)
          |> Enum.reduce(true, fn {_y, q}, acc ->
            p <= q and acc
          end)

        {x, b}
      end)
      |> Enum.filter(fn {_, b} -> b end)
      |> Enum.map(fn {x, _} -> x end)
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

いらなくなった変数を削除して綺麗にしましょう．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      l..r
      |> Enum.map(fn x ->
        p =
          if x >= a do
            x - a
          else
            a - x
          end

        b =
          l..r
          |> Enum.map(fn y ->
            if y >= a do
              y - a
            else
              a - y
            end
          end)
          |> Enum.reduce(true, fn q, acc ->
            p <= q and acc
          end)

        {x, b}
      end)
      |> Enum.filter(fn {_, b} -> b end)
      |> Enum.map(fn {x, _} -> x end)
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

絶対値の計算なので，`a`の場合を境にして場合わけをしてみます．

Cで，`if (条件1) {節1} else if (条件2) {節2} else {節3}`のように書く時には，Elixirでは`cond`というものを用います．すなわち，次のように書きます．

```elixir
cond do
  条件1 -> 節1
  条件2 -> 節2
  true -> 節3
end
```

まずは愚直に式を展開します．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l ->
          l..r
          |> Enum.map(fn x ->
            p =
              if x >= a do
                x - a
              else
                a - x
              end

            b =
              l..r
              |> Enum.map(fn y ->
                if y >= a do
                  y - a
                else
                  a - y
                end
              end)
              |> Enum.reduce(true, fn q, acc ->
                p <= q and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)

          a > r ->
            l..r
            |> Enum.map(fn x ->
              p =
                if x >= a do
                  x - a
                else
                  a - x
                end

              b =
                l..r
                |> Enum.map(fn y ->
                  if y >= a do
                    y - a
                  else
                    a - y
                  end
                end)
                |> Enum.reduce(true, fn q, acc ->
                  p <= q and acc
                end)

              {x, b}
            end)
            |> Enum.filter(fn {_, b} -> b end)
            |> Enum.map(fn {x, _} -> x end)

            true ->
              l..r
              |> Enum.map(fn x ->
                p =
                  if x >= a do
                    x - a
                  else
                    a - x
                  end

                b =
                  l..r
                  |> Enum.map(fn y ->
                    if y >= a do
                      y - a
                    else
                      a - y
                    end
                  end)
                  |> Enum.reduce(true, fn q, acc ->
                    p <= q and acc
                  end)

                {x, b}
              end)
              |> Enum.filter(fn {_, b} -> b end)
              |> Enum.map(fn {x, _} -> x end)
        end
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

まず，`a < l`を検討します．`x >= a`と`y >= a`は，それぞれ，常に真になりますので，次のように展開できます．


```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l ->
          l..r
          |> Enum.map(fn x ->
            p = x - a

            b =
              l..r
              |> Enum.map(fn y ->
                y - a
              end)
              |> Enum.reduce(true, fn q, acc ->
                p <= q and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)

        a > r ->
          l..r
          |> Enum.map(fn x ->
            p =
              if x >= a do
                x - a
              else
                a - x
              end

            b =
              l..r
              |> Enum.map(fn y ->
                if y >= a do
                  y - a
                else
                  a - y
                end
              end)
              |> Enum.reduce(true, fn q, acc ->
                p <= q and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)

        true ->
          l..r
          |> Enum.map(fn x ->
            p =
              if x >= a do
                x - a
              else
                a - x
              end

              b =
              l..r
              |> Enum.map(fn y ->
                if y >= a do
                  y - a
                else
                  a - y
                end
              end)
              |> Enum.reduce(true, fn q, acc ->
                p <= q and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)
      end
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

`p`,`q`を展開すると次のようになります．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l ->
          l..r
          |> Enum.map(fn x ->
            b =
              l..r
              |> Enum.reduce(true, fn y, acc ->
                x - a <= y - a and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)

        a > r ->
          l..r
          |> Enum.map(fn x ->
            p =
              if x >= a do
                x - a
              else
                a - x
              end

            b =
              l..r
              |> Enum.map(fn y ->
                if y >= a do
                  y - a
                else
                  a - y
                end
              end)
              |> Enum.reduce(true, fn q, acc ->
                p <= q and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)

        true ->
          l..r
          |> Enum.map(fn x ->
            p =
              if x >= a do
                x - a
              else
                a - x
              end

            b =
              l..r
              |> Enum.map(fn y ->
                if y >= a do
                  y - a
                else
                  a - y
                end
              end)
              |> Enum.reduce(true, fn q, acc ->
                p <= q and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)
      end
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

`x`と`y`の値域を考えると，`x == l`の場合のみ成立しますので，次のように`x`と`y`のループをなくすことができます．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l -> l

        a > r ->
          l..r
          |> Enum.map(fn x ->
            p =
              if x >= a do
                x - a
              else
                a - x
              end

            b =
              l..r
              |> Enum.map(fn y ->
                if y >= a do
                  y - a
                else
                  a - y
                end
              end)
              |> Enum.reduce(true, fn q, acc ->
                p <= q and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)

        true ->
          l..r
          |> Enum.map(fn x ->
            p =
              if x >= a do
                x - a
              else
                a - x
              end

            b =
              l..r
              |> Enum.map(fn y ->
                if y >= a do
                  y - a
                else
                  a - y
                end
              end)
              |> Enum.reduce(true, fn q, acc ->
                p <= q and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)
      end
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

同様に，`a > r`の時には，次のように展開できます．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l -> l

        a > r ->
          l..r
          |> Enum.map(fn x ->
            b =
              l..r
              |> Enum.reduce(true, fn y, acc ->
                a - x <= a - y and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)

        true ->
          l..r
          |> Enum.map(fn x ->
            p =
              if x >= a do
                x - a
              else
                a - x
              end

            b =
              l..r
              |> Enum.map(fn y ->
                if y >= a do
                  y - a
                else
                  a - y
                end
              end)
              |> Enum.reduce(true, fn q, acc ->
                p <= q and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)
      end
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

この条件を満たすのは，`x = r`の時だけですので，次のようになります．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l -> l

        a > r -> r

        true ->
          l..r
          |> Enum.map(fn x ->
            p =
              if x >= a do
                x - a
              else
                a - x
              end

            b =
              l..r
              |> Enum.map(fn y ->
                if y >= a do
                  y - a
                else
                  a - y
                end
              end)
              |> Enum.reduce(true, fn q, acc ->
                p <= q and acc
              end)

            {x, b}
          end)
          |> Enum.filter(fn {_, b} -> b end)
          |> Enum.map(fn {x, _} -> x end)
      end
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

同様に，残りの条件では，`l <= a <= r`です．`l..a`と`a..r`に場合わけし，リストを結合してみたいと思います．リスト`l1`と`l2`の結合は `l1 ++ l2`と書きます．次のように書き換えてみますが，こうすると，`x == a`の時が重複しますので，値が1つ多く出てしまいます．ですが，わかりやすさのために一旦このまま進めます．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l -> l

        a > r -> r

        true ->
          lx1 =
            l..a
            |> Enum.map(fn x ->
              p =
                if x >= a do
                  x - a
                else
                  a - x
                end

              b =
                l..r
                |> Enum.map(fn y ->
                  if y >= a do
                    y - a
                  else
                    a - y
                  end
                end)
                |> Enum.reduce(true, fn q, acc ->
                  p <= q and acc
                end)

              {x, b}
            end)
            |> Enum.filter(fn {_, b} -> b end)
            |> Enum.map(fn {x, _} -> x end)

          lx2 =
            a..r
            |> Enum.map(fn x ->
              p =
                if x >= a do
                  x - a
                else
                  a - x
                end

              b =
                l..r
                |> Enum.map(fn y ->
                  if y >= a do
                    y - a
                  else
                    a - y
                  end
                end)
                |> Enum.reduce(true, fn q, acc ->
                  p <= q and acc
                end)

              {x, b}
            end)
            |> Enum.filter(fn {_, b} -> b end)
            |> Enum.map(fn {x, _} -> x end)

          lx1 ++ lx2
      end
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

`y`についても同様に展開します．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l -> l

        a > r -> r

        true ->
          lx1 =
            l..a
            |> Enum.map(fn x ->
              p =
                if x >= a do
                  x - a
                else
                  a - x
                end

              ly1 =
                l..a
                |> Enum.map(fn y ->
                  if y >= a do
                    y - a
                  else
                    a - y
                  end
                end)

              ly2 =
                a..r
                |> Enum.map(fn y ->
                  if y >= a do
                    y - a
                  else
                    a - y
                  end
                end)

              b =
                Enum.reduce(ly1 ++ ly2, true, fn q, acc ->
                  p <= q and acc
                end)

              {x, b}
            end)
            |> Enum.filter(fn {_, b} -> b end)
            |> Enum.map(fn {x, _} -> x end)

          lx2 =
            a..r
            |> Enum.map(fn x ->
              p =
                if x >= a do
                  x - a
                else
                  a - x
                end

              ly1 =
                l..a
                |> Enum.map(fn y ->
                  if y >= a do
                    y - a
                  else
                    a - y
                  end
                end)

              ly2 =
                a..r
                |> Enum.map(fn y ->
                  if y >= a do
                    y - a
                  else
                    a - y
                  end
                end)

              b =
                Enum.reduce(ly1 ++ ly2, true, fn q, acc ->
                  p <= q and acc
                end)

              {x, b}
            end)
            |> Enum.filter(fn {_, b} -> b end)
            |> Enum.map(fn {x, _} -> x end)

          lx1 ++ lx2
      end
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

それぞれの場合について検討します．

`lx1`と`ly1`の組合せの時，すなわち，$L \leq X_i \leq A_i$かつ$L \leq Y \leq A_i$の時には，全ての$Y$について$|X_i - A_i| \leq |Y - A_i|$を満たすのは，$X_i = A_i$の時のみです．

同様に，`lx1`と`ly2`の組合せの時，すなわち，$L \leq X_i \leq A_i$かつ$A_i \leq Y \leq R$の時には，全ての$Y$について$|X_i - A_i| \leq |Y - A_i|$を満たすのは，$X_i = A_i$の時のみです．

したがって，次のように最適化できます．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l -> l

        a > r -> r

        true ->
          lx1 = [a]

          lx2 =
            a..r
            |> Enum.map(fn x ->
              p =
                if x >= a do
                  x - a
                else
                  a - x
                end

              ly1 =
                l..a
                |> Enum.map(fn y ->
                  if y >= a do
                    y - a
                  else
                    a - y
                  end
                end)

              ly2 =
                a..r
                |> Enum.map(fn y ->
                  if y >= a do
                    y - a
                  else
                    a - y
                  end
                end)

              b =
                Enum.reduce(ly1 ++ ly2, true, fn q, acc ->
                  p <= q and acc
                end)

              {x, b}
            end)
            |> Enum.filter(fn {_, b} -> b end)
            |> Enum.map(fn {x, _} -> x end)

          lx1 ++ lx2
      end
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

同様に，`lx2`の場合も同じことが言えます．したがって，次のようにループを削減できます(値の重複もなくなりました)．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l -> l
        a > r -> r
        true -> a
      end
    end)
    |> List.flatten()
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

`List.flatten/1`はもはや不要です．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      cond do
        a < l -> l
        a > r -> r
        true -> a
      end
    end)
    |> Enum.join(" ")
    |> IO.puts()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

これはとてもシンプルなプログラムですね．計算量も$O(n)$です．下記のように，見事ACできました．

https://atcoder.jp/contests/abc330/submissions/48603780


