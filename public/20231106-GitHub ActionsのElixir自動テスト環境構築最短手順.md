---
title: GitHub ActionsのElixir自動テスト環境構築最短手順
tags:
  - Elixir
  - dependabot
  - GitHubActions
private: true
updated_at: '2023-11-06T21:05:55+09:00'
id: 993f50a2add27763edf3
organization_url_name: null
slide: false
ignorePublish: false
---
本記事では表題通り，GitHub Actionsを用いてElixir自動テスト環境を構築する最短手順をご紹介します．Dependabotの設定もつけています．

## 手順

本手法の手順は次のとおりです．

1. `mix new`で新しいプロジェクトを作る
2. GitHubでプロジェクトを新規作成し，登録する
3. ActionsでElixirのテスト環境を設定する
4. テストが成功することを確認する
5. (オプション)Matrixを用いて複数バージョンでテストする環境を構築する
6. (オプション)Dependabotを設定する

## 1. `mix new`で新しいプロジェクトを作る

たとえば `sample_project` というプロジェクトを作ってみます．この名称は他の名称に変更しても良いですが，以降の`sample_project`をその名称に変更します．

```zsh
mix new sample_project
```

その後，プロジェクトのディレクトリへ移動します．

```zsh
cd sample_project
```

自動テストを実行する方法は下記のとおりです．

```zsh
mix test
```

緑色で`1 doctest, 1 test, 0 failures`と表示され，テストが成功することを確認します．

## 2. GitHubでプロジェクトを新規作成し，登録する

次にGitHubで`sample_project`というプロジェクトを新規作成します．GitHubにログインすると右上部分が下図のようになっていると思います．

![GitHubの右上](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/40cf1b1b-9906-e4ff-1399-5667a59e6688.png)

なお，私のGitHubアカウントでの画像なので，一番右の画像アイコンは私，山崎進の画像アイコンになっていますが，実際には読者各自のアカウントになります．

このアイコンの`+`記号のボタンを押します．

![GitHub右上で+ボタンを押した時](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/12846308-680c-c790-67f0-7e636c1dac03.png)

この `New repository` を押します．すると次のような画面になります．

![New repository](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/8f8ffe2b-1418-14a7-0258-d0d138d827f3.png)

なお，私のアカウントなので，Ownerには私のアカウントである`zacky1972`が表示されていますが，これは実際には読者各自のアカウントになります．

Repository nameに，手順1で作成したレポジトリ名である`sample_project`を入れます．

![create sample_project and choose public](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/561dc0ab-ab8c-2a20-fb39-e910d7444976.png)

上図のように，緑文字で`sample_project is available.`と出るならば，レポジトリを作成することができます．もしそうではなく，エラーが出るようならば，すでに存在するレポジトリ名である場合が多いので，手順1に戻って別の名前でプロジェクトを作るか，GitHub上の`sample_project`レポジトリを削除してください．

また，このレポジトリを公開したくない時には，その下の `Private` の左にある丸を選択してください．

他はそのままにして，一番下の `Create repository` ボタンを押します．

![Create repository](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/ba916d9e-b540-d3c0-22ff-c15461b94d36.png)

すると画面が切り替わります．

下図の手順に着目します．

![steps](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/cd36016b-e550-f9a1-6389-dd1d0285499a.png)

おそらく `git remote ...` の手順のところは，私とみなさんとで異なるはずです．

次のように打ち込んでいきます．

1. `git init`
2. `git add -A`

続けて，`git commit -m "first commit"`から`git push -u origin main`までをマウスで選択して，コピーし，手順1で操作したターミナル画面にペーストします．ペーストできない場合には，キーボードで順番に打ってください．パスワード等が求められる場合には，状況により，GitHubアカウントのパスワード，SSH鍵のパスフレーズ，指紋認証などで対応します．

うまくいけば，GitHubの画面をリロードすると次のような画面になると思います．

![Created GitHub repository](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/cb19dc42-f59d-5a3a-b4c0-5c8efe3cdd45.png)



## 3. ActionsでElixirのテスト環境を設定する

## 4. テストが成功することを確認する

## 5. (オプション)Matrixを用いて複数バージョンでテストする環境を構築する

## 6. (オプション)Dependabotを設定する
