---
title: DRP-AI日記その3 Kakipネットワーク等初期設定
tags:
  - DRP-AI
  - Kakip
  - Ubuntu
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
Kakipのネットワーク等を初期設定しました．

電力が不足しているのか，熱がまずいのか，ディスプレイ出力が安定しません．USBハブを使うのを諦めて，キーボードとマウスを抜き差ししながら，慎重に作業を進めます．

1. 最初にキーボードを繋いで初期ユーザー・初期パスワードでログインします．
2. 次にマウスに繋ぎかえます．
3. 「Ubuntu 24.04.1 LTSへようこそ」で「次へ」をクリック
4. 「Ubuntu Pro」で「Skip for now」を選択して「次へ」をクリック(もちろんUbuntu Proにしても良いです)
5. 「Ubuntuの改善を支援する」で「はい、システムデータをUbuntuチームと共有します」を選択して「次へ」をクリック(もちろん共有しない設定にするのもありです)
6. 「さらにアプリケーションを追加する」の画面で「完了」をクリックする

次に左下の「Show Apps」アイコンをクリックして，「設定」を選択します．

1. ネットワークタブを選択して，有線の歯車アイコンをクリックする
2. IPv4タブを選択して，固定IP設定にする

次に左下の「Show Apps」アイコンをクリックして，「端末」を選択します．

1. `sudo apt update`
2. `sudo apt upgrade`

続いてユーザーを新たに作ります．`ユーザー名`には実際には作成するユーザーアカウントの英数字を入れます．

1. `sudo adduser ユーザー名`
2. `sudo gpasswd -a ユーザー名 sudo`

一旦ログアウトして新しいユーザー名でログインしなおします．その後，デフォルトユーザー`ubuntu`を削除します．

1. `sudo userdel -r ubuntu`

## sshd のポート変更

現在のUbuntuでは`systemd`を用いて`sshd`を運用しているようです．下記で確認できます．

```bash
sudo systemctl statys ssh.socket
```

`/usr/lib/systemd/system/ssh.socket`を編集します．

```txt:/usr/lib/systemd/system/ssh.socket
...
[Socket]
ListenStream=22
```

ここの22を変更したいポート番号にします．

その後，次のコマンドを実行します．

```bash
sudo systemctl daemon-reload
sudo systemctl restart ssh.socket
sudo systemctl status ssh.socket
```

## そのほかのsshdの設定

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
```

* rootユーザーでのログインを抑止(PermitRootLogin)

```bash
sudo systemctl restart ssh.socket
sudo systemctl restart ssh
```

パスワード認証でログインし，公開鍵を配置します．

その後，次の処理をします．

* パスワード認証の抑止(PasswordAuthentication)

```bash
sudo systemctl restart ssh.socket
sudo systemctl restart ssh
```

パスワードでのログインが禁止されたことを確認しました．



