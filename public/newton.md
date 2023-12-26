---
title: ニュートン法をElixirで実装してみた
tags:
  - Elixir
private: false
updated_at: ''
id: null
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
授業で教えているニュートン法をElixirで実装してみましたので，報告します．

## 解答例

```elixir
fn f, f_d, x0, n, e ->
  Enum.reduce_while(1..n, {x0, nil}, fn _, {x, _} ->
    t = f.(x) / f_d.(x)
    x = x - t
    ee = abs(t / x)
    if ee < e do
      {:halt, {x, ee}}
    else
      {:cont, {x, ee}}
    end
  end)
  |> then(fn {x, ee} ->
    if ee < e do
      {:ok, x}
    else
      {:error, "Solution is not found."}
    end
  end)
end
```

## 実行例

`f`に$f(x)$，`f_d`に$f'(x)$，`x0`に初期値，`e`に目標精度を与えます．

先ほどの関数を変数`newton`に代入し，$f(x) = x^2 - 16, f'(x) = 2x$としてみましょう．

```elixir
iex> newton.(fn x -> x ** 2 - 16 end, fn x -> 2 * x end, 10, 2, 0.1)
{:error, "Solution is not found."}
iex> newton.(fn x -> x ** 2 - 16 end, fn x -> 2 * x end, 10, 3, 0.1)
{:ok, 4.009115285226041}
iex> newton.(fn x -> x ** 2 - 16 end, fn x -> 2 * x end, 10, 3, 0.01)
{:error, "Solution is not found."}
iex> newton.(fn x -> x ** 2 - 16 end, fn x -> 2 * x end, 10, 4, 0.01)
{:ok, 4.000010362438947}
iex> newton.(fn x -> x ** 2 - 16 end, fn x -> 2 * x end, 10, 4, 0.001)
{:error, "Solution is not found."}
iex> newton.(fn x -> x ** 2 - 16 end, fn x -> 2 * x end, 10, 5, 0.001)
{:ok, 4.000000000013422}
iex> newton.(fn x -> x ** 2 - 16 end, fn x -> 2 * x end, 10, 5, 0.0001)
{:ok, 4.000000000013422}
iex> newton.(fn x -> x ** 2 - 16 end, fn x -> 2 * x end, 10, 5, 0.00001)
{:ok, 4.000000000013422}
iex> newton.(fn x -> x ** 2 - 16 end, fn x -> 2 * x end, 10, 5, 0.000001)
{:error, "Solution is not found."}
iex> newton.(fn x -> x ** 2 - 16 end, fn x -> 2 * x end, 10, 6, 0.000001)
{:ok, 4.0}
```

$f(x) = x^2 - 2, f'(x) = 2x$としてみましょう．

```elixir
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 2, 0.1)
{:error, "Solution is not found."}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 3, 0.1)
{:error, "Solution is not found."}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 4, 0.1)
{:error, "Solution is not found."}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 5, 0.1)
{:ok, 1.4145256551487377}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 5, 0.01)
{:error, "Solution is not found."}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 6, 0.01)
{:ok, 1.4142135968022693}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 6, 0.001)
{:ok, 1.4142135968022693}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 6, 0.0001)
{:error, "Solution is not found."}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 7, 0.0001)
{:ok, 1.4142135623730954}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 7, 0.00001)
{:ok, 1.4142135623730954}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 7, 0.000001)
{:ok, 1.4142135623730954}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 7, 0.0000001)
{:ok, 1.4142135623730954}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 7, 0.00000001)
{:error, "Solution is not found."}
iex> newton.(fn x -> x ** 2 - 2 end, fn x -> 2 * x end, 10, 8, 0.00000001)
{:ok, 1.4142135623730951}
iex> :math.sqrt(2)
1.4142135623730951
```