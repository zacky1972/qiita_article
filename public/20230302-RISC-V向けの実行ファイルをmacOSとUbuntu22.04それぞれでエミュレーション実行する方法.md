---
title: RISC-V向けの実行ファイルをmacOSとUbuntu22.04それぞれでエミュレーション実行する方法
tags:
  - homebrew
  - macOS
  - RISC-V
  - Ubuntu22.04
private: false
updated_at: '2023-05-15T07:46:09+09:00'
id: 6d433bdbef737d1e300f
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
`riscv-isa-sim`と`riscv-pk`を使います．

# macOS

```zsh
brew tap riscv-software-src/riscv
brew install riscv-isa-sim riscv-pk
```

# Ubuntu 22.04

## `spike`のインストール

下記をインストールします．

https://github.com/riscv-software-src/riscv-isa-sim

`/usr/local/riscv` にインストールします．

```bash
sudo apt update
sudo apt install device-tree-compiler
git clone https://github.com/riscv-software-src/riscv-isa-sim.git
cd riscv-isa-sim
mkdir build
cd build
../configure --prefix=/usr/local/riscv
make -j$(nproc)
sudo make install
```

## `pk`のインストール

あらかじめ下記にしたがって，`riscv-gnu-toolchain`をインストールして，インストール先(`/usr/local/riscv/bin`など)に`PATH`を通しておいてください．

https://qiita.com/zacky1972/items/0cbfdf4e400e0205aa7b

下記をインストールします．

https://github.com/riscv-software-src/riscv-pk

`/usr/local/riscv` にインストールします．

```bash
git clone https://github.com/riscv-software-src/riscv-pk.git
cd riscv-pk
git checkout 8ce2dc4 # 2023年5月15日現在，このcommit hashをcheckoutしないとpkが正常に動作しません
mkdir build
cd build
../configure --prefix=/usr/local/riscv --host=riscv64-unknown-elf --with-arch=rv64gc_zifencei
make -j$(nproc)
sudo make install
```

参考記事は下記の通りです．

https://github.com/riscv-software-src/riscv-pk/issues/298

# 使い方

次のように使います．

macOSの場合

```zsh
spike pk (実行ファイル)
```

Ubuntu 22.04の場合

```bash
/usr/local/riscv/bin/spike /usr/local/riscv/riscv64-unknown-elf/bin/pk (実行ファイル)
```

ベクタ拡張を含む実行ファイルを実行するには次のようにします．

masOSの場合

```zsh
spike --isa=RV64IMAFDCV pk (実行ファイル)
```

Ubuntu 22.04の場合

```bash
/usr/local/riscv/bin/spike --isa=RV64IMAFDCV /usr/local/riscv/riscv64-unknown-elf/bin/pk (実行ファイル)
```

`--isa=RV64GV`では動作しませんでした．

32ビットアーキテクチャで動かすためには，`riscv-pk`を32ビットアーキテクチャでコンパイルする必要があります．

あらかじめ，下記の記事にしたがって，`riscv-gnu-toolchain`をインストールしておきます．

https://qiita.com/zacky1972/items/0cbfdf4e400e0205aa7b

`pk`のインストール先をたとえば次のように設定します．

```zsh
export RISCV=~/rv32
```

その後，次のようにしてビルド・インストールします．

macOSの場合

```zsh
git clone https://github.com/riscv/riscv-pk.git
cd riscv-pk
mkdir build
cd build
../configure --prefix=$RISCV --host=riscv64-unknown-elf --with-arch=rv32i
make
make install
```

Ubuntuの場合

```bash
git clone https://github.com/riscv-software-src/riscv-pk.git
cd riscv-pk
git checkout 8ce2dc4 # 2023年5月15日現在，このcommit hashをcheckoutしないとpkが正常に動作しません
mkdir build
cd build
../configure --prefix=$RISCV --host=riscv64-unknown-elf --with-arch=rv32i_zifencei
make -j$(nproc)
sudo make install
```

使用方法としては，例えば次のようにします．

```zsh
spike --isa=RV32I ~/rv32/riscv32-unknown-elf/bin/pk (実行ファイル)
```






