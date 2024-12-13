---
title: DRP-AI日記その2 Kakipを起動してみた
tags:
  - DRP-AI
  - Kakip
private: false
updated_at: '2024-12-13T10:08:27+09:00'
id: 438ddc192fc499fb697c
organization_url_name: null
slide: false
ignorePublish: false
---
Kakipを起動してみました．

DRP-AIシリーズ・Kakip

- [DRP-AI日記その1 なぜDRP-AIシリーズに取り組むのか](https://qiita.com/zacky1972/items/3ebf021cab1e972890f8)

## 用意するもの

https://yds-kakip-team.github.io/techdoc/jp/2/

* Kakip本体
* 電源
    * DC12V/25W以上の出力
    * DCジャック（外形：φ5.5mm、ピン：φ2.1mm、センタープラス）形状のもの
* USB TypeA Hub (本体には2つしかないのでセットアップには足りません)
* マウス・キーボード(USB Type Aの有線接続のもの)
* USB Type A 接続のディスプレイアダプタ．次の2つが動作確認済とのこと
    * Buffalo GX-HDMI/U2
    * Wavlink WL-UG17D1 (私はこちらを購入しました)
* ディスプレイ
* micro SDカード
* イーサケーブル・有線LAN
* micro SDを読み書きできるPC

## macOSの場合のmicroSDカード書き込み

https://yds-kakip-team.github.io/techdoc/jp/2/2-1/

インストールのいらないこちらの手順にしました．

* [MacでOSイメージをSDカードに焼く](https://qiita.com/ishihamat/items/f1fb1f30327373dffac7)

## 起動

https://yds-kakip-team.github.io/techdoc/jp/2/2-2/


[Kakipを使いはじめてみた](https://wasa-labo.com/wp/?p=1228#%25e8%25b5%25b7%25e5%258b%2595%25e3%2581%25ab%25e6%2599%2582%25e9%2596%2593%25e3%2581%258c%25e3%2581%258b%25e3%2581%258b%25e3%2582%258b%25e3%2581%25ae%25e3%2581%25a7%25e6%25b3%25a8%25e6%2584%258f)にあるように，起動には結構時間がかかります．

注意点として，2024年12月現在，次のIssueがありました(私が報告しました)．

https://github.com/Kakip-ai/kakip_linux/issues/1

## まとめ

今日のところは動作確認のためにただ起動しただけですが，別の整った場所に設置し直して環境を整えて，SSHでリモートログインできるように設定しようと思います．

