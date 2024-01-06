---
title: Pelemayをふりかえる
tags:
  - Elixir
  - Pelemay
  - nx
private: false
updated_at: '2021-12-24T07:02:11+09:00'
id: fabfbc651ef21ad81ae4
organization_url_name: null
slide: false
ignorePublish: false
---
昨日は @im_miolab さんの[技術コミュニティを2年間運営して主宰イベントを50回開催してきた上で意識や工夫してきたこと](https://qiita.com/im_miolab/items/584b0adfa1921d88526b)でした。

# はじめに〜なぜこの文章を書き始めたか

Pelemay(ペレメイ)というのは，私が研究開発しているElixir向けSIMD方式の並列処理系です。

この文章を書くことになったきっかけは k.nako @kn339264 さんが始めた[「Elixirコミュニティの歩き方〜国内オンライン編〜」](https://speakerdeck.com/elijo/elixirkomiyunitei-falsebu-kifang-guo-nei-onrainbian)からでした。

https://twitter.com/kn339264/status/1456986610973622276

このときに k.nako さんがPelemayMeetupの説明がうまくできない状況だったようです。

それで次のようなツイートになりました。

https://twitter.com/kn339264/status/1451225457186074626?s=20

このスレッドでのやりとりをふりかえって，私が痛感したことを次の引用リツイートに書きました。

https://twitter.com/zacky1972/status/1451457153458327560?s=20

名文化→明文化ですね。最近老眼の進行のせいか，誤字が。。。

それを受けて，k.nakoさんが次の企画を提案しました。

https://pelemay.connpass.com/event/229288/

この企画も直前に押し迫った11月11日に今年も[fukuoka.ex Advent Calendar 2021](https://qiita.com/advent-calendar/2021/fukuokaex)に書いてほしいという @piacerex さんの要望を受け，何を書こうかと考えました。

で，翌11月12日にエントリーした際に，Pelemayの歴史のふりかえりを寄稿することを思い立った次第です。

# あらすじ

1. 黎明期〜研究を開始する以前の話
1. Hastega(ヘイスガ)発表前史〜研究を開始してからLonestar ElixirConf 2019で発表するまで
1. Lonestar ElixirConf 2019〜世界デビュー，[Lunchisode](https://smartlogic.io/podcast/elixir-wizards/special-lonestar-elixir-2019/)，そして José Valim (ジョゼ・ヴァリム)との初対面・ディスカッション
1. FAIS支援による研究開発第1期〜 @hisaway の活躍
1. HastegaからPelemayへ〜凱旋報告，Pelemayへの改称，そして ElixirConf US 2019での発表
1. FAIS支援による研究開発第2期〜Pelemay Meetupスタート
1. minsoraとJST A-STEP トライアウトの支援による研究開発第1期〜ElixirConf US 2020での発表，PelemayFpの発表
1. minsoraとJST A-STEP トライアウトの支援による研究開発第2期〜JoséによるNxの発表，Nxへの合流，BEAM/OTP対話とSIMD勉強会
1. 2022年に向けての抱負

思いつきですが，ダラダラと時系列順に書くのではなく，いくつかの論点に沿って「伏線とその回収」という感じでまとめた方がわかりやすいのではないかという気がします。

# 論点その1: 私がPelemayの研究開発を始めたのはなぜか，そして JoséがPelemayに期待し，その後Nxを作ったのはどんな動機によるものか

@zacky1972 視点

* 私がElixirを研究対象とするきっかけは， @piacerex さんの誘いによるもの
* 私がElixirを研究対象として選んだのは，次のような理由
    * Elixirがイミュータブルであること
    * そのことの意義が，並列性を始め，とても奥深いものであったこと
    * 私が既存のプログラミング言語で不満に思っていたことがミュータブルに起因することだったことに気づいたこと
* [GPGPUとEnum/Flowのプログラミングが類似していたことがPelemay(Hastega)の研究の始まりだったこと](https://qiita.com/zacky1972/items/140d2380dfdf727b22bc)
* 私が2018年4月ごろにElixirでの研究開発のテーマの候補として，GPGPUと軽量コールバックスレッドのどちらにするかを @piacerex さんに聞いたところ，GPGPUと答えたことで，GPGPUの研究にフォーカスしたこと

José視点

* 少なくとも2019年のLonestar ElixirConf 2019時点で，Elixirを機械学習等の文脈で数値演算(number crunching)を行わせることにJoséが強く興味を持っていたことが，[Lunchisode](https://smartlogic.io/podcast/elixir-wizards/special-lonestar-elixir-2019/)に記録されている。
* その Lunchisode で，そのことを知らない私がただ GPU というキーワードに反応して，[直後にする自分の発表 "Hastega: Challenge for GPGPU on Elixir"](https://youtu.be/lypqlGlK1So)について，語り始めたので，Joséが関心を持って，講演終了後にディスカッションをしてきた
* ElixirConf US 2019のJoséのkeynoteにて，Hastegaの名前が大きく掲示される
* その後も，Joséは，積極的に私のことを支援してくれた
* その後，Joséは，Nxを発表。そのお披露目をした[Thinking Elixir PodcastでPelemayとの違いを言及(22:30付近から)。](https://thinkingelixir.com/podcast-episodes/034-jose-valim-reveals-project-nx/)。曰く，Elixirのサブセットを定義して，数値演算により適した形にしたということだと思う。

# Pelemay Meetup にて

これをもとにふりかえりの会をしました。

https://youtu.be/QW8kvYn-VxE


# 明日は

@piacerex さんです。お楽しみに
