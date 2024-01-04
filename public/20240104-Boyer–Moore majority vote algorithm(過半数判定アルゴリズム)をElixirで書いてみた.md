---
title: Boyer–Moore majority vote algorithm(過半数判定アルゴリズム)をElixirで書いてみた
tags:
  - アルゴリズム
  - Elixir
private: false
updated_at: '2024-01-04T20:08:40+09:00'
id: da9b9c3d822a6bc95d7e
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
下記の記事を見て興味を持ったので，Elixirで実装してみました．

https://qiita.com/tatmius/items/37707bce1ef079616c93

英語のWikipediaでアルゴリズムを確認しました．

https://en.wikipedia.org/wiki/Boyer–Moore_majority_vote_algorithm

## 実装例

プログラム本体は次のとおりです．

```elixir:lib/majority.ex
defmodule Majority do
  @moduledoc """
  The Boyer–Moore majority vote algorithm.
  """

  @doc """
  Returns the majority of the given `list`.
  """
  @spec get(list(any())) :: any()
  def get(list) do
    list
    |> Enum.reduce({nil, 0}, fn
      x, {_, 0} -> {x, 1}
      x, {x, c} -> {x, c + 1}
      _, {m, c} -> {m, c - 1}
    end)
    |> elem(0)
  end
end
```

あっさり，[`Enum.reduce/3`](https://hexdocs.pm/elixir/1.16.0/Enum.html#reduce/3)で書けました．

テストコードは次のとおりです．

```elixir:majority_test.exs
defmodule MajorityTest do
  use ExUnit.Case
  doctest Majority

  describe "Majority.get/1" do
    test "[1, 2, 1, 1]" do
      assert Majority.get([1, 2, 1, 1]) == 1
    end

    test "[1, 2, 2, 1, 1]" do
      assert Majority.get([1, 2, 2, 1, 1]) == 1
    end

    test "[1, 2, 2, 2, 1, 3]" do
      assert Majority.get([1, 2, 2, 2, 1, 3]) == 2
    end

    test "[1, 2, 2, 2, 3, 2, 3]" do
      assert Majority.get([1, 2, 2, 2, 3, 2, 3]) == 2
    end
  end
end
```


