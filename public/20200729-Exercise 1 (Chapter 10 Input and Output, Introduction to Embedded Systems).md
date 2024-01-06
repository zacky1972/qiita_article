---
title: 'Exercise 1 (Chapter 10: Input and Output, Introduction to Embedded Systems)'
tags:
  - 組込みシステム開発
private: true
updated_at: '2020-07-29T15:26:44+09:00'
id: f0e024fc86a3aa359e9f
organization_url_name: null
slide: false
ignorePublish: false
---
例10.6のように，次のようなRS232シリアルインタフェースに8バイトを送信するUARTを用いたAtmel AVR向けのCプログラムを考える:

```c
for(i = 0; i < 8; i++) {
	while(!(UCSR0a & 0x20));
	UDR0 = x[i];
}
```

プロセッサは50MHzで動作すると仮定する。またUARTは最初動作していないので，コードを実行し始めた時に `UCSR0A & 0x20 == 0x20` が成立すると仮定する。さらに，シリアルポートは19,200bpsで操作すると仮定する。上記のコードを実行するのに何サイクル必要か？

* `for`文の実行には3サイクルを要すると仮定する(1サイクルは`i++`の実行に，1サイクルは8との比較に，1サイクルは条件分岐に要するとする)。
* `while`文の実行には2サイクルを要すると仮定する(1サイクルは`!(UCSR0a & 0x20)`の実行に，1サイクルは条件分岐に要する)。
* そして`UDR0`への代入は1サイクルを要すると仮定する。
