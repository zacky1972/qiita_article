---
title: OSS "Pelemay Backend" で行っているGitHub Actionsによる自動化事例2023年12月版
tags:
  - Elixir
  - テスト自動化
  - GitHubActions
private: true
updated_at: '2023-12-18T11:42:13+09:00'
id: c56da534e391de50f597
organization_url_name: null
slide: false
ignorePublish: false
---
私，山崎 進はプログラミング言語Elixir(エリクサー)向けのOSSであるPelemay Backend(ペレメイ・バックエンド)という機械学習基盤を開発しております．本記事では，Pelemay Backend向けに構築したGitHub Actionsによる自動テスト事例について，2023年12月現在の状況を紹介したいと思います．

## Pelemay Backendのレポジトリ

https://github.com/zeam-vm/pelemay_backend

## 今まで山崎進が書いたGitHub Actions関連のQiita記事

https://qiita.com/zacky1972/items/4a7614bff401650fb7d6

https://qiita.com/zacky1972/items/f89ed230ce91b57b6b71

https://qiita.com/zacky1972/items/e0d25c3f77effeb69a94

https://qiita.com/zacky1972/items/eca1ab95fba97cfae96b

https://qiita.com/zacky1972/items/26cfba3d093420bf80a0

https://qiita.com/zacky1972/items/993f50a2add27763edf3

https://qiita.com/zacky1972/items/d1d159f8bcf24d012fbc

## 2023年12月現在のPelemay Backendのディレクトリ構成

CIの対象になっているところのみ

* utilities
    * node_activator
        * A module to activate VM nodes.
        * https://hex.pm/packages/node_activator
    * spawn_co_elixir
        * SpawnCoElixir spawns cooperative Elixir nodes that are supervised.
        * https://hex.pm/packages/spawn_co_elixir
        * Depends on node_activator
    * http_downloader
        * Downloads remote file with progress bar.
        * https://hex.pm/packages/http_downloader
* benchmarks
    * onnx_to_axon_bench
        * A benchmark program of loading ONNX to Axon.
        * Depends on http_downloader
    * distributed_computing_bench (WIP)
        * Depends on spawn_co_elixir and http_downloader
* .github
    * dependabot.yml
    * workflows
        * ci_distributed_computing_bench.yml
        * ci_http_downloader.yml
        * ci_node_activator.yml
        * ci_onnx_to_axon_bench.yml
        * ci_self_hosted_macos.yml
        * ci_spawn_co_elixir.yml
        * dependabot_auto_merge.yml
        * reusable_ci_for_self_hosted_runner_macos.yml
        * reusable_ci_with_working_directory.yml
        * reusable_ci.yml
    * actions
        * matrix_check.yml
        * matrix_dependabot.yml
        * matrix_for_self_hosted_macos.yml
        * matrix_reduced_test_1.yml
        * matrix_reduced_test_2.yml
        * matrix_test.yml
