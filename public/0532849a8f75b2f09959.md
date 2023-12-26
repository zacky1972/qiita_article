---
title: ElixirのNxとCUDAを繋ぐ最小コード
tags:
  - CUDA
  - Elixir
  - nx
private: false
updated_at: '2022-11-26T09:21:41+09:00'
id: 0532849a8f75b2f09959
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
ElixirのNxとCUDAを繋いでみました．

追記: Nxバージョン0.3.0に対応していることを確認しました．
20220822追記: `'CharList'` を `~c'CharList'` にしました．[将来，`'CharList'`の書き方はdeprecated(非推奨)になるからです．]( https://github.com/elixir-lang/elixir/issues/12065)


ソースコードはこちらです．


https://github.com/zacky1972/ex_nvcc_sample

```elixir:mix.exs
defmodule ExNvccSample.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/zacky1972/ex_nvcc_sample"

  def project do
    [
      app: :ex_nvcc_sample,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExNvccSample",
      source_url: @source_url,
      docs: [
        main: "ExNvccSample",
        extras: ["README.md"]
      ],
      compilers: [:elixir_make] ++ Mix.compilers(),
      package: package()
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
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:elixir_make, "~> 0.6", runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false},
      {:nx, "~> 0.3"}
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "LICENSE",
        "mix.exs",
        "README.md",
        "Makefile",
        "c_src/*.c",
        "c_src/*.h",
        "c_src/*.cu"
      ]
    ]
  end
end
```

* `elixir_make`を設定しました．詳しくは公式ドキュメントをご覧ください．https://hexdocs.pm/elixir_make/Mix.Tasks.Compile.ElixirMake.html

```Makefile:Makefile
.phony: all clean

PRIV = $(MIX_APP_PATH)/priv
BUILD = $(MIX_APP_PATH)/obj
NIF = $(PRIV)/libnif.so

ifeq ($(shell uname -s),Linux)
ifeq ($(NVCC),)
NVCC = $(shell which nvcc)
ifeq ($(NVCC),)
ifeq ($(CUDA),true)
$(error Could not find nvcc. set path to nvcc)
endif
endif
endif
ifneq ($(NVCC),)
CUDA_PATH = $(shell elixir --eval "\"$(NVCC)\" |> Path.split() |> Enum.drop(-2) |> Path.join() |> IO.puts")
CFLAGS += -DCUDA
CUFLAGS += -DCUDA -I$(CUDA_PATH)/include --compiler-options -fPIC
CULDFLAGS += -L$(CUDA_PATH)/lib64
endif
endif

ifeq ($(CROSSCOMPILE),)
ifeq ($(shell uname -s),Linux)
LDFLAGS += -fPIC -shared
CFLAGS += -fPIC
else # macOS
LDFLAGS += -undefined dynamic_lookup -dynamiclib
endif
else
LDFLAGS += -fPIC -shared
CFLAGS += -fPIC
endif

ifeq ($(ERL_EI_INCLUDE_DIR),)
ERLANG_PATH = $(shell elixir --eval ':code.root_dir |> to_string() |> IO.puts')
ifeq ($(ERLANG_PATH),)
$(error Could not find the Elixir installation. Check to see that 'elixir')
endif
ERL_EI_INCLUDE_DIR = $(ERLANG_PATH)/usr/include
ERL_EI_LIBDIR = $(ERLANG_PATH)/usr/lib
endif

ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)

CFLAGS += -std=c11 -O3 -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers

C_SRC = c_src/libnif.c
C_OBJ = $(C_SRC:c_src/%.c=$(BUILD)/%.o)
CU_SRC = c_src/vectorAdd.cu
CU_OBJ = $(CU_SRC:c_src/%.cu=$(BUILD)/%.o)

all: $(PRIV) $(BUILD) $(NIF)

$(PRIV) $(BUILD):
	mkdir -p $@

$(BUILD)/%.o: c_src/%.c
	@echo " CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

ifneq ($(NVCC),)
$(BUILD)/%.o: c_src/%.cu
	@echo " NVCC $(notdir $@)"
	$(NVCC) $(CUFLAGS) -c -o $@ $<
endif

ifeq ($(NVCC),)
$(NIF): $(C_OBJ)
	@echo " LD $(notdir $@)"
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^
else
$(NIF): $(C_OBJ) $(CU_OBJ)
	@echo " LD $(notdir $@)"
	$(NVCC) -o $@ $(ERL_LDFLAGS) $(CULDFLAGS) --compiler-options $(LDFLAGS) $^
endif

clean:
	$(RM) $(NIF) $(C_OBJ)
```

* 環境変数`NVCC`に設定された`nvcc`とそのCUDAバージョンのヘッダファイル・ライブラリを使います．`NVCC`が設定されていないときには`PATH`上の`nvcc`コマンドを見ます

```elixir:lib/ex_nvcc_sample.ex
defmodule ExNvccSample do
  require Logger

  @moduledoc """
  A sample program that connects Elixir and `nvcc`.
  """

  @on_load :load_nif

  @doc false
  def load_nif do
    nif_file = ~c'#{Application.app_dir(:ex_nvcc_sample, "priv/libnif")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end

  @doc """
  Add two tensors with signed 32bit integer.
  ## Examples

      iex> ExNvccSample.add_s32(0, 1)
      #Nx.Tensor<
        s32[1]
        [1]
      >

      iex> ExNvccSample.add_s32(Nx.tensor([0, 1, 2, 3]), Nx.tensor([3, 2, 1, 0]))
      #Nx.Tensor<
        s32[4]
        [3, 3, 3, 3]
      >

  """
  def add_s32(x, y), do: add(x, y, {:s, 32})

  @doc false
  def add(x, y, type) when is_struct(x, Nx.Tensor) and is_struct(y, Nx.Tensor) do
    add_sub(Nx.as_type(x, type), Nx.as_type(y, type), type)
  end

  @doc false
  def add(x, y, type) when is_number(x) do
    add(Nx.tensor([x]), y, type)
  end

  @doc false
  def add(x, y, type) when is_number(y) do
    add(x, Nx.tensor([y]), type)
  end

  defp add_sub(x, y, type) do
    if Nx.shape(x) == Nx.shape(y) do
      Nx.from_binary(add_sub_sub(Nx.size(x), Nx.shape(x), Nx.to_binary(x), Nx.to_binary(y), type), type)
    else
      raise RuntimeError, "shape is not much add(#{inspect Nx.shape(x)}, #{inspect Nx.shape(y)})"
    end
  end

  defp add_sub_sub(size, shape, binary1, binary2, {:s, 32}) do
    try do
      add_s32_nif(size, shape, binary1, binary2)
    rescue
      e in ArgumentError -> raise e
      e in ErlangError -> raise RuntimeError, message: List.to_string(e.original)
    end
  end

  @doc false
  def add_s32_nif(_size, _shape, _binary1, _binary2), do: :erlang.nif_error(:not_loaded)
end
```

* `load_nif`関数でNIFをロードします．
* `add_s32_nif`関数は符号付き32ビット整数版の加算関数のNIFを呼び出すスタブです．なお，`shape`を渡していますが，今回は見ていません．
* `add_s32`関数から順に展開していって，`add_s32_nif`関数を呼び出すようにしています．
* 型の異なる加算関数(例えば `add_f32`関数など)を呼び出すときには`add_sub_sub`関数でパターンマッチ(この例では最後の引数を`{:f, 32}`とします)して，`add_(型)`関数を定義します(この例では`add_f32`関数を定義します)．
* CUDAが失敗したときに発生するErlangErrorを受け取ってRuntimeErrorに変換します．

```c:c_src/libnif.c
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <erl_nif.h>

#ifdef CUDA
#include "vectorAdd.h"
#endif

static ERL_NIF_TERM add_s32_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 4, false)) {
        return enif_make_badarg(env);
    }

    ErlNifUInt64 vec_size;
    if(__builtin_expect(!enif_get_uint64(env, argv[0], &vec_size), false)) {
        return enif_make_badarg(env);
    }

    ERL_NIF_TERM binary1_term = argv[2];
    ErlNifBinary in_data_1;
    if(__builtin_expect(!enif_inspect_binary(env, binary1_term, &in_data_1), false)) {
        return enif_make_badarg(env);
    }
    int32_t *in1 = (int32_t *)in_data_1.data;

    ERL_NIF_TERM binary2_term = argv[3];
    ErlNifBinary in_data_2;
    if(__builtin_expect(!enif_inspect_binary(env, binary2_term, &in_data_2), false)) {
        return enif_make_badarg(env);
    }
    int32_t *in2 = (int32_t *)in_data_2.data;

    ErlNifBinary out_data;
    if(__builtin_expect(!enif_alloc_binary(vec_size * sizeof(uint32_t), &out_data), false)) {
        return enif_make_badarg(env);
    }
    int32_t *out = (int32_t *)out_data.data;

#ifdef CUDA
    const char *cuda_error = "CUDA Error: ";
    char error[MAXBUFLEN];
    memset(error, 0, MAXBUFLEN);

    if(__builtin_expect(!add_s32_cuda(in1, in2, out, vec_size, error), false)) {
        size_t len = MAXBUFLEN + strlen(cuda_error);
        char ret_error[len];
        memset(ret_error, 0, len);
        snprintf(ret_error, len, "%s%s", cuda_error, error);
        return enif_raise_exception(env, enif_make_string(env, ret_error, ERL_NIF_LATIN1));
    }
#else
    for(ErlNifUInt64 i = 0; i < vec_size; i++) {
        out[i] = in1[i] + in2[i];
    }
#endif

    return enif_make_binary(env, &out_data);
}

static ErlNifFunc nif_funcs [] =
{
    {"add_s32_nif", 4, add_s32_nif}
};

ERL_NIF_INIT(Elixir.ExNvccSample, nif_funcs, NULL, NULL, NULL, NULL)
```

* Nxのデータ本体は`binary`で受け渡しをします．
* マクロ`CUDA`が定義されている場合は `c_src/vectorAdd.cu` に定義されているCUDA関数を呼び出します．

```c++:vectorAdd.h
#ifndef VECTOR_ADD_H
#define VECTOR_ADD_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif
bool add_s32_cuda(const int32_t *x, const int32_t *y, int32_t *z, uint64_t numElements, char *error);
#ifdef __cplusplus
}
#endif

#endif // VECTOR_ADD_H
```

* CUDA関数はC++なので，`extern "C"`をつける必要があります．そうしないとリンクで失敗します．

```cuda:vectorAdd.cu
#include <stdio.h>
#include <stdint.h>
#include <cuda_runtime.h>
#include "vectorAdd.h"

__global__ void vectorAdd(const int32_t *A, const int32_t *B, int32_t *C, uint64_t numElements)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < numElements) {
        C[i] = A[i] + B[i];
    }
}

#ifdef __cplusplus
extern "C" {
#endif
bool add_s32_cuda(const int32_t *h_A, const int32_t *h_B, int32_t *h_C, uint64_t numElements, char *error_message)
{
    // Error code to check return values for CUDA calls
    cudaError_t err = cudaSuccess;
    
    // compute numElements
    uint64_t size = numElements * sizeof(int32_t);

    // Verify that allocations succeeded
    if (h_A == NULL || h_B == NULL || h_C == NULL) {
        snprintf(error_message, MAXBUFLEN, "h_A, h_B and h_C must be not NULL.");
        return false;
    }

    // Allocate the device input vector A
    int32_t *d_A = NULL;
    err = cudaMalloc((void **)&d_A, size);
    if (err != cudaSuccess) {
        snprintf(error_message, MAXBUFLEN, "Failed to allocate device vector A (error code %s)!\n",
            cudaGetErrorString(err));
        return false;
    }

    // Allocate the device input vector B
    int32_t *d_B = NULL;
    err = cudaMalloc((void **)&d_B, size);
    if (err != cudaSuccess) {
        snprintf(error_message, MAXBUFLEN, "Failed to allocate device vector B (error code %s)!\n",
            cudaGetErrorString(err));
        return false;
    }


    // Allocate the device input vector C
    int32_t *d_C = NULL;
    err = cudaMalloc((void **)&d_C, size);
    if (err != cudaSuccess) {
        snprintf(error_message, MAXBUFLEN, "Failed to allocate device vector C (error code %s)!\n",
            cudaGetErrorString(err));
        return false;
    }

    // Copy the host input vectors A and B in host memory to the device input
    // vectors in
    // device memory
    err = cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        snprintf(error_message, MAXBUFLEN,
            "Failed to copy vector A from host to device (error code %s)!\n",
            cudaGetErrorString(err));
        return false;
    }

    err = cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
    if (err != cudaSuccess) {
        snprintf(error_message, MAXBUFLEN,
            "Failed to copy vector B from host to device (error code %s)!\n",
            cudaGetErrorString(err));
        return false;
    }

    // Launch the Vector Add CUDA Kernel
    int threadsPerBlock = 256;
    int blocksPerGrid = (numElements + threadsPerBlock - 1) / threadsPerBlock;
    //printf("CUDA kernel launch with %d blocks of %d threads\n", blocksPerGrid,
    //     threadsPerBlock);
    vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, numElements);
    err = cudaGetLastError();

    if (err != cudaSuccess) {
        snprintf(error_message, MAXBUFLEN, "Failed to launch vectorAdd kernel (error code %s)!\n",
             cudaGetErrorString(err));
        return false;
    }

    // Copy the device result vector in device memory to the host result vector
    // in host memory.
    // printf("Copy output data from the CUDA device to the host memory\n");
    err = cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess) {
        snprintf(error_message, MAXBUFLEN,
             "Failed to copy vector C from device to host (error code %s)!\n",
             cudaGetErrorString(err));
        return false;
    }

    // Free device global memory
    err = cudaFree(d_A);
    if (err != cudaSuccess) {
        snprintf(error_message, MAXBUFLEN, "Failed to free device vector A (error code %s)!\n",
             cudaGetErrorString(err));
        return false;
    }
    err = cudaFree(d_B);
    if (err != cudaSuccess) {
        snprintf(error_message, MAXBUFLEN, "Failed to free device vector B (error code %s)!\n",
             cudaGetErrorString(err));
        return false;
    }
    err = cudaFree(d_C);
    if (err != cudaSuccess) {
        snprintf(error_message, MAXBUFLEN, "Failed to free device vector C (error code %s)!\n",
             cudaGetErrorString(err));
        return false;
    }

    return true;
}
#ifdef __cplusplus
}
#endif
```

* CUDA Samples https://docs.nvidia.com/cuda/cuda-samples/index.html の vectorAdd をNIFに合うように改造しました．
* CUDA関数はC++なので，`extern "C"`をつける必要があります．そうしないとリンクで失敗します．




