---
title: '堅牢なNIFの書き方: パフォーマンスの高いフォールト・トレラント・システムのためのElixirとCの併用〜その1 関数呼び出しそれぞれに条件分岐を設ける'
tags:
  - C
  - Elixir
private: false
updated_at: '2023-01-12T11:22:28+09:00'
id: b1cbac9a4f31cd60800a
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[「Elixir Advent Calendar 2022」](https://qiita.com/advent-calendar/2022/elixir)1日目の記事です．また，この内容の講演がElixirConf EU 2023にacceptされました．

https://www.elixirconf.eu/talks/how-to-describe-robust-nifs/


パフォーマンスを必要とするシステムを実装する場合，Elixir からよりパフォーマンスの高い C コードを呼び出すメカニズムである NIF を使用することがあります．NIF は，C を呼び出すもう 1 つのメカニズムである Port よりも優れたパフォーマンスを発揮します．ただし，NIF がクラッシュすると，Supervisor の制御下であっても，Erlang VM 全体が異常終了するという欠点があります．この欠陥は，フォールト・トレラント・システムを構築する際の大きな障害となります．

この記事では，堅牢な NIF を説明する1つ目のポイントを示します．

* **不確実な値を返す可能性がある関数呼び出しそれぞれに対し条件分岐を適切に設定します．**

では，具体例を示していきましょう．

関数`foo`を呼び出した時，正常終了した時には戻り値としてポインタが返ってくるが，失敗した時には`NULL`ポインタが返ってくる場合を考えます．さらに`foo`の戻り値を使って別の関数`bar`を呼び出すようなシチュエーションを考えます．

安直には次のようにプログラミングしたくなるかもしれません．

```c
  v = bar(foo(a, b, c));
```

しかし，もし`bar`に`NULL`ポインタを与えた時にセグメンテーション・フォールトを発生することもありえます．この時には，たとえElixirがSupervisorを設定していたとしても，NIFがセグメンテーション・フォールトで異常終了することでElixirのVMごと落としてしまいます．

そこで，次のようにプログラミングすべきです．

```c
  w = foo(a, b, c);
  if(w == NULL) {
    // 異常終了した旨をElixirに通知する．例えば次のようなコード
    return enif_make_badarg(env);
  }
  v = bar(w);
```

関数`enif_make_badarg`については https://www.erlang.org/doc/man/erl_nif.html#enif_make_badarg をご覧ください．一般に引数が不正だった旨の例外を発生させるための関数です．

このようなことを一般化すると次のようになるというわけです．

* **不確実な値を返す可能性がある関数呼び出しそれぞれに対し条件分岐を適切に設定します．**

いかがだったでしょうか？ [ではその2に続きます．](https://qiita.com/zacky1972/items/fa52c07532c8d4c704b0) https://qiita.com/zacky1972/items/fa52c07532c8d4c704b0




















