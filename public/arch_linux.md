---
title: >-
  ネットワークが繋がらない最小構成のままElixirをインストールして実行してみる〜Arch LinuxをT2チップを備えない古いIntel
  Macにインストールしようとする日々その5
tags:
  - Mac
  - Linux
  - archLinux
  - Elixir
private: false
updated_at: '2023-12-26T10:29:49+09:00'
id: 9a145632c6c12c650bed
organization_url_name: null
slide: false
ignorePublish: false
---
この記事は，Ubuntuはよく使うが，Arch Linuxは初めてという私 @zacky1972 が，まずは手近なT2チップを備えていない古いIntel MacにArch Linuxをインストールして習得していく過程を記録する駄文の5回目です．前回まででMac Pro(Mid 2010)へArch Linuxをインストールできたものの，ネットワークも繋がらない最小構成でした．今回は，この状態でもElixirをインストールして実行することができるのかを検証してみたいと思います．

## シリーズ

1. [Arch LinuxをブートできるUSBメモリを用意する](https://qiita.com/zacky1972/items/9f447f9a11f91e90f6e8)
2. [デュアル・ブート環境にするためにパーティションを区切る](https://qiita.com/zacky1972/items/4b3d8240ff1f4a599908)
3. [いよいよArch Linuxをインストールする](https://qiita.com/zacky1972/items/da1db6795b84151186ab)
4. ネットワークの設定を見る(本記事)
5. [Mac Pro (Mid 2010)にArch Linuxをインストールする](https://qiita.com/zacky1972/items/2904a0a07f9335fdb2de)
6. ネットワークが繋がらない最小構成のままElixirをインストールして実行してみる(本記事)

## `fdisk -l`の結果

Mac Pro (Mid 2010)の2023年12月現在の`fdisk -l`の結果は次のとおりです．

|Device   |Size  |Type                |
|:--------|-----:|:-------------------|
|/dev/sda1|  200M|EFI System          |
|/dev/sda2|488.9G|Linux filesystem    |


## 再度USBメモリブート

1. Arch Linux live USBメモリをMac Pro(Mid 2010)に挿す
2. optionキーを押しながら起動する
3. USBメモリを選択して起動する
4. `mount /dev/sda2 /mnt`
5. `arch-chroot /mnt`

その後，`pacman -Syyu` として，パッケージをアップグレードしておきます．

## asdf で Arch Linux に Elixir をインストール

https://qiita.com/mnishiguchi/items/122249b6c27391f03d82

```bash
pacman -S curl git
cd
git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.13.1
. $HOME/.asdf/asdf.sh
```

`$HOME/.bashrc`に次を追記します．

```bash:.bashrc
. $HOME/.asdf/asdf.sh
```

```bash
pacman -S base-devel ncurses glu mesa wxwidgets-gtk3 libpng libssh unixodbc libxslt fop
```

インストールするJDKについて聞かれるので，好きなものを選びます．私は`jdk-openjdk`を選びました．

```bash
asdf plugin add erlang
asdf install erlang latest
```

ビルドされるまでしばらく待ちます．ビルドは成功したと出ています．

```bash
asdf global erlang latest
```

ここで，インストールされていない旨，エラーが出ました．root権限に対応していないのか？

`$HOME/.asdf/installs`を見てみると，空です．本来だと，ここにビルドしたファイルが入っていないといけません．

ただし，Erlangのビルド自体は成功したようなので，あとでソースコードインストールを試みます．

続けて，Elixirのインストールを試みます．

```bash
pacman -S unzip
asdf plugin add elixir
asdf install elixir latest
asdf global elixir latest
asdf list
```

Elixirはインストールできました．

## Erlangのソースコードビルド

Erlangのダウンロードの公式ページはこちらです．

https://www.erlang.org/downloads

最新版の26.2.1のソースコードをダウンロードします．

```bash
curl -OL https://github.com/erlang/otp/releases/download/OTP-26.2.1/otp_src_26.2.1.tar.gz
```

続けて展開してディレクトリに入ります．

```bash
tar xfz otp_src_26.2.1.tar.gz
cd otp_src_26.2.1
```

次のようにして，`./configure`を実行したログを記録します．

```bash
./configure > configure.log
```

ログを眺めます．

`less`がなかったので，インストールします．

```bash
pacman -S less
```

ログを眺めた限り，依存ライブラリを一通り認識しているようですので，このまま進めます．

```bash
make
```

ビルドが終わるまで，しばらく放置します．ビルドが終わったら次を実行します．

```bash
make install
```

これで，`/usr/local/bin`にErlangがインストールされました．ライブラリは`/usr/local/lib/erlang`に入っています．

## USBメモリ環境での実行の確認

Elixirの実行を確認します．

```bash
iex
```

```elixir
1..10 |> Enum.map(& &1 * 10) |> IO.inspect()
```

```elixir
Mix.install([:flow])
1..10 |> Flow.from_enumerable() |> Flow.map(& &1 * 10) |> Enum.to_list() |> IO.inspect()
```

動きました．

## SSD環境での実行の確認

再起動して，SSDから起動します．

1. `exit`
2. `reboot`
3. rEFIndの起動で，F2またはInsertを2回押して，カーネル・パラメータの編集画面に移行する．
4. 末尾に`reboot=pci`を足して，Enterキーを押す．
5. ユーザーでログインする

あれ，起動すると次のようなエラーが出ますね．

```bash
ERROR: Firmware file "b43/ucode16_mimo.fw" not found
ERROR: Firmware file "b43-open/ucode16_mimo.fw" not found
ERROR: You must go to https://wireless.wiki.kernel.org/en/users/Drivers/b43#devicefirmware and download the correct firmware for this driver version. Please carefully read all instructions on this website.
```

https://wireless.wiki.kernel.org/en/users/Drivers/b43#devicefirmware

読むと，無線LANに関する設定でした．現在，まだ無線LANを設定していないのですが，ファームウェアが欠落しているということは，無線LANを認識しない恐れがありそうですね．これは将来課題とします．

ともあれ，次のように，root権限になります．

```bash
sudo su
```

先ほどのElixirのテストをしてみます．

```bash
iex
```

```elixir
1..10 |> Enum.map(& &1 * 10) |> IO.inspect()
```

```elixir
Mix.install([:flow])
1..10 |> Flow.from_enumerable() |> Flow.map(& &1 * 10) |> Enum.to_list() |> IO.inspect()
```

既に読み込んだHexパッケージFlowであれば，実行できました．

一旦 `iex` を終了して，再度`iex`を立ち上げ，次のようにしてみました．ここで，NxはUSBメモリブート時に読み込んでいないHexライブラリである点に注意してください．

```elixir
Nx.install([:nx])
```

予想通り，ネットワークにつながっていないことに起因するエラーになりました．

## まとめ

以上を踏まえると，Arch Linuxの最小構成にあっても，ネットワーク接続の問題のほかは，Arch Linux live USBメモリブートしてElixirをインストールし，その後，再起動してElixirを実行できることがわかりました．

ただし，Erlangはasdfではインストールできず，ソースコードインストールが必要です．Elixirはasdfでインストールできます．

`Mix.install`によって，Arch Linux live USBメモリブート時にあらかじめHexパッケージを読み込んでおくことが可能だということもわかりました．


