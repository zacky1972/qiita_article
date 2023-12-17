---
title: >-
  A - Counting Passes を Elixir で解いた〜トヨタシステムズプログラミングコンテスト2023(AtCoder Beginner
  Contest 330)
tags:
  - AtCoder
  - Elixir
private: true
updated_at: '2023-12-17T10:27:39+09:00'
id: 39e09321c75c7b41526f
organization_url_name: null
slide: false
ignorePublish: false
---
トヨタシステムズプログラミングコンテスト2023(AtCoder Beginner Contest 330)の A - Counting Passes を Elixir で解きましたので，ご報告します．

## 問題

https://atcoder.jp/contests/abc330/tasks/abc330_a

## 簡易ローカルテスト環境の構築

次のようなMakefileを書きました．

```make:Makefile
.phony: all clean

test: test_ex

test_ex:
	elixir test.exs < in1.txt | diff - out1.txt
	elixir test.exs < in2.txt | diff - out2.txt
	elixir test.exs < in3.txt | diff - out3.txt
```

```elixir:test.exs
Code.eval_file("main.exs")
Main.main()
```

入力例1を`in1.txt`，出力例1を`out1.txt`のように与え，`main.exs`に解答を書きます．その後，`make`コマンドを実行します．

## 解答例

https://atcoder.jp/contests/abc330/submissions/48519927

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l] = read_int_list()
    a = read_int_list()

    a
    |> Enum.filter(& &1 >= l)
    |> Enum.count()
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

関数`Main.read_int_list/0`は，[`IO.read/2`](https://hexdocs.pm/elixir/1.15.7/IO.html#read/2)で標準入力から1行読み取り，[`String.trim/1`](https://hexdocs.pm/elixir/1.12/String.html#trim/1)で改行文字を取り除いた後，[`String.split/3`](https://hexdocs.pm/elixir/1.12/String.html#split/3)で空白文字で区切ってリストにしてから，[`Enum.map/2`](https://hexdocs.pm/elixir/1.15.7/Enum.html#map/2)で各要素について，[`String.to_integer/1`](https://hexdocs.pm/elixir/1.12/String.html#to_integer/1)を適用して文字列を数字に変換し，その結果のリストを返します．

これにより，まず，`n`と`l`を読み込みます．`n`は使用しないので，`_n`と書くことで，`n`を読み捨てます．

次にリスト`a`を読み込みます．その後，`a`を[`Enum.filter/2`](https://hexdocs.pm/elixir/1.15.7/Enum.html#filter/2)で`l`以上の値を持つ要素を抽出し，[`Enum.count/1`](https://hexdocs.pm/elixir/1.15.7/Enum.html#count/1)で個数を数えます．最後に結果を[`IO.puts/2`](https://hexdocs.pm/elixir/1.15.7/IO.html#puts/2)で出力します．

## 別解

`a`を使わずに，パイプラインで直接繋ぐこともできます．

```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l] = read_int_list()
  
    read_int_list()
    |> Enum.filter(& &1 >= l)
    |> Enum.count()
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

さらに[`Enum.count/2`](https://hexdocs.pm/elixir/1.15.7/Enum.html#count/2)を使って，[`Enum.filter/2`](https://hexdocs.pm/elixir/1.15.7/Enum.html#filter/2)と[`Enum.count/1`](https://hexdocs.pm/elixir/1.15.7/Enum.html#count/1)を合わせてしまいます．


```elixir:main.exs
defmodule Main do
  def main() do
    [_n, l] = read_int_list()
  
    read_int_list()
    |> Enum.count(& &1 >= l)
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

https://atcoder.jp/contests/abc330/submissions/48602469

実行時間やメモリ使用量はともかくとして，Elixirはデータ変換パラダイムによって，書きたいことをストレートに，かつ簡潔に書けますね．

