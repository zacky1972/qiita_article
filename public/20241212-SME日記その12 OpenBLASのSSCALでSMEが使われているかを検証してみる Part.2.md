---
title: SME日記その12 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.2
tags:
  - Elixir
  - OpenBLAS
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2024-12-12T20:16:48+09:00'
id: 2d69ed8b7ae5840012db
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
OpenBLASのSSCALでSMEが使われているかを検証すべく，ベンチマークプログラムを作成してみました．

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

## ソースコード

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
export USE_OPEN_BLAS=true 
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

まず M3 Max で実行してみました．

```zsh
% mix run -r benchmark.exs
Operating System: macOS
CPU Information: Apple M3 Max
Number of Available Cores: 16
Available memory: 128 GB
Elixir 1.17.3
Erlang 27.1.2
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
OpenBLAS       10.73 K      0.0932 ms    ±10.50%      0.0924 ms       0.120 ms
Nx              0.21 K        4.75 ms     ±3.68%        4.78 ms        5.31 ms

Comparison: 
OpenBLAS       10.73 K
Nx              0.21 K - 51.02x slower +4.66 ms

##### With input Medium #####
Name               ips        average  deviation         median         99th %
OpenBLAS      652.10 K        1.53 μs   ±868.81%        1.46 μs        1.96 μs
Nx              2.54 K      393.24 μs     ±5.29%      385.63 μs      463.12 μs

Comparison: 
OpenBLAS      652.10 K
Nx              2.54 K - 256.43x slower +391.71 μs

##### With input Small #####
Name               ips        average  deviation         median         99th %
OpenBLAS        3.50 M        0.29 μs  ±6654.78%        0.25 μs           3 μs
Nx            0.0255 M       39.27 μs     ±6.92%       38.38 μs       49.17 μs

Comparison: 
OpenBLAS        3.50 M
Nx            0.0255 M - 137.32x slower +38.99 μs
```

ips が，Small < Medium なのは想定していましたが，Medium > Bigger なのは，キャッシュメモリから溢れているからかもしれませんね．

次はいよいよM4 Proで実行してみます．

