---
title: 'Vulkan日記その5: Raspberry Pi 4 + Nerves でも Vulkanが動くっぽい'
tags:
  - RaspberryPi
  - Nerves
  - Vulkan
  - RaspberryPi4
private: false
updated_at: '2024-11-04T09:08:40+09:00'
id: a67c0139ee6eee431de9
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
調べたところ，Raspberry Pi 5だけでなく，Raspberry Pi 4でも，Nerves で Vulkan を動かすことが可能っぽいです．

- [Vulkan日記その1: HomebrewでVulkanをインストール](https://qiita.com/zacky1972/items/967d6ea213ee658bfa43)
- [Vulkan日記その2: デモンストレーション・プログラムを動かす](https://qiita.com/zacky1972/items/65ac97e850441958a7ea)
- [Vulkan日記その3: Raspberry Pi 5 + Nerves で Vulkanが動くっぽい](https://qiita.com/zacky1972/items/1b76e79b47fd58f90c80)
- [Vulkan日記その4: buildrootでVulkanをインストールする方法について](https://qiita.com/zacky1972/items/85bbcb135db4f90ad09e)

## RasPi 4 のGPUは Broadcom VideoCore VI

https://www.raspberrypi.com/products/raspberry-pi-4-model-b/specifications/

> Broadcom BCM2711

https://www.zep.co.jp/ysugisaki/article/z-rpiqpu-da1/

> Raspberry Pi 4 （BCM2711): VideoCore VI （6)

## Vulkanのサポート状況

https://vulkan.gpuinfo.org

![Vulkan Drivers for VideoCores](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/f4e32196-d3b4-602e-2b1c-1a9a23d5f94e.png)


## まとめ

以上をまとめると，Raspberry Pi 4 上の Nerves で Vulkan を動かせるっぽいです．

つづく，かも．
