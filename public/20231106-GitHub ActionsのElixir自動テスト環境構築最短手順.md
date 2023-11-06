---
title: GitHub ActionsのElixir自動テスト環境構築最短手順
tags:
  - Elixir
  - dependabot
  - GitHubActions
private: true
updated_at: '2023-11-06T21:29:47+09:00'
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

作成したGitHubプロジェクトの下図部分の`Actions`をクリックします．

![tool bar](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/8a03b20b-d783-e58f-e91f-0966c77c6d90.png)

すると下図のような画面になると思います．おすすめされるままに`Elixir`の下の`Configure`を押します．

![Get Started with GitHub Actions](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/d121275e-fdf5-b882-cf95-c95b4b8dcb70.png)

すると下図のような画面になります．

![elixir.yml](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/bb38a125-e770-1706-8074-97a98f67e9d4.png)

コードは次のとおりです．

```yaml:elixir.yaml
# This workflow uses actions that are not certified by GitHub.
# They are provided by a third-party and are governed by
# separate terms of service, privacy policy, and support
# documentation.

name: Elixir CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

permissions:
  contents: read

jobs:
  build:

    name: Build and test
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Set up Elixir
      uses: erlef/setup-beam@61e01a43a562a89bfc54c7f9a378ff67b03e4a21 # v1.16.0
      with:
        elixir-version: '1.15.2' # [Required] Define the Elixir version
        otp-version: '26.0'      # [Required] Define the Erlang/OTP version
    - name: Restore dependencies cache
      uses: actions/cache@v3
      with:
        path: deps
        key: ${{ runner.os }}-mix-${{ hashFiles('**/mix.lock') }}
        restore-keys: ${{ runner.os }}-mix-
    - name: Install dependencies
      run: mix deps.get
    - name: Run tests
      run: mix test
```

右上の緑色の`Commit changes...`を押します．すると次のポップアップが出ますので，右下の`Commit changes`を押します．

![Popup](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/1646cd81-55db-de6a-b487-94a4aeedef87.png)

## 4. テストが成功することを確認する

その後，プロジェクト画面に戻るので，`Actions`を押します．

![tool bar](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/8a03b20b-d783-e58f-e91f-0966c77c6d90.png)

順調にいけば，下記のワークフローが緑✅で完了するのですが，私の場合，次のようにエラーになりました．

![Create elixir.yml](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/773a1635-3378-3715-78ee-d506e1c7ba79.png)

`Create elixir.yml`をクリックして，`Build and test`をクリックすると，下図のようなログを出して，原因を探ることができます．この場合，`mix.exs`に定義しているElixirバージョンが新しすぎたみたいです．

![Log](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/3f69d9ae-91f9-fe26-f379-631107795726.png)

`mix.exs`は次のようでした．

```elixir
defmodule SampleProject.MixProject do
  use Mix.Project

  def project do
    [
      app: :sample_project,
      version: "0.1.0",
      elixir: "~> 1.16-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
```

この `project` 関数の中の `elixir:` の後の，`1.16-rc`を`1.15`に変更して，commitし，pushします．

プロジェクト画面の`Actions`を再確認すると，次のように成功しました．

![Success](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/b5654cb9-1ad5-5015-4fab-70ac42cef87b.png)

## 5. (オプション)Matrixを用いて複数バージョンでテストする環境を構築する

## 6. (オプション)Dependabotを設定する
