---
title: Elixirと宇宙の話でもしますか〜Elixirと宇宙利用の関係
tags:
  - Elixir
  - 宇宙
private: false
updated_at: '2022-12-14T02:21:13+09:00'
id: 6c98bb91c7c076f92988
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
現在，私は大きく分けて，並列プログラミング言語Elixirに関する研究と，宇宙利用・宇宙開発におけるコンピュータの研究を行っています．この2つは，まるで関連がないように思うかもしれませんが，私はこの2つの研究を，一貫性を持って研究しているつもりでいます．この記事では，その2つの関連性のうち，Elixirと宇宙利用の関係についてお話ししたいと思います．

なお，この記事は，A-STEPトライアウト「SAR衛星観測データ解析・伝送・共有による費用対効果の高い土砂災害検出システムの実現可能性検証」の主要研究成果物です．

https://zacky1972.github.io/blog/2022/03/29/sar-apps.html

また科研費基盤C「MPSoCとSAR衛星によるリアルタイム土砂災害情報提供システムの実現可能性検証」の一環でもあります．

https://zacky1972.github.io/blog/2022/03/04/sar-data-processing-satellites.html


# Elixirの特長

Elixirの特長を改めてあげると次のようになるかと思います([この質問への回答で書きました](https://qiita.com/BananaCat13/questions/cb5f58b9de650b3e8605#answer-f8fadef0585faacc21f7))．

1. Enumとパイプライン演算子で上から下にデータ変換していくようなプログラミングスタイル(データ変換パラダイムと呼んでいます)と，関数パターンマッチで，とても気持ち良くプログラミングできる
2. アクターモデルに基づいて，並行・並列処理を容易に記述できる
3. Supervisorによるエラーハンドリングにより，フォールト・トレラント・システムを容易に構築できる(Supervisorによるエラーハンドリングを言語レベルで導入しているプログラミング言語は，Elixir/ErlangなどBEAM言語だけです)
4. 自動テスト・Doctestが組み込まれており，Typespecsによる後付けの型チェックを入れられるので，TDDやソフトウェア品質保証も容易にできる
5. Regexによる正規表現，Nimble Parsecによる構文解析，マクロによるメタプログラミングなど，充実していて，ミニ言語(DSL)を取り入れるのがとても容易

# 宇宙利用について

宇宙産業というとロケット打ち上げをイメージすることが多いと思いますが，宇宙産業は裾野が広く，ロケット打ち上げは一角に過ぎません．

様々な宇宙産業の中でも参入しやすいのが，衛星データなど，宇宙で得られる成果物を利用して，私たちの身の回りに役に立つようにする情報産業です．この宇宙利用の産業で最も身近な存在といえば，民間気象予報事業者ではないでしょうか．

衛星データから得られる情報は気象情報だけではなく，農業，防災，交通，漁業，鉱業，土木業など，様々な産業に応用可能な情報が得られます．[宙畑](https://sorabatake.jp)というウェブサイトでは，このような産業利用を数多く紹介しているので，ぜひご覧になってください．

# 宇宙利用の技術的課題の1つ

衛星から得られるデータは1枚あたり数万ピクセル四方にも及ぶ巨大な画像データを含んでいるために，様々な技術的課題が生じます．通信するのも大変ですし，保存も大変です．そして処理するのも一苦労です．

[第66回宇宙科学技術連合講演会という学会で発表した「SAR衛星によるリアルタイム土砂災害情報提供システムの実現に向けた衛星画像の分散並列処理の実現」](https://researchmap.jp/zacky1972/misc/40467660)における思考実験を引用します．

> ここで思考実験を行う．この方向性を究極まで押し進めたとする．まず，民間に流通するSAR衛星データの空間分解能は，日本では法律ならびに内閣府令によって規制を受けている．このような法令による規制が設けられた理由は，高分解能の衛星データを悪用されないよう管理するためであり，日本だけでなく，米独仏加４カ国にも同様の制限を課す法令が存在する．これらによると，SAR衛星画像として合法的に民間で流通できる最も高い空間分解能は24センチメートル四方であると我々は解釈した．これを踏まえ，日本の民間企業のSAR衛星コンステレーション1社が保有する衛星画像の量的な上限として，地球全体の表面積約5億平方キロメートルを空間分解能24センチメートル四方かつ10分間隔に観測できた場合を想定する．この時に地球全体を画像化した時の画像サイズは約8.7ペタピクセルにも及び，4K画像10億枚以上に相当する．1ピクセルを8ビットで表現した場合，この画像は約8.7ペタバイトとなり，1テラバイトのSSDが約8,700台分に相当する．これを10分間隔で更新するので，1日に約1.2エクサバイト，1年間で約456エクサバイトに達する．すなわち1年間で地球全体を収めたSAR衛星画像データのためだけにSSDを4.56億台も増設する必要がある計算となる．

「この方向性」というのは，最近の民間の衛星事業者は複数の衛星を周回軌道に投入することで地表や海洋を10分間隔〜数時間間隔で観測できるようになってきていることを指します．SAR衛星というのは衛星の種類で，マイクロ波を地表面に照射して散乱して戻ってくるマイクロ波を受信することで地表面を精細に観測する衛星のことです．衛星コンステレーションというのは，複数の衛星を周回軌道に投入して協調させて動作させる方式のことです．

このように，究極的にはとてつもない分量の衛星データが生み出される未来がすぐそこにあるのです．

また，この文献では次のようにも述べています．

> そこまで考えなかったとしても，日常業務で衛星画像を扱うのにコンピュータの処理能力を必要とすることは多々ある．衛星画像1枚だけでも数万ピクセル四方の巨大なサイズであり，SAR衛星画像3枚をR,G,Bに割り当てて合成する極めて単純な画像処理をPC上で行うだけでも，一瞬とはいかない処理時間を要するものである．また，たくさんのウィンドウを開いて複数の衛星画像を俯瞰しようとすると，メモリ不足に陥ることも多い．

# 宇宙利用でElixirに期待していること


前述のElixirの特長の中で

> アクターモデルに基づいて，並行・並列処理を容易に記述できる

宇宙利用の観点ではこの点に特に期待しているということになります．つまり，並列処理を行うことで，巨大かつ膨大な衛星データの通信と処理を円滑に行えるのではないかという期待です．

しかもElixirだと

> Enumとパイプライン演算子で上から下にデータ変換していくようなプログラミングスタイル(データ変換パラダイムと呼んでいます)と，関数パターンマッチで，とても気持ち良くプログラミングできる

この特長と組み合わせることができます．

よく使う例ですが，次のようなプログラム

```elixir
1..1_000_000
|> Enum.map(& &1 * 2)
|> Enum.map(& &1 + 1)
```

は，各要素で行う2倍して1加える処理は互いに依存関係がなく独立しているので，最大1,000,000並列で行っても良いです．

そこで，Flowという仕組みを使って次のように可読性を損ねることなく，実に簡単に並列処理できます．

```elixir
1..1_000_000
|> Flow.from_enumerable()
|> Flow.map(& &1 * 2)
|> Flow.map(& &1 + 1)
|> Enum.to_list()
```

また，巨大な画像を扱った画像処理や機械学習は実行に長時間かかることがあります．この処理が途中で異常終了してしまうと困ることになります．

そこで，次の特長に期待します．

> Supervisorによるエラーハンドリングにより，フォールト・トレラント・システムを容易に構築できる(Supervisorによるエラーハンドリングを言語レベルで導入しているプログラミング言語は，Elixir/ErlangなどBEAM言語だけです)

このように，Elixirを衛星データの解析で利用できるようになると，宇宙利用で役に立つというわけです．

その方向性の研究を紹介しているのがこちらです．

https://youtu.be/9H0AsmAsxgk

https://youtu.be/RkMzCQm-Ws4

@RyoWakabayashi さんがLivebookを使うようにQiita記事化してくださいました．

https://qiita.com/RyoWakabayashi/items/60d0aec59d7d6cc65f9c

続きはこちらに書いています．

https://qiita.com/zacky1972/items/5fced3392af5746c6a9f
