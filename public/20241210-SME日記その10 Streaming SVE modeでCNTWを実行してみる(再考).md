---
title: SME日記その10 Streaming SVE modeでCNTWを実行してみる(再考)
tags:
  - assembly
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2024-12-10T20:08:25+09:00'
id: ba3e07a8bc1e5e56d19a
organization_url_name: null
slide: false
ignorePublish: false
---
[SME日記その4 Streaming SVE modeでCNTWを実行してみる．](https://qiita.com/zacky1972/items/3182fa1693983846205d)に寄せられた[コメント](https://qiita.com/zacky1972/items/3182fa1693983846205d#comment-ad9e51f41dd14216a9a6)を踏まえて，再考してみます．

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

## いただいたコメント

https://qiita.com/zacky1972/items/3182fa1693983846205d#comment-ad9e51f41dd14216a9a6

> 推測を外したお詫び（？）にこの記事の実行結果をちゃんと説明しておくと、まず、Streaming SVE Modeへの切り替えは正しく行われます。そして、Streaming SVE Modeで printf が実行され、その内部で実行される浮動小数点命令がStreaming SVE Modeに対応していないのでSIGILLになります。デバッガーを使えば一発でわかります。
> 
> printf の内部でクラッシュするのは、（理由は違いますが）x86-64でアセンブリー言語を書くプログラミングをしているとたまに遭遇するので、懐かしい気分になりますね。

## 検証プログラムコード

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
  uint64_t c = cntw();
  smstop();
  printf("%llu\n", c);
}
```

## コンパイル方法

```zsh
clang -O2 -march=armv9-a+sme -o cntw cntw.c
```

## 実行の方法と結果

```zsh
% ./cntw                                     
16
```

## まとめ

お騒がせしました．確かに`printf`をStream SVE Mode の外に追い出せば，実行できました．これは注意しないといけないですね．

そして，デバッガを使うことも大事...




