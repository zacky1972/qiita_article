---
title: DRP-AI日記その5 OpenBLASを実行してみる
tags:
  - Ubuntu
  - Elixir
  - OpenBLAS
  - DRP-AI
  - Kakip
private: false
updated_at: '2025-01-07T07:27:06+09:00'
id: 02be10d1acc013a499d2
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
KakipでOpenBLASを実行してみました．

DRP-AIシリーズ・Kakip

- [DRP-AI日記その1 なぜDRP-AIシリーズに取り組むのか](https://qiita.com/zacky1972/items/3ebf021cab1e972890f8)
- [DRP-AI日記その2 Kakipを起動してみた](https://qiita.com/zacky1972/items/438ddc192fc499fb697c)
- [DRP-AI日記その3 Kakipネットワーク等初期設定](https://qiita.com/zacky1972/items/ab6a176f0ad481473f71)
- [DRP-AI日記その4 Elixirのインストール](https://qiita.com/zacky1972/items/922176433e54046b8338)

## OpenBLASを入れたNxの実行手順

注意: 2025年1月7日にNxSgemmに対して行った破壊的更新のため，GitHubのmainブランチのコードでは動作しなくなっています．

```bash
sudo apt update
sudo apt install libopenblas-dev
git clone https://github.com/zacky1972/nx_sgemm.git
cd nx_sgemm/
mix deps.get
mix test
```

## ベンチマーク

```bash
mix new nx_sgemm_bench_openblas
```

```elixir:mix.exs
defmodule NxSgemmBenchOpenblas.MixProject do
  use Mix.Project

  def project do
    [
      app: :nx_sgemm_bench_openblas,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:nx_sgemm, github: "zacky1972/nx_sgemm", branch: "main"},
      {:benchee, "~> 1.0", only: :dev}
    ]
  end
end
```

```bash
mix deps.get 
mix compile
```

```elixir:benchmark.exs
Benchee.run(
  %{
    "Nx" => fn input -> Nx.multiply(input, 2.0) end,
    "OpenBLAS" => fn input -> NxSgemm.multiply(input, 2.0) end
  },
  inputs: %{
    "Small" => Nx.iota({1_000}) |> Nx.multiply(1.0),
    "Medium" => Nx.iota({10_000}) |> Nx.multiply(1.0),
    "Bigger" => Nx.iota({100_000}) |> Nx.multiply(1.0)
  }
)
```

## Kakipでの実行結果

```bash
$ mix run -r benchmark.exs
Operating System: Linux
CPU Information: Unrecognized processor
Number of Available Cores: 4
Available memory: 7.02 GB
Elixir 1.18.1
Erlang 27.2
JIT enabled: true

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
reduction time: 0 ns
parallel: 1
inputs: Bigger, Medium, Small
Estimated total run time: 42 s

Benchmarking Nx with input Bigger ...
Benchmarking Nx with input Medium ...
Benchmarking Nx with input Small ...
Benchmarking OpenBLAS with input Bigger ...
Benchmarking OpenBLAS with input Medium ...
Benchmarking OpenBLAS with input Small ...
Calculating statistics...
Formatting results...

##### With input Bigger #####
Name               ips        average  deviation         median         99th %
OpenBLAS        2.83 K        0.35 ms     ±8.04%        0.35 ms        0.44 ms
Nx           0.00883 K      113.22 ms     ±5.90%      108.35 ms      122.41 ms

Comparison: 
OpenBLAS        2.83 K
Nx           0.00883 K - 320.41x slower +112.87 ms

##### With input Medium #####
Name               ips        average  deviation         median         99th %
OpenBLAS       26.88 K      0.0372 ms    ±38.05%      0.0351 ms      0.0616 ms
Nx             0.111 K        9.00 ms     ±2.23%        8.90 ms        9.47 ms

Comparison: 
OpenBLAS       26.88 K
Nx             0.111 K - 241.77x slower +8.96 ms

##### With input Small #####
Name               ips        average  deviation         median         99th %
OpenBLAS      136.96 K        7.30 μs   ±337.95%        6.42 μs       65.63 μs
Nx              1.10 K      911.64 μs     ±3.22%      906.96 μs     1017.12 μs

Comparison: 
OpenBLAS      136.96 K
Nx              1.10 K - 124.86x slower +904.34 μs
```

CPUで実行したときにOpenBLASを使うとこのくらいは速くなります．

* Bigger: 320.41倍
* Medium: 241.77倍
* Small: 124.86倍
