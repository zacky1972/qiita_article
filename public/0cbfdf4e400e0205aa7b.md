---
title: 'Cのプログラムを任意のRISC-V拡張に対応させてクロスコンパイルする方法(macOS, Ubuntu 22.04) (20230818改訂)'
tags:
  - homebrew
  - macOS
  - RISC-V
  - Ubuntu22.04
private: false
updated_at: '2023-08-18T15:02:23+09:00'
id: 0cbfdf4e400e0205aa7b
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
macOS で表題のことを行うには，`brew install riscv64-elf-gcc` とします．
Ubuntu で表題のことを行うには，`riscv-gnu-toolchain`をインストールします．

# macOS

```zsh
brew install riscv64-elf-gcc
```

すると `/opt/homebrew/opt/riscv64-elf-gcc/bin`に，`riscv64-elf-`で始まるツールチェーンがインストールされます．2023年8月現在，次のコマンドがインストールされます．

* `riscv64-elf-c++`
* `riscv64-elf-cpp`
* `riscv64-elf-g++`
* `riscv64-elf-gcc`
* `riscv64-elf-gcc-13.2.0`
* `riscv64-elf-gcc-ar`
* `riscv64-elf-gcc-nm`
* `riscv64-elf-gcc-ranlib`
* `riscv64-elf-gcov`
* `riscv64-elf-gcov-dump`
* `riscv64-elf-gcov-tool`
* `riscv64-elf-lto-dump`

またこれにより，`riscv64-elf-binutils`もインストールされます．`/opt/homebrew/opt/riscv64-elf-binutils/bin`に，`riscv64-elf-`で始まるツールチェーンがインストールされます．2023年8月現在，次のコマンドがインストールされます．

* `riscv64-elf-addr2line`
* `riscv64-elf-ar`
* `riscv64-elf-as`
* `riscv64-elf-c++filt`
* `riscv64-elf-elfedit`
* `riscv64-elf-gprof`
* `riscv64-elf-ld`
* `riscv64-elf-ld.bfd`
* `riscv64-elf-nm`
* `riscv64-elf-objcopy`
* `riscv64-elf-objdump`
* `riscv64-elf-ranlib`
* `riscv64-elf-readelf`
* `riscv64-elf-size`
* `riscv64-elf-strings`
* `riscv64-elf-strip`

# Ubuntu 22.04

参考記事: https://msyksphinz.hatenablog.com/entry/2022/05/24/040000

次のようにしました．

```bash
sudo apt update
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git
cd riscv-gnu-toolchain
mkdir build
./configure --prefix=/usr/local/riscv
make -j$(nproc)
make install
```

すると `/usr/local/riscv/bin` に次のコマンドがインストールされます．

* `riscv64-unknown-elf-addr2line`
* `riscv64-unknown-elf-ar`
* `riscv64-unknown-elf-as`
* `riscv64-unknown-elf-c++`
* `riscv64-unknown-elf-c++filt`
* `riscv64-unknown-elf-cpp`
* `riscv64-unknown-elf-elfedit`
* `riscv64-unknown-elf-g++`
* `riscv64-unknown-elf-gcc`
* `riscv64-unknown-elf-gcc-12.2.0` このコマンドについてはバージョンが上がるとバージョンを表す数字が変わるものと思います．
* `riscv64-unknown-elf-gcc-ar`
* `riscv64-unknown-elf-gcc-nm`
* `riscv64-unknown-elf-gcc-ranlib`
* `riscv64-unknown-elf-gcov`
* `riscv64-unknown-elf-gcov-dump`
* `riscv64-unknown-elf-gcov-tool`
* `riscv64-unknown-elf-gdb`
* `riscv64-unknown-elf-gdb-add-index`
* `riscv64-unknown-elf-gprof`
* `riscv64-unknown-elf-ld`
* `riscv64-unknown-elf-ld.bfd`
* `riscv64-unknown-elf-lto-dump`
* `riscv64-unknown-elf-nm`
* `riscv64-unknown-elf-objcopy`
* `riscv64-unknown-elf-objdump`
* `riscv64-unknown-elf-ranlib`
* `riscv64-unknown-elf-readelf`
* `riscv64-unknown-elf-run`
* `riscv64-unknown-elf-size`
* `riscv64-unknown-elf-strings`


# 使い方

標準状態では RV64G(RV64IMAFD) 向けにクロスコンパイルするものと思います(正確なところはドキュメント等で確認できませんでした)．オプションでいうと，`-march=rv64g -mabi=lp64d`です．

もし異なる拡張を指定したい場合には，たとえば次のようにします．拡張の組み合わせについては，自由に設定できるわけではなく，下記以外の組み合わせでは，コンパイルできてもリンクしてコードを生成するときにエラーが出ることがありました．

* RV64G `-march=rv64g -mabi=lp64d`
* RV64GV `-march=rv64gv -mabi=lp64d`
* RV32I `-march=rv32i -mabi=ilp32`
* RV32IMAC `-march=rv32imac -mabi=ilp32`
* RV32IMAFC `-march=rv32imafc -mabi=ilp32f`

Zで始まる拡張を指定するときには次のようにします．

* RV64GCZifencei `-march=rv64gc_zifencei -mabi=lp64d`

Auto-vectorizationは働きませんでした．Auto-vectorizationの対応状況がどうなっているのかが，よくわかりません．Clang 16ではAuto-vectorizationできているらしいので，確認してみたいと思っています．

