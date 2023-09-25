---
title: オープンソースソフトウェア(OSS)へのIssueの書き方〜Elixirの例を題材に
tags:
  - Elixir
  - issue
  - OSS
private: false
updated_at: '2022-12-13T10:20:10+09:00'
id: 6dc0485884d24263df97
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事では，オープンソースソフトウェア(OSS)への貢献のしかたの1つとして，Issueの書き方を説明します．たとえばOSSに対して，バグを報告する，新機能を提案するというような時にIssueを書きます．特にOSSでバグを報告する場合について書いてみたいと思います．

# Issueとはどのようなものか

Issueを直訳すると「問題」というような意味になります．ソフトウェアにおけるIssueには，バグや新機能の提案などを含みます．

GitHubにはIssueを報告する機能があります．たとえばElixirには次のURLでアクセスできます．

https://github.com/elixir-lang/elixir/issues

OpenなIssueは，未解決の問題を表しています．ClosedなIssueは，解決済みの問題を表しています．

たいていのOSSでは，Issueは英語で書かれていると思います．臆してしまうかもしれませんが，現代ではGoogle翻訳やDeepLなどの機械翻訳が発達していますし，Issueを書く場合には後述するような「定型的な書き方」というものがありますので，慣れれば割と簡単に書くことができると思います．

多くのOSS開発者にとって，Issueを書いてもらうことはとてもありがたいことです！なぜならば，自分の視点や開発環境だけでは気づかなかった自分のOSSの問題点に気づくことができるからです．それによって，より良いOSSに仕上げる機会を得ることができます．

# 最初に注意: 脆弱性を報告する場合

もし脆弱性を報告する場合には注意が必要です．なぜならば，脆弱性の報告を公開された場で報告すると，それを悪用して攻撃されてしまう場合があるからです．

メジャーなOSSでは，脆弱性の報告については非公開の方法で報告する手段が用意されていることが多いです．たとえば，[Elixirでは，Security Policyの掲示がされています．](https://github.com/elixir-lang/elixir/security/policy) https://github.com/elixir-lang/elixir/security/policy これを読むと，脆弱性については次のように報告すると書かれています．

> ## Reporting a vulnerability
> Please disclose security vulnerabilities privately at elixir-security@googlegroups.com

> ## 脆弱性の報告
> セキュリティの脆弱性については，elixir-security@googlegroups.com 宛に非公開で報告してください

# 最新版を試すこと

OSSを使っていてIssueを見つけた時に，まずそのOSSが最新版の場合でもIssueが起こるのかを確認します．最新版だとそのIssueは既に解決済みであることがあります．

Elixirの場合には，開発者のJosé Valim(ジョゼ・ヴァリム)が，バージョン1.10以降は破壊的更新をしないという宣言をしています．したがって，最新版を常時使っていても大きな問題になることが滅多にないです．ただしPhoenixやNervesなどが最新版に追従していないことがあるので，その時には少し古いバージョンを使うことはあります．しかし，Elixirコミュニティの文化として，できるだけ最新のElixirを使うように各OSS開発者が心掛けているので，最新版を尊重するような文化に馴染みましょう．

# 過去に報告されたIssueの中に同じものがないかを確認すること

では最新版の場合でもIssueが起こったとします．その時には，同じIssueがすでに報告されていることもあるので，それを確認します．

特徴的なエラーメッセージや関連するモジュールや関数の名称などでIssueを検索すると見つかるかもしれません．OpenなIssueとClosedなIssueの両方探しましょう．

もしClosedなIssueの中に，自分が直面したIssueと同じものがあれば，そこに書かれている解決方法を試しましょう．大抵の場合はそれで解決に至ると思います．もし解決しなかった場合には，そのIssueのコメントに，自分自身の環境を提示した上で，問題がなお解決していないことを報告すると良いでしょう．環境の提示の仕方については後述します．

もしOpenなIssueの中に，自分が直面したIssueと同じものがある場合には，そのIssueにsubscribeすると良いです．すると，そのIssueに更新があった場合に通知がきます．一通り読んでみて，自分自身の環境と同じような環境について報告されていないようならば，自分自身の環境でも問題が起こることをコメントで報告するのも良い手です．

# Issueを書く場合

もし最新版でもIssueが起こり，かつ今までに報告されていないIssueであると認識した場合には，勇気を持ってIssueを書きましょう！ New Issueボタンを押します．

## Issueテンプレートが用意されている場合

例えばElixirの場合には，次のような画面になります．このような場合はIssueテンプレートが用意されている場合です．

![Issueテンプレートがある場合〜Elixirのケース](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/11c2b6e7-d74e-ce0a-afd0-ae28e04d129d.png)

こういう場合には，テンプレートの説明に沿って，必要事項を埋めていきます．例えば，最初の項目では，`elixir --version`の実行結果を添付することで，ElixirとErlang/OTPのバージョンを報告します．

## Issueテンプレートが用意されていない場合

たとえばNxの場合には，次のような画面になります．このような場合はIssueテンプレートが用意されていない場合です．

![Issueテンプレートがない場合〜Nxのケース](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/8476c425-0a01-3687-5adb-104468980243.png)

こういう場合には，次のように報告すると良いです．

1. どのようなIssueなのかの概要を示す
1. どのような手順でIssueが再現するのかを示す
1. 実行した環境がどのようなものなのかを示す
1. もし補足情報があれば示す

基本的にはこれらを示せば，Issueレポートとしての要件を満たせます．では，過去に私がレポートしたIssueからそれぞれの例を見ていこうと思います．

## 例1: Elixir Desktop での例

https://github.com/elixir-desktop/ios-example-app/issues/9

この例では，次のような構成で報告しています．

> My environment is:
> 
> M2 Macbook Air
> macOS 12.6
> Xcode 14.0
> iOS 16.0

ここでは実行した環境を提示していました．

> I did the following steps:
> 
> 1. I built Erlang/OTP 25.0.4 with export DED_LDFLAGS_CONFTEST="-bundle" with asdf
> 2. `git clone https://github.com/elixir-desktop/ios-example-app.git`
> 3. `cd ios-example-app`
> 4. `carthage update --platform ios --use-xcframeworks --no-use-binaries --new-resolver` (According to this issue: Carthage gets stuck on carthage update Carthage/Carthage#2615)
> 5. `open todoapp.xcodeproj`
> 6. Fix an issue of Bundle Identifier
> 7. Connect my iPhone (iOS 16.0) and set the target to it
> 8. Build

このようにIssueが再現する手順を示しました．

> But, I got the error: `error build: Command PhaseScriptExecution failed with a nonzero exit code.`

このように表示されたエラーメッセージを示しました．

> I found the issue #3, but I feel my issue may be different to it.

補足情報として，似たようなIssueが他にあったが，それとは異なるように感じた旨を記載しました．

以上を簡潔に表すタイトルとして，次のようなタイトルをつけました．

> Fail to build on macOS 12.6, Xcode 14.0 and iOS 16.0

このように，報告自体はそれほど難しくはないです．

# Issueで大事なポイント: できるだけ最小限の，確実に再現する手順を示す

実はIssueをレポートする上で，早い解決につながるとても重要なコツは，**できるだけ最小限の，確実に再現する手順を示す**ことです．

OSSを使ってシステム開発をしている状況で何かのバグに遭遇した場合，ものすごく膨大な手順を経てバグが起こるというような状況になります．これをそのまま報告しようとすると，今までシステム開発してきたソースコードを開示する必要が出てきますし，何より本質的でない情報がたくさん含まれているので，問題の解決に時間がかかります．

そこで，私がOSSを使ってシステム開発をする多くの場合，本格的に導入する前に，そのOSSで使いたい機能を一通り試すような小さなプロジェクトを作って評価します．そしてこの試行プロジェクトを原則公開します．こうすると，できるだけ最小限の，確実に再現する手順を示しやすくなります．

技術的には，このポイントを押さえた報告ができるかどうかが，とても重要で，早期の問題解決の成否を分けます．

# 他の事例

これは，"Nice catch"と褒められたIssueです．ElixirのIssueテンプレートに沿った報告の例です．

https://github.com/elixir-lang/elixir/issues/12072

こういう例もあります．ここではURLの微妙な違いに気づいて，合わせて報告しています．

https://github.com/cocoa-xu/evision/issues/70

# まとめ

オープンソースソフトウェア(OSS)への重要な貢献の1つとして，Issueレポートがあります．

脆弱性を報告する場合には，非公開の報告ルートが用意されていることが多いので，それに従います．Issueを見つけた時に，最新版を試して再現することを確認し，過去に報告されたIssueの中に同じものがないかを確認したら，勇気を持ってNew Issueボタンを押します．

Issueテンプレートが用意されている場合にはそれにしたがって報告します．用意されていない場合には，どのようなIssueなのかの概要を示し，どのような手順でIssueが再現するのかを示し，実行した環境を示し，もし補足情報があれば示します．

Issueで大事なポイントは，できるだけ最小限の，確実に再現する手順を示すことです．OSSを使ってシステム開発をする場合に，そのOSSで使いたい機能を一通り試すような小さなプロジェクトを作って公開する習慣を身につけると，このような手順を見出しやすくなり，早期の問題解決につながります．

20221213 追記: 関連記事を紹介します．コメントのやり取りをしました．[初めてIssueをあげてみた](https://qiita.com/shihou-ono/items/88d9ebfa91291482f2e4)
