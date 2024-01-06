---
title: その1 Nerves化構想を思い立つ〜Arch Linuxを元にT2チップを備えない古いIntel MacをNerves化しようとする日々
tags:
  - Mac
  - archLinux
  - Elixir
  - Nerves
private: false
updated_at: '2024-01-05T18:00:41+09:00'
id: d1da49dedfaafae57cbb
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
「Arch LinuxをT2チップを備えない古いIntel Macにインストールしようとする日々」シリーズに取り組んでいて，「Arch Linuxを元にT2チップを備えない古いIntel MacをNerves化しよう」という構想が沸々と湧いてまいりました．引き続き，駄文を連ねていこうと思います．

## 背景

2023年末， @pojiro に依頼して，Zybo Z7-10へのNerves移植を進めてきました．@pojiro が[Nerves 大好きな私が2023年にやったこと](https://qiita.com/pojiro/items/e66c1082462b955e83d9#移植)にまとめてくれています．

https://qiita.com/pojiro/items/e66c1082462b955e83d9#移植

気づいた人もいるかと思うのですが，これは，[Nerves，月へ行く](https://qiita.com/zacky1972/items/b9bde6aa6724960340ab)で構想を発表した，月面探査車YAOKI向けのKintex UltraScaleのFPGAボードによるNervesシステムの予行演習に位置付けているものです．

https://qiita.com/zacky1972/items/b9bde6aa6724960340ab

そういうわけで，私の中で，Nerves移植熱が急上昇しております．そして，LinuxとElixir, Nervesの関係性を深く理解したいという意欲に目覚めております．

## Arch Linuxに触れて湧いた，ある意欲

2023年末から，@mnishiguchi の勧めにしたがって，Arch Linuxと戯れてきました．その体験を通して得た経験知を，「Arch LinuxをT2チップを備えない古いIntel Macにインストールしようとする日々」シリーズと銘打ち，下記のようにしたためてきました．

1. [Arch LinuxをブートできるUSBメモリを用意する](https://qiita.com/zacky1972/items/9f447f9a11f91e90f6e8)
2. [デュアル・ブート環境にするためにパーティションを区切る](https://qiita.com/zacky1972/items/4b3d8240ff1f4a599908)
3. [いよいよArch Linuxをインストールする](https://qiita.com/zacky1972/items/da1db6795b84151186ab)
4. [ネットワークの設定を見る](https://qiita.com/zacky1972/items/fcce6bdeaf2b87697e3f)
5. [Mac Pro (Mid 2010)にArch Linuxをインストールする](https://qiita.com/zacky1972/items/2904a0a07f9335fdb2de)
6. [ネットワークが繋がらない最小構成のままElixirをインストールして実行してみる](https://qiita.com/zacky1972/items/9a145632c6c12c650bed)
7. [ネットワークが繋がらない最小構成のままElixirをasdfではなくソースコードビルドしてインストールする](https://qiita.com/zacky1972/items/ab537e53fd30ac0d15a6)

このまま，T2チップを備えない古いIntel MacをArch Linux化していっても良いのですが，6,7でElixirを入れられるということがわかってしまったので，「Nerves化したい！」という意欲が沸々と湧いてまいりました．

## 「Arch Linuxを元にT2チップを備えない古いIntel MacをNerves化しよう」という構想

Arch Linuxを元にすれば，T2チップを備えない古いIntel MacのNerves化は，なんとなく出来そうな予感がします！

つづく

https://qiita.com/zacky1972/items/4ce0032514978a7d2f1f