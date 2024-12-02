---
title: Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている
tags:
  - M4
  - M3
  - M1
  - AppleSilicon
  - M2
private: false
updated_at: '2024-12-02T19:40:14+09:00'
id: 69fd802fd41ae4d7d469
organization_url_name: null
slide: false
ignorePublish: false
---
`sysctl hw`を実行するとサポートされているCPU命令セットなどが出ますが，Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されていることがわかりました．

```txt:sysctl hw 相違点(M3→M4)
< hw.optional.arm.FEAT_WFxT: 0
> hw.optional.arm.FEAT_WFxT: 1
< hw.optional.arm.FEAT_SSBS: 1
> hw.optional.arm.FEAT_SSBS: 0
< hw.optional.arm.FEAT_SME: 0
< hw.optional.arm.FEAT_SME2: 0
< hw.optional.arm.SME_F32F32: 0
< hw.optional.arm.SME_BI32I32: 0
< hw.optional.arm.SME_B16F32: 0
< hw.optional.arm.SME_F16F32: 0
< hw.optional.arm.SME_I8I32: 0
< hw.optional.arm.SME_I16I32: 0
< hw.optional.arm.FEAT_SME_F64F64: 0
< hw.optional.arm.FEAT_SME_I16I64: 0
> hw.optional.arm.FEAT_SME: 1
> hw.optional.arm.FEAT_SME2: 1
> hw.optional.arm.SME_F32F32: 1
> hw.optional.arm.SME_BI32I32: 1
> hw.optional.arm.SME_B16F32: 1
> hw.optional.arm.SME_F16F32: 1
> hw.optional.arm.SME_I8I32: 1
> hw.optional.arm.SME_I16I32: 1
> hw.optional.arm.FEAT_SME_F64F64: 1
> hw.optional.arm.FEAT_SME_I16I64: 1
< hw.targettype: J516c
> hw.targettype: J773s
```

`FEAT_WFxT` は Armv8.7 で追加された拡張命令で，次のような説明でした．

> FEAT_WFxT, WFE and WFI instructions with timeout
> FEAT_WFxT introduces WFET and WFIT. These instructions support the generation of a local timeout event to act as a wake-up event for the PE when the virtual count in CNTVCT_EL0 equals or exceeds the value supplied by the instruction for the first time.
> FEAT_WFxT は WFET と WFIT を導入します。これらの命令は、CNTVCT_EL0 の仮想カウントが命令によって初めて指定された値と等しいかそれを超えたときに、PE のウェイクアップ イベントとして機能するローカル タイムアウト イベントの生成をサポートします。

https://developer.arm.com/documentation/109697/2024_09/Feature-descriptions/The-Armv8-7-architecture-extension

`FEAT_SSBS` は Armv8.5で追加された拡張命令で，次のような説明でした．

> FEAT_SSBS, Speculative Store Bypass Safe
> FEAT_SSBS allows software to indicate whether hardware is permitted to load or store speculatively in a manner that could give rise to a cache timing side channel, which in turn could be used to derive an address from values loaded to a register from memory.
> FEAT_SSBS を使用すると、ソフトウェアは、キャッシュ タイミング サイド チャネルを発生させる可能性のある方法でハードウェアが投機的にロードまたは保存することを許可されているかどうかを示すことができます。これにより、メモリからレジスタにロードされた値からアドレスを導出できるようになります。

`FEAT_SME`はArmv9.2で追加された拡張命令で，次のような説明でした．

> FEAT_SME, Scalable Matrix Extension
> FEAT_SME introduces two AArch64 execution modes that can be enabled and disabled by application software:
> * In ZA storage enabled mode, scalable, two-dimensional, architectural ZA tile storage becomes available and instructions are defined to load, store, extract, insert, and clear rows and columns of the ZA tiles.
> * In Streaming SVE mode, the Effective SVE vector length changes to match the Effective ZA tile width, support for a substantial subset of the SVE2 instruction set is available, and, when ZA mode is also enabled, instructions are defined that accumulate the matrix outer product of two SVE vectors into a ZA tile.
> FEAT_SME は、アプリケーション ソフトウェアによって有効化および無効化できる 2 つの AArch64 実行モードを導入します。
> * ZA ストレージ有効モードでは、スケーラブルな 2 次元のアーキテクチャ ZA タイル ストレージが使用可能になり、ZA タイルの行と列をロード、保存、抽出、挿入、およびクリアするための命令が定義されます。
> * ストリーミング SVE モードでは、有効な SVE ベクトルの長さが有効な ZA タイルの幅に合わせて変更され、SVE2 命令セットのか​​なりのサブセットのサポートが利用可能になり、ZA モードも有効になっている場合は、2 つの SVE ベクトルのマトリックス外積を ZA タイルに累積する命令が定義されます。

`FEAT_SME2`はArmv9.3で追加された拡張命令で，次のような説明でした．

> FEAT_SME2, Scalable Matrix Extensions version 2
> FEAT_SME2 is a superset of FEAT_SME that introduces the following:
> * The ability to treat the SME ZA array as containing addressable groups of one-dimensional ZA array vectors, instead of two-dimensional ZA tiles.
> * Multi-vector instructions that operate on groups of Z vector registers and ZA array vectors.
> * A multi-vector predication mechanism for multi-vector load and store.
> * A dedicated 512-bit lookup table register, ZT0, for data decompression.
> FEAT_SME2 は FEAT_SME のスーパーセットで、次の機能を導入しています:
> * SME ZA 配列を、2 次元 ZA タイルではなく、1 次元 ZA 配列ベクトルのアドレス指定可能なグループを含むものとして扱う機能。
> * Z ベクトル レジスタと ZA 配列ベクトルのグループを操作するマルチベクトル命令。
> * マルチベクトルのロードとストアのためのマルチベクトル予測メカニズム。
> * データ解凍用の専用の 512 ビット ルックアップ テーブル レジスタ ZT0。

## `sysctl hw` 全出力結果

```txt:sysctl hw(M4 Pro)
hw.ncpu: 14
hw.byteorder: 1234
hw.memsize: 68719476736
hw.activecpu: 14
hw.perflevel0.physicalcpu: 10
hw.perflevel0.physicalcpu_max: 10
hw.perflevel0.logicalcpu: 10
hw.perflevel0.logicalcpu_max: 10
hw.perflevel0.l1icachesize: 196608
hw.perflevel0.l1dcachesize: 131072
hw.perflevel0.l2cachesize: 16777216
hw.perflevel0.cpusperl2: 5
hw.perflevel0.name: Performance
hw.perflevel1.physicalcpu: 4
hw.perflevel1.physicalcpu_max: 4
hw.perflevel1.logicalcpu: 4
hw.perflevel1.logicalcpu_max: 4
hw.perflevel1.l1icachesize: 131072
hw.perflevel1.l1dcachesize: 65536
hw.perflevel1.l2cachesize: 4194304
hw.perflevel1.cpusperl2: 4
hw.perflevel1.name: Efficiency
hw.optional.arm.FEAT_FlagM: 1
hw.optional.arm.FEAT_FlagM2: 1
hw.optional.arm.FEAT_FHM: 1
hw.optional.arm.FEAT_DotProd: 1
hw.optional.arm.FEAT_SHA3: 1
hw.optional.arm.FEAT_RDM: 1
hw.optional.arm.FEAT_LSE: 1
hw.optional.arm.FEAT_SHA256: 1
hw.optional.arm.FEAT_SHA512: 1
hw.optional.arm.FEAT_SHA1: 1
hw.optional.arm.FEAT_AES: 1
hw.optional.arm.FEAT_PMULL: 1
hw.optional.arm.FEAT_SPECRES: 0
hw.optional.arm.FEAT_SB: 1
hw.optional.arm.FEAT_FRINTTS: 1
hw.optional.arm.FEAT_LRCPC: 1
hw.optional.arm.FEAT_LRCPC2: 1
hw.optional.arm.FEAT_FCMA: 1
hw.optional.arm.FEAT_JSCVT: 1
hw.optional.arm.FEAT_PAuth: 1
hw.optional.arm.FEAT_PAuth2: 1
hw.optional.arm.FEAT_FPAC: 1
hw.optional.arm.FEAT_DPB: 1
hw.optional.arm.FEAT_DPB2: 1
hw.optional.arm.FEAT_BF16: 1
hw.optional.arm.FEAT_I8MM: 1
hw.optional.arm.FEAT_WFxT: 1
hw.optional.arm.FEAT_RPRES: 1
hw.optional.arm.FEAT_ECV: 1
hw.optional.arm.FEAT_AFP: 1
hw.optional.arm.FEAT_LSE2: 1
hw.optional.arm.FEAT_CSV2: 1
hw.optional.arm.FEAT_CSV3: 1
hw.optional.arm.FEAT_DIT: 1
hw.optional.arm.FEAT_FP16: 1
hw.optional.arm.FEAT_SSBS: 0
hw.optional.arm.FEAT_BTI: 1
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
hw.optional.arm.FP_SyncExceptions: 1
hw.optional.arm.caps: 1152375836863623167
hw.optional.floatingpoint: 1
hw.optional.neon: 1
hw.optional.neon_hpfp: 1
hw.optional.neon_fp16: 1
hw.optional.armv8_1_atomics: 1
hw.optional.armv8_2_fhm: 1
hw.optional.armv8_2_sha512: 1
hw.optional.armv8_2_sha3: 1
hw.optional.armv8_3_compnum: 1
hw.optional.watchpoint: 4
hw.optional.breakpoint: 6
hw.optional.armv8_crc32: 1
hw.optional.armv8_gpi: 1
hw.optional.AdvSIMD: 1
hw.optional.AdvSIMD_HPFPCvt: 1
hw.optional.ucnormal_mem: 1
hw.optional.arm64: 1
hw.features.allows_security_research: 0
hw.physicalcpu: 14
hw.physicalcpu_max: 14
hw.logicalcpu: 14
hw.logicalcpu_max: 14
hw.cputype: 16777228
hw.cpusubtype: 2
hw.cpu64bit_capable: 1
hw.cpufamily: 399882554
hw.cpusubfamily: 4
hw.cacheconfig: 14 1 4 0 0 0 0 0 0 0
hw.cachesize: 3534340096 65536 4194304 0 0 0 0 0 0 0
hw.pagesize: 16384
hw.pagesize32: 16384
hw.cachelinesize: 128
hw.l1icachesize: 131072
hw.l1dcachesize: 65536
hw.l2cachesize: 4194304
hw.tbfrequency: 24000000
hw.memsize_usable: 67958849536
hw.packages: 1
hw.osenvironment: 
hw.ephemeral_storage: 0
hw.use_recovery_securityd: 0
hw.use_kernelmanagerd: 1
hw.serialdebugmode: 0
hw.nperflevels: 2
hw.targettype: J773s
```
