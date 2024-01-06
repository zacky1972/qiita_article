---
title: ElixirのNxとMetalもしくはCUDAを繋ぐ最小コード
tags:
  - CUDA
  - Elixir
  - Metal
  - nx
private: false
updated_at: '2022-11-26T09:20:19+09:00'
id: 11061b6c4fc9d844321f
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
次の2つを統合しました．

* [ElixirのNxとMetalを繋ぐ最小コード](https://qiita.com/zacky1972/items/c3d788c621b18636f867)
* [ElixirのNxとCUDAを繋ぐ最小コード](https://qiita.com/zacky1972/items/0532849a8f75b2f09959)

コード全体は下記の通りです．

https://github.com/zacky1972/sample_nx_add_by_gpu

20221028追記: macOS Ventura 13.0 でも現状ソースコードで問題なく動作することを確認しました．


## `mix.exs`

```elixir:mix.exs
defmodule SampleNxAddByGpu.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/zacky1972/sample_nx_add_by_gpu"
  @module_name "SampleNxAddByGpu"

  def project do
    [
      app: :sample_nx_add_by_gpu,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: @module_name,
      source_url: @source_url,
      docs: [
        main: @module_name,
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
        "nif_src/*.c",
        "nif_src/*.h",
        "nif_src/cuda/*.h",
        "nif_src/cuda/*.cu",
        "nif_src/metal/*.h",
        "nif_src/metal/*.m",
        "nif_src/metal/*.metal"
      ]
    ]
  end
end
```

* `elixir_make`を設定しています．`deps`と`project`の`compilers`です．詳しくは公式ドキュメントをご覧ください．https://hexdocs.pm/elixir_make/Mix.Tasks.Compile.ElixirMake.html
* `package`に`elixir_make`でコンパイルするのに必要なコード一式を入れています．Hexに公開するときに必要になります．
* Nxを`deps`に入れています．2022年8月21日現在の最新版は0.3.0です．
* `ex_doc`を設定しています．`mix docs`コマンドを実行するとドキュメントが生成されます．`deps`と`project`の`name`, `source_url`, `docs` です．メインページをモジュール`SampleNxAddByGpu`に設定してみました．

## `Makefile`

```make:Makefile
.phony: all clean

PRIV = $(MIX_APP_PATH)/priv
BUILD = $(MIX_APP_PATH)/obj
NIF = $(PRIV)/libnif.so

ifeq ($(shell uname -s),Darwin)
CFLAGS += -DMETAL
endif

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

NIF_SRC_DIR = nif_src
C_SRC = $(NIF_SRC_DIR)/libnif.c
C_OBJ = $(C_SRC:$(NIF_SRC_DIR)/%.c=$(BUILD)/%.o)

CUDA_SRC_DIR = $(NIF_SRC_DIR)/cuda
CU_SRC = $(CUDA_SRC_DIR)/vectorAdd.cu
CU_OBJ = $(CU_SRC:$(CUDA_SRC_DIR)/%.cu=$(BUILD)/%.o)

METAL_SRC_DIR = $(NIF_SRC_DIR)/metal
OC_SRC = $(METAL_SRC_DIR)/wrap_add.m $(METAL_SRC_DIR)/MetalAdder.m
OC_OBJ = $(OC_SRC:$(METAL_SRC_DIR)/%.m=$(BUILD)/%.o)


all: $(PRIV) $(BUILD) $(NIF)

$(PRIV) $(BUILD):
	mkdir -p $@

$(BUILD)/%.o: $(NIF_SRC_DIR)/%.c
	@echo " CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

ifeq ($(shell uname -s),Darwin)
$(BUILD)/%.o: $(METAL_SRC_DIR)/%.m
	@echo " CLANG $(notdir $@)"
	xcrun clang -c $(OBJC_FLAGS) $(CFLAGS) -o $@ $<
endif

ifneq ($(NVCC),)
$(BUILD)/%.o: $(CUDA_SRC_DIR)/%.cu
	@echo " NVCC $(notdir $@)"
	$(NVCC) $(CUFLAGS) -c -o $@ $<
endif

ifneq ($(NVCC),)
$(NIF): $(C_OBJ) $(CU_OBJ)
	@echo " LD $(notdir $@)"
	$(NVCC) -o $@ $(ERL_LDFLAGS) $(CULDFLAGS) --compiler-options $(LDFLAGS) $^
else
ifeq ($(shell uname -s),Darwin)
$(NIF): $(C_OBJ) $(OC_OBJ)
	@echo " LD $(notdir $@)"
	xcrun clang -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^
else
$(NIF): $(C_OBJ)
	@echo " LD $(notdir $@)"
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^
endif
endif

clean:
	$(RM) $(NIF) $(C_OBJ) $(CU_OBJ) $(OC_OBJ)
```

順に解説していきます．

下記は `all` と `clean` というターゲットに対応するファイルが存在しなくて良いことを `make` に指示しています．

```make
.phony: all clean
```

下記で `Makefile` 中で用いる定数を定義しています．

* `$(MIX_APP_PATH)`は，`elixir_make`が設定する環境変数で，Elixirで[`Application.app_dir(:sample_nx_add_by_gpu)`](https://hexdocs.pm/elixir/1.13/Application.html#app_dir/1)を評価した結果の文字列が入ります．これは，アプリケーション SampleNxAddByGpu(つまり，このプログラム)のためのディレクトリのPATHを返します．
* `PRIV = $(MIX_APP_PATH)/priv` は，NIFライブラリなど，実行に必要なプライベートデータを配置するディレクトリを`PRIV`に定義します．このディレクトリ名を変えると正常に動作しません．
* `BUILD = $(MIX_APP_PATH)/obj`は，コンパイルの中間結果を配置するディレクトリを`OBJ`に定義します．このディレクトリ名を変えても正常に動作すると思います．
* `NIF = $(PRIV)/libnif.so` は生成するNIFライブラリのPATHを`NIF`に定義します．`libnif`は，後で紹介する`lib/sample_nx_add_by_gpu.ex`の`SampleNxAddByGpu.load_nif/0`関数で指定するNIFファイル名と一致させる必要があります．

```make
PRIV = $(MIX_APP_PATH)/priv
BUILD = $(MIX_APP_PATH)/obj
NIF = $(PRIV)/libnif.so
```

下記で，Macかどうかを判定して，Macだったら`METAL`マクロを定義するように，Cコンパイラに渡すオプション`CFLAGS`を指定します(Cコード中で`#define METAL`したのと同じ効果)．`uname -s`コマンドをmacOS上で動作させると，`Darwin`が返ってきます．

```make
ifeq ($(shell uname -s),Darwin)
CFLAGS += -DMETAL
endif
```

下記はCUDA関係の設定をしています．

* `ifeq ($(shell uname -s),Linux)`で，Linuxかどうかを判定しています．このコードでは，CUDAを実行する環境として，Linuxのみを想定しています．Windowsにはまだ対応していないので，ご了承ください．
* `ifeq ($(NVCC),)`で環境変数`NVCC`が設定されていない場合を判定します．これは`nvcc`コマンドのPATHを入れていることが想定されています．`nvcc`コマンドはCUDAのコードをコンパイルするNVIDIA製のコマンドです．
    * もし設定されていなかった場合，`NVCC = $(shell which nvcc)`として，`which nvcc`コマンドを実行した結果を `NVCC` に設定します．
    * それでもなお`NVCC`が設定されない場合
        * `CUDA`が設定されている場合には，エラー`Could not find nvcc. set path to nvcc`を出力して終了します．
        * そうでない場合は，無視します．(CUDA無しでの実行)
* その後の`CUDA_PATH = $(shell elixir --eval "\"$(NVCC)\" |> Path.split() |> Enum.drop(-2) |> Path.join() |> IO.puts")`では`NVCC`が，通常，`/usr/local/cuda/bin/nvcc`のように設定されているはずなので，これを `/usr/local/cuda` に加工する Elixir のワンライナーを実行して `CUDA_PATH` に入れます．前提として末尾が`bin/nvcc`であることです．
* `CFLAGS += -DCUDA` と `CUFLAGS += -DCUDA`で，`CUDA`マクロを定義するように，Cコンパイラに渡すオプション`CFLAGS`，`nvcc`で`.cu`ファイルをコンパイルするときに渡すオプション`CUFLAGS`を指定します(コード中で`#define CUDA`したのと同じ効果)．
* 先ほどの`CUDA_PATH`をもとに，`CUFLAGS`に`-I$(CUDA_PATH)/include`を設定することで，CUDAのヘッダファイルを読み込むように設定します．
* `CUFLAGS`に`--compiler-options -fPIC`を設定することで，`nvcc`からC++コンパイラを実行するときのコンパイラオプションに`-fPIC`を設定します．これは，今回のように共有ライブラリをLinuxで作成するときに指定するオプションで，プログラムのロード位置に依存しないコードを生成するという意味です．共有ライブラリだと，リンカがプログラムロード位置を調整するので，このオプションを指定すると良いということです．
* `CULDFLAGS += -L$(CUDA_PATH)/lib64` で，`nvcc`でリンクするときに渡すオプションとして，CUDAのライブラリを読み込ませるように設定します．

```make
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
```

下記のコードは，共有ライブラリの設定をしています．Nervesでクロスコンパイルするときにも対応したコードです．

* Nervesでクロスコンパイルするときには`CROSSCOMPILE`という環境変数が設定されます．`ifeq ($(CROSSCOMPILE),)`でクロスコンパイルで無い場合を判別します．
* クロスコンパイルでない場合には，ホストで実行するファイルをコンパイルします．
    * Linuxならば，リンカに渡すオプション`LDFLAGS`に`-fPIC -shared`を，Cコンパイラに渡すオプション`CFLAGS`に`-fPIC`をそれぞれ設定します．
        * `-fPIC`は，今回のように共有ライブラリをLinuxで作成するときに指定するオプションで，プログラムのロード位置に依存しないコードを生成するという意味です．共有ライブラリだと，リンカがプログラムロード位置を調整するので，このオプションを指定すると良いということです．
        * `-shared` は共有ライブラリを生成するようにリンカに指示します．
    * macOSならば，`LDFLAGS += -undefined dynamic_lookup -dynamiclib`とします．
        * `-undefined dynamic_lookup` は，すべての未定義シンボルを実行時に検索する必要があるものとしてマークします．
        * `-dynamiclib`は，共有ライブラリ作成をリンカに指示します．
    * そのほかのOSには対応していません．
* クロスコンパイルである場合は，ターゲットで実行するファイルをコンパイルします．NervesのターゲットのOSは，Linuxであることを想定しています．この後の動作は，ホストのOSがLinuxである場合と同様です．


```make
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
```

下記は，Erlang VMのヘッダファイルとライブラリを読み込むように設定しています．前半でヘッダファイルのPATHを指定する`ERL_EI_INCLUDE_DIR`とライブラリのPATHを指定する`ERL_EI_LIBDIR`を設定し，後半でCコンパイラに渡すオプション`ERL_CFLAGS`と，リンカに渡すオプション`ERL_LDFLAGS`を設定します．

* `ERL_EI_INCLUDE_DIR`をあらかじめ指定されている場合(たとえば，Nervesでクロスコンパイルする場合)，前半をパスします．
* 指定されていない場合は，まず，`ERLANG_PATH`にElixirで`:code.root_dir`を実行したときの結果を設定します．`:code.root_dir/0`は，Erlangのルートディレクトリを返す関数です．https://www.erlang.org/doc/man/code.html#root_dir-0
* もしこれが空だったら，`elixir_make`経由で実行していないことを意味するので，`Could not find the Elixir installation. Check to see that 'elixir'`をエラー表示して終了します．
* その後，`ERLANG_PATH`を元に，`ERL_EI_INCLUDE_DIR`と`ERL_EI_LIBDIR`を設定します．

その後，`ERL_EI_INCLUDE_DIR`を元に`ERL_CFLAGS`を，`ERL_EI_LIBDIR`を元に`ERL_LDFLAGS`を，それぞれ設定します．


```make
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
```

下記で，C11規格でコンパイルすること，最適化レベルを3にすること，警告を全て出し，追加の警告も出し，未使用関数と未使用引数の警告は出さず，フィールド初期化子が抜けている警告も出さないという指定をしています．警告関係の設定は，NIFをコンパイルするときに有用になるようにしています．

```make
CFLAGS += -std=c11 -O3 -Wall -Wextra -Wno-unused-function -Wno-unused-parameter -Wno-missing-field-initializers
```

下記でソースコードの場所を指定しています．次のようになるように設定しています．

* `C_SRC`: `nif_src/libnif.c`
* `C_OBJ`: `$(BUILD)/libnif.o`
* `CU_SRC`: `nif_src/cuda/vectorAdd.cu`
* `CU_OBJ`: `$(BUILD)/vectorAdd.o`
* `OC_SRC`: `nif_src/metal/wrap_add.m nif_src/metal/MetalAdder.m` 
* `OC_OBJ`: `$(BUILD)/wrap_add.o $(BUILD)/MetalAdder.o`

```make
NIF_SRC_DIR = nif_src
C_SRC = $(NIF_SRC_DIR)/libnif.c
C_OBJ = $(C_SRC:$(NIF_SRC_DIR)/%.c=$(BUILD)/%.o)

CUDA_SRC_DIR = $(NIF_SRC_DIR)/cuda
CU_SRC = $(CUDA_SRC_DIR)/vectorAdd.cu
CU_OBJ = $(CU_SRC:$(CUDA_SRC_DIR)/%.cu=$(BUILD)/%.o)

METAL_SRC_DIR = $(NIF_SRC_DIR)/metal
OC_SRC = $(METAL_SRC_DIR)/wrap_add.m $(METAL_SRC_DIR)/MetalAdder.m
OC_OBJ = $(OC_SRC:$(METAL_SRC_DIR)/%.m=$(BUILD)/%.o)
```

下記で，ビルドするのは`PRIV`ディレクトリと`BUILD`ディレクトリと`NIF`であることを指定します．

```make
all: $(PRIV) $(BUILD) $(NIF)
```

下記で，`PRIV`ディレクトリと`BUILD`ディレクトリを作成します．

```make
$(PRIV) $(BUILD):
	mkdir -p $@
```

下記で，Cコンパイラにてコンパイルします．オプションは`ERL_CFLAGS`と`CFLAGS`です．

```make
$(BUILD)/%.o: $(NIF_SRC_DIR)/%.c
	@echo " CC $(notdir $@)"
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<
```

Macの時には，Objective-Cのファイルをコンパイルします．`xcrun clang`とすることで，Appleのコンパイラを指定してコンパイルしています・

```make
ifeq ($(shell uname -s),Darwin)
$(BUILD)/%.o: $(METAL_SRC_DIR)/%.m
	@echo " CLANG $(notdir $@)"
	xcrun clang -c $(OBJC_FLAGS) $(CFLAGS) -o $@ $<
endif
```

CUDAの時には，`nvcc`を使って`.cu`ファイルをコンパイルします．

```make
ifneq ($(NVCC),)
$(BUILD)/%.o: $(CUDA_SRC_DIR)/%.cu
	@echo " NVCC $(notdir $@)"
	$(NVCC) $(CUFLAGS) -c -o $@ $<
endif
```

下記でそれぞれの環境に合わせてリンクします．CUDAの場合とMetalの場合でリンクで用いるコマンドがそれぞれ異なり，兼ね合わせることができないのですが，幸いなことに，CUDAかつMetalの場合は存在しないので，リンクすることができます．

* CUDAの場合は `nvcc`コマンドを使ってリンクします．`ERL_LDFLAGS`と`CULDFLAGS`は`nvcc`コマンドに渡しますが，`LDFLAGS`は`--compiler-options`を使って，`g++`に渡す必要があります．
* Metalの場合は，`xcrun clang`コマンドを使ってリンクします．そうすることで，必要なフレームワークも自動的にリンクしてくれます．
* どちらでもない場合は，`CC`で指定されるCコンパイラを使ってリンクします．


```make
ifneq ($(NVCC),)
$(NIF): $(C_OBJ) $(CU_OBJ)
	@echo " LD $(notdir $@)"
	$(NVCC) -o $@ $(ERL_LDFLAGS) $(CULDFLAGS) --compiler-options $(LDFLAGS) $^
else
ifeq ($(shell uname -s),Darwin)
$(NIF): $(C_OBJ) $(OC_OBJ)
	@echo " LD $(notdir $@)"
	xcrun clang -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^
else
$(NIF): $(C_OBJ)
	@echo " LD $(notdir $@)"
	$(CC) -o $@ $(ERL_LDFLAGS) $(LDFLAGS) $^
endif
endif
```

`mix clean`を実行したときにファイルを初期化します．

```make
clean:
	$(RM) $(NIF) $(C_OBJ) $(CU_OBJ) $(OC_OBJ)
```

## `lib/sample_nx_add_by_gpu.ex`

```elixir:lib/sample_nx_add_by_gpu.ex
defmodule SampleNxAddByGpu do
  require Logger

  @moduledoc """
  A sample program that connects Nx and GPU (CUDA or Metal).
  """

  @on_load :init

  @doc false
  def init do
    case load_nif() do
      :ok ->
        case init_metal("nif_src/metal/add.metal") do
          :ok -> :ok
          {:error, char_list} -> {:error, List.to_string(char_list)}
        end
    end
  end

  @doc false
  def load_nif do
    nif_file = ~c'#{Application.app_dir(:sample_nx_add_by_gpu, "priv/libnif")}'

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
  def init_metal_nif(_metal_src), do: :erlang.nif_error(:not_loaded)

  @doc """
  Add two tensors with signed 32bit integer.
  ## Examples

      iex> SampleNxAddByGpu.add_s32(0, 1)
      #Nx.Tensor<
        s32[1]
        [1]
      >

      iex> SampleNxAddByGpu.add_s32(Nx.tensor([0, 1, 2, 3]), Nx.tensor([3, 2, 1, 0]))
      #Nx.Tensor<
        s32[4]
        [3, 3, 3, 3]
      >

  """
  def add_s32(x, y), do: add_s32(x, y, :gpu)

  @doc """
  Add two tensors with signed 32bit integer with specified processor.
  ## Examples

      iex> SampleNxAddByGpu.add_s32(2, 3, :gpu)
      #Nx.Tensor<
        s32[1]
        [5]
      >

      iex> SampleNxAddByGpu.add_s32(4, 5, :cpu)
      #Nx.Tensor<
        s32[1]
        [9]
      >
  """
  def add_s32(x, y, processor), do: add(x, y, {:s, 32}, processor)

  @doc false
  def add(x, y, type, processor) when is_struct(x, Nx.Tensor) and is_struct(y, Nx.Tensor) do
    add_sub(Nx.as_type(x, type), Nx.as_type(y, type), type, processor)
  end

  @doc false
  def add(x, y, type, processor) when is_number(x) do
    add(Nx.tensor([x]), y, type, processor)
  end

  @doc false
  def add(x, y, type, processor) when is_number(y) do
    add(x, Nx.tensor([y]), type, processor)
  end

  defp add_sub(x, y, type, processor) do
    if Nx.shape(x) == Nx.shape(y) do
      Nx.from_binary(add_sub_sub(Nx.size(x), Nx.shape(x), Nx.to_binary(x), Nx.to_binary(y), type, processor), type)
    else
      raise RuntimeError, "shape is not much add(#{inspect Nx.shape(x)}, #{inspect Nx.shape(y)})"
    end
  end

  defp add_sub_sub(size, shape, binary1, binary2, {:s, 32}, processor) do
    try do
      add_s32_sub(size, shape, binary1, binary2, processor)
    rescue
      e in ArgumentError -> raise e
      e in ErlangError -> raise RuntimeError, message: List.to_string(e.original)
    end
  end

  defp add_s32_sub(size, shape, binary1, binary2, :gpu) do
    add_s32_gpu_nif(size, shape, binary1, binary2)
  end

  defp add_s32_sub(size, shape, binary1, binary2, :cpu) do
    add_s32_cpu_nif(size, shape, binary1, binary2)
  end

  @doc false
  def add_s32_gpu_nif(_size, _shape, _binary1, _binary2), do: :erlang.nif_error(:not_loaded)

  @doc false
  def add_s32_cpu_nif(_size, _shape, _binary1, _binary2), do: :erlang.nif_error(:not_loaded)
end
```

下記では次のことを定義しています．


* このモジュールが`SampleNxAddByGpu`であることを定義しています．Elixirではモジュール名はキャメルケースで表現します．
* ログを出力するモジュール`Logger`を使えるようにしています．後のところでNIFの読み込みに失敗した時に`Logger`に出力するので，必要です．
* モジュールの説明を`A sample program ...`としています．`ex_doc`がこの部分をMarkDownであるとして整形して出力してくれます．

```elixir
defmodule SampleNxAddByGpu do
  require Logger

  @moduledoc """
  A sample program that connects Nx and GPU (CUDA or Metal).
  """
```

下記では次のことをします．

* `@on_load :init`で，このモジュールのロード時に `SampleNxAddByGpu.init/0` 関数を呼び出します．
    * `SampleNxAddByGpu.init/0`の返す値が `:ok` であった場合には正常にモジュールが読み込まれます．それ以外の結果が返ってきた時には，モジュールが読み込まれず無効になります．公式ドキュメントはこちら https://hexdocs.pm/elixir/1.13/Module.html#module-on_load
* `@doc false`とすることで，`SampleNxAddByGpu.init/0`関数のドキュメント生成を抑制します．また，`iex`コマンドで関数の補完の対象にならないように設定されます．公式ドキュメントはこちら https://hexdocs.pm/elixir/1.13/Module.html#module-doc-and-typedoc
* `def init do ... end` で `SampleNxAddByGpu.init/0`関数を定義します．
* `case load_nif() do ... end` で `SampleNxAddByGpu.load_nif/0`関数を呼び出し，その結果を見て次のように条件分岐します．
    * `:ok`だった場合
        * `case init_metal("nif_src/metal/add.metal") do ... end` として，`SampleNxAddByGpu.init_metal/1`関数を呼び出して，Metalの初期化として，`nif_src/metal/add.metal`を読み込むように設定し，その結果を見て条件分岐をします．
            * `:ok`だった場合，`:ok`を返します．
            * `{:error, char_list}` だった場合，エラーが返ってきたことを意味します．`char_list`にはErlangの文字列の形式である文字のリストが入っているので，`List.to_string/1`関数を使ってElixirの文字列であるバイナリ形式に変換します．`List.to_string/1`関数の公式ドキュメントはこちら https://hexdocs.pm/elixir/1.13/List.html#to_string/1

```elixir
  @on_load :init

  @doc false
  def init do
    case load_nif() do
      :ok ->
        case init_metal("nif_src/metal/add.metal") do
          :ok -> :ok
          {:error, char_list} -> {:error, List.to_string(char_list)}
        end
    end
  end
```

下記では，関数`SampleNxAddByGpu.load_nif/0`関数を次のように定義しています．

* `@doc false`は前項で説明しました．
* `nif_file`に，Erlangの文字列でNIFのライブラリへのPATHを与えています．
    * `Application.app_dir/2`関数はアプリケーション`SampleNxAddByGpu`用のディレクトリへのPATHに`priv/nif`を末尾につけたPATHを返します．公式ドキュメントはこちら https://hexdocs.pm/elixir/1.13/Application.html#app_dir/2
    * `~c'charlist'`はErlangの文字列(文字のリスト)を表します．従来は`'charlist'`と表現していたのですが，近い将来 deprecated (非推奨)になる見込みで，`~c'charlist'`と書き換えることを推奨されています．詳しくは https://github.com/elixir-lang/elixir/issues/12065
* `case :erlang.load_nif(niffile, 0) do ... end`により，`nif_file`をNIFとして読み込み，その結果を見て条件分岐します．
    * `:erlang.load_nif/2`の公式ドキュメントはこちら https://www.erlang.org/doc/man/erlang.html#load_nif-2
    * `:ok`の場合 `:ok`を返します．
    * `{:error, {:reload, _}}`の場合は，リロードした場合なので，`:ok`を返します．
    * それ以外の場合は，失敗した理由を`Logger`にエラーとして出力して，`:ok`を返します．`Logger.error/2`の公式ドキュメントはこちら https://hexdocs.pm/logger/1.12.3/Logger.html#error/2


```elixir
  @doc false
  def load_nif do
    nif_file = ~c'#{Application.app_dir(:sample_nx_add_by_gpu, "priv/libnif")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end
```

下記では，`SampleNxAddByGpu.init_metal/1`関数を呼び出して，Elixir文字列`metal_src`で与えられたPATHからファイルを読み込み(`File.read!/1`関数 https://hexdocs.pm/elixir/1.13/File.html#read!/1 )，読み込んで得られたElixir文字列をErlang文字列に変換して(`String.to_charlist/1`関数 https://hexdocs.pm/elixir/1.12/String.html#to_charlist/1 )，`SampleNxAddByGpu.init_metal_nif/1`関数に渡しています．

```elixir
  @doc false
  def init_metal(metal_src) do
    metal_src
    |> File.read!()
    |> String.to_charlist()
    |> init_metal_nif()
  end
```

下記では `SampleNxAddByGpu.init_metal_nif/1`関数を定義しています．これはNIF関数として定義されるもので，NIFが正常にロードされなかった場合には，`:not_loaded`を引数に与えて `:erlang.nif_error/1` https://www.erlang.org/doc/man/erlang.html#nif_error-1 を呼び出し，終了します．NIFを表す書き方はいろいろありますが，型検査ツールDialyzerのことを考えると，この形式が良いということでした． `@doc false`としています．

```elixir
  @doc false
  def init_metal_nif(_metal_src), do: :erlang.nif_error(:not_loaded)
```

下記では，`SampleNxAddByGpu.add_s32/2`関数を定義しています．これは`@doc`で定義しているドキュメントにも書かれているように，符号付き32ビット整数で表される2つのNxテンソルの和を返します．実際にはNxテンソルだけでなく数値でもOKです．`iex>`の部分はDocTestというもので，ドキュメントのコード例と `mix test`で自動テストを実行した時のテストケースを兼ねています．関数の定義としては，`SampleNxAddByGpu.add_s32/3`を呼び出していて，GPUでこの計算をするように指定しています．

```elixir
  @doc """
  Add two tensors with signed 32bit integer.
  ## Examples

      iex> SampleNxAddByGpu.add_s32(0, 1)
      #Nx.Tensor<
        s32[1]
        [1]
      >

      iex> SampleNxAddByGpu.add_s32(Nx.tensor([0, 1, 2, 3]), Nx.tensor([3, 2, 1, 0]))
      #Nx.Tensor<
        s32[4]
        [3, 3, 3, 3]
      >

  """
  def add_s32(x, y), do: add_s32(x, y, :gpu)
```

下記では，`SampleNxAddByGpu.add_s32/3`関数を定義しています．これは前述の`SampleNxAddByGpu.add_s32/2`関数と同様に，符号付き32ビット整数で表される2つのNxテンソルの和を求めるのですが，第3引数で`:cpu`とするとCPUで実行し，`:gpu`とするとGPUで実行します．関数定義としては，`SampleNxAddByGpu.add/4`関数を呼び出しています．

```elixir
  @doc """
  Add two tensors with signed 32bit integer with specified processor.
  ## Examples

      iex> SampleNxAddByGpu.add_s32(2, 3, :gpu)
      #Nx.Tensor<
        s32[1]
        [5]
      >

      iex> SampleNxAddByGpu.add_s32(4, 5, :cpu)
      #Nx.Tensor<
        s32[1]
        [9]
      >
  """
  def add_s32(x, y, processor), do: add(x, y, {:s, 32}, processor)
```

下記では`SampleNxAddByGpu.add/4`関数を定義しています．仮に`@doc false`としています．ここで行っているのは，第1引数と第2引数のどちらかが数値であった場合に，Nxテンソルに変換しておいて再度呼び出し，第1引数と第2引数の両方ともNxテンソルになったら，`SampleNxAddByGpu.add_sub/4`関数に引き継ぎます．第3引数`type`には，`Nx.type/1`関数 https://hexdocs.pm/nx/Nx.html#type/1 で得られる型情報 https://hexdocs.pm/nx/Nx.Type.html を入れます．これにより，任意の型に拡張することができます．

```elixir
  @doc false
  def add(x, y, type, processor) when is_struct(x, Nx.Tensor) and is_struct(y, Nx.Tensor) do
    add_sub(Nx.as_type(x, type), Nx.as_type(y, type), type, processor)
  end

  @doc false
  def add(x, y, type, processor) when is_number(x) do
    add(Nx.tensor([x]), y, type, processor)
  end

  @doc false
  def add(x, y, type, processor) when is_number(y) do
    add(x, Nx.tensor([y]), type, processor)
  end
```

下記では`SampleNxAddByGpu.add_sub/4`関数を定義しています．第1引数と第2引数それぞれの`Nx.shape/1`関数 https://hexdocs.pm/nx/Nx.html#shape/1 の結果が等しい場合のみ，`SampleNxAddByGpu.add_sub_sub/6`関数を呼び出します．そうでなかった場合は，`RuntimeError`(実行時エラー)例外を発生させます．

* `SampleNxAddByGpu.add_sub_sub/6`関数を呼び出すにあたって与える引数は次のとおりです．
    * 第1引数にはテンソルのサイズを`Nx.size/1`関数 https://hexdocs.pm/nx/Nx.html#size/1 で与えます．この状況では，`Nx.size(x)`と`Nx.size(y)`は同じ値が返ってくるはずです．
    * 第2引数にはテンソルの形を`Nx.shape/1`関数で与えます．
    * 第3引数と第4引数には，テンソルの実体となるバイナリを`Nx.to_binary/2`関数 https://hexdocs.pm/nx/Nx.html#to_binary/2 で，それぞれ与えます．
    * 第5引数には`type`を与えます．これには`Nx.type/1`関数 https://hexdocs.pm/nx/Nx.html#type/1 で得られる型情報 https://hexdocs.pm/nx/Nx.Type.html を入れます
    * 第6引数には`:cpu`もしくは`:gpu`を与えます．
* `SampleNxAddByGpu.add_sub_sub/6`関数の戻り値はバイナリです．それをNxテンソルに戻すために，`Nx.from_binary/3`関数 https://hexdocs.pm/nx/Nx.html#from_binary/3 を実行します．第2引数には`type`を与えます．
* この`Nx.to_binary/2`関数と`Nx.from_binary/3`関数が，NxテンソルをNIFで扱うときの肝となります．


```elixir
  defp add_sub(x, y, type, processor) do
    if Nx.shape(x) == Nx.shape(y) do
      Nx.from_binary(add_sub_sub(Nx.size(x), Nx.shape(x), Nx.to_binary(x), Nx.to_binary(y), type, processor), type)
    else
      raise RuntimeError, "shape is not match add(#{inspect Nx.shape(x)}, #{inspect Nx.shape(y)})"
    end
  end
```

下記の関数`SampleNxAddByGpu.add_sub_sub/6`関数では，第5引数`type`でパターンマッチをしています．第5引数が符号付き32ビット整数`{:s, 32}`に一致する場合のみ，処理をします．ここに他の`type`にマッチするような関数定義を与えれば，他の型の場合に対応することができます．

この後で，`SampleNxAddByGpu.add_s32_sub/5`関数を呼び出しています．もしここでNIFから発せされる`ErlangError`の例外があった場合には，実行時例外`RuntimeError`に変換し，エラーメッセージのErlang文字列をElixir文字列に変換します．(`List.to_string/1`関数 https://hexdocs.pm/elixir/1.13/List.html#to_string/1 )


```elixir
  defp add_sub_sub(size, shape, binary1, binary2, {:s, 32}, processor) do
    try do
      add_s32_sub(size, shape, binary1, binary2, processor)
    rescue
      e in ErlangError -> raise RuntimeError, message: List.to_string(e.original)
    end
  end
```

下記の関数 `SampleNxAddByGpu.add_s32_sub/5`では，第5引数`processor`にパターンマッチして，`:gpu`の場合に`SampleNxAddByGpu.add_s32_gpu_nif/4`を，`:cpu`の場合に`SampleNxAddByGpu.add_s32_cpu_nif/4`を，それぞれ呼ぶようにしています．

```elixir
  defp add_s32_sub(size, shape, binary1, binary2, :gpu) do
    add_s32_gpu_nif(size, shape, binary1, binary2)
  end

  defp add_s32_sub(size, shape, binary1, binary2, :cpu) do
    add_s32_cpu_nif(size, shape, binary1, binary2)
  end
```

下記では，`SampleNxAddByGpu.add_s32_gpu_nif/4`と`SampleNxAddByGpu.add_s32_cpu_nif/4`のNIF関数を定義しています．NIFが正常にロードされなかった場合には，`:not_loaded`を引数に与えて `:erlang.nif_error/1` https://www.erlang.org/doc/man/erlang.html#nif_error-1 を呼び出し，終了します．NIFを表す書き方はいろいろありますが，型検査ツールDialyzerのことを考えると，この形式が良いということでした． `@doc false`としています．

```elixir
  @doc false
  def add_s32_gpu_nif(_size, _shape, _binary1, _binary2), do: :erlang.nif_error(:not_loaded)

  @doc false
  def add_s32_cpu_nif(_size, _shape, _binary1, _binary2), do: :erlang.nif_error(:not_loaded)
```

## `nif_src/libnif.c`

```c:nif_src/libnif.c
#include <stdbool.h>
#include <erl_nif.h>

#ifdef METAL
#include <string.h>
#include <stdio.h>
#include "metal/wrap_add.h"
#endif

#ifdef CUDA
#include <string.h>
#include "cuda/vectorAdd.h"
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

static ERL_NIF_TERM add_s32_gpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
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
#elif CUDA
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

static ERL_NIF_TERM add_s32_cpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
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

    for(ErlNifUInt64 i = 0; i < vec_size; i++) {
        out[i] = in1[i] + in2[i];
    }

    return enif_make_binary(env, &out_data);
}

static ErlNifFunc nif_funcs [] =
{
    {"init_metal_nif", 1, init_metal_nif},
    {"add_s32_gpu_nif", 4, add_s32_gpu_nif},
    {"add_s32_cpu_nif", 4, add_s32_cpu_nif}
};

ERL_NIF_INIT(Elixir.SampleNxAddByGpu, nif_funcs, NULL, NULL, NULL, NULL)
```

下記ではヘッダファイルを設定しています．

* `#include <stdbool.h>`は`true`, `false`を使えるようにします．
* `#include <erl_nif.h>`は Erlang の NIF のAPIを使えるようにします． 公式ドキュメントはこちら https://www.erlang.org/doc/man/erl_nif.html
* `METAL`が定義されている時には，エラーメッセージ変換のために，`string.h`と`stdio.h`を読み込みます．さらに，ラッパー関数を定義している`nif_src/metal/wrap_add.h`を読み込みます．
* `CUDA`が定義されている時には，エラーメッセージ変換のために`string.h`を読み込みます．さらに，`nif_src/cuda/vectorAdd.h`を読み込みます．


```c
#include <stdbool.h>
#include <erl_nif.h>

#ifdef METAL
#include <string.h>
#include <stdio.h>
#include "metal/wrap_add.h"
#endif

#ifdef CUDA
#include <string.h>
#include "cuda/vectorAdd.h"
#endif
```

下記でNIF関数`init_metal_nif`を定義します．最後の`nif_funcs`と`ERL_NIF_INIT`の定義により，Elixirの`SampleNxAddByGpu.init_metal_nif/1`関数と対応づけられます．第1引数は実行時環境`env`，第2引数は`init_metal_nif`関数に渡される引数の数(1)，第3引数は引数の実体を保持する`ERL_NIF_TERM`型の配列(長さが第2引数で与えられて，1)です．`erl_nif.h`で定義される関数を使って，`ERL_NIF_TERM`型の変数と実行時環境`env`から値を取得します．戻り値は`ERL_NIF_TERM`型です．この戻り値も，実行時環境`env`などを使って`erl_nif.h`で定義される関数を使って生成します．

```c
static ERL_NIF_TERM init_metal_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
}
```

下記では，`init_metal_nif`関数に与えられる引数の数が`1`でなかった場合，`badarg`例外を発生させて終了します．`badarg`例外は，引数に問題がある場合に使用するErlangの例外です． https://www.erlang.org/doc/man/erl_nif.html#enif_make_badarg

`__builtin_expect`は，第1引数の結果が第2引数になる場合がほとんどであるという分岐予測をするようなヒントを与えます．ここでは，この`if`文の条件がほとんどの場合偽になり，`return enif_make_badarg(env);`を実行しないという前提で分岐予測をするようなヒントを与えます．

```c
static ERL_NIF_TERM init_metal_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 1, false)) {
        return enif_make_badarg(env);
    }
    ...
}
```

下記では`METAL`である場合とそうでない場合に分けます．`METAL`でない場合は，Elixirの`:ok`を返すようにします．
https://www.erlang.org/doc/man/erl_nif.html#enif_make_atom


```c
static ERL_NIF_TERM init_metal_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
#ifdef METAL
    ...
#else
    return enif_make_atom(env, "ok");
#endif
}
```

`METAL`である場合に，以下の変数の初期設定をします．

* `ret`: `init_metal`関数の戻り値を格納します．
* `metal_error`: エラーメッセージの接頭辞として`"Metal Error: "`を加えます．
* `error`: `init_metal`関数から戻ってくるエラーメッセージを格納します．`memset`関数で`0`に初期化します．


```c
static ERL_NIF_TERM init_metal_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
#ifdef METAL
    bool ret = true;
    const char *metal_error = "Metal Error: ";
    char error[MAXBUFLEN];
    memset(error, 0, MAXBUFLEN);
    ...
#endif
}
```

下記は第1引数`argv[0]`に与えられたErlang文字列を受け取り，`char *metal_src`に格納します．

* Erlang文字列はリストでもあるので，最初に`enif_get_list_length`関数を使って`unsigned len`にリストの長さを格納します．https://www.erlang.org/doc/man/erl_nif.html#enif_get_list_length
    * `enif_get_list_length`の戻り値が`false`の場合はエラーです．エラーが返った場合は，`enif_make_badarg`関数で，`badarg`例外を発生させて終了します．https://www.erlang.org/doc/man/erl_nif.html#enif_make_badarg
* `char *metal_src`に `enif_alloc`関数でメモリを確保します． https://www.erlang.org/doc/man/erl_nif.html#enif_alloc
    * メモリが確保できなかった時には `enif_alloc`関数は`NULL`を返します．その場合は，`enif_make_badarg`関数で，`badarg`例外を発生させて終了します． https://www.erlang.org/doc/man/erl_nif.html#enif_make_badarg
* `enif_get_string`関数で，メモリ確保済みの`metal_src`に第1引数`argv[0]`のErlang文字列を格納します．
    * `enif_get_string`がエラーの場合は，`false`を返します．その場合は，`enif_make_badarg`関数で，`badarg`例外を発生させて終了します． 


```c
static ERL_NIF_TERM init_metal_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
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
    ...
}
```

`init_metal`関数を呼び出し，結果によって，Elixirに返す戻り値を準備します．

* `init_metal`関数は，`nif_src/metal/wrap_add.m`のObjective-Cコードに定義されています．`metal_src`を入力として，Metalのソースコードを設定して `true`を返します．途中でエラーが返ってきた場合には，`error`にエラーメッセージを設定して`false`を返します．
* `metal_src`はもう不要になるので，`enif_free`で解放します． https://www.erlang.org/doc/man/erl_nif.html#enif_free
* `true`が返ってきた場合には，`:ok`を返します． https://www.erlang.org/doc/man/erl_nif.html#enif_make_atom
* `false`が返ってきた場合には，`{:error, ~c'Metal Error: #{error}'}`を返します．
    * `ret_error`に，`MAXBUFLEN`と`"Metal Error: "`の文字数を加えたサイズ確保して，`memset`関数で`0`に初期化します．
    * `metal_error`と`error`をつなげた文字列を`snprintf`関数で生成して`ret_error`に格納します．
    * `enif_make_atom`関数で`:error`を生成します．https://www.erlang.org/doc/man/erl_nif.html#enif_make_atom
    * `enif_make_string`関数で`ret_error`のErlang文字列を生成します． https://www.erlang.org/doc/man/erl_nif.html#enif_make_string
    * `enif_make_tuple2`関数で，タプルを返します． https://www.erlang.org/doc/man/erl_nif.html#enif_make_tuple2

```c
static ERL_NIF_TERM init_metal_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
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
    ...
}
```

下記でNIF関数`add_s32_gpu_nif`を定義します．最後の`nif_funcs`と`ERL_NIF_INIT`の定義により，Elixirの`SampleNxAddByGpu.add_s32_gpu_nif/4`関数と対応づけられます．第1引数は実行時環境`env`，第2引数は`init_metal_nif`関数に渡される引数の数(1)，第3引数は引数の実体を保持する`ERL_NIF_TERM`型の配列(長さが第2引数で与えられて，1)です．`erl_nif.h`で定義される関数を使って，`ERL_NIF_TERM`型の変数と実行時環境`env`から値を取得します．戻り値は`ERL_NIF_TERM`型です．この戻り値も，実行時環境`env`などを使って`erl_nif.h`で定義される関数を使って生成します．

```c
static ERL_NIF_TERM add_s32_gpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
}
```

下記では，`add_s32_gpu_nif`関数に与えられる引数の数が`4`でなかった場合，`badarg`例外を発生させて終了します．`badarg`例外は，引数に問題がある場合に使用するErlangの例外です． https://www.erlang.org/doc/man/erl_nif.html#enif_make_badarg

`__builtin_expect`は，第1引数の結果が第2引数になる場合がほとんどであるという分岐予測をするようなヒントを与えます．ここでは，この`if`文の条件がほとんどの場合偽になり，`return enif_make_badarg(env);`を実行しないという前提で分岐予測をするようなヒントを与えます．

```c
static ERL_NIF_TERM add_s32_gpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    if(__builtin_expect(argc != 4, false)) {
        return enif_make_badarg(env);
    }
    ...
}
```

第1引数の符号無し64ビット整数を`enif_get_uint64`関数で受け取って`vec_size`に格納します． https://www.erlang.org/doc/man/erl_nif.html#enif_get_uint64
第1引数を符号無し64ビット整数で受け取れなかった場合に，`badarg`例外を発生させて終了します．`badarg`例外は，引数に問題がある場合に使用するErlangの例外です． https://www.erlang.org/doc/man/erl_nif.html#enif_make_badarg

```c
static ERL_NIF_TERM add_s32_gpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
    ErlNifUInt64 vec_size;
    if(__builtin_expect(!enif_get_uint64(env, argv[0], &vec_size), false)) {
        return enif_make_badarg(env);
    }
    ...
}
```

第2引数は無視します．


* 第3引数を`enif_inspect_binary`関数でバイナリとして受け取って，`in_data_1`に格納します． https://www.erlang.org/doc/man/erl_nif.html#enif_inspect_binary
    * 第3引数をバイナリで受け取れなかった場合に，`badarg`例外を発生させて終了します．`badarg`例外は，引数に問題がある場合に使用するErlangの例外です． https://www.erlang.org/doc/man/erl_nif.html#enif_make_badarg
* このバイナリを32ビット整数であるとして，`in1`に格納します．
* 同様に第4引数を処理して，32ビット整数であるとして`in2`に格納します．


```c
static ERL_NIF_TERM add_s32_gpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
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
    ...
}
```

出力結果を格納するバイナリ`out_data`と32ビット整数配列`out`を`enif_alloc_binary`関数で確保します． https://www.erlang.org/doc/man/erl_nif.html#enif_alloc_binary

* 確保するサイズは，`vec_size`と`sizeof(int32_t)`の積です．
* 戻り値が`false`の場合はエラーです．その場合は，`badarg`例外を発生させて終了します．`badarg`例外は，引数に問題がある場合に使用するErlangの例外です．https://www.erlang.org/doc/man/erl_nif.html#enif_make_badarg
* このバイナリを32ビット整数であるとして，`out`に格納します．


```c
static ERL_NIF_TERM add_s32_gpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
    ErlNifBinary out_data;
    if(__builtin_expect(!enif_alloc_binary(vec_size * sizeof(int32_t), &out_data), false)) {
        return enif_make_badarg(env);
    }
    int32_t *out = (int32_t *)out_data.data;
    ...
}
```

`METAL`の場合に，`add_s32_metal`関数を呼び出します．

* `metal_error`: エラーメッセージの接頭辞として`"Metal Error: "`を加えます．
* `error`: `init_metal`関数から戻ってくるエラーメッセージを格納します．`memset`関数で`0`に初期化します．
* `add_s32_metal`関数は`nif_src/metal/wrap_add.m`に定義されています．
    * 第1引数に`in1`，第2引数に`in2`を与えて，結果が第3引数`out`に返ってきます．これらを第4引数`vec_size`の数の配列だとみなします．
    * 正常終了すると`true`が返ります．エラーの場合は第5引数`error`にエラーメッセージを格納して`false`が返ります．
* エラーだった場合に，`~c'Metal Error: #{error}'`をメッセージとしてもつ例外を発生させます．
    * `MAXBUFLEN`と`metal_error`の文字数の和を`len`に格納し，`len`の文字数分の`ret_error`を確保し，`0`に初期化します．
    * `metal_error`と`error`を`snprintf`関数で結合して`ret_error`に出力します．
    * `enif_make_string`関数で文字列を生成します． https://www.erlang.org/doc/man/erl_nif.html#enif_make_string
    * `enif_raise_exception`関数で例外を発生させます． https://www.erlang.org/doc/man/erl_nif.html#enif_raise_exception

```c
static ERL_NIF_TERM add_s32_gpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
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
   ...
#endif
   ...
}
```


`CUDA`の場合に，`add_s32_cuda`関数を呼び出します．だいたい前項と同じです．差分は次のとおりです．

* `cuda_error`: エラーメッセージの接頭辞として`"CUDA Error: "`を加えます．
* `add_s32_cuda`関数は`nif_src/cuda/vectorAdd.cu`に定義されています．
* エラーだった場合に，`~c'CUDA Error: #{error}'`をメッセージとしてもつ例外を発生させます．
    * `MAXBUFLEN`と`cuda_error`の文字数の和を`len`に格納し，`len`の文字数分の`ret_error`を確保し，`0`に初期化します．
    * `cuda_error`と`error`を`snprintf`関数で結合して`ret_error`に出力します．

```c
static ERL_NIF_TERM add_s32_gpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    ...
#ifdef METAL
    ...
#elif CUDA
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
   ...
#endif
   ...
}
```

どちらでもなかった場合は，CPUでの配列の加算を実行します．

```c
static ERL_NIF_TERM add_s32_gpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
#ifdef METAL
    ...
#elif CUDA
    ...
#else
    for(ErlNifUInt64 i = 0; i < vec_size; i++) {
        out[i] = in1[i] + in2[i];
    }
#endif
   ...
}
```

正常終了の場合は，バイナリ`out_data`を返します．

```c
static ERL_NIF_TERM add_s32_gpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
   ...
    return enif_make_binary(env, &out_data);
}
```

`add_s32_cpu_nif`関数は`add_s32_gpu_nif`関数とほぼ同様で，違いは`METAL`でも`CUDA`でもCPUで配列の加算を実行する点です．説明は省略します．

```c
static ERL_NIF_TERM add_s32_cpu_nif(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
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

    for(ErlNifUInt64 i = 0; i < vec_size; i++) {
        out[i] = in1[i] + in2[i];
    }

    return enif_make_binary(env, &out_data);
}
```

`nif_funcs`を定義します．`nif_funcs`はNIF関数の対応表で，名称と引数の数を関数に紐付けます．

```c
static ErlNifFunc nif_funcs [] =
{
    {"init_metal_nif", 1, init_metal_nif},
    {"add_s32_gpu_nif", 4, add_s32_gpu_nif},
    {"add_s32_cpu_nif", 4, add_s32_cpu_nif}
};
```

`ERL_NIF_INIT`を使ってNIF関数を定義します．`SampleNxAddByGpu`モジュールと紐づけます．初期化関数群はひとまず与えていません．

```c
ERL_NIF_INIT(Elixir.SampleNxAddByGpu, nif_funcs, NULL, NULL, NULL, NULL)
```

## Metal

ここではMetal対応のために次のファイルを用意しています．

* `nif_src/metal/wrap_add.h`
* `nif_src/metal/wrap_add.m`
* `nif_src/metal/MetalAdder.h`
* `nif_src/metal/MetalAdder.m`
* `nif_src/metal/add.metal`

Apple Developer Documentationの[Performing Calculations on a GPU: Use Metal to find GPUs and perform calculations on them.](https://developer.apple.com/documentation/metal/performing_calculations_on_a_gpu)を参考に作成しました．

### `nif_src/metal/wrap_add.h`

NIFと`MetalAdder`クラスをつなぐラッパー関数のプロトタイプを宣言します．

* `init_metal`: Metalのソースコードを設定する関数です．
* `add_s32_metal`: Metalを使って符号なし32ビット整数の加算を行います．


```nif_src/metal/wrap_add.h
#ifndef WRAP_ADD_H
#define WRAP_ADD_H

#include <stdbool.h>
#include <stdint.h>

#define MAXBUFLEN 1024

bool init_metal(const char *metal_src, char *error);

bool add_s32_metal(const int32_t *in1, const int32_t *in2, int32_t *out, uint64_t vec_size, char *error);

#endif // WRAP_ADD_H
```


### `nif_src/metal/wrap_add.m`

NIFと`MetalAdder`クラスをつなぐラッパー関数を定義します．

* `init_metal`: Metalのソースコードを設定する関数です．
* `add_s32_metal`: Metalを使って符号なし32ビット整数の加算を行います．

```objc:nif_src/metal/wrap_add.m
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

`init_metal`関数は，Metalのソースコードを設定します．

* `id<MTLDevice> device`に`MTLCreateSystemDefaultDevice`関数を使ってMetalのデフォルトデバイスを取得します．https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice
    * もしMetalをサポートしていないなどの事情で，`device`が取得できない場合は`nil`が返ってきます．その場合に，`error_message`にエラーメッセージを書き込んで`false`を返して`init_metal`関数を終了します．
* `NSError* error`にはエラーが入ります．初期値として`nil`を与えます．
* `NSString`の`stringWithCString:encoding:`メソッドで，Cの文字列である`metal_src`からObjective-Cの`NSString`に変換し，`NSString *src`に格納します．
https://developer.apple.com/documentation/foundation/nsstring/1497310-stringwithcstring
* `MTLCompileOptions* options`を初期化し，Metalの言語バージョンを2.4に設定します．(macOS Montereyではこのバージョンでした)
* `device`に`newLibraryWithSource:options:error:`メッセージを送って，`src`で与えられるMetalのプログラムコードを`options`で指定したコンパイルオプションでコンパイルして`addLibrary`に格納します．`addLibrary`は`nif_src/metal/MetalAdder.h`に定義されているグローバル変数です．エラーは`error`に格納されます． https://developer.apple.com/documentation/metal/mtldevice/1433431-newlibrarywithsource?changes=_5
    * `addLibrary`が`nil`もしくは`error`が`nil`でない場合にはエラーとなります．エラーメッセージ`error_message`を設定して，`false`を返して`init_metal`関数を終了します．
* 全て成功したら，`true`を返して`init_metal`関数を終了します．


```objc
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
```

`add_s32_metal`関数では，Metalを使って符号なし32ビット整数の加算を行います．

* `id<MTLDevice> device`に`MTLCreateSystemDefaultDevice`関数を使ってMetalのデフォルトデバイスを取得します．https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice
    * もしMetalをサポートしていないなどの事情で，`device`が取得できない場合は`nil`が返ってきます．その場合に，`error_message`にエラーメッセージを書き込んで`false`を返して`add_s32_metal`関数を終了します．
* `NSError* error`にはエラーが入ります．初期値として`nil`を与えます．
* `MetalAdder`クラスのオブジェクト`adder`を確保して`initWithDevice:error:`メソッドで初期化します．`adder`が`nil`だった時にはエラーの場合で，`false`を返して`add_s32_metal`関数を終了します．エラー時には`error_message`は設定済みです．
* `adder`に`prepareData:inB:size:error:`メッセージを送り，入力データを設定します．`false`が返ってきた時にはそのまま`false`を返して`add_s32_metal`関数を終了します．エラー時には`error_message`は設定済みです．
* `adder`に`sendComputeCommand:error:`メッセージを送り，計算をします．結果を`int32_t *result`に格納します．
    * `result`が`nil`の時にはエラーの場合で，`false`を返して`add_s32_metal`関数を終了します．エラー時には`error_message`は設定済みです．
    * 正常終了時には`result`を`memcpy`関数で`out`に書き込みます．その後，`true`を返して`add_s32_metal`関数を終了します．
 
```objc
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




### `nif_src/metal/MetalAdder.h`

クラス`MetalAdder`のインタフェースを決めます．また，グローバル変数`addLibrary`もここに置いています．次のメソッドを持ちます．

* `initWithDevice:error:`: `MetalAdder`クラスをデバイスを与えて初期化します．
* `prepareData:inB:size:error:`: 入力データを準備します．
* `sendComputeCommand:error:` GPUで計算を実行します．

```objc:nif_src/metal/MetalAdder.h
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


### `nif_src/metal/MetalAdder.m`

```objc:nif_src/metal/MetalAdder.m
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

メンバ変数を定義します．

* `id<MTLDevice> _mDevice`: デバイス https://developer.apple.com/documentation/metal/mtldevice
* `id<MTLComputePipelineState> _mAddFunctionPSO`: 関数ポインタのようなもので，`nif_src/metal/add.metal`で記述されたベクタ加算の関数`add_arrays`の実体が入ります． https://developer.apple.com/documentation/metal/mtlcomputepipelinestate
* `id<MTLCommandQueue> _mCommandQueue`: GPUで実行するコマンドを格納します．キューと呼ぶからには，複数の関数を順番に呼べるようになっているのでしょうか．https://developer.apple.com/documentation/metal/mtlcommandqueue
* `id<MTLBuffer>`: GPUで使用するメモリ領域です． https://developer.apple.com/documentation/metal/mtlbuffer
    * `_mBufferA`: 1つ目の入力データを格納します．
    * `_mBufferB`: 2つ目の入力データを格納します．
    * `_mBufferResult`: 結果を格納します．

```objc
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
```

`initWithDevice:error:`メソッドはデバイスを引数に与えて`MetalAdder`クラスを初期化します．
* `_mDevice`に`device`を設定します．
* `NSError* error`を`nil`で初期化します．
* `addLibrary`が`nil`の場合，`error_message`にエラーメッセージを記録して`nil`を返し，`initWithDevice:error:`メソッドを終了します．
* `addLibrary`に`newFunctionWithName:`メッセージを送り，`add_arrays`という関数を取得し，`id<MTLFUnction> addFunction`に格納します． https://developer.apple.com/documentation/metal/mtllibrary/1515524-newfunctionwithname
    * `addFunction`が`nil`だった時には，`error_message`にエラーメッセージを記録して`nil`を返し，`initWithDevice:error:`メソッドを終了します．
* `_mDevice`に`newComputePipelineStateWithFunction:error:`メッセージを送って，`_mAddFunctionPSO`に格納します．https://developer.apple.com/documentation/metal/mtldevice/1433395-newcomputepipelinestatewithfunct
    * `_mAddFunctionPSO`が`nil`または`error`が`nil`でない場合はエラーです．エラー時には，`error_message`にエラーメッセージを記録して`nil`を返し，`initWithDevice:error:`メソッドを終了します．
* `_mDevice`に`newCommandQueue`メソッドを送って，`_mCommandQueue`に格納します．
    * `_mCommandQueue`が`nil`の時にはエラーです．エラー時には，`error_message`にエラーメッセージを記録して`nil`を返し，`initWithDevice:error:`メソッドを終了します．
* 全て正常に終了した場合は，`self`を返し，`initWithDevice:error:`メソッドを終了します．


```objc
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
```


`prepareData:inB:size:error:`メソッドは，入力データを準備します．

* `size_t bufferSize`に`vec_size`と`sizeof(int32_t)`の積を格納します．
* `_mDevice`に`newBufferWithLength:options:`メッセージを送ってバッファを確保します．https://developer.apple.com/documentation/metal/mtldevice/1433375-newbufferwithlength
    * `options:`に`MTLResourceStorageModeShared`を指定することで，CPUとGPUの共有メモリを確保します． https://developer.apple.com/documentation/metal/mtlresourceoptions/mtlresourcestoragemodeshared
    * _mBufferA, _mBufferB, _mBufferResult にそれぞれ確保します．
    * _mBufferA, _mBufferB, _mBufferResult のいずれかが`nil`だった場合にはエラーです．`error_message`にエラーメッセージを記録して`false`を返し，`prepareData:inB:size:error:`メソッドを終了します．
* `self`に`generateData:in:size:error`メソッドを送り，入力データを初期化します．両方とも`true`にならなかった場合には，`false`を返し，`prepareData:inB:size:error:`メソッドを終了します．
* 全て正常に完了した場合，`true`を返し，`prepareData:inB:size:error:`メソッドを終了します．

```objc
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
```

`sendComputeCommand:error:`メソッドによって，GPUで計算を実行します．

* `_mCommandQueue`に`commandBuffer`メッセージを送ってコマンドバッファを取得し，`id<MTLCommandBuffer> commandBuffer`に格納します．https://developer.apple.com/documentation/metal/mtlcommandqueue/1508686-commandbuffer
    * `commandBuffer`が`nil`の場合はエラーです．`error_message`にエラーメッセージを記録して`nil`を返し，`sendComputeCommand:error:`メソッドを終了します．
* `commandBuffer`に`computeCommandEncoder`メッセージを送り，結果を`id<MTLComputeCommandEncoder> computeEncoder`に格納します．https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443044-computecommandencoder
    * `computeEncoder`が`nil`の場合はエラーです．`error_message`にエラーメッセージを記録して`nil`を返し，`sendComputeCommand:error:`メソッドを終了します．
* `self`に`encodeAddCommand:size:error:`メッセージを送ります．
    * 結果が`false`だった場合はエラーです．`nil`を返し，`sendComputeCommand:error:`メソッドを終了します．エラー時には`error_message`にエラーメッセージが格納済みです．
* `commandEncoder`に`endEncoding`メッセージを送ります．
https://developer.apple.com/documentation/metal/mtlcommandencoder/1458038-endencoding
* `commandBuffer`に`commit`メッセージを送って，計算を実行します．https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443003-commit
* `commandBuffer`に`waitUntilCompleted`メッセージを送って，同期します．https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443039-waituntilcompleted
    * おそらく，`commit`と`waitUntilCompleted`の間に別の処理をすることが可能だと思われます．この間でNIFを分割すると，ノン・ブロッキングなAPIになるんじゃないかと思います．
* `_mBufferResult`と`_mBufferResult.contents`のどちらかが`nil`だった場合には，エラーです．`error_message`にエラーメッセージを記録して`nil`を返し，`sendComputeCommand:error:`メソッドを終了します．
* 全て正常終了した場合，`_mBufferResult.contents`を返し，`sendComputeCommand:error:`メソッドを終了します．


```objc
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
```

`encodeAddCommand:size:error`メソッドは，`computeEncoder`にベクタ加算の関数と入力データ・出力データを設定し，GPUで計算するための準備をします．

* `_mAddFunctionPSO`, `_mBufferA`, `_mBufferB`, `_mBufferResult`のいずれかが`nil`だった場合は，エラーです．`error_message`にエラーメッセージを格納して，`false`を返し，`encodeAddCommand:size:error`メソッドを終了します．
* `computeEncoder`に`setComputePipelineState:`メッセージを送ります．https://developer.apple.com/documentation/metal/mtlcomputecommandencoder/1443140-setcomputepipelinestate
* `computerEncoder`に`setBuffer:offset:atIndex:`メッセージを送り，入出力を設定します．https://developer.apple.com/documentation/metal/mtlcomputecommandencoder/1443126-setbuffer
* `MTLSizeMake`関数のの結果を`MTLSize gridSize`に格納します． https://developer.apple.com/documentation/metal/1515357-mtlsizemake
* `NSUInteger threadGroupSize`の値を，`_mAddFunctionPSO.maxTotalThreadsPerThreadgroup`と`vec_size`のうち，より小さな値とします． https://developer.apple.com/documentation/metal/mtlcomputepipelinestate/1414927-maxtotalthreadsperthreadgroup
* `MTLSize threadgroupSize`に`MTLSizeMake`関数の結果を格納します．https://developer.apple.com/documentation/metal/1515357-mtlsizemake
* `computeEncoder`に`dispatchThreads:threadsPerThreadgroup:`メッセージを送ります．https://developer.apple.com/documentation/metal/mtlcomputecommandencoder/2866532-dispatchthreads
* `true`を返して，`encodeAddCommand:size:error`メソッドを終了します．


```objc
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
```

`generateData:in:size:error:`メソッドはバッファ`buffer`に入力データ`in`を格納します．

* `buffer`, `buffer.contents`, `in`のいずれかが`nil`だった場合には，エラーです．`error_message`にエラーメッセージを格納して，`false`を返し，`generateData:in:size:error:`メソッドを終了します．
* `buffer.contents`に`in`をコピーして，`true`を返し，`generateData:in:size:error:`メソッドを終了します．


```objc
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
```


### `nif_src/metal/add.metal`

GPUで実行するMetalコードを記述します．ここでは，加算する`add_arrays`関数を定義します．

```:nif_src/metal/add.metal
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


## CUDA

ここではCUDA対応のために次のファイルを用意しています．

* `nif_src/cuda/vectorAdd.h`
* `nif_src/cuda/vectorAdd.cu`

### `nif_src/cuda/vectorAdd.h`

`nif_src/cuda/vectorAdd.h`では，`nif_src/cuda/vectorAdd.cu`で定義している関数`add_s32_cuda`のプロトタイプ宣言をしています．`extern "C"`をつけている点に注意してください．CUDAではC++で記述し，NIFはCで記述するので，互いを行き来する関数に`extern "C"`をつけないとリンク時に失敗してしまいます．

```c++:nif_src/cuda/vectorAdd.h
#ifndef VECTOR_ADD_H
#define VECTOR_ADD_H

#include <stdbool.h>
#include <stdint.h>

#define MAXBUFLEN 1024

#ifdef __cplusplus
extern "C" {
#endif
bool add_s32_cuda(const int32_t *x, const int32_t *y, int32_t *z, uint64_t numElements, char *error);
#ifdef __cplusplus
}
#endif

#endif // VECTOR_ADD_H
```

### `nif_src/cuda/vectorAdd.cu`

下記を参考に作成しました．`0_Introduction` の `vectorAdd`です．

https://github.com/NVIDIA/cuda-samples

```cuda:nif_src/cuda/vectorAdd.cu
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

下記がベクタ加算の本体です．オリジナルから32ビット整数演算に変更しています．

```cuda
__global__ void vectorAdd(const int32_t *A, const int32_t *B, int32_t *C, uint64_t numElements)
{
    int i = blockDim.x * blockIdx.x + threadIdx.x;

    if (i < numElements) {
        C[i] = A[i] + B[i];
    }
}
```

`add_s32_cuda`関数を定義しています．第1引数と第2引数のベクタ配列を加算して第3引数に書き込みます．配列のサイズは第4引数で与えます．正常終了した場合には`true`を返します．エラーの場合には，エラーメッセージを第5引数に書き込んで，`false`を返します．`extern "C"`とすることで，NIFから呼び出せるようにしています．

```cuda
#ifdef __cplusplus
extern "C" {
#endif
bool add_s32_cuda(const int32_t *h_A, const int32_t *h_B, int32_t *h_C, uint64_t numElements, char *error_message)
{
    ...
}
#ifdef __cplusplus
}
#endif
```

次の変数を定義し，初期化します．

* `cudaError_t err`: CUDAのエラーコードを格納します．初期値として`cudaSuccess`(成功)を入れておきます．
* `uint64_t size`: 配列のサイズとして，`numElement`と`sizeof(int32_t)`の積を格納します．

その後，`h_A`, `h_B`, `h_C`がいずれも`NULL`でないことを確認します．`NULL`だった場合には，`snprintf`関数を用いて`error_message`にエラーメッセージを格納します．

```cuda
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
    ...
}
```

* `h_A`, `h_B`, `h_C`それぞれに対応するGPU側のメモリ領域`d_A`, `d_B`, `d_C`を`cudaMalloc`関数で確保します．
    * https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__MEMORY.html#group__CUDART__MEMORY_1g37d37965bfb4803b6d4e59ff26856356
    * エラーの場合は`err`に`cudaSuccess`以外の値が入ります．
        * エラーコードを`cudaGetErrorString`関数で得ることができます． https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__ERROR.html#group__CUDART__ERROR_1g4bc9e35a618dfd0877c29c8ee45148f1
        * それをもとに`snprintf`関数で`error_message`にエラーメッセージを出力します．
        * その後，`false`を返して`add_s32_cuda`関数を終了します．

```cuda
bool add_s32_cuda(const int32_t *h_A, const int32_t *h_B, int32_t *h_C, uint64_t numElements, char *error_message)
{
    ...
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
    ...
}
```

CPU側にある入力データ`h_A`と`h_B`の値をそれぞれGPU側のメモリ領域`d_A`と`d_B`に転送します．

* `cudaMemcpy`関数を用います． https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__MEMORY.html#group__CUDART__MEMORY_1gc263dbe6574220cc776b45438fc351e8
* エラーの時のコードは，前項と同様ですので，説明を省略します．

```cuda
bool add_s32_cuda(const int32_t *h_A, const int32_t *h_B, int32_t *h_C, uint64_t numElements, char *error_message)
{
    ...
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
    ...
}
```

`vectorAdd`関数をGPUで実行します．

* ブロックあたりのスレッド数 `threadsPerBlock`を`256`とします．この数値の根拠をCUDAのドキュメントから探したのですが，見つかりませんでした．(下記の記述くらい)

> A thread block size of 16x16 (256 threads), although arbitrary in this case, is a common choice. The grid is created with enough blocks to have one thread per matrix element as before. For simplicity, this example assumes that the number of threads per grid in each dimension is evenly divisible by the number of threads per block in that dimension, although that need not be the case.

> この場合は任意ですが、16x16 (256 スレッド) のスレッド ブロック サイズが一般的な選択です。 グリッドは、以前と同様に行列要素ごとに 1 つのスレッドを持つのに十分なブロックで作成されます。 簡単にするために、この例では、各次元のグリッドあたりのスレッド数が、その次元のブロックあたりのスレッド数で割り切れると仮定していますが、そうである必要はありません。


* グリッドあたりのブロック `blocksPerGrid`を`(numElements + threadsPerBlock - 1) / threadsPerBlock`とします．単に`numElements / threadsPerBlock`としないのは，割り切れるかどうかにかかわらず，結果を整合させるためです．

* `vectorAdd<<<blocksPerGrid, threadsPerBlock>>>(d_A, d_B, d_C, numElements);`として，GPUの処理関数`vectorAdd`を呼び出します．
* エラーを`cudaGetLastError`関数で拾います． https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__ERROR.html#group__CUDART__ERROR_1g3529f94cb530a83a76613616782bd233
* エラーに関する処理は，前項までと同じなので，説明を省略します．

Metalのコードと違って同期的な呼び出し方ですね．おそらくCUDAにも非同期的，つなりノン・ブロッキングな呼び出し方があるんじゃないかと思いますので，調べてみたいと思います．

```cuda
bool add_s32_cuda(const int32_t *h_A, const int32_t *h_B, int32_t *h_C, uint64_t numElements, char *error_message)
{
    ...
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
    ...
}
```

`cudaMemcpy`関数を使って，計算結果が格納されているGPU側のメモリ領域`d_C`からCPU側のメモリ領域`h_C`に転送します． https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__MEMORY.html#group__CUDART__MEMORY_1gc263dbe6574220cc776b45438fc351e8

エラーに関する処理は前項までと同様なので，説明を省略します． 


```cuda
bool add_s32_cuda(const int32_t *h_A, const int32_t *h_B, int32_t *h_C, uint64_t numElements, char *error_message)
{
    ...
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
    ...
}
```

`cudaFree`関数を使って`d_A`, `d_B`, `d_C`に確保したメモリを解放します． https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__MEMORY.html#group__CUDART__MEMORY_1ga042655cbbf3408f01061652a075e094

エラーに関する処理は前項までと同様なので，説明を省略します．

全て成功した場合，`true`を返して，`add_s32_cuda`関数を終了します．

```cuda
bool add_s32_cuda(const int32_t *h_A, const int32_t *h_B, int32_t *h_C, uint64_t numElements, char *error_message)
{
    ...
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
```

