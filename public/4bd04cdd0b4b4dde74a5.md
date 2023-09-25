---
title: '[AtCoder + Elixir] Elixirにおけるメモ化再帰とDP(動的計画法)の一考察'
tags:
  - AtCoder
  - Elixir
  - 動的計画法
  - メモ化再帰
private: false
updated_at: '2023-07-12T14:50:52+09:00'
id: 4bd04cdd0b4b4dde74a5
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
お題をいただきました．

https://twitter.com/GeekMasahiro/status/1678869060350808064

恥ずかしながら，DPという言葉が何を指すのかわからなかったのでググりました．次の記事に当たりました．なるほど，動的計画法ならば知っています．

https://atcoder.jp/contests/abc247/editorial/3735?lang=ja

この入門記事のコードをElixirで書いてみましたので，本記事ではそれを共有してみたいと思います．

## 通常の再帰関数による実装

https://atcoder.jp/contests/abc247/submissions/43492735

`IO.gets/2`を使っちゃったけど，`IO.read/2`の方が適切かなとも思います．お好きな方で実装してください．コードを下記にも書いておきます．

```elixir
defmodule Main do
  def main() do
    IO.gets("")
    |> String.trim()
    |> String.to_integer()
    |> solve()
    |> Enum.join(" ")
    |> IO.puts()
  end
  
  def solve(1), do: [1]

  def solve(n) do
    s = solve(n - 1)
    s ++ [n] ++ s
  end
end
```

元のプログラムで再帰関数中のif文を書いているところを，Elixirでは関数パターンマッチを使うことで簡潔に書けますね．わかりやすさという点ではこの上ないと思います．

## メモ化再帰

メモを取るのにETSを使ってみました．

https://atcoder.jp/contests/abc247/submissions/43500043


```elixir
defmodule Main do
  def main() do
    :ets.new(:memo, [:set, :protected, :named_table])
    
    IO.gets("")
    |> String.trim()
    |> String.to_integer()
    |> solve()
    |> Enum.join(" ")
    |> IO.puts()
  end
  
  def solve(n) do
    case :ets.lookup(:memo, n) do
      [{^n, result}] -> result
      
      [] -> 
        s = solve_s(n)
        :ets.insert(:memo, {n, s})
        s
    end
  end
  
  def solve_s(1), do: [1]
 
  def solve_s(n) do
    s = solve(n - 1)
    s ++ [n] ++ s
  end
end
```

`solve`関数と`solve_s`関数の2段構えにしている点が特徴となります．
`solve_s`関数は実質，再帰版と同様で読みやすいです．
メモ化のロジックについて，ETSに慣れていないと，わかりにくいかもしれません．

## DP(動的計画法)

解釈が合っているのか，若干自信ないのですが，Elixirだと`Enum.reduce`を使うということだと思いました．

https://atcoder.jp/contests/abc247/submissions/43493019

```elixir
defmodule Main do
  def main() do
    IO.gets("")
    |> String.trim()
    |> String.to_integer()
    |> solve()
    |> Enum.join(" ")
    |> IO.puts()
  end
  
  def solve(n) do
    Enum.reduce(0..n, [], fn
      0, _acc -> []
      n, acc -> acc ++ [n] ++ acc
    end)
  end
end
```

`solve`関数をインライン展開して，1つのパイプラインで推し切ることもできますね．

```elixir
defmodule Main do
  def main() do
    IO.gets("")
    |> String.trim()
    |> String.to_integer()
    |> then(&Enum.reduce(0..&1, [], fn
      0, _acc -> []
      n, acc -> acc ++ [n] ++ acc
    end))
    |> Enum.join(" ")
    |> IO.puts()
  end
end
```

`Enum.reduce`の中の関数を外に出して，パターンマッチにすることもできます．

```elixir
defmodule Main do
  def main() do
    IO.gets("")
    |> String.trim()
    |> String.to_integer()
    |> then(fn n -> Enum.reduce(0..n, [], &sub/2) end)
    |> Enum.join(" ")
    |> IO.puts()
  end

  defp sub(0, _), do: []
  defp sub(n, acc), do: acc ++ [n] ++ acc
end
```

ああ，美しい．

## DPあるいは`Enum.reduce`の解法についての考察

今回の問題はDPを使ったとは言うものの，1つ前の値しか参照していないので，最初の再帰と大して変わらないというのはあると思います．

そうすると，1つ前と2つ前の値を参照するフィボナッチ関数だと，どういう実装になるのだろうか，というところに興味が湧きます．

まず再帰版のフィボナッチ関数です．

```elixir
defmodule Main do
  def main() do
    IO.gets("")
    |> String.trim()
    |> String.to_integer()
    |> fib()
    |> IO.puts()
  end
  
  def fib(0), do: 0
  def fib(1), do: 1

  def fib(n) do
    fib(n - 1) + fib(n - 2)
  end
end
```

これを`Enum.reduce`で書いてみましょう．

```elixir
defmodule Main do
  def main() do
    IO.gets("")
    |> String.trim()
    |> String.to_integer()
    |> fib()
    |> IO.puts()
  end
  
  def fib(n) do
    0..n
    |> Enum.reduce([], fn
      0, acc -> [0 | acc]
      1, acc -> [1 | acc]
      _, acc = [a, b | _] -> [a + b | acc]
    end)
    |> hd()
  end
end
```

3つ目のパターンマッチの末尾は捨てるので，次のように書いてメモリを節約する戦術も有効だと思います．

```elixir
defmodule Main do
  def main() do
    IO.gets("")
    |> String.trim()
    |> String.to_integer()
    |> fib()
    |> IO.puts()
  end
  
  def fib(n) do
    0..n
    |> Enum.reduce([], fn
      0, acc -> [0 | acc]
      1, acc -> [1 | acc]
      _, [a, b | _] -> [a + b | [a]]
    end)
    |> hd()
  end
end
```

`Enum.reduce`版を実行してみるとわかりますが，とても高速です．

一般に，`Enum.reduce`に与える変数`acc`に，記憶したい`dp`変数相当を入れておいて，リストを参照するパターンマッチなり関数なりを入れれば良いということになります．

また，記憶しておくべき変数が多岐にわたる場合には，ETSを使用しても良いと思います．

## Elixirにおけるメモ化再帰 vs DP(`Enum.reduce`)

最初どっちでも良いやと思ったのですが，再考したら，DP(`Enum.reduce`)の方が断然良いと思い直しました．

理由はメモ化再帰の時のキャッシュロジックを書く煩雑さ，DP(`Enum.reduce`)がオリジナルの再帰と変わらないくらい可読性が高いことの2点です．


