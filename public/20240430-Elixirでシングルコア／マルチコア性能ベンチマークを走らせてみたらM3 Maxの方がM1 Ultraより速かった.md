---
title: Elixirでシングルコア／マルチコア性能ベンチマークを走らせてみたらM3 Maxの方がM1 Ultraより速かった
tags:
  - Elixir
  - M3
  - M1
  - AppleSilicon
private: false
updated_at: '2024-04-30T19:06:04+09:00'
id: d561052df292050094dd
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[ElixirのCPUバウンド並列処理ベンチマーク](https://qiita.com/zacky1972/items/fc317a7aa4a132a33ef3)を使って，M3 Max 全部入りとM1 Ultra全部入りのシングルコア／マルチコア性能を比較してみたところ，M3 Maxの方がマルチコア性能で2.5倍，シングルコア性能で1.24倍速かったです！


```elixir:bench.exs
Mix.install([:flow, :benchee])

Benchee.run(
  %{
    "sequential execution" => fn -> 1..1_000_000 |> Enum.map(fn _ -> :crypto.strong_rand_bytes(1000) end) |> Enum.map(& Base.encode32(&1, case: :lower)) end,
    "parallel execution" => fn -> 1..1_000_000 |> Flow.from_enumerable() |> Flow.map(fn _ -> :crypto.strong_rand_bytes(1000) end) |> Flow.map(& Base.encode32(&1, case: :lower)) |> Enum.to_list() end
  }
)
```

```zsh: elixir -v on M3 Max
Erlang/OTP 26 [erts-14.2.4] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit]

Elixir 1.16.2 (compiled with Erlang/OTP 26)
```

```txt:benchmark results (M3 Max)
Operating System: macOS
CPU Information: Apple M3 Max
Number of Available Cores: 16
Available memory: 128 GB
Elixir 1.16.2
Erlang 26.2.4
JIT enabled: true

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
reduction time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 14 s

Benchmarking parallel execution ...
Benchmarking sequential execution ...
Calculating statistics...
Formatting results...

Name                           ips        average  deviation         median         99th %
parallel execution            2.55         0.39 s     ±2.48%         0.39 s         0.40 s
sequential execution          0.36         2.76 s     ±4.98%         2.76 s         2.86 s

Comparison: 
parallel execution            2.55
sequential execution          0.36 - 7.06x slower +2.37 s
```

```zsh: elixir -v on M1 Ultra
Erlang/OTP 26 [erts-14.2.4] [source] [64-bit] [smp:20:20] [ds:20:20:10] [async-threads:1] [jit]

Elixir 1.16.2 (compiled with Erlang/OTP 26)
```


```txt:benchmark results (M1 Ultra)
Operating System: macOS
CPU Information: Apple M1 Ultra
Number of Available Cores: 20
Available memory: 128 GB
Elixir 1.16.2
Erlang 26.2.4
JIT enabled: true

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
reduction time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 14 s

Benchmarking parallel execution ...
Benchmarking sequential execution ...
Calculating statistics...
Formatting results...

Name                           ips        average  deviation         median         99th %
parallel execution            1.02         0.98 s     ±5.48%         1.00 s         1.01 s
sequential execution          0.29         3.41 s     ±3.94%         3.41 s         3.50 s

Comparison: 
parallel execution            1.02
sequential execution          0.29 - 3.47x slower +2.42 s
```

