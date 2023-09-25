---
title: >-
  Apple Silicon (M1/M2) Mac に Phoenix Framework 向けに Homebrew で PostgreSQL
  をインストールする際のエラーを解消する方法
tags:
  - Mac
  - homebrew
  - PostgreSQL
  - Phoenix
  - AppleSilicon
private: false
updated_at: '2023-03-12T09:01:09+09:00'
id: 26c88709bd80b1ca30b9
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
Apple Silicon (M1/M2) Mac に Phoenix Framework 向けに Homebrew で PostgreSQL をインストールする際のエラーを解消する方法を説明します．

# 再現手順

1. `brew install postgresql` あるいは `brew install postgresql@14` を実行する
1. `psql -U postgres` を実行する
1. エラーが出る

# エラーその1

こんな感じのエラーが出る場合

```zsh
psql: error: connection to server on socket "/tmp/.s.PGSQL.5432" failed: No such file or directory
	Is the server running locally and accepting connections on that socket?
```

このエラーは，PostgreSQLを起動し忘れている時に発生します．

まず手順を次のようにしないといけないのでした．

1. `brew install postgresql` あるいは `brew install postgresql@14` を実行する
1. `brew services start postgresql` あるいは `brew services start postgresql@14`を実行する(どちらを実行するかについては，その前のコマンドに合わせる)
1. `psql -U postgres` を実行する

# エラー対応の一般論

この状況で何かエラーが出る場合

まず，PostgreSQLのログを確認します．PostgreSQLのログの場所は次のとおりです．

```zsh
`brew --prefix`/var/log/postgresql@14.log
```

(`@14`が付かない場合もあります)

次のようなコマンドで，ログの末尾を確認します．

```zsh
tail -100 `brew --prefix`/var/log/postgresql@14.log
```

エラーとなる場合には，`exited with exit code 1` とか `ERROR` とか `FATAL` とか出ます．

このエラーメッセージをコピーして，postgresqlというキーワードとともにGoogle検索します．英語のページも出てくると思いますが，機械翻訳すれば怖くない！1つずつ問題を解消していけば，最終的に`psql -U postgres`で正常に起動できるようになると思います．

このような対処方法をするときに，使用するコマンドがどのような作用を持つのかについて，調べるというのが良いです．そうすると深い理解につながりますし，書かれた通りに実行してもうまくいかなかったときにも対応できるようになります．

# エラーの例その2

次のようなエラーが出ていた場合

```zsh
FATAL: role postgres does not exist 
```

このエラーは，`postgres`というロール(ユーザー)が存在しないという意味です．

世の中に，このエラーに対処する様々な環境での試行錯誤の結果が溢れかえっているので，Apple Silicon Macの場合にぴたりと当てはまる事例を探すのにとても苦労しました．

その中で，下記の手順を見つけました．

https://gist.github.com/dnovais/c6c6894b95d764be2aca9736436edd0e

これはIntel Macの場合の手順なので，Apple Silicon Macの場合には次のようになります．

```zsh
/opt/homebrew/Cellar/postgresql/<version>/bin/createuser -s postgres
```

`postgresql`の部分が`postgresql@14`になることはあります．また，`<version>`には，`14.6`などが実際には入ります．

Intel/Apple Silicon両方の場合に対応した手順にして，初心者にもわかるように次のように手順を書いてみました．

まず，ターミナルに次のように打ち込んでください．

```zsh
`brew --prefix`
```

続けて次のように打ち込み続けます．

```zsh
`brew --prefix`/Cel
```

ここでタブキーを2回打ちます．すると次のように表示されるでしょう(Apple Silicon Macの場合)．

```zsh
/opt/homebrew/Cellar/
```

これはオートコンプリージョン(自動補完)という機能です．この機能を使うと最小限のキータイプでコマンドを打つことができます．

次のように続けます．

```zsh
/opt/homebrew/Cellar/postgres
```

ここでもタブキーを打ちます．すると実際にインストールしたpostgreSQLのバージョンに合わせて次のようになります．(あるいは候補が出ます)

```zsh
/opt/homebrew/Cellar/postgresql@14/
```

もう一度タブキーを押すとおそらく `<version>` の部分が補完されます．私の環境では次のようになりました．

```zsh
/opt/homebrew/Cellar/postgresql@14/14.6_1/
```

続けて次のようにコマンドを打ち込みます．

```zsh
/opt/homebrew/Cellar/postgresql@14/14.6_1/bin/createuser -s postgres
```

このコマンドはユーザーを作るというコマンドです．これを実行すれば，問題が解決できると思います．




















