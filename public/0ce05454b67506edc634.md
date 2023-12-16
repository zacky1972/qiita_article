---
title: >-
  parcel に Pull Request を送って merge されるまでの顛末記〜生まれてはじめて国際的に OSS
  への貢献をしてみたら，とても歓待された
tags:
  - JavaScript
  - parcel
private: false
updated_at: '2018-01-12T09:13:17+09:00'
id: 0ce05454b67506edc634
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
# parcel に Pull Request を送って merge されるまでの顛末記〜生まれてはじめて国際的に OSS への貢献をしてみたら，とても歓待された

2017年末に parcel に Pull Request を送ってから，年を越して2018年初に merge されました。

[Resolve Dependency correctly if the target asset is URI-encoded #401 (Issue of parcel-bundler/parcel on GitHub)](https://github.com/parcel-bundler/parcel/pull/401#issuecomment-355719292)

※ この記事は [parcel に Pull Request を送って merge されるまでの顛末記〜生まれてはじめて国際的に OSS への貢献をしてみたら，とても歓待された〜実験室 〜 Lab in ZACKY's Laboratory](https://zacky1972.github.io/tech/2018/01/06/parcel-encoding-url.html) を転載しました。

## 背景

Ruby on Rails ライクに静的ウェブページを構築できること，GitHub Pages にも使えることから，次期ブログシステムとして Middleman をいじりはじめました。

Middleman version 4 になって，Ruby on Rails に由来する Asset Pipeline から External Pipeline に移行したことについて，最初は疎ましく思っていたものでした。

しかし，新しい技術に対する知的好奇心から，この Tech ブログで本格的に研究を始め，なんとか Bootstrap v4 を使えるようにしたのは2017年の11月前半のこと。情報発信したことから新たに情報を得て，11月後半には Webpack を使い始め，Javascript 界隈の技術革新の勢いを目の当たりにしたものです。

この頃には純粋に面白くなりはじめ，[KK-SHiFT](https://zacky1972.github.io/KK-SHiFT/)，[SWESTプログラムページ](http://swest.toppers.jp/SWEST19/program/)，[KaFT: プログラミング教育講座](https://zacky1972.github.io/KaFT/kids-expo.html)といったウェブページを，デザイナー志望の山田麻里衣さんによるデザインを私が Middleman v4 の External Pipeline を駆使してコーディングして構築するようになりました。学生のデザインのシンプルさと数々の便利ツールのおかげで，立ち上げに1〜3日という短期間で次々リリースすることができました。

parcel と出会ったのは2017年12月初頭，エンジニア志望の岡住和樹くんからの情報でした。フロントエンドエンジニアとしての目覚めつつあった私に「先生が興味ありそうな」と言って紹介してくれたのが最初でした。ちょうど Qiita でも[webpack時代の終わりとparcel時代のはじまり](https://qiita.com/bitrinjani/items/b08876e0a2618745f54a)がバズり出しました。Middleman と parcel を連携させたという記事も見当たらなかったことから，私の探求心に火がついてすぐに研究を始めました。parcel は設定がほとんど不要でありつつ，とてもいい感じでビルドしてくれるので，すぐに気に入りました。フロントエンドエンジニア志望の村崎拓也くんと研鑽しながら，さっそく私が構築したウェブページのいくつかを Webpack から parcel に乗り換えて実装しました。その試行錯誤の結果，最初の parcel 実践記事である [Middleman v4 で parcel を使って Bootstrap をインストールしてみる](https://qiita.com/zacky1972/items/711a33de47c7b5838815) をリリースしました。

まだ新しいツールなので，ネット上には懐疑的な見方もありました。曰く，parcel はお手軽だが，実用性は Webpack の方が上である，置き換えるものではないと。

しかし私はこの新しいツール parcel に魅せられて，研究を続けます。Middleman から parcel を活用する上で必要性を痛感したので，[gulp-parcel](https://github.com/zacky1972/gulp-parcel) という gulp プラグインを開発しました([gulp-parcel 公開しました](https://qiita.com/zacky1972/items/fa7425acbd160c054091))。gulp-parcel は gulp から parcel がよびだせるという単機能のプラグインです。実は密かにこだわった機能がありまして，gulp-parcel を使うと，複数のファイルを同時並行でビルドできます。これは諸事情で現時点だとあまり有効に機能しないのですが，後に説明することが揃うと威力を発揮すると考えて伏線を張っています。

余談ですが，同時期に開発した Middleman カスタム拡張 [middleman-iepab](https://github.com/zacky1972/middleman-iepab) ([middleman-iepab 公開しました](https://qiita.com/zacky1972/items/738520e0a3eb5f6cdb68)) も，実は parcel を後処理に使うために開発したものだったりします。これも伏線です。

そういうわけで，今，私は parcel の可能性に夢中になっています。

## 不具合の発見から Shawn との出会いまで

さて，parcel の研究を重ねていく上で，一つ気づいた不具合がありました。日本語のファイル名を含む画像等へのリンクを含む HTML ファイルを parcel でビルドしようとすると「ファイルが存在しない」というようなエラーメッセージが出るのです。これは[SWESTプログラムページ](http://swest.toppers.jp/SWEST19/program/)の html ファイルを parcel でビルドしようとして遭遇した不具合です。原因は割とすぐに思い当たりました。日本語を含む URI はエンコードされて表されます。たとえば，次のような感じです。

```html
<img src="images/%e6%97%a5%e6%9c%ac%e8%aa%9e.jpg" />
```

これは「日本語.jpg」という画像ファイルへのリンクですが，URI にするときにエンコードされています。

parcel のソースコードを読んで試行錯誤を重ねるうちに，割と早期に不具合を修正することができました。さっそく Pull Request を送ります。([Resolve Dependency correctly if the target asset is URI-encoded #401 (Issue of parcel-bundler/parcel on GitHub)](https://github.com/parcel-bundler/parcel/pull/401#issuecomment-355719292))

割とすぐに反応があり，(このときはそうとは知らなかったのですが)オーナーの Devon から次のようなコメントが寄せられました。

> I think this should be specific to HTML assets. We don't want to double decode in the case where something has a legit percent symbol in the filename.

要は私の書いたパッチが全てのアセットに無差別に適用されるものだったので，HTML アセット限定にしてくれ，ということでした。

他にも Brandon からダメ出しがあり，とりあえず WIP (Work in Progress: 作業中)ということになって，パッチの初期バージョンは却下されてしまいました。

そこで，私はちょっと勇気を出して次のようにコメントしました。

> Thank you for your comments.
> I'd like to reorganize this patch into the HTML asset, but I can't understand where I should insert the patch into the source code of the HTML asset. Help me!

HTML アセットのソースコードを読んでも，どこをどういじっていいか皆目見当がつかなかったので，助けを求めたわけです。

すると，parcel チームメンバーの Shawn が現れて，人懐っこく次のように助け舟を出してくれました。

> Hi, if you hop on our slack and send me a message (I'm @shawwn) I can help
you sort through the codebase.

そこで，私は parcel の Slack に参加し，Shawn に DM (Direct Message) を送りました。これが Shawn との(たぶん)運命的な出会いです。2018年元旦のことでした。

## Shawn との交流

少し迷いましたが，Shawn にならって，最初の呼びかけは "Hi!" で始めることにしました。

> Hi!
> I'm zacky1972, the owner of this pull request: https://github.com/parcel-bundler/parcel/pull/401

Shawn から速攻で返答がありました。時差の関係で向こうはまだ2017年大晦日だったと思うのだけど，年越しパーティーの準備で忙しかったみたい。こっちも元旦で，初詣に行くところだったので，あとで質問を送ると伝えました。

ところがそれから2時間も経たないうちに Shawn が「年越しパーティは終わったよ！いつでも気軽に質問してきて！すぐに返事するから！」とか送ってくるじゃないですか！ 少々慌てたものの，元旦で忙しかったり，次の日から旅行に行ったりで，特に返事しないまま放置してしまいました。でも1月3日に再び Shawn が「まだ助けは要る？なんでもいいから質問してきてくれたら嬉しいな」とか言ってきたので，さすがに悪いなと思い，旅行中で慌ただしかった合間を縫ってソースコードを読んで返事を返したところ，Shawn があっさり「できた！」と言ってパッチを送ってきます。実はこのコードで正解だったのですが，私が手動でテストした時におそらく手順を間違えたのでしょう，「結果がおかしい」と返答してしまいます。

Shawn は入れ違いに，「日本はまだ早朝なのに，きみはこんなに朝早くから仕事をしているなんて，感銘を受けた！」とか言いながら，なぜか松岡修造の YouTube 動画を送りつけてきます。私はテザリング環境だったので，このときには動画はスルーしたのですが，Shawn が「わかった，#contributors チャネルを見てくれ。Devon が助けてくれるだろう。僕も見るよ」とか言います。この #contributors チャネル，私とのやりとりがきっかけで，Shawn がわざわざ作ってくれたのです！ 私はここで少し感激しました。

Shawn は続けます。「問題のあるテストデータを送ってくれないか？」と。そこで私はいそいそとテストデータを作成します。問題の生じた[SWESTプログラムページ](http://swest.toppers.jp/SWEST19/program/)だと大きすぎるので，現象が再現する最小限のテストデータを作りました。旅行中だったので，途中中断し，夕方にようやく再開できて完成しました。改めてテストしてみたら，きちんと動くじゃないですか！

この時作ったテストデータは[parcel-encodedURI](https://github.com/zacky1972/parcel-encodedURItest)です。もともとの Pull Request で例に書いたのが「日本語.jpg」だったので，ちょっと迷いつつ国旗を表示するようにしたのですが，ちょっと粋な計らいをしようと思って，Shawn の母国の国旗と並べようと思い立ちます。ところが，私がなぜか Shawn をドイツ人だと早合点してしまい，ドイツ国旗と並べます。(実際には Shawn は生まれも育ちもアメリカであることが，後で判明します。)

それはさておき，Shawn は「おめでとう！」と言ってくれて，「再度 Pull Request を送って」と言ってきました。そして「他に助けがいるかい？」と聞いてきます。Pull Request を上書きする方法を知らなかったので，いろいろ調べて，```git push -f``` で送ることを理解しました(参考: [一度送ったプルリクエストを修正する](https://www.pupha.net/archives/2451/))。ついでに[gulp-parcel](https://github.com/zacky1972/gulp-parcel)で困っていることがある，と伝えました。 Shawn はすぐに「gulp-parcel も見ておくよ！」と言ってくれました。

Shawn とはこれ以外にも実にさまざまなことを話し合いました。松岡修造のこと，私が住んでいる北九州のこと，Shawn が住んでいるシカゴのこと，音楽のこと，私の自作の曲のこと，Devon のこと，私が勤めている北九州市立大学での仕事のこと，研究のこと，Shawn の大学に対する思い，学生のこと，などなど。

gulp-parcel のこともしっかり見てくれて，問題の解決までは至らなかったものの，ヒントをいただけました。

## Pull Request のその後

さて，下記の Pull Request の修正版を送ったところ，さっそく反応がありました。

[Resolve Dependency correctly if the target asset is URI-encoded #401 (Issue of parcel-bundler/parcel on GitHub)](https://github.com/parcel-bundler/parcel/pull/401#issuecomment-355719292)

まず Shawn が Approve してくれました。

> This PR looks good to me now. Any further thoughts?
> I think the UTF-8 concern is good, but we might want to merge this for now. Supporting at least one Japanese user is better than supporting all hypothetical foreign users, and @zacky1972 has spent a lot of time on this already.

完璧ではないものの，とりあえずこれでマージしようよとのことです。

すると，オーナーの Devon が次のように言います。

> Would be awesome to add a test if possible, but it looks good to me otherwise!

awesome (すごくいいね)というのだから，すかさず私はテストを追加すると申し出ます。

> OK! I'd like to add a test.

1日寝かせて，仕事が終わった夜中にゴソゴソ起きてテストコードを書きました。parcel のテストは，mocha を使っていて，cross-env で呼び出しています。test/html.js を参考にしながら，サクッと書けました。test/utils.js が実に使い勝手良かったです。

テストコードを書いていて，ふと疑問に思ったのが，ファイルシステムのエンコーディングについてでした。UTF-8 を前提にしていたのですが，そうでないファイルシステムもあるなと思ったのです。そこで，こんなふうに不安を漏らしました。

> I add a test code.
> But, I found another problem. This patch assumes encoding of the file system is UTF-8.
If encoding is CP932, which is used in Windows in Japan, or EUC-JP, which is used in old UNIX system in Japan, the patch might be unworkable.
> I'd like to test such systems, but I don't have them.

手元に Windows も Linux も転がっていなかったので，居ても立ってもいられず，Twitter と Facebook で協力を呼びかけます。

* [https://twitter.com/zacky1972/status/949342180430237697](https://twitter.com/zacky1972/status/949342180430237697)
* [https://www.facebook.com/zacky1972/posts/1799791536720470](https://www.facebook.com/zacky1972/posts/1799791536720470)

> parcel ユーザーで，ファイルシステムが UTF-8 でない Windows や Linux 等をお使いの方いらっしゃいませんか？ テストにご協力ください！#拡散希望

深夜未明だったので，さほど拡散せず。

しかし，Devon が「Node は大丈夫じゃない？」と言ってくれます。

> I think Node will handle converting from UTF8 and back for us, but it would be good to verify. Some info here: https://nodejs.org/api/fs.html#fs_buffer_api

Brandon からは慎重な意見が寄せられます。

> That seems true for the encoding of the files, but decodeURIComponent itself only handles UTF-8 though (and will throw otherwise), even in node. More details: sindresorhus/got#420.
> We may want to take a "try-decode" approach here, continuing with the raw value if decoding fails.

しかし，Devon は次のように言って，ついにマージしてくれました！

> Let's get this in and deal with any other encoding issues as they come up. Thanks for your work on this @zacky1972!

## ふりかえり

とにかく，Shawn がいなかったら，ここまでこぎつけられませんでした。Shawn が人懐っこく，かつ日本のことが大好きで，私のことを歓待してくれたからこそ，私にとって初めての国際的な OSS への貢献の経験が，とても楽しく，心温まるものになったなと思いました。parcel は，とっても温かいコミュニティですよ！ ぜひ貢献することを強くおススメします！ たとえば，[parceljs.org](https://parceljs.org) の日本語訳をしませんか？ もう少ししたらコツコツと始めようと思います。

そして，GitHub と Slack によって OSS が加速しているというのは，こういうことなんだな，ということを強く実感した出来事でした。今までも頭ではわかっていたのですが，体感してみるとまた違った見方ができます。

こういう交流をすると，英語の仕事力は格段に鍛えられますね！ 英語が得意でない私でも，こういうアプローチなら鍛えられそうな気がしたし，Shawn とは parcel についてもプライベートについてもいろいろ話し合いたいです！
