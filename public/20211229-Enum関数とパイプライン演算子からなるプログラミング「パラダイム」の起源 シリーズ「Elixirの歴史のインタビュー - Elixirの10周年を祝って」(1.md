---
title: >-
  Enum関数とパイプライン演算子からなるプログラミング「パラダイム」の起源: シリーズ「Elixirの歴史のインタビュー -
  Elixirの10周年を祝って」(1)
tags:
  - Elixir
private: false
updated_at: '2022-12-18T20:24:21+09:00'
id: 2dc7c4930f6ab8a4688a
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
インタビューを受ける人: José Valim (ジョゼ・ヴァリム), Elixirの作者, DashbitのChief Adoption Officer
インタビュワー: 山崎 進, 北九州市立大学 准教授, ElixirConf JPのオーガナイザー

原文: [The Origin of the Programming "Paradigm" by the Combination of Enum Functions and Pipeline Operators](https://dev.to/zacky1972/the-origin-of-the-programming-paradigm-come-from-the-combination-of-enum-functions-and-pipeline-operators-4mc6)

# José Valim に投げかけた質問【2021年12月17日】

Joséへ

森 正和（ElixirConf US 2021[^1]でプレゼンテーションしました @piacerex、ElixirConf JPオーガナイザーでもあります）と私は、北九州市立大学で「プログラミング論」のコースを講義しています。これには，命令型プログラミング・OOP・関数型プログラミングなどの主流のプログラミングパラダイムが含まれ，コンピュータシステムのアーキテクチャの歴史に関連づけています。

もちろん，コースの主なトピックの1つは「なぜElixirなのか」です。

Programming Elixir[^2]で、Dave Thomas(デイヴ・トーマス)は、「データを隠蔽したいわけではない。データを変換したいのである」と述べています。

私は，この考察を関数型プログラミングではない新しいプログラミングパラダイム，**データ変換パラダイム**だと認識しました。

そこで，この話題を含め，Elixirの設計についての考察の歴史についてメールでインタビューしたいと思います。このインタビューは，編集して，Elixir10周年記念記事の1つとして公開する予定です。

[^1]: Masakazu Mori: *Live Coding in 20 Minutes of a Membership Site by Phoenix and phx_gen_auth*, ElixirConf 2021. The movie is available at https://youtu.be/t5TT0-mI2O4
[^2]: Dave Thomas: *Programming Elixir 1.6: Functional `|>` Concurrent `|>` Pragmatic `|>` Fun*, 2nd edition, The Pragmatic Bookshelf, 2018. https://pragprog.com/titles/elixir16/programming-elixir-1-6/ 邦訳: プログラミングElixir第2版: https://shop.ohmsha.co.jp/shop/shopdetail.html?brandcode=000000006824&search=%A5%D7%A5%ED%A5%B0%A5%E9%A5%DF%A5%F3%A5%B0elixir&sort=

まず，データ変換の基盤となるElixirの本質的な機能は，`Enum`の関数とパイプライン演算子の組み合わせです。

ご存知のように，これはプログラミングに大きな快感をもたらします！ 実際，それはElixirを選ぶ理由の1つです。

しかし，10年前のElixirの最初のバージョンは関数型ではなく、オブジェクト指向型です。

それで，Elixirの最初のアイデアには，データ変換に向けたそのような概念が含まれていない可能性があると考えました。

そこで私の最初の質問は，この特徴に関する考察のプロセスについてです: **いつアイデアが形成されましたか，そしてそのアイデアは何からもたらされましたか？**

> 註: Joséによると，Elixirが生まれたのは2012年5月24日だそうです。

# José Valimからの返信【2021年12月28日】

> **いつアイデアが形成されましたか，そしてそのアイデアは何からもたらされましたか？**

そのアイデアが生まれた特定の瞬間はなかったと思います。むしろ，それはオブジェクト指向をゆっくりと解明するような，いくつかのアイデアや概念として明らかにすることでした。

そのような瞬間の1つは、Clojureの作者であるRich Hickey(リッチー・ヒッキー)による[Simple Made Easy](https://www.infoq.com/presentations/Simple-Made-Easy/)という講演でした。

もう1つの瞬間は，Peter Van Roy(ピーター・ヴァン・ロイ)とSeif Haridi(セイフ・ハリディ)による["Concepts, Techniques, and Models of Computer Programming"](https://mitpress.mit.edu/9780262220699/concepts-techniques-and-models-of-computer-programming/)([「コンピュータプログラミングの概念・技法・モデル」](https://www.shoeisha.co.jp/book/detail/9784798113463))という本を読んでいたときのことです。この本では，新しい概念とその利点を1つずつ紹介することによってプログラミング言語を構築しています。

オブジェクト指向に関する章では，オブジェクト指向は既知のモジュールにディスパッチするためのシンタックスシュガーにすぎないと彼らは主張しています。 たとえば，次の場合:

```java
car = new Car()
car.method()
```

次と同じです:

```java
car = new Car()
Car.method(car)
```

オブジェクト指向をシンタックスシュガーと見なすとしたら，次の質問に答える必要があります: そのシンタックスシュガーには，そうするだけの価値がありますか？ 

このシンタックスシュガー(とオブジェクト指向)の問題点は，状態とふるまいを結合することです。状態(`car`)は、特定のエンティティ(クラス`Car`)によってのみ処理できます。これは(オブジェクト指向の)特徴として売りにすることがよくありますが，実際には，開発者はこの結合を元に戻そうとしたり，推論したりするのに多くの時間を費やしているのが実態です。

たとえば，この結合によって，継承が必要になります。しかし，継承の導入にはそれ自体で多くの問題があり，プログラミング言語に多重継承(ミックスイン)やオープンクラス(モンキーパッチ)のような概念を導入することになりました。それら全て，それ自体で欠陥を持っています！

この「パズル」のもう一方の部分は，ソフトウェアが複雑なのは，その計算やアルゴリズムにあるわけではないということを関数型プログラミングが示してきたことです。

システムに共有状態がない場合，システムに副作用がない場合は，人間とコンパイラの双方にとって，コードについて推論するのがはるかに簡単になります。したがって，状態をカプセル化することにより，私たちはオブジェクト指向からシステムの複雑な部分を隠すことを学びました。

それだけでなく，この状態をいくつかのオブジェクトに分割することがよくあります。これにより，アプリケーションがどのように機能するかを理解して視覚化できます。

最後に，産業界は何十年にもわたって学術の分野で知られていることを学びました: カプセル化，抽象化，ポリモーフィズムなど，オブジェクト指向に積極的に関連付けられている特性は，実際にはオブジェクト指向に固有のものではなく，他のパラダイムで活用でき，場合によってはさらに成功することもあります。

---

では、元の質問に戻りましょう。このシンタックスシュガーにはそうするだけの価値がありますか？ 

オブジェクト指向にはそうするだけの価値がありますか？ 

私にとってその答えは明らかにノーです。

マイナス面はプラス面よりもはるかに多いのです。 

そして，オブジェクトがなければ，私たちはただ，個別のエンティティとしての状態(データ)と関数(変換)だけを使います。Elixirプログラミングの様式は，その直接的な結果としてもたらされます。

Elixirはパイプライン演算子も提供します。これは、シンタックスシュガーと見なすこともできます。パイプライン演算子は次のプログラム:

```elixir
Enum.frequencies(String.graphemes("Elixir"))
```

を次のように変換します:

```elixir
"Elixir" |> String.graphemes() |> Enum.frequencies()
```

ある意味では，オブジェクト指向言語の `.` として見ることもできますが，状態とふるまいの結合はありません(註: 状態とふるまいを綺麗に分離することができます)。状態(この場合は，`"Elixir"`という文字列として始まる)は，文字列型を受けつける任意のふるまいに送信することができます。(註: `String.graphemes("Elixir")` における状態 `"Elixir"` と振る舞い `graphemes` はペアになっています。それが，`"Elixir" |> String.graphemes` だと、状態 `"Elixir"` を，文字列型を受け入れる任意の振る舞い`graphemes`に送信するという記述になっています)

P.S. 合わせてこちらもお楽しみください．[「Elixirと私の未来: 集合論型 by José Valim」](https://qiita.com/zacky1972/items/6c9cc82d9ba5f83e76d2)
