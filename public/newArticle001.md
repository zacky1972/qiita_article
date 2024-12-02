---
title: >-
  SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension
  (SME)のベクトル長(SVL)を取得する
tags:
  - assembly
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2024-12-02T22:08:55+09:00'
id: 231fd22a1fdef15d4108
organization_url_name: null
slide: false
ignorePublish: false
---
Apple Silicon M4にはScalable Matrix Extension(SME)，すなわち可変長行列演算拡張命令が備わっています．これを探求してみたいと思います．

下記記事を試そうとしたのですが，

https://zenn.dev/mod_poppo/articles/arm-scalable-matrix-extension

下記記事にもあるように，サンプルプログラムがエラーになって動作しませんでした．

https://blog.miz-ar.info/2024/11/m4-mac-mini/

なので，インラインアセンブラで書いてみました．

まず，RDSVL命令を試します．

https://developer.arm.com/documentation/ddi0602/2024-09/SME-Instructions/RDSVL--Read-multiple-of-Streaming-SVE-vector-register-size-to-scalar-register-

> Read multiple of Streaming SVE vector register size to scalar register
> ストリーミングSVEベクトルレジスタサイズの倍数をスカラーレジスタに読み取る

さっそく書いてみました．

```c:rdsvl.c
#include <stdint.h>
#include <stdio.h>

int main()
{
  uint64_t len;
  asm volatile ("rdsvl %0, 8"
                : "=r"(len)
               );
  printf("%llu\n", len);
}
```

コンパイル方法は次のとおりです．

```zsh
clang -march=armv9-a+sme -o rdsvl rdsvl.c
```

実行結果は次のとおりです．

```zsh
% ./rdsvl 
512
```

すなわち，512ビット(64バイト)のレジスタ長を持っていることがわかりました．

