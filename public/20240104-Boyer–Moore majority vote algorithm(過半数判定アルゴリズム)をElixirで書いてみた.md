---
title: Boyer–Moore majority vote algorithm(過半数判定アルゴリズム)をElixirで書いてみた
tags:
  - アルゴリズム
  - Elixir
private: false
updated_at: '2024-08-06T01:14:32+09:00'
id: da9b9c3d822a6bc95d7e
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
下記の記事を見て興味を持ったので，Elixirで実装してみました．

https://qiita.com/tatmius/items/37707bce1ef079616c93

英語のWikipediaでアルゴリズムを確認しました．

https://en.wikipedia.org/wiki/Boyer–Moore_majority_vote_algorithm

原著論文も参照しました．

Robert S. Boyer and J. Strother Moore: MJRTY---A Fast Majority Vote Algorithm, Institute for Computing Science and Computer Applications, Texas University, Austin, Texas, USA, February, 1981. Appear in *Automated Reasoning: Essays in Honor of Woody Bledsoe*, Edited by Robert S. Boyer, Springer Science+Business Media, B.V., 1991.


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
  def get(enum) do
    mid =
      enum
      |> Enum.count()
      |> Bitwise.bsr(1)

    enum
    |> Enum.reduce({nil, 0}, fn
      a, {_, 0} -> {a, 1}
      a, {a, k} -> {a, k + 1}
      _, {m, k} -> {m, k - 1}
    end)
    |> case do
      {c, k} when k > mid ->
        c

      {c, _} ->
        enum
        |> Enum.count(&(&1 == c))
        |> then(&(&1 > mid))
        |> case do
          true -> c
          _ -> nil
        end
    end
  end
end
```

あっさり，[`Enum.reduce/3`](https://hexdocs.pm/elixir/1.16.0/Enum.html#reduce/3)で書けました．

202408004 修正: 原著論文のコードに合わせました．

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

    test "[1, 2, 3, 2, 1]" do
      assert Majority.get([1, 2, 3, 2, 1]) == nil
    end
  end
end
```

過半数が決まらなかった時には `nil` を返します．(なお，Wikipedia中のコードではランダムな値が返ってくる不完全なコードです．)
