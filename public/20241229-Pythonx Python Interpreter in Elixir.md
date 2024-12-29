---
title: 'Pythonx: Python Interpreter in Elixir'
tags:
  - Python
  - Elixir
private: false
updated_at: '2024-12-29T19:16:20+09:00'
id: 1a369949a699ffcb9a54
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
PythonxはElixir上で使えるPython処理系です．Elixirから気軽にPython資産を使えることが期待できます．

Elixirコミュニティ向けには既に， @RyoWakabayashi さんの手により，下記の記事でPythonxは紹介されています．

https://qiita.com/RyoWakabayashi/items/8cd6a0b1fdf464d86156

今回はPythonコミュニティ向けに，より基礎的なところから記述していきたいと思います．

まず，Livebookのインストール方法からです．Livebookは，Pythonで言うところのJupyterLabに相当するElixirの環境です．

https://livebook.dev/#install

![Livebookホームページ](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/c00bef8d-5449-1a39-ab29-73c1586928e3.png)

まずこのページの"Install Livebook"ボタンを押します．

![Livebookインストールボタン](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/0056c747-0c2f-4473-8f66-ace8bd174dd2.png)

環境に合わせてお好きなボタンを押します．今回の説明ではMacのローカルインストールについて説明しますので，"Mac (Universal)"を選択することにします．

![ダウンロード](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/4aa793d5-b102-e711-39bd-ac2beb22e423.png)

DockのダウンロードにLivebookのimgファイルが配置されますので，クリックして開きます．

![LivebookInstall.img](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/f8d40aaa-0237-2325-9227-a547db2a7a0a.png)

アプリとしてインストールするには，右のLivebookアイコンを左のApplicationフォルダにドラッグして，アプリケーションからLivebookを開きます．お試しで開きたいときには，Livebookアイコンをダブルクリックします．

![Livebook立ち上げ画面](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/fd941a27-d27f-a88c-c4f4-4c229233f8d3.png)

Livebookのホームページです．Jupyterで見慣れたような画面ですね．一応一通り簡単に説明します．

* "+ New notebook"をクリックすると，新しいノートを開くことができます．
* ノートを一旦開くと"Running Session"のところに現れるので，そちらで再開することができます．
* 右下の"Shut Down"を押すと，Livebookを完全に閉じて終了することができます．
* 残りのボタンは，いろいろ押して試してみてください．

![Livebookアイコン](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/cadec535-825e-1d16-44eb-8ca0e40cc6c8.png)

メニューバーの右上の状況メニューにあるこのアイコンをクリックすると次のようなメニューが出てきますので，Livebookのホームページを間違えて閉じてしまったとしても，復活させることができます．

![スクリーンショット 2024-12-29 18.20.37.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/1ba67d21-aeb7-4154-91a2-fc68f2bd35ed.png)

このメニューの"Open"を押せば，Livebookのホームページを開くことができます．

さて，下記に戻ります．

![Livebook立ち上げ画面](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/fd941a27-d27f-a88c-c4f4-4c229233f8d3.png)

"+ New notebook"を押してみましょう．

![Untitled notebook](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/b1588626-84a9-0118-37a6-cb0cac123814.png)

最初に"Notebook dependencies and setup"を押します．

![Notebook dependencies and setup](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/5d78d50a-fe50-26a8-32cc-afb89f2d2622.png)

この黒い画面に次のように打ち込みます．

```elixir
Mix.install([:pythonx, :kino])
```

![Mix.install](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/1d5cd3a7-bdbd-5848-9639-d35f230f0fec.png)

"Reconnect and setup"を押します．

![Mix.install OK画面](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/b1ac8819-0149-07e9-bd4b-f0423d74f7f4.png)

しばらくして，このように `:ok` が出ればセットアップ完了です．

![Section](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/e7f94707-73fc-9429-979e-5e88ac5d69ee.png)

次にこの"Section"の黒い部分に次のように打ち込みます．

```elixir
alias Pythonx.C
alias Pythonx.C.PyDict
alias Pythonx.C.PyErr
alias Pythonx.C.PyFloat
alias Pythonx.C.PyList
alias Pythonx.C.PyLong
alias Pythonx.C.PyObject
alias Pythonx.C.PyRun
alias Pythonx.C.PyTuple
alias Pythonx.C.PyUnicode
```

![alias](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/88d9c755-e2ce-5f16-8fda-4bce3b59678a.png)

"Evaluate"を押します．

![Evaluated alias](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/13e641b7-b3e9-945b-36af-5248ff14bdbb.png)

![Elixirアイコン](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/bf59e877-d18b-407e-cfb0-99977aa7cf7b.png)

下の方にカーソルを持っていくと，次の3つのアイコンが登場します．

* "+ Elixir"
* "+ Block"
* "+ Smart"

"+ Elixir"を押します．

![+ Elixir 押下](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/83e3a5c4-d99a-54a6-159e-991f46350762.png)

こんな感じで，新しい入力画面が出てきます．

この要領で，次のように打ち込んで，都度，"Evaluate"ボタンを押していきます．各コードの説明は，[Elixir Livebook で Python コードを実行する【Pythonx】](https://qiita.com/RyoWakabayashi/items/8cd6a0b1fdf464d86156)をお読みください．

```elixir
Pythonx.initialize_once()
```

なお，このコードの説明

> 内部的には NIF をロードしています

で出てくる"NIF"というのは，Native Implemented Functionの略で，要はElixirからC等のネイティブコードを呼び出すFFI(Foreign function interface)のことです．

https://www.erlang.org/doc/system/nif.html

```elixir
globals = PyDict.new()
locals = PyDict.new()
```

このコード以降を次々を打ち込んで，試してみてください！

ちなみに私の環境だと，下記のみうまく動きませんでした．環境設定の方法について工夫が必要そうでした．

https://qiita.com/RyoWakabayashi/items/8cd6a0b1fdf464d86156#python-スクリプトの実行

P.S. Issue 書きました．

https://github.com/cocoa-xu/pythonx/issues/6