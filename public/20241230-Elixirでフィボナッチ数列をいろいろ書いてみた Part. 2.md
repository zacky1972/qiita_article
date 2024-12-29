---
title: Elixirでフィボナッチ数列をいろいろ書いてみた Part. 2
tags:
  - Elixir
  - フィボナッチ数列
private: false
updated_at: '2024-12-30T07:27:17+09:00'
id: fed96c37aef3a09da0c5
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
@mod_poppoさんの[Haskellでフィボナッチ数列 〜Haskellで非実用的なコードを書いて悦に入るのはやめろ〜](https://qiita.com/mod_poppo/items/4f78d135bb43b7fd1743)にインスピレーションを得て，Elixirでフィボナッチ数列をいろいろ書いてみるシリーズ記事の第2弾です．

https://qiita.com/mod_poppo/items/4f78d135bb43b7fd1743

フィボナッチ数列シリーズ

- [Elixirでフィボナッチ数列をいろいろ書いてみた Part. 1](https://qiita.com/zacky1972/items/74f7ce9b6463862ea5bb)

## Stream版

```elixir:fib_benchee.exs
Mix.install([:benchee])

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

defmodule Fibonacci do
  def of(n)
  def of(0), do: 0
  def of(1), do: 1
  def of(n), do: of(n - 2) + of(n - 1)
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
      },
    "Fibonacci by Stream" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Stream.of(input) end) end
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
Estimated total run time: 3 min 9 s

Benchmarking Fibonacci by Stream with input 1 ...
Benchmarking Fibonacci by Stream with input 2 ...
Benchmarking Fibonacci by Stream with input 3 ...
Benchmarking Fibonacci by Stream with input 4 ...
Benchmarking Fibonacci by Stream with input 5 ...
Benchmarking Fibonacci by Stream with input 6 ...
Benchmarking Fibonacci by Stream with input 7 ...
Benchmarking Fibonacci by Stream with input 8 ...
Benchmarking Fibonacci by Stream with input 9 ...
Benchmarking Fibonacci with Memoization with input 1 ...
Benchmarking Fibonacci with Memoization with input 2 ...
Benchmarking Fibonacci with Memoization with input 3 ...
Benchmarking Fibonacci with Memoization with input 4 ...
Benchmarking Fibonacci with Memoization with input 5 ...
Benchmarking Fibonacci with Memoization with input 6 ...
Benchmarking Fibonacci with Memoization with input 7 ...
Benchmarking Fibonacci with Memoization with input 8 ...
Benchmarking Fibonacci with Memoization with input 9 ...
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
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci            1404.29 K        0.71 μs  ±1952.22%        0.67 μs        0.92 μs
Fibonacci by Stream             240.19 K        4.16 μs   ±171.21%        3.92 μs       11.92 μs
Fibonacci with Memoization       12.24 K       81.71 μs     ±4.21%       81.04 μs       95.97 μs

Comparison: 
Very Slow Fibonacci            1404.29 K
Fibonacci by Stream             240.19 K - 5.85x slower +3.45 μs
Fibonacci with Memoization       12.24 K - 114.74x slower +81.00 μs

##### With input 2 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             931.64 K        1.07 μs  ±1275.82%           1 μs        1.42 μs
Fibonacci by Stream             208.66 K        4.79 μs   ±101.32%        4.46 μs       12.92 μs
Fibonacci with Memoization       12.11 K       82.55 μs     ±5.75%       81.96 μs       98.36 μs

Comparison: 
Very Slow Fibonacci             931.64 K
Fibonacci by Stream             208.66 K - 4.46x slower +3.72 μs
Fibonacci with Memoization       12.11 K - 76.91x slower +81.48 μs

##### With input 3 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             690.37 K        1.45 μs   ±702.67%        1.38 μs        1.92 μs
Fibonacci by Stream             186.12 K        5.37 μs    ±99.65%        5.04 μs       13.75 μs
Fibonacci with Memoization       11.96 K       83.60 μs     ±3.94%       82.75 μs       98.42 μs

Comparison: 
Very Slow Fibonacci             690.37 K
Fibonacci by Stream             186.12 K - 3.71x slower +3.92 μs
Fibonacci with Memoization       11.96 K - 57.72x slower +82.15 μs

##### With input 4 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             459.56 K        2.18 μs   ±484.04%        2.08 μs        2.88 μs
Fibonacci by Stream             168.18 K        5.95 μs    ±77.67%        5.75 μs       12.50 μs
Fibonacci with Memoization       12.12 K       82.49 μs     ±4.87%       82.21 μs       98.42 μs

Comparison: 
Very Slow Fibonacci             459.56 K
Fibonacci by Stream             168.18 K - 2.73x slower +3.77 μs
Fibonacci with Memoization       12.12 K - 37.91x slower +80.31 μs

##### With input 5 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             306.73 K        3.26 μs   ±252.74%        3.13 μs        4.38 μs
Fibonacci by Stream             153.15 K        6.53 μs    ±96.25%        6.21 μs       15.08 μs
Fibonacci with Memoization       11.96 K       83.61 μs     ±5.60%       82.75 μs       99.54 μs

Comparison: 
Very Slow Fibonacci             306.73 K
Fibonacci by Stream             153.15 K - 2.00x slower +3.27 μs
Fibonacci with Memoization       11.96 K - 25.65x slower +80.35 μs

##### With input 6 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             194.14 K        5.15 μs   ±120.03%           5 μs        6.92 μs
Fibonacci by Stream             139.24 K        7.18 μs    ±54.31%        6.83 μs       15.79 μs
Fibonacci with Memoization       12.01 K       83.26 μs     ±4.48%       82.33 μs       98.75 μs

Comparison: 
Very Slow Fibonacci             194.14 K
Fibonacci by Stream             139.24 K - 1.39x slower +2.03 μs
Fibonacci with Memoization       12.01 K - 16.16x slower +78.10 μs

##### With input 7 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci by Stream             128.01 K        7.81 μs    ±56.62%        7.50 μs       16.42 μs
Very Slow Fibonacci             123.90 K        8.07 μs    ±52.85%        7.88 μs       10.92 μs
Fibonacci with Memoization       12.06 K       82.91 μs     ±4.31%       82.08 μs          98 μs

Comparison: 
Fibonacci by Stream             128.01 K
Very Slow Fibonacci             123.90 K - 1.03x slower +0.26 μs
Fibonacci with Memoization       12.06 K - 10.61x slower +75.10 μs

##### With input 8 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci by Stream             115.56 K        8.65 μs    ±54.84%        8.33 μs       17.33 μs
Very Slow Fibonacci              77.14 K       12.96 μs    ±15.92%       12.63 μs       17.54 μs
Fibonacci with Memoization       12.09 K       82.71 μs     ±5.32%       81.71 μs       99.13 μs

Comparison: 
Fibonacci by Stream             115.56 K
Very Slow Fibonacci              77.14 K - 1.50x slower +4.31 μs
Fibonacci with Memoization       12.09 K - 9.56x slower +74.06 μs

##### With input 9 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci by Stream             107.45 K        9.31 μs    ±34.49%        9.13 μs       15.25 μs
Very Slow Fibonacci              47.55 K       21.03 μs     ±9.72%       20.63 μs       28.33 μs
Fibonacci with Memoization       12.05 K       83.00 μs     ±5.11%       82.13 μs       99.08 μs

Comparison: 
Fibonacci by Stream             107.45 K
Very Slow Fibonacci              47.55 K - 2.26x slower +11.72 μs
Fibonacci with Memoization       12.05 K - 8.92x slower +73.70 μs
```

|                          |1    |2    |3    |4    |5    |6    |7    |8    |9    |
|:-------------------------|----:|----:|----:|----:|----:|----:|----:|----:|----:|
|Very Slow Fibonacci       |  710| 1070| 1450| 2180| 3260| 5150| 8070|12960|21030|
|Fibonacci by Stream       | 4160| 4790| 5370| 5950| 6530| 7180| 7810| 8650| 9310|
|Fibonacci with Memoization|81710|82550|83600|82490|83610|83260|82910|82710|83000|

![Fibonacci by Stream](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/94f1e8ef-f68e-bab9-6801-d590b2795aaf.png)


7以上でFibonacci by Streamが高速になります．Fibonacci with Memoization でStream用いても良さそうですね．トレンドラインを見ると， $y = 638.17x + 3448.1$ なので，120以上だとFibonacci with MemoizationがFibonacci by Streamより高速になる可能性があります．


## StreamつきMemoization

```elixir:fib_benchee.exs
Mix.install([:benchee])

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

defmodule Fibonacci.Memoization.Stream do
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
          Stream.unfold([], fn
            [] -> {0, [0]}
            [0] -> {1, [1, 0]}
            [m, n] -> {m + n, [m + n, m]}
          end)
          |> Enum.at(n)

        Agent.update(__MODULE__, &(Map.put(&1, n, result)))
        result
    end
  end
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
    "Fibonacci with Memoization" => 
      {
        fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Memoization.of(input) end) end,
        before_scenario: fn input -> 
          Fibonacci.Memoization.start_link(%{})
          input
        end
      },
    "Fibonacci with Memoization and Stream" => 
      {
        fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Memoization.Stream.of(input) end) end,
        before_scenario: fn input -> 
          Fibonacci.Memoization.Stream.start_link(%{})
          input
        end
      },
    "Fibonacci by Stream" => fn input -> Enum.reduce(1..100, fn _, _ -> Fibonacci.Stream.of(input) end) end
  },
  inputs: %{
    "120" => 120
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
inputs: 120
Estimated total run time: 21 s

Benchmarking Fibonacci by Stream with input 120 ...
Benchmarking Fibonacci with Memoization with input 120 ...
Benchmarking Fibonacci with Memoization and Stream with input 120 ...
Calculating statistics...
Formatting results...

##### With input 120 #####
Name                                            ips        average  deviation         median         99th %
Fibonacci with Memoization and Stream       12.72 K       78.60 μs     ±7.37%       76.58 μs       98.04 μs
Fibonacci by Stream                          8.06 K      124.04 μs     ±6.33%      121.79 μs      153.08 μs
Fibonacci with Memoization                   5.63 K      177.74 μs     ±6.33%      175.13 μs      210.29 μs

Comparison: 
Fibonacci with Memoization and Stream       12.72 K
Fibonacci by Stream                          8.06 K - 1.58x slower +45.44 μs
Fibonacci with Memoization                   5.63 K - 2.26x slower +99.15 μs
```

目論見通り，120の時に，Fibonacci with Memoization and Stream が Fibonacci by Stream よりも高速になりました．

