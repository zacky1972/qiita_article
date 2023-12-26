---
title: Catalina で Erlang OTP 24.0.1 と Elixir 1.12.0 を asdf でインストールする
tags:
  - Erlang
  - Elixir
  - asdf
private: false
updated_at: '2021-05-22T14:22:33+09:00'
id: b8963ac3eeca7e1edf36
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
JITを搭載した新しいErlangであるOTP24がリリースされました。しかし，リリース前後にあった `autoconf`のバージョンアップにともなって`OTP24.0`の `configure` プロセスに不具合が出てしまうというアクシデントに見舞われました。そこで，[この Issue](https://github.com/erlang/otp/issues/4821) が立ち上がり，解決を図ったOTP24.0.1がリリースされました。

この記事は，Erlang OTP24.0.1の `asdf` でのビルド方法について紹介するものです。現状ではまだ `asdf-erlang` と，それが使用している `kerl` が追従していないので，ビルドに若干の手間がかかります。

# 動作確認した環境

次の環境で動作確認しました。

* macOS Catalina (x86_64)

Big Surでは x86_64, ARM ともに通常のインストールで大丈夫でした。

Linux環境は，現在当方の環境がメンテナンス中のため，しばらく試すことができません。もし試した人がいたら，教えてください。

## 追記

2021.5.21 14:00

もしかすると，この記事に書いたことは少なくとも Big Sur では既に不要になっているようです。

引き続き確認を続けます。

2021.5.21 20:40

Catalina では通常のインストールだと依然としてエラーとなりました。
Big Surでは問題が表出しないということだと思います。

2021.5.21 20.45

手順2は無くてもよいかもしれません。環境によってもし問題が出たらこの対処をするという感じだと思います。

2021.5.22 14:22

タイトルにCatalinaと明記しました。

# 1. asdf が使用している kerl にパッチを当てる

`~/.asdf/plugins/erlang/kerl` に https://github.com/erlang/otp/issues/4821#issuecomment-840342780 が示しているパッチを当てます。

```
diff --git a/kerl b/kerl
index 6345138..53c12f3 100755
--- a/kerl
+++ b/kerl
@@ -791,8 +791,9 @@ _flags() {
     # We need to munge the LD and DED flags for clang 9/10 shipped with
     # High Sierra (macOS 10.13) and Mojave (macOS 10.14) and quite
     # probably for Catalina (macOS 10.15)
+    # disabled (originally for Darwin)
     case "$KERL_SYSTEM" in
-        Darwin)
+        Darwin-disabled)
             osver=$(uname -r)
             case "$osver" in
                 # TODO: Remove this in a future kerl release, probably
```

# 2. もし途中でエラーになるならば，DED_LDFLAGS つきで asdf を用いて Erlang OTP 24.0.1 をビルドする

もし上記パッチを当ててビルドしてもエラーになるようであれば，次のようにインストールします。

```
DED_LDFLAGS="-m64 -bundle -bundle_loader ~/.asdf/plugins/erlang/kerl-home/builds/asdf_24.0.1/otp_src_24.0.1/bin/x86_64-apple-darwin19.6.0/beam.smp" asdf install erlang 24.0.1
```

# Elixir 1.12.0 をインストールする

```
asdf install elixir 1.12.0-otp-24
```

