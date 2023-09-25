---
title: 初学者のための「コンピュータの動作原理」RISC-V 編 Lesson 5
tags:
  - assembly
  - CPU
  - RISC-V
private: false
updated_at: '2019-05-21T09:35:12+09:00'
id: a81daf50bbe8351c71b8
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
[RV32I インストラクション・セット](https://qiita.com/zacky1972/items/48bf61bfe3ef2b8ce557)を読みながら，次のコードを読みましょう。与えられたレジスタマップとメモリマップを使用してください。[手順についてはこちらを参照してください。](https://qiita.com/zacky1972/items/9cc5392d70d43503afb6#実施)

さて，このコードは，何を計算しているのでしょうか？ 考察してみましょう。初期値を色々変えてみて，実行結果を分析してみると，きっと理解できますよ。

# コード

`pc` が「戻りアドレス」になったら，終了してください。

```
	.file	"sample.c"
	.option nopic
	.text
	.align	2
	.globl	calc
	.type	calc, @function
calc:
	bgtz	a0,.L8
	li	a0,0
	ret
.L8:
	addi	sp,sp,-16
	sw	ra,12(sp)
	addi	a0,a0,-1
	call	calc
	lw	ra,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	calc, .-calc
	.ident	"GCC: (GNU) 8.2.0"
```

# レジスタマップ

|レジスタ|初期値|
|:------|:-----|
|a0     |0x00000003|
|sp     |0x10000010|
|x0 (zero)|常に0|
|x1 (ra)|戻りアドレス|
|pc     |calcのアドレス|

# メモリマップ

|アドレス|データ初期値|
|:------|:-----|
|0x10000000|0x00000000|
|0x10000004|0x00000000|
|0x10000008|0x00000000|
|0x1000000c|0x00000000|
|0x10000010|0x00000000|

# 命令について

## call

さしあたり，`call offset` は `jalr ra, ra, offset` だと思ってください。

## ret

実際には `jalr zero, ra, 0` に展開されます。

## jr

`jr rs` は `jalr zero, rs, 0` に展開されます。
