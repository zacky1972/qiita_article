---
title: 'ZEAM開発ログ番外編: Elixir で再帰とStreamのどちらが速いのか，素因数分解で比較してみた'
tags:
  - Elixir
private: false
updated_at: '2018-12-10T03:33:25+09:00'
id: d63903ff68f64e52b74a
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
(この記事は[「Elixir Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/elixir)の3日目です)

[「Elixir Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/elixir)2日目は @ryo33 さんの[「食事する哲学者の問題 with Cizen」](https://qiita.com/ryo33/items/3d3fc82cdcb929e0b9ec)でした。

[「Elixir Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/elixir)3日目の今日は， @sym_num さんが書いた[「素因数分解　-Elixir見習いの実習-」](https://qiita.com/sym_num/items/51f71cbb132946875adb)に刺激を受けて記事を書きました。 

私たち [fukuoka.ex](https://fukuokaex.fun) は次のような理由で再帰呼び出しよりも `Enum` を使った MapReduce スタイルのプログラムを推奨しています。

* プログラムが読みやすくなる
* 今まで研究してきた SIMD / GPU 並列化には `Enum` を使った形式の方が最適化しやすい

@sym_num さんは再帰呼び出しを使って書いていたので，`Enum` に近いプログラミングスタイルが実現できる `Stream` を使ったらいいんじゃないかと，軽い気持ちで取り組み始めたのですが，意外と実装に時間がかかり，しかもパフォーマンスは悪化しました。

いろいろと試行錯誤してパフォーマンスチューニングをした結果，見えてきたことが出てきたので，レポートをまとめたいと思います。

なお，この記事は，2018年12月2日に公開した[「言語実装 Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/lang_dev)2日目の[「ZEAM開発ログ: Elixir マクロ + LLVM で超並列プログラミング処理系を研究開発中」](https://qiita.com/zacky1972/items/cc88260a3c93c9f71317)に関連する内容でもあります。

# ベンチマークプログラムについて

ベンチマークプログラムは [GitHub: https://github.com/zeam-vm/fact](https://github.com/zeam-vm/fact) にて公開していますので，参照ください。

今回評価したのは次の5つです。

* **FactRecursive1**: @sym_num さんのオリジナル: factor と compress 両方で再帰呼び出しを使用
* **FactRecursive2**: @sym_num さんの改造版: factor は再帰呼び出し，compress は `Enum` を使用
* **FactStream1**: @zacky1972 による `Stream` 版その1: 最初に素数を生成して余りが0のものをピックアップ。ただし互除法を採用せずに元の数を割らない
* **FactStream2**: @zacky1972 による `Stream` 版その2: 2と奇数からなる数列を生成して余りが0のものをピックアップした後で，エラトステネスの篩にかける。互除法を採用せずに元の数を割らない
* **FactStream3**: @zacky1972 による `Stream` 版その3: 2と奇数からなる数列を生成して余りが0のものをピックアップして互除法により元の数を割り，探索範囲を絞り込む

ベンチマークを起動するプログラムは次のようなコードです。

```elixir
defmodule Fact do

  @on_load :on_load
  
  @benchmarks [
      {&Fact.FactRecursive1.info/0, &Fact.FactRecursive1.benchmark/0},
      {&Fact.FactRecursive2.info/0, &Fact.FactRecursive2.benchmark/0},
      {&Fact.FactStream1.info/0,    &Fact.FactStream1.benchmark/0},
      {&Fact.FactStream2.info/0,    &Fact.FactStream2.benchmark/0},
      {&Fact.FactStream3.info/0,    &Fact.FactStream3.benchmark/0},
  ]

  def on_load() do
    case :mnesia.start do
      :ok -> case :mnesia.create_table( :verify, [ attributes: [ :id, :fact] ] ) do
        {:atomic, :ok} -> :ok
        _ -> :err
      end
      _ -> :err
    end
  end

  def all_benchmarks() do
    @benchmarks
    |> Enum.map(fn {info, benchmark} ->
      IO.puts info.()

      {time, result} = :timer.tc(benchmark)

      case :mnesia.dirty_read(:verify, self()) do
      [] -> :mnesia.dirty_write({:verify, self(), result})
      [{:verify, _pid, verify}] -> if verify != result do
          IO.puts "verify error."
        end
      end

      IO.puts "#{:erlang.float_to_binary(time / 1_000_000, [decimals: 6])} sec."
    end)
  end
end
```

使ったテクニックとしては次の通りです。

* ベンチマークで利用する2つの関数 `info` と `benchmark` をタプルリスト `@benchmarks` にして整理しておく。`all_benchmarks` で順次 `@benchmarks` から `Enum.map` で取り出して，`info` と `benchmark` を呼び出す。
* Mnesia (Erlang VM が用意しているデータベース)に共有変数を記録する。初期化は `@on_load` を用いる。一番最初のベンチマークで実行した結果 `result` を Mnesia に記録し，2番目以降のベンチマークで実行した結果と比較する。
* 実行時間を秒で表示する際，指数表示ではなく10進表記で表示したいときには，`:erlang.float_to_binary/2` を用いる。第2引数を `[decimals: `(表示したい小数点以下の桁数)`]`で指定すると，10進表記になる。

このプログラムには書かれていませんが，ベンチマークは `factorization(11_111)` を実行する時間を計測することにより行います。

# FactRecursive1

@sym_num さんのオリジナルで， factor と compress 両方で再帰呼び出しを使用しています。

```elixir
defmodule Fact.FactRecursive1 do
  def factorization(n) do
    factorization1(n) |> compress
  end

  def compress([1,l|ls]) do compress1(ls,l,1,[]) end
  def compress([l|ls]) do compress1(ls,l,1,[]) end

  def compress1([],p,n,mult) do [[p,n]|mult] end
  def compress1([p|ls],p,n,mult) do compress1(ls,p,n+1,mult) end
  def compress1([l|ls],p,n,mult) do compress1(ls,l,1,[[p,n]|mult]) end

  def factorization1(n) do
    factor([],n,2,trunc(:math.sqrt(n)))
  end

  def factor(p,n,x,limit) do
    cond do
      n == 1 -> p
      x > limit -> [n|p]
      rem(n,x) == 0 -> factor([x|p],div(n,x),x,limit)
      x == 2 -> factor(p,n,3,limit)
      true -> factor(p,n,x+2,limit)
    end
  end

  def info() do
  	"#{__MODULE__}: factorization using recursive calls in compress and factor"
  end

  def benchmark() do
  	factorization(11_111)
  end
end
```

* `factor/4` にて，互除法を用いて探索範囲を狭めています(`cond` の `rem(n,x) == 0` の場合) 
* `info/0` にて `__MODULE__` というマクロが登場しますが，これによりモジュール名を取得できます。

# FactRecursive2

@sym_num さんの改造版で，factor は再帰呼び出し，compress は `Enum` を使用しています。

```elixir
defmodule Fact.FactRecursive2 do
  def factorization(n) do
    factorization1(n) |> compress
  end

  def compress(ls) do
    Enum.chunk_by(ls,fn(n) -> n end)
    |> Enum.map(fn(x) -> [hd(x),length(x)] end)
    |> Enum.reverse
  end

  def factorization1(n) do
    factor([],n,2,trunc(:math.sqrt(n)))
  end

  def factor(p,n,x,limit) do
    cond do
      n == 1 -> p
      x > limit -> [n|p]
      rem(n,x) == 0 -> factor([x|p],div(n,x),x,limit)
      x == 2 -> factor(p,n,3,limit)
      true -> factor(p,n,x+2,limit)
    end
  end

  def info() do
  	"#{__MODULE__}: factorization using recursive calls in factor and Enum in compress"
  end

  def benchmark() do
  	factorization(11_111)
  end
end
```

# FactStream1

@zacky1972 による `Stream` 版その1で，次のような方針を採っています。

* 最初にエラトステネスの篩(`sieve`)により素数を生成。ただし最初から2と奇数に絞っている。
* 余りが0のものをピックアップ
* ただし互除法を採用せずに元の数を割らない

```elixir
defmodule Fact.FactStream1 do
  def factorization(n) do
    result = Stream.unfold(2, fn
      2 -> {2, 3}
      m -> {m, m + 2}
    end)
    |> sieve()
    |> Stream.take_while(& (&1 <= div(n, 2) ))
    |> Stream.filter(& (rem(n, &1) == 0))
    |> Stream.map(& [&1, count_div(n, &1)])
    |> Enum.to_list()

    if length(result) == 0 do
      [[n, 1]]
    else
      result
    end
  end

  def sieve(seq) do
    Stream.unfold(seq, fn s ->
      p    = s |> Enum.at(0)
      next = s |> Stream.filter(fn x -> rem(x, p) != 0 end)
      {p, next}
    end)
  end

  def count_div(n, x) do
    Stream.unfold(n, fn
      1 -> nil
      n -> {n, div(n, x)}
    end)
    |> Stream.take_while(& (rem(&1, x) == 0))
    |> Enum.count
  end

  def info() do
  	"#{__MODULE__}: factorization using Stream that generates every prime numbers while half of the target number without dividing the target number"
  end

  def benchmark() do
  	factorization(11_111)
  end
end
```

* 互除法を採用しなかったのは，このときには `Stream.filter/1` でわかった結果に基づいて，その後の `Stream.filter/1` や `Stream.map/1` をコントロールする方法が思いつかなかったのでした。
* 互除法を採用しなかったことで，最初に生成する無限数列を素数列にする必要が出てきました。
* 素数の無限数列を生成するために，エラトステネスの篩 (`sieve`) は @naoya@github さんの[「無限リストによるエラトステネスのふるい」](https://qiita.com/naoya@github/items/c71f614b5ed8c05b998c)を採用しました。
* `元の数 = 2 * 素数` の場合が最も大きな素因数が登場すると考えたので，`Stream.take_while/1` で元の数を2で割った値以下の場合のみを取り出すようにしました。
* `Stream.unfold/2` は使い方が難しいですが，慣れると狙った無限数列を自在に作ることができるようになります。作る時は `iex` と `IO.inspect/1` を活用して，適宜中身を表示して動きを確かめながら作ります。

# FactStream2

@zacky1972 による `Stream` 版その2で，次のような方針を採っています。

* 2と奇数からなる数列を生成
* 余りが0のものをピックアップ
* その後，エラトステネスの篩にかける
* 互除法を採用せずに元の数を割らない

```elixir
defmodule Fact.FactStream2 do
  def factorization(n) do
    result = Stream.unfold(2, fn
      2 -> {2, 3}
      m -> {m, m + 2}
    end)
    |> Stream.take_while(& (&1 <= div(n, 2) ))
    |> Stream.filter(& (rem(n, &1) == 0))
    |> sieve()
    |> Stream.map(& [&1, count_div(n, &1)])
    |> Enum.to_list()

    if length(result) == 0 do
      [[n, 1]]
    else
      result
    end
  end

  def sieve(seq) do
    Stream.unfold(seq, fn s ->
      p    = s |> Enum.at(0)
      next = s |> Stream.filter(fn x -> rem(x, p) != 0 end)
      if p == nil do
        nil
      else
        {p, next}
      end
    end)
  end

  def count_div(n, x) do
    Stream.unfold(n, fn
      1 -> nil
      n -> {n, div(n, x)}
    end)
    |> Stream.take_while(& (rem(&1, x) == 0))
    |> Enum.count
  end

  def info() do
  	"#{__MODULE__}: factorization using Stream that generates numbers while half of the target number and filter by sieve without dividing the target number"
  end

  def benchmark() do
  	factorization(11_111)
  end
end
```

* 観測していて，`sieve` が重たいことに気づいたので，パイプラインの順番を組み替えて，後で `sieve` でフィルタリングするという手を試しました。
* `sieve` を改造して，有限数列が与えられた場合でも機能するようにしました。

# FactStream3

@zacky1972 による `Stream` 版その3で，次のような方針を採っています。

* 2と奇数からなる数列を生成
* 余りが0のものをピックアップ
* 互除法により元の数を割り，探索範囲を絞り込む

```elixir
defmodule Fact.FactStream3 do
  @on_load :on_load

  def on_load() do
    case :mnesia.start do
      :ok -> case :mnesia.create_table( :factor, [ attributes: [ :id, :n, :limit] ] ) do
        {:atomic, :ok} -> :ok
        _ -> :err
      end
      _ -> :err
    end
  end

  def factorization(n) do
    :mnesia.dirty_write({:factor, self(), n, div(n, 2)})
    result = Stream.unfold(2, fn
      2 -> {2, 3}
      m -> {m, m + 2}
    end)
    |> Stream.take_while(& reach_limit?(&1))
    |> Stream.filter(& rem0?(&1))
    |> Stream.map(& [&1, count_div(n, &1)])
    |> Enum.to_list()

    if length(result) == 0 do
      [[n, 1]]
    else
      result
    end
  end

  defp reach_limit?(x) do
    [{:factor, _pid, _n, limit}] = :mnesia.dirty_read({:factor, self()})
    x <= limit
  end

  defp rem0?(x) do
    [{:factor, _pid, n, _limit}] = :mnesia.dirty_read({:factor, self()})
    result = (rem(n, x) == 0)
    if result do 
      n = div_all(n, x)     
      :mnesia.dirty_write({:factor, self(), n, n})
    end
    result
  end

  defp loop_div(n, x) do
    Stream.unfold(n, fn
      1 -> nil
      n -> {n, div(n, x)}
    end)
    |> Stream.take_while(& (rem(&1, x) == 0))
  end

  defp div_all(n, x) do
    loop_div(n, x) |> Enum.at(-1) |> div(x)
  end

  defp count_div(n, x) do
    loop_div(n, x) |> Enum.count
  end
  
  def info() do
  	"#{__MODULE__}: factorization using Stream that generates numbers while half of the target number or that divided by founded factor"
  end

  def benchmark() do
  	factorization(11_111)
  end
end
```

* Mnesia を使って，元の数 `n` と探索範囲 `limit` を共有することで，互除法を実現しました。
* 元の数 `n` を因数 `x` で何回割り切れるかをカウントする `count_div/2` と，元の数 `n` を因数 `x` で繰り返し割って割り切ったあまりを求める `div_all/2` の共通部分式である `loop_div/2` をくくり出しました。
* `list |> Enum.at(-1)` はリスト `list` の末尾要素を取り出します。

# 実行結果

iMac Pro (2017) にてベンチマーク `Fact.all_benchmarks` を実行してみました。

* Processor: [2.3 GHz Intel Xeon W](https://ark.intel.com/JA/products/126793/Intel-Xeon-W-2195-Processor-24_75M-Cache-2_30-GHz) (プロセッサ数 1，物理コア18，論理コア36)
* Memory: 32 GB 2666 MHz DDR4
* Graphics: Radeon Pro Vega 64 16368MB
* SSD (BlackMagic)
    * Write 2980.3MB/s
    * Read 2465.1MB/s

CPUとGPUは最高性能の構成，メモリとSSDは標準構成です。

```bash
$ mix run -e "Fact.all_benchmarks"
Elixir.Fact.FactRecursive1: factorization using recursive calls in compress and factor
0.000005 sec.
Elixir.Fact.FactRecursive2: factorization using recursive calls in factor and Enum in compress
0.001167 sec.
Elixir.Fact.FactStream1: factorization using Stream that generates every prime numbers while half of the target number without dividing the target number
2.336041 sec.
Elixir.Fact.FactStream2: factorization using Stream that generates numbers while half of the target number and filter by sieve without dividing the target number
0.000391 sec.
Elixir.Fact.FactStream3: factorization using Stream that generates numbers while half of the target number or that divided by founded factor
0.000201 sec.
```

FactRecursive1 ぶっちぎりです。やはり全て再帰呼び出しで書いた方がパフォーマンスは良くなります。

`Stream` を用いたベンチマークは，改良により大幅に高速化されていることがわかります。エラトステネスの篩が特に重たいですし，互除法を採用することでも探索範囲が狭まって高速化できます。結果として相当高速化されたのですが，FactRecursive1 には及びません。

# 考察

Elixir / Erlang VM 環境下では `Enum` や `Stream`，`Flow` などを用いるより，再帰呼び出しを用いた方が高速であるということは，今回のベンチマーク結果だけでなく，今までも観測してきたことです。

一方，現在研究開発中の micro Elixir / ZEAM 環境下では，Hastega により `Enum` について SIMD 並列化を施したネイティブコードで実行できるようにすることを計画しています。できれば，Hastega は `Enum` だけでなく，`Stream` や `Flow` を使ったコードも同様に SIMD 並列化できればいいなと思っています。もし実現すれば，既存の Elixir コードを Hastega を利用するように少し書き換えるだけで，CPU バウンドなデータ処理部分を SIMD 並列化したネイティブコードで実行できるので，恩恵が大きいと考えています。

この場合に気をつけたいのが，`Stream` で書かれたプログラムは現状逐次実行されるもので，並列化を想定していないという点です。例えば，FactStream3 は，Mnesia を通じて共有変数を書き換えているので，並列化したときに実行順序が保たれず，意図しない結果になることが予想されます。おそらく FactStream2 のように `sieve` を挟まないと実行結果が狂うんじゃないかと思います。並列化した時にこのような問題が起こらないかどうかを，コンパイラが静的に検出するのは一般にはとても難しいことだと思います。

また，そもそも `Stream` を扱うということは，無限数列を生成できるということなので，私たちが実現に向けて検討していた実行時間推定は `Stream` を用いてしまうと実現できないということが言えます。これについては，`Stream` を含む一連のパイプラインには「実行時間が推定できない」というマークをつけることで対処することになると思います。

さらに，`Stream` を用いた場合には，固定長の配列ではなく，後から要素を追加できる線形リストのようなデータ構造を用いる必要があるという制約が出てきます。この制約はSIMD並列化に不利になります。しかし，ある程度の数をまとめて配列のリストというような形で実装すれば，SIMD並列化の恩恵が受けられるのではないかと思います。

# 考察追記

@piacere_ex さんからの指摘があり「Mnesia は速度が遅い」ということでした。今回はMnesiaのオーバーヘッド以上にアルゴリズムの改善が利いて速度向上したということだと思います。

[FastGlobal という Discord が作った保持ライブラリ](https://github.com/discordapp/fastglobal)を使うと速度が有利だそうです。

近々，FastGlobal を使ってベンチマーク評価しようと思います。お楽しみに！ また，Hastega にも導入してみたいと思います。

# おわりに

素因数分解について，再帰呼び出しを用いた場合と `Stream` を用いた場合とで性能を比較し，将来の Hastega / micro Elixir / ZEAM で `Stream` をどのように扱うべきか考察しましたが，いかがだったでしょうか？　2018年のアドベントカレンダー各所でも展開していきます！ 次に私がアドベントカレンダーの記事を書くのは2018年12月7日の[「ソフトウェアテスト #2 Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/softwaretesting-2)7日目[「並列プログラミング言語 Elixir (エリクサー) におけるソフトウェアテスト〜基礎から最新展望まで」](https://qiita.com/zacky1972/items/c4ae3f34a4406ee99487)です。お楽しみに！

[「Elixir Advent Calendar 2018」](https://qiita.com/advent-calendar/2018/elixir)，明日の記事は @piacere_ex さんの[「【Gigalixir編①】Elixir／Phoenix本番リリース： 初期PJリリースまで」](https://qiita.com/piacere_ex/items/1a9cbcc740ca3707eaec)です。こちらもお楽しみに！
