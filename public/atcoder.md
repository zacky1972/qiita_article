---
title: ElixirにおけるAtCoder Beginners Selection 最後の難問 ABC086C Traveling ついに解ける！
tags:
  - AtCoder
  - Elixir
private: false
updated_at: '2023-12-04T17:02:39+09:00'
id: 810a7e8567dbd1688ae3
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
AtCoder Beginners Selectionは初心者向けのAtCoderの問題ですが，最後の問題 ABC086C Travelingを Elixir で解こうとすると，TLE(実行時間制限超過)になってしまって，なかなか解けないでいました．しかし，Streamを駆使することで，ついに解けましたので，ご報告します．

https://atcoder.jp/contests/abs/submissions/48188980

```elixir
defmodule Main do
  @bl 65536

  defp st(_h, {l1, l2, 0}), do: {:halt, {l1, l2, 0}}

  defp st(h, {l1, l2, n}) when n > 0 do
    h = Enum.join(l1 ++ ["#{l2}#{h}"], " ")

    if String.match?(h, ~r/\n/) do
      l = String.split(h, "\n")
      c = Enum.count(l)

      last = 
        Enum.take(l, -1) 
        |> hd()

      l = 
        Enum.take(l, c - 1)
        |> Enum.map(&String.split(&1, " "))
        |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)

      n = n - (c - 1)

      if String.match?(last, ~r/ /) do
        l1 = String.split(last, " ")
        c = Enum.count(l1)
        l2 = (Enum.take(l1, -1) |> hd())
        l1 = Enum.take(l1, c - 1)
        {l, {l1, l2, n}}
      else
        {l, {[], last, n}}
      end
    else
      {[], {l1, h, n}}
    end
  end

  defp s([tp, xp, yp], [to, xo, yo]) do
    td = abs(tp - to)
    xd = abs(xp - xo)
    yd = abs(yp - yo)
    t = td - (xd + yd)
  
    t >= 0 and Bitwise.band(t, 1) == 0
  end

  def main() do
    n =
      IO.read(:line)
      |> String.trim()
      |> String.to_integer()

    IO.stream(:stdio, @bl)
    |> Stream.transform({[], "", n}, &st/2)
    |> Stream.scan([[0, 0, 0]], & [&1 | &2])
    |> Stream.transform(true, fn [x1 | [x2 | _]], acc -> 
      t = s(x1, x2) and acc

      if t do
        {[t], t}
      else
        {:halt, t}
      end
    end)
    |> Enum.to_list()
    |> Enum.count()
    |> case do
      ^n -> "Yes"
      _ -> "No"
    end
    |> IO.puts()
  end
end
```

まずはアルゴリズムについて，解説をご覧ください．

https://blog.hamayanhamayan.com/entry/2018/01/21/225430

この解説のアルゴリズムに沿って，Elixirで解くと，次のようになります．

```elixir
defmodule Main do
  defp s([tp, xp, yp], [to, xo, yo]) do
    td = abs(tp - to)
    xd = abs(xp - xo)
    yd = abs(yp - yo)
    t = td - (xd + yd)
  
    t >= 0 and Bitwise.band(t, 1) == 0
  end

  def main() do
    _n =
      IO.read(:line)
      |> String.trim()
      |> String.to_integer()

    IO.read(:all)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)
    |> Enum.scan([[0, 0, 0]], & [&1 | &2])
    |> Enum.reduce(true, fn [x1 | [x2 | _]], acc -> 
      s(x1, x2) and acc
    end)
    |> case do
      true -> "Yes"
      _ -> "No"
    end
    |> IO.puts()
  end
end
```

しかし，このコードは3つのケースでTLE(実行時間制限超過)になってしまいます．

https://atcoder.jp/contests/abs/submissions/48188580

そこで，まずStreamを使うことを検討します．`IO.read(:all)`の代わりに`IO.stream()`を用い，`Enum.reduce`を`Stream.transform`に置き換えます．`t`が`false`になったら打ち切って，全体の個数が`n`の時に`Yes`を，そうでない時に`No`を表示するようにします．

```elixir
defmodule Main do
  defp s([tp, xp, yp], [to, xo, yo]) do
    td = abs(tp - to)
    xd = abs(xp - xo)
    yd = abs(yp - yo)
    t = td - (xd + yd)
  
    t >= 0 and Bitwise.band(t, 1) == 0
  end

  def main() do
    n =
      IO.read(:line)
      |> String.trim()
      |> String.to_integer()

    IO.stream(:stdio, :line)
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&String.split(&1, " "))
    |> Stream.map(fn l -> Enum.map(l, &String.to_integer/1) end)
    |> Stream.scan([[0, 0, 0]], & [&1 | &2])
    |> Stream.transform(true, fn [x1 | [x2 | _]], acc -> 
      t = s(x1, x2) and acc

      if t do
        {[t], t}
      else
        {:halt, t}
      end
    end)
    |> Enum.to_list()
    |> Enum.count()
    |> case do
      ^n -> "Yes"
      _ -> "No"
    end
    |> IO.puts()
  end
end
```

これにより，TLE(実行時間制限超過)が2つにまで減りました．

https://atcoder.jp/contests/abs/submissions/48188939

入力例と`IO.stream`の挙動について考察してみると，改行を境に一度に3つの値を読み込むような感じになります．もし，バッファリングされていないのだとすると，細切れに値を読み込むことになります．ここがボトルネックになりそうです．

そこで，`IO.stream`で読み込む時に，定数`@bl`で示したバイト数だけ一気に読み込んで文字列に格納していき，その直後に`Stream.transform`で，改行とスペースを区切りとしながら，端数も考慮して，Streamに分割していくことを考えます．それを実装したのが，冒頭のプログラムコードになります．

