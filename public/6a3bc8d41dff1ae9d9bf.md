---
title: 続・ソフトウェア技術者のための英語習得法の案
tags:
  - English
private: false
updated_at: '2022-06-14T09:25:43+09:00'
id: 6a3bc8d41dff1ae9d9bf
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
前回，[「ソフトウェア技術者のための英語習得法の案」](https://qiita.com/zacky1972/items/7114bfe8c6d203c3d67e)を書いてから1年経ちました。今の自分の状態を自己申告する「定点観測」の意味も込めて，第2弾を書いてみたいと思います。

# 数年前までの私の英語能力

まず，私の英語能力の変遷について，正直に告白したいと思います。

* 高校時代に英語で赤点(落第一歩手前の成績)を取っていた。
* 受験の時には，文法は得点できていたが，単語をあまり覚えておらず，単語力を試される問題や長文読解が課題だった。
* 大学時代に外国語が理由で留年するところだった(再履修で難を逃れた)。
* たしか大学院生時代に受けたTOEICはいちおう700点台まで到達したが，ほとんどはreadingで得点していて，listeningはかなりボロボロだった。
* 4技能を分析すると reading >> writing > speaking >>>>>> listening という感じ。
* 英英辞典・シソーラスは，博士後期課程の時から使い始めて，10何年にも渡ってじっくり取り組んでいた。おかげで reading & writing に関しては，それなりに自信がついたのと，課題だった語彙力をある程度カバーできるようになった。
* かつて英語の学習法はいろいろ試したが，自分に合った学習法がないなと感じていた。

# Slack で手応え

こんな私が変わる経緯は，[「parcel に Pull Request を送って merge されるまでの顛末記〜生まれてはじめて国際的に OSS への貢献をしてみたら，とても歓待された」](https://qiita.com/zacky1972/items/0ce05454b67506edc634)に詳細に書いています。

要約すると次の通りです。

1. parcel というOSSライブラリに強く興味を持ち，OSSを作ろうとした。
2. 自分だけでは解決できない不具合があったので，意を決して parcel Slack に参加した。
3. Shawn という人懐っこい parcel チームメンバーの人が優しく手解きしてくれたので，無事貢献できた。
4. Slack を通じて Shawn と公私にわたって英語でやりとりをしたことで，はじめて英語の習得に手応えを感じた。

残念ながらその後，Shawn は parcel チームから去ったようで，連絡が取れなくなり，私自身も parcel から遠のいてしまって疎遠になってしまいました。

これで得られた教訓は次の通りです。

* reading / writing に問題は少ないが，listening に難のある人は，Slack を用いると，ストレス少なくコミュニケーションが取れる。
* Slack はリアルタイム性が要求されるので，reading / writing を通して，listening / speaking 能力も磨かれる。
* 英語圏の友達を持つことは，コミュニケーションのニーズと欲求が自然と発生するので，英語のトレーニングには効果的。

# Lonestar ElixirConf 2019 での登壇経験

その後，私は Elixir の研究に邁進するようになり，1年間かけて Pelemay (昔は Hastega と呼んでいました) というGPGPUライブラリのプロトタイプを構築することに成功しました。その研究成果を携えて，Lonestar ElixirConf 2019 に発表申し込みをします。

※ その節には，北九州産業学術推進機構(FAIS)新成長戦略推進研究開発事業(シーズ創出・実用性検証事業)の研究助成をいただきました。また，Japan Elixir Association に旅費の支援をいただきました。この場を借りて改めて厚く御礼申し上げます。

そのときの講演の動画はこちらです。

[![スクリーンショット 2020-03-17 2.42.44.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/076aa231-de3a-a3fb-40a5-09a75696fd01.png)](https://youtu.be/lypqlGlK1So)

今，改めて聴くと，発音の日本訛りがひどく，しゃべるスピードもかなりゆっくりですし，頻繁に言い間違えていますねw

この時の狙いとしては，日本語のプレゼンテーションでは絶対やらないのですが，アメリカでは禅や侍のような日本文化はウケるだろう，ということと，以前，たしか電波少年だったと思うのですが，ダウンタウンの松本人志氏が渡米して，アメリカで馬鹿ウケするギャグを研究し，たとえばバナナで滑ってコケる，みたいな単純なギャグをしつこく繰り返す，というギャグがとてもウケる，という法則を発見するという話があったのですが，それを意識して，コテコテにしつこくメタファーを繰り返す，たとえばディストピア(理想郷＝ユートピアの逆の概念)をメタファーとして繰返し見せて印象付ける，というようなことをしました。この狙いは大成功し，笑いが絶えず拍手喝采で，ベストプレゼンテーションだったね！と褒められるに至りました。

また，現代の流行である，写真や簡潔で抽象的な短文1つをスライドに映して，あとは1枚あたり2〜3分喋り倒す，というようなプレゼンテーションスタイルは，日本語でやるならいざ知らず，今の私の英語力では無謀である，という自覚はあったのと，発音が悪いのも自覚していたので，これも日本語のプレゼンテーションでは絶対やらないのですが，しゃべるセリフをスライドに全部書いておき，それを読み上げるというスタイルにしました。これも功を奏し，発音にかかわらず，意図が確実に伝わるプレゼンテーションに仕上がったかなと思います。

あとは，アメリカ人に馴染みが深いであろう，ハリウッド映画(ターミネーターなど)や文学作品(三銃士)のパロディも，著作権に最大限配慮した形で，ふんだんに盛り込みました。欧米のプレゼンテーションや書籍では，書籍や詩，演説などの一節を引用して，意図を伝えるというスタイルが一般的です。このことはつまり，幅広い教養が試されるという意味でもあります。

発表練習もかなり入念にしました。このときは発表当日前夜遅くまで，同行した2人 @piacerex @takasehideki とともにプレゼンテーションを詰めていました。その前に発表練習したにも関わらず，大幅な改修が入ってしまったので，私は半泣きでした。でも，その大幅な改修を急いで済ませた後，寝る間を惜しんで発表練習を繰り返しました。

Lonestar ElixirConf 2019 に行く前に取り組んでいた英語学習法をまとめたのが，前掲の[「ソフトウェア技術者のための英語習得法の案」](https://qiita.com/zacky1972/items/7114bfe8c6d203c3d67e)です。

要約すると次の通りです。

私にとって劇的に効果的だった英語習得方法をご紹介します。

1. フォニックス
2. 多読
3. 海外技術交流のSlack

# Lonestar ElixirConf 2019 での Lunchisode 

実はその発表の前のランチタイムの講師控室にて Lunchisode という，Elixir Wizards Podcast の収録がありました。

[![スクリーンショット 2020-03-17 3.10.12.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/2db73916-397f-bee6-21e8-50e0b440f26e.png)](https://podcast.smartlogic.io/special-lonestar-elixir-2019)

私はそのことを知らずに，講師控室にて1人で発表練習をしていました。そうしたらいつの間にやら大勢の人に取り囲まれ，何やらディスカッションが始まります。気にせず1人でブツブツと発表練習をしていたところ，ふいに声をかけられて，自己紹介しろと言われます。？？？と思いながら自己紹介をして，発表練習をやめてディスカッションに耳を傾け始めました。プログラミング言語の Elixir(エリクサー) 作者の José Valim (ジョゼ・バリム) が意図せず私の隣に座っていたことに気づきます。私にはディスカッションはほとんど聞き取れなかったのですが，何やらElixirにおけるコンパイラが話題に上っているっぽいということに気づきます。そこで意を決して，会話に割り込みました。「今，コンパイラについて話していますか？」いっせいに全員が私に注目します。そのまま，私は，たどたどしい英語で自分の研究成果について話しました。Joséが目を輝かせて私に質問してきます。私も頭が真っ白になりながら，なんとか説明をしました。Elixir のウェブフレームワーク Phoenix 作者の Chris McCord (クリス・マッコード) も話題に入ってきました。途中でこの議論が収録されていることに私は気づきます。このようなやりとりの後，私からの発言に満足して，皆は次の話題に移り，私はホッとして再び議論に聞き入りました。議論の詳細は依然として掴めないものの，Elixir の将来構想について話しているようでした。私にとって夢のようなひと時でした。

この時の様子は [Transcript (議事録) も記録されています。](https://assets.fireside.fm/file/fireside-images/podcasts/transcripts/0/03a50f66-dc5e-4da4-ab6e-31895b6d4c9e/episodes/4/4646981d-f12c-479e-a5cc-7629570962ed/transcript.txt) 後で公開されたので，読んでみると，空気読めない私が，そう大して空気を外していない発言をすることができていたことがわかりました。(私の発言は Zaki になっています)

ここで，勇気，というか，蛮勇をふりしぼって発言したことで，この場に居合わせた出席者全員が私に注目するようになり，熱心に私の発表に耳を傾けてくれる結果になりました。この時の「蛮勇」によって，私は今のポジションが築けたのだなとふりかえって思います。

Lonestar ElixirConf 2019 と Lunchisode で得られた教訓は次の通りです。

* 海外のカンファレンスに行った時に，ただ受け身になって講演を聞くのも良いが，下手でもいいので，とにかく発表する。自分が語れる話題を持っていれば，たとえ英語が下手でも興味を持って耳を傾けてくれる。
* グループディスカッションで盛り上がっていて割り込む隙がなくても，話題を完全には聞き取れなくて場の空気を壊してしまうのが怖いなと思っても，勇気を振り絞ってしゃべる。たとえば「今，〇〇について話していた？」という質問から始めてもOK。そのあと，それについての話題をていねいに語る。そうするとちゃんと耳を傾けてくれる。蛮勇大事。

# ElixirConf US 2019 での講演

その後も研究を続け，ElixirConf US 2019 にて発表することになりました。

※ その節には，科学技術振興機構(JST)未来社会創造事業，北九州産業学術推進機構(FAIS)新成長戦略推進研究開発事業(シーズ創出・実用性検証事業)，中小企業庁戦略的基盤技術高度化支援事業からそれぞれ研究助成をいただいて，いくつもの研究成果をまとめ上げることができました。この場を借りて厚く御礼申し上げます。

[![スクリーンショット 2020-03-17 3.45.41.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/4567f72e-2311-9a2c-bcf9-57cc3380a690.png)](https://youtu.be/uCkPyfFhPxI)

前回の Lonestar ElixirConf 2019 の時の発表と比べて，かなり発音が良くなっていると思います。ECCに通っている子と一緒に毎日フォニックスに基づいて英語のトレーニングをした結果だと思います。

子の英語教育の方針についてと，私自身の英語トレーニング方法については，同僚の岡本清美先生と，[日本トランスレーション協会のリチャード朋子先生](https://tomokorichard.com/profile/)に助言をいただきました。お二人に加え，リチャード朋子先生を紹介してくださった[Kids Code Club](https://kidscodeclub.jp)の石川麻衣子さんにも，厚く御礼申し上げます。

リチャード朋子先生が私の英語の状態を診断した結果，効果的なトレーニング方法はフォニックスに加えて，[オーバーラッピング](https://eikaiwa.weblio.jp/column/study/overlapping-method)という方法を紹介いただきました。これは，先ほどの Lunchisode のような Transcription がついている音声に合わせて読み上げるという，シャドーイングに近い方法です。

ただし，ElixirConf US 2019のときにはオーバーラッピングは，それほど熱心には取り組んでいませんでした。日々の生活の中で，子とともに，[NHKのえいごであそぼ](https://www4.nhk.or.jp/eigodeasobo/)と，ECCの教材に沿って，毎日英語を練習するので精一杯だったところがあります。それでも毎日取り組んでいたというのは効果的だったようで，少なくとも発音はぐっと良くなりました。

このときのプレゼンテーションのポイントは，前回を踏襲しつつ，アメリカ人が深くは知らないであろう日本の歴史と古典文化を紹介することを中心に展開しました。聴衆の反応としては，笑い声は前回より減ってどちらかというと静かだったのですが，最後の拍手は多かったです。おそらく，初めて触れる日本の歴史と古典文化の話だったので，真剣に話に聞き入っていたものの，笑っていいかどうかわからずにいたんだと思います。私たちがアメリカ人のプレゼンテーションを聞いている時に，周りが笑っているけど，自分は聞き入って考え込む状態になることがあると思うのですが，こういう状況に近かったんじゃないかと思います。

あと，前回の Lonestar ElxirConf 2019 や，ElixirConf を主催する Dr. Jim Freeze (ジム・フリーズ)，ElixirConf JP 2019にて基調講演をすることになった Nerves co-auther の Justin Schneck (ジャスティン・シュネック), そしてもちろん，Elixir 作者の José Valim，Phoenix 作者の Chris McCord へのリスペクトをふんだんに盛り込んだというのもこだわりポイントです。

ちなみに Return of Wabi-Sabi というタイトルは，前回の Lonestar ElixirConf 2019 の講演終了直後に，司会の Justus (ジャスティス)から "Wabi-Sabi!!!!" と激励されて握手を求められるシーンがあったのと，Star Wars の Return of Jedi (ジェダイの帰還) のオマージュです。

# Lonestar Elixir 2020 にて

3回目の参加を今年の2月末にしてきました。本当は発表するつもりで応募したのですが，あえなく落選してしまっていたのでした。気を取り直して，ElixirConf JP 2020 の宣伝のために，と参加申込みをして，はじめて一般参加として参加しました。

COVID-19の問題があったので，今年から主催者になった Bruce Tate (ブルース・テート)にあらかじめメッセージを送って，参加可否を尋ねました。

Bruce Tate は昨年の Lonestar ElixirConf 2019 にて，私の講演の次に講演しました。講演タイトルは The River Elixir.next。これは実に熱い講演で，大河の流れにたとえて，Elixir コミュニティの歴史とありかたについて問いかけるものでした。

[![スクリーンショット 2020-03-17 4.50.21.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/1a38772a-c3aa-af76-aefc-4a483b255944.png)](https://youtu.be/KW85rW6-PgI)

さて，COVID-19に直面して参加可否を尋ねる際に送ったメッセージは次の通りです。

> Dear Bruce, 
> Coronaviruses (COVIDs) are prevalent in China. Also in Japan, they begin prevalent.
> I heard news that the US Congress is discussing Japan's countermeasures against coronavirus, especially the issue of the Diamond Princess. I have also heard that Americans have a negative sentiment for Japan on this issue.
> This issue affects the following:
> 1. I'll go to Lonestar Elixir. I am worried that other participants may be afraid of infection when I'll go to these, even if I'm not infected, now. 
> 2. I'll make an announcement for ElixirConf JP 2020 at these time. I am very worried that American participants will have a negative feeling at ElixirConf JP and no one will be participating. I guess it is necessary to explain the measures against COVIDs in ElixirConf JP.
> Please comment on these issues.

> ブルース，
> コロナウイルス(COVID)が中国で流行しています。日本でも流行し始めています。
> 私はアメリカ議会が日本のコロナウイルス対策について議論を始めたというニュースを聞きました。
> とくに，ダイヤモンドプリンセス号の問題についてです。
> 私はアメリカン人がこの問題について日本に対しネガティブな感情を持っているとも聞きました。
> この問題は次のような影響があります。
> 1. 私はLonestar Elixirに行くつもりです。私が心配しているのは，私が行った時に他の参加者が感染を心配するのではないかということです。もし今は私が感染していなかったとしても。
> 2. 私は ElixirConf JP 2020 について告知をする予定です。
> 私が特に心配しているのは，アメリカの参加者がElixirConf JP にネガティブな感情を持って誰も参加しなくなるのではないかということです。
> 私はElixirConf JPにおいてCOVIDについてどのように対策するかについて説明する必要があるんじゃないかと考えています。
> この問題について意見をください。

これに対する Bruce の回答は，即座に，次のように熱いメッセージでした。

> I think you are wise to think about these issues. However, I think you are underestimating the Lonestar conference attendees. As for the leadership...
> You are well known and respected among us. Do what you need to do to be safe. That is your job. We will do what we need to do to make you feel respected and welcome. That is our job. 
> We trust you, Zacky. We are looking forward to seeing you.
> You are one of us!

> この問題に関して，あなたは賢明だと思います。
> しかし，あなたは Lonestar カンファレンスの参加者について過小評価しています。リーダーシップについて...
> あなたは私たちからよく知られていて尊敬されています。
> あなたは安全に関してすべきことをしてください。それはあなたの仕事です。
> 私たちはあなたが尊敬され歓迎されていると感じるように場を整えます。それは私たちの仕事です。
> Zacky, 私たちはあなたを信用します。会えることを楽しみにしています。
> あなたは私たちの一部です！

この言葉には本当に感激しました。次のように返しました。

> I am moved by your words and shed tears...!!!

Bruce の言葉通り，現地では全力で歓待を受けました。Bruce や，Justin, Justus はじめとして，たくさんの友達と再会し，新たに友達を作りました。

[![ForLonestarElixir.001.jpeg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/cb22b87f-e0b2-6e0a-31f7-26a244d6d8a6.jpeg)](https://speakerdeck.com/zacky1972/introduction-of-elixirconf-jp-2020)

ここで一番こだわったポイントはこちらです。

[![ForLonestarElixir.002.jpeg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/0e8e23d8-c50f-d10a-5606-7193e047460c.jpeg)](https://speakerdeck.com/zacky1972/introduction-of-elixirconf-jp-2020?slide=2)

昨今の COVID-19 を踏まえて日本の状況を説明するというものでした。当時はまだアメリカには感染者は出ておらず，日本で流行が深刻化していた時期でした。なので，恐怖心を煽らないように，日本の状況をユーモアを交えて説明するということに細心の注意を払いました。そこで，"WASH MY HANDS", "DO NOT KISS ME!" というような冗談を入れました。

この冗談は大いにウケ，居合わせた参加者から「DO NOT KISS ME! は実によかった」というような反応をいただけました。

また，Elixir Wizards と Elixir Outlaws のジョイントイベントで，短い時間ですが，会期中にリリースした Pelemay 0.0.6 について発表しました。話題の中心だった機械学習の文脈で，トークの最後の方で Justus が私に声をかけてくれたのでした。

[![スクリーンショット 2020-03-17 5.01.24.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/15be0217-02a4-acac-50da-03154c026e5b.png)](https://podcast.smartlogic.io/s3-bonus-outlaws-and-wizards)

[![スクリーンショット 2020-03-17 5.03.58.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/128dc98e-c4b9-db31-5765-729ae4a4ee00.png)](https://elixiroutlaws.com/67)

そういうわけで，交流という点ではとても大きな成果を得られたのですが，Lonestar Elixir 2020 の講演内容については，実はほとんど理解できませんでした。というのは，次のような事情があったからです。

* 深刻な時差ボケ(jet lag)に悩まされていて，講演中，終始眠たくてまるで集中できなかった。
* プレゼンテーションのほぼ全てが，スライドに1枚写真もしくは簡潔で抽象的な短文だけで構成され，1枚のスライドにつき2〜3分くらい早口でしゃべるというスタイルだったので，とても辛かった。
* 私の他に日本人の参加者がいなかったので，「あの話なんだった？」と聞ける相手がいなかった。

また，ネイティブ同士によるグループディスカッションがまるでついていけなかったという痛い思いをしたということもあります。

まさに，reading >> writing > speaking >>>>>> listening という現在の4技能バランスを反映した現実を突きつけられたということでした。

# 2020年3月現在の取り組み

現在では，次のような取り組みを始めています。

* ElixirConf JP で，海外対応を買って出る。
* Elixir Wizards や Elixir Outlaws の特に興味あるトピックを購読し，車を運転している間は聴き続ける。聞き取れたものについてはシャドーイングもする。
* ElixirConf JP と自分自身の Twitter アカウント，Elixir 関連 Slackを運用する際に，英語での Elixir の情報やアメリカで出会った友達を日本語で紹介したり，ElixirConf JP や日本での Elixir の取り組みなどを英語で紹介したりする。
* 英語文章を速読する。
* Nerves Meetup という Zoom イベントに参加する。
* iPhone や Mac，アプリなどを英語設定にする。

今のところ，楽しく続けられています。
