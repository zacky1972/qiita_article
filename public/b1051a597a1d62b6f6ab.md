---
title: Elixirで速度を追い求めるときのプログラミングスタイル PartⅡ，Pelemayの近況もあるよ
tags:
  - Elixir
  - Pelemay
private: false
updated_at: '2020-12-25T14:00:54+09:00'
id: b1051a597a1d62b6f6ab
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[fukuoka.ex Elixir／Phoenix Advent Calendar 2020](https://qiita.com/advent-calendar/2020/fukuokaex) 25日目の記事です。

昨日は @Yoosuke さんの[「高校生に教えていた Elixirのカリキュラムの一部をクリスマスイブに公開します。（５時間分まで）」](https://qiita.com/Yoosuke/items/6c623a882acdf7956589)でした。

[fukuoka.ex Elixir／Phoenix Advent Calendar 2020](https://qiita.com/advent-calendar/2020/fukuokaex)は，[WebテクノロジーのLGTM数順](https://qiita.com/advent-calendar/2020/ranking/feedbacks/categories/web_technologies)で堂々1位となりました。 素晴らしいことです！

さて，今日は[「Elixirで速度を追い求めるときのプログラミングスタイル」](https://qiita.com/zacky1972/items/5963a8bf5f2a34c67d88)の第2弾ということで，「Elixirで速度を追い求めるときのプログラミングスタイル PartⅡ，Pelemayの近況もあるよ」をお送りします。

# BasicBenchmarkElixir

今回のベンチマークのコードはこちらです。

https://github.com/zacky1972/basic_benchmarks_elixir

# 検証環境

```bash
> elixir -v
Erlang/OTP 23 [erts-11.1.1] [source] [64-bit] [smp:36:36] [ds:36:36:10] [async-threads:1] [hipe]

Elixir 1.11.2 (compiled with Erlang/OTP 23)
```

iMac Pro 2017 のCPU/GPU全部盛りで検証しています。

# 結果

```
## EnumBench
benchmark name iterations   average time 
Enum.map               50   55946.10 µs/op
recursive              50   56215.64 µs/op
## ListAddBench
benchmark name iterations   average time 
add long list  1000000000   0.01 µs/op
add head       1000000000   0.01 µs/op
add tail       1000000000   0.01 µs/op
## ListPopBench
benchmark name iterations   average time 
pop head        100000000   0.02 µs/op
pop tail               50   37582.68 µs/op
## ListReverseBench
benchmark name iterations   average time 
reverse               200   9471.07 µs/op
## ProcessBench
benchmark name iterations   average time 
echo              1000000   1.42 µs/op
send list         1000000   1.42 µs/op
```

* `EnumBench`は`Enum.map`と`recursive`の実行時間を比較しています。ご覧の通り，ほぼ差はなく，`Enum.map`を選ばない手はないかなと思います。
* `ListAddBench`は次の3つのベンチマークです。どれも速度に差はなく，極めて高速に処理できることがわかります。
    * `add long list`は長いリスト2つを`++`で結合します。
    * `add head` は先頭に1つ要素を追加します `[:a | @list]`
    * `add tail` は末尾に1つ要素を追加します `@list ++ [:a]`
* `ListPopBench`は次の2つのベンチマークです。先頭から要素を取り出すのは極めて高速ですが，末尾の要素を無理矢理取り出すのは極めて低速です。
    * `pop head` は `[head | tail]`を実行します。
    * `pop tail` は `List.delete_at(@list, -1)`を実行します。
* `ListReverseBench`は`Enum.reverse`を計測しています。リスト長が長くなると実行時間がかかりますが，他の操作に比べると比較的高速です。
* `ProcessBench`は，`spawn`→`send`→`receive`の一連の操作にかかる時間を計測しています。プロセスを起動しているとは思えないくらい，極めて高速に実行できます。ちなみにプロセスをプールするよりも高速に実行できることがわかっています。送るメッセージの長さを変えても実行時間は変わりませんでした。ノードを起動して，分散実行した時を検証してみたいところです。

# 所感

次の結果は，今までの常識を塗り替える物だったので，特に驚きました。

* `++`は結合するリストの長さによらず，極めて高速に実行できること
* `Enum.map`と再帰スタイルの実行時間に差がないこと
* プロセスの起動は極めて高速で，1〜数μ秒オーダーであること，プールするよりも速いこと

ElixirおよびErlangのアップデートにより，これらの改善が図られてきたのではないかと思うと，胸熱です。

# この結果を今後どう活かすか？

なぜこのような基礎的なベンチマークを取っていたかというと，Pelemayのマルチコア並列処理版を作ろうとしているからです。プロトタイプ版はすでに動いていて，従来のFlowやPmapはもちろんのこと，EnumやPelemayよりも高速に動作できることを確かめています。数々の試作を重ねて基礎データを積み重ねてきたことで，設計・実装する上での肝となる部分が把握できたので，現在，プロトタイプ第2弾を実装しているところです。

この成果については，論文発表をしてから改めて発表する予定です。

本研究成果は、科学技術振興機構研究成果展開事業研究成果最適展開支援プログラム A-STEP トライアウト JPMJTM20H1 の支援を受けた。
