---
title: いよいよArch Linuxをインストールする〜Arch LinuxをT2チップを備えない古いIntel Macにインストールしようとする日々その3
tags:
  - Mac
  - Linux
  - archLinux
private: false
updated_at: '2023-12-25T14:05:09+09:00'
id: da1db6795b84151186ab
organization_url_name: null
slide: false
ignorePublish: false
---
この記事は，Ubuntuはよく使うが，Arch Linuxは初めてという私 @zacky1972 が，まずは手近なT2チップを備えていない古いIntel MacにArch Linuxをインストールして習得していく過程を記録する駄文の3回目です．今回は，表題の通り，いよいよMacBook Air (11-inch, Early 2014, MacBookAir6,1)にArch Linuxインストールする作業を行いたいと思います．

## シリーズ

1. [Arch LinuxをブートできるUSBメモリを用意する](https://qiita.com/zacky1972/items/9f447f9a11f91e90f6e8)
2. [デュアル・ブート環境にするためにパーティションを区切る](https://qiita.com/zacky1972/items/4b3d8240ff1f4a599908)
3. いよいよArch Linuxをインストールする(本記事)

## パーティションの状態

[前回までにパーティションを次のように区切りました．](https://qiita.com/zacky1972/items/4b3d8240ff1f4a599908#パーティションの作成fdisk2回目)

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2| 92.7G|Apple HFS/HFS+      |
|/dev/sda3|619.9M|Apple boot          |
|/dev/sda4|  5.6G|Apple HFS/HFS+      |
|/dev/sda5|795.1G|Microsoft basic data|

今日はここから作業していきます．

## macOSの起動セクションを作る(1回目)

下記の手順に従います．

https://wiki.archlinux.org/title/Mac#Installing_a_boot_loader_to_a_separate_HFS+_partition

まず，次のようにして`/dev/sda4`をマウントします．

```bash
mount /dev/sda4 /mnt
```

これで，ドキュメント中の`/mountpoint`は`/mnt`に置き換えられます．

試しに次のようにしてみます．

```bash
touch /mnt/mach_kernel
```

おや？書き込みができないようです．

一旦，アンマウントして，書き込みするようにしてマウントし直します．

```bash
umount /dev/sda4
mount -rw /dev/sda4 /mnt
```

しかし，依然として，書き込みができません．

下記の記事を見つけました．

https://askubuntu.com/questions/332315/how-to-read-and-write-hfs-journaled-external-hdd-in-ubuntu-without-access-to-os

`hfsprogs`なるものをインストールするようです．

Arch Linuxのパッケージマネージャのpacmanのドキュメントを読みます．

https://wiki.archlinux.org/title/pacman

https://aur.archlinux.org/packages/hfsprogs

次のようにインストールします．

```bash
pacman -Sy hfsprogs
```

ターゲットがないと言われますね．

調べてみたら，レポジトリと同期する必要があるようです．

```bash
pacman -Syy
```

この後で，もう一度，`hfsprogs`をインストールします．

```bash
pacman -Sy hfsprogs
```

まだ見つかりません．下記をやってみても，見つからないようです．

```bash
pacman -Ss hfsprogs
```

次のようにアップグレードしようとすると，パーティションがいっぱいでできないと言われます．

```bash
pacman -Syyu
```

推測ですが，先にSSD(`/dev/sda5`)にArch Linuxをインストールして，ルートディレクトリ(`/`)をSSD(`/dev/sda5`)にマウントしてから，この手順をやるんじゃないでしょうかね．

## Arch Linux を SSD にインストールする

というわけで，Arch LinuxをSSD(`/dev/sda5`)にインストールして，マウントしなおしてみたいと思います．

まず，下記のようにして`ext4`で`/dev/sda5`をフォーマットします．

https://wiki.archlinux.org/title/Installation_guide#Format_the_partitions

```bash
mkfs.ext4 /dev/sda5
```

次に下記のようにマウントします．

https://wiki.archlinux.org/title/Installation_guide#Mount_the_file_systems

```bash
mount /dev/sda5 /mnt
```

続いて，次のインストール手順を行います．

https://wiki.archlinux.org/title/Installation_guide#Installation

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

ここで `/etc/locale.gen` を編集しようとしてつまづきました．エディタである`vi`がありません．

`pacman`で`vi`をインストールします．

```bash
pacman -Syyu
pacman -Sy vi
```

`/etc/locale.gen`を編集して，`ja_JP.UTF-8 UTF-8`を有効にして，次のコマンドを実行します．

```bash
locale-gen
```

`/etc/locale.conf`を次のように作成します．

```conf:locale.conf
LANG=ja_JP.UTF-8
```

英語キーボードなので，キーボードレイアウトはそのままにします．

`/etc/hostname`を作成して，ホスト名を決めます．

Initramfsは研究してみたいので，設定します．

```bash
mkinitcpio -P
```

Root passwordを設定します．

```bash
passwd
```

## macOSの起動セクションを作る(2回目)

下記に従って，ブートローダーを設定します．

https://wiki.archlinux.org/title/Mac#Setup_boot_loader

今回は，[Installing a boot loader to a separate HFS+ partition](https://wiki.archlinux.org/title/Mac#Installing_a_boot_loader_to_a_separate_HFS+_partition)に従うものと思います．

https://wiki.archlinux.org/title/Mac#Installing_a_boot_loader_to_a_separate_HFS+_partition

次のように`hfsprogs`をインストールします．

```bash
pacman -Sy hfsprogs
```

依然としてパッケージが見つかりません．

どうも調べてみると，パッケージを作成してインストールする必要があるみたい．

ただし，下記手順で`root`では`makepkg`を実行できませんでした．

https://linux-packages.com/aur/package/hfsprogs

そこで，ユーザーを作成します．

参考

https://qiita.com/mdps513/items/4c29be9d080b47534e7c

ユーザー`zacky`を作成します．ログインシェルは`/bin/bash`とします．

```bash
useradd -m -g wheel -s /bin/bash zacky
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

次のようにインストールします．

```bash
sudo pacman -S --needed base-devel git
```

次のように`hfsprogs`をチェックアウトして，インストールします．

```bash
git clone https://aur.archlinux.org/hfsprogs.git ~/hfsprogs
cd ~/hfsprogs
makepkg -si
```

ここまでうまく終わったら，次のようにして，`root`に戻ります．

```bash
exit
```

下記の記事にあるようにHFS+をマウントします．

https://askubuntu.com/questions/332315/how-to-read-and-write-hfs-journaled-external-hdd-in-ubuntu-without-access-to-os

```bash
mount -t hfsplus -o force,rw /dev/sda4 /mnt
```

下記の手順に従います．

https://wiki.archlinux.org/title/Mac#Installing_a_boot_loader_to_a_separate_HFS+_partition

```bash
touch /mnt/mach_kernel
```

今度は無事書き込めました．

```bash
mkdir -p /mnt/System/Library/CoreServices
```

## 将来課題

次に"Now, you can install any UEFI boot loader you want."の手順をしようとするのですが，ファイルが見つかりません．

rEFIndをインストールする手順をやってみます．

https://wiki.archlinux.org/title/REFInd

まず，パッケージをインストールします．

```bash
pacman -S refind
```

次のコマンドを実行すると，エラーになります．

```bash
refind-install
```

ESPを設定していないのだそうです．

ESPの説明はこちらです．

https://wiki.archlinux.org/title/EFI_system_partition

読んだ感じ，おそらくですが，下記の`/dev/sda1`を書き換えると言っているような気がします．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2| 92.7G|Apple HFS/HFS+      |
|/dev/sda3|619.9M|Apple boot          |
|/dev/sda4|  5.6G|Apple HFS/HFS+      |
|/dev/sda5|795.1G|Microsoft basic data|

しかし，デュアル・ブート環境に支障が出そうな予感がします．つまり，ここにインストールすると，Arch Linuxしか立ち上がらないのではないかという気がするのです．

そもそも，デュアル・ブート環境にしようというのは，保険の意味だったので，ここで決断して，Arch Linuxのみのシングル・ブートにしても良いのかもしれません．しかし，今後の研究材料ということで，ブート方法については，将来課題として，置いておこうと思います．

## 現状の起動シーケンス

現状でも，次のように操作することで，Arch Linux環境にすることができます．

1. Arch LinuxのliveのUSBメモリを挿す
2. optionキーを押しながら電源オン
3. EFI boot (USB) を選択
4. GRUBが立ち上がるので，Enterキーを入力
5. (Arch Linuxが起動)
6. `mount /dev/sda5 /mnt`
7. `arch-chroot /mnt`
8. `sudo su zacky`
9. `cd`

これでユーザー`zacky`のユーザー権限で起動できます．お疲れ様でした！

