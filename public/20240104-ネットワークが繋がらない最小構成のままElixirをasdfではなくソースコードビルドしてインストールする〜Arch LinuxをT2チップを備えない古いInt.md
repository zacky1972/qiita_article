---
title: >-
  ネットワークが繋がらない最小構成のままElixirをasdfではなくソースコードビルドしてインストールする〜Arch
  LinuxをT2チップを備えない古いIntel Macにインストールしようとする日々その7
tags:
  - Mac
  - Linux
  - archLinux
  - Elixir
private: false
updated_at: '2024-01-04T10:58:22+09:00'
id: ab537e53fd30ac0d15a6
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は，Ubuntuはよく使うが，Arch Linuxは初めてという私 @zacky1972 が，まずは手近なT2チップを備えていない古いIntel MacにArch Linuxをインストールして習得していく過程を記録する駄文の7回目です．前回まででMac Pro(Mid 2010)へArch Linuxをインストールしたもののネットワークも繋がらない最小構成でしたが，この状態でもElixirをインストールできることを立証しました．ただし，ErlangはソースコードビルドしたもののElixirはasdfのインストールであったため，Elixirを使用するにはrootでログインして使用する必要がありました．そこで，今回はElixirもソースコードビルドして，任意のユーザーがElixirを使用できるようにします．

## シリーズ

1. [Arch LinuxをブートできるUSBメモリを用意する](https://qiita.com/zacky1972/items/9f447f9a11f91e90f6e8)
2. [デュアル・ブート環境にするためにパーティションを区切る](https://qiita.com/zacky1972/items/4b3d8240ff1f4a599908)
3. [いよいよArch Linuxをインストールする](https://qiita.com/zacky1972/items/da1db6795b84151186ab)
4. [ネットワークの設定を見る](https://qiita.com/zacky1972/items/fcce6bdeaf2b87697e3f)
5. [Mac Pro (Mid 2010)にArch Linuxをインストールする](https://qiita.com/zacky1972/items/2904a0a07f9335fdb2de)
6. [ネットワークが繋がらない最小構成のままElixirをインストールして実行してみる](https://qiita.com/zacky1972/items/9a145632c6c12c650bed)
7. ネットワークが繋がらない最小構成のままElixirをasdfではなくソースコードビルドしてインストールする(本記事)

## `fdisk -l`の結果

Mac Pro (Mid 2010)の2024年1月4日現在の`fdisk -l`の結果は次のとおりです．

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

## Elixirのソースコードインストール

手順はこちらに書いてあります．

https://elixir-lang.org/install.html#compiling-from-source

今回は，latest releaseをインストールしたいと思っています．2024年1月4日現在の最新版は1.16.0です．下記のようにダウンロードします．

```bash
cd
curl -OL https://github.com/elixir-lang/elixir/archive/v1.16.0.zip
```

続いて，次のようにビルドします．

```bash
cd elixir-1.16.0
make clean compile
```

しばらくかかります．コンパイルが終わったら，次のようにインストールします．

```bash
make install
```

これで，`/usr/local/bin`に`elixir`がインストールされます．ライブラリは`/usr/local/lib/elixir`にインストールされていました．

## asdfの設定をクリアする

このままだとasdfを優先して読み込むようになっていますので，asdfの設定をクリアします．

```bash
cd
cat .bashrc
```

次のように表示されており，asdfの設定だけが入っている状態です．

```
. $HOME/.asdf/asdf.sh
```

これを削除します．

```bash
rm .bashrc
```

一旦，`arch-chroot`環境を抜けて再度入り直します．

```bash
exit
arch-chroot /mnt
```

次のように確認をします．

```bash
echo $PATH
which elixir
```

無事，asdfの設定がクリアされていましたので，`.asdf`を消します．

```bash
cd
rm -rf .asdf
```

## 起動して確認

次に再起動してSSDで`elixir`を起動できることを確認します．

```bash
exit
reboot
```

2024年1月4日時点での起動シーケンスは下記の通りです．

1. rEFIndの起動で，F2またはInsertを2回押して，カーネル・パラメータの編集画面に移行する．
2. 末尾に`reboot=pci`を足して，Enterキーを押す．
3. ユーザーでログインする

次のようにElixirがユーザーモードで実行できることを確認しました．

```bash
which elixir
elixir -v
iex
iex> 1..10 |> Enum.map(& &1 * 2)
```

