---
title: ZEAM開発ログ v.0.4.14 Elixir / NIF 間で BigNum をやりとりする (Elixir 側)
tags:
  - Elixir
private: false
updated_at: '2018-10-02T05:41:09+09:00'
id: a6e7cff3dcdddca3312c
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
ZACKYこと山崎進です。

Elixirでは整数値に上限・下限はないのですが，NIFとやりとりできるのはINT64もしくはUINT64の範囲だけです。今回，Elixir側でUINT64に分解することで NIF とBigNumをやりとりすることに成功したので3回に分けて報告します。

[「ZEAM開発ログ 目次」はこちら](https://qiita.com/zacky1972/items/70593ab2b70d192813df)

# 利用方法

Elixir 側のコードを[Asm パッケージ](https://github.com/zeam-vm/asm)の一部として実装しました。バージョン0.0.9以降です。

利用したい場合は mix.exs の該当箇所にこんな感じで書いてください。

```elixir
  defp deps do
    [
      {:asm, "~> 0.0.10"}
    ]
  end
```

整数値から BigNum 形式に変換するには次のようにします。

```elixir
iex(1)> bignum = Asm.BigNum.from_int 0
{0, [0]}
```

UINT64の範囲を超えるとこんな感じになります。タプルの第2引数がリトルエンディアン風にリストに並んでいます。

```elixir
iex(2)> Asm.BigNum.from_int(Asm.max_uint + 1)
{0, [0, 1]}
```

負の値は，タプルの第1引数が1になり，タプルの第2引数は絶対値になります。

```elixir
iex(3)> Asm.BigNum.from_int(-1)
{1, [1]}
```

BigNum 形式から整数値に変換するには次のようにします。

```elixir
iex(4)> bignum |> Asm.BigNum.to_int
0
```

# 書いたコード

lib/asm/big_num.ex

```elixir
defmodule Asm.BigNum do
  use Bitwise
  require Asm
  import Asm

  @moduledoc """
  Asm.BigNum is an implementation of BigNum for NIF interface.
  """
  defp is_negative(number) when number >= 0, do: 0
  defp is_negative(number) when number <  0, do: 1

  @doc """
  from_int(number) converts a number from integer to BigNum.

  ## Examples
  iex> Asm.BigNum.from_int(0)
  {0, [0]}

  iex> Asm.BigNum.from_int(Asm.max_uint + 1)
  {0, [0, 1]}

  iex> Asm.BigNum.from_int(-1)
  {1, [1]}

  iex> Asm.BigNum.from_int(-(Asm.max_uint + 1))
  {1, [0, 1]}
  """
  def from_int(number) when is_integer(number) do
    {number |> is_negative, number |> abs |> from_int_p}
  end

  defp from_int_p(number) when is_uint64(number), do: [number]
  defp from_int_p(number) when is_integer(number) do
    lower = number &&& Asm.max_uint
    higher = bsr(number, 64)
    [lower] ++ from_int_p(higher)
  end

  @doc """
  to_int(bignum) converts the bignum to an integer.

  ## Examples
    iex> 0 |> Asm.BigNum.from_int |> Asm.BigNum.to_int
    0
    iex> 1 |> Asm.BigNum.from_int |> Asm.BigNum.to_int
    1
    iex> Asm.max_uint + 1 |> Asm.BigNum.from_int |> Asm.BigNum.to_int
    0x1_0000_0000_0000_0000
    iex> -1 |> Asm.BigNum.from_int |> Asm.BigNum.to_int
    -1
    iex> -Asm.max_uint - 1 |> Asm.BigNum.from_int |> Asm.BigNum.to_int
    -0x1_0000_0000_0000_0000
  """
  def to_int({is_negative, bignum_p}) do
    result = bignum_p |> Enum.reverse |> Enum.reduce(0, & &1 + bsl(&2, 64))
    case is_negative do
      0 -> result
      1  -> -result
    end
  end
end
```

順に解説していきます。

```elixir
  defp is_negative(number) when number >= 0, do: 0
  defp is_negative(number) when number <  0, do: 1
```

負数かどうかを1/0で表します。true/falseにしなかったのは，NIF側でtrue/falseで判別するのが面倒だったからです。

```elixir
  defp from_int_p(number) when is_uint64(number), do: [number]
  defp from_int_p(number) when is_integer(number) do
    lower = number &&& Asm.max_uint
    higher = bsr(number, 64)
    [lower] ++ from_int_p(higher)
  end
```

プライベート関数 `from_int_p` は，リトルエンディアン順で整数値をUINT64に分解してリスト化します。

`Bitwise`の`&&&`と`bsr`を使っています。これらは正の整数に対してはうまく機能するのですが，負の整数に対して意図通りになってくれなかったので，絶対値を記録するという方式にしました。最後に再帰呼び出しにしてリストを連結しています。(本当は，ここの再帰をなくしたかった)

```elixir
  def from_int(number) when is_integer(number) do
    {number |> is_negative, number |> abs |> from_int_p}
  end
```

こんな感じでタプルにします。パイプライン演算子を使うと流れが読みやすいですね。

```elixir
  def to_int({is_negative, bignum_p}) do
    result = bignum_p |> Enum.reverse |> Enum.reduce(0, & &1 + bsl(&2, 64))
    case is_negative do
      0 -> result
      1  -> -result
    end
  end
```

一方，`to_int`では，引数でのマッチングと `Enum.reduce` を使いました。`Enum.reduce` の中で左シフトしながら加算していきます。最後に `is_negative` の値によって正負に分けます。

# ビッグエンディアンからリトルエンディアンに変更した理由

BigNum の加算では同じ桁同士を加算し，桁上がりを上位の桁に加算します。また桁数は可変です。

ビッグエンディアンの場合，2つのBigNum a, b が与えられたとき，a, b それぞれの n 桁目の配列上の位置が異なる可能性があります。このため，a, b を加算する時に a, b の配列上の位置が揃わない可能性があります。これは SIMD 化した時に障害になります。

これに対し，リトルエンディアンでは a, b それぞれの n 桁目の配列上の位置は一致するので，この問題が起きません。


次回は[「ZEAM開発ログ v.0.4.14.1 Elixir / NIF 間で BigNum をやりとりする (NIF側)」](https://qiita.com/zacky1972/items/2bafe7f51570670fc932)です。お楽しみに！
