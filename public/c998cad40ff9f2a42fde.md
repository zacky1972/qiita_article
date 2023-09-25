---
title: ZEAM開発ログv0.1.6 Elixir から Rustler で GPU を駆動しよう〜ElixirでAI/MLを高速化
tags:
  - Rust
  - Elixir
  - GPU
private: false
updated_at: '2018-09-29T08:59:32+09:00'
id: c998cad40ff9f2a42fde
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
（この記事は、[「fukuoka.ex(その2) Elixir Advent Calendar 2017」](https://adventar.org/calendars/2871)の12日目，[「機械学習と数学 Advent Calendar 2017](https://qiita.com/advent-calendar/2017/ml_and_math2017)の6日目です)

昨日は @twinbee さんの[「Elixirから簡単にRustを呼び出せるRustler #4 SHIFT-JIS変換を行う」](https://qiita.com/twinbee/items/75415203e44daee16fcc)でしたね。

[「ZEAM開発ログ 目次」はこちら](https://qiita.com/zacky1972/items/70593ab2b70d192813df)

# おしらせ

*お礼：各種ランキングに69回のランクインを達成しました*

4/27から、30日間に渡り、毎日お届けしている[「季節外れのfukuoka.ex Elixir Advent Calendar」](https://qiita.com/advent-calendar/2017/elixir-or-phoenix)と[「季節外れのfukuoka.ex(その2) Elixir Advent Calender」](https://adventar.org/calendars/2871)ですが、[Qiitaトップページトレンドランキング](https://qiita.com/trend)に8回入賞、[Elixirウィークリーランキング](https://qiita.com/tags/elixir)では5週連続で１／２／３フィニッシュを飾り、各種ランキング通算で、<font color="red"><b>トータル69回ものランクイン</b></font>（前週比+60.1%）を達成しています

みなさまの暖かい応援に励まされ、<font color="red"><b>合計452件ものQiita「いいね」</b></font>（前週差+103件）もいただき、fukuoka.exアドバイザーズとfukuoka.exキャストの一同、ますます季節外れのfukuoka.ex Advent Calendar、頑張っていきます

[![image.png](https://qiita-image-store.s3.amazonaws.com/0/155423/bbe9d349-c978-e9e8-ba7d-f8feda74be91.png)](https://adventar.org/calendars/2871)

# さて本題〜はじめに

ElixirでAI/MLを高速化すべく，今回はElixirからGPUを駆動しました。

本連載の前回記事はこちら
|> [ZEAM開発ログv0.1.0 Flow / GenStage による並列プログラミング入門](https://qiita.com/zacky1972/items/e843607881bbeca34b70)
|> [ZEAM開発ログv0.1.1 AI/MLを爆速にしたい！ Flow / GenStage でGPUを駆動できないの？](https://qiita.com/zacky1972/items/140d2380dfdf727b22bc)
|> [ZEAM開発ログv0.1.2 AI/MLを爆速にしたい！ Flow のコードを OpenCL で書いてみる〜CPU編](https://qiita.com/zacky1972/items/c5c43794bd8af75a9800)
|> [ZEAM開発ログv0.1.3 AI/MLを爆速にしたい！ Flow のコードを OpenCL で書いてみる〜GPU編](https://qiita.com/zacky1972/items/05ab840561657da1e154)
|> [ZEAM開発ログv0.1.4 Python/NumPyとElixir/Flow一本勝負！ElixirはAI/ML業界に革命をもたらすか!?](https://qiita.com/zacky1972/items/5e7a31b3ee03bc0d31dd)
|> [ZEAM開発ログv0.1.5 Elixir から Rustler でネイティブコードベンチマークを呼び出してみよう〜ElixirでAI/MLを高速化](https://qiita.com/zacky1972/items/95d898c5b44fd6f243ee)

今までのまとめとしては次の通りです。

1. OpenCLでGPUを利用した時にはC言語の1並列と比べて3.95倍の速度向上，Elixirの同等プログラムと比べて10.8〜11.9倍の速度向上になりました。
2. OpenCLを使わずにマルチコアかつSIMD命令やAVX命令を使った場合は，GPUの場合より高速になる可能性があります。見積もりではElixirの同等プログラムと比べて13倍前後の速度向上を期待できそうです。
3. GPUの場合は，データの転送に時間がかかっているので，データの転送量に比べて演算負荷が大きくなればなるほど，CPUよりGPUの方が有利になると思われます。
4. CPUとGPUで適性を見極めて適切に負荷分散をすること，さらにCPUとGPUを並列実行することで，さらなるパフォーマンスを引き出せる可能性があります。
5. Elixir / Flow は Python / NumPy より1.5倍前後速いです。
6. OpenCL(GPU) は Python / NumPy より17倍前後速いです。
7. 今後，研究・開発が進んだ暁には，PythonからElixirに移行することで，AI/ML処理の実行速度が大幅に向上する可能性があります。
8. Rustler を使っても pure Elixir から高速化できませんでした。
9. Flow は便利ですが，オーバーヘッドがかなりあります。
10. Rustler とC言語やOpenCLと比べるとまだまだ速度差は歴然としています。さらなる高速化に向けてはデータ表現の相互変換をどのように工夫するかが鍵になりそうです。LLVMで直にアセンブリコードを出力したらどうなるか興味があります！

今回はいよいよElixirからRustlerとOpenCL経由でGPUを駆動してみたいと思います。GPU駆動について書いたこれまでの連載の集大成です！

# Rust の最適化

Rust でのコード最適化のやりかたを @tatsuya6502 さんに教わりました！ ありがとうございます。

Cargo.toml に次のような記述を加えます。

```toml
# 最高の性能を得るためにreleaseプロファイルを調整する 
[profile.release]
# 最適化レベル。デフォルトは2
opt-level = 3

# LLVMのcodegenの多重度。デフォルトは16。
# 数字を増やすとコンパイル時間が短くなるが、最適化の機会が減ってしまう。
# 1にするとコンパイル時間が長くなるが、コンパイル後のバイナリでは最高の性能が得られる。
codegen-units = 1
```

また，C言語のプログラムを int64 を使うようにしないとオーバーフローするということだったので，修正しました。

以上を踏まえて全面的にベンチマークを取り直すことにしました。

# Rust から OpenCL を利用するには

[ocl というライブラリがありました。GitHubはこちら](https://github.com/cogciprocate/ocl)

使い方は README や ocl/examples に書かれているコードを読んでください。

# Elixir / Rustler から OpenCL を利用する

[GitHub レポジトリはこちら](https://github.com/zeam-vm/logistic_map)

現状では，OpenCLの有無の判定のしかたがわからなかったので，OpenCL ブランチに push しています。下記のようにしてください。

```bash
$ git clone git@github.com:zeam-vm/logistic_map.git
$ git checkout OpenCL
```

ソースコードはこんな感じです。

native/logistic_map/src/lib.rs の OpenCL 周り

```rust
#[macro_use] extern crate rustler;
#[macro_use] extern crate lazy_static;

extern crate ocl;

use rustler::{NifEnv, NifTerm, NifResult, NifEncoder, NifError};
use rustler::types::list::NifListIterator;
use ocl::{ProQue, Buffer, MemFlags};

rustler_export_nifs! {
    "Elixir.LogisticMapNif",
    [("call_ocl", 3, call_ocl)],
    None
}

fn logistic_map_ocl(x: Vec<i64>, p: i64, mu: i64) -> ocl::Result<(Vec<i64>)> {
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

fn call_ocl<'a>(env: NifEnv<'a>, args: &[NifTerm<'a>]) -> NifResult<NifTerm<'a>> {
    let iter: NifListIterator = try!(args[0].decode());
    let p: i64 = try!(args[1].decode());
    let mu: i64 = try!(args[2].decode());

    let res: Result<Vec<i64>, NifError> = iter
        .map(|x| x.decode::<i64>())
        .collect();

    match res {
        Ok(result) => {
            let r1: ocl::Result<(Vec<i64>)> = logistic_map_ocl(result, p, mu);
            match r1 {
               Ok(r2) => Ok(r2.encode(env)),
               Err(_) => Err(NifError::BadArg),
            }
        },
        Err(err) => Err(err),
    }
}
```

lib/logistic_map_Nif.ex の該当部分

```elixir
defmodule LogisticMapNif do
  use Rustler, otp_app: :logistic_map, crate: :logistic_map

  # When your NIF is loaded, it will override this function.
  def call_ocl(_x, _p, _mu), do: :erlang.nif_error(:nif_not_loaded)
```

lib/logistic_map.ex の該当部分

```elixir
defmodule LogisticMap do

  @logistic_map_size      0x2000000
  @default_prime 6_700_417
  @default_mu 22
  @default_loop 10

  @doc """

  ## Examples

      iex> 1..3 |> LogisticMap.mapCalc9(61, 22, 1)
      [28, 25, 37]
  """
  def mapCalc9(x, p, mu, _stages) do
    x
    |> Enum.to_list
    |> LogisticMapNif.call_ocl(p, mu)
  end
```

このコードだとリスト長がGPUで確保できるメモリを超えてしまった時にエラーが発生します。その問題を修正するならこちらです。

```elixir
defmodule LogisticMap do

  @logistic_map_size      0x2000000
  @default_prime 6_700_417
  @default_mu 22
  @default_loop 10

  @doc """

  ## Examples

      iex> 1..3 |> LogisticMap.mapCalc9(61, 22, 1)
      [28, 25, 37]
  """
  def mapCalc9(x, p, mu, _stages) do
    x
    |> Enum.to_list
    |> Stream.chunk_every(100000000000)
    |> Enum.map(& &1 |> LogisticMapNif.call_ocl(p, mu))
  end
```

ただし実験してみると， `Stream.chunk_every` でけっこうオーバーヘッドが発生することがわかったので，今回は前者で実験してみました。この辺りは課題ですね。

コンパイルしてみると，OpenCLがインストールされている場合には，完全に次の1コマンドで実行できます。ビルドと実行が容易なのは，とても嬉しいですね！ mix と cargo のおかげです！

```bash
$ mix run -e "LogisticMap.allbenchmarks"
```

@twinbee さんの実験によると，GCE の GPU 付きでも，OpenCL をインストールすることで動作したそうです！ そのうち Qiita の記事にしていただけるんじゃないかと期待しています！

# Rust単体実行バージョン

比較のためにRust単体で実行するベンチマークも作成しました。 @tatsuya6502 さん，ありがとうございます！

[GitHub レポジトリはこちら](https://github.com/zeam-vm/logistic_map_rust)

master ブランチがCPU1並列バージョン，OpenCLブランチが ocl を利用しての OpenCL バージョンです。

CPU1並列バージョンの実行方法

```bash
$ git clone git@github.com:zeam-vm/logistic_map_rust.git
$ cd logistic_map_rust
$ cargo run --release
```

OpenCLバージョンの実行方法

```bash
$ git clone git@github.com:zeam-vm/logistic_map_rust.git
$ cd logistic_map_rust
$ git checkout OpenCL
$ cargo run --release
```

# 実行結果

実行環境は下記の通りです。

> Mac Pro (Mid 2010)
> Processor 2.8GHz Quad-Core Intel Xeon
> Memory 16GB
> ATI Radeon HD 5770 1024MB


主要な実行結果は次の通りでした。(条件を揃えるため，すべてベンチマークを取り直しています)

なお，benchmarks_emptyは，Rustler の呼び出しコストを測定するため，一切の計算を無しに引数を読み込むだけ読み込んで結果を Elixir にそのまま返すという処理を記述してみました。

|stages|benchmarks1|benchmarks3|benchmarks5|benchmarks8|benchmarks9|benchmarks_empty|C  |Rust CPU|Rust OpenCL|Python|
|-----:|----------:|----------:|----------:|----------:|---------:|----------------:|--:|-------:|----------:|-----:|
|      |pure Elixir|pure Elixir|Elixir/Rustler|Elixir/Rustler|Elixir/Rustler|Elixir/Rustler|clang|Rust|Rust|Python|
|      |loop       |inlining inside of Flow.map|loop, passing by list|passing by list, with Window|OpenCL(GPU), inlining|Ruslter empty|CPU, loop|CPU, loop|OpenCL(GPU), inlining|NumPy, CPU|
|     1|53.223249|44.075415|12.042998| 9.702550|6.571943|6.027101|2.727346|2.720996|1.857096|17.749182|
|     2|26.474494|20.632323|36.622580|17.419324|
|     4|15.186692|13.497807|36.566198|16.233323|
|     8|12.796444|11.570678|36.226341|15.953845|
|    16|12.962736|11.607420|36.405342|16.846778|
|    32|12.988720|11.488179|39.785561|19.186600|
|    64|13.288242|11.561640|39.646524|24.126142|
|   128|13.214251|12.116703|40.206917|35.373501|

1. benchmarks9(Elixir/Rustler, OpenCL(GPU), inlining)は，pure Elixir(benchmarks1, benchmarks3)のベストタイム(stages=8,32)よりも，1.75〜1.95倍高速です。
2. benchmarks9(Elixir/Rustler, OpenCL(GPU), inlining)は，Elixir/Rustler/CPU(benchmarks5, benchmarks8)のベストタイム(stages=1)よりも1.5〜1.83倍高速です。
3. benchmarks9(Elixir/Rustler, OpenCL(GPU), inlining)とbenchmarks_empty(Elixir/Rustler)の差は0.55秒で，Rust OpenCL が1.86秒，この間くらいが正味の Rust による OpenCL の実行時間だと思われます。オーバーヘッド分は Erlang VM の実行コストと，リスト構造から配列に変換するコストです。Erlang VM で実行するのではなく，リスト構造を最初から配列にする最適化も含めたElixirソースコードからの静的コンパイル/最適化をかけてやると，Rust OpenCL くらいの実行時間(pure Elixir との比較で6.18〜6.88倍高速)になる潜在的可能性があります。
4. C言語の実行時間とRust CPUの実行時間はほぼ等しいです。最適化をかけた場合には，Rustそのものによる実行時間のオーバーヘッドはないものと考えて良さそうです。
5. Python から pure Elixir は1.39〜1.54倍，Python から benchmarks9(Elixir/Rustler, OpenCL(GPU), inlining) は2.7倍，Python から Rust OpenCL は9.54倍の速度向上です。Python から Elixir に置き換えることで，このくらいの速度向上を期待できそうです！

# おわりに

ついに Elixir から Rustler と OpenCL 経由で GPU を駆動することに成功しました！

1. Elixir/Rustler/OpenCL(GPU) は pure Elixir よりも1.75〜1.95倍高速です。
2. Elixir/Rustler/OpenCL(GPU) は Elixir/Rustler/CPU よりも1.5〜1.83倍高速です。
3. Erlang VM の実行コストと，リスト構造から配列に変換するコストが結構かかっています。リスト構造を最初から配列にする最適化も含めたElixirソースコードからの静的コンパイル/最適化をかけてやると，6.18〜6.88倍高速になる潜在的可能性があります。
4. C言語の実行時間とRust CPUの実行時間はほぼ等しいです。最適化をかけた場合には，Rustそのものによる実行時間のオーバーヘッドはないものと考えて良さそうです。
5. Python から pure Elixir は1.39〜1.54倍，Python から benchmarks9(Elixir/Rustler, OpenCL(GPU), inlining) は2.7倍，Python から Rust OpenCL は9.54倍の速度向上です。Python から Elixir に置き換えることで，このくらいの速度向上を期待できそうです

とにかく，ビルド設定に関しては，ほとんど何も考える必要なく OpenCL を駆動できたのは素晴らしいです！ これは，Rust の ocl ライブラリと，Rustler の功績です。NumPy 互換の CuPy で CUDA 経由で GPU を使うのにあれこれ煩雑な設定がたくさん要ることを考えると，この利点だけでも相当なアドバンテージです。

ただし，Rust プログラミングはかなり熟練を必要とし， @twinbee さんがおっしゃるように，コード1行書くのに1時間かかるというのも決して誇張ではない状況です。今後の研究で Elixir のコードからじかに コンパイルして GPU 駆動できるようにライブラリを整備していきたいと思います。

今後にもどうぞご期待くださいませ。

今回で連載は一区切りですが，[次回は Elixir / Rustler の小ネタを披露します。](https://qiita.com/zacky1972/items/cab329e03f9fae6c7404)お楽しみに！

明日は @koga1020 さんの[「Phoenix + Vue.js 入門」](https://qiita.com/koga1020/items/c02a0fd5ae11fb5da1e0)です。こちらもお楽しみに！

# p.s.「いいね」よろしくお願いします

よろしければ，ページ左上の ![image.png](https://qiita-image-store.s3.amazonaws.com/0/155423/4d515047-cc48-382e-c2b1-3ad0cc50dbbf.png) や ![image.png](https://qiita-image-store.s3.amazonaws.com/0/155423/a4e3da58-70a3-4197-95a2-6a6906650d01.png) のクリックをお願いしますー:bow:
ここの数字が増えると，書き手としては「ウケている」という感覚が得られ，連載を更に進化させていくモチベーションになりますので，もっとElixirネタを見たいというあなた，私たちと一緒に盛り上げてください！:tada:
