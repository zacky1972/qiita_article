---
title: SME日記その4 Streaming SVE modeでCNTWを実行してみる．
tags:
  - assembly
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2024-12-05T23:18:11+09:00'
id: 3182fa1693983846205d
organization_url_name: null
slide: false
ignorePublish: false
---
Stream SVE mode について調べて，Stream SVE modeでCNTWを実行してみました．

SMEシリーズ

- [Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている](https://qiita.com/zacky1972/items/69fd802fd41ae4d7d469)
- [SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension(SME)のベクトル長(SVL)を取得する](https://qiita.com/zacky1972/items/231fd22a1fdef15d4108)
- [SME日記その2: Apple Silicon M4にはCVTW命令は備わっていない？](https://qiita.com/zacky1972/items/a4fc98614df085586175)
- [SME日記その3: Apple Silicon M4にどの命令が実装されているかをsysctl hwの実行結果とドキュメントから推測する](https://qiita.com/zacky1972/items/427035001554cb9768bc)

## Stream SVE mode

https://developer.arm.com/documentation/109246/0100/SME-Overview/Streaming-SVE-mode

> Streaming SVE mode
> 
> An implementation of SME supports Streaming SVE mode. The Streaming SVE mode is a dedicated mode for SME operations that can be enabled or disabled by software by programming the PSTATE.SM field.
> 
> When the PE is in Streaming SVE mode:
> 
> The streaming vector registers Z0-Z31, streaming predicate registers P0-P15 and SME architecture state are accessible by SME instructions and a subset of SVE2 instructions executable in Streaming SVE mode.
> The effective vector length changes to streaming vector length. The SMCR_EL1, Streaming SVE Mode Control Register for EL1 configures the Effective Streaming SVE vector length when the PE is in Streaming SVE mode and executing at EL1 or EL0. For EL2 and EL3, corresponding SMCR register configures the Effective Streaming SVE vector length.
> SVL is independent of SVE Vector length (referred to as VL which is the vector length when not in Streaming SVE mode). The Effective Streaming SVE vector length, SVL, is a power of two in the range 128-2048 bits inclusive. > SVL can vary between implementations. When streaming SVE mode is disabled, the ZCR_ELx register determines the effective SVE vector length (VL).
> 
> Streaming SVE mode is enabled when PSTATE.SM=1. When PSTATE.SM is changed from 0 to 1, Streaming SVE mode is entered and SVE registers Z0-Z31 and P0-P15 in the new mode are set to 0.
> 
> You cannot directly program the PSTATE.SM field. The PSTATE.SM field can be programmed by using the SVCR register. You can use the following instruction to independently set or clear PSTATE.SM field:
> 
> `MSR SVCRSM, #<imm1>`
> Also, you can use SMSTART SM instruction, alias of the MSR SVCRSM, #1 and SMSTOP SM instruction, alias of the MSR SVCRSM, #0.
> 
> You can use the MRS instruction to read the SVCR register.
> 
> When the PSTATE.SM is changed from 1 to 0, an exit from Streaming SVE mode is performed, and each implemented bit of the SVE registers Z0-Z31 and P0-P15 in the new mode will set to zero.
> 
> Note
> 
> SMSTART SM enters Streaming SVE mode, but does not enable the SME ZA storage.

> ストリーミング SVE モード
>
> SME の実装はストリーミング SVE モードをサポートします。ストリーミング SVE モードは SME 操作専用のモードで、PSTATE.SM フィールドをプログラムすることでソフトウェアで有効または無効にできます。
>
> PE がストリーミング SVE モードの場合:
>
> ストリーミング ベクター レジスタ Z0-Z31、ストリーミング プレディケート レジスタ P0-P15、および SME アーキテクチャ状態は、ストリーミング SVE モードで実行可能な SME 命令および SVE2 命令のサブセットでアクセスできます。
> 有効ベクター長はストリーミング ベクター長に変更されます。PE がストリーミング SVE モードで EL1 または EL0 で実行されている場合、EL1 のストリーミング SVE モード制御レジスタ SMCR_EL1 は、有効なストリーミング SVE ベクター長を構成します。EL2 および EL3 の場合、対応する SMCR レジスタは、有効なストリーミング SVE ベクター長を構成します。
> SVL は SVE ベクトル長 (ストリーミング SVE モードではない場合のベクトル長である VL と呼ばれる) とは無関係です。有効なストリーミング SVE ベクトル長 SVL は、128 ～ 2048 ビットの範囲の 2 の累乗です。 > SVL は実装によって異なります。ストリーミング SVE モードが無効になっている場合、ZCR_ELx レジスタによって有効な SVE ベクトル長 (VL) が決定されます。
>
> ストリーミング SVE モードは、PSTATE.SM=1 のときに有効になります。PSTATE.SM が 0 から 1 に変更されると、ストリーミング SVE モードに入り、新しいモードの SVE レジスタ Z0 ～ Z31 および P0 ～ P15 が 0 に設定されます。
>
> PSTATE.SM フィールドを直接プログラムすることはできません。PSTATE.SM フィールドは、SVCR レジスタを使用してプログラムできます。次の命令を使用して、PSTATE.SM フィールドを個別に設定またはクリアできます。
>
> `MSR SVCRSM, #<imm1>`
> また、MSR SVCRSM, #1 のエイリアスである SMSTART SM 命令と、MSR SVCRSM, #0 のエイリアスである SMSTOP SM 命令を使用することもできます。
>
> SVCR レジスタを読み取るには、MRS 命令を使用できます。
>
> PSTATE.SM が 1 から 0 に変更されると、ストリーミング SVE モードからの終了が実行され、新しいモードで実装された SVE レジスタ Z0-Z31 および P0-P15 の各ビットがゼロに設定されます。
>
> 注
>
> SMSTART SM はストリーミング SVE モードに入りますが、SME ZA ストレージは有効になりません。

つまり，

```
SMSTART SM
```

とすると，Stream SVE modeに入り，

```
SMSTOP SM
```

とすると，Stream SVE modeが解除されるようです．

## 実験

### コード

```c:cntw.c
#include <stdint.h>
#include <stdio.h>

void smstart()
{
  asm volatile ("smstart sm");
}

void smstop()
{
  asm volatile ("smstop sm");
}

uint64_t cntw()
{
  uint64_t count;
  asm volatile ("cntw %0"
                : "=r"(count)
               );
  return count;
}

int main()
{
  smstart();
  printf("%llu\n", cntw());
  smstop();
}
```

### コンパイル方法

```zsh
clang -O2 -march=armv9-a+sme -o cntw cntw.c
```

### 実行の方法と結果

```zsh
% ./cntw                                     
zsh: illegal hardware instruction  ./cntw
```

仮説は外れましたね．

なお，`cntw()`を呼び出している行をコメントアウトしてコンパイルし直すと，正常に動作します．

