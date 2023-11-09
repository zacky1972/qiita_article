---
title: Dependabotで依存関係の更新を検出後，自動テストに成功したらPRを自動マージする方法
tags:
  - Elixir
  - dependabot
  - GitHubActions
private: true
updated_at: '2023-11-10T03:46:04+09:00'
id: d1d159f8bcf24d012fbc
organization_url_name: null
slide: false
ignorePublish: false
---
GitHub Actionsでは，Dependabotを使用すると，パッケージなどの依存関係の更新を察知してPRを生成することができます．また，このようなPRを手動でいちいちマージするのは面倒ですが，GitHubに自動マージさせることもできます．さらにテストが成功したら自動マージを行い，失敗したら保留にすることもできます．本記事では，このような方法をご紹介します．

## 例題

本記事では次の例題を扱います．

https://qiita.com/zacky1972/items/993f50a2add27763edf3

この例題では，Elixirでテストを書いていますが，本記事で紹介する方法は，他のプログラミング言語で書いたプログラムにも応用できます．

Dependabotで次のようにしています．

```yaml:.github/dependabot.yml

次のようなコードです．

```yaml:.github/dependabot.yml
# To get started with Dependabot version updates, you'll need to specify which
# package ecosystems to update and where the package manifests are located.
# Please see the documentation for all configuration options:
# https://docs.github.com/github/administering-a-repository/configuration-options-for-dependency-updates

version: 2
updates:
  - package-ecosystem: "github-actions" 
    directory: "/" # Location of package manifests
    schedule:
      interval: "daily"
  - package-ecosystem: "mix" 
    directory: "/" # Location of package manifests
    schedule:
      interval: "daily"
```

またワークフローは次のようになっています．

```yaml:.github/workflows/elixir.yml
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

    strategy:
      matrix:
        elixir-version: ['1.15.7', '1.16.0-rc.0']

    steps:
    - uses: actions/checkout@v4
    - name: Set up Elixir
      uses: erlef/setup-beam@61e01a43a562a89bfc54c7f9a378ff67b03e4a21 # v1.16.0
      with:
        elixir-version: ${{ matrix.elixir-version }} # [Required] Define the Elixir version
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

## 本題

まず，次のコマンドを実行して，ワークフローをコピーして`.github/workflows/dependabot-automerge.yml`を作成します．

```zsh
cp .github/workflows/elixir.yml .github/workflows/dependabot-automerge.yml
```

次に次のように変更します．

```yaml:.github/workflows/dependabot-automerge.yml
# This workflow uses actions that are not certified by GitHub.
# They are provided by a third-party and are governed by
# separate terms of service, privacy policy, and support
# documentation.

name: Dependabot auto-merge

on: pull_request

permissions:
  contents: read

jobs:
  build:

    name: Build and test
    runs-on: ubuntu-latest
    if: ${{ github.actor == 'dependabot[bot]' || github.event.action == 'synchronize' && startsWith( github.head_ref, 'dependabot' ) }}

    strategy:
      matrix:
        elixir-version: ['1.15.7', '1.16.0-rc.0']

    steps:
    - uses: actions/checkout@v4
    - name: Set up Elixir
      uses: erlef/setup-beam@61e01a43a562a89bfc54c7f9a378ff67b03e4a21 # v1.16.0
      with:
        elixir-version: ${{ matrix.elixir-version }} # [Required] Define the Elixir version
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
  dependabot:
    runs-on: ubuntu-latest
    permissions: write-all
    needs: build
    if: ${{ github.actor == 'dependabot[bot]' || github.event.action == 'synchronize'  && startsWith( github.head_ref, 'dependabot' ) }}
    steps:
      - name: Dependabot metadata
        id: metadata
        uses: dependabot/fetch-metadata@v1
        with:
          github-token: "${{ secrets.GITHUB_TOKEN }}"
      - name: Approve and enable auto-merge for Dependabot PRs
        if: |
          ${{ ( steps.metadata.outputs.package-ecosystem == 'mix' && steps.metadata.outputs.update-type == 'version-update:semver-patch' ) || steps.metadata.outputs.package-ecosystem == 'github-actions' }}
        run: |
          gh pr review --approve "$PR_URL"
          gh pr edit "$PR_URL" -t "(auto merged) $PR_TITLE"
          gh pr merge --auto --merge "$PR_URL"
        env:
          PR_URL: ${{ github.event.pull_request.html_url }}
          PR_TITLE: ${{ github.event.pull_request.title }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

これは次のような意図で作っています．

1. `name: Dependabot auto-merge`として名称変更しています．
2. `on: pull_request`として，全てのPRで実行するようにします．
3. `build`ジョブに`if: ${{ github.actor == 'dependabot[bot]' }}`をつけて，Dependabot実行時のみテストするようにします．
4. `dependabot`ジョブについて
  1. `runs-on: ubuntu-latest`として，最もコストの安いUbuntuの最新版でジョブを実行します．
  2. `permissions: write-all` として，書き込み権限を与えます．
  3. `needs: build`とすることで，前のジョブ`build`が正常終了した時，すなわちテストが通った後に実行するように指定します．
  4. `if: ${{ github.actor == 'dependabot[bot]' || github.event.action == 'synchronize'  && startsWith( github.head_ref, 'dependabot' ) }}`とすることで，Dependabotが実行している時のみ，もしくは再pushしてブランチ名が`dependabot`で始まる場合に実行します．
  5. 最初のステップ`Dependabot metadata`は，Denpendabotの実行時に得られるメタデータを取得します．
  6. 次のステップ`Approve and enable auto-merge for Dependabot PRs`が本題です．
    * `steps.metadata.outputs.package-ecosystem == 'mix'` はDependabotの`package-ecosystem`が`mix`の時を表します．
    * `steps.metadata.outputs.update-type == 'version-update:semver-patch'`とすることで，パッチバージョン(バージョン番号が`x.y.z`だった時に`z`のこと)に更新があった時を表します．
    * これらのアンド`&&`を取るので，両方の条件が成立した時に実行します．
    * さらに`steps.metadata.outputs.package-ecosystem == 'github-actions'`は，Dependabotの`package-ecosystem`が`github-actions`の時を表していて，それとのオア`||`を取るので，全体として，`mix`でかつパッチバージョン更新の時か，`github-actions`の時に実行するようにします．
    * 次の`run`により，`gh`コマンドを使用して，PRをapproveしてから，PRのタイトルの先頭に`(auto merged)`を付加し，auto-mergeします．
    * その際に必要な環境変数を`env`以下で設定します．

さらに書き込み権限を与えるために，Settings > Actions > General の，Workflow permissions の Allow GitHub Actions to create and approve pull requests にチェックを入れて，Saveボタンを押します．

Dependabotが動作するような状況になるまで待ちます．うまくいけば，Dependabotが発動し，かつHexパッケージがパッチバージョンの更新か，GitHub Actionsの更新があったときには，次のようにPull Requestに`(auto merged)` という名前が先頭に付記されて，`Merged`かつ`Closed`になる結果になるはずです！

![(auto merged)](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/9175ac8d-3f72-2dea-d274-57019e8ce60b.png)
