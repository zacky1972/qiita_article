---
title: 新規のC言語処理系を実装することによる組込みシステム研究にもたらす価値についての考察
tags:
  - C
  - compiler
  - コンパイラ
private: false
updated_at: '2024-11-21T04:18:46+09:00'
id: 008bf957038e458781c3
organization_url_name: null
slide: false
ignorePublish: false
---
現在，主流となっているGCCやClangとは異なるC言語処理系を，現代においてわざわざ新たに実装することが，今後の組込みシステム研究にもたらす価値は，少なくとも次のような研究の基礎を提供することであると考察した．

1. 組込みシステム向けのメモリ一貫性モデルと過剰なコード最適化の抑制 
2. 形式手法をCコードに適用する研究 
3. コード最適化の等価性保証の研究 
4. サイドチャネル攻撃耐性を備えたコード生成器の研究

今後，このような研究のインフラストラクチャとなることを意図したC言語処理系を独自に開発することを検討する．

## Abstract

The value brought to the research of embedded systems by implementing a brand new processing system for the C programming language instead of GCC and Clang, the current mainstream systems, 
is to provide the following research basis: 

1. a memory consistency model for embedded systems and suppression of excessive optimization; 
2. the research that formal methods apply C code; 
3. the research to ensure equivalency of code optimization; and 
4. the research of code generator that has immunity to side-channel channel attacks. 

In the future, we will consider developing such a system as the infrastructure for the research.

## キーワード

組込みシステム，プログラミング言語処理系，メモリ一貫性モデル，コード最適化，形式手法，サイドチャネル攻撃

## Keywords

Embedded systems, Programming language prosessor, Memory consistency model, Code optimization, Formal method, Side-channel attack.

## URL

https://researchmap.jp/zacky1972/misc/48296213

## スライド

