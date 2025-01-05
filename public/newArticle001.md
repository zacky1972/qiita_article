---
title: SME日記その17 __arm_new("za")について調べる Part.2
tags:
  - M4
  - AppleSilicon
  - SME
  - Clang
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
[SME日記その8 __arm_new("za")について調べる](https://qiita.com/zacky1972/items/762b73b3414369d762ad)では，`__arm_new("za")`について，ドキュメントから調査しましたが，実際にApple Clangにコンパイルさせてみました．

SMEシリーズ

- [Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている](https://qiita.com/zacky1972/items/69fd802fd41ae4d7d469)
- [SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension(SME)のベクトル長(SVL)を取得する](https://qiita.com/zacky1972/items/231fd22a1fdef15d4108)
- [SME日記その2: Apple Silicon M4にはCVTW命令は備わっていない？](https://qiita.com/zacky1972/items/a4fc98614df085586175)
- [SME日記その3: Apple Silicon M4にどの命令が実装されているかをsysctl hwの実行結果とドキュメントから推測する](https://qiita.com/zacky1972/items/427035001554cb9768bc)
- [SME日記その4 Streaming SVE modeでCNTWを実行してみる．](https://qiita.com/zacky1972/items/3182fa1693983846205d)
- [SME日記その5 Streaming SVE modeでCNTWを実行してみる Part 2](https://qiita.com/zacky1972/items/b7b5dd456fe021b30eb2)
- [SME日記その6 Streaming SVE modeでsvcntw()とsvcntsw()を実行してみる](https://qiita.com/zacky1972/items/7d4ec630d54564ebb9b3)
- [SME日記その7 svcntw()とRDSVL命令の実行結果の関係性を考察する](https://qiita.com/zacky1972/items/48cf7577e254b8c3a0b6)
- [SME日記その8 __arm_new("za")について調べる](https://qiita.com/zacky1972/items/762b73b3414369d762ad)
- [SME日記その9 OpenBLASのSME対応状況について調べる](https://qiita.com/zacky1972/items/0c6f5aed0365f1b4fdb6)
- [SME日記その10 Streaming SVE modeでCNTWを実行してみる(再考)](https://qiita.com/zacky1972/items/ba3e07a8bc1e5e56d19a)
- [SME日記その11 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.1](https://qiita.com/zacky1972/items/15bca5a0dcd3073d4d60)
- [SME日記その12 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.2](https://qiita.com/zacky1972/items/2d69ed8b7ae5840012db)
- [SME日記その13 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.3](https://qiita.com/zacky1972/items/5fe73657dd1e4b167320)
- [SME日記その14 AppleBLASのSSCALでSMEが使われているかを検証してみる Part.1](https://qiita.com/zacky1972/items/9b22e23cd18a4912b99a)
- [SME日記その15 AppleBLASのSGEMMでSMEが使われているかを検証してみる Part.1](https://qiita.com/zacky1972/items/e6e8d8ebe4400c6ef737)
- [SME日記その16 Scalable Matrix Extension (SME)の研究の今後の展望についての技術的ポエム](https://qiita.com/zacky1972/items/34ff853daebaf24761a4)

## サンプルコード

```c:test_sme.c
#include <stdio.h>
#include <arm_sme.h>

__arm_locally_streaming
__arm_new("za")
void test_arm_new(void)
{
}

int main(int argc, char *argv[])
{
  test_arm_new();
}
```

```zsh
clang -O2 -march=armv9-a+sme test_sme.c -o test_sme
```

```zsh
% ./test_sme
%
```

```zsh
clang -O2 -march=armv9-a+sme -S test_sme.c
```

```asm:test_sme.s
        .section        __TEXT,__text,regular,pure_instructions
        .build_version macos, 15, 0     sdk_version 15, 2
        .globl  _test_arm_new                   ; -- Begin function test_arm_new
        .p2align        2
_test_arm_new:                          ; @test_arm_new
        .cfi_startproc
; %bb.0:
        stp     d15, d14, [sp, #-96]!           ; 16-byte Folded Spill
        stp     d13, d12, [sp, #16]             ; 16-byte Folded Spill
        stp     d11, d10, [sp, #32]             ; 16-byte Folded Spill
        stp     d9, d8, [sp, #48]               ; 16-byte Folded Spill
        stp     x20, x19, [sp, #64]             ; 16-byte Folded Spill
        stp     x29, x30, [sp, #80]             ; 16-byte Folded Spill
        add     x29, sp, #80
        sub     sp, sp, #16
        .cfi_def_cfa w29, 16
        .cfi_offset w30, -8
        .cfi_offset w29, -16
        .cfi_offset w19, -24
        .cfi_offset w20, -32
        .cfi_offset b8, -40
        .cfi_offset b9, -48
        .cfi_offset b10, -56
        .cfi_offset b11, -64
        .cfi_offset b12, -72
        .cfi_offset b13, -80
        .cfi_offset b14, -88
        .cfi_offset b15, -96
        smstart sm
        rdsvl   x8, #1
        mul     x8, x8, x8
        mov     x9, x8
Lloh0:
        adrp    x16, ___chkstk_darwin@GOTPAGE
Lloh1:
        ldr     x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
        blr     x16
        mov     x9, sp
        add     x8, x8, #15
        and     x8, x8, #0xfffffffffffffff0
        sub     x8, x9, x8
        mov     sp, x8
        stur    wzr, [x29, #-84]
        sturh   wzr, [x29, #-86]
        stur    x8, [x29, #-96]
        mrs     x8, TPIDR2_EL0
        cbz     x8, LBB0_2
; %bb.1:
        bl      ___arm_tpidr2_save
        msr     TPIDR2_EL0, xzr
LBB0_2:
        smstart za
        zero    {za}
        smstop  za
        smstop  sm
        sub     sp, x29, #80
        ldp     x29, x30, [sp, #80]             ; 16-byte Folded Reload
        ldp     x20, x19, [sp, #64]             ; 16-byte Folded Reload
        ldp     d9, d8, [sp, #48]               ; 16-byte Folded Reload
        ldp     d11, d10, [sp, #32]             ; 16-byte Folded Reload
        ldp     d13, d12, [sp, #16]             ; 16-byte Folded Reload
        ldp     d15, d14, [sp], #96             ; 16-byte Folded Reload
        ret
        .loh AdrpLdrGot Lloh0, Lloh1
        .cfi_endproc
                                        ; -- End function
        .globl  _main                           ; -- Begin function main
        .p2align        2
_main:                                  ; @main
        .cfi_startproc
; %bb.0:
        mov     w0, #0                          ; =0x0
        ret
        .cfi_endproc
                                        ; -- End function
.subsections_via_symbols
```

最適化されてしまって，実際には関数 `test_arm_new` を実行していないみたいですね．

## 考察

ドキュメントと比較してみます．

> * 関数は、遅延保存された ZA データをコミットします。

下記の部分が該当しそうです．

```asm
        stp     d15, d14, [sp, #-96]!           ; 16-byte Folded Spill
        stp     d13, d12, [sp, #16]             ; 16-byte Folded Spill
        stp     d11, d10, [sp, #32]             ; 16-byte Folded Spill
        stp     d9, d8, [sp, #48]               ; 16-byte Folded Spill
        stp     x20, x19, [sp, #64]             ; 16-byte Folded Spill
...
        ldp     x20, x19, [sp, #64]             ; 16-byte Folded Reload
        ldp     d9, d8, [sp, #48]               ; 16-byte Folded Reload
        ldp     d11, d10, [sp, #32]             ; 16-byte Folded Reload
        ldp     d13, d12, [sp, #16]             ; 16-byte Folded Reload
        ldp     d15, d14, [sp], #96             ; 16-byte Folded Reload
```

> * 関数は新しい ZA コンテキストを作成し、PSTATE.ZA を有効にします。

下記の部分が該当しそうです．

```asm
        smstart sm
        rdsvl   x8, #1
        mul     x8, x8, x8
        mov     x9, x8
Lloh0:
        adrp    x16, ___chkstk_darwin@GOTPAGE
Lloh1:
        ldr     x16, [x16, ___chkstk_darwin@GOTPAGEOFF]
        blr     x16
        mov     x9, sp
        add     x8, x8, #15
        and     x8, x8, #0xfffffffffffffff0
        sub     x8, x9, x8
        mov     sp, x8
        stur    wzr, [x29, #-84]
        sturh   wzr, [x29, #-86]
        stur    x8, [x29, #-96]
        mrs     x8, TPIDR2_EL0
        cbz     x8, LBB0_2
; %bb.1:
        bl      ___arm_tpidr2_save
        msr     TPIDR2_EL0, xzr
LBB0_2:
        smstart za
        zero    {za}
```

> * 関数は、戻る前に PSTATE.ZA を無効にします (0 に設定)。

下記の部分が該当しそうです．

```asm
        smstop  za
        smstop  sm
```
