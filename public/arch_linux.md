---
title: Arch LinuxをIntel Macにインストールしようとする日々その1
tags:
  - Mac
  - Linux
  - archLinux
private: true
updated_at: '2023-12-18T07:31:19+09:00'
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

Bittorrentのクライアントを入れようとします．Homebrewで入れる方法を探したところ，下記を見つけました．

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

```zsh
diskutil list 
```

```zsh
diskutil list
/dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *1.0 TB     disk0
   1:             Apple_APFS_ISC Container disk1         524.3 MB   disk0s1
   2:                 Apple_APFS Container disk3         994.7 GB   disk0s2
   3:        Apple_APFS_Recovery Container disk2         5.4 GB     disk0s3

/dev/disk3 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +994.7 GB   disk3
                                 Physical Store disk0s2
   1:                APFS Volume Macintosh HD            10.1 GB    disk3s1
   2:              APFS Snapshot com.apple.os.update-... 10.1 GB    disk3s1s1
   3:                APFS Volume Preboot                 6.0 GB     disk3s2
   4:                APFS Volume Recovery                923.3 MB   disk3s3
   5:                APFS Volume Data                    377.1 GB   disk3s5
   6:                APFS Volume VM                      1.1 GB     disk3s6

/dev/disk4 (disk image):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        +4.1 GB     disk4
   1:                 Apple_APFS Container disk5         4.1 GB     disk4s1

/dev/disk5 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +4.1 GB     disk5
                                 Physical Store disk4s1
   1:                APFS Volume WatchOS 9.1 Simulator   3.9 GB     disk5s1

/dev/disk6 (disk image):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        +4.1 GB     disk6
   1:                 Apple_APFS Container disk7         4.1 GB     disk6s1

/dev/disk7 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +4.1 GB     disk7
                                 Physical Store disk6s1
   1:                APFS Volume WatchOS 9.0 Simulator   3.9 GB     disk7s1

/dev/disk8 (disk image):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        +3.8 GB     disk8
   1:                 Apple_APFS Container disk9         3.8 GB     disk8s1

/dev/disk9 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +3.8 GB     disk9
                                 Physical Store disk8s1
   1:                APFS Volume AppleTVOS 16.0 Simul... 3.5 GB     disk9s1

/dev/disk10 (disk image):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        +3.9 GB     disk10
   1:                 Apple_APFS Container disk11        3.9 GB     disk10s1

/dev/disk11 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +3.9 GB     disk11
                                 Physical Store disk10s1
   1:                APFS Volume AppleTVOS 16.1 Simul... 3.5 GB     disk11s1

zacky@zackym2air01 ~ % diskutil list
/dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *1.0 TB     disk0
   1:             Apple_APFS_ISC Container disk1         524.3 MB   disk0s1
   2:                 Apple_APFS Container disk3         994.7 GB   disk0s2
   3:        Apple_APFS_Recovery Container disk2         5.4 GB     disk0s3

/dev/disk3 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +994.7 GB   disk3
                                 Physical Store disk0s2
   1:                APFS Volume Macintosh HD            10.1 GB    disk3s1
   2:              APFS Snapshot com.apple.os.update-... 10.1 GB    disk3s1s1
   3:                APFS Volume Preboot                 6.0 GB     disk3s2
   4:                APFS Volume Recovery                923.3 MB   disk3s3
   5:                APFS Volume Data                    377.1 GB   disk3s5
   6:                APFS Volume VM                      1.1 GB     disk3s6

/dev/disk4 (disk image):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        +4.1 GB     disk4
   1:                 Apple_APFS Container disk5         4.1 GB     disk4s1

/dev/disk5 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +4.1 GB     disk5
                                 Physical Store disk4s1
   1:                APFS Volume WatchOS 9.1 Simulator   3.9 GB     disk5s1

/dev/disk6 (disk image):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        +4.1 GB     disk6
   1:                 Apple_APFS Container disk7         4.1 GB     disk6s1

/dev/disk7 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +4.1 GB     disk7
                                 Physical Store disk6s1
   1:                APFS Volume WatchOS 9.0 Simulator   3.9 GB     disk7s1

/dev/disk8 (disk image):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        +3.8 GB     disk8
   1:                 Apple_APFS Container disk9         3.8 GB     disk8s1

/dev/disk9 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +3.8 GB     disk9
                                 Physical Store disk8s1
   1:                APFS Volume AppleTVOS 16.0 Simul... 3.5 GB     disk9s1

/dev/disk10 (disk image):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        +3.9 GB     disk10
   1:                 Apple_APFS Container disk11        3.9 GB     disk10s1

/dev/disk11 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +3.9 GB     disk11
                                 Physical Store disk10s1
   1:                APFS Volume AppleTVOS 16.1 Simul... 3.5 GB     disk11s1

/dev/disk12 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *15.5 GB    disk12
   1:             Windows_FAT_32                         15.5 GB    disk12s1
```

```zsh
diskutil eraseDisk MS-DOS UNTITLED /dev/disk12
diskutil unmountDisk /dev/disk12 
sudo dd if=~/Downloads/archlinux-2023.12.01-x86_64.iso of=/dev/disk12 conv=fsync oflag=direct status=progress
```
