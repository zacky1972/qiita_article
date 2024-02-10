---
title: Verilator 5をGitHub Actionsで動かす方法〜Dockerを使って高速化
tags:
  - SystemVerilog
  - verilator
  - GitHubActions
private: false
updated_at: '2023-01-24T22:35:45+09:00'
id: d0054b6d8567162898dd
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
下記の記事を書いたところ，

https://qiita.com/zacky1972/items/5062e599a447ab529880

@tenmyo さんより次のコメントをいただけました．

https://qiita.com/zacky1972/items/5062e599a447ab529880#comment-df0627606ef8b9aa9322

> あまり詳しくないのですが、非公式でこんなのを見つけました。新しめのvarilatorのイメージです。
> https://hub.docker.com/r/hdlc/verilator
> HDL関係のコンテナ整備プロジェクトが提供しているようです。
> https://hdl.github.io/containers/

試行錯誤してみたところ，動かすことに成功しました！

```yaml:main.yml
# This is a basic workflow to help you get started with Actions

name: CI

# Controls when the workflow will run
on:
  # Triggers the workflow on push or pull request events but only for the "main" branch
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main" ]

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  build:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest
    container:
      image: hdlc/verilator

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Run apt update
      - name: Run apt update
        run: apt update 2>/dev/null

      - name: Run apt install prerequisites
        run: |
          apt install -y clang-9
          ln -s /usr/bin/clang++-9 /usr/bin/clang++

      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v3

      # Run compiling and testing (To be continued)
```

やりました！


# ハマったポイント

ハマったポイントですが，イメージの中に`clang++`が入っていないので困り，さらに`apt install -y clang`とするとClang 11が入るのですが，それだとVerilatorがエラーを吐くという問題に遭遇しました．

Clang 11の時のエラーメッセージはこんな感じでした．

```c++
clang++  -I.  -MMD -I/usr/local/share/verilator/include -I/usr/local/share/verilator/include/vltstd -DVM_COVERAGE=0 -DVM_SC=0 -DVM_TRACE=0 -DVM_TRACE_FST=0 -DVM_TRACE_VCD=0 -faligned-new -fbracket-depth=4096 -fcf-protection=none -Qunused-arguments -Wno-bool-operation -Wno-tautological-bitwise-compare -Wno-parentheses-equality -Wno-sign-compare -Wno-uninitialized -Wno-unused-parameter -Wno-unused-variable -Wno-shadow     -DVL_TIME_CONTEXT  -std=gnu++14 -fcoroutines-ts -Os -c -o Vriscv_alu32_test__ALL.o Vriscv_alu32_test__ALL.cpp
12
In file included from Vriscv_alu32_test__ALL.cpp:4:
13
./Vriscv_alu32_test___024root__DepSet_h766c62ac__0.cpp:10:27: error: the expression 'co_await __promise.final_suspend()' is required to be non-throwing
14
VL_INLINE_OPT VlCoroutine Vriscv_alu32_test___024root___eval_initial__TOP__0(Vriscv_alu32_test___024root* vlSelf) {
15
                          ^
16
/usr/bin/../lib/gcc/x86_64-linux-gnu/10/../../../../include/c++/10/coroutine:205:5: note: must be declared with 'noexcept'
17
    }
18
    ^
19
1 error generated.
20
make[1]: *** [/usr/local/share/verilator/include/verilated.mk:237: Vriscv_alu32_test__ALL.o] Error 1
21
make[1]: Leaving directory '/__w/spprv32/spprv32/obj_dir'
22
%Error: make -C obj_dir -f Vriscv_alu32_test.mk -j 1 exited with 2
23
%Error: Command Failed ulimit -s unlimited 2>/dev/null; exec /usr/local/bin/verilator_bin --binary --assert --top-module riscv_alu32_test test/riscv_alu32_test.sv src/riscv_alu32.sv -o riscv_alu32_test
24
make: *** [Makefile.verilator:16: obj_dir/riscv_alu32_test] Error 2
25
Error: Process completed with exit code 2.
```


20240210追記:

本記事から大幅アップデートした手法について，[FPGAマガジン特別版No.2で紹介しております https://fpga.tokyo/no2-2/](https://fpga.tokyo/no2-2/)

大変光栄なことに，トップを飾っております．

> 第1章　Verilator 5とGitHub Actionsによるテストベンチ自動検証

他にも有用な記事が満載ですので，ぜひこの機会にInterfaceを定期購読ください！