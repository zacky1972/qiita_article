---
title: 初学者のための「コンピュータの動作原理」RISC-V 編 Lesson 6
tags:
  - assembly
  - CPU
  - RISC-V
private: false
updated_at: '2019-05-21T09:36:02+09:00'
id: ad7f749200c48f9555da
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
	.type	sub, @function
sub:
	li	a5,1
	li	a4,0
.L2:
	bgt	a5,a1,.L4
	add	a4,a4,a0
	addi	a5,a5,1
	j	.L2
.L4:
	mv	a0,a4
	ret
	.size	sub, .-sub
	.align	2
	.globl	calc
	.type	calc, @function
calc:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	mv	s4,a2
	li	s0,0
	li	s1,0
.L6:
	bgt	s0,s4,.L9
	addi	s2,a0,4
	addi	s3,a1,4
	lw	a1,0(a1)
	lw	a0,0(a0)
	call	sub
	add	s1,s1,a0
	addi	s0,s0,1
	mv	a1,s3
	mv	a0,s2
	j	.L6
.L9:
	mv	a0,s1
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	lw	s4,8(sp)
	addi	sp,sp,32
	jr	ra
	.size	calc, .-calc
	.ident	"GCC: (GNU) 8.2.0"
```

# レジスタマップ

|レジスタ|初期値|
|:------|:-----|
|a0     |0x00000003|
|a1     |0x00000002|
|a4     |0x00000000|
|a5     |0x00000000|
|sp     |0x10000020|
|s0     |0x10001000|
|s1     |0x00000010|
|s2     |0x00000020|
|s3     |0x00000040|
|s4     |0x00000080|
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
|0x10000014|0x00000000|
|0x10000018|0x00000000|
|0x1000001c|0x00000000|
|0x10000020|0x00000000|


# 命令について

## call

さしあたり，`call offset` は `jalr ra, ra, offset` だと思ってください。

## ret

実際には `jalr zero, ra, 0` に展開されます。

## jr

`jr rs` は `jalr zero, rs, 0` に展開されます。

