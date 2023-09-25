---
title: RISC-Vベクタ拡張プログラミングをGCCインラインアセンブラで
tags:
  - GCC
  - assembly
  - RISC-V
private: false
updated_at: '2023-05-07T11:00:31+09:00'
id: eabbcae5af04e24c2cc0
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
RISC-Vベクタ拡張(RVV)はRISC-Vの目玉機能として規格の策定が進められてきました．RVVは2021年にバージョン1.0として批准されました(公式の仕様については下記URL)．

https://github.com/riscv/riscv-v-spec

RVVを搭載するRISC-V CPUは，バージョン0.7のAllwinner D1が先駆けだったように思います．下記の論文によると，バージョン1.0のRVVについては，SiFive X280，Andres NX27V，Atrevido 220などで実装されているそうです(この論文自体もオープンソースのRVV実装を提案するものでした)．

https://arxiv.org/abs/2210.08882

RISC-VではOSやプログラミング言語処理系向けに，標準的にサポートすべき拡張をプロファイルとして定義しています(下記URL)．2023年版プロファイルでは，RVVを必須とする案が審議されている模様です．

https://github.com/riscv/riscv-profiles

RVVには批判もあります(たとえば下記のツイート)．曰く，仕様が複雑で巨大であること，
スーパースカラに組込んだ時にハードがどうなるかの考慮が不足しているということだそうです．

https://twitter.com/r_shioya/status/1646328992004206593?s=46&t=dYLTM5nVZx8m6yrtIlzlag

このようなRVVを活用するには，2023年5月現在では目下Auto-vectorizationを開発中のようで，アセンブリコードを書くしかなさそうです．しかも調べてみたところ，2023年5月現在ではアセンブラ`as`にRVVをアセンブルさせるとエラーになってしまって受け付けてくれなかったので，GCCインラインアセンブラで実装することにしてみました．macOSの場合ですが，コンパイラオプションには下記のようにRVVを含めてビルドするように指定します．

https://qiita.com/zacky1972/items/0cbfdf4e400e0205aa7b

実行環境についても，これもmacOSの場合ですが下記記事のように `spike` と `pk`を用いてエミュレーション実行させることができました．

https://qiita.com/zacky1972/items/6d433bdbef737d1e300f

この記事では，RVVをGCCインラインアセンブラで記述する方法について説明したいと思います．

# コード例

先にRISC-VのCコード例を示します．

```c
#include <stdint.h>

#if ! ( defined(__riscv_vector) && defined(ASM_ROUTINE) )

int64_t sum(uint64_t n, int64_t *v)
{
    int64_t result = 0;
    int64_t *p = v;

    for(uint64_t i = 0; i < n; i++) {
        result += *p++;
    }

    return result;
}

#else // ( defined(__riscv_vector) && defined(ASM_ROUTINE) )

int64_t sum(uint64_t n, int64_t *v)
{
    int64_t result = 0;
    int64_t *p = v;

    asm volatile(
        "mv t1, %[n]\n\t"
        "vsetvli t0, t1, e64, m8\n\t"
        "vmv.v.x v8, x0\n\t"
        "loop%=:\n\t"
        "vsetvli t0, t1, e64, m8\n\t"
        "vle64.v v0, %[p]\n\t"
        "vredsum.vs v8, v0, v8\n\t"
        "sub t1, t1, t0\n\t"
        "slli t0, t0, 2\n\t"
        "add %[v], %[v], t0\n\t"
        "bnez t1, loop%=\n\t"
        "vmv.x.s %[result], v8\n\t"
        : [result] "=r" (result), [p] "=rm" (*p), [v] "=r" (p)
        : [n] "r" (n)
        : "t0", "t1"
    );

    return result;    
}

#endif // ( defined(__riscv_vector) && defined(ASM_ROUTINE) )
```

コンパイルと実行の仕方は次のとおりです．

C版

```zsh
riscv64-unknown-elf-gcc -march=rv64gv -mabi=lp64d -O2 sum.c -o sum_c
./sum_c
```

RVV版

```zsh
riscv64-unknown-elf-gcc -march=rv64gv -mabi=lp64d -O2 -DASM_ROUTINE sum.c -o sum_asm
./sum_asm
```

# コード解説

```c
#if ! ( defined(__riscv_vector) && defined(ASM_ROUTINE) )
```

マクロ`__riscv_vector`はGCCによって設定され，RVVをサポートしている時に真になります．これを用いて `#ifdef` 等で分岐することができます．ここでは．`__riscv_vector`が真で，かつマクロ`ASM_ROUTINE`も真である時にRVV用のコードが発動するようにしています．

```c
    asm volatile(
        ...
        : [result] "=r" (result), [p] "=rm" (*p), [v] "=r" (p)
        : [n] "r" (n)
        : "t0", "t1"
    );
```

* `asm volatile`はインラインアセンブリコードを指示します．`volatile`はコード最適化の対象にしないことを示しています．
* `...`部分にアセンブリコードを書きます．
* `: [result]`の行は出力として変化するレジスタと変数を指定しています．`=rm`とすることでメモリを参照することを示しています．`*p`と`p`を呼び分けているのは，苦肉の策です(どうまとめたらいいかがわからなかったので，より良い方法をご存知の方は教えてください)．
* `: [n]`の行は入力として使用するレジスタと変数を指定しています．
* `"t0"`の行は，内部で使用するレジスタを指定しています．ベクタレジスタは指定しなくて良いようです．

```c
    asm volatile(
        "mv t1, %[n]\n\t"
        "vsetvli t0, t1, e64, m8\n\t"
        "vmv.v.x v8, x0\n\t"
        ...
    );
```

プロローグ部分です．
* `t1`レジスタに`n`の値を格納して，カウンタとして機能させます．
* `vmv.v.x` 命令により，ベクトルレジスタ`v8`を`x0`すなわち`0`で初期化します．ベクトルレジスタ`v8`に結果をアキュムレート(累算)していくことになります．
* ベクトル命令を使用する時にはそれに先立ってコンフィギュレーションをしないと不正命令例外になるようです．それで仕方なく後述するのと同じ`vsetvli`命令の初期化を入れています．これをもっとスマートにするにはどうしたらいいかがよくわかりません．もしより良い方法をご存知の方は教えてください．

```c
    asm volatile(
        ...
        "loop%=:\n\t"
        "vsetvli t0, t1, e64, m8\n\t"
        "vle64.v v0, %[p]\n\t"
        "vredsum.vs v8, v0, v8\n\t"
        "sub t1, t1, t0\n\t"
        "slli t0, t0, 2\n\t"
        "add %[v], %[v], t0\n\t"
        "bnez t1, loop%=\n\t"
        ...
    );
```

ループ本体です．
* ラベルを指定する時には `%=`を末尾につけます．こうすることで，コード展開によって同名のラベルが現れたときに区別することができます．
* `vsetvli`命令によってベクトルレジスタを初期化します．`e64`は1要素のサイズが64ビットであることを示します．`m8`はベクトルレジスタを8つまとめて同時に使うことで，より効率の良いコードにします．スカラレジスタ`t0`には各イテレーション(反復)で一度に処理する要素数が格納されます．
* `vle64.v v0, %[p]`命令によって，ベクトルレジスタ`v0`に`*p`の値をロードします．
* `vredsum.vs v8, v0, v8`とすることで，ベクトルレジスタ`v8`の先頭要素にベクトルレジスタ`v0`の値をアキュムレート(累算)していきます．
* `sub t1, t1, t0`命令によって，カウンタ`t1`から，このイテレーション(反復)で一度に処理する要素数`t0`を減算します．
* `slli t0, t0, 2`と`add %[v], %[v], t0`により，ポインタをインクリメントします．
* `bnez t1, loop%=`とすることで，カウンタ`t1`の値が0より大きい時にループします．

```c
    asm volatile(
        ...
        "vmv.x.s %[result], v8\n\t"
        ...
    );
```

エピローグ部分です．

* `vmv.x.s`命令は，今回のようにベクタレジスタの先頭要素にアキュムレート(累算)した値などが格納されている時に，その値をスカラレジスタに移動するときに用いる命令です．ここではスカラレジスタである変数`result`にベクトルレジスタ`v8`の先頭要素を格納します．

# おわりに

RVVについての日本語ドキュメントはこちらが便利です．

https://msyksphinz-self.github.io/riscv-v-spec-japanese/html/index.html

RVVでアセンブリプログラミングするのは，元となるCコードがあれば，比較的，容易にできると思いました．少なくともソフトウェアを組む立場からは，RVVはとても良さそうに見えます．

でも前述のツイートのように，ロジックを組む側からすると，実装するのはとても大変なのでしょうね．
