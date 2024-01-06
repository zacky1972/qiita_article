---
title: Elixir Zen スタイル バイナリ＋パターンマッチでバイナリデコーダを作ってみよう！
tags:
  - Elixir
private: false
updated_at: '2019-09-20T12:36:54+09:00'
id: 6548eef0bc52e65549ec
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">Elixir Zen スタイル講座，お次はバイナリデコーダを作ってみましょう。バイナリデコーダって何？って話なんですが，具体例としてはCPUエミュレータとかバイトコードインタプリタ，ELFバイナリのダンプ，MIDIシーケンサなど，あるビット列に合致するかどうかで条件分岐するようなプログラムです。</p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174887899986182144?ref_src=twsrc%5Etfw">September 20, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">このようなバイナリデコーダは，Elixir ではバイナリとパターンマッチの組合せで，とても見通し良く書くことができます。ではやっていきます。</p>&mdash; Susumu Yamazaki (@zacky1972) <a href="https://twitter.com/zacky1972/status/1174888218690379776?ref_src=twsrc%5Etfw">September 20, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

ではコード例をご紹介。MIDIシーケンサーの一部を書いてみました。

```elixir
defmodule MidiDecoder do
  def decode(<<>>), do: []

  def decode(<<
  	8::size(4),
  	channel::bitstring-size(4),
  	velocity::bitstring-size(8),
  	rest::bitstring()
  >>) do
  	[{:note_off, channel, velocity}] ++ decode(rest)
  end

  def decode(<<
  	9::size(4),
  	channel::bitstring-size(4),
  	velocity::bitstring-size(8),
  	rest::bitstring()
  >>) do
  	[{:note_on, channel, velocity}] ++ decode(rest)
  end
  …
end
```

まず

```elixir
def decode(<<>>), do: []
```

これは再帰呼び出しを止めるために存在します。

次に

```elixir
  def decode(<<
  	8::size(4),
  	channel::bitstring-size(4),
  	velocity::bitstring-size(8),
  	rest::bitstring()
  >>) do
  	[{:note_off, channel, velocity}] ++ decode(rest)
  end
```

コメントで注釈を入れていきますね。

```elixir
  def decode(<<
  	8::size(4),                   # 4ビット取り出して値が8である場合
  	channel::bitstring-size(4),   # 次の4ビットは channel に割り当てます
  	velocity::bitstring-size(8),  # その次の8ビットは velocity に割り当てます
  	rest::bitstring()             # 残りです。
  >>) do
  	[{:note_off, channel, velocity}] ++ decode(rest)  # ノートオフを読み出せました
  end
```

では同様にこちらも読み解いてみましょう。

```elixir
  def decode(<<
  	9::size(4),
  	channel::bitstring-size(4),
  	velocity::bitstring-size(8),
  	rest::bitstring()
  >>) do
  	[{:note_on, channel, velocity}] ++ decode(rest)
  end
```

わかりました？

こんな感じで，バイナリ列にマッチするような条件分岐をスマートに書くことができます！

これを Elixir Zen スタイルの新しい仲間に加えたいと思います。

