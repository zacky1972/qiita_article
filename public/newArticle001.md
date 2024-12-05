---
title: 'SME日記その3: Apple Silicon M4にどの命令が実装されているかを`sysctl hw`の実行結果tとドキュメントから推測する'
tags:
  - assembly
  - Elixir
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: '2024-12-05T21:09:22+09:00'
id: 427035001554cb9768bc
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
前回の記事で，Apple Silicon M4に実装されているものと思っていたCVTW命令が意外にも実装されていなかったことを踏まえると，Apple Silicon M4にどの命令が実装されているかを知る必要があるのですが，1つ1つ命令をコンパイルして実行して確かめるのだと効率が悪すぎます．そこで，`sysctl hw`の実行結果とドキュメントから推測する方法について検討してみます．

SMEシリーズ

- [Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている](https://qiita.com/zacky1972/items/69fd802fd41ae4d7d469)
- [SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension(SME)のベクトル長(SVL)を取得する](https://qiita.com/zacky1972/items/231fd22a1fdef15d4108)
- [SME日記その2: Apple Silicon M4にはCVTW命令は備わっていない？](https://qiita.com/zacky1972/items/a4fc98614df085586175)

```txt:sysctl hw 実行結果抜粋
hw.optional.arm.FEAT_SME: 1
hw.optional.arm.FEAT_SME2: 1
hw.optional.arm.SME_F32F32: 1
hw.optional.arm.SME_BI32I32: 1
hw.optional.arm.SME_B16F32: 1
hw.optional.arm.SME_F16F32: 1
hw.optional.arm.SME_I8I32: 1
hw.optional.arm.SME_I16I32: 1
hw.optional.arm.FEAT_SME_F64F64: 1
hw.optional.arm.FEAT_SME_I16I64: 1
```

ドキュメントを読んでみます．

https://developer.arm.com/documentation/109697/2024_09/Feature-descriptions/The-Armv9-2-architecture-extension

> FEAT_SME, Scalable Matrix Extension
> FEAT_SME introduces two AArch64 execution modes that can be enabled and disabled by application software:
> In ZA storage enabled mode, scalable, two-dimensional, architectural ZA tile storage becomes available and instructions are defined to load, store, extract, insert, and clear rows and columns of the ZA tiles.
> In Streaming SVE mode, the Effective SVE vector length changes to match the Effective ZA tile width, support for a substantial subset of the SVE2 instruction set is available, and, when ZA mode is also enabled, instructions are defined that accumulate the matrix outer product of two SVE vectors into a ZA tile.
> This feature is supported in AArch64 state only.
> FEAT_SME is OPTIONAL from Armv9.2.
> If FEAT_SME is implemented, then FEAT_FCMA, FEAT_FP16, FEAT_BF16, and FEAT_FHM are implemented.
> When FEAT_SME and FEAT_EL2 are implemented, FEAT_FGT and FEAT_HCX are implemented.
> When FEAT_SME and FEAT_PMUv3 are implemented, FEAT_PMUv3p1 is implemented.
> The following field identifies the presence of FEAT_SME:
> ID_AA64PFR1_EL1.SME.
> If FEAT_SME is implemented, this does not imply that FEAT_SVE and FEAT_SVE2 are implemented when the PE is not in Streaming SVE mode.
> For more information, see ‘The Scalable Matrix Extension’.

> FEAT_SME、スケーラブル マトリックス拡張
> FEAT_SME は、アプリケーション ソフトウェアによって有効化および無効化できる 2 つの AArch64 実行モードを導入します。
> ZA ストレージ有効モードでは、スケーラブルな 2 次元アーキテクチャ ZA タイル ストレージが使用可能になり、ZA タイルの行と列をロード、保存、抽出、挿入、およびクリアするための命令が定義されます。
> ストリーミング SVE モードでは、有効な SVE ベクトルの長さが有効な ZA タイルの幅に合わせて変更され、SVE2 命令セットのか​​なりのサブセットのサポートが使用可能になり、ZA モードも有効になっている場合は、2 つの SVE ベクトルのマトリックス外積を ZA タイルに累積する命令が定義されます。
> この機能は、AArch64 状態でのみサポートされます。
> FEAT_SME は、Armv9.2 以降ではオプションです。
> FEAT_SME が実装されている場合、FEAT_FCMA、FEAT_FP16、FEAT_BF16、および FEAT_FHM が実装されます。
> FEAT_SME と FEAT_EL2 が実装されている場合、FEAT_FGT と FEAT_HCX が実装されます。
> FEAT_SME と FEAT_PMUv3 が実装されている場合、FEAT_PMUv3p1 が実装されます。
> 次のフィールドは、FEAT_SME の存在を識別します:
> ID_AA64PFR1_EL1.SME。
> FEAT_SME が実装されている場合、PE がストリーミング SVE モードではないときに FEAT_SVE と FEAT_SVE2 が実装されていることを意味するものではありません。
> 詳細については、「スケーラブル マトリックス拡張」を参照してください。

ここに注目します．

> If FEAT_SME is implemented, this does not imply that FEAT_SVE and FEAT_SVE2 are implemented when the PE is not in Streaming SVE mode.
> FEAT_SME が実装されている場合、PE がストリーミング SVE モードではないときに FEAT_SVE と FEAT_SVE2 が実装されていることを意味するものではありません。

一方，CNTW命令は下記のとおりで，FEAT_SVEに属します．

https://developer.arm.com/documentation/ddi0602/2024-09/SVE-Instructions/CNTB--CNTD--CNTH--CNTW--Set-scalar-to-multiple-of-predicate-constraint-element-count-?lang=en

```c
if !IsFeatureImplemented(FEAT_SVE) && !IsFeatureImplemented(FEAT_SME) then
    EndOfDecode(Decode_UNDEF);
constant integer esize = 32;
constant integer d = UInt(Rd);
constant bits(5) pat = pattern;
constant integer imm = UInt(imm4) + 1;
```

```c
CheckSVEEnabled();
constant integer count = DecodePredCount(pat, esize);
X[d, 64] = (count * imm)<63:0>;
```

[前回](https://qiita.com/zacky1972/items/a4fc98614df085586175)の実行結果ではCNTW命令を実行すると，下記のようにエラーになりました．

```zsh
% ./cntw                                     
zsh: illegal hardware instruction  ./cntw
```

これは必ずしも命令が備わっていないということではなく，Stream SVE modeではなかったためにFEAT_SVEの命令が実行できずにエラーになったということを意味するのではないでしょうか．

Stream SVE modeに切り替える方法がわかれば，この仮説を確かめることができます．その点については，後日検討しましょう．

ここで，命令のドキュメントを見ると，備えている拡張と命令の対応関係がわかりそうですが，1つ1つの命令を確かめないといけないのは大変です．一網打尽に知る方法は無いものでしょうか．

そのうち，Elixir+Reqで解析するプログラムを書いてみようかと思います．
