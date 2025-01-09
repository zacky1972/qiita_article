---
title: SME日記その16 Scalable Matrix Extension (SME)の研究の今後の展望についての技術的ポエム
tags:
  - Elixir
  - M4
  - AppleSilicon
  - SME
  - 技術的ポエム
private: false
updated_at: '2025-01-09T11:09:49+09:00'
id: 34ff853daebaf24761a4
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
Scalable Matrix Extension (SME)の研究の今後の展望について技術的ポエムを書いてみました．

SMEシリーズ

- [Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている](https://qiita.com/zacky1972/items/69fd802fd41ae4d7d469)
- [SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension(SME)のベクトル長(SVL)を取得する](https://qiita.com/zacky1972/items/231fd22a1fdef15d4108)
- [SME日記その2: Apple Silicon M4にはCVTW命令は備わっていない？](https://qiita.com/zacky1972/items/a4fc98614df085586175)
- [SME日記その3: Apple Silicon M4にどの命令が実装されているかをsysctl hwの実行結果とドキュメントから推測する](https://qiita.com/zacky1972/items/427035001554cb9768bc)
- [SME日記その4 Streaming SVE modeでCNTWを実行してみる．](https://qiita.com/zacky1972/items/3182fa1693983846205d)
- [SME日記その5 Streaming SVE modeでCNTWを実行してみる Part 2](https://qiita.com/zacky1972/items/b7b5dd456fe021b30eb2)
- [SME日記その6 Streaming SVE modeでsvcntw()とsvcntsw()を実行してみる](https://qiita.com/zacky1972/items/7d4ec630d54564ebb9b3)
- [SME日記その7 svcntw()とRDSVL命令の実行結果の関係性を考察する](https://qiita.com/zacky1972/items/48cf7577e254b8c3a0b6)
- [SME日記その8 __arm_new("za")について調べる](https://qiita.com/zacky1972/items/762b73b3414369d762ad)
- [SME日記その9 OpenBLASのSME対応状況について調べる](https://qiita.com/zacky1972/items/0c6f5aed0365f1b4fdb6)
- [SME日記その10 Streaming SVE modeでCNTWを実行してみる(再考)](https://qiita.com/zacky1972/items/ba3e07a8bc1e5e56d19a)
- [SME日記その11 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.1](https://qiita.com/zacky1972/items/15bca5a0dcd3073d4d60)
- [SME日記その12 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.2](https://qiita.com/zacky1972/items/2d69ed8b7ae5840012db)
- [SME日記その13 OpenBLASのSSCALでSMEが使われているかを検証してみる Part.3](https://qiita.com/zacky1972/items/5fe73657dd1e4b167320)
- [SME日記その14 AppleBLASのSSCALでSMEが使われているかを検証してみる Part.1](https://qiita.com/zacky1972/items/9b22e23cd18a4912b99a)
- [SME日記その15 AppleBLASのSGEMMでSMEが使われているかを検証してみる Part.1](https://qiita.com/zacky1972/items/e6e8d8ebe4400c6ef737)

## Scalable Matrix Extension (SME)について

Scalable Matrix Extension (SME)は，ARM A-Profile の拡張命令で，Apple Silicon M4に搭載された新しい命令セットです．その名の通り，CPUによる高速な行列・ベクトル演算をサポートします．

## Apple Accelerate Frameworkを超えるものを作る

Apple Accelerate Frameworkというものがあります．

https://developer.apple.com/jp/accelerate/

もちろんAppleもSMEをフル活用した上でApple Accelerate Frameworkを構築しているとは思うのですが，コード最適化の研究者としては，それをさらに上回るものを作ってみたいという欲に駆られています．

特に以前，下記について論文を書いたので，CORDICによる三角関数の高速化には是非とも挑戦したいです．

https://qiita.com/zacky1972/items/e3ec1e57168e685e2893

三角関数については，Apple Accelerate Frameworkでは，vForceというのでサポートされています．

https://developer.apple.com/documentation/accelerate/veclib/vforce/

その中でもこれらの関数ですよね．

https://developer.apple.com/documentation/accelerate/vforce/3241296-sincos

https://developer.apple.com/documentation/accelerate/1470504-vvcosisin?language=objc

https://developer.apple.com/documentation/accelerate/1470346-vvsincos?language=objc

行列の乗算とかにも興味あります．

https://developer.apple.com/documentation/accelerate/blas?language=objc

中でも次の関数ですよね．

https://developer.apple.com/documentation/accelerate/1513065-cblas_sgemv

https://developer.apple.com/documentation/accelerate/1513065-cblas_sgemv?language=objc

https://developer.apple.com/documentation/accelerate/1513264-cblas_sgemm

https://developer.apple.com/documentation/accelerate/1513264-cblas_sgemm?language=objc

## NxバックエンドEMLXに貢献する

このような知見を生かして，Apple Silicon向け機械学習ライブラリMLXやApple Silicon向けNxバックエンドEMLXに貢献したいですね．

https://github.com/ml-explore/mlx

https://github.com/elixir-nx/emlx

EMLXについては， @RyoWakabayashi さんが紹介記事を書いています．

https://qiita.com/RyoWakabayashi/items/150b35d97d0b1a70dccc

## 追記: 20240109 SSCAL程度ではSME実行オーバーヘッドの元が取れない

SME命令を実行するにあたって，行列を格納するZAレジスタの退避・復旧を含むオーバーヘッドがかかります．

研究してみてわかったのが，このオーバーヘッドが思ったより大きく，SSCAL(ベクトルとスカラーの積)くらいの演算強度では元が取れないということです．([SME日記その19 SSCALをScalable Matrix Extensionで書いたけど，単純なforループの方が速かった件について](https://qiita.com/zacky1972/items/02829310e691d3380f5d))

この点に留意して，今後も，さらなる研究に邁進します！
