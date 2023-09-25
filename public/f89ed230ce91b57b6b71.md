---
title: GitHub ActionsのワークフローでElixirのDialyzerをキャッシュして高速化する
tags:
  - Elixir
  - dialyzer
  - GitHubActions
  - dialyxir
private: false
updated_at: '2023-06-18T11:32:52+09:00'
id: f89ed230ce91b57b6b71
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
GitHub Actionsのワークフローで `mix dialyzer` を実行するとかなりの時間がかかる問題を，キャッシュすることで解決する方法を編み出しました．

前回の記事

https://qiita.com/zacky1972/items/4a7614bff401650fb7d6

基本的には `_build/dev/dialyxir_erlang-*_elixir-*_deps-dev.plt*` をキャッシュしてあげれば良いです．

そこで，シングルレポジトリの場合には，次のようにします(Ubuntu上だけで`mix dialyzer`を実行するとしています)．

```yaml
    - name: Restore dialyzer cache (Ubuntu)
      if: ${{ startsWith(runner.os, 'linux') }}
      uses: actions/cache@v3
      with:
        path: ${{ github.workspace }}/_build/dev/dialyxir_erlang-${{ matrix.otp-version }}_elixir-${{ matrix.elixir-version }}_deps-dev.plt*
        key: ${{ runner.os }}-${{ steps.system-info.outputs.release }}-Elixir-${{ matrix.elixir-version }}-OTP-${{ matrix.otp-version }}-plt
        restore-keys: ${{ runner.os }}-${{ steps.system-info.outputs.release }}-Elixir-${{ matrix.elixir-version }}-OTP-${{ matrix.otp-version }}-plt
```

ただし，マルチレポジトリ構成にしているときには，次のように，それぞれのサブプロジェクトで別々のIDになるようにキャッシュしてあげないとエラーになります．

```yaml
    - name: Restore dialyzer cache (Ubuntu)
      if: ${{ startsWith(runner.os, 'linux') }}
      uses: actions/cache@v3
      with:
        path: ${{ github.workspace }}/${{ matrix.working-directory }}/_build/dev/dialyxir_erlang-${{ matrix.otp-version }}_elixir-${{ matrix.elixir-version }}_deps-dev.plt*
        key: ${{ runner.os }}-${{ steps.system-info.outputs.release }}-Elixir-${{ matrix.elixir-version }}-OTP-${{ matrix.otp-version }}-repo-${{ matrix.working-directory }}-plt
        restore-keys: ${{ runner.os }}-${{ steps.system-info.outputs.release }}-Elixir-${{ matrix.elixir-version }}-OTP-${{ matrix.otp-version }}-repo-${{ matrix.working-directory }}-plt
```


