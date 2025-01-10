---
title: SME日記その20 SSCALをScalable Matrix Extensionで書いたけど，単純なforループの方が速かった件について
tags:
  - C
  - BLAS
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2025-01-10T12:52:13+09:00'
id: 02829310e691d3380f5d
organization_url_name: null
slide: false
ignorePublish: false
---
[SME日記その19 SMEでベクトルのスカラー倍を記述してみる](https://qiita.com/zacky1972/items/95f6a4a4f47205299df6)のプログラムについて，研究論文にしようと目論んで，フェアで厳正な比較になるようにベンチマークプログラムをCで書き直してみたのですが，残念ながらポジティブな結果は出なかったので，Qiita記事として公開して供養します．

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
- [SME日記その16 Scalable Matrix Extension (SME)の研究の今後の展望についての技術的ポエム](https://qiita.com/zacky1972/items/34ff853daebaf24761a4)
- [SME日記その17 __arm_new("za")について調べる Part.2](https://qiita.com/zacky1972/items/ecf250b81e9e2afa8ab2)
- [SME日記その18 SMEが使えるかどうかをElixirから判定する](https://qiita.com/zacky1972/items/ab2ebbb0a23d5709efe0)
- [SME日記その19 SMEでベクトルのスカラー倍を記述してみる](https://qiita.com/zacky1972/items/95f6a4a4f47205299df6)

## プログラム

https://github.com/zacky1972/sscal_sme/tree/v0.1.0

## 実行結果

```zsh
apple_blas: vec_size: 1000
sscal1
time: 5000005000 (nano sec)
count: 708787
IPS: 0.014176 (giga)
average: 70.543125 (nano sec)
apple_blas: vec_size: 10000
sscal1
time: 5000003000 (nano sec)
count: 233300
IPS: 0.004666 (giga)
average: 214.316459 (nano sec)
apple_blas: vec_size: 100000
sscal1
time: 5000182000 (nano sec)
count: 10790
IPS: 0.000216 (giga)
average: 4634.088971 (nano sec)
apple_blas: vec_size: 1000000
sscal1
time: 5004379000 (nano sec)
count: 893
IPS: 0.000018 (giga)
average: 56040.078387 (nano sec)
apple_blas: vec_size: 10000000
sscal1
time: 5016981000 (nano sec)
count: 88
IPS: 0.000002 (giga)
average: 570111.477273 (nano sec)
----
apple_blas: vec_size: 1000
sscal_scopy
time: 5000000000 (nano sec)
count: 379614
IPS: 0.007592 (giga)
average: 131.712740 (nano sec)
apple_blas: vec_size: 10000
sscal_scopy
time: 5000031000 (nano sec)
count: 126990
IPS: 0.002540 (giga)
average: 393.734231 (nano sec)
apple_blas: vec_size: 100000
sscal_scopy
time: 5000264000 (nano sec)
count: 5492
IPS: 0.000110 (giga)
average: 9104.632192 (nano sec)
apple_blas: vec_size: 1000000
sscal_scopy
time: 5002104000 (nano sec)
count: 505
IPS: 0.000010 (giga)
average: 99051.564356 (nano sec)
apple_blas: vec_size: 10000000
sscal_scopy
time: 5118143000 (nano sec)
count: 41
IPS: 0.000001 (giga)
average: 1248327.560976 (nano sec)
====
open_blas: vec_size: 1000
sscal1
time: 5000003000 (nano sec)
count: 752298
IPS: 0.015046 (giga)
average: 66.463064 (nano sec)
open_blas: vec_size: 10000
sscal1
time: 5000009000 (nano sec)
count: 85504
IPS: 0.001710 (giga)
average: 584.769017 (nano sec)
open_blas: vec_size: 100000
sscal1
time: 5000365000 (nano sec)
count: 7809
IPS: 0.000156 (giga)
average: 6403.335894 (nano sec)
open_blas: vec_size: 1000000
sscal1
time: 5001879000 (nano sec)
count: 732
IPS: 0.000015 (giga)
average: 68331.680328 (nano sec)
open_blas: vec_size: 10000000
sscal1
time: 5012390000 (nano sec)
count: 128
IPS: 0.000003 (giga)
average: 391592.968750 (nano sec)
----
open_blas: vec_size: 1000
sscal_scopy
time: 5000010000 (nano sec)
count: 425703
IPS: 0.008514 (giga)
average: 117.453013 (nano sec)
open_blas: vec_size: 10000
sscal_scopy
time: 5000113000 (nano sec)
count: 42188
IPS: 0.000844 (giga)
average: 1185.197924 (nano sec)
open_blas: vec_size: 100000
sscal_scopy
time: 5006672000 (nano sec)
count: 636
IPS: 0.000013 (giga)
average: 78721.257862 (nano sec)
open_blas: vec_size: 1000000
sscal_scopy
time: 5005451000 (nano sec)
count: 319
IPS: 0.000006 (giga)
average: 156910.689655 (nano sec)
open_blas: vec_size: 10000000
sscal_scopy
time: 5019305000 (nano sec)
count: 66
IPS: 0.000001 (giga)
average: 760500.757576 (nano sec)
====
sme: vec_size: 1000
sscal1
time: 5000007000 (nano sec)
count: 617882
IPS: 0.012358 (giga)
average: 80.921713 (nano sec)
sme: vec_size: 10000
sscal1
time: 5000011000 (nano sec)
count: 74765
IPS: 0.001495 (giga)
average: 668.763593 (nano sec)
sme: vec_size: 100000
sscal1
time: 5000040000 (nano sec)
count: 6579
IPS: 0.000132 (giga)
average: 7600.000000 (nano sec)
sme: vec_size: 1000000
sscal1
time: 5004946000 (nano sec)
count: 587
IPS: 0.000012 (giga)
average: 85263.134583 (nano sec)
sme: vec_size: 10000000
sscal1
time: 5063235000 (nano sec)
count: 59
IPS: 0.000001 (giga)
average: 858175.423729 (nano sec)
----
sme: vec_size: 1000
sscal_scopy
time: 5000001000 (nano sec)
count: 619006
IPS: 0.012380 (giga)
average: 80.774677 (nano sec)
sme: vec_size: 10000
sscal_scopy
time: 5000026000 (nano sec)
count: 74957
IPS: 0.001499 (giga)
average: 667.052577 (nano sec)
sme: vec_size: 100000
sscal_scopy
time: 5000862000 (nano sec)
count: 5302
IPS: 0.000106 (giga)
average: 9432.029423 (nano sec)
sme: vec_size: 1000000
sscal_scopy
time: 5008793000 (nano sec)
count: 545
IPS: 0.000011 (giga)
average: 91904.458716 (nano sec)
sme: vec_size: 10000000
sscal_scopy
time: 5076061000 (nano sec)
count: 54
IPS: 0.000001 (giga)
average: 940011.296296 (nano sec)
====
clang_for: vec_size: 1000
sscal1
time: 5000001000 (nano sec)
count: 866779
IPS: 0.017336 (giga)
average: 57.684842 (nano sec)
clang_for: vec_size: 10000
sscal1
time: 5000052000 (nano sec)
count: 91395
IPS: 0.001828 (giga)
average: 547.081569 (nano sec)
clang_for: vec_size: 100000
sscal1
time: 5000223000 (nano sec)
count: 8554
IPS: 0.000171 (giga)
average: 5845.479308 (nano sec)
clang_for: vec_size: 1000000
sscal1
time: 5000314000 (nano sec)
count: 760
IPS: 0.000015 (giga)
average: 65793.605263 (nano sec)
clang_for: vec_size: 10000000
sscal1
time: 5022664000 (nano sec)
count: 76
IPS: 0.000002 (giga)
average: 660876.842105 (nano sec)
----
clang_for: vec_size: 1000
sscal_scopy
time: 5000012000 (nano sec)
count: 391175
IPS: 0.007823 (giga)
average: 127.820336 (nano sec)
clang_for: vec_size: 10000
sscal_scopy
time: 5000018000 (nano sec)
count: 73085
IPS: 0.001462 (giga)
average: 684.137374 (nano sec)
clang_for: vec_size: 100000
sscal_scopy
time: 5000162000 (nano sec)
count: 6969
IPS: 0.000139 (giga)
average: 7174.862965 (nano sec)
clang_for: vec_size: 1000000
sscal_scopy
time: 5004389000 (nano sec)
count: 709
IPS: 0.000014 (giga)
average: 70583.765867 (nano sec)
clang_for: vec_size: 10000000
sscal_scopy
time: 5001674000 (nano sec)
count: 70
IPS: 0.000001 (giga)
average: 714524.857143 (nano sec)
```

単位ナノ秒

|size|Apple BLAS SSCAL|Apple BLAS SCOPY+SSCAL|Open BLAS SSCAL|OpenBLAS SCOPY+SSCAL|SME SSCAL|SME fused SCOPY+SSCAL|Clang simple for loop -O3 SSCAL|Clang simple for loop -O3 fused SCOPY+SSCAL|
|-------:|-----:|------:|-----:|-----:|-----:|-----:|-----:|-----:|
|    1000|    71|    132|    66|   117|    81|    81|    58|   128|
|   10000|   214|    394|   585|  1185|   669|   667|   547|   684|
|  100000|  4634|   9105|  6403| 78721|  7600|  9432|  5845|  7175|
| 1000000| 56040|  99052| 68332|156911| 85263| 91904| 65794| 70584|
|10000000|570111|1248328|391593|760501|858175|940011|660877|714525|

Scalable Matrix Extensionを使ったプログラムはほぼ惨敗です．単純なforループ(Clang simple for loop -O3)が思ったより速いですね．OpenBLAS SCOPY+SSCALの挙動が若干不可解で，大きい配列の時にOpenBLAS SSCALよりも速くなります．

