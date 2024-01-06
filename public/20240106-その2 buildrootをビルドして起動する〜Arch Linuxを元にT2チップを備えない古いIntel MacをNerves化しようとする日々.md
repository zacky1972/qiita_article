---
title: その2 buildrootをビルドして起動する〜Arch Linuxを元にT2チップを備えない古いIntel MacをNerves化しようとする日々
tags:
  - Mac
  - archLinux
  - Elixir
  - buildroot
  - Nerves
private: false
updated_at: '2024-01-06T12:11:46+09:00'
id: 4ce0032514978a7d2f1f
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
「Arch Linuxを元にT2チップを備えない古いIntel MacをNerves化しよう」という構想の実現に邁進する駄文シリーズの第2弾です．今回は，素のx86_64 PC向けのbuildrootを古いIntel MacであるMac Pro (Mid 2010) に入れて起動を試みてみました．

## シリーズ

1. [Nerves化構想を思い立つ](https://qiita.com/zacky1972/items/d1da49dedfaafae57cbb)
1. buildrootをビルドして起動する(本記事)

## Nervesの移植方法について

Nervesの移植方法については，下記にドキュメント化されています．

https://github.com/nerves-project/nerves_system_br/blob/main/README.md

2024年1月現在では次のことを最初に行うと書かれています．

> Create a minimal Buildroot `defconfig` that boots and runs on the board. This doesn't use Nerves at all.

というわけで，Buildrootに取り組んでみます．

## buildrootの作成

buildrootの作成ですが，まずは試しなので，適当なUbuntuマシンでサクッと作ってしまいました．後で，ArchLinuxでの構築を試そうと思っています．

まず，下記にあるパッケージを全てインストールしました(必須もオプションも)．

https://buildroot.org/downloads/manual/manual.html#requirement

そして，下記のGit Repositoryからダウンロードしました．

https://buildroot.org/download.html

試したブランチはLatest Stable Releaseである`2023.11.x`です．

```bash
git clone https://gitlab.com/buildroot.org/buildroot.git
cd buildroot
git checkout 2023.11.x
```

下記を眺めてみました．

```bash
make list-defconfigs
```

多いので，`x86_64`がないかを探します．

```bash
make list-defconfigs | grep x86_64
```

すると下記がありました．

```
  mender_x86_64_efi_defconfig         - Build for mender_x86_64_efi
  pc_x86_64_bios_defconfig            - Build for pc_x86_64_bios
  pc_x86_64_efi_defconfig             - Build for pc_x86_64_efi
  qemu_x86_64_defconfig               - Build for qemu_x86_64
```

たぶん，`pc_x86_64_efi_defconfig`なんだろうと思います．そこで，次のコマンドを実行します．

```bash
make pc_x86_64_efi_defconfig
make menuconfig
```

ざっと眺めた後，何も変更せずに`Exit`をして，下記コマンドを実行します．

```bash
make
```

かなり待った後で，次のファイルができていることを確認しました．

```bash
ls output/images/disk.img
```

## SSDの用意

Mac Pro (Mid 2010) の良いところは，ストレージを着脱しやすい点です．そこで，[Mac Pro (Mid 2010)にArch Linuxをインストールする](https://qiita.com/zacky1972/items/2904a0a07f9335fdb2de)までで構築したArch Linuxを用いて，前述の`disk.img`を焼きます．

### SSHの準備と`disk.img`のコピー

まず，Live USBでブートします．

https://qiita.com/zacky1972/items/9f447f9a11f91e90f6e8

起動したら，下記コマンドで編集して，`PermitRootLogin yes`とします．

```bash
vim /etc/ssh/sshd_config
```

下記コマンドで`root`のパスワードを設定します．

```bash
passwd
```

下記コマンドで，接続されているネットワークインタフェースのデバイスとMACアドレスを取得します．

```bash
ip link
```

下記コマンドで`dhcpcd`を起動します．

```bash
systemctl start dhcpcd@(ここにネットワークインタフェースのデバイスを入れる).service
```

下記コマンドで`sshd`を起動します．

```bash
systemctl start sshd.service
```

`disk.img`のある外部のマシンから次のコマンドを実行して，MACアドレスに対応するIPアドレスを得ます．

```bash
arp -a
```

下記のようにして，SSHでログインできることを確かめます．

```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@(IPアドレス)
```

現在だと，USBメモリしかマウントしていないので，Arch LinuxのSSDをマウントします．私の環境だと，下記でマウントできました．

```bash
mount /dev/sda2 /mnt
```

次に，`disk.img`のあるディレクトリで，`scp`を用いてコピーします．

```bash
scp -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" disk.img root@(IPアドレス):/mnt/root/
```

### Arch Linuxの起動とbuildrootのSSDへの書き込み

Mac Pro (Mid 2010) の電源を一度切って，新しいSSDを装着し，Arch Linuxを起動します．

https://qiita.com/zacky1972/items/2904a0a07f9335fdb2de#mac-pro-mid-2010の現在の起動シーケンス

下記のように`root`になります．

```bash
sudo su
cd
LANG=C
```

`fdisk -l`をすると，下記のようになっていました．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2|488.9G|Apple APFS          |
|/dev/sdb |      |                    |

そこで，次のコマンドをうちます．

```bash
dd if=disk.img of=/dev/sdb conv=fsync oflag=direct status=progress
```

`fdisk -l`をすると，下記のようになっていました．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2|488.9G|Apple APFS          |
|/dev/sdb1|   16M|EFI System          |
|/dev/sdb2|  120M|Linux root (x86)    |

## buildrootの起動

Mac Pro (Mid 2010)を再起動して，optionキーを押し続けて待機します．

すると，下記の写真のように，SSDが2つ見えているじゃないですか！

![optionキーを押して起動した時の画面](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/0329a116-7b43-88cd-f0cf-b7a1fd6c077e.jpeg)

右キーを押して，Enterキーを押します．

![右側のEFI bootを選択](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/3f81ca0c-2eb7-24d9-10dc-6aeb986f59d9.jpeg)

すると，buildrootと銘打ったGRUBが起動してくれます！

![buildrootのGRUB](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/fed70a97-58c9-e6ab-01de-6ea26094b7a8.jpeg)

しかし，起動すると，ブートログが途中で止まってしまいます．

![buildrootのブートログ](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/38cdce25-4763-9660-0ee0-6026a501fe1e.jpeg)

必要なデバイスドライバが足りないとか，何かのデバイスドライバが起動に失敗しているとか，とにかく，素のx86_64のbuildrootの設定では，Intel Macは起動しないということがわかりました．

本記事は，ひとまず，ここまでです．

## 追記その１

デバイスドライバが足りないのであれば，Arch Linuxの`dmesg`の出力結果が参考になると思いました．

また，Nerves Project代表のFrank Hunlethさん曰く，

> It looks like the root filesystem isn't showing up. I didn't look hard enough to see whether it was due to a device driver missing or the the hard drive that it's looking for having a different name.
> When Linux hangs like your screenshot shows, it usually has to something to do with mounting the root filesystem.

ということ，つまり，SSDが想定されているドライブの位置に接続されていないので，ドライブ名違いでrootをマウントできない可能性があることを指摘してくださいました．

Mac Pro (Mid 2010)の特に気に入っている点の1つは，ドライブの交換がとても簡単であるという点です．早速，あとで試してみたいと思います．

## 追記その２

というわけで，SSDを入れ替えて起動してみました．

![SSDを入れ替えた時のbuildrootのブートログ](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/3f5bf02d-1282-0939-c1aa-0e363245dd76.jpeg)

前より少し進んだかな？

でもブートログはこれ以上進みませんでした．そうすると，デバイスドライバを調整してbuildrootを構築し，さらにSSDを入れ替える，もしくはデバイスドライバの調整に加えてSSDに関する設定をした上でbuildrootを構築する，という感じでしょうか．

