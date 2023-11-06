---
title: Dependabotで依存関係の更新を検出後，自動テストに成功したらPRを自動マージする方法
tags:
  - dependabot
  - GitHubActions
private: true
updated_at: '2023-11-06T22:02:37+09:00'
id: d1d159f8bcf24d012fbc
organization_url_name: null
slide: false
ignorePublish: false
---
GitHub Actionsでは，Dependabotを使用すると，パッケージなどの依存関係の更新を察知してPRを生成することができます．また，このようなPRを手動でいちいちマージするのは面倒ですが，GitHubに自動マージさせることもできます．さらにテストが成功したら自動マージを行い，失敗したら保留にすることもできます．本記事では，このような方法についてステップ・バイ・ステップで紹介していきます．
