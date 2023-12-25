---
title: Arch LinuxをブートできるUSBメモリを用意する〜Arch LinuxをT2チップを備えない古いIntel Macにインストールしようとする日々その1
tags:
  - Mac
  - Linux
  - archLinux
private: false
updated_at: '2023-12-18T11:42:12+09:00'
id: 9f447f9a11f91e90f6e8
organization_url_name: null
slide: false
ignorePublish: false
---
Arch Linuxに前から興味がありました．Apple Silicon Mac向けの最初のLinuxディストリビューションであるAsahi LinuxがArch Linuxベースであるというところから強く興味を持ちました．Linuxの仕組みを深く知りたいというのも動機の1つです．@mnishiguchi さんがArch Linux使いになったと聞き，いよいよArch Linuxをやってみようと決意しました．この記事は，Ubuntuはよく使うが，Arch Linuxは初めてという私 @zacky1972 が，まずは手近なT2チップを備えていない古いIntel MacにArch Linuxをインストールして習得していく過程を記録する駄文です．

## シリーズ

1. Arch LinuxをブートできるUSBメモリを用意する(本記事)
2. [デュアル・ブート環境にするためにパーティションを区切る](https://qiita.com/zacky1972/items/4b3d8240ff1f4a599908)
3. [いよいよArch Linuxをインストールする](https://qiita.com/zacky1972/items/da1db6795b84151186ab)

## まず公式ドキュメントを見る

何はともあれ，公式ドキュメントからです．

https://archlinux.org

インストール手順を読もうとします．

https://wiki.archlinux.org/title/Installation_guide

あれ？Macについて書いていないぞ？

検索するとありました．

https://wiki.archlinux.org/title/Mac

なになに？

> This page complements the Installation guide with instructions specific to Apple Macs.

ということは，さっきのインストール手順と合わせ読まないといけないのね．

## Pre-installation

というわけで，Macの2. Pre-installationを読みます．

https://wiki.archlinux.org/title/Mac#Pre-installation

2023年12月現時点では，「ファームウェアのアップデートはmacOSでしてね」「ColorSyncを開いてカラープロファイルを保存してね」「ボリュームを調整しておいてね．そのまま起動音のボリュームになるよ」の3点が書かれていました．

さしあたり，ファームウェアが最新であることを確認して，ColorSyncの設定をDropboxに放り込んでおき，ボリュームが適切であることを確認しました．

次にインストールガイドのPre-instllationを読みます．

https://wiki.archlinux.org/title/Installation_guide#Pre-installation

Downloadを開きます．

https://archlinux.org/download/

基本，Bittorrentでダウンロードするということでした．

私が普段使っているMacに，Bittorrentのクライアントを入れようとします．Homebrewで入れる方法を探したところ，下記を見つけました．

https://formulae.brew.sh/cask/qbittorrent

https://www.qbittorrent.org

そこで，次のコマンドでインストールしました．

```zsh
brew install qbittorrent
```

下記のページの Magnet link を開くと，「このWebページで“qBittorrent”を開くことを許可しますか?」とメッセージが出るので許可しますが，その後，「qBittorrent”が悪質なソフトウェアかどうかをAppleでは確認できないため、このソフトウェアは開けません。」と出ました．

https://archlinux.org/download/

「Finderに表示」をクリックして，qBittorrentを開くとして，「“qBittorrent”が悪質なソフトウェアかどうかをAppleでは確認できないため、このソフトウェアは開けません。」に対して「開く」を押し，その後，認証の画面が出るので，"I Agree"を押します．

再度，下記のページの Magnet link を開くと，qbittorrentを起動する旨，メッセージが出るので許可します．

https://archlinux.org/download/

ダウンロードが無事始まりました．

ダウンロード後に，念のため，`sha256sum`コマンドで確認します．

次に installation medium ということで，USBメモリを用意して，ダウンロードしたイメージをUSBメモリに書き込みます．

Macで行う方法は次のとおりです．

まずUSBメモリをMacに挿して，次のコマンドを実行します．

```zsh
diskutil list 
```

そうすると私の環境では，次のように表示されました．

```zsh
diskutil list
/dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *1.0 TB     disk0
   1:             Apple_APFS_ISC Container disk1         524.3 MB   disk0s1
   2:                 Apple_APFS Container disk3         994.7 GB   disk0s2
   3:        Apple_APFS_Recovery Container disk2         5.4 GB     disk0s3

...

/dev/disk12 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *15.5 GB    disk12
   1:             Windows_FAT_32                         15.5 GB    disk12s1
```

最後のが，`external, physical`となっているので，これがUSBメモリなのでしょう．実際，`Windows_FAT_32`となっていますし．

私の場合には，`/dev/disk12`でしたが，皆さんの環境ではおそらく違う値になっていることでしょう．この文字列を仮に`$USB_MEMORY`と表現することにします．

次のようにディスクを消去します．

```zsh
diskutil eraseDisk MS-DOS UNTITLED $USB_MEMORY
```

次のようにしてUSBメモリをアンマウントします．

```zsh
diskutil unmountDisk $USB_MEMORY
```

最後に意を決して書き込みます．仮にダウンロードしたイメージファイルのパスを`/path/to/archlinux-image.iso`とします．`sudo`コマンドを使っているので，MacOSのログインパスワードが聞かれます．

```zsh
sudo dd if=/path/to/archlinux-image.iso of=$USB_MEMORY conv=fsync oflag=direct status=progress
```

出来上がったUSBメモリを用いて，live環境をブートします．

Intel Macの場合には，起動時にoptionキーを長押しすると，起動メディアの選択になります．

https://support.apple.com/ja-jp/guide/mac-help/mchlp1034/mac

こんな感じになると思うので，

![booting_choose_macOS.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/1a697121-9008-78bd-b858-c6f34a7c94a2.png)

右矢印キーを押してUSBメモリを選択し，Enterします．

![booting_choose_USBmemory.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/b1347c21-ec17-e2cc-e506-6af821585fab.png)

すると見慣れたGRUBの起動画面になります．一番上のArch Linux install mediumを選択します．多分2番目を選択すると，読み上げてくれるのかな？

![GRUB.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/6c1aa113-96db-7216-8583-f55549d11b43.png)

起動が始まります．起動の途中で "Welcome to Arch Linux!"と，温かく出迎えてくれます．

![WelcomeToArchLinux.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/ebeeb65b-fc9b-4554-7e3d-d8e854d84d9c.png)

しばらく待つと，下記のようにコマンドラインになります．やった！

![CommandLine.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/12f1f188-0f3a-4e56-db6d-86fbbd02c538.png)

なお，この時点では，まだSSDに何も書き込んでいないので，引き返せます．

## 諸々いじってみる

私が最初に起動させたのは，機種IDがMacBookAir6,1でした．下記ページを見ると，MacBook Air (11-inch, Early 2014)に該当します．

https://support.apple.com/ja-jp/102869

最初にキーボードの設定を必要があるのですが，私のMacBookはUS配列なので，このままでOKです．日本語配列の場合には，いろいろ設定する必要があるのでしょうね．

次に，ネットワークに繋いでみます．

Apple Thunderbolt - ギガビットEthernetアダプタというものを合わせて購入して持っています．下記だと思います．

https://www.apple.com/jp/shop/product/MD463ZM/A/apple-thunderbolt-ギガビットethernetアダプタ

これを接続して，インターネットにつながっている有線LANに繋いでみます．その上で，次のコマンドを実行すると，何やら，つながっているっぽいことがわかります(ループバックの他に，イーサーネットがつながっているように出力される)．

```bash
ip link
```

試しに適当な外部のIPアドレスに`ping`を打ってみると，反応してくれます．やった！インターネットにつながっている！

今日までに試したのは，ここまでです．少しずつ育てていきます．次はSSDへのインストールかなあ．

Linuxへの深い理解をしたいというのがArch Linuxを習得しようとする動機の1つなので， @mnishiguchi さんの話では `archinstall` コマンドを使えば楽勝だということなのですが，あえてそれを用いずに，1つ1つ基本的なコマンドを確かめながらインストールしていこうと考えています．`archinstall` コマンドを使うのだと，Ubuntuのインストーラーを使うのと同程度にしか，Linuxを理解できないと思いましたので！ 楽したい人は，このシリーズの続きを読むのではなく，`archinstall`の使い方を調べてくださいませ．
