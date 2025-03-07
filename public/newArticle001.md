---
title: Ubuntu22.04にcolimaをインストールする
tags:
  - Docker
  - Ubuntu
  - colima
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
Dockerを動かす手段の1つとして、`colima`があります。`colima`をmacOSで動かす手順は広く知られていますが、Ubuntu22.04で動かす方法があまり広まっていないので、この度、Qiita記事にまとめてみました。

## 手順

1. Ubuntu22.04にNixをインストールする
2. Nixで`colima`をインストールする
3. Docker ComposeとBuildxをプラグインとして導入する

順に見ていきましょう。

### 1. Ubuntu22.04にNixをインストールする

下記のDeterminate Nix Installerを使用します。

https://github.com/DeterminateSystems/nix-installer

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

途中で`sudo`権限を求められます。また、設問に答える必要があります(`Y`でOK)。

メッセージで表示されますが、最後に下記を実行します。

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### 2. Nixで`colima`をインストールする

下記の手順は古いです。

https://github.com/abiosoft/colima

代わりに下記のコマンドを使います。

```bash
nix profile install nixpkgs#colima
```

### 3. Docker ComposeとBuildxをプラグインとして導入する

基本的には下記に沿って、都度、最新版の手順を実行していきます。

https://zenn.dev/fastsnowy/articles/fd2920d4844bc9

#### Docker Composeをインストールする

https://docs.docker.com/compose/install/linux/#install-the-plugin-manually

最後に `.bashrc` に下記を足します。

```bash:.bashrc
export DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
```

#### Buildxをインストールする

下記から最新版のURLを取得します。

https://github.com/docker/buildx/releases/

下記のようにコマンドを入力します(プラットフォームは `linux-amd64` としています)。

```bash
curl -SL https://github.com/docker/buildx/releases/download/v0.21.2/buildx-v0.21.2.linux-amd64 -o $DOCKER_CONFIG/cli-plugins/docker-buildx
```

```bash
chmod +x $DOCKER_CONFIG/cli-plugins/docker-buildx
docker buildx version
```

バージョンが表示されればbuildxの導入は完了です。

その後、次のコマンドを実行して、`buildx`をデフォルトにします。

```bash
docker buildx install
```


