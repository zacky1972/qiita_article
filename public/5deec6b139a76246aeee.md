---
title: Apple Silicon M2はM1シリーズと比べて命令セットが拡張されている
tags:
  - M1
  - AppleSilicon
  - M2
private: false
updated_at: '2022-08-26T21:06:17+09:00'
id: 5deec6b139a76246aeee
organization_url_name: null
slide: false
ignorePublish: false
---
`sysctl hw`を実行するとサポートされている命令セットなどが出ますが，Apple Silicon M2はM1シリーズと比べて命令セットが拡張されていることがわかりました．

```txt:sysctl hw 相違点
hw.perflevel0.l2cachesize: 12582912 → 16777216
hw.optional.arm.FEAT_PAuth2: 0 → 1
hw.optional.arm.FEAT_FPAC: 0 → 1
hw.optional.arm.FEAT_BF16: 0 → 1
hw.optional.arm.FEAT_I8MM: 0 → 1
hw.optional.arm.FEAT_BTI: 0 → 1
hw.cpufamily: 458787763 → -634136515
hw.targettype: J313 → J413
```

* `hw.memsize`も違っていましたが，それはメモリ容量が違うから．

違いをそれぞれ見ていきます．

* `hw.perflevel0.l2cachesize`: L2キャッシュサイズが12MBから16MBに増えたということです．`hw.perflevel1.l2cachesize`というのもあって，こちらは変わらず4MBですが，これらの違いはなんでしょうか？ 前者がPコアで，後者がEコアなのか？
* `hw.optional.arm.FEAT_PAuth2`: Armv8.3のEnhancements to pointer authentication で，ポインタを偽造されないようにするセキュリティ機能だそうです．
* `hw.optional.arm.FEAT_FPAC`: Armv8.3のFaulting on pointer authentication instructionsで，偽造されたポインタを検出します．
* `hw.optional.arm.FEAT_BF16`: Armv8.2のAARch64 BFloat16 instructionsです．精度を落として並列度を上げた演算命令です．これは嬉しい！
* `hw.optional.arm.FEAT_I8MM`: Armv8.2のInt8 Matrix Multiplicationです．整数の行列積ですね．これも嬉しい！
* `hw.optional.arm.FEAT_BTI`: Armv8.5のBranch target identificationです．間接分岐命令に対する攻撃を防ぐそうです．
* `hw.cpufamily`と`hw.targettype`はCPUの種類を表しているようです．


参考: 
* https://developer.arm.com/downloads/-/exploration-tools/feature-names-for-a-profile
* https://community.arm.com/arm-community-blogs/b/architectures-and-processors-blog/posts/armv8-1-m-pointer-authentication-and-branch-target-identification-extension

## どのような影響が考えられるか？

* セキュリティ関連の命令(FEAT_PAuth2, FEAT_FPAC, FEAT_BTI)の導入で，より強固なセキュリティになろうかと思います．
* 効率の良い演算命令(FEAT_BF16, FEAT_I8MM)の導入で，機械学習方面への応用が期待されます．
* これらはカーネル関連の命令というわけではないので可能性は低いかもしれませんが，macOSの今後のアップデートにより，M2より先にM1がサポート外になる可能性が少しあります．


## sysctl hw 出力結果(M1)

```txt:sysctl hw 出力結果(M1)
% sysctl hw
hw.ncpu: 8
hw.byteorder: 1234
hw.memsize: 17179869184
hw.activecpu: 8
hw.perflevel0.physicalcpu: 4
hw.perflevel0.physicalcpu_max: 4
hw.perflevel0.logicalcpu: 4
hw.perflevel0.logicalcpu_max: 4
hw.perflevel0.l1icachesize: 196608
hw.perflevel0.l1dcachesize: 131072
hw.perflevel0.l2cachesize: 12582912
hw.perflevel0.cpusperl2: 4
hw.perflevel1.physicalcpu: 4
hw.perflevel1.physicalcpu_max: 4
hw.perflevel1.logicalcpu: 4
hw.perflevel1.logicalcpu_max: 4
hw.perflevel1.l1icachesize: 131072
hw.perflevel1.l1dcachesize: 65536
hw.perflevel1.l2cachesize: 4194304
hw.perflevel1.cpusperl2: 4
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
hw.optional.arm.FEAT_PAuth2: 0
hw.optional.arm.FEAT_FPAC: 0
hw.optional.arm.FEAT_DPB: 1
hw.optional.arm.FEAT_DPB2: 1
hw.optional.arm.FEAT_BF16: 0
hw.optional.arm.FEAT_I8MM: 0
hw.optional.arm.FEAT_ECV: 1
hw.optional.arm.FEAT_LSE2: 1
hw.optional.arm.FEAT_CSV2: 1
hw.optional.arm.FEAT_CSV3: 1
hw.optional.arm.FEAT_FP16: 1
hw.optional.arm.FEAT_SSBS: 1
hw.optional.arm.FEAT_BTI: 0
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
hw.physicalcpu: 8
hw.physicalcpu_max: 8
hw.logicalcpu: 8
hw.logicalcpu_max: 8
hw.cputype: 16777228
hw.cpusubtype: 2
hw.cpu64bit_capable: 1
hw.cpufamily: 458787763
hw.cpusubfamily: 2
hw.cacheconfig: 8 1 4 0 0 0 0 0 0 0
hw.cachesize: 3499458560 65536 4194304 0 0 0 0 0 0 0
hw.pagesize: 16384
hw.pagesize32: 16384
hw.cachelinesize: 128
hw.l1icachesize: 131072
hw.l1dcachesize: 65536
hw.l2cachesize: 4194304
hw.tbfrequency: 24000000
hw.packages: 1
hw.osenvironment: 
hw.ephemeral_storage: 0
hw.use_recovery_securityd: 0
hw.use_kernelmanagerd: 1
hw.serialdebugmode: 0
hw.nperflevels: 2
hw.targettype: J313
```

## sysctl hw 出力結果(M2)

```txt:sysctl hw 出力結果(M2)
% sysctl hw
hw.ncpu: 8
hw.byteorder: 1234
hw.memsize: 25769803776
hw.activecpu: 8
hw.perflevel0.physicalcpu: 4
hw.perflevel0.physicalcpu_max: 4
hw.perflevel0.logicalcpu: 4
hw.perflevel0.logicalcpu_max: 4
hw.perflevel0.l1icachesize: 196608
hw.perflevel0.l1dcachesize: 131072
hw.perflevel0.l2cachesize: 16777216
hw.perflevel0.cpusperl2: 4
hw.perflevel1.physicalcpu: 4
hw.perflevel1.physicalcpu_max: 4
hw.perflevel1.logicalcpu: 4
hw.perflevel1.logicalcpu_max: 4
hw.perflevel1.l1icachesize: 131072
hw.perflevel1.l1dcachesize: 65536
hw.perflevel1.l2cachesize: 4194304
hw.perflevel1.cpusperl2: 4
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
hw.optional.arm.FEAT_ECV: 1
hw.optional.arm.FEAT_LSE2: 1
hw.optional.arm.FEAT_CSV2: 1
hw.optional.arm.FEAT_CSV3: 1
hw.optional.arm.FEAT_FP16: 1
hw.optional.arm.FEAT_SSBS: 1
hw.optional.arm.FEAT_BTI: 1
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
hw.physicalcpu: 8
hw.physicalcpu_max: 8
hw.logicalcpu: 8
hw.logicalcpu_max: 8
hw.cputype: 16777228
hw.cpusubtype: 2
hw.cpu64bit_capable: 1
hw.cpufamily: -634136515
hw.cpusubfamily: 2
hw.cacheconfig: 8 1 4 0 0 0 0 0 0 0
hw.cachesize: 3499458560 65536 4194304 0 0 0 0 0 0 0
hw.pagesize: 16384
hw.pagesize32: 16384
hw.cachelinesize: 128
hw.l1icachesize: 131072
hw.l1dcachesize: 65536
hw.l2cachesize: 4194304
hw.tbfrequency: 24000000
hw.packages: 1
hw.osenvironment: 
hw.ephemeral_storage: 0
hw.use_recovery_securityd: 0
hw.use_kernelmanagerd: 1
hw.serialdebugmode: 0
hw.nperflevels: 2
hw.targettype: J413
```






