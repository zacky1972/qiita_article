---
title: 'Vulkan日記その3: Raspberry Pi 5 + Nerves で Vulkanが動くっぽい'
tags:
  - RaspberryPi
  - Nerves
  - Vulkan
  - raspberrypi5
private: false
updated_at: '2024-11-04T07:04:51+09:00'
id: 1b76e79b47fd58f90c80
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
調べたところ，Raspberry Pi 5 + Nerves で Vulkan を動かすことが可能っぽいです．

- [Vulkan日記その1: HomebrewでVulkanをインストール](https://qiita.com/zacky1972/items/967d6ea213ee658bfa43)
- [Vulkan日記その2: デモンストレーション・プログラムを動かす](https://qiita.com/zacky1972/items/65ac97e850441958a7ea)

## Raspberry Pi 5 搭載の GPU で Vulkan が動く

https://www.raspberrypi.com/products/raspberry-pi-5/

> VideoCore VII GPU, supporting OpenGL ES 3.1, Vulkan 1.2

## NervesでGPUがMesa3Dの下で動く

Nerves Project の Frank Hunleth さんに直に質問

ZACKY:

> Can Nerves drive GPU on RasPi 5? The following page does not seem to include description of the GPU.
> https://hexdocs.pm/nerves_system_rpi5/readme.html

Frank Hunlethさん:

> Yes, the Linux drivers are enabled at https://github.com/nerves-project/nerves_system_rpi5/blob/main/linux-6.6.defconfig#L373-L374. 
> Everything I know that uses the GPU these days, uses it via Mesa3D. https://github.com/nerves-project/nerves_system_rpi5/blob/main/nerves_defconfig#L46-L48. 
> If you're asking about ML rather than graphics, then I'm not sure if it has the optimal configuration.

## Mesa3Dの下で Vulkan Runtime が動く 

https://docs.mesa3d.org/vulkan/index.html

## アーキテクチャ構成図

![Vulkan on Nerves](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/671653e4-5fcf-c774-4028-555486e7a343.png)

## まとめ

以上をまとめると，Raspberry Pi 5 上の Nerves で Vulkan を動かせるっぽいです．

[つづく](https://qiita.com/zacky1972/items/85bbcb135db4f90ad09e)
