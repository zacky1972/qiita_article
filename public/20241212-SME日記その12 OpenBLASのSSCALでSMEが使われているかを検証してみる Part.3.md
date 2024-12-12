---
title: SME日記その13 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.3
tags:
  - Elixir
  - OpenBLAS
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2024-12-12T20:16:48+09:00'
id: 5fe73657dd1e4b167320
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
OpenBLASのSSCALでSMEが使われているかを検証すべく，ベンチマークプログラムをいよいよM4 Proで動かします．

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


```elixir
% mix run -r benchmark.exs 
Operating System: macOS
CPU Information: Apple M4 Pro
Number of Available Cores: 14
Available memory: 64 GB
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
OpenBLAS       12.19 K      0.0820 ms    ±11.12%      0.0808 ms       0.105 ms
Nx              0.27 K        3.75 ms     ±4.14%        3.75 ms        4.11 ms

Comparison: 
OpenBLAS       12.19 K
Nx              0.27 K - 45.69x slower +3.67 ms

##### With input Medium #####
Name               ips        average  deviation         median         99th %
OpenBLAS      774.27 K        1.29 μs  ±1027.11%        1.21 μs        1.71 μs
Nx              3.23 K      309.97 μs     ±6.64%      305.83 μs      384.78 μs

Comparison: 
OpenBLAS      774.27 K
Nx              3.23 K - 240.00x slower +308.67 μs

##### With input Small #####
Name               ips        average  deviation         median         99th %
OpenBLAS        4.07 M        0.25 μs  ±8647.04%        0.21 μs        2.50 μs
Nx            0.0331 M       30.17 μs     ±6.36%       30.96 μs       34.96 μs

Comparison: 
OpenBLAS        4.07 M
Nx            0.0331 M - 122.82x slower +29.93 μs
```

大体同じような傾向かなと思いました．

ただし，OpenBLASをビルドしているわけではないですので，ソースコードビルドを試みたいと思います．

```zsh
brew uninstall openblas
brew install --build-from-source openblas
mix deps.clean nx_sgemm
mix deps.get 
export USE_OPEN_BLAS=true 
mix compile
```

```elixir
 % mix run -r benchmark.exs 
Operating System: macOS
CPU Information: Apple M4 Pro
Number of Available Cores: 14
Available memory: 64 GB
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
OpenBLAS       12.33 K      0.0811 ms    ±11.02%      0.0798 ms       0.104 ms
Nx              0.25 K        3.95 ms     ±3.27%        3.94 ms        4.27 ms

Comparison: 
OpenBLAS       12.33 K
Nx              0.25 K - 48.66x slower +3.87 ms

##### With input Medium #####
Name               ips        average  deviation         median         99th %
OpenBLAS      714.34 K        1.40 μs   ±837.24%        1.33 μs        1.75 μs
Nx              3.09 K      323.40 μs     ±6.28%      316.21 μs         406 μs

Comparison: 
OpenBLAS      714.34 K
Nx              3.09 K - 231.02x slower +322.00 μs

##### With input Small #####
Name               ips        average  deviation         median         99th %
OpenBLAS        3.83 M        0.26 μs  ±8863.17%        0.21 μs        2.67 μs
Nx            0.0315 M       31.75 μs     ±3.77%       31.42 μs       35.50 μs

Comparison: 
OpenBLAS        3.83 M
Nx            0.0315 M - 121.59x slower +31.49 μs
```

結果をまとめてみましょう．

|                          |Bigger|Medium|Small   |
|:-------------------------|-----:|-----:|-------:|
|M3 Max OpenBLAS           |   932|  1.53|    0.29|
|M4 Pro OpenBLAS (prebuilt)|   820|  1.29|    0.25|
|M4 Pro OpenBLAS (built)   |   811|  1.40|    0.26|

Biggerで極端に実行時間がかかるのはキャッシュミスしているからではないかと推測しましたが，どうなのでしょうか．

つづく．
