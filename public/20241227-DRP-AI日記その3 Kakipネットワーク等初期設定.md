---
title: DRP-AI日記その3 Kakipネットワーク等初期設定
tags:
  - Ubuntu
  - DRP-AI
  - Kakip
private: false
updated_at: '2024-12-28T09:47:37+09:00'
id: ab6a176f0ad481473f71
organization_url_name: null
slide: false
ignorePublish: false
---
Kakipのネットワーク等を初期設定しました．

DRP-AIシリーズ・Kakip

- [DRP-AI日記その1 なぜDRP-AIシリーズに取り組むのか](https://qiita.com/zacky1972/items/3ebf021cab1e972890f8)
- [DRP-AI日記その2 Kakipを起動してみた](https://qiita.com/zacky1972/items/438ddc192fc499fb697c)

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
sudo systemctl status ssh.socket
```

ポート番号を書き換えるには，まず次のコマンドを実行して，エディタを好きなものに書き換えます．

```bash
sudo update-alternatives --config editor
```

そして次のコマンドを実行します．

```bash
sudo mkdir -p /etc/systemd/system/ssh.socket.d
sudo systemctl edit ssh.socket
```

`/etc/systemd/system/ssh.socket.d/override.conf`というファイルが作成されて，テキストエディタが開きます．

```txt:/etc/systemd/system/ssh.socket.d/override.conf
### Editing /etc/systemd/system/ssh.socket.d/override.conf
### Anything between here and the comment beflow will become the contents of the drop-in file

[Socket]
ListenStream=
ListenStream=(指定したいポート番号)

### Edits below this comment will be discarded
```

(指定したいポート番号)のところにポート番号を記載します．その前の `ListenStream=`という空の行で既存のエントリを削除しています．これが無いと，22番ポートでも待ち受けてしまいます．


その後，次のコマンドを実行します．

```bash
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

## さいごに大事なこと

`apt upgrade`で`systemd`が保留になっていたので，気になって，`apt install`で強制アップグレードしたら，起動しなくなってしまいました．原因を突き止めるまではアップグレード禁止．
