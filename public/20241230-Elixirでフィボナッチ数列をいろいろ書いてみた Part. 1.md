---
title: Elixirでフィボナッチ数列をいろいろ書いてみた Part. 1
tags:
  - Elixir
  - フィボナッチ数列
private: false
updated_at: '2024-12-30T05:53:51+09:00'
id: 74f7ce9b6463862ea5bb
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
@mod_poppoさんの[Haskellでフィボナッチ数列 〜Haskellで非実用的なコードを書いて悦に入るのはやめろ〜](https://qiita.com/mod_poppo/items/4f78d135bb43b7fd1743)にインスピレーションを得て，Elixirでフィボナッチ数列をいろいろ書いてみるシリーズ記事を書くことを思い立ちました．

https://qiita.com/mod_poppo/items/4f78d135bb43b7fd1743

## 素朴なコード

```elixir:fib_benchee.exs
Mix.install([:benchee])

defmodule Fibonacci do
  def of(n)
  def of(0), do: 0
  def of(1), do: 1
  def of(n), do: of(n - 2) + of(n - 1)
end

Benchee.run(
  %{
    "Very Slow Fibonacci" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.of(input) end) end
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
    "9" => 9,
    "10" => 10
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
inputs: 1, 10, 2, 3, 4, 5, 6, 7, 8, 9
Estimated total run time: 1 min 10 s

Benchmarking Very Slow Fibonacci with input 1 ...
Benchmarking Very Slow Fibonacci with input 10 ...
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
Name                          ips        average  deviation         median         99th %
Very Slow Fibonacci        1.46 M      685.64 ns  ±1989.29%         625 ns         875 ns

##### With input 10 #####
Name                          ips        average  deviation         median         99th %
Very Slow Fibonacci       29.92 K       33.42 μs    ±27.52%       33.21 μs       39.71 μs

##### With input 2 #####
Name                          ips        average  deviation         median         99th %
Very Slow Fibonacci      946.56 K        1.06 μs  ±1299.08%           1 μs        1.33 μs

##### With input 3 #####
Name                          ips        average  deviation         median         99th %
Very Slow Fibonacci      699.19 K        1.43 μs   ±844.05%        1.38 μs        1.79 μs

##### With input 4 #####
Name                          ips        average  deviation         median         99th %
Very Slow Fibonacci      468.81 K        2.13 μs   ±388.35%        2.08 μs        2.67 μs

##### With input 5 #####
Name                          ips        average  deviation         median         99th %
Very Slow Fibonacci      308.24 K        3.24 μs   ±268.69%        3.13 μs        4.42 μs

##### With input 6 #####
Name                          ips        average  deviation         median         99th %
Very Slow Fibonacci      197.26 K        5.07 μs   ±234.96%        4.96 μs        6.92 μs

##### With input 7 #####
Name                          ips        average  deviation         median         99th %
Very Slow Fibonacci      124.23 K        8.05 μs    ±52.30%        7.92 μs          11 μs

##### With input 8 #####
Name                          ips        average  deviation         median         99th %
Very Slow Fibonacci       78.44 K       12.75 μs    ±16.64%       12.58 μs       17.33 μs

##### With input 9 #####
Name                          ips        average  deviation         median         99th %
Very Slow Fibonacci       48.28 K       20.71 μs    ±10.17%       20.42 μs       27.50 μs
```

|                   |1  |2   |3   |4   |5   |6   |7   |8    |9    |10   |
|:------------------|--:|---:|---:|---:|---:|---:|---:|----:|----:|----:|
|Very Slow Fibonacci|686|1060|1430|2130|3240|5070|8050|12750|20710|33420|

![Very Slow Fibonacci](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/bc6f04aa-c9a3-e032-f00e-8743838fc452.png)

実行時間を指数関数で近似できました．

## memoization

```elixir:fib_benchee.exs
Mix.install([:benchee])

defmodule Fibonacci do
  def of(n)
  def of(0), do: 0
  def of(1), do: 1
  def of(n), do: of(n - 2) + of(n - 1)
end

defmodule Fibonacci.Memoization do
  use Agent

  def start_link(initial_value) when is_map(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def of(n) do
    case Agent.get(__MODULE__, & &1) do
      map when is_map_key(map, n) -> 
        Map.get(map, n)

      _ -> 
        result = 
          case n do
            0 -> 0
            1 -> 1
            n -> of(n - 2) + of(n - 1)
          end

        Agent.update(__MODULE__, &(Map.put(&1, n, result)))
        result
    end
  end
end

Benchee.run(
  %{
    "Very Slow Fibonacci" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.of(input) end) end,
    "Fibonacci with Memoization" => 
      {
        fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Memoization.of(input) end) end,
        before_scenario: fn input -> 
          Fibonacci.Memoization.start_link(%{})
          input
        end
      }
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
    "9" => 9,
    "10" => 10,
    "11" => 11,
    "12" => 12,
    "13" => 13,
    "14" => 14,
    "15" => 15,
    "16" => 16,
    "17" => 17,
    "18" => 18,
    "19" => 19,
    "20" => 20
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
inputs: 1, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 2, 20, 3, 4, 5, 6, 7, 8, 9
Estimated total run time: 4 min 40 s

Benchmarking Fibonacci with Memoization with input 1 ...
Benchmarking Fibonacci with Memoization with input 10 ...
Benchmarking Fibonacci with Memoization with input 11 ...
Benchmarking Fibonacci with Memoization with input 12 ...
Benchmarking Fibonacci with Memoization with input 13 ...
Benchmarking Fibonacci with Memoization with input 14 ...
Benchmarking Fibonacci with Memoization with input 15 ...
Benchmarking Fibonacci with Memoization with input 16 ...
Benchmarking Fibonacci with Memoization with input 17 ...
Benchmarking Fibonacci with Memoization with input 18 ...
Benchmarking Fibonacci with Memoization with input 19 ...
Benchmarking Fibonacci with Memoization with input 2 ...
Benchmarking Fibonacci with Memoization with input 20 ...
Benchmarking Fibonacci with Memoization with input 3 ...
Benchmarking Fibonacci with Memoization with input 4 ...
Benchmarking Fibonacci with Memoization with input 5 ...
Benchmarking Fibonacci with Memoization with input 6 ...
Benchmarking Fibonacci with Memoization with input 7 ...
Benchmarking Fibonacci with Memoization with input 8 ...
Benchmarking Fibonacci with Memoization with input 9 ...
Benchmarking Very Slow Fibonacci with input 1 ...
Benchmarking Very Slow Fibonacci with input 10 ...
Benchmarking Very Slow Fibonacci with input 11 ...
Benchmarking Very Slow Fibonacci with input 12 ...
Benchmarking Very Slow Fibonacci with input 13 ...
Benchmarking Very Slow Fibonacci with input 14 ...
Benchmarking Very Slow Fibonacci with input 15 ...
Benchmarking Very Slow Fibonacci with input 16 ...
Benchmarking Very Slow Fibonacci with input 17 ...
Benchmarking Very Slow Fibonacci with input 18 ...
Benchmarking Very Slow Fibonacci with input 19 ...
Benchmarking Very Slow Fibonacci with input 2 ...
Benchmarking Very Slow Fibonacci with input 20 ...
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
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci               1.39 M        0.72 μs  ±2294.72%        0.67 μs        0.96 μs
Fibonacci with Memoization      0.0129 M       77.31 μs     ±5.92%       76.25 μs       97.25 μs

Comparison: 
Very Slow Fibonacci               1.39 M
Fibonacci with Memoization      0.0129 M - 107.23x slower +76.59 μs

##### With input 10 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci              29.46 K       33.94 μs     ±6.86%       33.50 μs          46 μs
Fibonacci with Memoization       12.52 K       79.85 μs     ±7.83%       78.29 μs      100.00 μs

Comparison: 
Very Slow Fibonacci              29.46 K
Fibonacci with Memoization       12.52 K - 2.35x slower +45.91 μs

##### With input 11 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci              18.01 K       55.52 μs     ±6.33%       54.88 μs       72.42 μs
Fibonacci with Memoization       12.49 K       80.05 μs     ±8.09%       78.50 μs      101.38 μs

Comparison: 
Very Slow Fibonacci              18.01 K
Fibonacci with Memoization       12.49 K - 1.44x slower +24.52 μs

##### With input 12 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci with Memoization       12.32 K       81.16 μs     ±4.84%       82.50 μs       93.96 μs
Very Slow Fibonacci              11.16 K       89.62 μs    ±15.19%       88.17 μs      110.58 μs

Comparison: 
Fibonacci with Memoization       12.32 K
Very Slow Fibonacci              11.16 K - 1.10x slower +8.46 μs

##### With input 13 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci with Memoization       12.14 K       82.36 μs     ±5.22%       83.50 μs       98.83 μs
Very Slow Fibonacci               6.91 K      144.71 μs     ±5.42%      142.17 μs      174.67 μs

Comparison: 
Fibonacci with Memoization       12.14 K
Very Slow Fibonacci               6.91 K - 1.76x slower +62.35 μs

##### With input 14 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci with Memoization       12.51 K       79.92 μs     ±6.14%       79.21 μs       93.83 μs
Very Slow Fibonacci               4.27 K      234.23 μs     ±4.30%      230.34 μs      277.22 μs

Comparison: 
Fibonacci with Memoization       12.51 K
Very Slow Fibonacci               4.27 K - 2.93x slower +154.31 μs

##### With input 15 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci with Memoization       12.20 K       81.99 μs     ±6.64%       82.29 μs      101.21 μs
Very Slow Fibonacci               2.65 K      376.73 μs     ±3.19%      372.30 μs      427.34 μs

Comparison: 
Fibonacci with Memoization       12.20 K
Very Slow Fibonacci               2.65 K - 4.59x slower +294.74 μs

##### With input 16 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci with Memoization       11.98 K       83.45 μs     ±5.81%       83.38 μs      103.54 μs
Very Slow Fibonacci               1.64 K      608.78 μs     ±3.20%      602.09 μs      702.37 μs

Comparison: 
Fibonacci with Memoization       11.98 K
Very Slow Fibonacci               1.64 K - 7.29x slower +525.32 μs

##### With input 17 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci with Memoization       11.92 K       83.90 μs     ±5.44%       84.04 μs      101.04 μs
Very Slow Fibonacci               1.01 K      987.62 μs     ±2.98%      974.99 μs     1119.12 μs

Comparison: 
Fibonacci with Memoization       11.92 K
Very Slow Fibonacci               1.01 K - 11.77x slower +903.72 μs

##### With input 18 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci with Memoization       11.94 K      0.0837 ms     ±5.48%      0.0839 ms       0.101 ms
Very Slow Fibonacci               0.62 K        1.60 ms     ±2.21%        1.60 ms        1.72 ms

Comparison: 
Fibonacci with Memoization       11.94 K
Very Slow Fibonacci               0.62 K - 19.11x slower +1.52 ms

##### With input 19 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci with Memoization       11.70 K      0.0855 ms     ±6.24%      0.0848 ms       0.102 ms
Very Slow Fibonacci               0.38 K        2.60 ms     ±2.99%        2.58 ms        2.92 ms

Comparison: 
Fibonacci with Memoization       11.70 K
Very Slow Fibonacci               0.38 K - 30.44x slower +2.52 ms

##### With input 2 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             922.46 K        1.08 μs  ±1279.19%        1.04 μs        1.46 μs
Fibonacci with Memoization       11.73 K       85.25 μs     ±4.56%       84.71 μs         101 μs

Comparison: 
Very Slow Fibonacci             922.46 K
Fibonacci with Memoization       11.73 K - 78.64x slower +84.16 μs

##### With input 20 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci with Memoization       11.66 K      0.0857 ms     ±4.90%      0.0848 ms       0.103 ms
Very Slow Fibonacci               0.24 K        4.23 ms     ±2.61%        4.21 ms        4.60 ms

Comparison: 
Fibonacci with Memoization       11.66 K
Very Slow Fibonacci               0.24 K - 49.33x slower +4.14 ms

##### With input 3 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             695.91 K        1.44 μs   ±843.66%        1.38 μs        1.83 μs
Fibonacci with Memoization       11.68 K       85.64 μs     ±5.24%       85.29 μs      102.88 μs

Comparison: 
Very Slow Fibonacci             695.91 K
Fibonacci with Memoization       11.68 K - 59.60x slower +84.21 μs

##### With input 4 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             460.09 K        2.17 μs   ±468.75%        2.08 μs        2.92 μs
Fibonacci with Memoization       11.72 K       85.34 μs     ±4.99%       84.83 μs      102.13 μs

Comparison: 
Very Slow Fibonacci             460.09 K
Fibonacci with Memoization       11.72 K - 39.27x slower +83.17 μs

##### With input 5 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             309.01 K        3.24 μs   ±276.02%        3.13 μs        4.17 μs
Fibonacci with Memoization       11.72 K       85.30 μs     ±4.64%       84.63 μs      101.79 μs

Comparison: 
Very Slow Fibonacci             309.01 K
Fibonacci with Memoization       11.72 K - 26.36x slower +82.06 μs

##### With input 6 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             195.39 K        5.12 μs   ±144.98%        4.96 μs        6.92 μs
Fibonacci with Memoization       11.70 K       85.45 μs     ±4.79%       84.75 μs      103.25 μs

Comparison: 
Very Slow Fibonacci             195.39 K
Fibonacci with Memoization       11.70 K - 16.70x slower +80.33 μs

##### With input 7 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             123.82 K        8.08 μs    ±59.04%        7.88 μs       10.92 μs
Fibonacci with Memoization       11.70 K       85.50 μs     ±4.33%       84.75 μs      101.51 μs

Comparison: 
Very Slow Fibonacci             123.82 K
Fibonacci with Memoization       11.70 K - 10.59x slower +77.42 μs

##### With input 8 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci              76.18 K       13.13 μs    ±23.33%       12.75 μs       17.67 μs
Fibonacci with Memoization       11.71 K       85.41 μs     ±5.24%       84.79 μs      104.17 μs

Comparison: 
Very Slow Fibonacci              76.18 K
Fibonacci with Memoization       11.71 K - 6.51x slower +72.28 μs

##### With input 9 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci              47.50 K       21.05 μs     ±8.93%       20.46 μs       28.46 μs
Fibonacci with Memoization       11.69 K       85.53 μs    ±11.58%       84.63 μs      101.88 μs

Comparison: 
Very Slow Fibonacci              47.50 K
Fibonacci with Memoization       11.69 K - 4.06x slower +64.47 μs
```

##### With input 20 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci with Memoization       11.66 K      0.0857 ms     ±4.90%      0.0848 ms       0.103 ms
Very Slow Fibonacci               0.24 K        4.23 ms     ±2.61%        4.21 ms        4.60 ms


|                          |1    |2    |3    |4    |5    |6    |7    |8    |9    |10   |11   |12   |13    |14    |15    |16    |17    |18     |19     |20     |
|:-------------------------|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|----:|-----:|-----:|-----:|-----:|-----:|------:|------:|------:|
|Very Slow Fibonacci       |720  |1080 |1440 |2170 |3240 |5120 |8080 |13130|21060|33940|55520|89620|144710|234230|376730|608780|987620|1600000|2600000|4230000|
|Fibonacci with Memoization|77310|85250|85640|85340|85300|85450|85500|85410|85530|79850|80050|81160| 82360| 79920| 81990| 83450| 83900|  83700|  85500|  85700|

![Very Slow Fibonacci vs Fibonacci with Memoization](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/aabbaf77-c3af-f8e3-fb39-c8267addd976.png)

11くらいまでだとVery Slow Fibonacciの方が速く，12以降でFibonacci with Memoizationの方が速くなることがわかります．プロセスを用いたので，Memoizationのオーバーヘッドが思ったより大きいですね．

つづく．
