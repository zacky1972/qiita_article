---
title: ElixirChipとElixirChip Liteで超低消費電力・高性能の世界へ
tags:
  - Elixir
  - AppleSilicon
  - DRP-AI
  - 技術的ポエム
  - ElixirChip
private: false
updated_at: '2024-12-29T21:47:49+09:00'
id: 960f67189705c388b3a7
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
ElixirChipとElixirChip Liteに関する技術的ポエムを書いてみました．

ElixirChip構想を最初に表明したのは， @piacerex さんです．実は @piacerex さんがQiita記事でElixirChipを書く前から，私も独自プロセッサによるElixirアクセラレーションの可能性には気づいて秘密裏に研究を進めていたのですが，当時の私は事業性を見出していなかったので，大々的に発表する気になれず，細々と個人的に研究を進めていたのみでした．が， @piacerex さんのElixirChip構想の発表により，事業性があるんだということを思い知らされて，俄然やる気が出て， @piacerex さんに近づき，当時転職活動をしようとしていた @Ryuz さんを @piacerex さんにご紹介して引き抜いてもらい，並行して関連特許も出願して，ElixirChipについての研究を本格的にスタートしました．

ElixirChipについては，Interface 2024年10月号別冊付録のFPGAマガジン特別版No.3のコラムに書かせていただきました．Kria KR260を用いて，積和演算について，理論上，最高速クロック周波数で駆動することに成功し，高い電力あたり性能を達成しました．その後の検証で，消費電力を実測し，実証した電力あたり性能としては254GOPs/Wを達成しました．これは同程度のプロセスルールであるIntel Xeon E3-1285 v6に対して，24.2倍の電力あたり性能です．

さて，従来CPUでも，Elixirを導入することで，30倍の電力あたり性能を達成できます．下記事例では，300基の従来CPUを必要とするウェブ・アプリケーションを従来CPU10基に抑えることができたという報告です．

https://paraxial.io/blog/elixir-savings

これらを合わせると，726倍の電力あたり性能を達成できそうな計算になります！

最先端のプロセスルールとAIアクセラレータを採用したFPGAであるAMD Versalシリーズで実現したら，もっと高い電力あたり性能を追求できそうです．

さらに，最先端のプロセスルールでASIC化することで，さらにさらに高い電力あたり性能を追求できそうです．

どのくらいまでいけるんですかね．楽しみです．

さて，ElixirChip Lite という構想も， @piacerex さんの発案によるものです．ElixirChip Liteという構想は，ElixirChipでなくても，携帯電話や自動運転車のプロセッサなど，電力あたり性能の良さそうなプロセッサ向けにElixirによる最適化を行うという構想です．

最近，私が研究しているところで言うと，電力あたり性能の高いApple SiliconやルネサスエレクトロニクスDRP-AIシリーズなどで，ElixirChip Liteを実現すると良いのではないかと思います．

https://qiita.com/zacky1972/items/34ff853daebaf24761a4

https://qiita.com/zacky1972/items/5c92779e2bac7ab631e8

今後の予測では，AIの大規模化に伴い，データセンターの電力需要が急激に伸びるそうですが，ElixirChipとElixirChip Liteで，電力需要の伸びを抑制し，さらには減少させるくらいのインパクトを持たせることで，ゼロカーボン達成に貢献できると良いなと思っています．
