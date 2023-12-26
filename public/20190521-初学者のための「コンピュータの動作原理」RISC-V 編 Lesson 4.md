---
title: 初学者のための「コンピュータの動作原理」RISC-V 編 Lesson 4
tags:
  - assembly
  - CPU
  - RISC-V
private: false
updated_at: '2019-05-21T09:34:45+09:00'
id: fbb49fabdce67292954f
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
	.globl	sub
	.type	sub, @function
sub:
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
	.size	sub, .-sub
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	mv	s1,a1
	call	sub
	mv	s0,a0
	mv	a0,s1
	call	sub
	add	a0,s0,a0
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 8.2.0"
```

# レジスタマップ

|レジスタ|初期値|
|:------|:-----|
|a0     |0x00000003|
|a1     |0x00000002|
|a4     |0x00000000|
|a5     |0x00000000|
|sp     |0x10000010|
|s0     |0x10001000|
|s1     |0x00000010|
|x0 (zero)|常に0|
|x1 (ra)|戻りアドレス|
|pc     |mainのアドレス|

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
