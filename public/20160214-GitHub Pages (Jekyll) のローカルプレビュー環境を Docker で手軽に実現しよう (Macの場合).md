---
title: GitHub Pages (Jekyll) のローカルプレビュー環境を Docker で手軽に実現しよう (Macの場合)
tags:
  - Jekyll
  - GithubPages
private: false
updated_at: '2016-02-16T16:17:31+09:00'
id: 2f616963279eff0f33ad
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
# GitHub Pages (Jekyll) のローカルプレビュー環境を Docker で手軽に実現しよう (Macの場合)

## はじめに

Jekyll による GitHub Pages は私にとってとても良いブログ環境です。

* Markdown が使えます。なので，自分好みのテキストエディタでサクサク記事をかけます。
* 無料で使えます。
* WordPress みたいなセキュリティの心配をしなくて済みます。
* ウェブのフロントエンド(HTML, CSS, Javascript)の実験ができます。 
* 音声ファイルのような大きいファイルを置くこともできます。(なので自作Podcastをやっています)

でも，Jekyll のローカルプレビュー環境を構築したり保守したりするのはハードル高いです。当初の方法は gem, rbenv, bundle といった Ruby 環境構築ツールを使いこなす必要がある方法で，初期構築も大変でしたし，構築後わりとすぐに破綻しました。

それでもコンテンツの作成に Markdown エディタを使っていたので，最近まではローカルプレビューがなくても何とかなりました。しかし，最近フロントエンド周り(HTML, CSS, Javascript)の実験を始めたので，ローカルプレビューできないことが苦痛になってきました。

そこでローカルプレビュー環境を再構築しようと思い立っていろいろ調べました。すると Docker を使ったら Ruby 環境構築を頑張らなくてよさそうなことがわかりました(以下の参考記事)。

* [RubyをインストールせずにdockerでGitHub Pagesのプレビュー環境を作るメモ](http://qiita.com/yamamoto-febc/items/8c5b50acb4b6075ee15d)
* [Preview a Jekyll site with Docker on Mac OS X (英語)](https://getcarina.com/docs/tutorials/preview-jekyll-with-docker-on-mac/)

以前より Docker には関心を寄せていたので，ちょうど良い練習材料だろうと思い，チャレンジしてみました。

## 手順1: Docker Toolbox をインストールする

何はともあれ，ローカル環境やクラウド上に Docker Toolbox をインストールする必要があります。

私の場合は，Mac で Homebrew を使っていたので，次のコマンドでインストールしました。

```bash
$ brew cask install dockertoolbox
```

> 参考記事: [Docker Part 1 - Mac に Docker をインストールする〜かんがえるさかな](http://blog.syati.info/post/osx_docker_setup/)


(補足) 私の場合，これ↑に先立って，```brew cask update``` としたらエラーが発生しました。原因は brew cask が brew に統合されたためでした。最近は ```brew update``` とするだけで cask の方もアップデートされます。

もちろん公式サイトからダウンロードしてインストールしても構いません。

* [Docker Toolbox ダウンロードページ(英語)](https://www.docker.com/products/docker-toolbox)
* [Mac での Docker Toolbox インストール方法(英語)](https://docs.docker.com/mac/step_one/)

## 手順2: プレビュー環境を作る

プレビュー環境の作り方は2通りありました。

1. [grahamc / docker-jekyll](https://github.com/grahamc/docker-jekyll) を利用する方法
	* [Preview a Jekyll site with Docker on Mac OS X (英語)](https://getcarina.com/docs/tutorials/preview-jekyll-with-docker-on-mac/)
2. [jekyll / docker ](https://github.com/jekyll/docker) を利用する方法
	* [RubyをインストールせずにdockerでGitHub Pagesのプレビュー環境を作るメモ](http://qiita.com/yamamoto-febc/items/8c5b50acb4b6075ee15d)

1の方法はローカル環境の場合，2の方法はさくらクラウドを使う場合について説明していたので，Docker 初心者の私は 1 から試しはじめ，次に2の方法を取り入れるアレンジも試しました。

というわけで，次のスクリプトを実行してください。それぞれ ```JEKYLL_DIR=/Users/...``` を Jekyll を置いている絶対パスに書き換えてから利用してください。(制約: ユーザーディレクトリ上に存在すること)


### 1. grahamc / docker-jekyll を利用する場合

``` bash
#!/usr/bin/env bash

# Set to the name of the Docker machine you want to use
DOCKER_MACHINE_NAME=default

# Set to the name of the Docker image you want to use
DOCKER_IMAGE_NAME=jekyll

# Set to Absolute Directory of Jekyll site to preview 
JEKYLL_DIR=/Users/...

# Set to Port No.
PORT=4000

# Stop on first error
set -e

# Create a Docker host
if !(docker-machine ls | grep "^$DOCKER_MACHINE_NAME "); then
  docker-machine create --driver virtualbox $DOCKER_MACHINE_NAME
fi

# Start the host
if (docker-machine ls | grep "^$DOCKER_MACHINE_NAME .* Stopped"); then
  docker-machine start $DOCKER_MACHINE_NAME
fi

# Load your Docker host's environment variables
eval $(docker-machine env $DOCKER_MACHINE_NAME)

if [ -e Dockerfile ]; then
  # Build a custom Docker image that has custom Jekyll plug-ins installed
  docker build --tag $DOCKER_IMAGE_NAME --file Dockerfile .

  # Remove dangling images from previous runs
  docker rmi -f $(docker images --filter "dangling=true" -q) > /dev/null 2>&1 || true
else
  # Use an existing Jekyll Docker image
  DOCKER_IMAGE_NAME=grahamc/jekyll
fi

echo "***********************************************************"
echo "  Your site will be available at http://localhost:$PORT"
echo "***********************************************************"

# Port Forwarding
docker-machine ssh $DOCKER_MACHINE_NAME -f -N -L $PORT:localhost:$PORT

# Start Jekyll and watch for changes
docker run --rm -it \
  --volume=$JEKYLL_DIR:/src \
  --publish 127.0.0.1:$PORT:$PORT \
  $DOCKER_IMAGE_NAME \
  serve --watch --incremental --force_polling -H 0.0.0.0
```

### 2. jekyll / docker を利用する方法

``` bash
#!/usr/bin/env bash

# Set to the name of the Docker machine you want to use
DOCKER_MACHINE_NAME=default

# Set to the name of the Docker image you want to use
DOCKER_IMAGE_NAME=jekyll/jekyll:pages

# Set to Absolute Directory of Jekyll site to preview 
JEKYLL_DIR=/Users/...

# Set to Port No.
PORT=4000

# Stop on first error
set -e

# Create a Docker host
if !(docker-machine ls | grep "^$DOCKER_MACHINE_NAME "); then
  docker-machine create --driver virtualbox $DOCKER_MACHINE_NAME
fi

# Start the host
if (docker-machine ls | grep "^$DOCKER_MACHINE_NAME .* Stopped"); then
  docker-machine start $DOCKER_MACHINE_NAME
fi

# Load your Docker host's environment variables
eval $(docker-machine env $DOCKER_MACHINE_NAME)

if [ -e Dockerfile ]; then
  # Build a custom Docker image that has custom Jekyll plug-ins installed
  docker build --tag $DOCKER_IMAGE_NAME --file Dockerfile .

  # Remove dangling images from previous runs
  docker rmi -f $(docker images --filter "dangling=true" -q) > /dev/null 2>&1 || true
else
  # Use an existing Jekyll Docker image
  DOCKER_IMAGE_NAME=jekyll/jekyll:pages
fi

echo "***********************************************************"
echo "  Your site will be available at http://localhost:$PORT"
echo "***********************************************************"

# Port Forwarding
docker-machine ssh $DOCKER_MACHINE_NAME -f -N -L $PORT:localhost:$PORT

# Start Jekyll and watch for changes
docker run --rm -it \
  --volume=$JEKYLL_DIR:/srv/jekyll \
  --publish 127.0.0.1:$PORT:$PORT \
  $DOCKER_IMAGE_NAME 
```

### Jekyll をカスタマイズしたい場合

GitHub pages を利用する場合や，カスタマイズせずに Jekyll を用いる場合は，以下の手順は不要です。

Jekyll に gem を加えてカスタマイズしたい場合は，カレントディレクトリに Dockerfile を配置してください。Dockerfile の書き方は，それぞれの参考記事を参照してください。

1. [grahamc / docker-jekyll](https://github.com/grahamc/docker-jekyll) を利用する方法
	* [Preview a Jekyll site with Docker on Mac OS X (英語)](https://getcarina.com/docs/tutorials/preview-jekyll-with-docker-on-mac/)
2. [jekyll / docker ](https://github.com/jekyll/docker) を利用する方法
	* [RubyをインストールせずにdockerでGitHub Pagesのプレビュー環境を作るメモ](http://qiita.com/yamamoto-febc/items/8c5b50acb4b6075ee15d)

ちなみに Dockerfile を使うと，起動時間が遅くなり，必要なメモリ量も増加します。

## 結果

両方試しましたが，grahamc / docker-jekyll を用いた方がプレビューが立ち上がるまでの時間が短かったです。

## つまづいた点・謝辞

grahamc / docker-jekyll を使う方法で，プレビューを表示しながらエディタでブログ記事を編集しても，プレビューが反映されない問題があったのを解決するのが大変でした。最初は Docker に問題があるのかと思い，牛尾 剛 さんにアドバイスを求めました。迅速に対応していただき，ありがとうございます！

> [ディスカッションの記録(Facebook)](https://www.facebook.com/zacky1972/posts/1117490261617271)

結論としては，Docker に問題はなく，Jekyll serve の起動に --force_polling をつけることで解決しました。

## まとめと将来課題

Ruby の環境を構築することなく，GitHub Pages でローカルプレビューを表示するスクリプトができました。Docker Toolbox をインストールした環境で紹介したスクリプトを実行すれば，細かい設定で悩むことなく，ローカルプレビューできるようになりました。

将来課題としては，自機が MacBook Air (メモリ4GB)と非力なので，クラウドにローカルプレビューサーバーを置く方法についても模索してみたいなと思っています。
