---
title: >-
  最適化コンパイラを作りたい人にとって必要な解析器の数学的基礎を与えてくれそうな An Introduction to the Theory of
  Optimizing Compilers の斜め読みのしかた
tags:
  - コンパイラ
  - コンパイラ実装
  - コンパイラ自作
private: false
updated_at: '2020-07-29T11:07:27+09:00'
id: 28ce30e6f9358481bf07
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
超ニッチな記事です。

An Introduction to the Theory of Optimizing Compilers という書籍を知りました。[(Amazon リンク)](https://amzn.to/30Teck0)

一読して，この書籍は最適化コンパイラを作りたい人にとって必要な解析器の数学的基礎を与えてくれそうな書籍だと思いました。なので，2020年度はこの書籍を輪読することにしました。

この記事は，この書籍を読むにあたって，読破するためのモチベーションを高めるために，斜め読みして，どんなことに役立つかを先に知る方法について紹介します。

# 1. 目次より，章のタイトルを眺めます

この書籍の各章のタイトルとそれぞれのページ数を紹介します。

1. Fundamentals: 36
2. The Control Flow Graph: 52
3. Data Dependence Analysis: 14
4. Dataflow Analysis: 32
5. Optimization on SSA Form: 76
6. Instruction Scheduling: 16
7. Resister Allocation: 14
8. Whole-program optimization: 4
9. LLVM: 10
10. Performance Measurements: 4

このうち，第9章，第10章はページ数からも分かるとおり，おまけ程度の記載です。これらを期待して買うとガッカリします。

それぞれの解析の用途がわかる達人だったら，目次を見ただけで，期待値が高まることでしょう。目次の次のページに掲載しているアルゴリズムの一覧もあるので，それらを活用して必要な時に辞書的な使い方をするというのもありです。

本記事は，コンパイラの基礎は学習済で，私にそそのかされて，この書籍を買ってはみたものの，この各章のタイトルを読んだだけでは，ピンとこない人向けの記事です。

# 斜め読みするポイント

この書籍が何に役立つのかを知るためには，次の箇所を斜め読みすると良いです。

* 1.1節 Introduction
* 第2〜6章の各章の第1パラグラフ (第7章以降も第1パラグラフを読むと良いのですが，少し分量が多くなります。ざっと掴むには第6章までで良いかも)
* 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8 の各節の第1パラグラフ

最適化コンパイラを作りたいという意欲がある初学者にとっては，これらを読むことで，読破するモチベーションが高まるものと思います！

# おわりに

この書籍は，意外なことに，基本的に数学の本なので，頭からていねいに読まないと身につかないものと思います。でもそういう人は，作りたい気持ちが先行すると思うので，このような記事を書いてみました。数学は基礎の積み上げが大事だけど，それに立ち向かうのには途切れることがないモチベーションがいるものなので，その助けになればと思います。





