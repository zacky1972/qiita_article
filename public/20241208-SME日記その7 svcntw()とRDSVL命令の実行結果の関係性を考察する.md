---
title: SME日記その7 svcntw()とRDSVL命令の実行結果の関係性を考察する
tags:
  - assembly
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2024-12-08T09:24:23+09:00'
id: 48cf7577e254b8c3a0b6
organization_url_name: null
slide: false
ignorePublish: false
---
今までApple Silicon M4で実行できたsvcntw()とRDSVL命令の実行結果の関係性を考察します．

SMEシリーズ

- [Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている](https://qiita.com/zacky1972/items/69fd802fd41ae4d7d469)
- [SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension(SME)のベクトル長(SVL)を取得する](https://qiita.com/zacky1972/items/231fd22a1fdef15d4108)
- [SME日記その2: Apple Silicon M4にはCVTW命令は備わっていない？](https://qiita.com/zacky1972/items/a4fc98614df085586175)
- [SME日記その3: Apple Silicon M4にどの命令が実装されているかをsysctl hwの実行結果とドキュメントから推測する](https://qiita.com/zacky1972/items/427035001554cb9768bc)
- [SME日記その4 Streaming SVE modeでCNTWを実行してみる．](https://qiita.com/zacky1972/items/3182fa1693983846205d)
- [SME日記その5 Streaming SVE modeでCNTWを実行してみる Part 2](https://qiita.com/zacky1972/items/b7b5dd456fe021b30eb2)
- [SME日記その6 Streaming SVE modeでsvcntw()とsvcntsw()を実行してみる](https://qiita.com/zacky1972/items/7d4ec630d54564ebb9b3)

## プログラムコード(`veclen.c`)

```c:veclen.c
#include <stdint.h>
#include <stdio.h>
#include <arm_sme.h>

void streaming_fn(void)
{
  uint64_t cntw, cntsw;
  asm volatile ("smstart sm");
  cntw = svcntw();
  cntsw = svcntsw();
  asm volatile ("smstop sm");
  printf("Streaming mode: svcntw() = %llu, svcntsw() = %llu\n", cntw, cntsw);
}

int main(void)
{
  streaming_fn();
}
```

## プログラムコード(`rdsvl.c`)

```c:rdsvl.c
#include <stdint.h>
#include <stdio.h>

uint64_t rdsvl8()
{
  uint64_t len;
  asm volatile ("rdsvl %0, 8"
                : "=r"(len)
               );
  return len;
}

int main()
{
  printf("%llu\n", rdsvl8());
}
```

## コンパイル方法

```zsh
clang -O2 -march=armv9-a+sme -o veclen veclen.c
clang -O2 -march=armv9-a+sme -o rdsvl rdsvl.c
```

## 実行の方法と結果

```zsh
% ./veclen                                       
Streaming mode: svcntw() = 16, svcntsw() = 16
% ./rdsvl 
512
```

## 考察

`16 * 4 * 8 = 512` なので，これらの命令の結果は基本的に同じ長さを表しているのではないかと推測しました．

しかしドキュメントを見ると，関連はしていると読み取れるのですが，今回，たまたま一致していると捉えた方が良さそうです．

したがって，ドキュメントをしっかり読み込んで，適切に命令を使い分けるべきと思いました．

### CNTW命令の説明

https://developer.arm.com/documentation/ddi0602/2024-09/SVE-Instructions/CNTB--CNTD--CNTH--CNTW--Set-scalar-to-multiple-of-predicate-constraint-element-count-?lang=en

> CNTB, CNTD, CNTH, CNTW
> 
> Set scalar to multiple of predicate constraint element count
> 
> Determines the number of active elements implied by the named predicate constraint, multiplies that by an immediate in the range 1 to 16 inclusive, and then places the result in the scalar destination.
> 
> The named predicate constraint limits the number of active elements in a single predicate to:
> 
> * A fixed number (VL1 to VL256)
> * The largest power of two (POW2)
> * The largest multiple of three or four (MUL3 or MUL4)
> * All available, implicitly a multiple of two (ALL).
> 
> Unspecified or out of range constraint encodings generate an empty predicate or zero element count rather than Undefined Instruction exception.
> 
> It has encodings from 4 classes: Byte , Doubleword , Halfword and Word
> 
> CNTB、CNTD、CNTH、CNTW
>
> スカラーを述語制約要素数の倍数に設定します
>
> 指定された述語制約によって暗示されるアクティブ要素の数を決定し、その数を 1 から 16 までの範囲の即値で乗算して、結果をスカラーの宛先に配置します。
>
> 指定された述語制約は、1 つの述語内のアクティブ要素の数を次の数に制限します:
>
> * 固定数 (VL1 から VL256)
> * 2 の最大の累乗 (POW2)
> * 3 または 4 の最大の倍数 (MUL3 または MUL4)
> * すべて使用可能、暗黙的に 2 の倍数 (ALL)。
>
> 指定されていない、または範囲外の制約エンコーディングは、未定義命令例外ではなく、空の述語またはゼロの要素数を生成します。
>
> 4 つのクラスのエンコーディングがあります: バイト、ダブルワード、ハーフワード、およびワード


### RDSVL命令の説明

https://developer.arm.com/documentation/ddi0602/2024-09/SME-Instructions/RDSVL--Read-multiple-of-Streaming-SVE-vector-register-size-to-scalar-register-

> RDSVL
> 
> Read multiple of Streaming SVE vector register size to scalar register
> 
> Multiply the Streaming SVE vector register size in bytes by an immediate in the range -32 to 31 and place the result in the 64-bit destination general-purpose register.
> 
> This instruction does not require the PE to be in Streaming SVE mode.
>
> RDSVL
>
> ストリーミング SVE ベクトル レジスタ サイズの倍数をスカラー レジスタに読み取ります
>
> ストリーミング SVE ベクトル レジスタ サイズ (バイト単位) に -32 ～ 31 の範囲の即値を掛け、その結果を 64 ビットの宛先汎用レジスタに格納します。
>
> この命令では、PE がストリーミング SVE モードである必要はありません。

