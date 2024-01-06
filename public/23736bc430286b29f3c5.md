---
title: '堅牢なNIFの書き方: パフォーマンスの高いフォールト・トレラント・システムのためのElixirとCの併用〜その3アサーションを積極的に書く'
tags:
  - C
  - Elixir
private: false
updated_at: '2023-01-12T11:23:11+09:00'
id: 23736bc430286b29f3c5
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[「Elixir Advent Calendar 2022」](https://qiita.com/advent-calendar/2022/elixir)2日目の記事です．また，この内容の講演がElixirConf EU 2023にacceptされました．

https://www.elixirconf.eu/talks/how-to-describe-robust-nifs/

パフォーマンスを必要とするシステムを実装する場合，Elixir からよりパフォーマンスの高い C コードを呼び出すメカニズムである NIF を使用することがあります．NIF は，C を呼び出すもう 1 つのメカニズムである Port よりも優れたパフォーマンスを発揮します．ただし，NIF がクラッシュすると，Supervisor の制御下であっても，Erlang VM 全体が異常終了するという欠点があります．この欠陥は，フォールト・トレラント・システムを構築する際の大きな障害となります．

[1つ目のポイント](https://qiita.com/zacky1972/items/b1cbac9a4f31cd60800a)をhttps://qiita.com/zacky1972/items/b1cbac9a4f31cd60800a に
[2つ目のポイント](https://qiita.com/zacky1972/items/fa52c07532c8d4c704b0)をhttps://qiita.com/zacky1972/items/fa52c07532c8d4c704b0 に示しました．


この記事では，堅牢な NIF を説明する 3 つ目のポイントを示します．

* **暗黙の前提条件を指定するアサーションを作成し， `Supervisor` が処理する例外を発生させます．**

アサーション(表明)というのはご存知ですか？ たとえばCだと次のようなプログラムがあったとします．

```c:mysqrt.c
#include <math.h>
#include <assert.h>

double mysqrt(double a)
{
  assert(a >= 0);
  return sqrt(a);
}
```

引数`a`に負の値を与えると，次のように異常終了(abort)します．

```
Assertion failed: (a >= 0), function mysqrt, file mysqrt.c, line 6.
zsh: abort      ./a.out
```

アサーションを用いることで，意図しない入力を与えたり，意図しない出力結果が得られたりした時に，プログラムを強制停止することができます．このような入力や出力によって，破滅的な結果を招くことを予防することになります．

Cの場合にはアサーションによって異常終了するのみですが，Elixirの場合には `Supervisor` を用いることで，アサーションによって意図しない入出力を強制停止した後で，プロセスを再起動して再び入力を受け付けられるようにすることができます．Elixirにはこの `Supervisor` が存在することで，アサーションをより実用的に積極的に使うことができます．

NIFの場合には，`assert.h`を用いる代わりに，アサーションで表明する条件で分岐した後，条件に反する場合にはその2に書いた例外を発生させる方法で強制停止させます．たとえば次のようにします．

```c
#include <math.h>
#include <erl_nif.h>

static ERL_NIF_TERM mysqrt(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }

  double a;
  if(!enif_get_double(env, argv[0], &a)) {
    return enif_make_badarg(env);
  }
  
  // assert(a >= 0);
  if(!(a >= 0)) {
    ERL_NIF_TERM reason = enif_make_string(env, "Assertion failed: (a >= 0), function mysqrt", ERL_NIF_LATIN1);
    return enif_raise_exception(env, reason);
  }
  
  return enif_make_double(env, sqrt(a));
}

static ErlNifFunc nif_funcs[] =
{
    {"mysqrt", 1, mysqrt}
};

ERL_NIF_INIT(Elixir.MySqrt, nif_funcs, NULL, NULL, NULL, NULL)
```

いかがだったでしょうか？ 些細なことでも質問があれば，遠慮なくコメントしてください！
