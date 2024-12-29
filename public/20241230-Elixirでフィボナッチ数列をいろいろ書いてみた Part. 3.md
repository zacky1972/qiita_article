---
title: Elixirでフィボナッチ数列をいろいろ書いてみた Part. 3
tags:
  - Elixir
  - フィボナッチ数列
private: false
updated_at: '2024-12-30T08:07:31+09:00'
id: f65e000178c49fd84e1d
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
@mod_poppoさんの[Haskellでフィボナッチ数列 〜Haskellで非実用的なコードを書いて悦に入るのはやめろ〜](https://qiita.com/mod_poppo/items/4f78d135bb43b7fd1743)にインスピレーションを得て，Elixirでフィボナッチ数列をいろいろ書いてみるシリーズ記事の第3弾です．

https://qiita.com/mod_poppo/items/4f78d135bb43b7fd1743

フィボナッチ数列シリーズ

- [Elixirでフィボナッチ数列をいろいろ書いてみた Part. 1](https://qiita.com/zacky1972/items/74f7ce9b6463862ea5bb)
- [Elixirでフィボナッチ数列をいろいろ書いてみた Part. 2](https://qiita.com/zacky1972/items/fed96c37aef3a09da0c5)

## 再帰関数で定義する

```elixir:fib_benchee.exs
Mix.install([:benchee])

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

defmodule Fibonacci.Stream do
  def of(n) do
    Stream.unfold([], fn
      [] -> {0, [0]}
      [0] -> {1, [1, 0]}
      [m, n] -> {m + n, [m + n, m]}
    end)
    |> Enum.at(n)
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
    "Fibonacci by Stream" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Stream.of(input) end) end,
    "Fibonacci by Enum.reduce" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Reduce.of(input) end) end,
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
Estimated total run time: 3 min 9 s

Benchmarking Fibonacci by Enum.reduce with input 1 ...
Benchmarking Fibonacci by Enum.reduce with input 2 ...
Benchmarking Fibonacci by Enum.reduce with input 3 ...
Benchmarking Fibonacci by Enum.reduce with input 4 ...
Benchmarking Fibonacci by Enum.reduce with input 5 ...
Benchmarking Fibonacci by Enum.reduce with input 6 ...
Benchmarking Fibonacci by Enum.reduce with input 7 ...
Benchmarking Fibonacci by Enum.reduce with input 8 ...
Benchmarking Fibonacci by Enum.reduce with input 9 ...
Benchmarking Fibonacci by Stream with input 1 ...
Benchmarking Fibonacci by Stream with input 2 ...
Benchmarking Fibonacci by Stream with input 3 ...
Benchmarking Fibonacci by Stream with input 4 ...
Benchmarking Fibonacci by Stream with input 5 ...
Benchmarking Fibonacci by Stream with input 6 ...
Benchmarking Fibonacci by Stream with input 7 ...
Benchmarking Fibonacci by Stream with input 8 ...
Benchmarking Fibonacci by Stream with input 9 ...
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
Name                               ips        average  deviation         median         99th %
Very Slow Fibonacci          1386.06 K        0.72 μs  ±2380.01%        0.67 μs        0.88 μs
Fibonacci by Enum.reduce      492.71 K        2.03 μs   ±557.39%        1.92 μs        2.63 μs
Fibonacci by Stream           235.55 K        4.25 μs   ±141.24%        4.13 μs        7.58 μs

Comparison: 
Very Slow Fibonacci          1386.06 K
Fibonacci by Enum.reduce      492.71 K - 2.81x slower +1.31 μs
Fibonacci by Stream           235.55 K - 5.88x slower +3.52 μs

##### With input 2 #####
Name                               ips        average  deviation         median         99th %
Very Slow Fibonacci           918.11 K        1.09 μs  ±1267.69%        1.04 μs        1.38 μs
Fibonacci by Enum.reduce      407.27 K        2.46 μs   ±363.49%        2.33 μs        3.33 μs
Fibonacci by Stream           208.38 K        4.80 μs   ±107.27%        4.50 μs       13.08 μs

Comparison: 
Very Slow Fibonacci           918.11 K
Fibonacci by Enum.reduce      407.27 K - 2.25x slower +1.37 μs
Fibonacci by Stream           208.38 K - 4.41x slower +3.71 μs

##### With input 3 #####
Name                               ips        average  deviation         median         99th %
Very Slow Fibonacci           680.16 K        1.47 μs   ±763.90%        1.42 μs        1.96 μs
Fibonacci by Enum.reduce      349.79 K        2.86 μs   ±308.37%        2.71 μs        3.83 μs
Fibonacci by Stream           186.29 K        5.37 μs    ±93.36%        5.17 μs       13.50 μs

Comparison: 
Very Slow Fibonacci           680.16 K
Fibonacci by Enum.reduce      349.79 K - 1.94x slower +1.39 μs
Fibonacci by Stream           186.29 K - 3.65x slower +3.90 μs

##### With input 4 #####
Name                               ips        average  deviation         median         99th %
Very Slow Fibonacci           455.84 K        2.19 μs   ±462.00%        2.13 μs        2.96 μs
Fibonacci by Enum.reduce      314.96 K        3.18 μs   ±311.34%           3 μs        4.33 μs
Fibonacci by Stream           168.81 K        5.92 μs    ±75.71%        5.75 μs       14.25 μs

Comparison: 
Very Slow Fibonacci           455.84 K
Fibonacci by Enum.reduce      314.96 K - 1.45x slower +0.98 μs
Fibonacci by Stream           168.81 K - 2.70x slower +3.73 μs

##### With input 5 #####
Name                               ips        average  deviation         median         99th %
Very Slow Fibonacci           302.37 K        3.31 μs   ±278.34%        3.17 μs        4.33 μs
Fibonacci by Enum.reduce      283.51 K        3.53 μs   ±253.30%        3.33 μs        4.71 μs
Fibonacci by Stream           152.71 K        6.55 μs    ±91.59%        6.25 μs       15.33 μs

Comparison: 
Very Slow Fibonacci           302.37 K
Fibonacci by Enum.reduce      283.51 K - 1.07x slower +0.22 μs
Fibonacci by Stream           152.71 K - 1.98x slower +3.24 μs

##### With input 6 #####
Name                               ips        average  deviation         median         99th %
Fibonacci by Enum.reduce      257.42 K        3.88 μs   ±231.97%        3.67 μs        5.75 μs
Very Slow Fibonacci           191.31 K        5.23 μs   ±152.13%        5.08 μs        7.04 μs
Fibonacci by Stream           136.93 K        7.30 μs    ±52.36%        6.96 μs       15.75 μs

Comparison: 
Fibonacci by Enum.reduce      257.42 K
Very Slow Fibonacci           191.31 K - 1.35x slower +1.34 μs
Fibonacci by Stream           136.93 K - 1.88x slower +3.42 μs

##### With input 7 #####
Name                               ips        average  deviation         median         99th %
Fibonacci by Enum.reduce      235.40 K        4.25 μs   ±154.71%           4 μs        9.88 μs
Fibonacci by Stream           125.12 K        7.99 μs    ±51.91%        7.67 μs       16.71 μs
Very Slow Fibonacci           125.12 K        7.99 μs    ±58.07%        7.79 μs       10.46 μs

Comparison: 
Fibonacci by Enum.reduce      235.40 K
Fibonacci by Stream           125.12 K - 1.88x slower +3.74 μs
Very Slow Fibonacci           125.12 K - 1.88x slower +3.74 μs

##### With input 8 #####
Name                               ips        average  deviation         median         99th %
Fibonacci by Enum.reduce      218.50 K        4.58 μs   ±167.51%        4.25 μs       11.96 μs
Fibonacci by Stream           113.32 K        8.82 μs    ±46.63%        8.46 μs       17.71 μs
Very Slow Fibonacci            76.90 K       13.00 μs    ±15.62%       12.63 μs       16.13 μs

Comparison: 
Fibonacci by Enum.reduce      218.50 K
Fibonacci by Stream           113.32 K - 1.93x slower +4.25 μs
Very Slow Fibonacci            76.90 K - 2.84x slower +8.43 μs

##### With input 9 #####
Name                               ips        average  deviation         median         99th %
Fibonacci by Enum.reduce      202.06 K        4.95 μs   ±106.27%        4.63 μs       13.08 μs
Fibonacci by Stream           101.28 K        9.87 μs    ±42.37%        9.29 μs       16.92 μs
Very Slow Fibonacci            47.15 K       21.21 μs     ±7.93%       20.67 μs       27.63 μs

Comparison: 
Fibonacci by Enum.reduce      202.06 K
Fibonacci by Stream           101.28 K - 2.00x slower +4.92 μs
Very Slow Fibonacci            47.15 K - 4.29x slower +16.26 μs
```


|                         |1   |2   |3   |4   |5   |6   |7   |8    |9    |
|:------------------------|---:|---:|---:|---:|---:|---:|---:|----:|----:|
|Very Slow Fibonacci      | 720|1090|1470|2190|3260|3880|7990|13000|21210|
|Fibonacci by Stream      |4250|4800|5370|6550|6530|7300|7990| 8820| 9870|
|Fibonacci by Enum.reduce |2030|2460|2860|3180|3530|3880|4250| 4580| 4950|


![Fibonacci by Enum.reduce](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/f09b37a3-b8ea-c98e-18b9-fd6134f075b7.png)

5以上でFibonacci by Enum.reduceがVery Slow Fibonacciより高速になりました．一貫して，Fibonacci by Enum.reduceはFibonacci by Streamより高速です．
 $y = 358.67x + 1731.1$ ですので，219以上でMemoizationを用いた方が高速になる可能性がありますが，まあ，このくらい大きいのであれば，Memoizationを用いる必然性は薄いですね．
