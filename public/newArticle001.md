---
title: AI駆動開発でElixirライブラリをリリース
tags:
  - Elixir
  - Erlang
  - AI駆動開発
  - cursor
private: false
updated_at: ''
id: null
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
CursorによるAI駆動開発でElixirライブラリをリリースしました。

## 開発したElixirコードについて

https://github.com/zacky1972/epmd_up

Elixir/Erlangで分散コンピューティングをするときに、Erlang Port Mapper Daemon (`epmd`)というプログラムを仲介するのですが、`epmd`が起動しているかどうか(`active?`)、`epmd`の起動(`activate`)・停止(`deactivate`)、`epmd`のフルパスの取得を行う関数(`find_epmd_executable`)をまとめた`EpmdUp`というモジュールを作成しました。

`EpmdUp`という命名自体も、AIと相談しながら決めました。

`epmd`が起動しているかどうかの判定と、`epmd`の停止は、公式ドキュメント[Distribution Protocol](https://www.erlang.org/doc/apps/erts/erl_dist_protocol.html)に準拠して決めましたので、ロバストなのではないかなと自負しています。

`epmd`の起動に関して、`deamon`モードで起動するのが正式だとは思っています。

## Cursorの設定

Cursorは英語モードで使用しました。設定の仕方は忘れました。

英語モードにした理由は、2つあります。

* OSSとして公開するので、commit logやissueなど、全て英語にしたかったから
* 日本語でプロンプトを書くと、頭や入力モードを英語と日本語に切り替えるのが煩雑だと思ったから

## AIにさせたこと

* commit logの生成: `Check git diff, and generate a commit log`
* PRの生成: `Check git diff main, and generate PR`
* 命名の提案: `Propose a name of ...`
* Issueの生成: `Generate an issue of ...`
* ドキュメントの生成: `Generate document of ...`

## 今回AIにさせなかったこと

* Elixirコードの生成: 何も情報を与えない状態では、Cursorは満足なElixirコードを生成できませんでした。
* テストコードの生成: Cursorは結構まともなテストコードを生成することは知っていましたが、今回作成したプログラムは少し特殊だったので、テストは自分で書きました。

## ふりかえり

* commit logやissue、PRの英文を自動生成してくれるのは、とてもありがたく、生産性と可読性が向上しました！
* 命名の提案もありがたかったです。モジュール名や関数名がとてもわかりやすくなりました。
* 英文ドキュメントの生成も、手間なくできてありがたかったです。要らないこともたくさん書いてくるのですが、削るのは容易ですし、心も痛みません。

