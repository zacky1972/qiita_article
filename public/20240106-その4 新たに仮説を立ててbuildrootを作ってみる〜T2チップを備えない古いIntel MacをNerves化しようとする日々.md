---
title: その4 新たに仮説を立ててbuildrootを作ってみる〜T2チップを備えない古いIntel MacをNerves化しようとする日々
tags:
  - Mac
  - Linux
  - Elixir
  - buildroot
  - Nerves
private: false
updated_at: '2024-01-06T22:50:23+09:00'
id: 4e150e1f80e31ac69be7
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
「T2チップを備えない古いIntel MacをNerves化しよう」という構想の実現に邁進する駄文シリーズの第4弾です．前回，仮説を立てましたが，実際にbuildrootの中身を見てみると，到底，仮説通りにいかないことがわかりました．ただし，眺めているうちに分かったような気がしてきました．そこで，今回は新たな設定でbuildrootを作成して，Mac Pro (Mid 2010)で動かしてみようということになりました．

## シリーズ

1. [Nerves化構想を思い立つ](https://qiita.com/zacky1972/items/d1da49dedfaafae57cbb)
1. [buildrootをビルドして起動する](https://qiita.com/zacky1972/items/4ce0032514978a7d2f1f)
1. [仮説を立てる](https://qiita.com/zacky1972/items/3d38a74c6e67b26efe6d)
1. 新たに仮説を立ててbuildrootを作ってみる(本記事)

## やってみたbuildrootの設定

```bash
make pc_x86_64_efi_defconfig
make menuconfig
```

変更した設定は下記のとおりです．

* Target options
    * Target Architecture Variant (westmare)
* Toolchain
    * Enable C++
    * Enable OpenMP
* Build options
    * Enable compiler cache
* System configuration
    * System hostname
    * Passwords encoding (sha-512)
    * Root password
    * [C en_US ja_JP] Locales to keep
    * [*] Install timezone info
    * (Asia/Tokyo) default local time
* Kernel
    * Linux Kernel Tools
        * [*] cpupower
        * [*] perf
            * [*] enable installation of perf scripts
            * [*] enable perf TUI
* Target Packages
    * Busybox
        * [*] Show packages that are also provided by busybox
    * Filesystem and flash utilities
        * [*] exFAT
        * [*] exfat-utils
        * [*] exfatprogs
        * [*] f2fs-tools
        * [*] squashfs
        * [*] sshfs
    * Hardware handling
        * [*] memtest86
        * [*] memtester
        * [*] memtool
    * System Tools
        * [*] util-linux
            * [*] libuuid
            * [*] uuidd
```bash
make linux-menuconfig
```

しばらく待ちました．変更した設定は下記のとおりです．

* Device Drivers
    * Macintosh device drivers
        * Support for mouse button 2+3 emulation
    * Input device
        * <M> Mouse
    * USB support
        * USB announce new devices
        * Apple Cinema Display Support
* File systems
    * <*> F2FS
    * DOS/FAT/EXFAT
    * Miscellanuous filesystems
        * Apple Macintosh file system support
        * Apple Extended HFS file system support
        * SquashFS 4.0
    * UTF-8 normalization and case folding support

```bash
make
```

しばらく待ちます．かなり待った後で，次のファイルができていることを確認しました．

```bash
ls output/images/disk.img
```



## SSDを焼く

Mac Pro (Mid 2010) がUSBメモリで起動できなくなったので，今度はMac Pro (Mid 2010)でmacOSを起動し，SSDを焼きました．

```bash
diskutil list
```

この環境では，`/dev/disk2`でした．

```bash
dd if=disk.img of=/dev/disk2 conv=fsync oflag=direct status=progress
```

## 起動する

SSDを入れ替えて，ドライブ1にbuildrootのSSDを装着します．さてどうなるか？　つづく

