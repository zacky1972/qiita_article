---
title: Pelemayを開発している時にわかった Nerves 対応のコツ
tags:
  - Elixir
  - Nerves
  - Pelemay
private: false
updated_at: '2019-12-07T09:02:06+09:00'
id: b2beeeb5fd8689faba84
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[「#NervesJP Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/nervesjp)4日目の記事です。

昨日の[「#NervesJP Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/nervesjp)3日目は，@torifukukaiou さんの[「Nervesでcron的なことをする」](https://qiita.com/torifukukaiou/items/19a6aef76e28f9a1f319)でした。

昨日は[「言語実装 Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/lang_dev)3日目に[「Elixir / Pelemay 研究の背景と意義」](https://qiita.com/zacky1972/items/a3dedc0cdacbeed21b6d)という記事を寄稿しました。

今日からシリーズで，開発の過程で知ることになったNerves対応のコツについて紹介します。

# Nerves 対応のコツその1: コンパイラは環境変数CCで指定されているGCCクロスコンパイラを使用しよう

ことの発端は Pelemay を Nerves 上で動作させる試験をお願いした学生からのレポートです ([Fail `mix firmware` on Nerves RPi0 with Pelamy ** (Mix) Nerves encountered an error. %IO.Stream{device: :standard_io, line_or_bytes: :line, raw: true} #73](https://github.com/zeam-vm/pelemay/issues/73)

`mix firmware` すると下記のエラーが出るという報告でした。

```
Nerves environment
  MIX_TARGET:   rpi0
  MIX_ENV:      dev

Compiling 1 file (.ex)
|nerves_bootstrap| Building OTP Release...

* skipping runtime configuration (config/releases.exs not found)
* creating _build/rpi0_dev/rel/pelemay_sample/releases/0.1.0/vm.args
Updating base firmware image with Erlang release...
scrub-otp-release.sh: ERROR: Unexpected executable format for '/Users/osako/Documents/nerves/pelemay_sample/_build/_nerves-tmp/rootfs-additions/srv/erlang/lib/pelemay-0.0.4/priv/libnifelixirpelemaysample.so'

Got:
 file:Mach-O 64-bit dynamically linked shared library x86_64

Expecting:
 readelf:ARM;0x5000200, Version5 EABI, soft-float ABI

This file was compiled for the host or a different target and probably
will not work.

Check the following:

1. Are you using a path dependency in your mix deps? If so, run
   'mix clean' in that directory to avoid pulling in any of its
   build products.

2. Did you recently upgrade to Elixir 1.9 or Nerves 1.5?
   Nerves 1.5 adds support for Elixir 1.9 Releases and requires
   you to either add an Elixir 1.9 Release configuration or add
   Distillery as a dependency. Without this, the OTP binaries
   for your build machine will get included incorrectly and cause
   this error. See
   https://hexdocs.pm/nerves/updating-projects.html#updating-from-v1-4-to-v1-5

3. Did you recently upgrade or change your Nerves system? If so,
   try cleaning and rebuilding this project and its deps.

4. Are you building outside of Nerves' mix integration? If so,
   make sure that you've sourced 'nerves-env.sh'.

If you're still having trouble, please file an issue on Github
at https://github.com/nerves-project/nerves_system_br/issues.

** (Mix) Nerves encountered an error. %IO.Stream{device: :standard_io, line_or_bytes: :line, raw: true}
```

このエラーの見るべき箇所はこちらです。

```
Got:
 file:Mach-O 64-bit dynamically linked shared library x86_64

Expecting:
 readelf:ARM;0x5000200, Version5 EABI, soft-float ABI
```

つまり，ARMのELFであるべきところが，x86_64のDLLになっているというわけです。

# Nerves Project の中の人の1人，Frank Hunleth 曰く

> I assume this is due to calling clang. Nerves provides gcc crosscompilers.

それはおそらく clang を呼んでいるからだろうね。Nerves は GCC クロスコンパイラを提供しているよ。

> It (supporting auto-vectorization) might be ok to upgrade to gcc 9.2, but I’d have to check again. When I checked a 6 months ago, it wasn’t supported by crosstool-ng.

(Pelemay で用いている Auto Vectorization のサポートは) たぶん GCC 9.2 にアップグレードしたらできると思うけど，(Nervesでは) チェックしていないよ。6ヶ月前にテストした時には，GCC 9.2 (あるいは auto vectorization) は crosstool-ng ではサポートされていなかったよ。

> I don’t know if this is possible due to command line parameter differences, but you might be able to replace references to clang with $(CC) when building. Nerves sets CC to the proper crosscompiler when building.

コマンドラインパラメータの違いによって可能になるかはわからないけど，ビルド時に clang を環境変数`$(CC)`に置き換えることができるよ。Nerves は環境変数`CC`にビルド時に用いるクロスコンパイラをセットするよ。

# というわけで

Pelemay は GCC でもコンパイルできるようにしないといけないことがわかったのでした。

どうしよう。。。と思っていたら，[Christian Green がパッチを作ってくれました。](https://github.com/christianjgreen/pelemay/commit/8afb367577c8db3f3c6213ac5df558d9a0bc14bb) 

長らく見落としていてごめん。。。すぐに試すよ。。。

# おわりに

明日も[「#NervesJP Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/nervesjp)に[「CPU Info を開発している時にわかった Nerves 対応のコツ」](https://qiita.com/zacky1972/items/ad2fa8ce816bc83c0c61)をご紹介します。乞うご期待。
