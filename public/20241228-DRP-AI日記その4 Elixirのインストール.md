---
title: DRP-AI日記その4 Elixirのインストール
tags:
  - Erlang
  - Ubuntu
  - Elixir
  - DRP-AI
  - Kakip
private: false
updated_at: '2024-12-28T11:12:57+09:00'
id: 922176433e54046b8338
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
KakipにElixirをインストールします．

DRP-AIシリーズ・Kakip

- [DRP-AI日記その1 なぜDRP-AIシリーズに取り組むのか](https://qiita.com/zacky1972/items/3ebf021cab1e972890f8)
- [DRP-AI日記その2 Kakipを起動してみた](https://qiita.com/zacky1972/items/438ddc192fc499fb697c)
- [DRP-AI日記その3 Kakipネットワーク等初期設定](https://qiita.com/zacky1972/items/ab6a176f0ad481473f71)

## Elixir/Erlangインストール

下記に沿ってインストールします．

https://hexdocs.pm/nerves/installation.html

WXのパッケージがありませんでしたので，一旦省略します．

```bash
sudo apt install build-essential automake autoconf git squashfs-tools ssh-askpass pkg-config curl libmnl-dev libssl-dev libncurses5-dev help2man libconfuse-dev libarchive-dev
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
mise use -g erlang@27.2
```

予想通り，現状だと下記の警告が出ます．おいおい解消する方法を検討します．

```markdown
APPLICATIONS DISABLED (See: /home/zacky/.cache/mise/erlang/kerl/builds/27.2/otp_build_27.2.log)
 * jinterface     : No Java compiler found
 * odbc           : ODBC library - link check failed

APPLICATIONS INFORMATION (See: /home/zacky/.cache/mise/erlang/kerl/builds/27.2/otp_build_27.2.log)
 * wx             : No OpenGL headers found, wx will NOT be usable
 * No GLU headers found, wx will NOT be usable
 * wxWidgets was not compiled with --enable-webview or wxWebView developer package is not installed, wxWebView will NOT be available
 *         wxWidgets must be installed on your system.
 *         Please check that wx-config is in path, the directory
 *         where wxWidgets libraries are installed (returned by
 *         'wx-config --libs' or 'wx-config --static --libs' command)
 *         is in LD_LIBRARY_PATH or equivalent variable and
 *         wxWidgets version is 3.0.2 or above.
```

17分ほどかかってコンパイルしました．

```bash
mise use -g elixir@1.18.1-otp-27
mix local.hex
mix local.rebar
```

```bash
$ elixir -v
Erlang/OTP 27 [erts-15.2] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [jit]

Elixir 1.18.1 (compiled with Erlang/OTP 27)
```

JITが動きますね．素晴らしい！

```elixir:nx_bench.exs
Mix.install([:nx, :benchee])

Benchee.run(
  %{
    "Nx (multiply vector x scalar)" => fn input -> Nx.multiply(input, 2.0) end
  },
  inputs: %{
    "Small" => Nx.iota({1_000}),
    "Medium" => Nx.iota({10_000}),
    "Bigger" => Nx.iota({100_000}),
  }
)
```

```txt:Apple M3 Max
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
Estimated total run time: 21 s

Benchmarking Nx (multiply vector x scalar) with input Bigger ...
Benchmarking Nx (multiply vector x scalar) with input Medium ...
Benchmarking Nx (multiply vector x scalar) with input Small ...
Calculating statistics...
Formatting results...

##### With input Bigger #####
Name                                    ips        average  deviation         median         99th %
Nx (multiply vector x scalar)        307.55        3.25 ms     ±1.70%        3.24 ms        3.41 ms

##### With input Medium #####
Name                                    ips        average  deviation         median         99th %
Nx (multiply vector x scalar)        3.10 K      322.59 μs     ±6.92%      313.17 μs      399.53 μs

##### With input Small #####
Name                                    ips        average  deviation         median         99th %
Nx (multiply vector x scalar)       30.23 K       33.08 μs     ±7.62%       32.96 μs       42.38 μs
```

```txt:Kakip
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
Estimated total run time: 21 s

Benchmarking Nx (multiply vector x scalar) with input Bigger ...
Benchmarking Nx (multiply vector x scalar) with input Medium ...
Benchmarking Nx (multiply vector x scalar) with input Small ...
Calculating statistics...
Formatting results...

##### With input Bigger #####
Name                                    ips        average  deviation         median         99th %
Nx (multiply vector x scalar)         12.66       79.01 ms     ±0.51%       79.01 ms       80.28 ms

##### With input Medium #####
Name                                    ips        average  deviation         median         99th %
Nx (multiply vector x scalar)        134.72        7.42 ms     ±0.74%        7.41 ms        7.58 ms

##### With input Small #####
Name                                    ips        average  deviation         median         99th %
Nx (multiply vector x scalar)        1.28 K      782.82 μs     ±2.37%      781.08 μs      828.11 μs
```

* Bigger: 24.3倍 M3 Max の方が高速
* Medium: 23.0倍 M3 Max の方が高速
* Small: 23.6倍 M3 Max の方が高速

CPUの性能比はそんなもんですかね．

