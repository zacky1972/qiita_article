---
title: Elixirでフィボナッチ数列をいろいろ書いてみた Part. 2
tags:
  - Elixir
  - フィボナッチ数列
private: false
updated_at: '2024-12-30T06:56:58+09:00'
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
    |> Enum.take(n + 1)
    |> Enum.reverse()
    |> hd()
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
Very Slow Fibonacci            1406.94 K        0.71 μs  ±2305.62%        0.67 μs        0.88 μs
Fibonacci by Stream             281.39 K        3.55 μs   ±178.07%        3.38 μs       11.38 μs
Fibonacci with Memoization       12.84 K       77.88 μs     ±3.91%       77.08 μs       88.22 μs

Comparison: 
Very Slow Fibonacci            1406.94 K
Fibonacci by Stream             281.39 K - 5.00x slower +2.84 μs
Fibonacci with Memoization       12.84 K - 109.58x slower +77.17 μs

##### With input 2 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             931.12 K        1.07 μs  ±1467.05%           1 μs        1.33 μs
Fibonacci by Stream             201.96 K        4.95 μs    ±96.67%        4.67 μs       13.25 μs
Fibonacci with Memoization       12.45 K       80.29 μs     ±4.85%       81.50 μs       92.17 μs

Comparison: 
Very Slow Fibonacci             931.12 K
Fibonacci by Stream             201.96 K - 4.61x slower +3.88 μs
Fibonacci with Memoization       12.45 K - 74.76x slower +79.22 μs

##### With input 3 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             693.15 K        1.44 μs   ±825.91%        1.38 μs        1.83 μs
Fibonacci by Stream             183.73 K        5.44 μs   ±125.15%        5.29 μs       13.25 μs
Fibonacci with Memoization       12.27 K       81.47 μs     ±4.35%       82.71 μs       90.63 μs

Comparison: 
Very Slow Fibonacci             693.15 K
Fibonacci by Stream             183.73 K - 3.77x slower +4.00 μs
Fibonacci with Memoization       12.27 K - 56.47x slower +80.03 μs

##### With input 4 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             471.11 K        2.12 μs   ±489.73%        2.08 μs        2.67 μs
Fibonacci by Stream             157.45 K        6.35 μs    ±88.26%           6 μs       14.75 μs
Fibonacci with Memoization       12.24 K       81.68 μs     ±3.70%       81.96 μs          90 μs

Comparison: 
Very Slow Fibonacci             471.11 K
Fibonacci by Stream             157.45 K - 2.99x slower +4.23 μs
Fibonacci with Memoization       12.24 K - 38.48x slower +79.55 μs

##### With input 5 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             312.27 K        3.20 μs   ±238.72%        3.13 μs        4.08 μs
Fibonacci by Stream             133.63 K        7.48 μs    ±55.49%        7.04 μs       15.54 μs
Fibonacci with Memoization       12.25 K       81.65 μs     ±5.39%       82.38 μs       98.79 μs

Comparison: 
Very Slow Fibonacci             312.27 K
Fibonacci by Stream             133.63 K - 2.34x slower +4.28 μs
Fibonacci with Memoization       12.25 K - 25.50x slower +78.45 μs

##### With input 6 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             198.97 K        5.03 μs   ±138.76%        4.92 μs        6.38 μs
Fibonacci by Stream             119.55 K        8.37 μs    ±49.43%           8 μs       16.33 μs
Fibonacci with Memoization       12.06 K       82.90 μs     ±5.57%       82.71 μs      101.25 μs

Comparison: 
Very Slow Fibonacci             198.97 K
Fibonacci by Stream             119.55 K - 1.66x slower +3.34 μs
Fibonacci with Memoization       12.06 K - 16.50x slower +77.88 μs

##### With input 7 #####
Name                                 ips        average  deviation         median         99th %
Very Slow Fibonacci             125.99 K        7.94 μs    ±57.76%        7.83 μs       10.21 μs
Fibonacci by Stream             106.81 K        9.36 μs    ±45.03%        9.08 μs       15.21 μs
Fibonacci with Memoization       12.23 K       81.77 μs     ±3.82%       82.42 μs       90.63 μs

Comparison: 
Very Slow Fibonacci             125.99 K
Fibonacci by Stream             106.81 K - 1.18x slower +1.43 μs
Fibonacci with Memoization       12.23 K - 10.30x slower +73.83 μs

##### With input 8 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci by Stream              96.53 K       10.36 μs    ±36.83%       10.08 μs       15.42 μs
Very Slow Fibonacci              79.27 K       12.61 μs    ±13.84%       12.50 μs       15.29 μs
Fibonacci with Memoization       12.15 K       82.32 μs     ±3.03%       82.46 μs       90.63 μs

Comparison: 
Fibonacci by Stream              96.53 K
Very Slow Fibonacci              79.27 K - 1.22x slower +2.26 μs
Fibonacci with Memoization       12.15 K - 7.95x slower +71.96 μs

##### With input 9 #####
Name                                 ips        average  deviation         median         99th %
Fibonacci by Stream              86.40 K       11.57 μs    ±36.94%       11.71 μs       13.67 μs
Very Slow Fibonacci              48.73 K       20.52 μs     ±6.16%       20.41 μs       23.04 μs
Fibonacci with Memoization       12.13 K       82.42 μs     ±6.12%       82.67 μs      101.58 μs

Comparison: 
Fibonacci by Stream              86.40 K
Very Slow Fibonacci              48.73 K - 1.77x slower +8.95 μs
Fibonacci with Memoization       12.13 K - 7.12x slower +70.84 μs
```

|                          |1    |2    |3    |4    |5    |6    |7    |8    |9    |
|:-------------------------|----:|----:|----:|----:|----:|----:|----:|----:|----:|
|Very Slow Fibonacci       |  710| 1070| 1440| 2120| 3200| 5030| 7940|12610|20520|
|Fibonacci by Stream       | 3550| 4950| 5440| 6350| 7480| 8370| 9360|10360|11570|
|Fibonacci with Memoization|77880|80290|81470|81680|81650|82900|81770|82320|82420|

![Fibonacci by Stream](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/8bb952d9-ca35-1273-dc82-cc170f07e94b.png)

8以上でFibonacci by Streamが高速になります．Fibonacci with Memoization をStream用いても良さそうですね．トレンドラインを見ると， $y = 969.5x + 2644.7$ なので，80以上だとFibonacci with MemoizationがFibonacci by Streamより高速になる可能性があります．


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
    |> Enum.take(n + 1)
    |> Enum.reverse()
    |> hd()
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
          |> Enum.take(n + 1)
          |> Enum.reverse()
          |> hd()

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
    "80" => 80
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
inputs: 80
Estimated total run time: 21 s

Benchmarking Fibonacci by Stream with input 80 ...
Benchmarking Fibonacci with Memoization with input 80 ...
Benchmarking Fibonacci with Memoization and Stream with input 80 ...
Calculating statistics...
Formatting results...

##### With input 80 #####
Name                                            ips        average  deviation         median         99th %
Fibonacci with Memoization and Stream       13.02 K       76.79 μs     ±4.38%       75.67 μs       91.46 μs
Fibonacci by Stream                         12.34 K       81.06 μs     ±6.18%       79.96 μs       97.58 μs
Fibonacci with Memoization                   7.74 K      129.25 μs     ±3.46%      127.75 μs      148.25 μs

Comparison: 
Fibonacci with Memoization and Stream       13.02 K
Fibonacci by Stream                         12.34 K - 1.06x slower +4.27 μs
Fibonacci with Memoization                   7.74 K - 1.68x slower +52.46 μs
```

目論見通り，80の時に，Fibonacci with Memoization and Stream が Fibonacci by Stream よりも高速になりました．

