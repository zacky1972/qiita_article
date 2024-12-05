---
title: OpenCV の Elixir バインディング Evision の紹介
tags:
  - OpenCV
  - Elixir
  - evision
private: false
updated_at: '2024-12-05T22:29:01+09:00'
id: 9b37f73290ae6b57d42f
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
プログラミング言語ElixirにもOpenCVを使えるようにするバインディングEvisionがあります．ElixirにおけるJupyter NoteにあたるLivebookでEvisionを使う方法について紹介します．

## Livebookインストール方法

https://livebook.dev/#install

![livebook.dev](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/d2005a9f-ec4d-d69e-6467-71f4fcb1b1c3.png)

下の Run on your machine で Mac もしくは Windows を選ぶか，Run in the cloud の Run on Hugging Face を選ぶ，あるいは，Linux等の場合は，check our READMEを選んで，Dockerで実行します．

## Livebook

下記で + New notebook とします．

![Livebook](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/efa14954-b85e-b594-bc29-67ed39c822ef.png)

## Evision実行

Reconnect and setup をクリックして，下記を入れて実行します．

```elixir
Mix.install([:evision, :kino])
```

これにより，Evisionと，Livebookで画像等を表示するプラグインであるKinoをインストールします．

正常に終了した後で，SectionのEvaluateのところに下記を入れて実行します．

```elixir
Evision.imread("(お好きな画像へのPATH)")
```

![Run Evision](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/75804b40-8e35-1b43-bf3e-81194a0165d4.png)

基本的に`cv.(メソッド名)`と書くところを`Evision.(関数名)`とすれば，OpenCVプログラマであれば，大体直観的に動かせると思います．

## Evisionの仕組み

Evisionの仕組みって結構巧みにできています．OpenCVのソースコードを読み込んで，Pythonバインディングのコードをパースすることで，インタフェースとC++ライブラリの呼び出すコードを取得し，ElixirとC++FFIのコードを自動生成するというような離れ技をやっているように思います．すごい技術力ですね！
