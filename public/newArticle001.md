---
title: >-
  SME日記その2: Apple Silicon M4にはCVTW命令は備わっていない？
tags:
  - assembly
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: null
id: null
organization_url_name: null
slide: false
ignorePublish:
---
Apple Silicon M4でダイレクトにCVTW命令を実行してみたところ，`illegal hardware instruction` 例外が発生したので，Apple Silicon M4にはCVTW命令が備わっていない可能性があります．

SMEシリーズ

- [Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている](https://qiita.com/zacky1972/items/69fd802fd41ae4d7d469)
- [SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension(SME)のベクトル長(SVL)を取得する](https://qiita.com/zacky1972/items/231fd22a1fdef15d4108)

## ソースコード

```c:cntw.c
#include <stdint.h>
#include <stdio.h>

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
  printf("%llu\n", cntw());
}
```

## コンパイル方法

```zsh
clang -O2 -march=armv9-a+sme -o cntw cntw.c
```

## 実行の方法と結果

```zsh
% ./cntw                                     
zsh: illegal hardware instruction  ./cntw
```

