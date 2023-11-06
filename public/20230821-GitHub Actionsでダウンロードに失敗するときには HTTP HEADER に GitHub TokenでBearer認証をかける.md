---
title: GitHub Actionsでダウンロードに失敗するときには HTTP HEADER に GitHub TokenでBearer認証をかける
tags:
  - Elixir
  - GitHubActions
  - nx
  - EXLA
private: false
updated_at: '2023-08-21T21:50:17+09:00'
id: 26cfba3d093420bf80a0
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
GitHub Actionsで，たとえばEXLAのように大きなファイルをダウンロードするような
Hexライブラリを利用する場合に，GitHub ActionsによるCIでダウンロードに
失敗することがあります．本記事は，そのような場合に有効な方法を示します．
[Jonatan Kłosko](https://github.com/jonatanklosko) さんが教えてくれました．

## 方法 (EXLAの場合)

次のようにして，環境変数 `XLA_HTTP_HEADERS` に GitHub Token で Bearer 認証をかけます．

```yaml
env:
  XLA_HTTP_HEADERS: "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}"
```

## 一般解

HTTPでダウンロードするときに，HTTP HEADERに `Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}` を渡します．

## 適用例

https://github.com/zeam-vm/pelemay_backend/pull/232



