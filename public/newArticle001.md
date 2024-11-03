---
title: 'Vulkan日記その4: buildrootでVulkanをインストールする方法について'
tags:
  - RaspberryPi
  - buildroot
  - Nerves
  - Vulkan
  - raspberrypi5
private: false
updated_at: '2024-11-04T08:26:14+09:00'
id: 85bbcb135db4f90ad09e
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
buildrootでMesa3DのVulkanをインストールしておく方法について，仮説を立てました．

- [Vulkan日記その1: HomebrewでVulkanをインストール](https://qiita.com/zacky1972/items/967d6ea213ee658bfa43)
- [Vulkan日記その2: デモンストレーション・プログラムを動かす](https://qiita.com/zacky1972/items/65ac97e850441958a7ea)
- [Vulkan日記その3: Raspberry Pi 5 + Nerves で Vulkanが動くっぽい](https://qiita.com/zacky1972/items/1b76e79b47fd58f90c80)

## RasPi 5 の GPU

https://www.raspberrypi.com/products/raspberry-pi-5/

> VideoCore VII GPU, supporting OpenGL ES 3.1, Vulkan 1.2

VideoCore で検索すると，メーカーはBroadcomでした．

## Frank Hunlethさんから教わったことの確認

Nerves Project代表のFrank Hunlethさんから，次のリンクを教わっていました．

https://github.com/nerves-project/nerves_system_rpi5/blob/main/nerves_defconfig#L46-L48

## 調査

このオプションを調べてみると，次のようなページに行き当たりました．

https://fossies.org/linux/buildroot/package/mesa3d/Config.in

```
64 config BR2_PACKAGE_MESA3D_VULKAN_DRIVER
65 	bool
66 	select BR2_PACKAGE_MESA3D_DRIVER
...
285 config BR2_PACKAGE_MESA3D_VULKAN_DRIVER_BROADCOM
286 	bool "Vulkan broadcom driver"
287 	depends on BR2_arm || BR2_aarch64
288 	depends on BR2_TOOLCHAIN_HAS_SYNC_4 # dri3/libxshmfence
289 	select BR2_PACKAGE_MESA3D_VULKAN_DRIVER
290 	help
291 	  Vulkan broadcom driver.
```

## 仮説

すなわち，`nerves_defconfig`を次のように設定したら，Vulkanインストール済みにならないかなと思いました．

```
BR2_PACKAGE_MESA3D=y
BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_V3D=y
BR2_PACKAGE_MESA3D_OPENGL_ES=y
BR2_PACKAGE_MESA3D_VULKAN_DRIVER=y
BR2_PACKAGE_MESA3D_VULKAN_DRIVER_BROADCOM=y
```

## まとめ

以上をまとめると，buildrootの設定を変えることで，Raspberry Pi 5 上の Nerves で， Mesa3D の Vulkan をインストールすることができそうです．

つづく，かも．
