---
title: SME日記その9 OpenBLASの対応状況について調べる
tags:
  - assembly
  - M4
  - AppleSilicon
  - SME
  - OpenBLAS
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
ここまで調べて，ふと，OpenBLASやApple Accelerate FrameworkですでにSMEに対応している可能性に思い至り，まずOpenBLASに関して調査をしてみました．

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

## OpenBLASのChangelog.txt

https://github.com/OpenMathLib/OpenBLAS/blob/develop/Changelog.txt

- Version 0.3.28 8-Aug-2024
- Version 0.3.27 4-Apr-2024
- Version 0.3.26 2-Jan-2024
- Version 0.3.25 12-Nov-2023
- Version 0.3.24 03-Sep-2023
- Version 0.3.23 01-Apr-2023
- ...
- Version 0.1 alpha1 20-Mar-2011

SMEを検索しましたが見つかりませんでした．また，Scalable Matrix Extension でも見つかりませんでした．

Version 0.3.28に下記の記述を見つけました．

- added optimized SGEMV and DGEMV kernels for A64FX
- added optimized SVE kernels for small-matrix GEMM
- fixed potential miscompilation of the SVE SDOT and DDOT kernels
- fixed potential miscompilation of the non-SVE CDOT and ZDOT kernels

よって，OpenBLASの現行バージョン(Version 0.3.28)は，SVEに対応していない可能性が高く，これからSVE対応していくものと思います．

