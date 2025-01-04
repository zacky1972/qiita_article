---
title: Self-hosted Runnerを取りやめた話
tags:
  - GitHubActions
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
[OSS "Pelemay Backend" で行っているGitHub Actionsによる自動化事例2023年12月版](https://qiita.com/zacky1972/items/c56da534e391de50f597)で報告していたように，Self-hosted Runnerを用いてmacOSのx86_64とApple Siliconの両方の自動テストを行っていましたが，最近のGitHubの仕様変更に伴い，セキュリティ上の理由でSelf-hosted Runnerの使用が危ぶまれたので，取り急ぎ，中止することにしました．本記事では，その経緯について説明します．

## GitHub Actions

https://github.co.jp/features/actions

> GitHub Actionsを使用すると、ワールドクラスのCI / CDですべてのソフトウェアワークフローを簡単に自動化できます。 GitHubから直接コードをビルド、テスト、デプロイでき、コードレビュー、ブランチ管理、問題のトリアージを希望どおりに機能させます。

GitHubで行ったソースコード変更等のトリガーで，自動テスト等のスクリプトを自動実行できる便利な仕組みです．

## Self-hosted Runner

GitHub Actionsでは，通常，GitHub-hosted Runnerと言って，GitHubが用意するクラウド環境上でスクリプトを自動実行することができるのですが，Self-hosted Runnerを用いると，レポジトリオーナーが用意したローカル環境でスクリプトを自動実行することができます．

## Self-hosted Runnerのセキュリティ上の注意点

公開レポジトリでは，任意のコードを含むPull Requestを送ることができます．したがって，Self-hosted Runnerを運用していると，悪意あるコードを実行してしまう恐れがあります．

## 今まで運用していた方式

[OSS "Pelemay Backend" で行っているGitHub Actionsによる自動化事例2023年12月版](https://qiita.com/zacky1972/items/c56da534e391de50f597)で今まで運用していた方式は次のとおりです．

* `main` ブランチへは `check_by_SHR` ブランチからのみ Pull Request を受け付けるように設定する
* 一般から受け付けた Pull Requestを元にして，`check_by_SHR` ブランチから `main` ブランチへ Pull Request を発行する際には，コードレビューを行い，悪意あるコードが含まれていないことをよく確認するフローとする．
* `main` ブランチへの Pull Request の時に Self-hosted Runnerによる自動テストを実行する

## いつの間にかGitHubの仕様が変わっていた点について

> * `main` ブランチへは `check_by_SHR` ブランチからのみ Pull Request を受け付けるように設定する

これをSetting>Rules>Rulesetsで `main` ブランチのルールを作成し，Restrict branch names を用いて `check_by_SHR` ブランチのみマッチするように設定していたように記憶しているのですが，いつの間にかEnterprise版でのみ利用できることになってしまっていました．

## 検討した結果

私事ですが，今，私が使える研究開発のための予算が年度末のため欠乏している関係で，Enterpriseにすぐに加入することができません．そこで，応急措置として，Self-hosted Runnerの運用自体を取りやめることにしました．