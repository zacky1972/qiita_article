---
title: >-
  試行錯誤編: B - Minimize Abs 1 を Elixir で解いた〜トヨタシステムズプログラミングコンテスト2023(AtCoder
  Beginner Contest 330)
tags:
  - AtCoder
  - Elixir
private: true
updated_at: '2023-12-18T19:24:31+09:00'
id: b35641d2dc838ef34bdb
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

## ローカルテストを通すまでの試行錯誤の過程

ひとまず入力を一通り読み込むところを作ります．

```elixir:main.exs
defmodule Main do
  def main() do
    [n, l, r] = read_int_list()
    a = read_int_list()

    IO.inspect(n, label: "n")
    IO.inspect(l, label: "l")
    IO.inspect(r, label: "r")
    IO.inspect(a, label: "a")
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

テスト実行するときは次のようにします．

```zsh
% elixir test.exs < in1.txt 
n: 5
l: 4
r: 7
a: [3, 1, 4, 9, 7]
```

ちゃんと入力できていますので，次に進みます．

`IO.inspect(n, label: "n")`のようにすると，`n: 5`のように表示してくれます．便利ですね．

さしあたり，`a`を一通り走査してみましょう．

```elixir:main.exs
defmodule Main do
  def main() do
    [n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      IO.inspect(a, label: "a")
    end)
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

```zsh
% elixir test.exs < in1.txt
warning: variable "l" is unused (if the variable is not meant to be used, prefix it with an underscore)
  main.exs:3: Main.main/0

warning: variable "n" is unused (if the variable is not meant to be used, prefix it with an underscore)
  main.exs:3: Main.main/0

warning: variable "r" is unused (if the variable is not meant to be used, prefix it with an underscore)
  main.exs:3: Main.main/0

a: 3
a: 1
a: 4
a: 9
a: 7
```

警告は無視すると，ちゃんと`a`を走査できています．

`x`を`l`から`r`まで走査する二重ループを書いてみましょうか．

```elixir:main.exs
defmodule Main do
  def main() do
    [n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      l..r
      |> Enum.map(fn x -> 
        IO.inspect({a, x}, label: "{a, x}")
      end)
    end)
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

```zsh
% elixir test.exs < in1.txt
warning: variable "n" is unused (if the variable is not meant to be used, prefix it with an underscore)
  main.exs:3: Main.main/0

{a, x}: {3, 4}
{a, x}: {3, 5}
{a, x}: {3, 6}
{a, x}: {3, 7}
{a, x}: {1, 4}
{a, x}: {1, 5}
{a, x}: {1, 6}
{a, x}: {1, 7}
{a, x}: {4, 4}
{a, x}: {4, 5}
{a, x}: {4, 6}
{a, x}: {4, 7}
{a, x}: {9, 4}
{a, x}: {9, 5}
{a, x}: {9, 6}
{a, x}: {9, 7}
{a, x}: {7, 4}
{a, x}: {7, 5}
{a, x}: {7, 6}
{a, x}: {7, 7}
```

良い感じです．

条件 $|X_i - A_i|$ を表示してみましょう．

```elixir:main.exs
defmodule Main do
  def main() do
    [n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      l..r
      |> Enum.map(fn x -> 
        IO.inspect(abs(x - a), label: "abs(x - a)")
      end)
    end)
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

```zsh
% elixir test.exs < in1.txt
warning: variable "n" is unused (if the variable is not meant to be used, prefix it with an underscore)
  main.exs:3: Main.main/0

abs(x - a): 1
abs(x - a): 2
abs(x - a): 3
abs(x - a): 4
abs(x - a): 3
abs(x - a): 4
abs(x - a): 5
abs(x - a): 6
abs(x - a): 0
abs(x - a): 1
abs(x - a): 2
abs(x - a): 3
abs(x - a): 5
abs(x - a): 4
abs(x - a): 3
abs(x - a): 2
abs(x - a): 3
abs(x - a): 2
abs(x - a): 1
abs(x - a): 0
```

良い感じです．

このノリで，三重ループで`y`も求めてみましょう．

```elixir:main.exs
defmodule Main do
  def main() do
    [n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      l..r
      |> Enum.map(fn x -> 
        l..r
        |> Enum.map(fn y ->
          IO.inspect({abs(x - a) <= abs(y - a), x}, label: "{abs(x - a) <= abs(y - a), x}")
        end)
      end)
    end)
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

実行すると次のような感じです．

```zsh
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {false, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {false, 6}
{abs(x - a) <= abs(y - a), x}: {false, 6}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {false, 7}
{abs(x - a) <= abs(y - a), x}: {false, 7}
{abs(x - a) <= abs(y - a), x}: {false, 7}
{abs(x - a) <= abs(y - a), x}: {true, 7}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {false, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {false, 6}
{abs(x - a) <= abs(y - a), x}: {false, 6}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {false, 7}
{abs(x - a) <= abs(y - a), x}: {false, 7}
{abs(x - a) <= abs(y - a), x}: {false, 7}
{abs(x - a) <= abs(y - a), x}: {true, 7}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {false, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {false, 6}
{abs(x - a) <= abs(y - a), x}: {false, 6}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {false, 7}
{abs(x - a) <= abs(y - a), x}: {false, 7}
{abs(x - a) <= abs(y - a), x}: {false, 7}
{abs(x - a) <= abs(y - a), x}: {true, 7}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {false, 4}
{abs(x - a) <= abs(y - a), x}: {false, 4}
{abs(x - a) <= abs(y - a), x}: {false, 4}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {false, 5}
{abs(x - a) <= abs(y - a), x}: {false, 5}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {false, 6}
{abs(x - a) <= abs(y - a), x}: {true, 7}
{abs(x - a) <= abs(y - a), x}: {true, 7}
{abs(x - a) <= abs(y - a), x}: {true, 7}
{abs(x - a) <= abs(y - a), x}: {true, 7}
{abs(x - a) <= abs(y - a), x}: {true, 4}
{abs(x - a) <= abs(y - a), x}: {false, 4}
{abs(x - a) <= abs(y - a), x}: {false, 4}
{abs(x - a) <= abs(y - a), x}: {false, 4}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {true, 5}
{abs(x - a) <= abs(y - a), x}: {false, 5}
{abs(x - a) <= abs(y - a), x}: {false, 5}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {true, 6}
{abs(x - a) <= abs(y - a), x}: {false, 6}
{abs(x - a) <= abs(y - a), x}: {true, 7}
{abs(x - a) <= abs(y - a), x}: {true, 7}
{abs(x - a) <= abs(y - a), x}: {true, 7}
{abs(x - a) <= abs(y - a), x}: {true, 7}
```

`Enum.reduce`を使って$|X_i - A_i| \leq |Y_i - A_i|$を累積してみましょう．

```elixir:main.exs
defmodule Main do
  def main() do
    [n, l, r] = read_int_list()
    a = read_int_list()

    a
    |> Enum.map(fn a ->
      l..r
      |> Enum.map(fn x ->
        b = Enum.reduce(l..r, true, fn y, acc ->
          abs(x - a) <= abs(y - a) and acc
        end)

        IO.inspect({x, b}, label: "{x, true or false}")
      end)
    end)
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

```zsh
% elixir test.exs < in1.txt
warning: variable "n" is unused (if the variable is not meant to be used, prefix it with an underscore)
  main.exs:3: Main.main/0

{x, true or false}: {4, true}
{x, true or false}: {5, false}
{x, true or false}: {6, false}
{x, true or false}: {7, false}
{x, true or false}: {4, true}
{x, true or false}: {5, false}
{x, true or false}: {6, false}
{x, true or false}: {7, false}
{x, true or false}: {4, true}
{x, true or false}: {5, false}
{x, true or false}: {6, false}
{x, true or false}: {7, false}
{x, true or false}: {4, false}
{x, true or false}: {5, false}
{x, true or false}: {6, false}
{x, true or false}: {7, true}
{x, true or false}: {4, false}
{x, true or false}: {5, false}
{x, true or false}: {6, false}
{x, true or false}: {7, true}
```

良い感じで判定できました．あとは，`Enum.filter`で，2番目が`true`のものだけ抜き出せば良いです．

```elixir:main.exs
defmodule Main do
  def main() do
    [n, l, r] = read_int_list()
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
    |> IO.inspect()
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

```zsh
% elixir test.exs < in1.txt
warning: variable "n" is unused (if the variable is not meant to be used, prefix it with an underscore)
  main.exs:3: Main.main/0

[[4], [4], [4], ~c"\a", ~c"\a"]
```

結果が文字化けしてしまいましたので，最後の`IO.inspect()`を`IO.inspect(charlists: :as_lists)`とします．

```elixir:main.exs
defmodule Main do
  def main() do
    [n, l, r] = read_int_list()
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
    |> IO.inspect(charlists: :as_list)
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

```zsh
% elixir test.exs < in1.txt
warning: variable "n" is unused (if the variable is not meant to be used, prefix it with an underscore)
  main.exs:3: Main.main/0

[[4], [4], [4], [7], [7]]
```

大体結果が出ましたね．あとは，リストが多重になっているので，[`List.flatten/1`](https://hexdocs.pm/elixir/1.15.7/List.html#flatten/1)を使って平らにします．

```elixir:main.exs
defmodule Main do
  def main() do
    [n, l, r] = read_int_list()
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
    |> IO.inspect(charlists: :as_list)
  end

  def read_int_list() do
    IO.read(:line)
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
```

```zsh
% elixir test.exs < in1.txt
warning: variable "n" is unused (if the variable is not meant to be used, prefix it with an underscore)
  main.exs:3: Main.main/0

[4, 4, 4, 7, 7]
```

これで，結果が出たので，`Enum.join`と`IO.puts`に書き換えます．また，`n`は使わなかったので，`_n`としておきます．

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

`make`コマンドを実行してみましょう．

```zsh
% make
elixir test.exs < in1.txt | diff - out1.txt
elixir test.exs < in2.txt | diff - out2.txt
```

成功です．

ではAtCoderで提出してみましょう．

https://atcoder.jp/contests/abc330/submissions/48602835

おやおや，TLE(実行時間制限超過)になってしまいました．答えそのものは合っていそうです．

AtCoderの楽しみ方として，一旦はここまででも良いのかと思います．しかし，できればTLE(実行時間制限超過)をクリアしたいですよね．

今回の方法だと，三重ループを使っているので，計算量で言うと$O(n^3)$となるので，いかにも遅そうです．実際，問題の制約条件を見てみると，$O(n^3)$のアルゴリズムでは到底AC(正解)は得られないものと考えられます．

次の記事では，まずアルゴリズム上の工夫をしてみたいと思います．


