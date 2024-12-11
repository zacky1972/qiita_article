---
title: SME日記その11 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.1
tags:
  - M4
  - AppleSilicon
  - SME
  - OpenBLAS
  - Elixir
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
[OpenBLASでがSME使われている可能性に思い至った](https://qiita.com/zacky1972/items/0c6f5aed0365f1b4fdb6)ので，手始めに`SSCAL`でSMEが使われているかを検証することを試みました．

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

## ソースコード

https://github.com/zacky1972/nx_sgemm

[ExTask](https://qiita.com/zacky1972/items/4fa132017f0e6d5e620b)を使っています．

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

static ErlNifFunc nif_funcs [] =
{
    {"ok", 0, ok},
    {"mul_nif_f32_tensor_f32_scalar", 3, mul_nif_f32_tensor_f32_scalar},
    {"mul_nif_u8_tensor_u8_scalar", 3, mul_nif_u8_tensor_u8_scalar}
};

ERL_NIF_INIT(Elixir.NxSgemm, nif_funcs, NULL, NULL, NULL, NULL)
```

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
end
```

## テスト方法

```
% git clone https://github.com/zacky1972/nx_sgemm.git
Cloning into 'nx_sgemm'...
remote: Enumerating objects: 48, done.
remote: Counting objects: 100% (48/48), done.
remote: Compressing objects: 100% (27/27), done.
Receiving objects: 100% (48/48), 8.99 KiB | 8.99 MiB/s, done.
Resolving deltas: 100% (17/17), done.
remote: Total 48 (delta 17), reused 44 (delta 13), pack-reused 0 (from 0)
% cd nx_sgemm 
nx_sgemm % % mix deps.get
Resolving Hex dependencies...
Resolution completed in 0.022s
Unchanged:
  complex 0.5.0
  ex_task 0.3.0
  finch 0.19.0
  hpax 1.0.1
  jason 1.4.4
  mime 2.0.6
  mint 1.6.2
  nimble_options 1.1.1
  nimble_pool 1.1.0
  nx 0.9.2
  req 0.5.8
  telemetry 1.3.0
* Getting ex_task (Hex package)
* Getting nx (Hex package)
* Getting complex (Hex package)
* Getting telemetry (Hex package)
* Getting req (Hex package)
* Getting finch (Hex package)
* Getting jason (Hex package)
* Getting mime (Hex package)
* Getting mint (Hex package)
* Getting nimble_options (Hex package)
* Getting nimble_pool (Hex package)
* Getting hpax (Hex package)
nx_sgemm % % mix test
==> mime
Compiling 1 file (.ex)
Generated mime app
==> nimble_options
Compiling 3 files (.ex)
Generated nimble_options app
===> Analyzing applications...
===> Compiling telemetry
==> jason
Compiling 10 files (.ex)
Generated jason app
==> hpax
Compiling 4 files (.ex)
Generated hpax app
==> mint
Compiling 1 file (.erl)
Compiling 20 files (.ex)
Generated mint app
==> complex
Compiling 2 files (.ex)
Generated complex app
==> nx
Compiling 36 files (.ex)
Generated nx app
==> nimble_pool
Compiling 2 files (.ex)
Generated nimble_pool app
==> finch
Compiling 14 files (.ex)
Generated finch app
==> req
Compiling 17 files (.ex)
Generated req app
==> ex_task
Compiling 2 files (.ex)
Generated ex_task app
go-task/task info checking GitHub for latest tag
go-task/task debug http_download https://github.com/go-task/task/releases/latest
go-task/task info found version: 3.40.1 for v3.40.1/darwin/arm64
go-task/task debug downloading files into /var/folders/s4/8mb121gd2y94rh09nqtlp4hw0000gn/T/tmp.QOYZrOHSUQ
go-task/task debug http_download https://github.com/go-task/task/releases/download/v3.40.1/task_darwin_arm64.tar.gz
go-task/task debug http_download https://github.com/go-task/task/releases/download/v3.40.1/task_checksums.txt
go-task/task info installed /Users/zacky/github/nx_sgemm/_build/test/lib/ex_task/bin/task

==> nx_sgemm
Compiling 1 file (.ex)
Generated nx_sgemm app
Running ExUnit with seed: 34060, max_cases: 32

......
Finished in 0.00 seconds (0.00s async, 0.00s sync)
6 doctests, 0 failures
```

