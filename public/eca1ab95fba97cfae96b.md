---
title: GitHub Actionsの再利用可能なワークフローに別YAMLファイルで指定したmatrixを与えたい場合
tags:
  - Ruby
  - Erlang
  - Elixir
  - GitHubActions
private: false
updated_at: '2023-08-08T18:48:45+09:00'
id: eca1ab95fba97cfae96b
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
GitHub Actionsの再利用可能なワークフローに，入力として別YAMLファイルで指定したmatrixを与える方法について，苦心の末，ようやく実現できましたので，ご報告します．

ElixirとErlang/OTPのバージョンのmatrixを与える場合を例に書きます．

# matrixの与え方

通常のmatrixだと次のように与える場合について，

```yaml:matrix.yml
- otp-version: ['24.3.4.13', '25.3.2.3', '26.0.2']
  elixir-version: ['1.14.5', '1.15.4']
```

次のように展開し，さらに`include:`の下につけます．エラーにならないよう，`.github/workflows`とは別のディレクトリに配置することもポイントです．

```yaml:.github/actions/matrix.yml
include:
  - otp-version: '24.3.4.13'
    elixir-version: '1.14.5'
  - otp-version: '24.3.4.13'
    elixir-version: '1.15.4'
  - otp-version: '25.3.2.3'
    elixir-version: '1.14.5'
  - otp-version: '25.3.2.3'
    elixir-version: '1.15.4'
  - otp-version: '26.0.2'
    elixir-version: '1.14.5'
  - otp-version: '26.0.2'
    elixir-version: '1.15.4'
```


# 再利用可能なワークフローの書き方

次のようにします．

```yaml:.github/workflows/reusable_ci.yml
name: Reusable workflow

on:
  workflow_call:
    inputs:
      matrix:
        required: true
        type: string
      
jobs:
  reusable_ci:

    name: On ${{ matrix.elixir-version }}, ${{ matrix.otp-version }}
    runs-on: ubuntu-latest
    strategy:
      matrix: ${{ fromJSON(inputs.matrix) }}
    steps:
    - run: echo "done."
```

`fromJSON`を用いることがポイントです．

https://docs.github.com/ja/actions/learn-github-actions/expressions#fromjson


# 呼び出し側

次のようにします．

```yaml
name: Caller CI

on:
  pull_request:
    types: [opened, reopened, synchronize]
    branches: [ "main", "develop" ]
  push:
    branches: [ "main", "develop" ]    

jobs:
  constants:
    name: Constants
    runs-on: ubuntu-latest
    outputs:
      matrix: ${{ steps.set-matrix.outputs.matrix }}
    steps:
      - uses: actions/checkout@v3
      - id: set-matrix
        run: |
          json=$(cat ${{ github.workspace }}/.github/actions/matrix.yml| ruby -ryaml -rjson -e 'puts YAML.load(STDIN).to_json')
          echo "matrix=${json}" >> $GITHUB_OUTPUT
  call_reusable_workflows:
    name: Call Reusable Workflows
    needs: constants
    uses: ./.github/workflows/reusable_ci.yml
    with:
      matrix: ${{ needs.constants.outputs.matrix }}
```

あらかじめ，`id: set-matrix` としておきます．

YAMLからJSONへの変換のRubyワンライナー`cat file.yml| ruby -ryaml -rjson -e 'puts YAML.load(STDIN).to_json'` がポイントです．これで1行のJSONで出力されます． (Thanks! @zumin )

その値を環境変数`json`に一旦格納し，`echo "matrix=${json}" >> $GITHUB_OUTPUT`とすることで，`matrix`変数への出力として格納します．

それを `matrix: ${{ steps.set-matrix.outputs.matrix }}` として出力された`matrix`の値を参照したものを，`matrix`に入れます．

それをその後の呼び出しで，`with: matrix: ${{ needs.constants.outputs.matrix }}` として，再利用可能なワークフローに渡します．
