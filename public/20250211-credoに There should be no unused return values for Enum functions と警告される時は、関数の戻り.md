---
title: >-
  credoに "There should be no unused return values for Enum functions"
  と警告される時は、関数の戻り値に使っていない値があるのが問題なので、空の代入で回避する
tags:
  - Elixir
private: false
updated_at: '2025-02-11T15:56:26+09:00'
id: 7498894c5c6c41efa312
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
ほぼタイトルの通りです。

## コード例

例えば次のようなコードを考えてみます。

```elixir
defmodule Sample do
  @moduledoc false
  def code({to_return, side_effect}) do
    Enum.reduce(side_effect, fn
      1, _acc -> IO.puts("side effect")
      _, _ -> 0
    end)

    to_return
  end
end
```

このコードの意図することとしては、 `side_effect` で与えられたデータ列を元に、 `IO.puts` のような副作用のあるコードを実行した後、 `side_effect` から生成したデータ自体は捨ててしまうという感じです。

このコードに credo をかけると、次のような警告が出ます。

```elixir
% mix credo
Checking 3 source files ...

  Warnings - please take a look                                                 
┃ 
┃ [W] ↗ There should be no unused return values for Enum functions.
┃       lib/sample.ex:4:5 #(Sample.code)

Please report incorrect results: https://github.com/rrrene/credo/issues

Analysis took 0.03 seconds (0.01s to load, 0.02s running 55 checks on 3 files)
3 mods/funs, found 1 warning.

Showing priority issues: ↑ ↗ →  (use `mix credo explain` to explain issues, `mix credo --help` for options).
```

ちなみにこのコードの例だと、 次のように `Enum.each` を使えば警告は解消されます。

```elixir
defmodule Sample do
  @moduledoc false
  def code({to_return, side_effect}) do
    Enum.each(side_effect, fn
      1 -> IO.puts("side effect")
      _ -> 0
    end)

    to_return
  end
end
```

ただ、私がもともとやりたかったのは、 `Enum.reduce` でデータを集計しつつ、エラーが分かったときに標準出力に出したかったのですよね。

## 解決方法

次のように空の代入を入れると、credoは警告を出しません。

```elixir
defmodule Sample do
  @moduledoc false
  def code({to_return, side_effect}) do
    _ =
      Enum.reduce(side_effect, fn
        1, _acc -> IO.puts("side effect")
        _, _ -> 0
      end)

    to_return
  end
end
```

