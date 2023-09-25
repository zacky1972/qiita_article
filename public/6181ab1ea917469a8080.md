---
title: 'Elixir Zen スタイル講座: ループを Enum.reduce/3 で表す方法'
tags:
  - Elixir
private: false
updated_at: '2019-12-03T09:21:52+09:00'
id: 6181ab1ea917469a8080
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は [「Elixir Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/elixir) 2日目の記事です。

いよいよ今年もアドベントカレンダーの季節が始まりました！

昨日は @mocamocaland さんの[「構築したSerumでリンク先の追加と記事投稿をする方法」](https://qiita.com/mocamocaland/items/e4a4d4f00b7416513429)でした。

今日は Elixir Zen スタイル講座ということで，ループを `Enum.reduce/3` で表す方法についてご紹介します。

# 例題

C言語で書かれた次のようなループ構造を Enum.reduce/3 を使って Elixir にする方法について説明します。

```c
int loop_sample(int a[], int a_n) {
	int r1 = 0, r2 = 0;
	for(int i = 0; i < a_n; i++) {
		r1 = (r1 < a[i]) ? a[i] : r1;
		r2 += r1;
	}
	return r2;
}
```

説明を簡単にするため，if文ではなく，条件演算子を使って書いています。

解答例は次の通りです。

```elixir
defmodule ReduceSample do
  def loop_sample(a) do
    {_, r2} =
      Enum.reduce(
        a,
        {0, 0},
        fn x, {r1, r2} ->
          {
            max(x, r1),
            r2 + max(x, r1)
          }
        end
      )

    r2
  end
end
```

対応関係をコメントで書いてみます。

```elixir
defmodule ReduceSample do
  def loop_sample(a) do
    {_, r2} =
      Enum.reduce(
        a,
        {0, 0},             # int r1 = 0, r2 = 0;
        fn x, {r1, r2} ->
          {
            max(x, r1),     # r1 = (r1 < a[i]) ? a[i] : r1;
            r2 + max(x, r1) # r2 += r1; // C言語の r1 は更新後
          }
        end
      )

    r2                      # return r2;
  end
end
```

# 基本的な考え方

1. ループへの入力となるリストを Enum.reduce/3 の第1引数に与えます。
2. ループ内に登場する変数を記憶するために，変数と同じ数の要素を持つタプルを用意します。
3. 各変数の初期値をタプルにして Enum.reduce/3 の第2引数に与えます。
4. Enum.reduce/3 の第3引数の関数を次のように定義します。
	1. 第1引数をリストの各要素を表す `x` とします。
	2. 第2引数を，ループ内に登場する変数を表すタプルにします。
	3. 戻り値は，各変数を更新する式をタプルにして表します。
		* ただし，ループの中で更新された他の変数値を使用する場合は，その変数を更新する数式を展開しておきます。

# 制約条件

* リストがループの前後で不変である必要があります。
* 各イテレーションで複数の要素を参照しない場合のみ可能です。
* 各イテレーションで副作用がない場合のみ可能です。

# 次回予告

次は明日[「言語実装 Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/lang_dev)3日目に投稿予定です。[「Elixir / Pelemay 研究の背景と意義」](https://qiita.com/zacky1972/items/a3dedc0cdacbeed21b6d)です。よろしくお願いします。

明日の[「Elixir Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/elixir)は @torifukukaiou さんの[「12月3日なので、一二三、123ダーなElixirのこと」](https://qiita.com/torifukukaiou/items/8c37f9710e45b50b6aba#_reference-6fb2c85acda96988b720)です。こちらもよろしくお願いします。
