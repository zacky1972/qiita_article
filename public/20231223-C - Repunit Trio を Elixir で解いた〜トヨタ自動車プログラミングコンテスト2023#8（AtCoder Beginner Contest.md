---
title: >-
  C - Repunit Trio を Elixir で解いた〜トヨタ自動車プログラミングコンテスト2023#8（AtCoder Beginner
  Contest 333）
tags:
  - AtCoder
  - Elixir
private: false
updated_at: '2023-12-23T12:10:02+09:00'
id: 4f6782794f50d91196e4
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
トヨタ自動車プログラミングコンテスト2023#8（AtCoder Beginner Contest 333）の C - Repunit Trio をElixirで解いたので報告します．

## 問題

https://atcoder.jp/contests/abc333/tasks/abc333_c

## 解答例

https://atcoder.jp/contests/abc333/submissions/48721661

```elixir
defmodule Main do
  def main() do
    n =
      IO.read(:line)
      |> String.trim()
      |> String.to_integer()

    Stream.unfold([1], fn a ->
      l =
        for p <- a, q <- a, r <- a  do
          p + q + r
        end
        |> Enum.uniq()
        |> Enum.sort()
     
      {l, [hd(a) * 10 + 1 | a]}
    end)
    |> Stream.drop_while(fn l -> Enum.count(l) < n end)
    |> Enum.take(1)
    |> List.flatten()
    |> Enum.at(n - 1)
    |> IO.puts()
  end
end
```

## 解説

まず，Repunit(レピュニット)の次の値を計算する関数を考えます．それは`fn a -> a * 10 + 1 end`です．こうすると，初期値`1`から始めて，`11`→`111`のようになります．

次に，Repunitを降順に並べたリストを生成する関数を考えます．それは，`fn a -> [hd(a) * 10 + 1 | a] end`です．こうすると，初期値`[1]`から始めて，`[11, 1]`→`[111, 11, 1]`のようになります．

次に，Repunitを降順に並べたリスト`a`が与えられているときに，組み合わせを生成して和を求め，値が等しい要素を1つに絞って，整列するという処理は，次のように書けます．

```elixir
for p <- a, q <- a, r <- a  do
  p + q + r
end
|> Enum.uniq()
|> Enum.sort()
```

`Stream.unfold`を用いて，Repunitを降順に並べたリストを無限に生成してみましょう．

```elixir
Stream.unfold([1], fn a ->
  l =
    for p <- a, q <- a, r <- a  do
      p + q + r
    end
    |> Enum.uniq()
    |> Enum.sort()
     
  {l, [hd(a) * 10 + 1 | a]}
end)
```

試しに`Enum.take`を用いて取り出してみると，期待通りになります．

```elixir
Stream.unfold([1], fn a ->
  l =
    for p <- a, q <- a, r <- a  do
      p + q + r
    end
    |> Enum.uniq()
    |> Enum.sort()
     
  {l, [hd(a) * 10 + 1 | a]}
end)
|> Enum.take(3)
```

結果は`[[3], [3, 13, 23, 33], [3, 13, 23, 33, 113, 123, 133, 223, 233, 333]]`となります．

次のようにして要素数が`n`以上になった最初の要素を取り出します．

```elixir
Stream.unfold([1], fn a ->
  l =
    for p <- a, q <- a, r <- a  do
      p + q + r
    end
    |> Enum.uniq()
    |> Enum.sort()
     
  {l, [hd(a) * 10 + 1 | a]}
end)
|> Stream.drop_while(fn l -> Enum.count(l) < n end)
|> Enum.take(1)
|> List.flatten()
```

あとは，`Enum.at`で，`n`番目の要素を取り出します．

