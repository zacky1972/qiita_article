---
title: Jetson Nano で EXLA を実行する
tags:
  - Elixir
  - JetsonNano
  - nx
  - EXLA
private: false
updated_at: '2021-09-25T18:58:55+09:00'
id: 6852710272333bd5efab
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---

1. SWAP領域が無いとメモリ不足で死ぬので，足しておきます。
1. フル稼働モードにする `sudo nvpmodel -m 0; sudo jetson_clocks`
1. Python 3.8 をインストールする `sudo apt install python3.8`
1. Python 3.8 をデフォルトにする https://qiita.com/syu-kwsk/items/5ba485edabd19fb99d4d
1. pip をインストールする `sudo apt install python3-pip`
1. pip を最新版にアップデートする `python3 -m pip install -U pip`
1. NumPyをインストールする `sudo python3 -m pip install numpy` それとも `sudo pip3 install numpy` 一旦 NumPy をアンインストールしてからが正解か？
1. npmをインストールする `sudo apt install npm`
1. bazeliskをインストールする `sudo npm install -g @bazel/bazelisk`
1. OpenJDKをインストールする `sudo apt install openjdk-8-jdk`
1. Elixir 1.12以降とErlang OTP 24以降をインストールする
1. https://github.com/elixir-nx/nx を clone する
1. cd nx/exla
1. `mix deps.get`
1. `mix run -r bench/softmax.exs` とする

XLAをビルドしなくて良くなりました。(私が開発チームにビルド結果を渡したからですね)

```
Operating System: Linux
CPU Information: ARMv8 Processor rev 1 (v8l)
Number of Available Cores: 4
Available memory: 1.93 GB
Elixir 1.12.3
Erlang 24.1

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 56 s

Benchmarking elixir f32...
Benchmarking elixir f64...
Benchmarking xla jit-cpu f32...
Benchmarking xla jit-cpu f64...

Name                      ips        average  deviation         median         99th %
xla jit-cpu f32         57.96       0.0173 s     ±2.12%       0.0172 s       0.0193 s
xla jit-cpu f64         14.40       0.0694 s     ±3.24%       0.0682 s       0.0797 s
elixir f32               0.68         1.48 s     ±0.48%         1.48 s         1.48 s
elixir f64               0.67         1.50 s     ±1.26%         1.49 s         1.54 s

Comparison: 
xla jit-cpu f32         57.96
xla jit-cpu f64         14.40 - 4.02x slower +0.0522 s
elixir f32               0.68 - 85.65x slower +1.46 s
elixir f64               0.67 - 86.73x slower +1.48 s

Memory usage statistics:

Name               Memory usage
xla jit-cpu f32      0.00205 MB
xla jit-cpu f64      0.00205 MB - 1.00x memory usage +0 MB
elixir f32            267.01 MB - 130100.39x memory usage +267.00 MB
elixir f64            267.01 MB - 130100.40x memory usage +267.00 MB

**All measurements for memory usage were the same**

```

やったぜ！

CUDA だと次のような感じです。

`XLA_TARGET=cuda102 EXLA_TARGET=cuda mix run -r bench/softmax.exs`

```
Operating System: Linux
CPU Information: ARMv8 Processor rev 1 (v8l)
Number of Available Cores: 4
Available memory: 1.93 GB
Elixir 1.12.3
Erlang 24.1

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 1.87 min

Benchmarking elixir f32...
Benchmarking elixir f64...
Benchmarking xla jit-cpu f32...
Benchmarking xla jit-cpu f64...
Benchmarking xla jit-gpu f32...

18:49:41.205 [info] domain=elixir.xla file=tensorflow/core/platform/default/subprocess.cc line=304   Start cannot spawn child process: No such file or directory
Benchmarking xla jit-gpu f32 keep...
Benchmarking xla jit-gpu f64...
Benchmarking xla jit-gpu f64 keep...

Name                           ips        average  deviation         median         99th %
xla jit-gpu f32 keep        591.90        1.69 ms     ±1.96%        1.69 ms        1.78 ms
xla jit-gpu f64 keep        146.35        6.83 ms     ±0.43%        6.83 ms        6.92 ms
xla jit-gpu f32             100.49        9.95 ms     ±1.80%        9.93 ms       10.10 ms
xla jit-cpu f32              58.62       17.06 ms     ±3.47%       16.90 ms       20.10 ms
xla jit-gpu f64              49.76       20.10 ms     ±2.96%       20.03 ms       25.48 ms
xla jit-cpu f64              13.73       72.85 ms     ±1.96%       72.51 ms       79.16 ms
elixir f32                    0.69     1444.13 ms     ±0.61%     1444.49 ms     1455.88 ms
elixir f64                    0.67     1491.37 ms     ±1.36%     1483.28 ms     1517.37 ms

Comparison: 
xla jit-gpu f32 keep        591.90
xla jit-gpu f64 keep        146.35 - 4.04x slower +5.14 ms
xla jit-gpu f32             100.49 - 5.89x slower +8.26 ms
xla jit-cpu f32              58.62 - 10.10x slower +15.37 ms
xla jit-gpu f64              49.76 - 11.89x slower +18.41 ms
xla jit-cpu f64              13.73 - 43.12x slower +71.16 ms
elixir f32                    0.69 - 854.78x slower +1442.44 ms
elixir f64                    0.67 - 882.75x slower +1489.68 ms

Memory usage statistics:

Name                    Memory usage
xla jit-gpu f32 keep         2.09 KB
xla jit-gpu f64 keep         2.09 KB - 1.00x memory usage +0 KB
xla jit-gpu f32              2.13 KB - 1.01x memory usage +0.0313 KB
xla jit-cpu f32              2.10 KB - 1.00x memory usage +0.00781 KB
xla jit-gpu f64              2.13 KB - 1.01x memory usage +0.0313 KB
xla jit-cpu f64              2.10 KB - 1.00x memory usage +0.00781 KB
elixir f32              273414.10 KB - 130585.84x memory usage +273412.01 KB
elixir f64              273414.12 KB - 130585.85x memory usage +273412.02 KB

**All measurements for memory usage were the same**
```

