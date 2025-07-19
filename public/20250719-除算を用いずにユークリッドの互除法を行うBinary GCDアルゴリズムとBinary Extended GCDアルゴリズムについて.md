---
title: 除算を用いずにユークリッドの互除法を行うBinary GCDアルゴリズムとBinary Extended GCDアルゴリズムについて
tags:
  - アルゴリズム
  - Elixir
  - 数学
  - 暗号
  - ユークリッドの互除法
private: false
updated_at: '2025-07-19T11:10:24+09:00'
id: 67ec4938014d07ac1f96
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
除算を用いずにユークリッドの互除法を行うBinary GCDアルゴリズムとBinary Extended GCDアルゴリズムについて調べて、Elixirで実装しました。

この2つの違いは、Binary GCDアルゴリズムは最大公約数を返すのみですが、Binary Extended GCDアルゴリズムは最大公約数に加えて係数も返します。

## Binary GCDアルゴリズムのElixir実装

https://github.com/zacky1972/binary_gcd

```elixir
iex> BinaryGcd.of(48, 18)
6

iex> BinaryGcd.of(0, 5)
5

iex> BinaryGcd.of(54, 24)
6

iex> BinaryGcd.of(17, 13)
1
```

```elixir
defmodule BinaryGcd do
  def of(m, n)
  def of(0, n), do: n
  def of(m, 0), do: m

  def of(m, n) when Bitwise.band(m, 1) == 0 and Bitwise.band(n, 1) == 0 do
    of(Bitwise.bsr(m, 1), Bitwise.bsr(n, 1))
    |> Bitwise.bsl(1)
  end

  def of(m, n) when Bitwise.band(n, 1) == 0 do
    of(m, Bitwise.bsr(n, 1))
  end

  def of(m, n) when m <= n, do: of(m, n - m)
  def of(m, n), do: of(n, m)
end
```

1. 両方の数が偶数の場合、両方を2で割り、その結果に2を掛けます。
2. 片方の数が偶数の場合、それを2で割ります。
3. 両方の数が奇数の場合、大きい方から小さい方を引きます。
4. どちらかの数が0になるまで繰り返します。

## Binary Extended GCD アルゴリズム

https://github.com/zacky1972/binary_extended_gcd

```elixir
iex> BinaryExtendedGcd.of(48, 18)
{6, 2, -5}

iex> BinaryExtendedGcd.of(17, 13)
{1, -16, 21}

iex> BinaryExtendedGcd.of(0, 5)
{5, 0, 1}

iex> BinaryExtendedGcd.of(12, 0)
{12, 1, 0}
```

```elixir
iex> CommonTwos.of(12, 8)
{2, 3, 2}

iex> CommonTwos.of(16, 24)
{3, 2, 3}

iex> CommonTwos.of(7, 11)
{0, 7, 11}
```

```elixir
defmodule CommonTwos do
  def of(a, b), do: sub({0, a, b})

  # Private function that performs the recursive bitwise operations
  # to find common factors of 2 between the two numbers
  defp sub({shift, a, b}) when Bitwise.bor(a, b) |> Bitwise.band(1) != 0 do
    {shift, a, b}
  end

  defp sub({shift, a, b}), do: sub({shift + 1, Bitwise.bsr(a, 1), Bitwise.bsr(b, 1)})
end

defmodule BinaryExtendedGcd do
  def of(a, b)
  def of(0, b), do: {b, 0, 1}
  def of(a, 0), do: {a, 1, 0}

  def of(a, b) do
    CommonTwos.of(a, b)
    |> then(fn {shift, a, b} ->
      {shift, sub(a, b, a, b, 1, 0, 0, 1)}
    end)
    |> then(fn {shift, {v, cc, dd}} ->
      {Bitwise.bsl(v, shift), cc, dd}
    end)
  end

  # Main recursive function for binary extended GCD
  # Returns {gcd, x, y} where gcd = ax + by
  defp sub(0, v, _a, _b, _aa, _bb, cc, dd), do: {v, cc, dd}

  defp sub(u, v, a, b, aa, bb, cc, dd) do
    {u, a, b, aa, bb} = sub1(u, a, b, aa, bb)
    {v, a, b, cc, dd} = sub2(v, a, b, cc, dd)
    {u, v, aa, bb, cc, dd} = sub3(u, v, aa, bb, cc, dd)
    sub(u, v, a, b, aa, bb, cc, dd)
  end

  # Handle odd/even cases for first parameter u
  defp sub1(u, a, b, aa, bb) when Bitwise.band(u, 1) != 0 do
    {u, a, b, aa, bb}
  end

  defp sub1(u, a, b, aa, bb), do: sub11(Bitwise.bsr(u, 1), a, b, aa, bb)

  # Adjust Bézout coefficients when dividing by 2
  defp sub11(u, a, b, aa, bb) when Bitwise.band(aa, 1) == 0 and Bitwise.band(bb, 1) == 0 do
    {u, a, b, Bitwise.bsr(aa, 1), Bitwise.bsr(bb, 1)}
  end

  defp sub11(u, a, b, aa, bb) do
    {u, a, b, Bitwise.bsr(aa + b, 1), Bitwise.bsr(bb - a, 1)}
  end

  # Handle odd/even cases for second parameter v
  defp sub2(v, a, b, cc, dd) when Bitwise.band(v, 1) != 0 do
    {v, a, b, cc, dd}
  end

  defp sub2(v, a, b, cc, dd), do: sub11(Bitwise.bsr(v, 1), a, b, cc, dd)

  # Compare and subtract based on magnitude
  defp sub3(u, v, aa, bb, cc, dd) when u >= v do
    {u - v, v, aa - cc, bb - dd, cc, dd}
  end

  defp sub3(u, v, aa, bb, cc, dd) do
    {u, v - u, aa, bb, cc - aa, dd - bb}
  end
end
```
