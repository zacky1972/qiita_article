---
title: DRP-AI日記その1 なぜDRP-AIシリーズに取り組むのか
tags:
  - DRP-AI
  - Kakip
  - AI
  - Elixir
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
このたび，DRP-AIシリーズ・Kakip Advent Calendar 2024を始めました．その目的について語ってみたいと思います．

## 公式ページ

https://www.renesas.com/ja/software-tool/ai-accelerator-drp-ai?srsltid=AfmBOopZlHrDgHbpRxv8I1e0MpFAc7h_kgfaF04RBa0iucxujQ6asizl

> ディープラーニングによる人工知能(AI)技術は、すでにITの世界で様々な新しい価値の提供を始めており、組込み用途での活用が望まれています。
> しかし、一般的に画像などを用いたAIの処理には従来のソフトウェアに比べて桁違いに大量の演算が必要であり、CPUやGPUのような従来のソリューションでは電力が大きすぎて組込み用途に使えないという課題がありました。一方、AIの世界は常に進化を続けており、今もなお新たなアルゴリズムが開発されています。
> ルネサスは、この急速なAIの進化の中で、「高い性能と低消費電力」に加え、「進化に対応できる柔軟性」の両方を兼ね備えたAIアクセラレータ「DRP-AI」を開発し、これを搭載した組込みAIプロセッサ RZ/Vシリーズの提供を始めました。

## 性能について

Kakipでも採用されたルネサスエレクトロニクスDRP-AI3は最大80TOPS(おそらくINT8)，10TOPS/Wというような性能を発揮するとしています．

## 計画

[北九州産業学術推進機構(FAIS)の宇宙関連機器新技術開発事業の研究開発プロジェクトを行います](https://zacky1972.github.io/blog/2024/07/19/computer-and-software-for-spacecrafts-and-satellites.html
)

https://zacky1972.github.io/blog/2024/07/19/computer-and-software-for-spacecrafts-and-satellites.html

> ルネサス エレクトロニクス DRP-AI向け機械学習基盤の整備

というわけで，DRP-AIシリーズを使った機械学習基盤の研究開発を行うという名目で研究費をいただいています．具体的には，Elixirの機械学習基盤NxからDRP-AIシリーズを活用する基礎研究を行うというものです．

その背景については，おいおい明かしていきたいと思います．つづく．