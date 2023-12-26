---
title: 初学者のための「コンピュータの動作原理」RISC-V 編 Lesson 3
tags:
  - assembly
  - CPU
  - RISC-V
private: false
updated_at: '2019-04-16T07:57:09+09:00'
id: f41ee6b15c2b24bfda50
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[RV32I インストラクション・セット](https://qiita.com/zacky1972/items/48bf61bfe3ef2b8ce557)を読みながら，次のコードを読みましょう。与えられたレジスタマップとメモリマップを使用してください。[手順についてはこちらを参照してください。](https://qiita.com/zacky1972/items/9cc5392d70d43503afb6#実施)

ただし，`slli rd,rs1,2` については，さしあたり，レジスタ`rs1`の値を4倍した値をレジスタ`rd`に書き込むものと思ってください。

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
	li	a5,0
	li	a3,0
.L2:
	bge	a5,a1,.L4
	slli	a4,a5,2
	add	a4,a0,a4
	lw	a4,0(a4)
	add	a3,a3,a4
	addi	a5,a5,1
	j	.L2
.L4:
	mv	a0,a3
	ret
	.size	calc, .-calc
	.ident	"GCC: (GNU) 8.2.0"
```

# レジスタマップ

|レジスタ|初期値|
|:------|:-----|
|a0     |0x00001000|
|a1     |0x00000004|
|a3     |0x00000000|
|a4     |0x00000000|
|a5     |0x00000000|
|pc     |calcのアドレス|

# メモリマップ

|アドレス|データ初期値|
|:------|:-----|
|0x00001000|0x00000010|
|0x00001004|0x00000008|
|0x00001008|0x00000020|
|0x0000100c|0x00000004|
