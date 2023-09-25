---
title: Middleman v4 で parcel を使って Bootstrap をインストールしてみる
tags:
  - JavaScript
  - middleman
  - parcel
private: false
updated_at: '2017-12-23T00:47:59+09:00'
id: 711a33de47c7b5838815
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
Javascript 界隈の進化は早く，webpack 全盛時代から今度は parcel だと！ さっそく parcel を使ってみました。Bootstrap を使えるようにしてみました。ちょっと残念なことに，完全に parcel だけではうまくいかず，scss の変換で gulp を併用しています。


この記事は下記の2つの記事を再構成しました。

* [Middleman v4 で parcel を使ってみる](https://zacky1972.github.io/tech/2017/12/08/middleman-parcel.html)
* [Middleman v4 + parcel で Bootstrap を使う](https://zacky1972.github.io/tech/2017/12/08/02-middleman-parcel-bootstrap.html)

## 前提: Middleman と yarn の設定

Middleman で Slim を使いたいので次のように設定しました。 

```
$ gem install middleman
$ gem install slim
$ middleman init (プロジェクト名) -T yterajima/middleman-slim
```

最初の Middleman インストール時に次の設定にしました。

* Asset Pipe Line をオフにしました
* Compass, LiveReload はインストールしています
* config.ru を有効にしました。Heroku などにデプロイするときに使います

また，最初から yarn にしたので，yarn をインストールした後，次のコマンドで package.json を初期化しています。

```
$ cd (Middlemanのディレクトリ)
$ yarn init
```

たくさん質問されます。良きように設定してください。

## Middleman v4 で parcel を使えるようにする手順

1. yarn で parcel をインストールする
2. .gitignore を編集する
3. config.rb で，相対パス指定にして external_pipeline の設定に parcel を追加する

## 1. yarn で parcel をインストールする

次のコマンドを実行します。

```
$ yarn global add parcel-bundler
```

## 2. .gitignore を編集する

.gitignore に次の記述を足します。

```
# Ignore yarn log
yarn-error.log

# Ignore node_modules
/node_modules

# Ignore dist
dist/
```

## 3. config.rb で，相対パス指定にして external_pipeline の設定に parcel を追加する

ここが本題。config.rb に次の記述を足します。

```ruby
# 相対パス指定にする
activate :relative_assets

# parcel を呼び出す設定にする
activate :external_pipeline, {
	name: :parcel,
    command: build? ? "parcel build source/javascripts/all.js --out-dir build/javascripts/" : "parcel watch source/javascripts/all.js --out-dir build/javascripts/",
 	source: './build',
	latency: 1
}
```

## Middleman v4 + parcel で Bootstrap を使えるようにする手順

1. yarn で gulp を追加する
2. yarn で gulp-coffee と gulp-sass を追加する
3. config.rb の external_pipeline の設定に parcel と gulp を追加する
4. gulpfile.coffee に scss を変換する設定を追加する
5. site.css.scss を site.scss にリネームする
6. yarn で jQuery, bootstrap, popper.js を追加する
7. site.scss の bootstrap の記述を追加する
8. site.js (もしくは all.js) に bootstrap の記述を追加する

## 1. yarn で gulp を追加する

```
$ cd (Middlemanのディレクトリ)
$ yarn global add gulp
$ yarn add gulp
```

## 2. yarn で gulp-coffee と gulp-sass を追加する

```
$ cd (Middlemanのディレクトリ)
$ yarn add gulp-coffee gulp-sass
```

## 3. config.rb の external_pipeline の設定に parcel と gulp を追加する

config.rb の external_pipeline の設定を次のようにします。

```ruby
activate :relative_assets

activate :external_pipeline, {
    name: :parcel,
    command: build? ? "parcel build source/javascripts/site.js --out-dir build/javascripts/" : "parcel watch source/javascripts/site.js --out-dir build/javascripts/",
    source: "./build",
    latency: 1
}

activate :external_pipeline, {
    name: :gulp,
    command: build? ? "gulp build" : 'gulp watch',
    source: "./build",
    latency: 1
}
```

好みで source/javascripts/site.js を source/javascripts/all.js にしてもいいです。

## 4. gulpfile.coffee に scss を変換する設定を追加する

Middleman のディレクトリに下記のような gulpfile.coffee を追加します。

```coffee
gulp = require 'gulp'
sass = require 'gulp-sass'

gulp.task 'build:sass', () ->
  gulp.src 'source/stylesheets/**/*.scss'
    .pipe sass()
    .pipe gulp.dest('build/stylesheets/')

gulp.task 'watch:sass', ['build:sass'], () ->
  gulp.watch ['source/stylesheets/**/*.scss'], ['build:sass']

gulp.task 'build', ['build:sass']

gulp.task 'watch', ['watch:sass']
```

## 5. site.css.scss を site.scss にリネームする

```
$ cd (Middlemanのディレクトリ)
$ mv source/stylesheets/site.css.scss source/stylesheets/site.scss 
```

## 6. yarn で jQuery, bootstrap, popper.js を追加する

```
$ cd (Middlemanのディレクトリ)
$ yarn add jquery bootstrap@4.0.0-beta.2 popper.js
```

## 7. site.scss の bootstrap の記述を追加する

source/stylesheets/site.scss の冒頭を次のようにします。

```scss
@charset "utf-8";
@import "normalize";
@import "../../node_modules/bootstrap/scss/bootstrap";
```

## 8. site.js (もしくは all.js) に bootstrap の記述を追加する

source/javascripts/site.js (もしくは all.js) に次のように記述します。

```javascript
var $ = window.$ = window.jQuery = require('jquery');
window.Popper = require('popper.js');
require('bootstrap');
```

## 確認方法

まず，Javascript Console でエラーが出ていないことを確認しましょう。

次に source/index.html.slim に下記を追記してボタンを配置してみましょう。

```slim
.container
    button type="button" class="btn btn-danger" Danger
```

サーバーを立ち上げます。

```
$ cd (Middleman のディレクトリ)
$ middleman server
```

[http://localhost:4567](http://localhost:4567) を表示した時に赤いボタンが表示されていれば成功です。

次に source/stylesheets/site.css に下記を追記してみましょう。


```css
body {
	background: orange;
}

@include media-breakpoint-up(md) {
  body {
    background: red;
  }
}
```

サーバーを立ち上げます。

```
$ cd (Middleman のディレクトリ)
$ middleman server
```

PC で　[http://localhost:4567](http://localhost:4567) を表示した時，画面を広くした時に背景が赤くなり，狭くした時に背景がオレンジになれば成功です。

