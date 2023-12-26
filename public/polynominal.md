---
title: 多項式を計算するホーナー法をElixirで実装する
tags:
  - Elixir
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
授業で教えているホーナー法という，多項式を効率よく計算するアルゴリズムをElixirで実装してみましたので，報告します．

## 解答例

$a_0 x^n + a_1 x^{n - 1} + a_2 x^{n - 2} \cdots + a_{n - 2} x^2 + a_{n - 1} x + a_n$ を計算するのですが，リスト`a`として $[a_0, a_1, a_2, \cdots, a_{n - 2}, a_{n - 1}, a_n ]$ を与えます．

```elixir
fn x, a ->
  Enum.reduce(tl(a), hd(a), fn a, y -> y * x + a end)
end
```

## 解説

ホーナー法は次のようなアルゴリズムです．

* $y_k = a_0 x^k + a_1 x^{k - 1} + \cdots + a_{k - 1} x + a_{k}$ と定義する．
* $y_k$は次の漸化式で表せる
    * $y_0 = a_0$
    * $y_k = y_{k - 1} x + a_k$

そこで，`tl(a)` すなわち リスト$[a_1, a_2, \cdots, a_{n - 1}, a_n]$に対して，初期値`hd(a)` すなわち $a_0$ を初期値として，漸化式 `fn a, y -> y * x + a` を累積する[`Enum.reduce/3`](https://hexdocs.pm/elixir/1.16.0/Enum.html#reduce/3) を計算します．

ホーナー法が，Elixirだとこんなにも単純に書けるのは，少し感動しますね．
