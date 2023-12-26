---
title: ネットワークの設定を見る〜Arch LinuxをT2チップを備えない古いIntel Macにインストールしようとする日々その4
tags:
  - Mac
  - Linux
  - archLinux
private: false
updated_at: '2023-12-26T10:33:05+09:00'
id: fcce6bdeaf2b87697e3f
organization_url_name: null
slide: false
ignorePublish: false
---
この記事は，Ubuntuはよく使うが，Arch Linuxは初めてという私 @zacky1972 が，まずは手近なT2チップを備えていない古いIntel MacにArch Linuxをインストールして習得していく過程を記録する駄文の4回目です．今回は，前回インストールしたArch Linuxのネットワークの設定を見ます．

## シリーズ

1. [Arch LinuxをブートできるUSBメモリを用意する](https://qiita.com/zacky1972/items/9f447f9a11f91e90f6e8)
2. [デュアル・ブート環境にするためにパーティションを区切る](https://qiita.com/zacky1972/items/4b3d8240ff1f4a599908)
3. [いよいよArch Linuxをインストールする](https://qiita.com/zacky1972/items/da1db6795b84151186ab)
4. ネットワークの設定を見る(本記事)
5. [Mac Pro (Mid 2010)にArch Linuxをインストールする](https://qiita.com/zacky1972/items/2904a0a07f9335fdb2de)
6. [ネットワークが繋がらない最小構成のままElixirをインストールして実行してみる](https://qiita.com/zacky1972/items/9a145632c6c12c650bed)

## 起動

現状では，下記の起動シーケンスにしたがって起動しています．

https://qiita.com/zacky1972/items/da1db6795b84151186ab#現状の起動シーケンス

ユーザー権限で起動しているという想定です．

## ネットワークの設定

ネットワークの設定は下記のとおりです．

https://wiki.archlinux.org/title/Network_configuration

下記のネットワークマネージャーを使うことがあるようです．

https://wiki.archlinux.org/title/Network_configuration#Network_managers

`ps`で見てみると，どうやら`systemd-networkd`を使っているようです．

確認するために，一度，`exit`を2回押して，下記コマンドを入力します．

```bash
systemctl --type=service
```

これをみると，`systemd-networkd`もですが，`OpenSSH Deamon`も起動しているみたいですね．デフォルトでは入らないようにも見えますので，何かの過程でインストールされたのかもしれません．

`arch-chroot`を用いて起動している間は，残念ながら，この設定をいじることはできないようです．先にmacOSからの起動を確立してからでないと，いけないようです．

取り急ぎ，USBメモリ中のデフォルトの`systemd`の設定を，SSD中にコピーしておいた方が良さそうな気がします．見た感じ，何も設定されていないようでした．



