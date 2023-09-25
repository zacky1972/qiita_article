---
title: Erlang VMのprocess_flagのmessage_queue_dataのon_heapとoff_heapで軽く性能評価してみました
tags:
  - Erlang
  - Elixir
private: false
updated_at: '2021-12-15T09:00:39+09:00'
id: fc10dc46f241ab94f50a
organization_url_name: null
slide: false
ignorePublish: false
---
# はじめに

[BEAM/OTP対話#9](https://pelemay.connpass.com/event/230906/)で[The Erlang Runtime System](https://blog.stenmans.org/theBeamBook/)を[3.2節](https://blog.stenmans.org/theBeamBook/#_processes_are_just_memory)から[3.6節](https://blog.stenmans.org/theBeamBook/#_lock_free_message_passing)まで読んで知ったのですが，`process_flag`の`message_queue_data`を`on_heap`(デフォルト)にするか`off_heap`にするかで，メッセージを受け取るときの挙動と性能が変わるという話を聞いて，とても興味を持ったので実験をしてみました。

また，`benchee`を使って入力データの種類ごとにベンチマークを集計する方法，ベンチマークごとに前処理する方法についてもこの記事で紹介しています。

この記事は[NervesJP Advent Calendar 2021](https://qiita.com/advent-calendar/2021/nervesjp)の9日目の記事です。8日目は @torifukukaiou さんの[Nerves meets SORACOM (Elixir)](https://qiita.com/torifukukaiou/items/3a77efc82c48dc0ff61e)でした。

# BEAM/OTP対話#9で読んだところ

[The Erlang Runtime System](https://blog.stenmans.org/theBeamBook/)

* [3.2. Processes Are Just Memory](https://blog.stenmans.org/theBeamBook/#_processes_are_just_memory)
* [3.3. The PCB](https://blog.stenmans.org/theBeamBook/#_the_pcb)
* [3.4. The Garbage Collector (GC)](https://blog.stenmans.org/theBeamBook/#_the_garbage_collector_gc)
* [3.5. Mailboxes and Message Passing](https://blog.stenmans.org/theBeamBook/#_mailboxes_and_message_passing)
    * [3.5.1. Sending Messages in Parallel](https://blog.stenmans.org/theBeamBook/#_sending_messages_in_parallel)
* [3.6. Lock Free Message Passing](https://blog.stenmans.org/theBeamBook/#_lock_free_message_passing)
    * [3.6.1. Memory Areas for Messages](https://blog.stenmans.org/theBeamBook/#_memory_areas_for_messages)
    * [3.6.2. Inspecting Message Handling](https://blog.stenmans.org/theBeamBook/#_inspecting_message_handling)
    * [3.6.3. The Process of Sending a Message to a Process](https://blog.stenmans.org/theBeamBook/#_the_process_of_sending_a_message_to_a_process)
    * [3.6.4. Receiving a Message](https://blog.stenmans.org/theBeamBook/#_receiving_a_message)
    * [3.6.5. Tuning Message Passing](https://blog.stenmans.org/theBeamBook/#_tuning_message_passing)

この部分は，Erlang VMの内部に迫る内容で，メッセージパッシングを性能向上させるために，いかに安全性を保ったままロック獲得によるオーバーヘッドをなくしていくか，という話で，とても勉強になりました。[BEAM/OTP対話#9](https://pelemay.connpass.com/event/230906/)の[動画を公開しています](https://youtu.be/5YnqmkVge5Y)ので，ぜひ見てみてください。Erlang VMは，大袈裟ですが，人類が誇るべき財産だと思いました。

ちなみに[The Erlang Runtime System](https://blog.stenmans.org/theBeamBook/)の著者Erik Stenmanさんに連絡して，日本語訳をすることの許諾を得ました。近々取り組もうと思っています。翻訳チームに入りたい方，ご連絡ください。

# on_heapとoff_heapで何が変わるか？

`on_heap`はOTP 19以前からあるようなメッセージ受信の方法です。初期状態では`on_heap`となります。条件が整えば，ヒープに直接メッセージを書き込みますが，他のプロセスと競合しているなど，条件が整わない場合には m-buf というメモリ領域を別途確保してまとめてメッセージを書き込み，「あとで読んでね」と受信する側のプロセスに教えます。条件が整ったときにはコピーが発生しないので，高速になります。そのため1つのプロセスからしか受信をしない場合には有効です。反面，たくさんのプロセスから同時に受信するような場合には性能が落ちるとのことです。

これに対し，`off_heap`はOTP 19以降の新しいメッセージ受信の方法です。この戦略だと，状況に関係なく，m-bufというメモリ領域を別途確保してまとめてメッセージを書き込むことにします。多数のプロセスから受信をする場合に有効だとされています。

# Elixirでon_heapとoff_heapを切り替えるには？

Erlang VM全体で `off_heap` に切り替えるには次のようにします。

```zsh
elixir --erl "+hmqd off_heap" *.{ex,exs}
```

なお，`*.{ex,exs}`には実行させたいElixirのファイル名が入ります。

Mixを使って Erlang VM 全体を `off_heap` に切り替える場合には次のようにします。

```zsh
elixir --erl "+hmqd off_heap" -S mix
```

このようにしてErlang VM全体を`off_heap`にしてみて，パフォーマンスが向上するかどうかを確認します。向上しないならば，パフォーマンスボトルネックは他に原因があります。向上するならば，次にボトルネックになっているプロセスを特定してそのプロセスだけを `off_heap` にします。ボトルネックを見るには，プロセスごとのメッセージの滞留度合いを見れば良いかと思います。[BEAM/OTP対話#8](https://pelemay.connpass.com/event/229293/)にて解説しました。[BEAM/OTP対話#8の動画](https://youtu.be/u34TMuudPpE)を公開していますので，是非参照ください。

特定のプロセスを`off_heap`にするには，そのプロセスの中で次の式を実行します。

```elixir
Process.flag(:message_queue_data, :off_heap)
```

`GenServer`を使っているときには，`init`の中でこの式を実行すると良いでしょう。


# 実験

次のようなコードで実験をしてみました。[プログラミングElixir第2版](https://www.ohmsha.co.jp/book/9784274226373/)にも書かれている `Pmap` (Parallel map)の例です。

```elixir
defmodule Pmap do
  @moduledoc """
  Documentation for `Pmap`.
  """

  def pmap(collection, func) do
    collection
    |> Enum.map(&Task.async(fn -> func.(&1) end))
    |> Enum.map(&Task.await/1)
  end
end
```

[benchee](https://github.com/bencheeorg/benchee)を使って次のようなベンチマークコードを書いてみます。

```elixir
map_fun = fn i -> [i, i * i] end

Benchee.run(
  %{
    "pmap (on_heap)" => {
      fn input -> Pmap.pmap(input, map_fun) end,
      before_scenario: fn input ->
        Process.flag(:message_queue_data, :on_heap)
        input
      end
    },
    "pmap (off_heap)" => {
      fn input -> Pmap.pmap(input, map_fun) end,
      before_scenario: fn input ->
        Process.flag(:message_queue_data, :off_heap)
        input
      end
    }
  },
  inputs: %{
    "Small" => Enum.to_list(1..1_000),
    "Medium" => Enum.to_list(1..10_000),
    "Bigger" => Enum.to_list(1..100_000)
  },
  memory_time: 2
)
```

* 入力データ `input` は次の3種類です。
    * Small(1,000個の要素からなるリスト)
    * Medium(10,000個の要素からなるリスト)
    * Bigger(100,000個の要素からなるリスト)
* それぞれの入力データに対し，`on_heap`と`off_heap`のそれぞれの場合で性能がどのように変わるのかを検証します。
    * この切り替えは `before_sceario: fn -> ... end` を使って，ベンチマーク実行の直前で実行するようにしてみました。

## 実験環境

次のような環境で実験しました。

```
Operating System: macOS
CPU Information: Apple M1
Number of Available Cores: 8
Available memory: 16 GB
Elixir 1.13.0
Erlang 24.1.7
```

## 実験結果

得られたベンチマーク結果は次のとおりでした。

```
##### With input Bigger #####
Name                      ips        average  deviation         median         99th %
pmap (off_heap)          2.37      421.29 ms     ±1.84%      418.69 ms      437.96 ms
pmap (on_heap)           2.31      432.39 ms     ±2.12%      431.32 ms      454.44 ms

Comparison: 
pmap (off_heap)          2.37
pmap (on_heap)           2.31 - 1.03x slower +11.10 ms

Memory usage statistics:

Name                    average  deviation         median         99th %
pmap (off_heap)        66.38 MB     ±1.58%       66.92 MB       67.05 MB
pmap (on_heap)         66.93 MB     ±0.38%       66.99 MB       67.16 MB

Comparison: 
pmap (off_heap)        66.92 MB
pmap (on_heap)         66.93 MB - 1.01x memory usage +0.54 MB

##### With input Medium #####
Name                      ips        average  deviation         median         99th %
pmap (off_heap)         23.98       41.70 ms     ±3.02%       41.56 ms       44.82 ms
pmap (on_heap)          23.85       41.93 ms     ±3.77%       42.02 ms       46.16 ms

Comparison: 
pmap (off_heap)         23.98
pmap (on_heap)          23.85 - 1.01x slower +0.23 ms

Memory usage statistics:

Name                    average  deviation         median         99th %
pmap (off_heap)         6.61 MB     ±1.32%        6.63 MB        6.70 MB
pmap (on_heap)          6.57 MB     ±1.82%        6.59 MB        6.69 MB

Comparison: 
pmap (off_heap)         6.63 MB
pmap (on_heap)          6.57 MB - 0.99x memory usage -0.03901 MB

##### With input Small #####
Name                      ips        average  deviation         median         99th %
pmap (off_heap)        247.87        4.03 ms     ±7.31%        4.04 ms        4.76 ms
pmap (on_heap)         235.61        4.24 ms     ±7.01%        4.26 ms        5.08 ms

Comparison: 
pmap (off_heap)        247.87
pmap (on_heap)         235.61 - 1.05x slower +0.21 ms

Memory usage statistics:

Name                    average  deviation         median         99th %
pmap (off_heap)       650.49 KB     ±2.00%      653.55 KB      670.22 KB
pmap (on_heap)        652.15 KB     ±1.88%      654.64 KB      672.29 KB

Comparison: 
pmap (off_heap)       653.55 KB
pmap (on_heap)        652.15 KB - 1.00x memory usage +1.66 KB
```

`off_heap`の方がいずれも速くなっていますが，若干ぐらいかな，というところです。

# 考察

今回の実験で用いたプログラムだと，送信側のプロセスの数がとても多いものの，各プロセスの処理時間が短く，かつ送信が1回限りですので，プロセス間の競合が起きにくい状況だと思います。したがって，`off_heap`による性能向上の効果があまり無かったものと思います。

逆に言えば，もし，各プロセスが長い間にわたって生存し，送信をたびたび行うようなものであれば，`off_heap`の効果は大きくなるんじゃないかと思います。今後，実験していきたいと思います。

# おわりに

そういうわけで，ひとまず Elixir において，Erlang VM全体と特定のプロセスそれぞれについて，OTP 19以降でサポートされた `off_heap` に設定する方法がわかったので，満足とします。また，ついでに`benchee`を使って入力データの種類ごとにベンチマークを集計する方法，ベンチマークごとに前処理する方法がわかったこともよかったです。

明日は @the_haigo さんの[Nerves で GPS Loggerを作ってみた](https://qiita.com/the_haigo/items/a941f769ed1e60e382eb)です。お楽しみに。
