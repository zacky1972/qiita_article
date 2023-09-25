---
title: 'コンパイラのコード生成: 配列(カウンター方式)'
tags:
  - C
  - assembly
  - RISC-V
private: false
updated_at: '2019-04-23T08:57:56+09:00'
id: 9e2c4b18ef7a9d5bcedf
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
# はじめに

このテキストは[「コンパイラのコード生成: 繰返し」](https://qiita.com/zacky1972/items/29c1cf24ec2361e2f179)の続きです。


# C言語プログラム例

下記のC言語プログラム例を見ていきましょう。

```c
int calc(int a[], int n) {
	int sum = 0;
	for(int i = 0; i < n; i++) {
		sum += a[i];
	}
	return sum;
}
```

# RISC-Vのアセンブリコード

次のようにコンパイルします。

```bash
riscv64-unknown-elf-gcc -S -O0 -march=rv32i -mabi=ilp32 -o sample.s sample.c
```

得られた RISC-V のアセンブリコードは次の通りです。

```
	.file	"sample.c"
	.option nopic
	.text
	.align	2
	.globl	calc
	.type	calc, @function
calc:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	zero,-20(s0)
	sw	zero,-24(s0)
	j	.L2
.L3:
	lw	a5,-24(s0)
	slli	a5,a5,2
	lw	a4,-36(s0)
	add	a5,a4,a5
	lw	a5,0(a5)
	lw	a4,-20(s0)
	add	a5,a4,a5
	sw	a5,-20(s0)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L2:
	lw	a4,-24(s0)
	lw	a5,-40(s0)
	blt	a4,a5,.L3
	lw	a5,-20(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	calc, .-calc
	.ident	"GCC: (GNU) 8.2.0"
```

# 演習問題

レジスタマップとメモリマップを作成してみましょう。

# コード生成: 配列の参照

配列を参照している部分は次の通りです。

```
	lw	a5,-24(s0)
	slli	a5,a5,2
	lw	a4,-36(s0)
	add	a5,a4,a5
	lw	a5,0(a5)
```

`-24(s0)` が `i` に相当し，`slli a5,a5,2` によって `i` を4倍にします。さらに `-36(s0)` が `a` すなわち配列 `a` の先頭アドレスになりますので，`add a5,a4,a5`によって `a + i * 4` すなわち `a[i]`のアドレスがレジスタ`a5`に入ります。

あとは `lw a5, 0(a5)` によって参照するというわけです。

# コード生成: 配列への書き込み

逆に書き込む場合は，配列の参照のコードの最後を `sw (格納したい値を入れたレジスタ), 0(a5)` という具合にストア命令に書き換えます。

# ポインタを使った場合

下記のコードは，同じ実行結果になるコードですが，配列の代わりにポインタを用いています。

```c
int calc(int *a, int n) {
	int sum = 0;
	for(int i = 0; i < n; i++) {
		sum += *a++;
	}
	return sum;
}
```

# RISC-Vのアセンブリコード例 (ポインタを用いた場合)

```
	.file	"samplep.c"
	.option nopic
	.text
	.align	2
	.globl	calc
	.type	calc, @function
calc:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	sw	zero,-20(s0)
	sw	zero,-24(s0)
	j	.L2
.L3:
	lw	a5,-36(s0)
	addi	a4,a5,4
	sw	a4,-36(s0)
	lw	a5,0(a5)
	lw	a4,-20(s0)
	add	a5,a4,a5
	sw	a5,-20(s0)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L2:
	lw	a4,-24(s0)
	lw	a5,-40(s0)
	blt	a4,a5,.L3
	lw	a5,-20(s0)
	mv	a0,a5
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	calc, .-calc
	.ident	"GCC: (GNU) 8.2.0"
```

違いがわかりますか？ 配列版では，`slli` 命令がありますが，ポインタ版ではありません。

# 演習課題

配列版とポインタ版のロジックをよく見比べてみましょう。違いを説明してください。

