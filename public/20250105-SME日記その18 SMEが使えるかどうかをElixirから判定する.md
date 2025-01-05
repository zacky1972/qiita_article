---
title: SME日記その18 SMEが使えるかどうかをElixirから判定する
tags:
  - clang
  - Elixir
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2025-01-05T15:39:27+09:00'
id: ab2ebbb0a23d5709efe0
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
Elixirにおける，SMEが使えるかどうかの判定ロジックを考えてみました．

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
- [SME日記その15 AppleBLASのSGEMMでSMEが使われているかを検証してみる Part.1](https://qiita.com/zacky1972/items/e6e8d8ebe4400c6ef737)
- [SME日記その16 Scalable Matrix Extension (SME)の研究の今後の展望についての技術的ポエム](https://qiita.com/zacky1972/items/34ff853daebaf24761a4)
- [SME日記その17 __arm_new("za")について調べる Part.2](https://qiita.com/zacky1972/items/ecf250b81e9e2afa8ab2)

## ElixirでのSMEが使えるかどうかの判定ロジック

1. macOSでなければ`false`を返して終了
2. `sysctl hw.optional.arm` を実行し，出力に`hw.optional.arm.FEAT_SME: 1`と`hw.optional.arm.FEAT_SME2: 1`が含まれていれば，2の結果は`true`，そうでなければ2の結果は`false`
3. 次のCプログラムを`/usr/bin/clang -O2 -march=armv9-a+sme test_sme.c -o test_sme`としてコンパイルし，成功すれば3の結果は`true`，そうでなければ3の結果は`false`
4. 2と3の結果が共に`true`であれば，SMEを使えるので`true`を返す．そうでなければ`false`を返す．

1・2と，3 は並列に実行しても良い．

```c
#include <arm_sme.h>

__arm_locally_streaming
__arm_new("za")
void test_arm_new(void)
{
}

int main(int argc, char *argv[])
{
  test_arm_new();
}
```

## macOSかどうかの判定

```elixir
case :os.type() do
  {:unix, :darwin} -> true
  _ -> false
end
```

## `sysctl hw.optional.arm` の実行判定

```elixir
case :os.type() do
  {:unix, :darwin} ->
    case System.find_executable("sysctl") do
      nil -> false

      executable -> 
        case System.cmd(executable, ["hw.optional.arm"], into: []) do
          {result, 0} ->
            result 
            |> Enum.map(&String.trim/1)
            |> Enum.filter(&String.match?(&1, ~r/FEAT\_SME/))
            |> Enum.map(&String.split(&1, " "))
            |> Enum.filter(fn [_, v] -> v == "1" end)
            |> Enum.count()
            |> then(& &1 != 0)

          {_, _} -> false
        end
    end
  
  _ -> false
end
```

## Cプログラムのコンパイル

```elixir
case System.find_executable("/usr/bin/clang") do
  nil -> false

  executable -> 
    base_root = :crypto.strong_rand_bytes(10) |> Base.encode32(case: :lower)
    base = base_root <> ".c"

    File.write(
      Path.join("/tmp", base), 
      """
      #include <arm_sme.h>

      __arm_locally_streaming
      __arm_new("za")
      void test_arm_new(void) {}
      int main(int argc, char *argv[])
      {
        test_arm_new();
      }
      """
    )
    |> case do
      :ok -> 
        System.cmd(
          executable, 
          [
            "-O2", 
            "-Werror",
            "-Wall",
            "-march=armv9-a+sme", 
            base,
            "-o",
            base_root
          ],
          into: [],
          cd: "/tmp",
          stderr_to_stdout: true
        )
        |> case do
          {_, 0} -> true
          _ -> false
        end
      
      {:error, _reason} -> false
    end
end
```    

## 全体

```elixir
defmodule SME do
  def available?() do
    {:ok, pid} = Task.Supervisor.start_link()

    task1 = Task.Supervisor.async(pid, fn -> runnable?() end)
    task2 = Task.Supervisor.async(pid, fn -> compilable?() end)
    
    Task.await(task1) and Task.await(task2)
  end

  def runnable?() do
    case :os.type() do
      {:unix, :darwin} -> 
        case execute("sysctl", ["hw.optional.arm"]) do
          {result, 0} -> 
            result
            |> String.split("\n")
            |> Enum.map(&String.trim/1)
            |> Enum.filter(&String.match?(&1, ~r/FEAT\_SME/))
            |> Enum.map(&String.split(&1, " "))
            |> Enum.filter(fn [_, v] -> v == "1" end)
            |> Enum.count()
            |> then(& &1 != 0)

          _ -> false
        end

      _ -> false
    end
  end

  def compilable?() do
    base_root = :crypto.strong_rand_bytes(10) |> Base.encode32(case: :lower)
    base = base_root <> ".c"

    File.write(
      Path.join("/tmp", base), 
      """
      #include <arm_sme.h>

      __arm_locally_streaming
      __arm_new("za")
      void test_arm_new(void) {}
      int main(int argc, char *argv[])
      {
        test_arm_new();
      }
      """
    )
    |> case do
      :ok -> 
        execute("/usr/bin/clang", 
          [
            "-O2", 
            "-Werror",
            "-Wall",
            "-march=armv9-a+sme", 
            base,
            "-o",
            base_root
          ],
          cd: "/tmp",
          stderr_to_stdout: true
        )
        |> case do
          {_, 0} -> true
          _ -> false
        end
      
      {:error, _reason} -> false
    end
  end

  defp execute(executable, options, opts \\ []) do
    System.find_executable(executable)
    |> case do
      nil -> 
        executable
        |> Path.basename()
        |> System.find_executable()
        |> case do
          nil -> false
          executable -> System.cmd(executable, options, opts)
        end

      executable -> System.cmd(executable, options, opts)
    end
  end
end
```
