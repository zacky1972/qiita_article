---
title: xのn乗を計算する2進分解法をElixirで実装する
tags:
  - Elixir
private: false
updated_at: '2023-12-26T16:41:52+09:00'
id: 217579807b329a9cf293
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
授業で教えている2進分解法という，$x$と正の整数$n$に対する$x^n$を計算するアルゴリズムをElixirで実装してみましたので，報告します．

## 解答例

```elixir
fn x, n ->
  Stream.unfold(n, fn
      0 -> nil
      n -> {Bitwise.band(n, 1), Bitwise.bsr(n, 1)}
  end)
  |> Enum.reduce({1, x}, fn
    0, {r, x} -> {r, x * x}
    1, {r, x} -> {r * x, x * x}
  end)
  |> elem(0)
end
```

## 解説

[`Stream.unfold/2`](https://hexdocs.pm/elixir/1.16.0/Stream.html#unfold/2)を使って，下記のようにすることで，`n`を下位ビットから順番にビットを取り出したリストのStreamを生成し，上位ビットが全て0になったら終了します．

```elixir
Stream.unfold(n, fn
    0 -> nil
    n -> {Bitwise.band(n, 1), Bitwise.bsr(n, 1)}
end)
```

このリストに対し，初期値`{r, x} = {1, x}`として，[`Enum.reduce/3`](https://hexdocs.pm/elixir/1.16.0/Enum.html#reduce/3)によって，次のロジックで繰り返します．

* ビットが0の時には，`{r, x} = {r, x * x}`とする
* ビットが1の時には，`{r, x} = {r * x, x * x}`とする

最後に，[`elem/2`](https://hexdocs.pm/elixir/1.16.0/Kernel.html#elem/2)を使って，`r`のみを取り出します．

## 余談

[`Stream.unfold/2`](https://hexdocs.pm/elixir/1.16.0/Stream.html#unfold/2)のドキュメントの例題がわかりやすくなったと思いませんか？ 実はこれは私 @zacky1972 の提案によるものです！

https://hexdocs.pm/elixir/1.16.0/Stream.html#unfold/2

