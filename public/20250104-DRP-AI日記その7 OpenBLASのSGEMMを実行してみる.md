---
title: DRP-AI日記その7 OpenBLASのSGEMMを実行してみる
tags:
  - Ubuntu
  - Elixir
  - OpenBLAS
  - DRP-AI
  - Kakip
private: false
updated_at: '2025-01-04T16:15:00+09:00'
id: bb2627d3c1d16d77a466
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
KakipでOpenBLASのSGEMM(単精度一般行列積)を実行してみました．

DRP-AIシリーズ・Kakip

- [DRP-AI日記その1 なぜDRP-AIシリーズに取り組むのか](https://qiita.com/zacky1972/items/3ebf021cab1e972890f8)
- [DRP-AI日記その2 Kakipを起動してみた](https://qiita.com/zacky1972/items/438ddc192fc499fb697c)
- [DRP-AI日記その3 Kakipネットワーク等初期設定](https://qiita.com/zacky1972/items/ab6a176f0ad481473f71)
- [DRP-AI日記その4 Elixirのインストール](https://qiita.com/zacky1972/items/922176433e54046b8338)
- [DRP-AI日記その5 OpenBLASを実行してみる](https://qiita.com/zacky1972/items/02be10d1acc013a499d2)
- [DRP-AI日記その6 DRP-AIシリーズの研究の今後の展望についての技術的ポエム](https://qiita.com/zacky1972/items/5c92779e2bac7ab631e8)

## ソースコード

https://github.com/zacky1972/nx_sgemm

注意: 2025年1月7日にNxSgemmに対して行った破壊的更新のため，GitHubのmainブランチのコードでは動作しなくなっています．

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
    # "Bigger" => Nx.iota({500, 500}) |> Nx.multiply(1.0)
  }
)
```

```
mix deps.clean --all
mix deps.get
mix compile
mix run -r gemm_benchmark.exs
```

## Kakipでの実行結果

```elixir
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
inputs: Medium, Small
Estimated total run time: 28 s

Benchmarking BLAS(dot) with input Medium ...
Benchmarking BLAS(dot) with input Small ...
Benchmarking Nx(dot) with input Medium ...
Benchmarking Nx(dot) with input Small ...
Calculating statistics...
Formatting results...

##### With input Medium #####
Name                ips        average  deviation         median         99th %
BLAS(dot)        263.51      0.00379 s    ±15.13%      0.00376 s      0.00436 s
Nx(dot)            0.66         1.51 s     ±1.62%         1.51 s         1.54 s

Comparison: 
BLAS(dot)        263.51
Nx(dot)            0.66 - 398.62x slower +1.51 s

##### With input Small #####
Name                ips        average  deviation         median         99th %
BLAS(dot)       17.51 K      0.0571 ms    ±38.40%      0.0532 ms       0.105 ms
Nx(dot)          0.52 K        1.94 ms     ±3.63%        1.92 ms        2.26 ms

Comparison: 
BLAS(dot)       17.51 K
Nx(dot)          0.52 K - 33.90x slower +1.88 ms
```

* SSCAL
    * Bigger(100,000): 320.41倍
    * Medium(10,000): 241.77倍
    * Small(1,000): 124.86倍
* SGEMM
    * Medium(100x100): 398.62倍
    * Small(10x10): 33.90倍
  
この後で，NPU(DRP-AI3)を駆動することを試みますが，CPUで駆動するOpenBLASと比べて，より高速にしたいですね！
