---
title: GitHub ActionsのElixir自動テスト環境構築最短手順
tags:
  - Elixir
  - dependabot
  - GitHubActions
private: true
updated_at: '2023-11-06T20:23:27+09:00'
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

## 3. ActionsでElixirのテスト環境を設定する

## 4. テストが成功することを確認する

## 5. (オプション)Matrixを用いて複数バージョンでテストする環境を構築する

## 6. (オプション)Dependabotを設定する
