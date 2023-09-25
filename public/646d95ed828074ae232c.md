---
title: 初学者のための「コンピュータの動作原理」RISC-V 編 Lesson 1
tags:
  - assembly
  - CPU
  - RISC-V
private: false
updated_at: '2019-04-16T07:50:02+09:00'
id: 646d95ed828074ae232c
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[RV32I インストラクション・セット](https://qiita.com/zacky1972/items/48bf61bfe3ef2b8ce557)を読みながら，次のコードを読みましょう。与えられたレジスタマップを使用してください。[手順についてはこちらを参照してください。](https://qiita.com/zacky1972/items/9cc5392d70d43503afb6#実施)

さて，このコードは，何を計算しているのでしょうか？ 考察してみましょう。初期値を色々変えてみて，実行結果を分析してみると，きっと理解できますよ。

# コード

```
	.file	"sample.c"
	.option nopic
	.text
	.align	2
	.globl	calc
	.type	calc, @function
calc:
	li	a5,1
	li	a4,0
.L2:
	bgt	a5,a0,.L4
	add	a4,a4,a5
	addi	a5,a5,1
	j	.L2
.L4:
	mv	a0,a4
	ret
	.size	calc, .-calc
	.ident	"GCC: (GNU) 8.2.0"
```

# レジスタマップ

|レジスタ|初期値|
|:------|:-----|
|a0     |0x00000003|
|a4     |0x00000000|
|a5     |0x00000000|
|pc     |calcのアドレス|
