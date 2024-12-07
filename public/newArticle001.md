---
title: SME日記その6 Streaming SVE modeでsvcntw()とsvcntsw()を実行してみる
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
ようやく[ArmのScalable Matrix Extension (SME)を試す](https://zenn.dev/mod_poppo/articles/arm-scalable-matrix-extension)の`veclen.c`相当のプログラムを実行できるようになったので報告します．

SMEシリーズ

- [Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている](https://qiita.com/zacky1972/items/69fd802fd41ae4d7d469)
- [SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension(SME)のベクトル長(SVL)を取得する](https://qiita.com/zacky1972/items/231fd22a1fdef15d4108)
- [SME日記その2: Apple Silicon M4にはCVTW命令は備わっていない？](https://qiita.com/zacky1972/items/a4fc98614df085586175)
- [SME日記その3: Apple Silicon M4にどの命令が実装されているかをsysctl hwの実行結果とドキュメントから推測する](https://qiita.com/zacky1972/items/427035001554cb9768bc)
- [SME日記その4 Streaming SVE modeでCNTWを実行してみる．](https://qiita.com/zacky1972/items/3182fa1693983846205d)
- [SME日記その5 Streaming SVE modeでCNTWを実行してみる Part 2](https://qiita.com/zacky1972/items/b7b5dd456fe021b30eb2)

## プログラムコード

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

ポイントとしては，次の点です．

* `svcntw()`と`svcntsw()`についてはエラーにならない
* `__arm_locally_streaming`と`__arm_has_sme()`はリンクエラーになる
* `CNTW`という命令は存在するが，`CNTSW`なる命令は存在しない
* `svcntsw()`でどんなアセンブリコードを生成するのかは，調べても不明

## コンパイル方法

```zsh
clang -O2 -march=armv9-a+sme -o veclen veclen.c
```

## 実行の方法と結果

```zsh
% ./veclen                                       
Streaming mode: svcntw() = 16, svcntsw() = 16
```

ここまで，長かった！