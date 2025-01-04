---
title: Elixir Zen スタイルプログラミング講座
tags:
  - Elixir
private: false
updated_at: '2025-01-05T07:40:39+09:00'
id: 619f39cc77fbb52b1bbf
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
# はじめに

みなさん，Elixir Zen スタイルでプログラミングしていますか？

え，「Elixir Zen スタイルって何？」ですと?!

そんな流行に乗り遅れている貴方，このプレゼンテーションを聴衆とともに笑いながら見てください！

[<img width="666" alt="Lonestar ElixirConf 2019 - Hastega: Challenge for GPGPU on Elixir - Susumu Yamazaki" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/15ce8a01-5c2e-6747-6377-fbf0de4b19ea.png">](https://youtu.be/lypqlGlK1So)

英語はどうしても嫌だ！という人は，次のプレゼンテーションをどうぞ

[<img width="1006" alt="WSAに最適化された並列処理系" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/aa242dc8-d31e-c0f3-994e-ec576a6c3f72.png">](https://speakerdeck.com/zacky1972/web-system-architecture-nizui-shi-hua-saretabing-lie-chu-li-xi)

というわけで，Elixir Zen スタイルを推し進めると，次のような良いことがあります！

1. 再帰スタイルで書くよりも，**プログラムがとっても読みやすくなります。**
2. 今私たちが頑張って実装している **Hastega が実用になると，最速で実行してくれるようになります。**

これが **「魔法による禅と侍の調和」** すなわち **「侘び寂び」** です。なんのことかわからない人は，前述の英語プレゼンテーションを見てくださいね！

というわけで，この記事では，Elixir Zen スタイルの数々のプログラム例を紹介します。2019年5月3日からほぼ毎日のように連続ツイートしているので，見てやってください。

# Enum.reduce って何をしているの？

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">Elixir の Enum.reduce が何をしているか，わからない人向けの連続ツイート，書くぜ！ <a href="https://twitter.com/hashtag/fukuokaex?src=hash&amp;ref_src=twsrc%5Etfw">#fukuokaex</a></p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1124231401723678720?ref_src=twsrc%5Etfw">2019年5月3日</a></blockquote>



```elixir
Enum.reduce([1, 2, 3], 0, fn x, acc -> M.func(x, acc) end)

0 # 第2引数
|> M.func(1) # 第3引数の関数
|> M.func(2)
|> M.func(3)
```

<blockquote class="twitter-tweet" data-conversation="none" data-lang="ja"><p lang="ja" dir="ltr">言葉にすると，難しいと思うので，<br><br>0 # 第2引数<br>|&gt; M.func(1) # 第3引数の関数<br>|&gt; M.func(2)<br>|&gt; M.func(3)<br><br>このイメージをどうぞ！</p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1124239093376831489?ref_src=twsrc%5Etfw">2019年5月3日</a></blockquote>



# Enum.reduce/3 と Enum.map/2 の組合わせ

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">Enum.reduce/3 が何をしているか，理解しましたか？ 今度は <a href="https://t.co/FpqjZ1GS28">https://t.co/FpqjZ1GS28</a> と組み合わせてみましょう！</p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1124468005323173894?ref_src=twsrc%5Etfw">2019年5月4日</a></blockquote>


```elixir
[1, 2, 3]
|> Enum.map(& &1 * 2)
|> Enum.reduce(0, fn x, acc -> x + acc end)
```

# Elixir プログラミングでかっこが多重になりそうなときに，どうしたらいいか？

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">今回の連続ツイートでは，Elixir プログラミングでかっこが多重になりそうなときに，どうしたらいいか？を解説します。 <a href="https://twitter.com/hashtag/fukuokaex?src=hash&amp;ref_src=twsrc%5Etfw">#fukuokaex</a></p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1125160190251130880?ref_src=twsrc%5Etfw">2019年5月5日</a></blockquote>


**第1引数の中にカッコを書きたくなったら，パイプライン演算子を使え！**

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">今回の場合は ... の部分が第1引数にあるので，パイプライン演算子を使えば，次のようにかっこの外に追い出せます！<a href="https://t.co/GfdYKnkfmY">https://t.co/GfdYKnkfmY</a>(...)<br>|&gt; Enum.reduce(0, fn x, acc -&gt; x + acc end)</p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1125162121241563136?ref_src=twsrc%5Etfw">2019年5月5日</a></blockquote>


```elixir
Enum.reduce(Enum.map(...), 0, fn x, acc -> end)
```

```elixir
Enum.map(...)
Enum.reduce(0, fn x, acc -> x + acc end)
```

# 複数のリストの各要素ごとに積をとりたい

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">今日のお題:<br>[1, 2, 3] と [4, 5, 6] を各要素ごとに掛け算をして(積をとって)，[1 * 4, 2 * 5, 3 * 6] すなわち [4, 10, 18] を計算するプログラムを書きましょう。<a href="https://twitter.com/hashtag/fukuokaex?src=hash&amp;ref_src=twsrc%5Etfw">#fukuokaex</a></p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1125878666628440064?ref_src=twsrc%5Etfw">2019年5月7日</a></blockquote>


```elixir
Enum.zip([1, 2, 3], [4, 5, 6])
|> Enum.map(& Tuple.to_list(&1))
|> Enum.map(& Enum.reduce(&1, 1, fn x, acc -> x * acc end)) 
```

# 長いリストを決められた個数ごとに分割したい

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">今日のお題: 「長いリストを決められた個数ごとに分割したい」<br>こんな時は，Enum.chunk_every/2 を使います！<a href="https://twitter.com/hashtag/fukuokaex?src=hash&amp;ref_src=twsrc%5Etfw">#fukuokaex</a><a href="https://t.co/PEm25k63sM">https://t.co/PEm25k63sM</a></p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1126290793101029376?ref_src=twsrc%5Etfw">2019年5月9日</a></blockquote>


```elixir
1..24
|> Enum.chunk_every(4)
```

# To be continued...
