---
title: '型システムのアップデート: 研究から開発への移行 by José Valim'
tags:
  - Elixir
private: false
updated_at: '2023-07-05T18:16:07+09:00'
id: 33fd39ef2a1dcdbb8b73
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
原文: https://elixir-lang.org/blog/2023/06/22/type-system-updates-research-dev/

1年前のElixirConf EU 2022で，私たちはElixirの型システムを研究開発する取り組みを発表しました．[動画](https://www.youtube.com/watch?v=Jf5Hsa1KOc8) [報告書](https://elixir-lang.org/blog/2022/10/05/my-future-with-elixir-set-theoretic-types/) [訳註: 報告書日本語訳](https://qiita.com/zacky1972/items/6c9cc82d9ba5f83e76d2)

この研究は，CNRS 上級研究員の [Giuseppe Castagna](https://www.irif.fr/~gc/) の指導の下で行われており，[Guillaume Duboc](https://www.irif.fr/users/gduboc/index) が博士課程の研究の一環として担当し，さらに私 (José Valim) が指導しています．

この記事は，私たちの取り組みの現状と今後の方向性をまとめたものです．

## 研究完了

研究中の私たちの主な目標は，Elixir の機能のセマンティクス(意味論)のほとんどをモデル化できる型システムを見つけること，さらに互換性がない，または欠けているとわかった領域についてまったく新しい理論を開発することです．私たちは段階的な集合論型システムでこの目標を達成できたと信じており，現在開発に向かう準備ができています． 過去2か月にわたって，私たちは結果に関する多くのリソースを公開してきました．

* [Elixirの型システムの設計原則に関する技術レポート(訳註: 日本語訳計画中)](https://arxiv.org/abs/2306.06391)
* [上記の研究に関する ElixirConf 2023 での Guillaume Duboc による技術プレゼンテーション](https://youtu.be/gJJH7a2J9O8)
* [SmartLogic ポッドキャストでの Giuseppe Castagna，Guillaume Duboc，José Valim の非公式ディスカッション](https://smartlogic.io/podcast/elixir-wizards/s10-e12-jose-guillaume-giuseppe-types-elixir/)
* [Guillaume Duboc，José Valim，Twitch コミュニティでの非公式 Q&A](https://www.twitch.tv/videos/1841707383)

これまでのところ，セマンティクス(意味論)に焦点を当ててきました．新しい集合論的型システムのセマンティクスを表現できる新しい構文を導入しましたが，ユーザー向けのプログラミング言語の変更に関する具体的な計画がまだないため，この構文は最終的なものではありません．これらの変更を行うと確定したときに，型システム・インターフェイスとその構文についてコミュニティと十分な議論を行う予定です．

これまでの取り組みは，[Fresha](https://www.fresha.com)，[Supabase](https://supabase.com)，[Dashbit](https://dashbit.co) からのスポンサーシップによる [CNRS](https://www.cnrs.fr/fr) と [Remote](https://remote.com) のパートナーシップのおかげで可能になりました．

## 開発開始

研究はまだ進行中ですが，2023年後半以降は開発に重点を置きます．

大規模に使用される言語に型システムを組込むことは，困難な作業になる可能性があります．私たちの懸念は，コミュニティが型システムとどのように対話して使用するかから，大規模なコードベースでどのように実行されるかまで，多岐にわたります．したがって，私たちの計画は，(冗談を意図した)漸進的型システムを漸進的に(徐々に)Elixirコンパイラーへ導入することです．

最初のリリースでは，型はコンパイラーによって内部的にのみ使用されます．型システムは，言語にユーザー側の変更を加えることなく，パターンとガードから型情報を抽出し，フィールド名のタイプミスや文字列に整数を追加しようとしたときの型の不一致など，最も明らかな間違いを見つけます．この段階での主な目標は，型システムのパフォーマンスへの影響と，型指定違反の場合に生成できるレポートの品質を評価することです．結果に満足できない場合は，自分の仕事を再評価するか，主導権を完全に放棄する時間がまだあります．

2番目のマイルストーンは，Elixirコードベースで名前が付けられ静的に定義される構造体のみに型アノテーションを導入することです．Elixirプログラムは構造体のパターン・マッチを頻繁に実行し，構造体フィールドに関する情報を明らかにしますが，それぞれの型については何も知りません．プログラム全体にわたって構造体とそのフィールドから型を伝播することで，型システムの実装にさらに負担をかけながら，型システムのエラー検出能力を向上させます．

3番目のマイルストーンは，関数に(おそらく)`$`を接頭辞(prefix)としてつけた型アノテーションを導入することです．型の再構築はまったく行われないか，非常に限定されています．ユーザーはコードに型の注釈を付けることができますが，型のないパラメータは`Dynamic()`型であると想定されます．成功すれば，事実上，言語に型システムが導入されたことになります．

この新しいエキサイティングな開発段階は，[Fresha](https://www.fresha.com)[(採用中!)](https://www.fresha.com/careers/openings?department=engineering)，[Starfish*](https://starfish.team)[(採用中!)](https://starfish.team/jobs/experienced-elixir-developer)，[Dashbit](https://dashbit.co)によって後援されています．







