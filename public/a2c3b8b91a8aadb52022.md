---
title: TechConfにて英語で発表しよう〜ElixirConf US/EUを題材に〜その2 Talk Descriptionの書き方
tags:
  - Elixir
  - 英語
  - Conference
private: false
updated_at: '2022-12-11T09:09:37+09:00'
id: a2c3b8b91a8aadb52022
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
技術についてある程度自信を持ってきたら，次に積極的に情報発信をしていくことと思います．この記事は，その1つの手段として，いわゆるTechConf(テック・カンフ)，すなわち技術系の国際会議で発表・登壇する方法について紹介するシリーズの第2弾です．

シリーズ
* [TechConfにて英語で発表しよう〜ElixirConf US/EUを題材に〜その1 すごい技術を発明しないとElixirConfで発表できないのか？](https://qiita.com/zacky1972/items/62c427ea4e06e9489f17)
* [TechConfにて英語で発表しよう〜ElixirConf US/EUを題材に〜その3 Bio(自己紹介文)の書き方](https://qiita.com/zacky1972/items/6212a4c227ae7df9bc24)

この記事のシリーズではElixirConfについて説明しますが，他のTechConfにも通じる内容が多く含まれているのではないかと思います．この記事をきっかけにして，より多くの日本の方々が，もちろん，それだけに限定するつもりもないのですが．TechConfで発表することになると良いなと考えています．

# 投稿の要(かなめ)となるTalk Descriptionを書こう

Talk Descriptionは，講演概要という日本語訳になると思います．この文章に訴求力を持たせることが，採否の，そして当日の集客の要(かなめ)となります．

Talk Descriptionでは， **主語をI(私)にはしません．** I(私)を主語にした主観的な主張を書くのではなく，**普通の名詞を主語にした客観的な事実を書く**もしくは**読者・聴講者であるYouを主語にします．** つまり，記述の目線があくまで読者・聴講者の視点なのです．

背景を書くときには，みんなが納得する客観的事実や，聴衆への呼びかけで始めて，そこから提案手法の必然性を導き出すのが一般的です．

例として，私がElixirConf US 2022で投稿して採択されたTalk Descriptionを提示します．　

https://2022.elixirconf.com/speakers/susumu-yamazaki#s

> What do you use when you process enormous images? Of course, Python, Numpy, and OpenCV will be helpful for it, but don't you want to speed it up by processing it in a distributed and parallel way? Elixir can do it:
> 
> 1. You can replace Numpy and OpenCV with Nx and evision.
> 2. Node and Flow can make the processing distributed and parallel.
> 3. Supervisor makes it robust for crushing due to consuming much memory. 
> 
> This presentation will introduce satellite image processing for an information provision system of sediment disasters as an example case study shown at ElixirConf US 2020.

> 膨大な画像を処理するときに何を用いますか？ もちろん，Python, NumPy, OpenCVが助けになるでしょう．しかし，分散・並列処理して高速化したいと思いませんか？ Elixirならできます:
> 
> 1. NumPyとOpenCVをNxとevisionに置き換えることができます
> 2. NodeとFlowによって分散・並列処理できます
> 3. Supervisorによってメモリを大量に消費するためにクラッシュせずに堅牢にすることができます
>
> この発表ではElixirConf US 2020で示した例題である土砂災害情報提供システム向けの衛星画像処理を紹介します．

このTalk Descriptionは，最初に読者・聴講者への問いかけで始まっています．従来の一般的な方法を示した上で，もっと良い方法を知りたくないかを再度問いかけます．そしてソリューションとして「Elixirならできます」と決め台詞を述べた後で，3つのポイントを示します．

どうでしょう？ もし膨大な画像処理をしたい人ならば，そしてそれを高速化したいと思っているような人ならば，このようなTalk Descriptionに興味を示すと思いませんか？

# ElixirConf US 2022からTalk Descriptionをいくつか例示します

https://2022.elixirconf.com

## Let's talk to Industrial devices with Elixir & Nerves by Aldebaran Alonso

https://2022.elixirconf.com/speakers/aldebaran-alonso#s

> A look inside a common problem for startups when developing products focused on industrial environment: how to interact with industrial devices.
> 
> First, we will discuss the problem along with a brief introduction to industrial communication protocols, covering their importance and features. Then, we will talk about our experience and workflow for adopting such industrial protocols in Elixir, focusing particularly on Modbus TCP and OPC UA with a demo. Finally, we will cover the state of the art of open source projects that support several Industrial protocols, as well as future work.

> スタートアップ企業が産業環境に焦点を当てた製品を開発する際によくある問題の内部を見てみましょう: 産業用デバイスとどのようにやり取りするか。
> 
> 最初に、産業用通信プロトコルの重要性と機能について簡単に紹介するとともに、この問題について説明します。 次に、Elixir でこのような産業用プロトコルを採用するための経験とワークフローについて、特に Modbus TCP と OPC UA に焦点を当ててデモで説明します。 最後に、いくつかの産業用プロトコルをサポートする最新のオープン ソース プロジェクトと、今後の作業について説明します。

## WebAuthn + LiveView by Owen Bickford

https://2022.elixirconf.com/speakers/owen-bickford#s

> As I build my side project, a collaborative music application called LiveShowy, I want to avoid the development and customer support headaches of password management. I also want the app to run over Websockets as much as possible using LiveView.
> 
> The WebAuthn API provides Javascript functions for prompting users for biometric or physical key credentials. In the Elixir ecosystem, there are a few WebAuthn libraries, but none designed or documented for use in LiveViews. Phoenix LiveView provides JS hooks, which greatly simplify interactions with browser APIs.
> 
> In my talk, I will make the case for using WebAuthn when possible for improved security, telling the tale of how I implemented the API over Websockets with the Wax package from Hex. Leading up to the talk, I plan to review the implementation with experts with the intent to publish an open source package for LiveView applications at ElixirConf.

> サイド プロジェクトである LiveShowy と呼ばれる共同音楽アプリケーションを作成するとき、パスワード管理の開発とカスタマー サポートの頭痛の種を避けたいと考えています。 また、LiveView を使用して、可能な限り Websocket 上でアプリを実行したいと考えています。
> 
> WebAuthn API は、生体認証または物理キーの資格情報をユーザーに求めるための Javascript 関数を提供します。 Elixir エコシステムには、いくつかの WebAuthn ライブラリがありますが、LiveView で使用するために設計または文書化されたものはありません。 Phoenix LiveView は、ブラウザ API とのやり取りを大幅に簡素化する JS フックを提供します。
> 
> 私の講演では、可能な場合はセキュリティを向上させるために WebAuthn を使用することを主張し、Hex の Wax パッケージを使用して Websockets を介して API を実装した方法について説明します。 講演に先立ち、ElixirConf で LiveView アプリケーションのオープン ソース パッケージを公開する目的で、専門家と共に実装をレビューする予定です。

## Learn you some pattern matching for great good!  by Elayne Juten

https://2022.elixirconf.com/speakers/elayne-juten#s

> Move '`if`' to the bottom of your toolbox. Have you ever looked at a function with numerous conditionals buried within and thought, “there has to be a better way”? Well, there is! It’s pattern matching!
> 
> This talk will focus on the basics of pattern matching, both how it works and why we might want to use it to simplify our code structure.
> 
> First, we will walk through an example of a simple pattern match and take a look at how these concepts can be applied in a larger codebase.
> 
> Then we will refactor by taking a look at a function that utilizes multiple conditionals and walk through how to implement pattern matching in a step-by-step process. We’ll also discuss why refactoring to pattern matching can improve codebases.
> 
> Lastly, we’ll discuss the pros and cons of utilizing pattern matching in different situations you might see in a large codebase. By the end of this talk, you’ll have added pattern matching to your toolbox to wield with confidence.

> 「if」をツールボックスの一番下に移動します。 多数の条件文が埋め込まれた関数を見て、「もっと良い方法があるはずだ」と思ったことはありませんか? あります！ パターン・マッチングです！
> 
> この講演では、パターン・マッチングの基本に焦点を当て、パターン・マッチングのしくみと、コード構造を単純化するためにパターン・マッチングを使用する理由の両方について説明します。
> 
> 最初に、単純なパターン・マッチの例について説明し、これらの概念をより大きなコードベースに適用する方法を見ていきます。
> 
> 次に、複数の条件を利用する関数を見てリファクタリングし、段階的なプロセスでパターン・マッチングを実装する方法を説明します。 また、パターン・マッチングへのリファクタリングがコードベースを改善できる理由についても説明します。
> 
> 最後に、大規模なコードベースで見られるさまざまな状況でパターン・マッチングを利用することの長所と短所について説明します。 この講演の終わりまでに、ツールボックスにパターン・マッチングを追加して、自信を持って使用できるようになります。

