---
title: gulp-parcel 公開しました
tags:
  - JavaScript
  - parcel
private: false
updated_at: '2017-12-26T09:48:39+09:00'
id: fa7425acbd160c054091
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
# gulp-parcel 公開しました

この記事は，下記の記事の転載です。

* [gulp-parcel 公開しました (実験室 〜 Lab in ZACKY's Laboratory)](https://zacky1972.github.io/tech/2017/12/23/gulp-parcel.html)

parcel を gulp から呼び出すプラグイン gulp-parcel を公開しました。

* [npmjs の公開ページ](https://www.npmjs.com/package/gulp-parcel)
* [ソースコード(GitHub)](https://github.com/zacky1972/gulp-parcel)

はじめて gulp プラグインを作ったので，いろいろ制約があります。

* 入力となる gulp.src では read:false をつけないといけない
* ワーキングディレクトリに .tmp-gulpcompile-xxx というディレクトリを作成し，削除するので，同名のファイルがあるとエラーになったり，消されてしまったりする

インストール方法:

npm の場合

```bash
$ npm install --global parcel-bundler
```

yarn の場合

```bash
$ yarn global add parcel-bundler
```

使い方

gulpfile.coffee

```coffee
parcel = require 'gulp-parcel'

gulp.task 'build:js', () ->
  gulp.src 'source/javascripts/all.js', {read:false}
    .pipe parcel()
    .pipe gulp.dest('build/javascripts/')
```

こうすると，source/javascripts/all.js をエントリポイントとして parcel を起動し，build/javascripts/ 以下に展開します。
