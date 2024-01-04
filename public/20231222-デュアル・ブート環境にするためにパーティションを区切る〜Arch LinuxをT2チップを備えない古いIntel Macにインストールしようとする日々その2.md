---
title: デュアル・ブート環境にするためにパーティションを区切る〜Arch LinuxをT2チップを備えない古いIntel Macにインストールしようとする日々その2
tags:
  - Mac
  - Linux
  - archLinux
private: false
updated_at: '2023-12-26T14:22:40+09:00'
id: 4b3d8240ff1f4a599908
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は，Ubuntuはよく使うが，Arch Linuxは初めてという私 @zacky1972 が，まずは手近なT2チップを備えていない古いIntel MacにArch Linuxをインストールして習得していく過程を記録する駄文の2回目です．今回は，表題の通り，MacBook Air (11-inch, Early 2014, MacBookAir6,1)をmacOSとArch Linuxのデュアル・ブート環境にするために，パーティションを区切るのを行いたいと思います．

## シリーズ

1. [Arch LinuxをブートできるUSBメモリを用意する](https://qiita.com/zacky1972/items/9f447f9a11f91e90f6e8)
2. デュアル・ブート環境にするためにパーティションを区切る(本記事)
3. [いよいよArch Linuxをインストールする](https://qiita.com/zacky1972/items/da1db6795b84151186ab)
4. [ネットワークの設定を見る](https://qiita.com/zacky1972/items/fcce6bdeaf2b87697e3f)
5. [Mac Pro (Mid 2010)にArch Linuxをインストールする](https://qiita.com/zacky1972/items/2904a0a07f9335fdb2de)
6. [ネットワークが繋がらない最小構成のままElixirをインストールして実行してみる](https://qiita.com/zacky1972/items/9a145632c6c12c650bed)
7. [ネットワークが繋がらない最小構成のままElixirをasdfではなくソースコードビルドしてインストールする](https://qiita.com/zacky1972/items/ab537e53fd30ac0d15a6)



## パーティションの作成(Disk Utililty)1回目

まず，Macを起動する際にコマンドキー＋Rを押して，ディスク・ユーティリティを起動します．macOSのパーティション領域を小さくします．

パーティションをmacOSに100MBほど確保し，残りをFATにしてフォーマットしました．

私の場合は，なぜかmacOSの領域を狭めることができなかったので，一旦ディスクを消去し，パーティションを区切り直して，macOSをクリーン・インストールすることにしました．macOSを残したのは，保険の意味のみです．元のmacOSは，消しても惜しくありませんでした．クリーン・インストールすると，懐かしのOS X Mountain Lionになりました．macOSを起動した時に，脆弱性を突かれないように，ネットワークに繋がないようにした方が良いでしょうね．

## パーティションの作成(fdisk)1回目

デュアル・ブート環境にするときに，どのようにするかについては，次に書かれています．

https://wiki.archlinux.org/title/Mac#Arch_Linux_with_macOS_or_other_operating_systems

さらに，次のところにより詳細な情報が書かれています．

https://wiki.archlinux.org/title/Mac#Installing_a_boot_loader_to_a_separate_HFS+_partition

なかなか込み入っていて，Arch Linux初心者には訳がわかりません．ただ，最悪，macOSが起動できなくなっても，元々クリーン・インストールしたものですから，また最初からやり直せば良く，その点とても気楽です．

さて，Arch LinuxをUSBメモリから起動し，`fdisk -l`を見ると，次のように表示されました．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2| 92.7G|Apple HFS/HFS+      |
|/dev/sda3|619.9M|Apple boot          |
|/dev/sda4|800.8G|Microsoft basic data|

わからないのが，下記に書かれている`mach_kernel`や`boot.efi`を格納するHFS/HFS+のパーティションというのは，この例だと`/dev/sda3`のことなのか，それとも新たに領域を確保する必要があるのか．たぶん，後者だろうな．

https://wiki.archlinux.org/title/Mac#Installing_a_boot_loader_to_a_separate_HFS+_partition

そうすると，まず，次のように作る必要がありそう．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2| 92.7G|Apple HFS/HFS+      |
|/dev/sda3|619.9M|Apple boot          |
|/dev/sda4|  300M|Apple HFS/HFS+      |
|/dev/sda5|(残り)|(Arch Linux用)       |

次に下記を踏まえてArch Linux用のパーティションを考察します．

https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks

今回使用するMacBook Air(11-inch, Early 2014, MacBookAir6,1)は，4GBのメモリでした．取り急ぎ，Arch Linuxを起動するには，十分そうにも見えます．そして後からSWAPファイルを足すこともできたと思います．なので，SWAP領域を確保するのはやめました．

あとは，最初なので，全部を`/`(root)にする構成にしてみたいと思います．

そうすると，次のようにパーティションを作る必要があります．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2| 92.7G|Apple HFS/HFS+      |
|/dev/sda3|619.9M|Apple boot          |
|/dev/sda4|  300M|Apple HFS/HFS+      |
|/dev/sda5|(残り)|Linux x86-64         |

さて，やってみましょう．`fdisk /dev/sda4`とします．

1. まず `d: delete a partition`として，`4 (/dev/sda4)`を消します．
2. 次に `F: list free unpartiitoned space` として，空き容量を確認します．
3. 次に `n: add a new partition`として，`300M`の領域を作ります．
    * `Partition type`は，`e: extended (container for logical partitions)`を選ぶんじゃないかと思います(仮説)．
    * `First sector`は，デフォルト値(2048)にします．
    * `Last sector ...`は，`+300M`と入力します．
4. 一旦，ここで `w: write table to disk and exit`として，書き込んで様子を見ましょう．なお，ここまでの操作に失敗していたら，`q: quit without saving changes`で，操作を破棄できます．

ここで，`fdisk -l`としても，変化がないように見えます．

`fdisk`のオプションを確認して，`fdisk -l /dev/sda4`とします．すると，`/dev/sda4p?`というデバイスができていました．なるほど，多分，前述のようにレイアウトするには，ディスク・ユーティリティを使った方が無難そうです(Arch Linuxでどのようにするのかについてて調べるのは将来課題としましょう)．

## パーティションの作成(Disk Utililty)2回目

そういうわけで，再起動してmacOSを起動します．今度は，macOS起動中のディスク・ユーティリティでできるはずです．

ところが調べてみると，ディスク・ユーティリティでMac用に作れる最小サイズは6GB強だったようです．しかたがないので，そのように作りました．残りはFATにしています．

## パーティションの作成(fdisk)2回目

`fdisk -l`とすると，狙い通り，次のようになりました．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2| 92.7G|Apple HFS/HFS+      |
|/dev/sda3|619.9M|Apple boot          |
|/dev/sda4|  5.6G|Apple HFS/HFS+      |
|/dev/sda5|795.1G|Microsoft basic data|

今日はここまでで時間が来てしまいました．また後日．

