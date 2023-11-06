---
title: GitHub ActionsのElixir自動テスト環境構築最短手順
tags:
  - Elixir
  - dependabot
  - GitHubActions
private: true
updated_at: '2023-11-06T20:17:53+09:00'
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

