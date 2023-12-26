---
title: ElixirのNxとMetalを繋ぐ最小コード
tags:
  - Elixir
  - Metal
  - nx
private: false
updated_at: '2022-11-26T09:21:16+09:00'
id: c3d788c621b18636f867
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
ElixirのNxとMetalを繋いでみました．

20220818追記: Nx 0.3.0でも対応していることを確認しました．
20220822追記: `'CharList'` を `~c'CharList'` にしました．[将来，`'CharList'`の書き方はdeprecated(非推奨)になるからです．]( https://github.com/elixir-lang/elixir/issues/12065)




ソースコードはこちらです．

https://github.com/zacky1972/ex_metal_sample



```elixir:mix.exs
defmodule ExMetalSample.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/zacky1972/ex_metal_sample"

  def project do
    [
      app: :ex_metal_sample,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExMetalSample",
      source_url: @source_url,
      docs: [
        main: "ExMetalSample",
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
        "c_src/*.m",
        "c_src/*.metal"
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
MLIB = $(PRIV)/default.metallib

ifeq ($(shell uname -s),Darwin)
CFLAGS += -DMETAL
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
OC_SRC = c_src/wrap_add.m c_src/MetalAdder.m
OC_OBJ = $(OC_SRC:c_src/%.m=$(BUILD)/%.o)

all: $(PRIV) $(BUILD) $(NIF)

$(PRIV) $(BUILD):
	mkdir -p $@

$(BUILD)/%.o: c_src/%.c
	@echo " CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

ifeq ($(shell uname -s),Darwin)
$(BUILD)/%.o: c_src/%.m
	@echo " CLANG $(notdir $@)"
	xcrun clang -c $(OBJC_FLAGS) $(CFLAGS) -o $@ $<
endif

ifeq ($(shell uname -s),Darwin)
$(NIF): $(C_OBJ) $(OC_OBJ)
	@echo " LD $(notdir $@)"
	xcrun clang -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^
else
$(NIF): $(C_OBJ)
	@echo " LD $(notdir $@)"
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^
endif

clean:
	$(RM) $(NIF) $(C_OBJ) $(OC_OBJ) $(MTL_OBJ) $(MLIB)

```

* Macかどうかを判定します．(`Darwin`の部分)
* Objective-Cのプログラムは `xcrun clang`でコンパイルします．またリンクも同様にします．
* ~~Metalのプログラムは`xcrun metal`で`.air`にコンパイルします．その後，`xcrun metallib`で`.metallib`にリンクします．~~ 動的にコンパイルするように変更しました．

~~参考記事:　[Building a Library with Metal’s Command-Line Tools](https://developer.apple.com/documentation/metal/shader_libraries/building_a_library_with_metal_s_command-line_tools?language=objc)~~

```elixir:lib/ex_metal_sample.ex
defmodule ExMetalSample do
  require Logger

  @moduledoc """
  A sample program that connects Elixir and Metal.
  """

  @on_load :init

  @doc false
  def init do
    case load_nif() do
      :ok ->
        case init_metal("c_src/add.metal") do
          :ok -> :ok
          {:error, char_list} -> {:error, List.to_string(char_list)}
        end
    end
  end

  @doc false
  def load_nif do
    nif_file = ~c'#{Application.app_dir(:ex_metal_sample, "priv/libnif")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end

  @doc false
  def init_metal(metal_src) do
    metal_src
    |> File.read!()
    |> String.to_charlist()
    |> init_metal_nif()
  end

  @doc false
  def init_metal_nif(_default_metallib), do: :erlang.nif_error(:not_loaded)

  @doc """
  Add two tensors with signed 32bit integer.
  ## Examples

      iex> ExMetalSample.add_s32(0, 1)
      #Nx.Tensor<
        s32[1]
        [1]
      >

      iex> ExMetalSample.add_s32(Nx.tensor([0, 1, 2, 3]), Nx.tensor([3, 2, 1, 0]))
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
      Nx.from_binary(
        add_sub_sub(Nx.size(x), Nx.shape(x), Nx.to_binary(x), Nx.to_binary(y), type),
        type
      )
    else
      raise RuntimeError,
            "shape is not much add(#{inspect(Nx.shape(x))}, #{inspect(Nx.shape(y))})"
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
* `init_metal`関数で~~Metalを初期化するために必要な`default.metallib`の絶対パスを渡します．~~`c_src/add.metal`を読み込んでNIFに渡します．
* `add_s32_nif`関数は符号付き32ビット整数版の加算関数のNIFを呼び出すスタブです．なお，`shape`を渡していますが，今回は見ていません．
* `add_s32`関数から順に展開していって，`add_s32_nif`関数を呼び出すようにしています．
* 型の異なる加算関数(例えば `add_f32`関数など)を呼び出すときには`add_sub_sub`関数でパターンマッチ(この例では最後の引数を`{:f, 32}`とします)して，`add_(型)`関数を定義します(この例では`add_f32`関数を定義します)．
* Metalが失敗したときに発生する`ErlangError`を受け取って`RuntimeError`に変換します．

```C:c_src/libnif.c
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <erl_nif.h>

#include <stdio.h>

#ifdef METAL
#include "wrap_add.h"
#endif

static ERL_NIF_TERM init_metal_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 1, false)) {
        return enif_make_badarg(env);
    }
#ifdef METAL
    bool ret = true;
    const char *metal_error = "Metal Error: ";
    char error[MAXBUFLEN];
    memset(error, 0, MAXBUFLEN);

    unsigned len;
    if(__builtin_expect(!enif_get_list_length(env, argv[0], &len), false)) {
        return enif_make_badarg(env);
    }
    char *metal_src = enif_alloc(len);
    if(__builtin_expect(metal_src == NULL, false)) {
        return enif_make_badarg(env);
    }
    if(__builtin_expect(!enif_get_string(env, argv[0], metal_src, len, ERL_NIF_LATIN1), false)) {
        return enif_make_badarg(env);
    }
    ret = init_metal(metal_src, error);
    enif_free(metal_src);
    if(ret) {
        return enif_make_atom(env, "ok");
    } else {
        char ret_error[MAXBUFLEN + strlen(metal_error)];
        memset(ret_error, 0, MAXBUFLEN + strlen(metal_error));
        snprintf(ret_error, MAXBUFLEN + strlen(metal_error), "%s%s", metal_error, error);
        return enif_make_tuple2(env, enif_make_atom(env, "error"), enif_make_string(env, ret_error, ERL_NIF_LATIN1));
    }
#else
    return enif_make_atom(env, "ok");
#endif
}

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
    if(__builtin_expect(!enif_alloc_binary(vec_size * sizeof(int32_t), &out_data), false)) {
        return enif_make_badarg(env);
    }
    int32_t *out = (int32_t *)out_data.data;

#ifdef METAL
    const char *metal_error = "Metal Error: ";
    char error[MAXBUFLEN];
    memset(error, 0, MAXBUFLEN);

    if(__builtin_expect(!add_s32_metal(in1, in2, out, vec_size, error), false)) {
        size_t len = MAXBUFLEN + strlen(metal_error);
        char ret_error[len];
        memset(ret_error, 0, len);
        snprintf(ret_error, len, "%s%s", metal_error, error);
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
    {"init_metal_nif", 1, init_metal_nif},
    {"add_s32_nif", 4, add_s32_nif}
};

ERL_NIF_INIT(Elixir.ExMetalSample, nif_funcs, NULL, NULL, NULL, NULL)
```

* Nxのデータ本体はbinaryで受け渡しをします．
* マクロ`METAL`が定義されている場合は `c_src/wrap_add.m` に定義されているObjective-C関数を呼び出します．

```Objective-C:wrap_add.h
#ifndef WRAP_ADD_H
#define WRAP_ADD_H

#include <stdbool.h>
#include <stdint.h>

#define MAXBUFLEN 1024

bool init_metal(const char *metal_src, char *error);

bool add_s32_metal(const int32_t *in1, const int32_t *in2, int32_t *out, uint64_t vec_size, char *error);

#endif // WRAP_ADD_H
```

* CのコードからObjective-Cのコードへの橋渡しをする関数のプロトタイプ宣言です．

```Objective-c:wrap_add.m
#import <string.h>
#import <stdio.h>
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MetalAdder.h"
#import "wrap_add.h"

bool init_metal(const char *metal_src, char *error_message)
{
    @autoreleasepool {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        if(device == nil) {
            snprintf(error_message, MAXBUFLEN, "Device not found");
            return false;
        }

        NSError* error = nil;

        NSString *src = [NSString stringWithCString:metal_src encoding:NSUTF8StringEncoding];

        MTLCompileOptions* options = [MTLCompileOptions new];
        options.languageVersion = MTLLanguageVersion2_4;

        addLibrary = [device newLibraryWithSource:src options:options error:&error];
        if(addLibrary == nil || error != nil) {
            snprintf(error_message, MAXBUFLEN, "Fail to create new library from source.");
            return false;
        }
    }
    return true;
}

bool add_s32_metal(const int32_t *in1, const int32_t *in2, int32_t *out, uint64_t vec_size, char *error)
{
    @autoreleasepool {
        
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();

        if(device == nil) {
            snprintf(error, MAXBUFLEN, "Device not found");
            return false;
        }

        // Create the custom object used to encapsulate the Metal code.
        // Initializes objects to communicate with the GPU.
        MetalAdder* adder = [[MetalAdder alloc] initWithDevice:device error:error];
        
        if(adder == nil) {
            return false;
        }

        // Create buffers to hold data
        if(![adder prepareData:in1 inB:in2 size:vec_size error:error]) {
             return false;
        }
        
        // Send a command to the GPU to perform the calculation.
        int32_t *result = [adder sendComputeCommand:vec_size error:error];
        if(result == nil) {
            return false;
        }
        memcpy(out, result, vec_size * sizeof(int32_t));
    }
    return true;
}
```

* このコードの`add_s32_metal`関数は [Performing Calculations on a GPU](https://developer.apple.com/documentation/metal/performing_calculations_on_a_gpu?language=objc) の`main`関数を参考にしました．
* `init_metal`関数で読み込んだMetalのソースコードを動的コンパイルして`addLibrary`に設定します．

```Objective-C:MetalAdder.h
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

id<MTLLibrary> addLibrary;

@interface MetalAdder : NSObject 
- (instancetype) initWithDevice: (id<MTLDevice>) device error:(char*)error;
- (bool) prepareData: (const int32_t*)inA inB: (const int32_t*)inB size: (size_t)vec_size error:(char*)error;
- (int32_t*) sendComputeCommand: (size_t)vec_size error:(char*)error;
@end

NS_ASSUME_NONNULL_END
```

このコードは [Performing Calculations on a GPU](https://developer.apple.com/documentation/metal/performing_calculations_on_a_gpu?language=objc) の`MetalAdder.h`を参考にしました．

```Objective-C:MetalAdder.m
#import <stdio.h>
#import "MetalAdder.h"
#import "wrap_add.h"

@implementation MetalAdder
{
    id<MTLDevice> _mDevice;

    // The compute pipeline generated from the compute kernel in the .metal shader file.
    id<MTLComputePipelineState> _mAddFunctionPSO;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _mCommandQueue;

    // Buffers to hold data.
    id<MTLBuffer> _mBufferA;
    id<MTLBuffer> _mBufferB;
    id<MTLBuffer> _mBufferResult;

}

- (instancetype) initWithDevice: (id<MTLDevice>) device error:(char*)error_message
{
    self = [super init];
    if (self)
    {
        _mDevice = device;

        NSError* error = nil;

        if (addLibrary == nil)
        {
            snprintf(error_message, MAXBUFLEN, "addLibrary must be not nil.");
            return nil;
        }

        id<MTLFunction> addFunction = [addLibrary newFunctionWithName:@"add_arrays"];
        if (addFunction == nil)
        {
            snprintf(error_message, MAXBUFLEN, "Failed to find the adder function.");
            return nil;
        }

        // Create a compute pipeline state object.
        _mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction:addFunction error:&error];
        if (_mAddFunctionPSO == nil || error != nil)
        {
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode)
            snprintf(error_message, MAXBUFLEN, "Failed to created pipeline state object, error: %s", [[error description] UTF8String]);
            return nil;
        }

        _mCommandQueue = [_mDevice newCommandQueue];
        if (_mCommandQueue == nil)
        {
            snprintf(error_message, MAXBUFLEN, "Failed to find the command queue.");
            return nil;
        }
    }

    return self;
}

- (bool)prepareData:(const int32_t *)inA inB:(const int32_t *)inB size:(size_t)vec_size error:(char*)error_message
{
    // Allocate three buffers to hold our initial data and the result.
    size_t bufferSize = sizeof(int32_t) * vec_size;
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];

    if(_mBufferA == nil || _mBufferB == nil || _mBufferResult == nil) {
        snprintf(error_message, MAXBUFLEN, "Failed to create data buffer.");
        return false;
    }

    if(!([self generateData:_mBufferA in:inA size: vec_size error:error_message]
        && [self generateData:_mBufferB in:inB size: vec_size error:error_message])) {
        return false;
    }
    return true;
}

- (int32_t*) sendComputeCommand: (size_t)vec_size error: (char*)error_message
{
    // Create a command buffer to hold commands.
    id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
    if(commandBuffer == nil) {
        snprintf(error_message, MAXBUFLEN, "Failed to create command buffer.");
        return nil;
    }

    // Start a compute pass.
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    if(computeEncoder == nil) {
        snprintf(error_message, MAXBUFLEN, "Failed to create compute encoder.");
        return nil;
    }

    if(![self encodeAddCommand:computeEncoder size: vec_size error:error_message]) {
        return nil;
    }

    // End the compute pass.
    [computeEncoder endEncoding];

    // Execute the command.
    [commandBuffer commit];

    // Normally, you want to do other work in your app while the GPU is running,
    // but in this example, the code simply blocks until the calculation is complete.
    [commandBuffer waitUntilCompleted];

    if(_mBufferResult == nil) {
        snprintf(error_message, MAXBUFLEN, "_mBufferResult must not be nil.");
        return nil;
    }

    if(_mBufferResult.contents == nil) {
        snprintf(error_message, MAXBUFLEN, "_mBufferResult.contents must not be nil.");
        return nil;
    }
    return _mBufferResult.contents;
}

- (bool)encodeAddCommand:(id<MTLComputeCommandEncoder>)computeEncoder size: (size_t)vec_size error: (char*) error_message 
{
    // Encode the pipeline state object and its parameters.
    if(_mAddFunctionPSO == nil) {
        snprintf(error_message, MAXBUFLEN, "_mAddFunctionPS0 must not be nil.");
        return false;
    }
    if(_mBufferA == nil) {
        snprintf(error_message, MAXBUFLEN, "_mBufferA must not be nil.");
        return false;
    }
    if(_mBufferB == nil) {
        snprintf(error_message, MAXBUFLEN, "_mBufferB must not be nil.");
        return false;
    }
    if(_mBufferResult == nil) {
        snprintf(error_message, MAXBUFLEN, "_mBufferResult must not be nil.");
        return false;
    }
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
    [computeEncoder setBuffer:_mBufferA offset:0 atIndex:0];
    [computeEncoder setBuffer:_mBufferB offset:0 atIndex:1];
    [computeEncoder setBuffer:_mBufferResult offset:0 atIndex:2];

    MTLSize gridSize = MTLSizeMake(vec_size, 1, 1);

    // Calculate a threadgroup size.
    NSUInteger threadGroupSize = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
    if (threadGroupSize > vec_size)
    {
        threadGroupSize = vec_size;
    }
    MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);

    // Encode the compute command.
    [computeEncoder dispatchThreads:gridSize
              threadsPerThreadgroup:threadgroupSize];
    return true;
}

- (bool) generateData:(id<MTLBuffer>)buffer in: (const int32_t *) in size:(size_t)vec_size error:(char*)error_message
{
    if(buffer == nil) {
        snprintf(error_message, MAXBUFLEN, "buffer must not be nil.");
        return false;
    }

    int32_t* dataPtr = buffer.contents;
    if(dataPtr == nil) {
        snprintf(error_message, MAXBUFLEN, "Fail to get buffer.contents.");
        return false;
    }

    if(in == nil) {
        snprintf(error_message, MAXBUFLEN, "in must not be nil");
        return false;
    }

    for (size_t index = 0; index < vec_size; index++)
    {
        dataPtr[index] = in[index];
    }
    return true;
}
@end
```

* このコードは [Performing Calculations on a GPU](https://developer.apple.com/documentation/metal/performing_calculations_on_a_gpu?language=objc) の`MetalAdder.m`を参考にしました．
* ~~苦労したのは，`add.metal`をコンパイルしてできた`default.metallib`を読み込ませることでした．試行錯誤した末，`MTLDevice`の`newLibraryWithURL`を使いました．https://developer.apple.com/documentation/metal/mtldevice/2877432-newlibrarywithurl~~
* `addLibrary`に読み込んだMetalコードを実行します．


```add.metal
#include <metal_stdlib>

using namespace metal;
/// This is a Metal Shading Language (MSL) function equivalent to the add_arrays() C function, used to perform the calculation on a GPU.
kernel void add_arrays(device const int32_t* inA,
                       device const int32_t* inB,
                       device int32_t* result,
                       uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
    result[index] = inA[index] + inB[index];
}
```

このコードは [Performing Calculations on a GPU](https://developer.apple.com/documentation/metal/performing_calculations_on_a_gpu?language=objc) の`add.metal`を参考にしました．


