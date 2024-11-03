---
title: 'Vulkan日記その1: HomebrewでVulkanをインストール'
tags:
  - homebrew
  - macOS
  - Vulkan
private: false
updated_at: '2024-11-03T13:54:16+09:00'
id: 967d6ea213ee658bfa43
organization_url_name: null
slide: false
ignorePublish: false
---
今年のQiita Advent Calendar 2024での連載記事の1つは，Vulkanにしようかなと思いました．行き当たりばったりでつらつらと書きます．

まずは，Homebrewでインストールを試みてみます．

```zsh
brew update
brew search vulkan
```

とすると，次のFormulaeがあるようです．

* `vulkan-extensionlayer`
* `vulkan-headers`
* `vulkan-loader`
* `vulkan-profiles`
* `vulkan-tools`
* `vulkan-utility-libraries`
* `vulkan-validationlayers`
* `vulkan-volk`

全部入れてみました．

```zsh
brew install vulkan-extensionlayer vulkan-headers vulkan-loader vulkan-profiles vulkan-tools vulkan-utility-libraries vulkan-validationlayers vulkan-volk
```

それぞれインストールされたディレクトリを確認します．

```zsh
brew --prefix vulkan-extensionlayer vulkan-headers vulkan-loader vulkan-profiles vulkan-tools vulkan-utility-libraries vulkan-validationlayers vulkan-volk
```

インストールされた全てのファイルの確認方法は次のとおりです．

```zsh
brew --prefix vulkan-extensionlayer vulkan-headers vulkan-loader vulkan-profiles vulkan-tools vulkan-utility-libraries vulkan-validationlayers vulkan-volk | xargs -I {} find {}/
```

下記のドキュメントの Verify the SDK Installation に沿ってコマンドがインストールされているかを確認します．

https://vulkan.lunarg.com/doc/sdk/1.3.296.0/windows/getting_started.html

まず `vkvia`

```zsh
brew --prefix vulkan-extensionlayer vulkan-headers vulkan-loader vulkan-profiles vulkan-tools vulkan-utility-libraries vulkan-validationlayers vulkan-volk | xargs -I {} find {}/ | grep vkvia
```

あれ，無い．

探してみると，下記レポジトリをビルドするっぽい．必要になったらビルドするか．

https://github.com/KhronosGroup/VulkanTools-ForSC


次に，`vulkaninfo`

```zsh
brew --prefix vulkan-extensionlayer vulkan-headers vulkan-loader vulkan-profiles vulkan-tools vulkan-utility-libraries vulkan-validationlayers vulkan-volk | xargs -I {} find {}/ | grep vulkaninfo
```

ありそう．

最後に `vkcube`

```zsh
brew --prefix vulkan-extensionlayer vulkan-headers vulkan-loader vulkan-profiles vulkan-tools vulkan-utility-libraries vulkan-validationlayers vulkan-volk | xargs -I {} find {}/ | grep vkcube
```

あるっぽい．

[つづく](https://qiita.com/zacky1972/items/65ac97e850441958a7ea)
