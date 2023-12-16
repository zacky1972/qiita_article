---
title: 'Elixirで順に指定個数の素数を列挙する関数をEnum, Stream, Flowで作ってみた'
tags:
  - Elixir
private: false
updated_at: '2022-12-19T20:58:23+09:00'
id: 2cdc68f56c2b42b803e1
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
ふと興味を持ったので，エラトステネスのふるいを純朴に利用して，Elixirで小さいものから順に指定個数の素数を列挙する関数をEnum, Stream, Flowを使って作ってみました．

シリーズ

* [Elixirで順に指定個数の素数を列挙する関数をNxでも作ってみた](https://qiita.com/zacky1972/items/8923735951724ff21d44)


# ソースコード全体

```elixir
Mix.install(
  [
    {:flow, "~> 1.2"},
    {:benchee, "~> 1.1"}
  ]
)

defmodule Prime do

  def prime_candidates() do
    Stream.unfold(2, fn
      2 -> {2, 3}
      n -> {n, n + 2}
    end)
  end

  def prime_enum(count) do
    prime_candidates()
    |> Stream.map(fn pr -> {pr, Stream.take_while(prime_candidates(), & &1 < pr)} end)
    |> Enum.take(count)
    |> Enum.map(fn {pr, prs} -> {pr, Enum.filter(prs, & rem(pr, &1) == 0)} end)
    |> Enum.filter(fn {_pr, divisors} -> Enum.count(divisors) == 0 end)
    |> Enum.map(fn {pr, _} -> pr end)
  end

  def prime_stream(count) do
    prime_candidates()
    |> Stream.map(fn pr -> {pr, Stream.take_while(prime_candidates(), & &1 < pr)} end)
    |> Stream.take(count)
    |> Stream.map(fn {pr, prs} -> {pr, Stream.filter(prs, & rem(pr, &1) == 0)} end)
    |> Stream.filter(fn {_pr, divisors} -> Enum.count(divisors) == 0 end)
    |> Stream.map(fn {pr, _} -> pr end)
    |> Enum.to_list()
  end

  def prime_flow(count) do
    prime_candidates()
    |> Stream.map(fn pr -> {pr, Stream.take_while(prime_candidates(), & &1 < pr)} end)
    |> Stream.take(count)
    |> Flow.from_enumerable(max_demand: 1)
    |> Flow.map(fn {pr, prs} -> {pr, Stream.filter(prs, & rem(pr, &1) == 0)} end)
    |> Flow.filter(fn {_pr, divisors} -> Enum.count(divisors) == 0 end)
    |> Flow.map(fn {pr, _} -> pr end)
    |> Enum.to_list()
  end
end

Benchee.run(
  %{
    "prime_enum" => fn count -> Prime.prime_enum(count) end,
    "prime_stream" => fn count -> Prime.prime_stream(count) end,
    "prime_flow" => fn count -> Prime.prime_flow(count) end
  },
  inputs: %{
    "10" => 10,
    "100" => 100,
    "1000" => 1000,
    "10000" => 10000
  })
```

# コード解説

```elixir
  def prime_candidates() do
    Stream.unfold(2, fn
      2 -> {2, 3}
      n -> {n, n + 2}
    end)
  end
```

このプログラム片は次のような列挙をします．

```elixir
[2, 3, 5, 7, 9, 11, 13, 15, 17, 19, ...]
```

つまり最初2で，次は3で，以降，次々2を足していって奇数を列挙して，素数の候補(prime_candidates)としています．

次に，

```elixir
    prime_candidates()
    |> Stream.map(fn pr -> {pr, Stream.take_while(prime_candidates(), & &1 < pr)} end)
```

このプログラム片は，次のような列挙をします．

```elixir
[
    {2, []},
    {3, [2]},
    {5, [2, 3]},
    {7, [2, 3, 5]},
    ...
]
```

つまり，素数の候補(prime_candidates)と，それより小さい素数の候補のリストからなるタプルを列挙しています．

次に，

```elixir
  def prime_enum(count) do
    prime_candidates()
    |> Stream.map(fn pr -> {pr, Stream.take_while(prime_candidates(), & &1 < pr)} end)
    |> Enum.take(count)
```

とすることで，引数 `count` の個数だけ，前述の列挙をします．

Stream版，Flow版だと次のようにします．

```elixir
  def prime_enum(count) do
    prime_candidates()
    |> Stream.map(fn pr -> {pr, Stream.take_while(prime_candidates(), & &1 < pr)} end)
    |> Stream.take(count)
```

次がエラトステネスのふるいの本体となります．

```elixir
  def prime_enum(count) do
    prime_candidates()
    |> Stream.map(fn pr -> {pr, Stream.take_while(prime_candidates(), & &1 < pr)} end)
    |> Enum.take(count)
    |> Enum.map(fn {pr, prs} -> {pr, Enum.filter(prs, & rem(pr, &1) == 0)} end)
    |> Enum.filter(fn {_pr, divisors} -> Enum.count(divisors) == 0 end)
    |> Enum.map(fn {pr, _} -> pr end)
  end
```

* `|> Enum.map(fn {pr, prs} -> {pr, Enum.filter(prs, & rem(pr, &1) == 0)} end)`の部分は，素数の候補`pr`を，`pr`より小さい素数の候補のリスト`prs`の各要素で割り切れる数，すなわち`pr`の約数からなるリストを生成して，`pr`とともにタプルにしています．
* `|> Enum.filter(fn {_pr, divisors} -> Enum.count(divisors) == 0 end)` で，上記のリスト`divisors`(約数)の個数が0であるような要素のみからなるリストを生成します．
* `|> Enum.map(fn {pr, _} -> pr end)`とすることで，前述のようなエラトステネスのふるいを潜り抜けた，素数からなるリストを生成します．

Stream版の場合には次のようにしています．

```elixir
  def prime_stream(count) do
    prime_candidates()
    |> Stream.map(fn pr -> {pr, Stream.take_while(prime_candidates(), & &1 < pr)} end)
    |> Stream.take(count)
    |> Stream.map(fn {pr, prs} -> {pr, Stream.filter(prs, & rem(pr, &1) == 0)} end)
    |> Stream.filter(fn {_pr, divisors} -> Enum.count(divisors) == 0 end)
    |> Stream.map(fn {pr, _} -> pr end)
    |> Enum.to_list()
  end
```

Flow版の場合には次のようにしています．

```elixir
  def prime_flow(count) do
    prime_candidates()
    |> Stream.map(fn pr -> {pr, Stream.take_while(prime_candidates(), & &1 < pr)} end)
    |> Stream.take(count)
    |> Flow.from_enumerable(max_demand: 1)
    |> Flow.map(fn {pr, prs} -> {pr, Stream.filter(prs, & rem(pr, &1) == 0)} end)
    |> Flow.filter(fn {_pr, divisors} -> Enum.count(divisors) == 0 end)
    |> Flow.map(fn {pr, _} -> pr end)
    |> Enum.to_list()
  end
```

# ベンチマーク結果(MacStudio on M1 Ultra)

```
```

* 10個の時には僅差でEnumが最速でした．
* 100個の時にはStreamが最速でした．
* 1000,10000個の時にはFlowが最速でした．










