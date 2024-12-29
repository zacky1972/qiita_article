---
title: SME日記その15 AppleBLASのSGEMMでSMEが使われているかを検証してみる Part.1
tags:
  - Elixir
  - BLAS
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2024-12-29T09:03:53+09:00'
id: e6e8d8ebe4400c6ef737
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
AppleBLASのSGEMMでSMEが使われているかを検証すべく，ベンチマークプログラムをM3 MaxとM4 Proで動かします．

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
- [SME日記その14 AppleBLASのSSCALでSMEが使われているかを検証してみる Part.1](https://qiita.com/zacky1972/items/9b22e23cd18a4912b99a)

## ソースコード

https://github.com/zacky1972/nx_sgemm

```elixir:lib/nx_sgemm.ex
defmodule NxSgemm do
  @moduledoc """
  Documentation for `NxSgemm`.
  """
  require Logger

  @on_load :load_nif

  @doc false
  def load_nif do
    nif_file = ~c'#{Application.app_dir(:nx_sgemm, "priv/libnif")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end

  @doc """
  ok.

  ## Examples

      iex> NxSgemm.ok()
      :ok

  """
  def ok(), do: :erlang.nif_error(:not_loaded)

  @doc """
  Element-wise multiplication of two tensors.

  If a number is given, it is converted to a tensor.

  It will broadcast tensors whenever the dimensions do not match and broadcasting is possible.

  ## Examples

  ### Multiplying scalers

      iex> NxSgemm.multiply(1, 2)
      #Nx.Tensor<
        s32
        2
      >

  ### Multiplying tensors and scalers

      iex> NxSgemm.multiply(Nx.tensor([1, 2, 3], names: [:data], type: :u8), 1)
      #Nx.Tensor<
        u8[data: 3]
        [1, 2, 3]
      >

      iex> NxSgemm.multiply(1, Nx.tensor([1, 2, 3], names: [:data], type: :u8))
      #Nx.Tensor<
        u8[data: 3]
        [1, 2, 3]
      >

      iex> NxSgemm.multiply(Nx.tensor([1.0, 2.0, 3.0], names: [:data], type: :f32), 2.0)
      #Nx.Tensor<
        f32[data: 3]
        [2.0, 4.0, 6.0]
      >

      iex> NxSgemm.multiply(2.0, Nx.tensor([1.0, 2.0, 3.0], names: [:data], type: :f32))
      #Nx.Tensor<
        f32[data: 3]
        [2.0, 4.0, 6.0]
      >
  """
  def multiply(a, b) when is_integer(a) and is_integer(b) do
    Nx.tensor(a * b, type: :s32)
  end

  def multiply(a, b) when is_float(b) do
    case Nx.type(a) do
      {:f, 32} ->
        %{
          a
          | data: %{
            a.data
            | state: mul_nif_f32_tensor_f32_scalar(Nx.size(a), a.data.state, b)
          }
        }
    end
  end

  def multiply(a, b) when is_integer(b) when 0 <= b and b < 256 do
    case Nx.type(a) do
      {:u, 8} ->
        %{
          a
          | data: %{
            a.data
            | state: mul_nif_u8_tensor_u8_scalar(Nx.size(a), a.data.state, b)
          }
        }
    end
  end

  def multiply(a, b) when is_number(a) do
    multiply(b, a)
  end

  defp mul_nif_f32_tensor_f32_scalar(_size, _a, _b), do: raise("NIF mul_nif_f32_tensor_f32_scalar/3 not implemented")
  defp mul_nif_u8_tensor_u8_scalar(_size, _a, _b), do: raise("NIF mul_nif_u8_tensor_u8_scalar/3 not implemented")

  @doc """
  Returns the dot product of two tensors.

  Given `a` and `b`, computes the dot product according to the following rules:

  * If both `a` and `b` are scalars, it is equivalent to `a * b`.
  * If `a` is a scalar and `b` is a tensor, it is equivalent to `Nx.multiply(a, b)`.
  * If `a` is a tensor and `b` is a scalar, it is equivalent to `Nx.multiply(a, b)`.
  * If both `a` and `b` are 1-D tensors (vectors), it is the sum of the element-wise product between `a` and `b`. The lengths of `a` and `b` must be equal.
  * If both `a` and `b` are 2-D tensors (matrices), it is equivalent to matrix-multiplication.
  * If either `a` or `b` is a 1-D tensor, and the other is an n-D tensor, it is the sum of the element-wise product along the last axis of `a` or `b`. The length of the 1-D tensor must match the last dimension of the n-D tensor.
  * If `a` is an n-D tensor and `b` is an m-D tensor, it is the sum of the element-wise product along the last axis of `a` and the second-to-last axis of `b`. The last dimension of `a` must match the second-to-last dimension of `b`.

  ## Examples

      iex> left = Nx.tensor([[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]])
      iex> right = Nx.tensor([[7.0, 8.0], [9.0, 10.0], [11.0, 12.0]])
      iex> Nx.dot(left, right)
      #Nx.Tensor<
        f32[2][2]
        [
          [58.0, 64.0],
          [139.0, 154.0]
        ]
      >
  """
  def dot(a, b) do
    case {Nx.type(a), Nx.type(b), Nx.shape(a), Nx.shape(b)} do
      {{:f, 32}, {:f, 32}, {m, n}, {n, o}} ->
        c = Nx.iota({m, o}, type: {:f, 32})

        %{
          c
          | data: %{
            c.data
            | state: dot_nif_f32_matrix_f32_matrix(m, o, n, a.data.state, b.data.state)
          }
        }
    end
  end

  defp dot_nif_f32_matrix_f32_matrix(_m, _o, _n, _a, _b), do: raise("NIF dot_nif_f32_matrix_f32_matrix/5 not implemented")
end
```

```c:nif_src/libnif.c
#include <erl_nif.h>
#include <stdbool.h>
#include <stdint.h>
#ifdef USE_OPEN_BLAS
#include <cblas.h>
#else // USE_OPEN_BLAS
#include <Accelerate/Accelerate.h>
#endif // USE_OPEN_BLAS

static ERL_NIF_TERM ok(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    return enif_make_atom(env, "ok");
}

static ERL_NIF_TERM mul_nif_f32_tensor_f32_scalar(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if (__builtin_expect(argc != 3, false)) {
        return enif_make_badarg(env);
    }

    ErlNifUInt64 vec_size;
    if (__builtin_expect(!enif_get_uint64(env, argv[0], &vec_size), false)) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM binary_term = argv[1];
    ErlNifBinary in_data;
    if (__builtin_expect(!enif_inspect_binary(env, binary_term, &in_data), false)) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM double_term = argv[2];
    double factor;
    if (__builtin_expect(!enif_get_double(env, double_term, &factor), false)) {
        return enif_make_badarg(env);
    }

    float *in = (float *)in_data.data;
    ErlNifBinary out_data;
    if (__builtin_expect(!enif_alloc_binary(vec_size * sizeof(float), &out_data), false)) {
        return enif_make_badarg(env);
    }

    float *out = (float *)out_data.data;

    cblas_scopy((int)vec_size, in, 1, out, 1);
    cblas_sscal((int)vec_size, (float) factor, out, 1);

    return enif_make_binary(env, &out_data);
}

static ERL_NIF_TERM mul_nif_u8_tensor_u8_scalar(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if (__builtin_expect(argc != 3, false)) {
        return enif_make_badarg(env);
    }

    ErlNifUInt64 vec_size;
    if (__builtin_expect(!enif_get_uint64(env, argv[0], &vec_size), false)) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM binary_term = argv[1];
    ErlNifBinary in_data;
    if (__builtin_expect(!enif_inspect_binary(env, binary_term, &in_data), false)) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM uint_term = argv[2];
    unsigned int factor;
    if (__builtin_expect(!enif_get_uint(env, uint_term, &factor), false)) {
        return enif_make_badarg(env);
    }

    uint8_t *in = (uint8_t *)in_data.data;
    ErlNifBinary out_data;
    if (__builtin_expect(!enif_alloc_binary(vec_size * sizeof(uint8_t), &out_data), false)) {
        return enif_make_badarg(env);
    }

    uint8_t *out = (uint8_t *)out_data.data;

    for(ErlNifUInt64 i = 0; i < vec_size; i++) {
        out[i] = (uint8_t) (in[i] * factor); 
    }

    return enif_make_binary(env, &out_data);
}

static ERL_NIF_TERM dot_nif_f32_matrix_f32_matrix(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if (__builtin_expect(argc != 5, false)) {
        return enif_make_badarg(env);
    }

    ErlNifUInt64 m;
    if (__builtin_expect(!enif_get_uint64(env, argv[0], &m), false)) {
        return enif_make_badarg(env);
    }

    ErlNifUInt64 o;
    if (__builtin_expect(!enif_get_uint64(env, argv[1], &o), false)) {
        return enif_make_badarg(env);
    }

    ErlNifUInt64 n;
    if (__builtin_expect(!enif_get_uint64(env, argv[2], &n), false)) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM binary_term_a = argv[3];
    ErlNifBinary a_data;
    if (__builtin_expect(!enif_inspect_binary(env, binary_term_a, &a_data), false)) {
        return enif_make_badarg(env);
    }
    float *a = (float *)a_data.data;

    ERL_NIF_TERM binary_term_b = argv[4];
    ErlNifBinary b_data;
    if (__builtin_expect(!enif_inspect_binary(env, binary_term_b, &b_data), false)) {
        return enif_make_badarg(env);
    }
    float *b = (float *)b_data.data;

    ErlNifBinary c_data;
    if (__builtin_expect(!enif_alloc_binary(m * o * sizeof(float), &c_data), false)) {
        return enif_make_badarg(env);
    }
    float *c = (float *)c_data.data;

    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, m, o, n, 1.0, a, n, b, o, 0.0, c, o);

    return enif_make_binary(env, &c_data);
}

static ErlNifFunc nif_funcs [] =
{
    {"ok", 0, ok},
    {"mul_nif_f32_tensor_f32_scalar", 3, mul_nif_f32_tensor_f32_scalar},
    {"mul_nif_u8_tensor_u8_scalar", 3, mul_nif_u8_tensor_u8_scalar},
    {"dot_nif_f32_matrix_f32_matrix", 5, dot_nif_f32_matrix_f32_matrix}
};

ERL_NIF_INIT(Elixir.NxSgemm, nif_funcs, NULL, NULL, NULL, NULL)
```

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

```elixir:gemm_benchmark.exs
Benchee.run(
  %{
    "Nx(dot)" => fn input -> Nx.dot(input, input) end,
    "BLAS(dot)" => fn input -> NxSgemm.dot(input, input) end
  },
  inputs: %{
    "Small" => Nx.iota({10, 10}) |> Nx.multiply(1.0),
    "Medium" => Nx.iota({100, 100}) |> Nx.multiply(1.0),
    "Bigger" => Nx.iota({500, 500}) |> Nx.multiply(1.0)
  }
)
```

```
mix deps.clean --all
mix deps.get
mix compile
mix run -r gemm_benchmark.exs
mix deps.clean --all
mix deps.get
export USE_OPEN_BLAS=true
mix compile
mix run -r gemm_benchmark.exs
```

## M3 Max / AppleBLAS

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
inputs: Bigger, Medium, Small
Estimated total run time: 42 s

Benchmarking BLAS(dot) with input Bigger ...
Benchmarking BLAS(dot) with input Medium ...
Benchmarking BLAS(dot) with input Small ...
Benchmarking Nx(dot) with input Bigger ...
Benchmarking Nx(dot) with input Medium ...
Benchmarking Nx(dot) with input Small ...
Calculating statistics...
Formatting results...

##### With input Bigger #####
Name                ips        average  deviation         median         99th %
BLAS(dot)         92.56       0.0108 s    ±13.35%       0.0112 s       0.0140 s
Nx(dot)          0.0323        30.95 s     ±0.00%        30.95 s        30.95 s

Comparison: 
BLAS(dot)         92.56
Nx(dot)          0.0323 - 2865.16x slower +30.94 s

##### With input Medium #####
Name                ips        average  deviation         median         99th %
BLAS(dot)        4.02 K        0.25 ms     ±2.98%        0.25 ms        0.27 ms
Nx(dot)        0.0121 K       82.94 ms     ±1.26%       82.71 ms       86.31 ms

Comparison: 
BLAS(dot)        4.02 K
Nx(dot)        0.0121 K - 333.40x slower +82.69 ms

##### With input Small #####
Name                ips        average  deviation         median         99th %
BLAS(dot)      360.76 K        2.77 μs   ±278.59%        2.58 μs        3.71 μs
Nx(dot)          9.95 K      100.50 μs     ±6.34%       99.04 μs      120.42 μs

Comparison: 
BLAS(dot)      360.76 K
Nx(dot)          9.95 K - 36.26x slower +97.73 μs
```

## M3 Max / OpenBLAS

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
inputs: Bigger, Medium, Small
Estimated total run time: 42 s

Benchmarking BLAS(dot) with input Bigger ...
Benchmarking BLAS(dot) with input Medium ...
Benchmarking BLAS(dot) with input Small ...
Benchmarking Nx(dot) with input Bigger ...
Benchmarking Nx(dot) with input Medium ...
Benchmarking Nx(dot) with input Small ...
Calculating statistics...
Formatting results...

##### With input Bigger #####
Name                ips        average  deviation         median         99th %
BLAS(dot)         89.98       0.0111 s    ±11.51%       0.0107 s       0.0132 s
Nx(dot)          0.0322        31.03 s     ±0.00%        31.03 s        31.03 s

Comparison: 
BLAS(dot)         89.98
Nx(dot)          0.0322 - 2792.50x slower +31.02 s

##### With input Medium #####
Name                ips        average  deviation         median         99th %
BLAS(dot)        2.83 K        0.35 ms     ±6.36%        0.35 ms        0.40 ms
Nx(dot)        0.0121 K       82.45 ms     ±3.41%       81.80 ms      101.45 ms

Comparison: 
BLAS(dot)        2.83 K
Nx(dot)        0.0121 K - 233.64x slower +82.10 ms

##### With input Small #####
Name                ips        average  deviation         median         99th %
BLAS(dot)      365.96 K        2.73 μs   ±263.40%        2.54 μs        3.71 μs
Nx(dot)          9.86 K      101.39 μs     ±9.45%       98.46 μs      134.08 μs

Comparison: 
BLAS(dot)      365.96 K
Nx(dot)          9.86 K - 37.10x slower +98.66 μs
```

## M4 Pro / AppleBLAS

```elixir
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

Benchmarking BLAS(dot) with input Bigger ...
Benchmarking BLAS(dot) with input Medium ...
Benchmarking BLAS(dot) with input Small ...
Benchmarking Nx(dot) with input Bigger ...
Benchmarking Nx(dot) with input Medium ...
Benchmarking Nx(dot) with input Small ...
Calculating statistics...
Formatting results...

##### With input Bigger #####
Name                ips        average  deviation         median         99th %
BLAS(dot)        121.46      0.00823 s    ±11.70%      0.00781 s       0.0103 s
Nx(dot)          0.0428        23.35 s     ±0.00%        23.35 s        23.35 s

Comparison: 
BLAS(dot)        121.46
Nx(dot)          0.0428 - 2836.06x slower +23.34 s

##### With input Medium #####
Name                ips        average  deviation         median         99th %
BLAS(dot)        5.16 K       0.194 ms     ±2.61%       0.193 ms        0.21 ms
Nx(dot)        0.0159 K       63.05 ms     ±4.01%       62.41 ms       77.53 ms

Comparison: 
BLAS(dot)        5.16 K
Nx(dot)        0.0159 K - 325.17x slower +62.85 ms

##### With input Small #####
Name                ips        average  deviation         median         99th %
BLAS(dot)      465.04 K        2.15 μs   ±371.75%        2.04 μs        2.92 μs
Nx(dot)         12.34 K       81.04 μs    ±10.40%       80.67 μs      106.38 μs

Comparison: 
BLAS(dot)      465.04 K
Nx(dot)         12.34 K - 37.69x slower +78.89 μs
```

## M4 Pro / OpenLAS

```elixir
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

Benchmarking BLAS(dot) with input Bigger ...
Benchmarking BLAS(dot) with input Medium ...
Benchmarking BLAS(dot) with input Small ...
Benchmarking Nx(dot) with input Bigger ...
Benchmarking Nx(dot) with input Medium ...
Benchmarking Nx(dot) with input Small ...
Calculating statistics...
Formatting results...

##### With input Bigger #####
Name                ips        average  deviation         median         99th %
BLAS(dot)        104.46      0.00957 s    ±29.54%      0.00955 s       0.0195 s
Nx(dot)          0.0456        21.93 s     ±0.00%        21.93 s        21.93 s

Comparison: 
BLAS(dot)        104.46
Nx(dot)          0.0456 - 2290.55x slower +21.92 s

##### With input Medium #####
Name                ips        average  deviation         median         99th %
BLAS(dot)        3.79 K        0.26 ms    ±32.30%        0.27 ms        0.31 ms
Nx(dot)        0.0159 K       62.98 ms     ±1.53%       62.86 ms       66.01 ms

Comparison: 
BLAS(dot)        3.79 K
Nx(dot)        0.0159 K - 238.68x slower +62.71 ms

##### With input Small #####
Name                ips        average  deviation         median         99th %
BLAS(dot)      476.81 K        2.10 μs   ±379.70%        1.96 μs        2.92 μs
Nx(dot)         12.49 K       80.04 μs     ±6.27%       81.04 μs       91.75 μs

Comparison: 
BLAS(dot)      476.81 K
Nx(dot)         12.49 K - 38.17x slower +77.95 μs
```
