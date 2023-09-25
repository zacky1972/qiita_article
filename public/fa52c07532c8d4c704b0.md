---
title: '堅牢なNIFの書き方: パフォーマンスの高いフォールト・トレラント・システムのためのElixirとCの併用〜その2 慣習に従ったエラー処理を書く'
tags:
  - C
  - Elixir
private: false
updated_at: '2023-04-16T20:06:42+09:00'
id: fa52c07532c8d4c704b0
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[「Elixir Advent Calendar 2022」](https://qiita.com/advent-calendar/2022/elixir)1日目の記事です．また，この内容の講演がElixirConf EU 2023にacceptされました．

https://www.elixirconf.eu/talks/how-to-describe-robust-nifs/

パフォーマンスを必要とするシステムを実装する場合，Elixir からよりパフォーマンスの高い C コードを呼び出すメカニズムである NIF を使用することがあります．NIF は，C を呼び出すもう 1 つのメカニズムである Port よりも優れたパフォーマンスを発揮します．ただし，NIF がクラッシュすると，Supervisor の制御下であっても，Erlang VM 全体が異常終了するという欠点があります．この欠陥は，フォールト・トレラント・システムを構築する際の大きな障害となります．

1つ目のポイントを[その1](https://qiita.com/zacky1972/items/b1cbac9a4f31cd60800a) https://qiita.com/zacky1972/items/b1cbac9a4f31cd60800a で示しました．

この記事では，堅牢な NIF を説明する2つ目のポイントを示します．

* **一般的な慣習に従ってエラー処理を実行します．**

ここでいう「一般的な慣習」というのは[Elixir Schoolのエラーハンドリング](https://elixirschool.com/ja/lessons/intermediate/error_handling#一般的な規則-0)での説明に準拠します．すなわち次のようなルールです．

* 正常終了した時には `{:ok, result}`のような形式にする．ここで`result`には結果の値が入ります．
* 通常操作の一環でエラーを返す場合には `{:error, reason}`のような形式にする．ここで`reason`にはエラー理由がアトムや文字列などで入ります．
* 通常操作とは認められないようなエラーを返す場合には，例外をスローします．

NIFもこの一般的な慣習に従うべきだと言えます．

# `{:ok, result}`を返す場合のプログラム例

```c
  ERL_NIF_TERM result;
  result = ...;
  return enif_make_tuple2(env, enif_make_atom(env, "ok"), result);
```

# `{:error, reason}`を返す場合のプログラム例

```c
  ERL_NIF_TERM reason = enif_make_string(env, "reason", ERL_NIF_LATIN1);
  return enif_make_tuple2(env, enif_make_atom(env, "error"), reason);
```

* `"reason"` の箇所に実際のエラーメッセージを入れます．
* Elixir側では`{:error, reason}`の形で受け取れはするのですが，`reason`にはErlangの文字列(CharList `~c'reason'`)の形式で入っている点に注意してください．
* Elixirの文字列を渡すこともできなくはないのですが，少々煩雑なCコードになるので，Elixirの側で適切に処理することをお勧めします．

# 例外をスローする場合

## ArgumentErrorを返す場合

```c
  return enif_make_badarg(env);
```

* Elixir側では`ArgumentError`がスローされることになります．

```elixir
** (ArgumentError) argument error
```

## エラーメッセージ`reason`をつけて返す場合

```c
  ERL_NIF_TERM reason = enif_make_string(env, "reason", ERL_NIF_LATIN1);
  return enif_raise_exception(env, reason);
```

* `"reason"`には実際のエラー理由を入れます．
* Elixir側では`ErlangError`がスローされることになります．

```elixir
** (ErlangError) Erlang error: 'reason'
```

* `reason`にはErlangの文字列(CharList `~c'reason'`)の形式で入っている点に注意してください．
* Elixirの文字列を渡すこともできなくはないのですが，少々煩雑なCコードになるので，次のような感じでElixirの側で適切に処理することをお勧めします．(前述の`ArgumentError`を先に処理する点に注意してください)

```elixir
  try do
    case NifModule.nif_func() do # NIF関数の呼び出しを入れます
      {:ok, result} -> {:ok, result}
      {:error, reason} -> {:error, List.to_string(reason)}
    end 
  rescue
    e in ArgumentError -> raise e
    e in ErlangError -> raise ErlangError, message: List.to_string(e.original)
  end
```

いかがだったでしょうか？ [ではその3に続きます．](https://qiita.com/zacky1972/items/23736bc430286b29f3c5)
https://qiita.com/zacky1972/items/23736bc430286b29f3c5



















