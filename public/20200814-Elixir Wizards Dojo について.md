---
title: Elixir Wizards Dojo について
tags:
  - Elixir
  - 英語
  - IoT
  - Nerves
private: false
updated_at: '2021-11-21T10:42:11+09:00'
id: 82eeef7606083c8a7446
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
最近私が精力的に活動したElixir Wizards Dojoの企画と翻訳・監訳のご紹介です。

[ElixirConf](https://2020.elixirconf.com)の名物司会者，[Justus Eapen](https://twitter.com/justuseapen)がメインホストを務める[SmartLogic](https://smartlogic.io)提供の[人気Podcast，Elixir Wizards](https://smartlogic.io/podcast/elixir-wizards/)と，私たち[ElixirConf JP](https://twitter.com/elixirconfjp)のコラボレーション企画，それがElixir Wizards Dojoです。

ゲストでお招きするElixir Wizardsたちに，あらかじめ集めた日本だけでなく世界中の「弟子たち」からの質問に答えてもらうという，まさに道場のような形式を企画提案しました。さらにPodcastのTranscript(テキスト)をElixirConf JPメンバーが日本語に翻訳します。

リンク先の番組紹介と，Transcript: Japanese をご覧ください。日本語で番組内容が紹介されています。

* [Elixir Wizards Dojo Nerves Part 1](https://smartlogic.io/podcast/elixir-wizards/s4e13a-dojo/)
    * [Transcript: Japanese - Elixir Wizards Dojo Nerves Part 1](https://smartlogic.io/podcast/elixir-wizards/transcripts/s4e13a_dojo_nerves_JP.txt)
* [Elixir Wizards Dojo Nerves Part 2](https://smartlogic.io/podcast/elixir-wizards/s4e13b-dojo/)
    * [Transcript: Japanese - Elixir Wizards Dojo Nerves Part 2](https://smartlogic.io/podcast/elixir-wizards/transcripts/s4e13b_dojo_nerves_JP.txt)

最初のゲストは，昨年ElixirConf JPのkeynoteでご紹介したNervesをテーマに，JustinとFrank，次回がConnorとToddです。Nervesのディープなところまで語り尽くします。

頑張って翻訳したので，是非見て，聴いてください！

# Show Notes - Japanese Elixir Wizards Dojo 第一部 Frank Hunleth と Justin Schneck

## Episode S4E13a: 概要

Elixir Wizards Dojo スペシャル番組の第一部にようこそ。ElixirConf JPとのパートナーシップによるマッシュアップです。今日のエピソードでは、日本のNervesコミュニティからの質問をNervesコアチームのメンバーであるFrank Hunleth と Justin Schneck に尋ねます。ゲストの2人を紹介した後、Nervesを使用する会社のことや、ファームボット(オープンソースのロボティック農業ツール)に見る使用事例を探ります。JustinとFrankが交互にソフトリアルタイムとハードリアルタイムの違いを説明し、Nervesが「複雑さの中立的立場」、生産指向のニッチという点で優れていることを示します。ハロウィンのいたずらから、オフィスで育つ四川の唐辛子栽培まで、JustinとFrankはNervesを使用して構築したプロジェクトを紹介し、その幅広い応用性を強調します。Nervesが公式・非公式にさまざまなデバイスに移植された方法についてや、なぜみんながFrankにランダムなハードウェアを郵送するのか、オープンソースと単に作品を公開することの違いについて話し合います。JustinとFrankはBluetoothの機能開発の課題に同情し、イノベーションを推進する上でのNervesコミュニティの美点について語ります。さらにNervesについて話が進み、どのようにファイルシステムの機能性を拡張するのかや、JustinとFrankがNervesの将来のロードマップについて披露します。どのような開発サイクルにも「アジャイルに」できるシステムである、Nerves プロジェクトについてより詳しく知りたいという人は、是非聴いてください。

## このエピソードのみどころ

* ゲストの紹介と、日本のElixirコミュニティに対するこのエピソードの焦点
* Elixirプロジェクトについての興奮を広める上での「両刃」
* ファームボットに見るNervesが実現できる実事例
* ファームボットを例にした、ソフトリアルタイムとハードリアルタイムの違い
* Nervesの何が優れているのか: 他のプロセッサへのゲートウェイの役割
* JustinとFrankが共有する、Nervesで今まで構築してきたプロジェクトの数々
* Justinが愛する四川料理についての軽い脱線
* Nervesを製品サイクルに応用する他のマーケットや事例=
* Nervesが扱うのに手ごろな複雑さの独特の「中間基盤」 
* Nervesの異なるデバイスへの移植とNervesを実行させるのにどんなデバイスが必要
* オープンソースと作品を公開することの違いと、どのようにJustinがBluetoothでの仕事の一部を公開したか
* Bluetoothの開発作業のチャレンジ
* コミュニティのグループがどのようにNervesキーボードを作っているか 
* どのようにNervesのファイルシステムの機能性を拡張するか
* 本番環境で優れたツールとなる上でのNervesの機能

Special Guests: Frank Hunleth and Justin Schneck.

# Show Notes - Japanese Elixir Wizards Dojo 第2部 Connor Rigby と Todd Resudek

## Episode S4E13b: 概要

Elixir Wizards Dojo スペシャル番組の第二部にようこそ。ElixirConf JPとのパートナーシップによるマッシュアップです。今日のエピソードでは、NervesコアチームのメンバーであるTodd Resudek と Connor Rigby とNervesの全てについて話します。でも最初に、Toddは私たちをヘビーメタル音楽の彼の楽しみについての楽しい余談に導きます。メタルからNervesに戻って、ToddはNervesをインターネット接続のモニタリングと、特定の条件が満たされた時にルーターの自動で再起動する方法について話します。FlutterとDartを使ってGUIを構築する方法について話したあと、Toddに彼の作ったもう一つのNervesプロジェクト、スプリンクラーの未来，Drizzle 2000！についてシェアしてもらいます。そしてConnorがNervesチームにおける自ら定義した役割である、ネットワーキングライブラリの開発について探求し、もしElixirユーザーである場合にNervesを使うことがいかに簡単かについて議論します。ToddとConnorはNervesの未来の理想郷についての話題と、Nervesが提供するツールに敵うIoTソリューションが他に存在しない理由について飛び込みます。ファームボットについて話をして、雑草をやっつける機能を含む、ファームボットのモデルが持つたくさんの機能について話します。これは、農業分野でのIoT技術の重要性の高まりへの転換と、どのように次の10億ドル規模の産業になる可能性が高まってくるかについてを示しています。エピソードの締めくくりは、ゲストに自分自身とつながる方法について紹介してもらいながら、アイアンメイデン(Iron Maiden)とメタリカ(Metallica)のファーストアルバムをリスナーに紹介します。Elixir Wizards Dojoの初回への謝辞から、Nervesプロジェクトの詳細を学んでください。

## このエピソードのみどころ

* ゲストの紹介と、このエピソードとElixirConf JPとのコネクションについて
* Connor と Todd によるヘビーメタル音楽の歴史とサブジャンルへの案内
* ToddのNervesを使ったインターネット接続のモニタリングとルーターの再起動
* Flutter という Google の UI ツールキットを使った Nerves プロジェクトのユーザインタフェース構築
* GUIアプリに焦点を当てたときのアプリ開発のベストプラクティス
* Drizzle 2000について聴ける！ Nervesで動くToddのスプリンクラーコントローラシステム
* ToddとConnorのNervesコアチームにおけるそれぞれの役割
* Nervesを使う利点: 一度起動すると通常のElixirアプリになる
* キオスク端末とは何か，どのようにキオスク端末を国際化するか
* Nervesとハードウェア開発の将来の探求
* Nervesと他のIoTソリューションの比較: 結論としては，Nervesに敵うものはない
* ファームボットシステムのモデルの違いについて: 全てにNervesが使われていて、食糧を育てる
* Nervesを使ってビデオをエンコードしたり録画したり，ライブストリーミングしたりする方法
* IoTを農業分野に統合することが次の10億ドル産業になる理由

Special Guests: Connor Rigby and Todd Resudek.

# 翻訳チーム

* MasaTam
* piacere
* zacky1972
* emadurandal
* im
* kikuyuta
* torifukukaiou
* pojiro
* ishigaki

(敬称略，チームSlackでの表示名，表示順)
