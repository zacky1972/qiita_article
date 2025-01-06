---
title: SME日記その14 AppleBLASのSSCALでSMEが使われているかを検証してみる Part.1
tags:
  - Elixir
  - BLAS
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2025-01-07T07:27:07+09:00'
id: 9b22e23cd18a4912b99a
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
AppleBLASのSSCALでSMEが使われているかを検証すべく，ベンチマークプログラムをM3 MaxとM4 Proで動かします．

SMEシリーズ

- [Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている](https://qiita.com/zacky1972/items/69fd802fd41ae4d7d469)
- [SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension(SME)のベクトル長(SVL)を取得する](https://qiita.com/zacky1972/items/231fd22a1fdef15d4108)
- [SME日記その2: Apple Silicon M4にはCVTW命令は備わっていない？](https://qiita.com/zacky1972/items/a4fc98614df085586175)
- [SME日記その3: Apple Silicon M4にどの命令が実装されているかをsysctl hwの実行結果とドキュメントから推測する](https://qiita.com/zacky1972/items/427035001554cb9768bc)
- [SME日記その4 Streaming SVE modeでCNTWを実行してみる．](https://qiita.com/zacky1972/items/3182fa1693983846205d)
- [SME日記その5 Streaming SVE modeでCNTWを実行してみる Part 2](https://qiita.com/zacky1972/items/b7b5dd456fe021b30eb2)
- [SME日記その6 Streaming SVE modeでsvcntw()とsvcntsw()を実行してみる](https://qiita.com/zacky1972/items/7d4ec630d54564ebb9b3)
- [SME日記その7 svcntw()とRDSVL命令の実行結果の関係性を考察する](https://qiita.com/zacky1972/items/48cf7577e254b8c3a0b6)
- [SME日記その8 __arm_new("za")について調べる](https://qiita.com/zacky1972/items/762b73b3414369d762ad)
- [SME日記その9 OpenBLASのSME対応状況について調べる](https://qiita.com/zacky1972/items/0c6f5aed0365f1b4fdb6)
- [SME日記その10 Streaming SVE modeでCNTWを実行してみる(再考)](https://qiita.com/zacky1972/items/ba3e07a8bc1e5e56d19a)
- [SME日記その11 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.1](https://qiita.com/zacky1972/items/15bca5a0dcd3073d4d60)
- [SME日記その12 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.2](https://qiita.com/zacky1972/items/2d69ed8b7ae5840012db)
- [SME日記その13 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.3](https://qiita.com/zacky1972/items/5fe73657dd1e4b167320)

## ソースコード

https://github.com/zacky1972/nx_sgemm

注意: 2025年1月7日にNxSgemmに対して行った破壊的更新のため，GitHubのmainブランチのコードでは動作しなくなっています．

```zsh
mix new nx_sgemm_bench_openblas
```

```elixir:mix.exs
defmodule NxSgemmBenchOpenblas.MixProject do
  use Mix.Project

  def project do
    [
      app: :nx_sgemm_bench_openblas,
      version: "0.1.0",
      elixir: "~> 1.17",
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

```zsh
mix deps.get 
mix compile
```

```elixir:benchmark.exs
Benchee.run(
  %{
    "Nx" => fn input -> Nx.multiply(input, 2.0) end,
    "AppleBLAS" => fn input -> NxSgemm.multiply(input, 2.0) end
  },
  inputs: %{
    "Small" => Nx.iota({1_000}) |> Nx.multiply(1.0),
    "Medium" => Nx.iota({10_000}) |> Nx.multiply(1.0),
    "Bigger" => Nx.iota({100_000}) |> Nx.multiply(1.0)
  }
)
```

## M3 Max

```elixir
 % mix run -r benchmark.exs 
Compiling 1 file (.ex)
Generated nx_sgemm_bench_openblas app
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
inputs: Bigger, Medium, Small
Estimated total run time: 42 s

Benchmarking AppleBLAS with input Bigger ...
Benchmarking AppleBLAS with input Medium ...
Benchmarking AppleBLAS with input Small ...
Benchmarking Nx with input Bigger ...
Benchmarking Nx with input Medium ...
Benchmarking Nx with input Small ...
Calculating statistics...
Formatting results...

##### With input Bigger #####
Name                ips        average  deviation         median         99th %
AppleBLAS      117.31 K     0.00852 ms    ±57.49%     0.00833 ms     0.00946 ms
Nx               0.22 K        4.55 ms     ±2.98%        4.53 ms        4.95 ms

Comparison: 
AppleBLAS      117.31 K
Nx               0.22 K - 533.68x slower +4.54 ms

##### With input Medium #####
Name                ips        average  deviation         median         99th %
AppleBLAS      847.03 K        1.18 μs  ±1350.98%        1.08 μs        1.67 μs
Nx               2.62 K      381.30 μs     ±8.84%      375.92 μs      456.28 μs

Comparison: 
AppleBLAS      847.03 K
Nx               2.62 K - 322.97x slower +380.12 μs

##### With input Small #####
Name                ips        average  deviation         median         99th %
AppleBLAS        3.61 M        0.28 μs  ±6998.25%        0.21 μs        2.88 μs
Nx             0.0255 M       39.19 μs     ±8.26%       38.04 μs       50.75 μs

Comparison: 
AppleBLAS        3.61 M
Nx             0.0255 M - 141.41x slower +38.92 μs
```

## M4 Pro

```elixir
% mix run -r benchmark.exs
Compiling 1 file (.ex)
Generated nx_sgemm_bench_openblas app
Operating System: macOS
CPU Information: Apple M4 Pro
Number of Available Cores: 14
Available memory: 64 GB
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

Benchmarking AppleBLAS with input Bigger ...
Benchmarking AppleBLAS with input Medium ...
Benchmarking AppleBLAS with input Small ...
Benchmarking Nx with input Bigger ...
Benchmarking Nx with input Medium ...
Benchmarking Nx with input Small ...
Calculating statistics...
Formatting results...

##### With input Bigger #####
Name                ips        average  deviation         median         99th %
AppleBLAS      114.53 K     0.00873 ms    ±48.09%     0.00871 ms     0.00933 ms
Nx               0.26 K        3.78 ms     ±5.49%        3.76 ms        4.28 ms

Comparison: 
AppleBLAS      114.53 K
Nx               0.26 K - 433.25x slower +3.77 ms

##### With input Medium #####
Name                ips        average  deviation         median         99th %
AppleBLAS      953.64 K        1.05 μs  ±1650.92%        0.96 μs        1.46 μs
Nx               3.18 K      314.45 μs     ±8.41%      308.79 μs      398.93 μs

Comparison: 
AppleBLAS      953.64 K
Nx               3.18 K - 299.87x slower +313.40 μs

##### With input Small #####
Name                ips        average  deviation         median         99th %
AppleBLAS        3.97 M        0.25 μs  ±9895.77%        0.21 μs        2.54 μs
Nx             0.0321 M       31.11 μs     ±6.25%       31.63 μs       36.13 μs

Comparison: 
AppleBLAS        3.97 M
Nx             0.0321 M - 123.49x slower +30.86 μs
```

## 結果

|BLAS          |Apple Silicon|1,000|10,000 |100,000|
|:-------------|:------------|----:|------:|------:|
|OpenBLAS      |M3 Max       |3.500|0.65210|0.01073|
|OpenBLAS      |M4 Pro       |4.070|0.77427|0.01219|
|AppleBLAS     |M3 Max       |3.610|0.84703|0.11731|
|AppleBLAS     |M4 Pro       |3.970|0.95364|0.11453|
|Apple/OpenBLAS|M3 Max       |1.031|1.29893|10.9329|
|Apple/OpenBLAS|M4 Pro       |0.975|1.23166| 9.3954|

## 考察

AppleBLASはOpenBLASに比べてApple Siliconにチューニングされているようです．ベクトルの要素数が大きくなると飛躍的に差が広がります．

M1からM3については非公開のAMX命令を搭載していますので，今回評価したSSCALについても，AMX命令を用いていてもおかしくなさそうな結果です．仮にそうだとすると，M4でもAMX命令を用いているか，SME命令とAMX命令の効果は同等程度という仮説が成り立ちそうです．


