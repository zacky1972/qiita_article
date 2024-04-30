---
title: Apple Silicon M3はM2シリーズとCPU命令セットは同じ
tags:
  - M3
  - M1
  - AppleSilicon
  - M2
private: false
updated_at: '2024-04-30T17:41:05+09:00'
id: 61164dccbb472682e3df
organization_url_name: null
slide: false
ignorePublish: false
---
`sysctl hw`を実行するとサポートされているCPU命令セットなどが出ますが，Apple Silicon M3はM2シリーズとCPU命令セットが同じであることがわかりました．

```txt:sysctl hw 相違点(M2→M3)
hw.cpufamily: -634136515 → 1912690738
hw.cpusubfamily: 2 → 5
hw.targettype: J413 → J516c
```

```txt:sysctl hw 出力結果(M3)
hw.ncpu: 16
hw.byteorder: 1234
hw.memsize: 137438953472
hw.activecpu: 16
hw.features.allows_security_research: 0
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
hw.optional.arm.FEAT_DIT: 1
hw.optional.arm.FEAT_FP16: 1
hw.optional.arm.FEAT_SSBS: 1
hw.optional.arm.FEAT_BTI: 1
hw.optional.arm.FP_SyncExceptions: 1
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
hw.perflevel1.physicalcpu: 4
hw.perflevel1.physicalcpu_max: 4
hw.perflevel1.logicalcpu: 4
hw.perflevel1.logicalcpu_max: 4
hw.perflevel1.l1icachesize: 131072
hw.perflevel1.l1dcachesize: 65536
hw.perflevel1.l2cachesize: 4194304
hw.perflevel1.cpusperl2: 4
hw.perflevel1.name: Efficiency
hw.perflevel0.physicalcpu: 12
hw.perflevel0.physicalcpu_max: 12
hw.perflevel0.logicalcpu: 12
hw.perflevel0.logicalcpu_max: 12
hw.perflevel0.l1icachesize: 196608
hw.perflevel0.l1dcachesize: 131072
hw.perflevel0.l2cachesize: 16777216
hw.perflevel0.cpusperl2: 6
hw.perflevel0.name: Performance
hw.physicalcpu: 16
hw.physicalcpu_max: 16
hw.logicalcpu: 16
hw.logicalcpu_max: 16
hw.cputype: 16777228
hw.cpusubtype: 2
hw.cpu64bit_capable: 1
hw.cpufamily: 1912690738
hw.cpusubfamily: 5
hw.cacheconfig: 16 1 4 0 0 0 0 0 0 0
hw.cachesize: 3358556160 65536 4194304 0 0 0 0 0 0 0
hw.pagesize: 16384
hw.pagesize32: 16384
hw.cachelinesize: 128
hw.l1icachesize: 131072
hw.l1dcachesize: 65536
hw.l2cachesize: 4194304
hw.tbfrequency: 24000000
hw.memsize_usable: 136502542336
hw.packages: 1
hw.osenvironment: 
hw.ephemeral_storage: 0
hw.use_recovery_securityd: 0
hw.use_kernelmanagerd: 1
hw.serialdebugmode: 0
hw.nperflevels: 2
hw.targettype: J516c
```
