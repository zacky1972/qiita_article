---
title: Elixirでフィボナッチ数列をいろいろ書いてみた Part. 5
tags:
  - Elixir
  - フィボナッチ数列
private: false
updated_at: ''
id: null
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