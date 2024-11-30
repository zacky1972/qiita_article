---
title: ExTaskを使ったNIFの作り方
tags:
  - C
  - Go
  - task
  - Elixir
private: false
updated_at: '2024-11-30T20:03:36+09:00'
id: 4fa132017f0e6d5e620b
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
ExTaskを使ってNIFを作るサンプルプログラムを作りました．

https://github.com/zacky1972/ex_task

TaskはGoでできたプラットフォーム非依存の新しいタスクランナーです．

https://taskfile.dev

たとえば次のようなCコードをNIFとして作りたいとします．

```elixir:lib/sample_ex_task.ex
defmodule SampleExTask do
  @moduledoc """
  Documentation for `SampleExTask`.
  """
  require Logger

  @on_load :load_nif

  @doc false
  def load_nif do
    nif_file = ~c'#{Application.app_dir(:sample_ex_task, "priv/libnif")}'

    case :erlang.load_nif(nif_file, 0) do
      :ok -> :ok
      {:error, {:reload, _}} -> :ok
      {:error, reason} -> Logger.error("Failed to load NIF: #{inspect(reason)}")
    end
  end

  @doc """
  ok.

  ## Examples

      iex> SampleExTask.ok()
      :ok

  """
  def ok(), do: :erlang.nif_error(:not_loaded)
end
```

```c:nif_src/lib_nif.c
#include <erl_nif.h>

static ERL_NIF_TERM ok(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[])
{
    return enif_make_atom(env, "ok");
}

static ErlNifFunc nif_funcs [] =
{
    {"ok", 0, ok}
};

ERL_NIF_INIT(Elixir.SampleExTask, nif_funcs, NULL, NULL, NULL, NULL)
```

ごくシンプルに`:ok`を返すだけのNIFコードです．

```elixir
      iex> SampleExTask.ok()
      :ok
```

`mix.exs`を次のようにします．

```elixir:mix.exs
defmodule SampleExTask.MixProject do
  use Mix.Project

  def project do
    [
      app: :sample_ex_task,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:ex_task] ++ Mix.compilers
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
      {:ex_task, "~> 0.1", runtime: false}
    ]
  end
end
```

ポイントは2つ．

* `project`に`compilers: [:ex_task] ++ Mix.compilers`を足す
* `deps`に`{:ex_task, "~> 0.1", runtime: false}`を足す

次のような`Taskfile.yml`を配置します．

```yaml:Taskfile.yaml
version: '3'

tasks:
  default:
    vars:
      PRIV: $MIX_APP_PATH/priv
      BUILD: $MIX_APP_PATH/obj
      NIF: "{{.PRIV}}/libnif.so"
      ERLANG_PATH:
        sh: elixir --eval ':code.root_dir |> to_string() |> IO.puts'
      ERL_EI_INCLUDE_DIR: 
        sh: echo "${ERL_EI_INCLUDE_DIR:-{{.ERLANG_PATH}}/usr/include}"
      ERL_EI_LIBDIR:
        sh: echo "${ERL_EI_LIBDIR:-{{.ERLANG_PATH}}/usr/lib}"
      CFLAGS_O:
        sh: |
          if [ -z $CROSSCOMPILE ]; then
          if [ $(uname -s) -ne 'Darwin' ]; then
          echo -fPIC
          else
          :
          fi
          else
          echo -fPIC
          fi
      LDFLAGS_O:
        sh: |
          if [ -z $CROSSCOMPILE ]; then
          if [ $(uname -s) -ne 'Darwin' ]; then
          echo -fPIC -shared
          else
          echo -undefined dynamic_lookup -dynamiclib
          fi
          else
          echo -fPIC -shared
          fi
      CFLAGS: >-
        -I{{.ERL_EI_INCLUDE_DIR}}
        $CFLAGS
        {{.CFLAGS_O}}
        -std=c11
        -O3
        -Wall
        -Wextra
        -Wno-unused-function
        -Wno-unused-parameter
        -Wno-missing-field-initializers
      LDFLAGS: >-
        -L{{.ERL_EI_LIBDIR}}
        $LDFLAGS
        {{.LDFLAGS_O}}
      NIF_SRC_DIR: nif_src
      C_SRC: $NIF_SRC_DIR/libnif.c
    preconditions:
      - sh: '[ -n {{.ERLANG_PATH}} ]'
        msg: Could not find the Elixir installation. Check to see that 'elixir'.
    cmds:
      - mkdir -p {{.PRIV}}
      - mkdir -p {{.BUILD}}
      - cc -c {{.CFLAGS}} -o {{.BUILD}}/libnif.o {{.NIF_SRC_DIR}}/libnif.c
      - cc -o {{.NIF}} {{.LDFLAGS}} {{.BUILD}}/libnif.o
    status:
      - test -f {{.NIF}}
    silent: true
```

条件分岐などで，シェルの力を適宜借りないといけないのが，少し難点ですね．

