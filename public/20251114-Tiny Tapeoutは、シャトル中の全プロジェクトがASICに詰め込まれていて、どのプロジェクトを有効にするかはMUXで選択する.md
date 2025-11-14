---
title: Tiny Tapeoutは、シャトル中の全プロジェクトがASICに詰め込まれていて、どのプロジェクトを有効にするかはMUXで選択する
tags:
  - OSS
  - 半導体
  - オープンソース半導体
private: false
updated_at: '2025-11-15T08:43:17+09:00'
id: 053f2097b52b34401a1e
organization_url_name: null
slide: false
ignorePublish: false
---
[Tiny Tapeoutは、デザインを実際のチップ上に製造することをこれまで以上に簡単かつ安価にする教育プロジェクトです。](https://tinytapeout.com)

チップには下図のようにユーザーが作った回路がぎっしりと詰め込まれています。

![チップマップ](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/fe34c834-bdee-40ed-9969-0a37ed58aadc.png)

さて本題ですが、
[GETTING STARTED WITH THE TINY TAPEOUT 04+ DEMO BOARD](https://tinytapeout.com/guides/get-started-demoboard/)を読んでみると、

[Selecting Projects](https://tinytapeout.com/guides/get-started-demoboard/#selecting-projects)に下記が書かれています。

> Since TT04 a multiplexer on the chip decides which projects are powered and enabled to communicate through the I/O. This MUX, needs to be told just which project you’d like to interact with.

> TT04以降、チップ上のマルチプレクサが、どのプロジェクトに電源を供給し、I/O経由で通信できるようにするかを決定します。このMUXに、どのプロジェクトと通信したいかを伝える必要があります。

ISHI会のDiscordで @noritsuna さんに次のように聞いてみました。

> Tiny Tapeout ASICでは、各設計者の回路は、MUXで選択されるという理解で合っていますか？ その MUX がどのような設計になっているか知りたいのですが、どのように調べたら良いでしょうか？ (Tiny Tapeout ASICのクロックを理論上どこまで上げられる設計になっているかが知りたいです)

すると次のような回答がありました。

> ここの複合でビルドされてます。
> https://github.com/TinyTapeout/tinytapeout-sky-25b
> https://github.com/TinyTapeout/tt-multiplexer/tree/7481146140da8cc28dbd7679ee284e894a8913f3

見てみました。

https://github.com/TinyTapeout/tt-multiplexer/blob/7481146140da8cc28dbd7679ee284e894a8913f3/docs/INFO.md

つまりこういうことです。タイトルコール！

> Tiny Tapeoutは、シャトル中の全プロジェクトがASICに詰め込まれていて、どのプロジェクトを有効にするかはMUXで選択する

信号経路上にMUXが挟まるので、たとえば $F_{\textit{MAX}}$ をあまり極端に上げることができない模様です。
