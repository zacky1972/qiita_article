---
title: OSS "Pelemay Backend" で行っているGitHub Actionsによる自動化事例2023年12月版
tags:
  - Elixir
  - テスト自動化
  - GitHubActions
private: false
updated_at: '2023-12-21T17:10:06+09:00'
id: c56da534e391de50f597
organization_url_name: null
slide: false
ignorePublish: false
---
私，山崎 進はプログラミング言語Elixir(エリクサー)向けのOSSであるPelemay Backend(ペレメイ・バックエンド)という機械学習基盤を開発しております．本記事では，Pelemay Backend向けに構築したGitHub Actionsによる自動テスト事例について，2023年12月現在の状況を紹介したいと思います．

## Pelemay Backendのレポジトリ

https://github.com/zeam-vm/pelemay_backend

## 2023年12月現在のPelemay Backendのブランチ構成

* main
* check_by_SHR

運用としては次のようにします．

1. Issueごとに新しくブランチを作成して作業する
2. 1が出来上がったら，`check_by_SHR`にPRを送って，GitHub-hosted Runnerによるチェック(Ubuntu)を受ける．
3. 2のチェックをクリアしたら，マージし，`main`にPRを作成し，コード差分を読む．ライブラリの更新があった時には，Changelogを読む．脆弱性の確認と，機種依存のコードの有無を確認する．特に機種依存のコードがある場合には熟読して精査する．
4. 3に問題がなければ，PRを送って，Self-hosted Runnerによるチェックを受ける．2023年12月現在は次のSelf-hosted Runnerが存在する
    * macOS Sonoma 14.2.1 / x86_64
    * macOS Sonoma 14.2.1 / Apple Silicon 
5. 4のチェックをクリアしたらマージする．

## 2023年12月現在のPelemay Backendのディレクトリ構成

CIの対象になっているところのみ

* `utilities`
    * `node_activator`
        * A module to activate VM nodes.
        * https://hex.pm/packages/node_activator
    * `spawn_co_elixir`
        * SpawnCoElixir spawns cooperative Elixir nodes that are supervised.
        * https://hex.pm/packages/spawn_co_elixir
        * Depends on `node_activator`
    * `http_downloader`
        * Downloads remote file with progress bar.
        * https://hex.pm/packages/http_downloader
* `benchmarks`
    * `onnx_to_axon_bench`
        * A benchmark program of loading ONNX to Axon.
        * Depends on `http_downloader`
    * `distributed_computing_bench` (WIP)
        * Depends on `spawn_co_elixir` and `http_downloader`
* `.github`
    * `dependabot.yml`
        * Dependabotの設定．下記の更新をチェックする
            * GitHub Actions
            * Hex
    * `workflows`
        * `ci_node_activator.yml`
            * `utilities/node_activator`に更新があった時に実行するワークフロー
            * `node_activator`と，`node_activator`に依存する下記のモジュールのテストを行う
                * `spawn_co_elixir`
                * `distributed_computing_bench`
        * `ci_spawn_co_elixir.yml`
            * `utilities/spawn_co_elixir`に更新があった時に実行するワークフロー
            * `spawn_co_elixir`と，`spawn_co_elixir`に依存する下記のモジュールのテストを行う
                * `distributed_computing_bench`
        * `ci_http_downloader.yml`
            * `utilities/http_downloader`に更新があった時に実行するワークフロー
            * `http_downloader`と，`http_downloader`に依存する下記のモジュールのテストを行う
                * `onnx_to_axon_bench`
                * `distributed_computing_bench`
        * `ci_onnx_to_axon_bench.yml`
            * `benchmarks/onnx_to_axon_bench`に更新があった時に実行する
            * `onnx_to_axon_bench`のテストを行う
        * `ci_distributed_computing_bench.yml`
            * `benchmarks/distributed_computing_bench`に更新があった時に実行するワークフロー
            * `distributed_computing_bench`のテストを行う
        * `reusable_ci.yml`
            * 下記の引数を伴って呼び出されるGitHub-hosted runnerのワークフロー([詳細](#再利用可能ワークフロー))
                * `working_directory`
                * `os`
                * `matrix`
                    * 下記を与える
                        * `otp-version`
                        * `elixir-version`
                * `perform-check`
                    * `true`の時は，下記を行う
                        * `mix compile --warnings-as-errors`
                        * `mix format --check-formatted`
                        * `mix credo`
                        * `mix dialyzer`
                    * `false`の時は下記を行う
                        * `mix test`
        * `dependabot_auto_merge.yml`
            * Dependabotを実行しているとき，再利用可能ワークフローをテストしてパスした後，次のいずれかの条件の時には，自動でマージする
                * パッケージシステムが`hex`で，パッチバージョンのみの変更だった場合
                * パッケージシステムがGitHub Actions
        * `reusable_ci_with_working_directory.yml`
            * 下記の引数を伴って呼び出されるGitHub-hosted runnerのワークフロー([詳細](#再利用可能ワークフロー))
                * `os`
                * `matrix`
                    * 下記を与える
                        * `otp-version`
                        * `elixir-version`
                        * `working_directory`
                * `perform-check`
                    * `true`の時は，下記を行う
                        * `mix compile --warnings-as-errors`
                        * `mix format --check-formatted`
                        * `mix credo`
                        * `mix dialyzer`
                    * `false`の時は下記を行う
                        * `mix test`
        * `ci_self_hosted_macos.yml`
            * macOS向けSelf-hosted Runnerのワークフロー
            * テストのみを行う
        * `reusable_ci_for_self_hosted_runner_macos.yml`
            * 下記の引数を伴って呼び出されるmacOSのSelf-hosted runnerのワークフロー
                * `matrix`
                    * 下記を与える
                        * `otp-version`
                        * `elixir-version`
                        * `working_directory`
                * `arch`
                    * 下記のいずれかを与える
                        * `X64`
                        * `ARM64`
    * `actions`
        * `matrix_check.yml`
            * チェック用のマトリクス
            * 単一Elixir/Erlang環境
        * `matrix_test.yml`
            * テスト用の環境
            * Elixir/Erlangのサポート環境を網羅
        * `matrix_reduced_test_1.yml`
            * 回帰テスト用の環境
            * 組み合わせを削減
            * `matrix_reduced_test_2.yml`と合わせることで，Elixir/Erlangのサポート環境を網羅
        * `matrix_reduced_test_2.yml`
            * 回帰テスト用の環境
            * 組み合わせを削減
            * `matrix_reduced_test_1.yml`と合わせることで，Elixir/Erlangのサポート環境を網羅
        * `matrix_dependabot.yml`
            * Dependabot Automerge用のマトリクス
            * `working-directory`がついている
            * 今のところ単一Elixir/Erlang環境
        * `matrix_for_self_hosted_macos.yml`
            * Self-hosted Runner用の環境
            * `working-directory`がついている
            * 今のところ単一Erlang環境/複数Elixir環境

## 再利用可能ワークフロー

次の手順を実行する

1. チェックアウト
2. `kenchan0130/actions-system-info`によるシステム情報の取得
3. OTPのメジャーバージョンとマイナーバーションの取得
4. ElixirとErlangのバージョンの設定
5. `erlef/setup-beam`によるElixirのセットアップ
6. 5が失敗した時
    1. `asdf`インストール
    2. `asdf`キャッシュからの復旧
    3. 2が失敗した時に`asdf`による設定
7. dependenciesキャッシュからの復旧
8. 7が失敗した時に次を実行
    1. `mix local.hex`
    2. `mix local.rebar`
    3. `mix deps.get`
9. `perform-check`が`true`の時に次の手順を実行
    1. `mix compile --warnings-as-errors`
    2. `mix format --check-formatted`
    3. `mix credo`
    4. `dialyzer`キャッシュ復旧
    5. `mix dialyzer`
10. `perform-check`が`false`の時に次の手順を実行
    1. `mix test`

## 今まで山崎進が書いたGitHub Actions関連のQiita記事

https://qiita.com/zacky1972/items/4a7614bff401650fb7d6

https://qiita.com/zacky1972/items/f89ed230ce91b57b6b71

https://qiita.com/zacky1972/items/e0d25c3f77effeb69a94

https://qiita.com/zacky1972/items/eca1ab95fba97cfae96b

https://qiita.com/zacky1972/items/26cfba3d093420bf80a0

https://qiita.com/zacky1972/items/993f50a2add27763edf3

https://qiita.com/zacky1972/items/d1d159f8bcf24d012fbc

