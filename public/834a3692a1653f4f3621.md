---
title: Apple Silicon Mac上のLimaでx86_64版のUbuntu 22.04.1を走らせる方法
tags:
  - Mac
  - Lima
  - AppleSilicon
  - Ubuntu22.04
private: false
updated_at: '2023-02-20T09:31:47+09:00'
id: 834a3692a1653f4f3621
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
次のようにインストールします．

```zsh
brew install lima
```

x86_64版のUbuntu 22.04.1をインストールする場合は次のようなファイルを作ります．

```yaml:ubuntu2204-amd64.yaml
arch: "x86_64"
images:
- location: "https://cloud-images.ubuntu.com/releases/22.04/release-20221018/ubuntu-22.04-server-cloudimg-amd64.img"
  arch: "x86_64"
```

次のコマンドを実行します(かなり待ちます)．

```zsh
limactl start --tty=false ubuntu2204-amd64.yaml
```

`fail to download the image`と言われたら，上記 location がダウンしているか，新しいイメージに置き換わって古いイメージがなくなってしまったということです．その場合は，次のようにしてイメージを探します．

一般に下記を見ながらインストールするUbuntuのバージョンを探していきます．他のバージョンを入れる場合の応用になります．

https://github.com/lima-vm/lima/commits/master/examples/ubuntu.yaml

また，`limactl start ...`にて，`already exists`というようなエラーが出た場合には，次のようにしてコンテナのファイルを削除してから，`limactl start ...` を再実行します．

```zsh
rm -rf .lima/ubuntu2204-amd64
```

無事起動すると次のようなメッセージが出ると思います．

```
INFO[0237] READY. Run `limactl shell ubuntu2204-amd64` to open the shell.
```

そこで，表示されたコマンドを実行してみます．

```zsh
limactl shell ubuntu2204-amd64
```

すると次のようにUbuntuのシェルが立ち上がります．

```bash
username@lima-ubuntu2204-amd64:~$
```

ここでバージョンを確認してみましょう．

```bash
username@lima-ubuntu2204-amd64:~$ uname -a
Linux lima-ubuntu2204-amd64 5.15.0-52-generic #58-Ubuntu SMP Thu Oct 13 08:03:55 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
username@lima-ubuntu2204-amd64:~$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 22.04.1 LTS
Release:	22.04
Codename:	jammy
```

Ubuntuを実行した後，抜けてMacのターミナルに戻るには `exit`とします．

```bash
username@lima-ubuntu2204-amd64:~$ exit
```

走らせているコンテナの一覧を出すには次のようにします．

```zsh
% limactl list                                   
NAME                STATUS     SSH                VMTYPE    ARCH      CPUS    MEMORY    DISK      DIR
ubuntu2204-amd64    Running    127.0.0.1:59387    qemu      x86_64    4       4GiB      100GiB    ~/.lima/ubuntu2204-amd64
```

コンテナを停止するには次のようにします．

```zsh
limactl stop ubuntu2204-amd64
```

その後，コンテナを削除するには次のようにします．

```zsh
limactl delete ubuntu2204-amd64
```





