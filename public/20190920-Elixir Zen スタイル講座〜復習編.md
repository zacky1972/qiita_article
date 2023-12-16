---
title: Elixir Zen スタイル講座〜復習編
tags:
  - Elixir
private: false
updated_at: '2019-09-20T12:23:57+09:00'
id: 3d4cb94ed1f6f4d682ad
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
とりあえず仮に貼っておく。詳細な解説やコード例を後で書く。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">Elixir Zen スタイル講座。久しぶりなので，復習からしますかね。次のようなプログラムを作成してみてください。<br><br>1. 整数のリストを適当に用意します。例えば 1 から 10 までの整数<br>2. そのリストの各要素を2倍して，さらに各要素に1加えてください<br>3. リストの各要素の合計を算出してください</p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174503858166304768?ref_src=twsrc%5Etfw">2019年9月19日</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script> 

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">正解です。 <a href="https://t.co/42OPDguXQ4">https://t.co/42OPDguXQ4</a></p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174513681201164288?ref_src=twsrc%5Etfw">September 19, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">別解ですが，次のようにもできます。<br><br>1..10 |&gt; Enum.map(&amp; &amp;1 * 2) |&gt; Enum.map(&amp; &amp;1 + 1) |&gt; Enum.sum()<br><br>1. このように Enum.map を1つの処理ずつ分割することもできます。<br>2. 総和に関しては Enum.sum という便利関数があります。</p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174514234178162689?ref_src=twsrc%5Etfw">September 19, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">Pelemay では，1..10 |&gt; Enum.map(&amp; &amp;1 * 2) |&gt; Enum.map(&amp; &amp;1 + 1) のような数珠つなぎの呼出しを，1回のEnum.mapに変換することで最適化する，map-mapフュージョンの早期リリースを予定しています。</p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174515335673729024?ref_src=twsrc%5Etfw">September 19, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">現在，Pelemay はまだ仮リリースの状態で，みなさんの書いたプログラムに mix deps.get で組込んで自由に使えるようにするために，日夜研究開発に勤しんでいます。そのPRはこちらです。<a href="https://t.co/TbuKqA09F8">https://t.co/TbuKqA09F8</a></p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174515827527127040?ref_src=twsrc%5Etfw">September 19, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">こちらのPRで議論しているように，国内外の方々からの献身的な協力によって研究開発が進んでいます。ありがたいことです。<a href="https://t.co/TbuKqA09F8">https://t.co/TbuKqA09F8</a></p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174516036021784576?ref_src=twsrc%5Etfw">September 19, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">これももちろん正解です。Enum.map で分けるか分けないかですが，パフォーマンス上は分けない方が高速です。またこの程度の問題ならば分けない正しい解を思いつくでしょうから，積極的に分ける理由は無いでしょう。 <a href="https://t.co/8vWyO5RzzZ">https://t.co/8vWyO5RzzZ</a></p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174769881192861696?ref_src=twsrc%5Etfw">September 19, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">しかし，一般には異なってきます。分けた方が読みやすく保守しやすい場合もあるでしょうし，そもそも複雑すぎて分けて考えないと思いつかない場合もあるでしょう。またPelemayが実用になれば処理系が良い感じで勝手に結合してくれるようになります。<br>要は読みやすさ優先でいきましょう。</p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174770628735336448?ref_src=twsrc%5Etfw">September 19, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">これももちろん正解です。<a href="https://t.co/GfdYKnkfmY">https://t.co/GfdYKnkfmY</a> で分けるか分けないかですが，パフォーマンス上は分けない方が高速です。またこの程度の問題ならば分けない正しい解を思いつくでしょうから，積極的に分ける理由は無いでしょう。 <a href="https://t.co/8vWyO5RzzZ">https://t.co/8vWyO5RzzZ</a></p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174769881192861696?ref_src=twsrc%5Etfw">September 19, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
