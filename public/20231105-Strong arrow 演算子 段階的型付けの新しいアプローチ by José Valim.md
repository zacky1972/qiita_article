---
title: 'Strong arrow 演算子: 段階的型付けの新しいアプローチ by José Valim'
tags:
  - Elixir
  - 型システム
private: true
updated_at: '2023-12-04T17:24:49+09:00'
id: e8ffa1be10e0e4fad427
organization_url_name: null
slide: false
ignorePublish: false
---
# Strong arrow 演算子: 段階的型付けの新しいアプローチ by José Valim

本記事は，[ElixirConf US 2023 でのJosé Valimのkeynoteで議論された「段階的集合論的型付け」のトピック(The foundations of the Elixir type system)](https://www.youtube.com/watch?v=giYbq4HmfGA)を元にした翻訳記事です．

[元記事 "Strong arrows: a new approach to gradual typing"](https://elixir-lang.org/blog/2023/09/20/strong-arrows-gradual-typing/)

Elixir の型システムの研究と開発は，CNRS 上級研究員の [Giuseppe Castagna](https://www.irif.fr/~gc/) が主導し，[Guillaume Duboc](https://www.irif.fr/users/gduboc/index) が博士課程の研究の一環として取り組んでいる進行中の取り組みです(元記事 : ["Type system updates: moving from research into development"](https://elixir-lang.org/blog/2023/06/22/type-system-updates-research-dev/) 翻訳: [「型システムのアップデート: 研究から開発への移行 by José Valim」](https://qiita.com/zacky1972/items/33fd39ef2a1dcdbb8b73))．

本記事では，[Giuseppe Castagna et al. 2023(The Design Principles of the Elixir Type System)](https://arxiv.org/abs/2306.06391)で提示されたアイデアを紹介することを目的として，提案された型システムが段階的型付けにどのように取り組むのか，またそれが集合論的型とどのように関連するのかについて説明します．

## 集合論的型

Elixir 用に現在研究開発している型システムは，集合論的な型に基づいています．つまり，その演算は，和集合・積集合・否定の基本的な集合演算に基づいています．

たとえば、アトム`:ok`は Elixir の値であり，型 `:ok` で表すことができます．Elixir 内のすべてのアトムは，型システム内でそれ自体で表されます． `:ok` または `:error` のいずれかを返す関数は，`:ok or :error` を返すとします．ここで，`or` 演算子は和集合を表します．

`:ok` および `:error` 型は、すべてのアトムを表す無限集合である `atom()` 型に含まれています． `:ok` と `atom()` 型の和集合は，`:ok or atom()` として記述でき，`atom()` と等価です(`:ok` は `atom()` の部分集合であるため)． `:ok` と `atom()` 型の共通部分は、`:ok and atom()` として記述でき，`:ok` と等価です．

同様に，`integer()` は、すべての整数を表す無限集合です．`integer() or atom()` は、すべての整数とアトムの和集合です． 共通部分 `integer() and atom()` は空集合であり，これを `none()` とします．Elixir に存在するすべての型の和集合は `term()` です．

集合論的型の利点は，基本的な集合演算に基づいて Elixir プログラムに見られる多くの興味深い特性をモデル化できることです．これにより，Elixir での入力がより表現力豊かになり，アクセスしやすくなることが期待されます．有界数量化(bounded quantification) (または有界多相性(bounded polymorphism)) と呼ばれる型システムの特徴を集合論的型で実装する方法の例を見てみましょう．

## 上界・下界

恒等関数は引数を受け取り，それをそのまま返す関数です．Java では次のように記述します:

```java
static <T> T identity(T arg) {
    return arg;
}
```

Typescriptでは次のとおりです:

```typescript
function identity<T>(arg: T): T {
  return arg;
}
```

Haskellでは次のとおりです:

```haskell
id :: a -> a
id arg = arg
```

上記のすべての例で、関数は型変数 `T` (または Haskell の場合は型変数 `a`) の引数を受け取り，同じ型 `T` の値を返すとします．関数のパラメーター(引数)が，多くの(poly)型をとる(morphs)ので，これをパラメトリック多相性(parametric polymorphism)と呼びます．Elixir では，次のように表します:

```elixir
$ a -> a
def identity(arg), do: arg
```

場合によっては，これらの型変数をさらに制限したい場合があります．例として，Java の恒等関数を数値に制限してみましょう:

```java
static <T extends Number> T identity(T arg) {
    return arg;
}
```

Typescriptでは次のとおりです:

```typescript
function identity<T extends number>(arg: T): T {
    return arg;
}
```

HaskellではOrd などの型クラスに制約できます:

```haskell
id :: Ord a => a -> a
id x = x
```

言い換えれば，これらの関数は，指定された制約を満たす限り，任意の型を受け入れることができます．受け取ることのできる型に制限を設けているため，これは有界多相性(bounded polymorphism)と呼ばれます．

そうは言っても，集合論的型で有界多相性を実装するにはどうすればよいでしょうか？ 型変数 `a`` があると想像してください．それが別の型に制限または制約されていることを確認するにはどうすればよいでしょうか？

集合論的型では，この操作は共通部分になります．`a and atom()` がある場合、`a` は `:foo` 型になりえます． `a` はすべてのアトム型を表す `atom()` 型にすることもできますが，`integer() and atom()` は空集合を返すため、`a` を `integer()` にすることはできません．言い換えれば，型変数に上界を設定するために共通部分を使用できるため，新しい意味論的構造を導入する必要はありません．したがって，Elixir の恒等関数を次のような数値に制限できます:

```elixir
$ a and number() -> a and number()
def identity(arg), do: arg
```

もちろん，これらの制約に対するシンタックスシュガー(syntax sugar)を提供することもできます(訳註: つまり，1つ後のプログラムは，1つ前のプログラムと同じ意味で，よりわかりやすい表現としています):

```elixir
$ a -> a when a: number()
def identity(arg), do: arg
```

しかし，結局のところ，それは単に共通部分にまで拡大するだけです(訳註: 前の共通部分の例`a and atom()` で，型変数`a`を最も大きくした場合は，`atom()`でした．そのことを指しています)．重要なのは，セマンティック レベルでは追加の構成や表現が必要ないということです．

> 注: 型に興味のある読者のために説明すると，集合論的型は，[Kernel Fun 風の限定された形式の有界数量化(bounded quantification)](http://lucacardelli.name/Papers/OnUnderstanding.pdf)を実装しています．一言で言えば，関数の範囲が同じである場合にのみ関数を比較できることを意味します．たとえば，私たちの型システムは，`a -> a when a: integer() or boolean()` が `a -> a when a: integer()` の部分型ではないことを示します．

下界も同様に取得できます．共通部分により型変数に上界を設定できる場合，型変数が常に和集合で拡張されることを指定するため，和集合は下界と等価になります．たとえば，`a or atom()` は,
結果には常にアトムと，`a` で指定された他のもの (1つのアトム，アトム型`atom()` 自体，または `integer()` などの完全に`atom()`と素な型の可能性がある) を含むことを示します．

Elixir のプロトコルは，Haskell の型クラス または Java のインターフェイスと同等の Elixirの構文であり，追加のセマンティクスなしで集合論的型をモデル化および構成できる機能のもう 1 つの例です．これを行うための正確なメカニズムは，読者の演習として残します(または将来のブログ投稿のトピック)．

