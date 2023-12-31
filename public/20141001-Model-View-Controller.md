---
title: Model-View-Controller　
tags:
  - Objective-C
  - iPhone
  - Xcode
  - uml
  - oop
private: true
updated_at: '2014-10-09T09:32:42+09:00'
id: 23af9b1e8f8b9e026b22
organization_url_name: null
slide: false
ignorePublish: false
---

## はじめに
90年代に入って **ソフトウェア・アーキテクチャ (software architecture)** という概念が急速に広がりました。21世紀に入るとさらに広がりを見せ，あらゆるソフトウェアの分野で重要視されるようになってきています。

このセクションでは， ソフトウェア・アーキテクチャの概念と， GUI を用いたアプリケーションで広く使われているソフトウェア・アーキテクチャである， **Model-View-Controller (MVC) アーキテクチャ** を紹介します。

## ソフトウェア・アーキテクチャとは
ずいぶん昔からしばしばコンピュータやソフトウェア，とくにソフトウェア開発は建築に例えられていました。アーキテクチャ (architecture) という言葉は，その代表例の1つです。もともとアーキテクチャは建築様式という意味でした。たとえば欧州のゴシック様式やギリシャ様式などはアーキテクチャの例です。 主に基本的な構造や，設計や装飾の方法をさす言葉です。

ソフトウェアにおいてもソフトウェア・アーキテクチャという概念があります。これもアプリケーションの全体の構成や，それに付随する設計・プログラミングの方法・ルールを定めたものだとされています。

ソフトウェア・アーキテクチャは全体の構成に関わる事から分かる通り，ソフトウェア開発全体に影響を及ぼします。したがって立場の異なる多様な技術者がソフトウェア・アーキテクチャに関わることになります。

立場が異なる多様な技術者が関わるため，ソフトウェア・アーキテクチャの定義は，なんと100通り以上！あります。興味のある人は *SEI architecture definition* で検索してください (英文)。SEI とは，カーネギーメロン大学の Software Engineering Institute (ソフトウェア工学研究所) のことで，ソフトウェア・アーキテクチャの研究の総本山の1つです。

なお， LSI の分野ではコンピューター・アーキテクチャという似たような名前の概念があります。これは主にプロセッサの LSI 設計や，それに付随する周辺 LSI の構成などを指します。

これ以降の説明では，ソフトウェア・アーキテクチャを単にアーキテクチャと呼びます。

## Model-View-Controller アーキテクチャ
### MVC アーキテクチャの動機
Microsoft Office の１つであるエクセル (Excel) のような表計算ソフトウェアを想像してください (知らない人は，演習室の PC で OpenOffice の Calc を使ってみてください)。下図は Apple の Macintosh や iPad で使われる表計算ソフトウェア，Numbers のスクリーンショットです。

![screenshot-Numbers.png](https://qiita-image-store.s3.amazonaws.com/0/55223/f82146bb-6d7a-11bc-dc4d-224a5c0c8f8f.png "screenshot-Numbers.png")


ユーザーが左側の表に記入すると，その集計結果が右上の表にまとめられ，さらにそれを右下の円グラフと棒グラフの形で表示されます。

このように表計算ソフトウェアでは，1つのデータとしての表を，複数の集計結果や複数種類のグラフに表示することができます。そして表やグラフのどれかを編集すると，瞬時に関連する他の表やグラフを更新します。

このようなアプリケーションをつくるために Model-View-Controller (MVC) アーキテクチャが考案されました。

### MVCアーキテクチャの定義
MVC アーキテクチャは GUI を用いるソフトウェアを開発するためのアーキテクチャです。構成要素である Model, View, Controller は次のようなものです。

* **モデル (model):**  データの実体を保持します。 モデルはデータの保持や計算を行うだけで， GUI とは基本的にまったく関わりを持ちません。
* **ビュー(view):**　モデルをGUIの画面に表示するための仕組みです。1つのモデルに1つ以上のビューを割り当てることができます。モデルに変更があると瞬時にビューを更新します。
* **コントローラー(controller):** ビューとモデルの仲介をします。具体的にはビューからの指示を受け取ってモデルに伝えたり，モデルの変更をビューに伝えたりします。

モデルとビューは性質が異なります。モデルは抽象的な概念上の世界で，ビューは目に見える具体的な世界です。コントローラーはモデルとビューの橋渡しです。

### MVCアーキテクチャの利点
MVC アーキテクチャには多くの利点があります。

* たとえばプログラマーなどがモデルを担当し，工業デザイナーがビューとコントローラーを担当するといった， **効果的な分業** が可能になります。
* モデル・ビュー・コントローラーのそれぞれに特化したツールの活用ができます。
* 部品ごとの依存関係や変更の影響を抑制できます。

### MVC アーキテクチャを用いた開発方法
利点にも挙げましたが，MVC アーキテクチャを採用すると効果的な分業とツールの活用が可能になります。これについてもう少し詳しく見ていきましょう。

まずビューは GUI の見た目だけを扱います。したがって GUI 作成ツールが用意されていれば，それを用いて開発することができます。しかもプログラミングすることなく WYSIWYG (What You See is What You Get: 見たままのとおりに作成できること) で開発することが可能です。そのため，プログラマーではなく工業デザイナー (industrial designer) がビューを担当できます。

工業デザイナーは，工業製品の意匠(デザイン:design)つまり見た目を担当する専門家のことです。ただし，UMLなどのソフトウェアの設計を担当する人(ソフトウェア設計者)のことも，英語では　software designer と呼ぶので，ここでは区別するために工業デザイナーと呼んでいます。工業デザイナーの仕事は主に設計図を書くことで，最近は CAD (computer-aided design) ツールを用いて設計図を書きます。GUI 作成ツールは CAD を模して作られており，あたかも図面を書くように GUI を作成することができます。

一方，モデルは抽象的な概念を扱います。モデルは純粋に計算の世界でもあります。現在の一般的な統合開発環境では，プログラミングによってモデルを作成することが多いです。したがってこの場合には主にプログラマーがモデルの開発作業を担当することになります。

最後のコントローラーは，モデルとビューの橋渡しです。GUI作成ツールの中に，それぞれのビューの GUI 部品が操作されると，対応するモデルのどのメソッドを呼ぶことにするかを設定する機能が存在することが多いです。実際のコントローラーの開発ではこの機能を用い，モデルに記述されたコントローラーを代表する部品に指令を集約させるように開発します。

### MVCアーキテクチャの漫画での解説
世の中には MVC アーキテクチャを漫画で解説した人がいます。興味ある人は調べてみてください。

### MVCアーキテクチャの歌
世の中には MVC アーキテクチャを歌った人がいます。MVC song で検索してみてください。

### MVCアーキテクチャの解釈

MVC アーキテクチャにおいて，モデル／ビュー／コントローラーが具体的にどのようなものを指すのかについて，様々な理由で論者によって厳密な解釈が異なります。このテキストでは初心者向けであるということで，とても大づかみに捉える立場を取っています。解釈の違いについて興味のある人は，ある程度学習が進んだ後で調べてみてください。 


## まとめ
このセクションでは，次の項目について学習しました。

* ソフトウェア・アーキテクチャがどんなものかを知りました。
* MVC アーキテクチャがどんなものかを知りました。

## 演習問題

### Q002-2-1　
次の記述の空欄を埋めてください。
ソフトウェア・アーキテクチャはアプリケーションの(a　　　　　)や，それに付随する　(b 　　　)・プログラミングの(c　　　)・(d　　　　)を定めたものだとされています。
MVC はそれぞれ (e　　　　) (f　　　　　) (g　　　　　)の略です。

## 目次

1. [OOP演習の意義と目標](http://qiita.com/zacky1972/private/193e194cae1fe28b8dc2)
2. [はじめての iPhone アプリ開発](http://qiita.com/zacky1972/private/51765b58b7843758e85c)
	1. [Model-View-Controller](http://qiita.com/zacky1972/private/23af9b1e8f8b9e026b22)
	2. [Xcodeを使ってみよう](http://qiita.com/zacky1972/private/8c7b732e3505d4313e6c)
	3. [ビューの作成](http://qiita.com/zacky1972/private/d23a0c06d5c967fc225f)
	4. [コントローラーの作成](http://qiita.com/zacky1972/private/1a87638b8ac389fc5e29)
	5. [コントローラーからビューへの操作](http://qiita.com/zacky1972/private/7eb1a401fb459aa0078a)
	6. 状態機械モデルの作成
		1. [状態機械モデルの作成(1/2)](http://qiita.com/zacky1972/private/0413c332b1950284c889)
		2. [状態機械モデルの作成(2/2)](http://qiita.com/zacky1972/private/252050ecb1613ae845d2)
	7. ソフトウェアの動作，プログラミングとUMLモデリング
		1. [ソフトウェアの動作，プログラミングとUMLモデリング(1/4)](http://qiita.com/zacky1972/private/b9d474bba26f2a5ef87f)
		2. [ソフトウェアの動作，プログラミングとUMLモデリング(2/4)](http://qiita.com/zacky1972/private/a401b36612ea44a65192)
		3. [ソフトウェアの動作，プログラミングとUMLモデリング(3/4)](http://qiita.com/zacky1972/private/143296989fd8836d5f71)
		4. [ソフトウェアの動作，プログラミングとUMLモデリング(4/4)](http://qiita.com/zacky1972/private/f24bad0fba40129342e0)
	8. [状態機械モデルとコントローラーの分離](http://qiita.com/zacky1972/private/1986b8c3aec9d1356d83)
3. 電卓の開発
	1. 電卓のモデリング
		1. [電卓のモデリング(1/8)](http://qiita.com/zacky1972/private/aa39be058c86ea8a2373)
		2. [電卓のモデリング(2/8)](http://qiita.com/zacky1972/private/4c4560214c1cc2d40ae5)
		3. [電卓のモデリング(3/8)](http://qiita.com/zacky1972/private/a01c6023415935a4b6b4)
		4. [電卓のモデリング(4/8)](http://qiita.com/zacky1972/private/833d4a81695db93404db)
		5. [電卓のモデリング(5/8)](http://qiita.com/zacky1972/private/f55ba97d5de5576d39dc)
		6. [電卓のモデリング(6/8)](http://qiita.com/zacky1972/private/744e7939458de50b50fa)
		7. [電卓のモデリング(7/8)](http://qiita.com/zacky1972/private/c1ad11537201cfbadc64)
		8. [電卓のモデリング(8/8)](http://qiita.com/zacky1972/private/375479a7f4c02ebfb9e9)
	2. 電卓のプログラミング
