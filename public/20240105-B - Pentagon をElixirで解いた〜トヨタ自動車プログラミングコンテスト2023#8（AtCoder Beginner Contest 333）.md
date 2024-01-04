---
title: >-
  B - Pentagon をElixirで解いた〜トヨタ自動車プログラミングコンテスト2023#8（AtCoder Beginner Contest
  333）
tags:
  - AtCoder
  - Elixir
private: false
updated_at: '2024-01-05T06:18:53+09:00'
id: ba9046c4f9d171d4776d
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
トヨタ自動車プログラミングコンテスト2023#8（AtCoder Beginner Contest 333）のB - PentagonをElixirで解いたので報告します．

## 問題

https://atcoder.jp/contests/abc333/tasks/abc333_b

## 最終的な解答例

https://atcoder.jp/contests/abc333/submissions/48688631

```elixir
defmodule Main do
  def main() do
    s = read_edge() |> r() |> l() |> t()
    t = read_edge() |> r() |> l() |> t()
    
    if s == t do
      IO.puts("Yes")
    else
      IO.puts("No")
    end
  end
  
  def read_edge() do
    IO.read(:line)
    |> String.trim()
    |> String.to_charlist()
    |> Enum.map(fn
      ?A -> 1
      ?B -> 2
      ?C -> 3
      ?D -> 4
      ?E -> 5
    end)
  end

  def r([a, b]) when a <= b, do: [a, b]
  def r([a, b]), do: [a, b + 5]

  def l([a, b]), do: b - a

  def t(a) when a <= 2, do: a
  def t(a), do: 5 - a
end
```

まずElixirの初学者にとって難しいのが，文字列`"AB"`のような辺の情報をどのように扱うかです．よくあるAtCoderの問題のように空白文字で区切られていないので，いつも使うような[`String.split/3`](https://hexdocs.pm/elixir/1.16.0/String.html#split/3)を使えないという問題があります．Elixirでこの問題を解こうとした時に，辺の情報を扱う方法がわからなかったのではないかなと思います．

この解答例では，[`String.to_charlist/1`](https://hexdocs.pm/elixir/1.16.0/String.html#to_charlist/1)をまず使います．この関数名，初学者にとって`charlist`って何？というところだと思います．`charlist`というのは，文字列`"AB"`を，整数のリスト形式に変換したものです．

この整数値は文字をコード化したものになります．また，Elixirでは文字`A`をコード化したものを`?A`と表記します．これを利用して，[`Enum.map/2`](https://hexdocs.pm/elixir/1.16.0/Enum.html#map/2)で，文字`A`を1に，文字`B`を2に，というように変換します．

関数`Main.read_edge/0`は，標準入力から1行読み込み，末尾の改行を取り除き，前述の処理を行うことで，文字列`"AB"`があったら`[1, 2]`のように変換します．

```elixir
  def read_edge() do
    IO.read(:line)
    |> String.trim()
    |> String.to_charlist()
    |> Enum.map(fn
      ?A -> 1
      ?B -> 2
      ?C -> 3
      ?D -> 4
      ?E -> 5
    end)
  end
```

次に，関数`Main.r/1`ですが，`if`を使って書き直すと次のようになります．

```elixir
  def r([a, b]) do
    if a <= b do
      [a, b]
    else
      [a, b + 5]
    end
  end
```

すなわち，引数`[a, b]`があったときに，もし`a`が`b`以下である場合には，そのまま返し，`a`が`b`より大きい時には，`b`に5を加える補正をします．こうすることで，`[a, b]`があったときに，必ず`a <= b`が成立するように変換します．

Elixirでは，このような条件分岐を関数パターンマッチという機能で，数学の場合分けのような感じで，簡潔に書くことができます．また，`do ... end` が1行のみの時には，`, do: ...` のように書けます．

```elixir
  def r([a, b]) when a <= b, do: [a, b]
  def r([a, b]), do: [a, b + 5]
```

慣れると，このような表現は，とても簡潔で，読みやすいと受け止められるようになります．

関数`Main.l/1`は，単純に`[a, b]`があったときに`b - a`を返します．

```elixir
  def l([a, b]), do: b - a
```

ここまで処理すると，`1, 2, 3, 4`のいずれかの値になります．それぞれに対応する辺の長さは`1, 2, 2, 1`となります．関数`Main.t/1`は，このような変換を行うために，引数`a`が2以下の時はそのまま返し，`a`が2より大きい時には`5 - a`を返します．

```elixir
  def t(a) when a <= 2, do: a
  def t(a), do: 5 - a
```

関数`Main.main/0`では，ここまでの処理をパイプラインで一気に行います．その後，値を比較して等しければ`Yes`等しくなければ`No`を標準出力に表示します．

```elixir
  def main() do
    s = read_edge() |> r() |> l() |> t()
    t = read_edge() |> r() |> l() |> t()
    
    if s == t do
      IO.puts("Yes")
    else
      IO.puts("No")
    end
  end
```

