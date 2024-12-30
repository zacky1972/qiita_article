---
title: Elixirでフィボナッチ数列をいろいろ書いてみた Part. 4
tags:
  - Elixir
  - フィボナッチ数列
private: false
updated_at: '2024-12-30T13:06:01+09:00'
id: 70fec5829ad4e97bf872
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
@mod_poppoさんの[Haskellでフィボナッチ数列 〜Haskellで非実用的なコードを書いて悦に入るのはやめろ〜](https://qiita.com/mod_poppo/items/4f78d135bb43b7fd1743)にインスピレーションを得て，Elixirでフィボナッチ数列をいろいろ書いてみるシリーズ記事の第4弾です．

https://qiita.com/mod_poppo/items/4f78d135bb43b7fd1743

フィボナッチ数列シリーズ

- [Elixirでフィボナッチ数列をいろいろ書いてみた Part. 1](https://qiita.com/zacky1972/items/74f7ce9b6463862ea5bb)
- [Elixirでフィボナッチ数列をいろいろ書いてみた Part. 2](https://qiita.com/zacky1972/items/fed96c37aef3a09da0c5)
- [Elixirでフィボナッチ数列をいろいろ書いてみた Part. 3](https://qiita.com/zacky1972/items/f65e000178c49fd84e1d)

## ビネ(Binet)の公式

```math
F_n = \frac{1}{\sqrt{5}}\left( \left(\frac{1 + \sqrt{5}}{2} \right)^n - \left(\frac{1 - \sqrt{5}}{2} \right)^n\right)
```

```elixir
iex> fn n -> 1.0 / :math.sqrt(5) * (:math.pow((1 + :math.sqrt(5)) / 2, n) - :math.pow((1 - :math.sqrt(5)) / 2, n)) end.(10)
55.000000000000014
```

とりあえず合っていそうです．

手始めに$\sqrt{5}$を多倍長整数とニュートン法を用いて求めてみたいと思います．

下記のアルゴリズムを採用します．

https://www.mirai-kougaku.jp/laboratory/pages/240913.php

```elixir
fn a ->
  Stream.unfold({2, 1}, fn
    {p, q} -> 
      d = {p * p + a * q * q, Bitwise.bsl(p * q, 1)}
      {d, d}
  end)
end
```

後で使いやすいように，次のように，漸化式として定義します．

```elixir
fn {p, q} ->
  {p * p + a * q * q, Bitwise.bsl(p * q, 1)}
end
```

2進分解法を用いて $x^n$ を計算します．

```elixir
fn x, n ->
  Stream.unfold(n, fn
      0 -> nil
      n -> {Bitwise.band(n, 1), Bitwise.bsr(n, 1)}
  end)
  |> Enum.reduce({1, x}, fn
    0, {r, x} -> {r, x * x}
    1, {r, x} -> {r * x, x * x}
  end)
  |> elem(0)
end
```

以上をビネ(Binet)の公式に当てはめます．

```elixir:fib_benchee.exs
Mix.install([:benchee])

defmodule Fibonacci.Binet do
  def of(n) do
    Stream.unfold({2, 1}, fn {p, q} ->
      {
        {
          q * (power(q + p, n)- power(q - p, n)),
          p * power(Bitwise.bsl(q, 1), n)
        }, 
        {
          p * p + 5 * q * q, 
          Bitwise.bsl(p * q, 1)
        }
      }
    end)
    |> Stream.scan([], &[&1 | &2])
    |> Stream.drop(2)
    |> Stream.drop_while(fn [{p1, q1}, {p2, q2}, {p3, q3} | _] -> div(p1, q1) != div(p2, q2) and div(p1, q1) != div(p3, q3) end)
    |> Enum.at(0)
    |> hd()
    |> then(fn {p, q} -> div(p, q) end)
  end

  defp power(x, n) do
    Stream.unfold(n, fn
        0 -> nil
        n -> {Bitwise.band(n, 1), Bitwise.bsr(n, 1)}
    end)
    |> Enum.reduce({1, x}, fn
      0, {r, x} -> {r, x * x}
      1, {r, x} -> {r * x, x * x}
    end)
    |> elem(0)
  end
end

defmodule Fibonacci.Reduce do
  def of(n) do
    0..n
    |> Enum.reduce([], fn
      _, [] -> [0]
      _, [0] -> [1, 0]
      _, [m, n] -> [m + n, m]
    end)
    |> hd()
  end
end

IO.inspect(Fibonacci.Binet.of(1500) == Fibonacci.Reduce.of(1500))

Benchee.run(
  %{
    "Fibonacci by Enum.reduce" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Reduce.of(input) end) end,
    "Fibonacci with Binet method" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Binet.of(input) end) end
  },
  inputs: %{
    "1" => 1,
    "10" => 10,
    "100" => 100,
    "1000" => 1000
  }
)
```

### 実行結果

```elixir
true
Operating System: macOS
CPU Information: Apple M3 Max
Number of Available Cores: 16
Available memory: 128 GB
Elixir 1.18.1
Erlang 27.2
JIT enabled: true

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
reduction time: 0 ns
parallel: 1
inputs: 1, 10, 100, 1000
Estimated total run time: 56 s

Benchmarking Fibonacci by Enum.reduce with input 1 ...
Benchmarking Fibonacci by Enum.reduce with input 10 ...
Benchmarking Fibonacci by Enum.reduce with input 100 ...
Benchmarking Fibonacci by Enum.reduce with input 1000 ...
Benchmarking Fibonacci with Binet method with input 1 ...
Benchmarking Fibonacci with Binet method with input 10 ...
Benchmarking Fibonacci with Binet method with input 100 ...
Benchmarking Fibonacci with Binet method with input 1000 ...
Calculating statistics...
Formatting results...

##### With input 1 #####
Name                                  ips        average  deviation         median         99th %
Fibonacci by Enum.reduce         494.72 K        2.02 μs   ±585.40%        1.92 μs        2.67 μs
Fibonacci with Binet method       24.00 K       41.66 μs     ±6.22%       41.92 μs       48.29 μs

Comparison: 
Fibonacci by Enum.reduce         494.72 K
Fibonacci with Binet method       24.00 K - 20.61x slower +39.64 μs

##### With input 10 #####
Name                                  ips        average  deviation         median         99th %
Fibonacci by Enum.reduce         195.68 K        5.11 μs   ±136.15%        4.79 μs       13.08 μs
Fibonacci with Binet method        7.93 K      126.05 μs     ±4.44%      124.29 μs      150.17 μs

Comparison: 
Fibonacci by Enum.reduce         195.68 K
Fibonacci with Binet method        7.93 K - 24.67x slower +120.94 μs

##### With input 100 #####
Name                                  ips        average  deviation         median         99th %
Fibonacci by Enum.reduce          19.63 K      0.0509 ms     ±5.16%      0.0511 ms      0.0612 ms
Fibonacci with Binet method       0.110 K        9.06 ms     ±0.65%        9.05 ms        9.20 ms

Comparison: 
Fibonacci by Enum.reduce          19.63 K
Fibonacci with Binet method       0.110 K - 177.87x slower +9.01 ms

##### With input 1000 #####
Name                                  ips        average  deviation         median         99th %
Fibonacci by Enum.reduce           724.86      0.00138 s     ±3.40%      0.00139 s      0.00146 s
Fibonacci with Binet method         0.110         9.09 s     ±0.00%         9.09 s         9.09 s

Comparison: 
Fibonacci by Enum.reduce           724.86
Fibonacci with Binet method         0.110 - 6585.76x slower +9.08 s
```

|                           |1    |10    |100    |1000      |
|:--------------------------|----:|-----:|------:|---------:|
|Fibonacci by Enum.reduce   | 2020|  5110|  50900|   1380000|
|Fibonacci with Binet method|41660|126050|9060000|9090000000|

Fibonacci by Enum.reduce の方が圧倒的に速いですね．
