---
title: Ubuntu 22.04 でRISC-V向けClang 16をビルドする
tags:
  - clang
  - RISC-V
  - Ubuntu22.04
private: false
updated_at: '2023-05-16T10:16:32+09:00'
id: 6aa01b8a85e0f86dbafd
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
Clang 16ではRVV向けAuto-vectorizationができるらしいというのを聞いて，ここ最近Clang16をビルドしようと四苦八苦していました．

基本的には下記公式ドキュメントをもとにしています．

https://llvm.org/docs/GettingStarted.html

バージョンは16.0.3となります．また，`apt`で足りないツール類は適宜インストールしてください．

下記の2つの記事のインストールは完了させてください．

https://qiita.com/zacky1972/items/0cbfdf4e400e0205aa7b

https://qiita.com/zacky1972/items/6d433bdbef737d1e300f

あらかじめ，次の作業をしたのでした．

```bash
sudo ln --symbolic /usr/include/* /usr/local/riscv/include
```

(すでに存在する`/usr/local/riscv/include/gdb`のみエラーになると思います)


ではビルドするスクリプトを紹介します．

```bash
git clone https://github.com/llvm/llvm-project.git
cd llvm-project
git checkout llvmorg-16.0.3
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/riscv -DLLVM_ENABLE_PROJECTS="clang" -DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++ -DLLVM_BUILD_TESTS=False -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" -DDEFAULT_SYSROOT=/usr/local/riscv/riscv64-unknown-elf -DLLVM_TARGETS_TO_BUILD="RISCV" -G Ninja ../llvm
ninja
sudo ninja install
```

`cmake`で指定しているオプションについて解説します．

* `-DCMAKE_BUILD_TYPE=Release` リリース版をビルドします．
* `-DCMAKE_INSTALL_PREFIX=/usr/local/riscv` インストール先を`/usr/local/riscv`にします．
* `-DLLVM_ENABLE_PROJECTS="clang"` Clangをビルドします．
* `-DCMAKE_C_COMPILER=/usr/bin/gcc` ビルドで用いるCコンパイラを指定します．ここでは`/usr/bin/gcc`を用います．
* `-DCMAKE_CXX_COMPILER=/usr/bin/g++` ビルドで用いるC++コンパイラを指定します．ここでは`/usr/bin/g++`を用います．
* `-DLLVM_BUILD_TESTS=False` テストスクリプトをビルドしないようにします．テストスクリプトのビルドのためには`#include`を処理できる必要があるのですが，今回確立した方法ではヘッダファイルを含めることに失敗しているので，ビルドしないようにする必要があります．
* `-DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf"` `target`オプションなしでコンパイルした時のターゲットを`riscv64-unknown-elf`にします．
* `-DDEFAULT_SYSROOT=/usr/local/riscv/riscv64-unknown-elf` ビルドしたコンパイラが参照するライブラリやヘッダファイル類を定義する`SYSROOT`を`/usr/local/riscv/riscv64-unknown-elf`にします．
* `-DLLVM_TARGETS_TO_BUILD="RISCV"` RISC-Vをターゲットにできるようにします．
* `-G Ninja` この後，Ninjaでビルドできるようにします．

# 検証方法

次のようなCプログラムがコンパイルできることを確認します．

```c:hello.c
int main()
{
    return 0;
}
```

```bash
clang -march=rv64g hello.c 
spike /usr/local/riscv/riscv64-unknown-elf/bin/pk a.out 
```

同様に次のようなCプログラムもコンパイルできます．

```c:hello.c
#include <stdint.h>

int main()
{
    int64_t a = 0;
    return (int)a;
}
```

次のようなプログラムもできました．macOSではできなくて苦労していました！


```c:hello.c
#include <stdio.h>

int main()
{
	printf("hello, world.\n");
}
```

