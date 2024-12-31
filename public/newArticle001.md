---
title: TOPPERSカーネルと箱庭とElixirを利用したリアルタイムAIシステム・デジタルツイン構想について
tags:
  - Elixir
  - AI
  - TOPPERS
  - Vulkan
  - 箱庭
private: false
updated_at: '2024-12-31T09:54:41+09:00'
id: 19bb7c70a3647a90d832
organization_url_name: null
slide: false
ignorePublish: false
---
2024年の大晦日の締めに，2025年以降に向けての研究ヴィジョンを書いてみたいと思います．来る第15回TOPPERS活用アイデア・アプリケーション開発コンテストにとっておいても良いかなとも思わなくもないのですが，活用アイデア部門について金・銀・銅を総なめしたので，これ以上はやりすぎかなという感触もあるので，TOPPERS Advent Calendar 2024の記事として放流します．

まず下記記事にて，TOPPERSアプリケーションをElixirで記述できるようにする研究の抱負を述べました．

https://qiita.com/zacky1972/items/32ea9887fceb058ee5da

Elixirでは豊富なAI資産を活用することができます．下記は2022年12月9日に発表されたBumblebeeについて，Elixirの原作者のJosé Valim氏自身が表明したブログ記事です．

https://news.livebook.dev/announcing-bumblebee-gpt2-stable-diffusion-and-more-in-elixir-3Op73O

その後，ElixirのAI資産は順調に発展を遂げており，下記動画にあるように，MLOpsの方向，すなわち推論を効率よく行うオルタナティブ・ソリューションとしての方向性を強化しています．アメリカの軍事予算を入れて精力的に研究開発を進めているようです．

<iframe width="560" height="315" src="https://www.youtube.com/embed/6aVnwj8WQq4?si=vS67zaBw1jV9P_Jz" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

私が研究開発を進めるElixirでTOPPERSアプリケーションを記述する方向性に関して，当然のことながら，こうしたAI資産をそのまま活用することができることを目標に掲げていきたいです．

せっかくTOPPERSカーネルを利用するので，リアルタイムの方向性も追求していきたいですよね．現状のElixirではリアルタイム制約を記述する機能は備わっていませんが，研究がある程度の段階に達したところで，Elixirコミュニティに提案していく方向にしていきたいです．

一方で，最近，私たち山崎進研究室は，箱庭についても研究を進めています．箱庭ラボの森崇さん @kanetugu2018 にご協力いただき，山崎進研究室の学生に技術移転を図っています．私は諸事情で，リアルタイムではこの技術移転活動に加わりきれていないのですが，時間を見つけてフォローアップしていきたいと思っております．

私の箱庭に関する最大の関心事は，オンボードでのデジタルツインを実現することです！ その手始めとして，研究室学生の卒業研究で，UnityをRasPi 5で実行することに取り組んでいます．一応動作できたのですが，GPUアクセラレーションが利かないので，実用上使い物にならないだろうという結論を得ました．その結論は実は想定内でして，この結果を踏まえて，箱庭を用いたオンボードでのデジタルツイン環境の構築を進めていきたいと考えております．

ここで鍵となるAPI，Vulkanがあります．VulkanはOpenGL後継の3DグラフィックスAPIに位置付けられています．

https://www.vulkan.org

Vulkanを用いることで，機械学習とデジタルツインの両方のアクセラレーションを効率的にできるだろうと考えています．たとえばRasPi 5でVulkanを動かすことができることは確認済です．

実は，Vulkanに関する研究も山崎進研究室でスタートさせており，別の研究室学生にVulkanを紹介したところ，とても気に入ってくれて，精力的に研究を進めてくれています．

ElixirのAI資産や箱庭から，Vulkanを活用できるように，仕立てていこうと思っております．

そのように思って，Qiita Advent Calendar 2024にて，Vulkan日記を書き溜めていました．

- [Vulkan日記その1: HomebrewでVulkanをインストール](https://qiita.com/zacky1972/items/967d6ea213ee658bfa43)
- [Vulkan日記その2: デモンストレーション・プログラムを動かす](https://qiita.com/zacky1972/items/65ac97e850441958a7ea)
- [Vulkan日記その3: Raspberry Pi 5 + Nerves で Vulkanが動くっぽい](https://qiita.com/zacky1972/items/1b76e79b47fd58f90c80)
- [Vulkan日記その4: buildrootでVulkanをインストールする方法について](https://qiita.com/zacky1972/items/85bbcb135db4f90ad09e)
- [Vulkan日記その5: Raspberry Pi 4 + Nerves でも Vulkanが動くっぽい](https://qiita.com/zacky1972/items/a67c0139ee6eee431de9)

今後は，TOPPERSカーネルからVulkanを利用できるようにすることや，Vulkanの利用にリアルタイム制約を記述できるようにすることについても，研究を進めてまいりたいと思っております．

