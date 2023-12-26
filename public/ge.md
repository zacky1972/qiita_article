---
title: ガウスの消去法で連立方程式を解くElixirプログラム
tags:
  - Elixir
  - nx
private: false
updated_at: '2023-12-27T07:11:42+09:00'
id: 9c5aaa135c3360a48014
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
連立方程式を解く代表的なアルゴリズムとして，授業で教えている，ガウスの消去法をElixirとNxで書いたので，報告します．

## 解答例

```elixir
defmodule GuessianElimination do
  def solve(a, b) do
    {n, n} = Nx.shape(a)

    {a, b}
    |> forward_elimination(n)
    |> backward_substitution(n)
    |> Nx.tensor()
  end

  defp forward_elimination({a, b}, n) do
    0..n-2
    |> Enum.reduce({a, b}, fn k, {a, b} ->
      k+1..n-1
      |> Enum.reduce(pivot({a, b}, n, k), fn i, {a, b} ->
        alpha = Nx.negate(Nx.divide(a[i][k], a[k][k]))

        {
          Nx.indexed_add(a, indices(n, i), Nx.multiply(a[k], alpha)),
          Nx.indexed_add(b, Nx.tensor([i]), Nx.multiply(b[k], alpha))
        }
      end)
    end)
  end

  defp backward_substitution({a, b}, n) do
    Enum.reduce(n-2..0, [Nx.to_number(b[n-1]) / Nx.to_number(a[n-1][n-1])], fn k, x ->
      r =
        k+1..n-1
        |> Enum.map(& {Nx.to_number(a[k][&1]), Enum.at(x, &1 - k - 1)})
        |> Enum.map(fn {a, b} -> a * b end)
        |> Enum.sum()

      [(Nx.to_number(b[k]) - r) / Nx.to_number(a[k][k]) | x]
    end)
  end

  defp pivot({a, b}, n, k) do
    Nx.transpose(a)[k]
    |> Nx.slice([k], [n - k])
    |> Nx.argmax()
    |> Nx.add(k)
    |> Nx.to_number()
    |> case do
      l when l != k ->
        {
          swap(a, {indices(n, k), k}, {indices(n, l), l}),
          swap(b, {Nx.tensor([k]), k}, {Nx.tensor([l]), l})
        }

      _ -> {a, b}
    end
  end

  defp swap(t, {indices_l, l}, {indices_k, k}) do
    t
    |> Nx.indexed_put(indices_k, t[l])
    |> Nx.indexed_put(indices_l, t[k])
  end

  defp indices(n, i) do
    0..n-1
    |> Enum.map(&[i, &1])
    |> Nx.tensor()
  end
end
```

関数`forward_elimination`は前進消去，関数`backward_substitution`は後退代入，関数`pivot`は，部分ピボット選択(対角成分の最も大きな行を選択する処理)です．

作るのもとても難しかったですが，できたプログラムコードを説明するのも，とても難しいです...
