---
title: ZEAM開発ログ v.0.3.0 Elixir から GPU を駆動するベンチマークをいろいろアップグレードしてみた
tags:
  - Rust
  - Elixir
  - GPU
private: false
updated_at: '2018-09-29T09:02:10+09:00'
id: a4faa210b05cbd1ab8ab
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
（この記事は[「fukuoka.ex x ザキ研 Advent Calendar 2017」](https://adventar.org/calendars/2873)の25日目です)

昨日は @zumin さんの[「RubyMineにElixir Pluginを導入してみた」](https://qiita.com/zumin/items/78fcd7d53dc4dc92a077)でした。

[「ZEAM開発ログ 目次」はこちら](https://qiita.com/zacky1972/items/70593ab2b70d192813df)

# はじめに

今週からまたGPU駆動の話に戻ります。

さて，今回は @twinbee さんの [「Elixir-NIF-Rustボイラープレート Ruster0.17.1の注意点」](https://qiita.com/twinbee/items/e005939c1bab53e60f6e) にもありますように，Elixir / Rust 関係で下記のようなアップデートがありましたので，追従してみたいと思います。

* Elixir 1.6.6 (compiled with OTP 21)
* Rust 1.27.0
* Flow 0.14.0
* Rustler 0.17.1

なお，ocl はバージョン変わらず 0.18 です。

# Rustler 0.17.1 へのアップグレード

@twinbee さんの [「Elixir-NIF-Rustボイラープレート Ruster0.17.1の注意点」](https://qiita.com/twinbee/items/e005939c1bab53e60f6e) にもありますが，`Nif*`というプレフィックスがほとんどなくなりました。

* Rename NifEncoder/NifDecoder to Encoder/Decoder
* Rename NifTerm to Term
* Rename NifEnv to Env
* Rename NifError to Error
* Rename NifAtom to Atom
* Rename NifBinary to Binary
* Rename NifPid to Pid
* Rename NifListIterator to ListIterator
* Rename NifMapIterator to MapIterator

一部は `Nif` プレフィックスは残っていますので，注意しましょう。私が使った中では `NifResult` だけは残っています。
過去に紹介した下記の記事は，現状ではすべて Nif プレフィックスがついていますのでご注意ください。そのうち更新しようとは思っています。
|> [ZEAM開発ログv0.1.5 Elixir から Rustler でネイティブコードベンチマークを呼び出してみよう〜ElixirでAI/MLを高速化](https://qiita.com/zacky1972/items/95d898c5b44fd6f243ee)
|> [ZEAM開発ログv0.1.6 Elixir から Rustler で GPU を駆動しよう〜ElixirでAI/MLを高速化](https://qiita.com/zacky1972/items/c998cad40ff9f2a42fde)
|> [ZEAM開発ログv0.1.6.1 Elixir / Rustler 小ネタ集〜 Rustler でリストからバイナリに変換](https://qiita.com/zacky1972/items/cab329e03f9fae6c7404)

この更新はそれほど難しくありません。バージョンアップしたあと，エラーメッセージに従って淡々と修正するのみです。ただし，バージョンアップする際に，mix.exs と native/logistic_map/Cargo.toml の2箇所を修正する必要がある点にご注意ください。私は最初 mix.exs だけ修正していたので，コンパイル結果が変わらずに不審に思っていました。

修正したコードは下記の通りです(主要部分を抜き出しました)。

native/logistic_map/src/lib.rs 

```rust
#[macro_use] extern crate rustler;
#[macro_use] extern crate lazy_static;

extern crate ocl;

use rustler::{Env, Term, NifResult, Encoder, Error};
use rustler::types::list::ListIterator;
use rustler::types::binary::Binary;

use ocl::{ProQue, Buffer, MemFlags};

rustler_export_nifs! {
    "Elixir.LogisticMapNif",
    [("map_calc_list", 4, map_calc_list),
     ("call_ocl", 3, call_ocl)],
    None
}

fn loop_calc(num: i64, init: i64, p: i64, mu: i64) -> i64 {
    let mut x: i64 = init;
    for _i in 0..num {
        x = mu * x * (x + 1) % p;
    }
    x
}

fn map_calc_list<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let iter: ListIterator = try!(args[0].decode());
    let num: i64 = try!(args[1].decode());
    let p: i64 = try!(args[2].decode());
    let mu: i64 = try!(args[3].decode());

    let res: Result<Vec<i64>, Error> = iter
        .map(|x| x.decode::<i64>())
        .collect();

    match res {
        Ok(result) => Ok(result.iter().map(|&x| loop_calc(num, x, p, mu)).collect::<Vec<i64>>().encode(env)),
        Err(err) => Err(err),
    }
}

fn trivial(x: Vec<i64>, p: i64, mu: i64) -> ocl::Result<(Vec<i64>)> {
    let src = r#"
        __kernel void calc(__global long* input, __global long* output, long p, long mu) {
            size_t i = get_global_id(0);
            long x = input[i];
            x = mu * x * (x + 1) % p;
            x = mu * x * (x + 1) % p;
            x = mu * x * (x + 1) % p;
            x = mu * x * (x + 1) % p;
            x = mu * x * (x + 1) % p;
            x = mu * x * (x + 1) % p;
            x = mu * x * (x + 1) % p;
            x = mu * x * (x + 1) % p;
            x = mu * x * (x + 1) % p;
            x = mu * x * (x + 1) % p;
            output[i] = x;
        }
    "#;

    let pro_que = ProQue::builder()
        .src(src)
        .dims(x.len())
        .build().expect("Build ProQue");

    let source_buffer = Buffer::builder()
        .queue(pro_que.queue().clone())
        .flags(MemFlags::new().read_write())
        .len(x.len())
        .copy_host_slice(&x)
        .build()?;

    let result_buffer: Buffer<i64> = Buffer::builder()
        .queue(pro_que.queue().clone())
        .flags(MemFlags::new().read_write())
        .len(x.len())
        .build()?;

    let kernel = pro_que.kernel_builder("calc")
        .arg(&source_buffer)
        .arg(&result_buffer)
        .arg(p)
        .arg(mu)
        .build()?;

    unsafe { kernel.enq()?; }

    let mut vec_result = vec![0; result_buffer.len()];
    result_buffer.read(&mut vec_result).enq()?;
    Ok(vec_result)
}

fn call_ocl<'a>(env: Env<'a>, args: &[Term<'a>]) -> NifResult<Term<'a>> {
    let iter: ListIterator = try!(args[0].decode());
    let p: i64 = try!(args[1].decode());
    let mu: i64 = try!(args[2].decode());

    let res: Result<Vec<i64>, Error> = iter
        .map(|x| x.decode::<i64>())
        .collect();

    match res {
        Ok(result) => {
            let r1: ocl::Result<(Vec<i64>)> = trivial(result, p, mu);
            match r1 {
               Ok(r2) => Ok(r2.encode(env)),
               Err(_) => Err(Error::BadArg),
            }
        },
        Err(err) => Err(err),
    }
}
```

あ，`trivial` っていう関数名，変えたいな。。。あとで変えよう。

# Flow 0.14.0 へのアップグレード

次は Flow 0.14.0 による変更点です。[Flow の GitHub 上の CHANGELOG](https://github.com/elixir-lang/flow/blob/master/CHANGELOG.md) くらいしか情報がなく，とても難儀しました。

具体的には，Window で指定する `:reset` と `map_state` が廃止されて，代わりに `on_trigger` で調整するという感じです。

今回影響を受けるのは，`benchmarks8`で使用している `mapCalc8` です。

lib/logistic_map.ex

Flow 0.13.0 までのコード

```elixir
  def mapCalc8(list, num, p, mu, stages) when stages > 1 do
    window = Flow.Window.global
    |> Flow.Window.trigger_every(LogisticMapNif.get_env("LogisticMapNif_map_calc_list"), :reset)

    list
    |> Flow.from_enumerable
    |> Flow.partition(window: window, stages: stages)
    |> Flow.reduce(fn -> [] end, fn e, acc -> [e | acc] end)
    |> Flow.map_state(& &1 |> LogisticMapNif.map_calc_list(num, p, mu))
    |> Flow.emit(:state)
    |> Enum.to_list
  end
```

Flow 0.14.0 のコード

```elixir
  def mapCalc8(list, num, p, mu, stages) when stages > 1 do
    window = Flow.Window.global
    |> Flow.Window.trigger_every(LogisticMapNif.get_env("LogisticMapNif_map_calc_list"))

    list
    |> Flow.from_enumerable
    |> Flow.partition(window: window, stages: stages)
    |> Flow.reduce(fn -> [] end, fn e, acc -> [e | acc] end)
    |> Flow.on_trigger(fn acc -> {(acc |> LogisticMapNif.map_calc_list(num, p, mu)), []} end)
    |> Enum.to_list
  end
```

違いは3箇所。

(1) `Flow.Window.trigger_every` から `:reset` を取り除く

```elixir
    |> Flow.Window.trigger_every(LogisticMapNif.get_env("LogisticMapNif_map_calc_list"), :reset)
```

```elixir
    |> Flow.Window.trigger_every(LogisticMapNif.get_env("LogisticMapNif_map_calc_list"))
```

(2) `Flow.map_state` を `Flow.on_trigger` に置き換えて，`:reset` の場合の書き方にする

```elixir
    |> Flow.map_state(& &1 |> LogisticMapNif.map_calc_list(num, p, mu))
```

```elixir
    |> Flow.on_trigger(fn acc -> {(acc |> LogisticMapNif.map_calc_list(num, p, mu)), []} end)
```

(3) `Flow.emit` を取り除く

```elixir
    |> Flow.emit(:state)
```

とくに困ったのが，(3)がわからなかったことです。`Flow.emit`を書いたままにすると謎の実行時エラーに見舞われるのですが，この対処方法が探せど探せど見つからない。困った挙句，先頭から1行1行実行を確かめながら対応しました。

# Elixir 1.6.6 (compiled with OTP 21) へのアップグレード

この機会に Elixir と Erlang の両方をバージョン切り替えできるようにセットアップしなおしました。

Elixir 1.6.6 (compiled with OTP 21) をインストールする手順は次の通りです。

## Erlang を erlenv でインストールする

すでに Erlang を `brew` 等でインストールしていた場合には一度アンインストールしましょう。(`erlenv` でインストールしていた場合を除く)

その後，次のコマンドを順に実行します。

```bash
$ cd
$ git clone https://github.com/talentdeficit/erlenv.git .erlenv
```

ここで ~/.bash_profile に次の記述を加えます。

```bash
export PATH=$HOME/.erlenv/bin:/usr/local/opt/openssl/bin:$PATH
eval "$(erlenv init -)"
```

それから次のように Erlang をインストールします。(Intel Mac の場合)

```bash
$ brew install openssl
$ curl -O http://erlang.org/download/otp_src_21.0.tar.gz
$ tar zxf otp_src_21.0.tar.gz 
$ cd otp_src_21.0
$ ./configure --prefix=$HOME/.erlenv/releases/21.0 --enable-smp-support --enable-threads --enable-darwin-64bit --enable-kernel-poll --enable-hipe --without-javac --with-ssl=/usr/local/opt/openssl 
$ touch lib/wx/SKIP lib/odbc/SKIP
$ make
$ sudo make install
$ erlenv global 21.0
$ erlenv rehash
```

これでインストールできたはずです。`erl`を実行して下記のように表示されれば成功です。

```bash
$ erl 
Erlang/OTP 21 [erts-10.0] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]

Eshell V10.0  (abort with ^G)
1> 
```

ここで CTRL+C を押し，`a` キーを押して抜け出ます。

チェックポイントは，次の通りです。

* OTP 21 と表示されているか
* `64-bit` になっているか
* SMP環境だった時に `[smp:*:*]` となっているか
* `[hipe]` がついているか

もしこれらが異なっていたら，`configure` で正しく指定されていないか，ハードウェア的にサポートされていないかだと思います。

## Elixir を `exenv` でインストールする

次に Elixir をインストールします。これも `brew` 等ですでにインストールされていたらアンインストールします。(`exenv` でインストールしていた場合を除く)

```bash
$ brew install elixir-build exenv
$ exenv install -l
$ exenv install 1.6.6
$ exenv global 1.6.6
```

次のコマンドを実行して次のように表示されれば成功です。

```bash
$ elixir -v
Elixir 1.6.6 (compiled with OTP 21)
```

ベンチマークのソースコードの変更点はありません。

# Rust 1.27.0 へのアップグレード

`rustup` を使っている場合には次のコマンドだけで最新版がインストールされます。超簡単ですね。

```bash
$ rustup update
```

# ベンチマーク結果

さてバージョンアップで性能は向上するんでしょうか？ 気になるベンチマーク結果は...

|stages|benchmarks1|benchmarks3|benchmarks5|benchmarks8|benchmarks9|benchmarks_empty|C  |Rust CPU|Rust OpenCL|Python|
|-----:|----------:|----------:|----------:|----------:|---------:|----------------:|--:|-------:|----------:|-----:|
|      |pure Elixir|pure Elixir|Elixir/Rustler|Elixir/Rustler|Elixir/Rustler|Elixir/Rustler|clang|Rust|Rust|Python|
|      |loop       |inlining inside of Flow.map|loop, passing by list|passing by list, with Window|OpenCL(GPU), inlining|Ruslter empty|CPU, loop|CPU, loop|OpenCL(GPU), inlining|NumPy, CPU|
|     1|53.223249→47.472903|44.075415→37.091920|12.042998→10.768412| 9.702550→9.487438|6.571943→6.879992|6.027101→4.520966|2.727346|2.720996→2.931215|1.857096→1.561099|17.749182|
|     2|26.474494→22.943836|20.632323→19.870662|36.622580→32.880617|17.419324→24.325771|
|     4|15.186692→13.509106|13.497807→13.612359|36.566198→35.468315|16.233323→18.880198|
|     8|12.796444→12.146374|11.570678→14.655723|36.226341→35.201705|15.953845→17.437002|
|    16|12.962736→12.180955|11.607420→10.867108|36.405342→35.324410|16.846778→19.406703|
|    32|12.988720→12.366302|11.488179→11.144992|39.785561→38.734335|19.186600→22.267963|
|    64|13.288242→12.297703|11.561640→13.347286|39.646524→39.217209|24.126142→28.936603|
|   128|13.214251→12.196510|12.116703→11.158467|40.206917→39.528575|35.373501→38.189437|

Rustler のベンチマークを中心に若干スピードが向上しているようにも思います。が，誤差の範囲かもしれません。バージョンアップによる速度向上は気持ち速くなったかなくらいのようです。

# まとめ

バージョンアップにより次のような変更点があります。

* Rustler 0.17.1 へのアップグレードにより，`Nif`プレフィックスがほとんど不要になりました。`NifResult` だけは依然として必要です。
* Flow 0.14.0 へのアップグレードにより，Window で指定する `:reset` と `map_state` が廃止されて，代わりに `on_trigger` で調整するようになりました。
* バージョンアップによる速度向上はほとんどないか，あったとして気持ち速くなったかぐらいです。

次回は新しい Rustler の機能を使って，ベンチマーク高速化の試みをやってみましょう。お楽しみに！

明日は @takasehideki さんの「ElixirでIoT#1.3.3：logistic_mapをIoTボードで性能評価してみた」です。こちらもお楽しみに！

# p.s.「いいね」よろしくお願いします

よろしければ，ページ左上の ![image.png](https://qiita-image-store.s3.amazonaws.com/0/155423/4d515047-cc48-382e-c2b1-3ad0cc50dbbf.png) や ![image.png](https://qiita-image-store.s3.amazonaws.com/0/155423/a4e3da58-70a3-4197-95a2-6a6906650d01.png) のクリックをお願いしますー:bow:
ここの数字が増えると，書き手としては「ウケている」という感覚が得られ，連載を更に進化させていくモチベーションになりますので，もっとElixirネタを見たいというあなた，私たちと一緒に盛り上げてください！:tada:
