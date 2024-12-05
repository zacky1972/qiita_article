---
title: SME日記その5 Streaming SVE modeでCNTWを実行してみる Part 2
tags:
  - assembly
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
[前回](https://qiita.com/zacky1972/items/3182fa1693983846205d)，Stream SVE mode について調べて，Stream SVE modeでCNTWを実行してみましたが，次のような指摘を受けました．

> これコンパイラーが関数境界で自動的にsmstopを挿入してるんじゃないの。逆アセンブル結果を確認するべきだと思う

https://x.com/mod_poppo/status/1864694991538540671

なるほど！

SMEシリーズ

- [Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている](https://qiita.com/zacky1972/items/69fd802fd41ae4d7d469)
- [SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension(SME)のベクトル長(SVL)を取得する](https://qiita.com/zacky1972/items/231fd22a1fdef15d4108)
- [SME日記その2: Apple Silicon M4にはCVTW命令は備わっていない？](https://qiita.com/zacky1972/items/a4fc98614df085586175)
- [SME日記その3: Apple Silicon M4にどの命令が実装されているかをsysctl hwの実行結果とドキュメントから推測する](https://qiita.com/zacky1972/items/427035001554cb9768bc)
- [SME日記その4 Streaming SVE modeでCNTWを実行してみる．](https://qiita.com/zacky1972/items/3182fa1693983846205d)


```zsh
clang -O2 -march=armv9-a+sme -S cntw.c
```

```asm
        .section        __TEXT,__text,regular,pure_instructions
        .build_version macos, 15, 0     sdk_version 15, 1
        .globl  _smstart                        ; -- Begin function smstart
        .p2align        2
_smstart:                               ; @smstart
        .cfi_startproc
; %bb.0:
        ; InlineAsm Start
        smstart sm
        ; InlineAsm End
        ret
        .cfi_endproc
                                        ; -- End function
        .globl  _smstop                         ; -- Begin function smstop
        .p2align        2
_smstop:                                ; @smstop
        .cfi_startproc
; %bb.0:
        ; InlineAsm Start
        smstop  sm
        ; InlineAsm End
        ret
        .cfi_endproc
                                        ; -- End function
        .globl  _cntw                           ; -- Begin function cntw
        .p2align        2
_cntw:                                  ; @cntw
        .cfi_startproc
; %bb.0:
        ; InlineAsm Start
        cntw    x0
        ; InlineAsm End
        ret
        .cfi_endproc
                                        ; -- End function
        .globl  _main                           ; -- Begin function main
        .p2align        2
_main:                                  ; @main
        .cfi_startproc
; %bb.0:
        sub     sp, sp, #32
        stp     x29, x30, [sp, #16]             ; 16-byte Folded Spill
        add     x29, sp, #16
        .cfi_def_cfa w29, 16
        .cfi_offset w30, -8
        .cfi_offset w29, -16
        ; InlineAsm Start
        smstart sm
        ; InlineAsm End
        ; InlineAsm Start
        cntw    x8
        ; InlineAsm End
        str     x8, [sp]
Lloh0:
        adrp    x0, l_.str@PAGE
Lloh1:
        add     x0, x0, l_.str@PAGEOFF
        bl      _printf
        ; InlineAsm Start
        smstop  sm
        ; InlineAsm End
        mov     w0, #0                          ; =0x0
        ldp     x29, x30, [sp, #16]             ; 16-byte Folded Reload
        add     sp, sp, #32
        ret
        .loh AdrpAdd    Lloh0, Lloh1
        .cfi_endproc
                                        ; -- End function
        .section        __TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
        .asciz  "%llu\n"
```

ありゃ，インライン展開されている？

ダメ押しで次のようなことをしてみました．

```c:cntw2.c
#include <stdint.h>
#include <stdio.h>

int main()
{
  uint64_t count;
  asm volatile ("smstart sm\n\t"
                "cntw %0\n\t"
                "smstop sm"
                : "=r"(count)
               );
  printf("%llu\n", count);
}
```

```zsh
clang -O2 -march=armv9-a+sme -o cntw2 cntw2.c
```

```zsh
% ./cntw2
16
```

今度はうまく行きました．つまり，CNTW命令自体は備わっていて，Stream SVE modeにしてはじめて，CNTWを実行できるようになるということでした．

それにしても，アセンブリコードで見たときに，インライン展開されているように見えたのはなんだったのだろうか？これだとアセンブリコードの出力も信用できない...

