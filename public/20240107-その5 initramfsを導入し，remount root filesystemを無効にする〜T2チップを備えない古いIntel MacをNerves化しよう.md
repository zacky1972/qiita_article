---
title: >-
  その5 initramfsを導入し，remount root filesystemを無効にする〜T2チップを備えない古いIntel
  MacをNerves化しようとする日々
tags:
  - Mac
  - Linux
  - Elixir
  - buildroot
  - Nerves
private: false
updated_at: '2024-01-07T11:17:48+09:00'
id: 812fb744a62bc30661b3
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
「T2チップを備えない古いIntel MacをNerves化しよう」という構想の実現に邁進する駄文シリーズの第5弾です．今回は，Frankさんの助言にしたがって，`initramfs`を導入します．また，`remount root filesystem read-write during boot`が悪さをしているような気がしたので，これも無効にしてみます．設定を変えていくうちに，`efi-part.vfat`が一杯になるというエラーが出るようになったので，これまたFrankさんの助言で，`board/pc/genimage-efi.cfg`を編集してみました．

## シリーズ

1. [Nerves化構想を思い立つ](https://qiita.com/zacky1972/items/d1da49dedfaafae57cbb)
1. [buildrootをビルドして起動する](https://qiita.com/zacky1972/items/4ce0032514978a7d2f1f)
1. [仮説を立てる](https://qiita.com/zacky1972/items/3d38a74c6e67b26efe6d)
1. [新たに仮説を立ててbuildrootを作ってみる](https://qiita.com/zacky1972/items/4e150e1f80e31ac69be7)
1. initramfsを導入し，remount root filesystemを無効にする(本記事)

## やってみたbuidrootの設定

やっていくうちに次のエラーが出るようになりました．

```
>>>   Executing post-image script board/pc/post-image-efi.sh
INFO: cmd: "mkdir -p "/home/zacky/buildroot/output/build/genimage.tmp"" (stderr):
INFO: cmd: "rm -rf "/home/zacky/buildroot/output/build/genimage.tmp"/*" (stderr):
INFO: cmd: "mkdir -p "/home/zacky/buildroot/output/build/genimage.tmp"" (stderr):
INFO: cmd: "cp -a "/tmp/tmp.LbDAomNaaQ" "/home/zacky/buildroot/output/build/genimage.tmp/root"" (stderr):
INFO: cmd: "mkdir -p "/home/zacky/buildroot/output/images"" (stderr):
INFO: vfat(efi-part.vfat): cmd: "mkdosfs   '/home/zacky/buildroot/output/images/efi-part.vfat'" (stderr):
INFO: vfat(efi-part.vfat): adding file 'efi-part/EFI' as 'EFI' ...
INFO: vfat(efi-part.vfat): cmd: "MTOOLS_SKIP_CHECK=1 mcopy -sp -i '/home/zacky/buildroot/output/images/efi-part.vfat' '/home/zacky/buildroot/output/images/efi-part/EFI' '::EFI'" (stderr):
INFO: vfat(efi-part.vfat): adding file 'bzImage' as 'bzImage' ...
INFO: vfat(efi-part.vfat): cmd: "MTOOLS_SKIP_CHECK=1 mcopy -sp -i '/home/zacky/buildroot/output/images/efi-part.vfat' '/home/zacky/buildroot/output/images/bzImage' '::bzImage'" (stderr):
Disk full
INFO: vfat(efi-part.vfat): cmd: "rm -f "/home/zacky/buildroot/output/images/efi-part.vfat"" (stderr):
ERROR: vfat(efi-part.vfat): failed to generate efi-part.vfat
make[1]: *** [Makefile:820: target-post-image] エラー 1
make: *** [Makefile:82: _all] エラー 2
```

Nerves ProjectのFrank Hunlethに対処方法を教えてもらいました．EFIがいっぱいになっているので，プログラムを減らすか，容量を大きくするかです．後者をするには，下記ファイルを編集してサイズを大きくします．

```bash
vi board/pc/genimage-efi.cfg
```

```
image efi-part.vfat {
        vfat {
                file EFI {
                        image = "efi-part/EFI"
                }

                file bzImage {
                        image = "bzImage"
                }
        }

        size = 65504K # 64MB - 32KB
}

image disk.img {
        hdimage {
                partition-table-type = "gpt"
        }

        partition boot {
                image = "efi-part.vfat"
                partition-type-uuid = U
                offset = 32K
                bootable = true
        }

        partition root {
                partition-type-uuid = 44479540-f297-41b2-9af7-d131d5f0458a
                partition-uuid = UUID_TMP
                image = "rootfs.ext2"
        }
}
```

次にbuildrootの設定をしていきます．

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
    * [ ] remount root filesystem read-write during boot
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
* Filesystem images
    * [*] initial RAM filesystem linked into linux kernel 

```bash
make linux-menuconfig
```

しばらく待ちました．変更した設定は下記のとおりです．

* Device Drivers
    * [*] Macintosh device drivers
        * <M> Support for mouse button 2+3 emulation
    * Input device
        * <M> Mouse
    * USB support
        * [*] USB announce new devices
        * <M> Apple Cinema Display Support
* File systems
    * <*> F2FS
    * DOS/FAT/EXFAT
        * <M> MSDOS fs support
        * <M> VFAT (Windows-95) fs support
        * [*] Enable FAT UTF-8 option by default
        * <M> exFAT filesystem support
    * [*] Miscellanuous filesystems
        * <M> Apple Macintosh file system support
        * <M> Apple Extended HFS file system support
        * <*> SquashFS 4.0
    * <*> UTF-8 normalization and case folding support

```bash
make
```

しばらく待ちます．かなり待った後で，次のファイルができていることを確認しました．

```bash
ls output/images/disk.img
```

果たして，実行できるのか？

## SSDを焼く

Mac Pro (Mid 2010)上のmacOSで焼きます．`diskutil list`で確認すると，恐ろしいことに，今度は`/dev/disk2`ではなく`/dev/disk0`でした．毎回確認しないといけないようですね．

```bash
dd if=disk.img of=/dev/disk0
```

## 起動する

SSDを入れ替えて，ドライブ1にbuildrootのSSDを装着します．さてどうなるか？

![buildrootのGRUB](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/c0dda21d-575d-9e8e-b910-26fb6b7e2bc3.jpeg)

ブートログをできる限り写してみました．

![buildrootのブートログ1枚目](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/aa9d63cc-b804-1020-3a57-77d642714e4b.jpeg)

![buildrootのブートログ2枚目](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/a9c882d2-dfee-081c-4e89-ce2f17b952b0.jpeg)

![buildrootのブートログ3枚目](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/7545ca6f-0a03-09d5-0ab3-55249df8abd9.jpeg)

ここまででとまりました．
