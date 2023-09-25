---
title: GitHub Actionsでモノレポジトリ構成の部品間の依存関係に沿った自動回帰テストを備えたCIを構築する(Elixirの場合)
tags:
  - テスト
  - CI
  - Elixir
  - テスト自動化
  - GitHubActions
private: false
updated_at: '2023-07-11T16:05:04+09:00'
id: e0d25c3f77effeb69a94
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
GitHub Actionsの活用方法について日夜研究しています．モノレポジトリ構成にしている自作のOSS Pelemay Backend(下記)でGitHub ActionsによるCIを組んでいたのですが，ソフトウェア部品が増えたためにCIにかかる時間が増大してしまったので，今回，部品間の依存関係に沿って自動回帰テストを実装してみたところ，いくつか課題があるものの，概ね成功しましたので，Qiita記事にまとめてみました．

https://github.com/zeam-vm/pelemay_backend

## Pelemay Backend内のソフトウェア部品の依存関係について(2023年7月現在)

2023年7月には2つ目のマイルストーンに取り組んでいて，現在，次の3つのソフトウェア部品をリリースしています．

* NodeActivator
* SpawnCoElixir
* OnnxToAxonBench

それぞれのソフトウェア部品がどのようなものかの説明はさておいて，依存関係を図示すると次のようになります．

* SpawnCoElixir → NodeActivator
* OnnxToAxonBench

## 自動回帰テストの設計方針

GitHub Actionsでは，指定したブランチもしくはプルリクエストの中の更新されたファイルの集合について，指定したパスを包含する場合，もしくは指定したパスを含まない場合に，ワークフローを開始するような設定をすることが可能です．その方法は次のドキュメントにまとめられています．

https://docs.github.com/ja/actions/using-workflows/triggering-a-workflow#例-パスの包含および除外

また，ワークフローを部品化して再利用することもできます．その方法は次のドキュメントにまとめられています．

https://docs.github.com/ja/actions/using-workflows/reusing-workflows

さらに，複数のジョブを含むワークフローがあったときに，ジョブ1が成功したらジョブ2を実行するという依存関係を次のように記述することができます．

https://docs.github.com/ja/actions/using-jobs/using-jobs-in-a-workflow#defining-prerequisite-jobs

これらを統合することで，ソフトウェア部品間の依存関係に沿った自動回帰テストを概ね実現できます．

1. それぞれのソフトウェア部品のパスを包含するようなファイル更新があった時に，ワークフローを開始するようなスターターワークフローを定義する．
1. 再利用可能なワークフローを，ソフトウェア部品のパスを入力として受け取り，一通りの単体テスト・統合テストを実施するように定義する．
1. 1のジョブとして，まず該当ソフトウェア部品の単体テストを，2を呼び出すことで実施し，それが成功したら，そのソフトウェア部品に依存するソフトウェア部品の統合テストを，2を呼び出すことで実施するように，`needs`を使って依存関係を定義する．

以下にそれぞれについて，どのように実装したかを説明します．その後で，将来課題について述べます．

### ステップ1: ソフトウェア部品のパスを包含するようなファイル更新をトリガーとするスターターワークフローを定義する

たとえば，NodeActivatorの場合は次のようにトリガーを定義しています．

https://github.com/zeam-vm/pelemay_backend/blob/main/.github/workflows/ci_node_activator.yml#L8-L33

ここでのポイントは`paths:`と `- 'utilities/node_activator/*'`です．この対により，NodeActivator配下のファイルに更新があったときに自動テストを走らせることができます．

ただ，今これを見ると，潜在的な問題点があることに気づきました．将来課題で述べます．

### ステップ2: ソフトウェア部品のパスを入力としてテストを実施する，再利用可能なワークフローを定義する

Pelemay Backendでは，次のような再利用可能なワークフローを定義しました．

https://github.com/zeam-vm/pelemay_backend/blob/main/.github/workflows/reusable_elixir_ci.yml

記述のポイントは下記です．

https://github.com/zeam-vm/pelemay_backend/blob/9bd605d54e1495a377f19e27ff8c885c0440c239/.github/workflows/reusable_elixir_ci.yml#L9-L13

これにより，再利用可能ワークフローであることを明示し，かつ入力として`working-directory`を必須の文字列として受け取ることを定義しています．

この`working-directory`の参照の仕方は，たとえば次のようになります．

https://github.com/zeam-vm/pelemay_backend/blob/9bd605d54e1495a377f19e27ff8c885c0440c239/.github/workflows/reusable_elixir_ci.yml#L113C39-L113C70

この再利用可能ワークフローがどのような手順でテストしているかについては，下記記事を参照ください．

https://qiita.com/zacky1972/items/4a7614bff401650fb7d6

https://qiita.com/zacky1972/items/f89ed230ce91b57b6b71


### ステップ3: 単体テスト後に統合テストを実施するワークフローを定義する

NodeActivatorをテストした後，成功した場合には，SpawnCoElixirをテストするように，下記で記述しています．

https://github.com/zeam-vm/pelemay_backend/blob/9bd605d54e1495a377f19e27ff8c885c0440c239/.github/workflows/ci_node_activator.yml#L42-L51

ここでのポイントは，次の3点です．

* `uses`で2で定義した再利用可能ワークフローを指定している
* `with: working-directory`で各ソフトウェア部品へのパスを指定している
* `needs: elixir_ci_node_activator`とすることで，NodeActivatorの自動テストが成功してからSpawnCoElixirの自動テストを実行するように設定している

## 将来課題

現状では，ソフトウェア部品NodeActivatorとSpawnCoElixirの両方に更新があった場合，SpawnCoElixirのテストを2回実行してしまいます．この問題を回避する方法について，調査を進めています．

もし，この問題について，解決するためのアイデアや情報をお持ちの方がいましたら，是非コメントをお寄せください．

また，`paths` の記述のルールからすると，部品中の`*.md`や`LICENSE`に更新があった場合でも，自動テストが発動してしまうような気がします．記述の順番を入れ替えないといけないように思います．
