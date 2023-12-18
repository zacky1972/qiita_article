---
title: Arch LinuxをIntel Macにインストールしようとする日々その1
tags:
  - Mac
  - Linux
  - archLinux
private: true
updated_at: '2023-12-18T08:00:08+09:00'
id: 9f447f9a11f91e90f6e8
organization_url_name: null
slide: false
ignorePublish: false
---
Arch Linuxに前から興味がありました．Apple Silicon Mac向けの最初のLinuxディストリビューションであるAsahi LinuxがArch Linuxベースであるというところから強く興味を持ちました．@mnishiguchi さんがArch Linux使いになったと聞き，いよいよArch Linuxをやってみようと決意しました．この記事は，Ubuntuはよく使うが，Arch Linuxは初めてという私 @zacky1972 が，まずは手近なIntel MacにArch Linuxをインストールして習得していく過程を記録する駄文です．

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

最後に意を決して書き込みます．仮にダウンロードしたイメージファイルのパスを`/path/to/archlinux-image.iso`とします．

```zsh
sudo dd if=/path/to/archlinux-image.iso of=$USB_MEMORY conv=fsync oflag=direct status=progress
```
