---
title: Elixirでフィボナッチ数列をいろいろ書いてみた Part. 5
tags:
  - Elixir
  - フィボナッチ数列
private: false
updated_at: '2024-12-30T13:32:31+09:00'
id: 1d2dd390454e80f39d3f
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
- [Elixirでフィボナッチ数列をいろいろ書いてみた Part. 4](https://qiita.com/zacky1972/items/70fec5829ad4e97bf872)

## 行列のべき乗を使う

```math
\begin{pmatrix}
  F_n \\
  F_{n+1}
\end{pmatrix}
=
\begin{pmatrix}
  0 & 1 \\
  1 & 1
\end{pmatrix}^n
\begin{pmatrix}
  0 \\
  1
\end{pmatrix}
```

```elixir:fib_benchee.exs
Mix.install([:benchee])

defmodule Fibonacci.Matrix do
  def of(n) do
    Enum.reduce(1..n, {0, 1}, fn
      _, {p, q} -> {q, p + q}
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

IO.inspect(Fibonacci.Matrix.of(1500) == Fibonacci.Reduce.of(1500))

Benchee.run(
  %{
    "Fibonacci by Enum.reduce" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Reduce.of(input) end) end,
    "Fibonacci with Matrix" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Matrix.of(input) end) end
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
Benchmarking Fibonacci with Matrix with input 1 ...
Benchmarking Fibonacci with Matrix with input 10 ...
Benchmarking Fibonacci with Matrix with input 100 ...
Benchmarking Fibonacci with Matrix with input 1000 ...
Calculating statistics...
Formatting results...

##### With input 1 #####
Name                               ips        average  deviation         median         99th %
Fibonacci with Matrix         572.17 K        1.75 μs   ±750.26%        1.63 μs        2.25 μs
Fibonacci by Enum.reduce      475.76 K        2.10 μs   ±520.80%           2 μs        2.88 μs

Comparison: 
Fibonacci with Matrix         572.17 K
Fibonacci by Enum.reduce      475.76 K - 1.20x slower +0.35 μs

##### With input 10 #####
Name                               ips        average  deviation         median         99th %
Fibonacci with Matrix         213.34 K        4.69 μs   ±333.13%        4.38 μs       12.50 μs
Fibonacci by Enum.reduce      194.28 K        5.15 μs   ±148.88%        4.83 μs       13.29 μs

Comparison: 
Fibonacci with Matrix         213.34 K
Fibonacci by Enum.reduce      194.28 K - 1.10x slower +0.46 μs

##### With input 100 #####
Name                               ips        average  deviation         median         99th %
Fibonacci with Matrix          22.02 K       45.41 μs     ±5.32%       45.04 μs       57.29 μs
Fibonacci by Enum.reduce       19.56 K       51.11 μs     ±5.81%       50.92 μs       62.04 μs

Comparison: 
Fibonacci with Matrix          22.02 K
Fibonacci by Enum.reduce       19.56 K - 1.13x slower +5.71 μs

##### With input 1000 #####
Name                               ips        average  deviation         median         99th %
Fibonacci with Matrix           761.80        1.31 ms     ±1.90%        1.31 ms        1.40 ms
Fibonacci by Enum.reduce        754.01        1.33 ms     ±2.85%        1.32 ms        1.44 ms

Comparison: 
Fibonacci with Matrix           761.80
Fibonacci by Enum.reduce        754.01 - 1.01x slower +0.0136 ms
```

|                         |1    |10  |100  |1000   |
|:------------------------|----:|---:|----:|------:|
|Fibonacci by Enum.reduce | 2010|5150|51110|1330000|
|Fibonacci with Matrix    | 1750|4690|45410|1310000|

Fibonacci with Matrix は素晴らしく速いですね！

## オリジナルのフィボナッチとの比較

```elixir:fib_benchee.exs
Mix.install([:benchee])

defmodule Fibonacci.Matrix do
  def of(n) do
    Enum.reduce(1..n, {0, 1}, fn
      _, {p, q} -> {q, p + q}
    end)
    |> elem(0)
  end
end

defmodule Fibonacci do
  def of(n)
  def of(0), do: 0
  def of(1), do: 1
  def of(n), do: of(n - 2) + of(n - 1)
end
Benchee.run(
  %{
    "Very Slow Fibonacci" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.of(input) end) end,
    "Fibonacci with Matrix" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Matrix.of(input) end) end
  },
  inputs: %{
    "1" => 1,
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9
  }
)
```

### 実行結果

```elixir
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
inputs: 1, 2, 3, 4, 5, 6, 7, 8, 9
Estimated total run time: 2 min 6 s

Benchmarking Fibonacci with Matrix with input 1 ...
Benchmarking Fibonacci with Matrix with input 2 ...
Benchmarking Fibonacci with Matrix with input 3 ...
Benchmarking Fibonacci with Matrix with input 4 ...
Benchmarking Fibonacci with Matrix with input 5 ...
Benchmarking Fibonacci with Matrix with input 6 ...
Benchmarking Fibonacci with Matrix with input 7 ...
Benchmarking Fibonacci with Matrix with input 8 ...
Benchmarking Fibonacci with Matrix with input 9 ...
Benchmarking Very Slow Fibonacci with input 1 ...
Benchmarking Very Slow Fibonacci with input 2 ...
Benchmarking Very Slow Fibonacci with input 3 ...
Benchmarking Very Slow Fibonacci with input 4 ...
Benchmarking Very Slow Fibonacci with input 5 ...
Benchmarking Very Slow Fibonacci with input 6 ...
Benchmarking Very Slow Fibonacci with input 7 ...
Benchmarking Very Slow Fibonacci with input 8 ...
Benchmarking Very Slow Fibonacci with input 9 ...
Calculating statistics...
Formatting results...

##### With input 1 #####
Name                            ips        average  deviation         median         99th %
Very Slow Fibonacci          1.41 M        0.71 μs  ±1889.67%        0.67 μs        0.92 μs
Fibonacci with Matrix        0.58 M        1.73 μs   ±783.76%        1.58 μs        2.25 μs

Comparison: 
Very Slow Fibonacci          1.41 M
Fibonacci with Matrix        0.58 M - 2.43x slower +1.02 μs

##### With input 2 #####
Name                            ips        average  deviation         median         99th %
Very Slow Fibonacci        931.45 K        1.07 μs  ±1252.44%           1 μs        1.38 μs
Fibonacci with Matrix      495.09 K        2.02 μs   ±419.01%        1.92 μs        2.75 μs

Comparison: 
Very Slow Fibonacci        931.45 K
Fibonacci with Matrix      495.09 K - 1.88x slower +0.95 μs

##### With input 3 #####
Name                            ips        average  deviation         median         99th %
Very Slow Fibonacci        696.63 K        1.44 μs   ±808.65%        1.38 μs        1.92 μs
Fibonacci with Matrix      420.12 K        2.38 μs   ±415.39%        2.25 μs        3.25 μs

Comparison: 
Very Slow Fibonacci        696.63 K
Fibonacci with Matrix      420.12 K - 1.66x slower +0.94 μs

##### With input 4 #####
Name                            ips        average  deviation         median         99th %
Very Slow Fibonacci        465.50 K        2.15 μs   ±396.15%        2.08 μs        2.88 μs
Fibonacci with Matrix      363.66 K        2.75 μs   ±335.59%        2.58 μs        3.75 μs

Comparison: 
Very Slow Fibonacci        465.50 K
Fibonacci with Matrix      363.66 K - 1.28x slower +0.60 μs

##### With input 5 #####
Name                            ips        average  deviation         median         99th %
Fibonacci with Matrix      327.94 K        3.05 μs   ±324.63%        2.88 μs        4.25 μs
Very Slow Fibonacci        307.30 K        3.25 μs   ±260.37%        3.13 μs        4.33 μs

Comparison: 
Fibonacci with Matrix      327.94 K
Very Slow Fibonacci        307.30 K - 1.07x slower +0.20 μs

##### With input 6 #####
Name                            ips        average  deviation         median         99th %
Fibonacci with Matrix      292.98 K        3.41 μs   ±212.03%        3.21 μs        8.67 μs
Very Slow Fibonacci        196.20 K        5.10 μs   ±138.86%        4.96 μs        6.92 μs

Comparison: 
Fibonacci with Matrix      292.98 K
Very Slow Fibonacci        196.20 K - 1.49x slower +1.68 μs

##### With input 7 #####
Name                            ips        average  deviation         median         99th %
Fibonacci with Matrix      271.75 K        3.68 μs   ±291.31%        3.46 μs        9.67 μs
Very Slow Fibonacci        124.97 K        8.00 μs    ±63.10%        7.83 μs       10.96 μs

Comparison: 
Fibonacci with Matrix      271.75 K
Very Slow Fibonacci        124.97 K - 2.17x slower +4.32 μs

##### With input 8 #####
Name                            ips        average  deviation         median         99th %
Fibonacci with Matrix      249.91 K        4.00 μs   ±162.08%        3.75 μs        5.75 μs
Very Slow Fibonacci         78.12 K       12.80 μs    ±22.94%       12.63 μs       17.46 μs

Comparison: 
Fibonacci with Matrix      249.91 K
Very Slow Fibonacci         78.12 K - 3.20x slower +8.80 μs

##### With input 9 #####
Name                            ips        average  deviation         median         99th %
Fibonacci with Matrix      232.67 K        4.30 μs   ±160.95%        4.04 μs       10.38 μs
Very Slow Fibonacci         48.32 K       20.70 μs     ±7.37%       20.54 μs       27.08 μs

Comparison: 
Fibonacci with Matrix      232.67 K
Very Slow Fibonacci         48.32 K - 4.82x slower +16.40 μs
```

|                      |1   |2   |3   |4   |5   |6   |7   |8    |9    |
|:---------------------|---:|---:|---:|---:|---:|---:|---:|----:|----:|
|Very Slow Fibonacci   | 710|1070|1440|2150|3250|5100|8000|12800|20700|
|Fibonacci with Matrix |1730|2020|2380|2750|3050|3410|3680| 4000| 4300|

5で逆転しましたね．