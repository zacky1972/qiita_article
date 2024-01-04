---
title: >-
  Mac Pro (Mid 2010)にArch Linuxをインストールする〜Arch LinuxをT2チップを備えない古いIntel
  Macにインストールしようとする日々その5
tags:
  - Mac
  - Linux
  - archLinux
private: false
updated_at: '2023-12-26T14:22:40+09:00'
id: 2904a0a07f9335fdb2de
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は，Ubuntuはよく使うが，Arch Linuxは初めてという私 @zacky1972 が，まずは手近なT2チップを備えていない古いIntel MacにArch Linuxをインストールして習得していく過程を記録する駄文の5回目です．前回まで，MacBook Air (11-inch, Early 2014, MacBookAir6,1)にデュアル・ブート環境としてインストールを試みていたのですが，再起動してブートできるようにならないと，ネットワークの設定ができないという問題にぶち当たったので，今回から趣向を変えて，Mac Pro (Mid 2010)にインストールしてみます．これはmacOSなしにクリーンインストールできるので，前述の問題が発生しないと思われます．

## シリーズ

1. [Arch LinuxをブートできるUSBメモリを用意する](https://qiita.com/zacky1972/items/9f447f9a11f91e90f6e8)
2. [デュアル・ブート環境にするためにパーティションを区切る](https://qiita.com/zacky1972/items/4b3d8240ff1f4a599908)
3. [いよいよArch Linuxをインストールする](https://qiita.com/zacky1972/items/da1db6795b84151186ab)
4. [ネットワークの設定を見る](https://qiita.com/zacky1972/items/fcce6bdeaf2b87697e3f)
5. Mac Pro (Mid 2010)にArch Linuxをインストールする(本記事)
6. [ネットワークが繋がらない最小構成のままElixirをインストールして実行してみる](https://qiita.com/zacky1972/items/9a145632c6c12c650bed)
7. [ネットワークが繋がらない最小構成のままElixirをasdfではなくソースコードビルドしてインストールする](https://qiita.com/zacky1972/items/ab537e53fd30ac0d15a6)



## Mac Pro (Mid 2010)の仕様

* Processor: 2 x 3.46 GHz 6-Core Intel Xeon (プロセッサ数 2，物理コア数 6 x 2，論理コア数 12 x 2)
* Memory 64GB 1333MHz DDR3
* Graphics: ATI Radeon HD 5770 1024MB
* SSD 500GB (Crucial)

## Arch LinuxをSSDにインストールする

`fdisk -l`の結果は次のとおりです．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2|488.9G|Apple APFS          |

https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions

次のようにして，`ext4`で`/dev/sda2`をフォーマットします．

```bash
mkfs.ext4 /dev/sda2
```

`fdisk -l`の結果は次のとおりで，APFSのままですね．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2|488.9G|Apple APFS          |

次のコマンドをうちます．

```bash
fdisk /dev/sda
```

選択肢は次のようにします．

```bash
Command: t
Partition number: 2
Partition type or alias: linux
Command: w
```

`fdisk -l`の結果は次のようになりました．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2|488.9G|Linux filesystem    |

念のため，再度ファイルシステムを作ります．

```bash
mkfs.ext4 /dev/sda2
```

次に，下記のようにマウントします．

https://wiki.archlinux.org/title/Installation_guide#Mount_the_file_systems

```bash
mount /dev/sda2 /mnt
```

続いて，次のインストール手順を行います．

https://wiki.archlinux.org/title/Installation_guide#Installation

```bash
pacstrap -K /mnt base linux linux-firmware
```

おっと，ネットワークに繋いでいませんでした．ネットワークに繋ぎ，`ip link`として，繋がっていることを確認し，再び，次のコマンドをうちます．

```bash
pacstrap -K /mnt base linux linux-firmware
```

続いて，次の手順に移ります．

https://wiki.archlinux.org/title/Installation_guide#Configure_the_system

```bash
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc
```

`/etc/locale.gen`を編集するために`pacman`で`vi`をインストールします．

```bash
pacman -Syyu
pacman -Sy vi
```

すると，署名が信頼できない旨，エラーになったので，一回`exit`してアンマウントして，ファイルシステムを作り直すところからやり直しました．すると，うまくいきました．

`/etc/locale.gen`を編集して，`ja_JP.UTF-8 UTF-8`を有効にして，次のコマンドを実行します．

```bash
locale-gen
```

`/etc/locale.conf`を次のように作成します．

```conf:locale.conf
LANG=ja_JP.UTF-8
```

英語キーボードなので，キーボードレイアウトはそのままにします．

`/etc/hostname`を作成して，ホスト名を決めます．仮のホスト名にしました(後で変える)．

Initramfsは研究してみたいので，設定します．

```bash
mkinitcpio -P
```

Root passwordを設定します．

```bash
passwd
```

ユーザーを作成します．

参考

https://qiita.com/mdps513/items/4c29be9d080b47534e7c

ユーザー`zacky`を作成します．ログインシェルは`/bin/bash`とします．

```bash
useradd -m -g wheel -s /bin/bash zacky
```

パスワードを設定します．

```bash
passwd zacky
```

`sudo`をインストールします．

```bash
pacman -Sy sudo
```

`visudo`で次の2行をコメントアウトします．

```
# Defaults env_keep += "HOME"

# %wheel ALL=(ALL) ALL
```

次のようにして，ユーザー権限になります．

```bash
sudo su zacky
cd
```

適当に`sudo`して，root権限になれることを確認します．

終わったら`exit`して，root権限に戻ります．

## ブートローダーの設定

下記に従って，ブートローダーを設定します．

https://wiki.archlinux.org/title/Mac#Setup_boot_loader

Using rEFindにします．

https://wiki.archlinux.org/title/Mac#Setup_boot_loader

https://wiki.archlinux.org/title/REFInd

refindパッケージをインストールします．

```bash
pacman -S refind
```

手順に戻ります．

https://wiki.archlinux.org/title/Mac#Using_rEFInd

意を決して，次のコマンドをうちます．

```bash
refind-install --usedefault /dev/sda1
```

成功しました！

手順に戻ります．

https://wiki.archlinux.org/title/Mac#Installation

次は，カーネル・パラメータをいじるのだそうです．rEFIndの場合は，下記です．

https://wiki.archlinux.org/title/Kernel_parameters#rEFInd

一回起動してみないといけないみたいですね．

意を決して，再起動します！

```bash
exit
reboot
```

起動しました！

rEFIndの起動画面

![rEFIndの起動画面](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/9f838a80-c354-a700-a1fa-467302a8db7b.jpeg)

ここからF2またはInsertまたは+を押します．

![rEFIndの詳細起動画面](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/f36185f2-1640-43c7-90ab-b80206c727f1.jpeg)

さらにF2またはInsertを押すと，カーネル・パラメータの編集画面に移行します．

![カーネル・パラメータの編集画面](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/79f4049b-4bb0-8bae-bb83-938039b60536.jpeg)

末尾に`reboot=pci`を足して，Enterキーを押します．すると起動しました．

![Arch Linuxのログイン画面](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/dcaaeb36-e6de-f3a6-75ce-e54fe43b95c3.jpeg)


起動した後に，次のコマンドを入力して，カーネル・パラメータが渡されていることを確認します．

```bash
cat /proc/cmdline
```

ただ，再起動するたびに，カーネル・パラメータを指定しないと，いけないようでした．これは今後の課題ですね．

また，`ip link`とすると，ネットワークが繋がっていません．懸念したように，`systemd`周りの設定をしないといけないですね．これも今後の課題です．

## Mac Pro (Mid 2010)の現在の起動シーケンス

1. rEFIndの起動で，F2またはInsertを2回押して，カーネル・パラメータの編集画面に移行する．
2. 末尾に`reboot=pci`を足して，Enterキーを押す．
3. ユーザーでログインする


