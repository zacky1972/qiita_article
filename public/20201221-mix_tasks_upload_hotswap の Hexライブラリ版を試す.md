---
title: mix_tasks_upload_hotswap の Hexライブラリ版を試す
tags:
  - Elixir
  - Nerves
  - Pelemay
private: false
updated_at: '2023-12-16T08:51:47+09:00'
id: f0b47eded7c902008871
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[#NervesJP Advent Calendar 2020](https://qiita.com/advent-calendar/2020/nervesjp) 23日目の記事です。

昨日は @ringo156 さんの[「Nervesで画像処理がしたい」](https://qiita.com/ringo156/items/688a52cf7c062f428094)でした。

さて，話題沸騰の `mix_tasks_upload_hotswap` がHexライブラリになったので，さっそく試しました。

# まずは mix new

`mix nerves.new (プロジェクト名)`として，Nervesのプロジェクトを作成します。例として，`hot_upload_test`という名称のプロジェクトを作成してみます。

```bash
❯ mix nerves.new hot_upload_test
* creating hot_upload_test/config/config.exs
* creating hot_upload_test/config/target.exs
* creating hot_upload_test/lib/hot_upload_test.ex
* creating hot_upload_test/lib/hot_upload_test/application.ex
* creating hot_upload_test/test/test_helper.exs
* creating hot_upload_test/test/hot_upload_test_test.exs
* creating hot_upload_test/rel/vm.args.eex
* creating hot_upload_test/rootfs_overlay/etc/iex.exs
* creating hot_upload_test/.gitignore
* creating hot_upload_test/.formatter.exs
* creating hot_upload_test/mix.exs
* creating hot_upload_test/README.md

Fetch and install dependencies? [Yn]   
* running mix deps.get
Your Nerves project was created successfully.

You should now pick a target. See https://hexdocs.pm/nerves/targets.html#content
for supported targets. If your target is on the list, set `MIX_TARGET`
to its tag name:

For example, for the Raspberry Pi 3 you can either
  $ export MIX_TARGET=rpi3
Or prefix `mix` commands like the following:
  $ MIX_TARGET=rpi3 mix firmware

If you will be using a custom system, update the `mix.exs`
dependencies to point to desired system's package.

Now download the dependencies and build a firmware archive:
  $ cd hot_upload_test
  $ mix deps.get
  $ mix firmware

If your target boots up using an SDCard (like the Raspberry Pi 3),
then insert an SDCard into a reader on your computer and run:
  $ mix firmware.burn

Plug the SDCard into the target and power it up. See target documentation
above for more information and other targets.
```

次のコマンドを入力して依存ライブラリをインストールします。(Raspberry Pi 3 を想定します)

```bash
❯ cd hot_upload_test
hot_upload_test ❯ export MIX_TARGET=rpi3
hot_upload_test ❯ mix deps.get
Resolving Hex dependencies...
Dependency resolution completed:
Unchanged:
  dns 2.2.0
  elixir_make 0.6.2
  gen_state_machine 2.1.0
  mdns_lite 0.6.6
  muontrap 0.6.0
  nerves 1.7.1
  nerves_pack 0.4.1
  nerves_runtime 0.11.3
  nerves_ssh 0.2.1
  nerves_system_bbb 2.8.2
  nerves_system_br 1.13.5
  nerves_system_osd32mp1 0.4.2
  nerves_system_rpi 1.13.2
  nerves_system_rpi0 1.13.2
  nerves_system_rpi2 1.13.2
  nerves_system_rpi3 1.13.2
  nerves_system_rpi3a 1.13.2
  nerves_system_rpi4 1.13.2
  nerves_system_x86_64 1.13.3
  nerves_time 0.4.2
  nerves_toolchain_aarch64_unknown_linux_gnu 1.3.2
  nerves_toolchain_arm_unknown_linux_gnueabihf 1.3.2
  nerves_toolchain_armv6_rpi_linux_gnueabi 1.3.2
  nerves_toolchain_ctng 1.7.2
  nerves_toolchain_x86_64_unknown_linux_musl 1.3.2
  one_dhcpd 0.2.5
  ring_logger 0.8.1
  shoehorn 0.7.0
  socket 0.3.13
  ssh_subsystem_fwup 0.5.1
  system_registry 0.8.2
  toolshed 0.2.17
  uboot_env 0.3.0
  vintage_net 0.9.2
  vintage_net_direct 0.9.0
  vintage_net_ethernet 0.9.0
  vintage_net_wifi 0.9.1
All dependencies are up to date

Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

==> elixir_make
Compiling 1 file (.ex)
Generated elixir_make app
==> nerves
cc -c -O2 -Wall -Wextra -Wno-unused-parameter -std=c99 -D_GNU_SOURCE -o /Users/zacky/hot_upload_test/_build/rpi3_dev/lib/nerves/obj/port.o src/port.c
cc /Users/zacky/hot_upload_test/_build/rpi3_dev/lib/nerves/obj/port.o  -o /Users/zacky/hot_upload_test/_build/rpi3_dev/lib/nerves/priv/port
Compiling 41 files (.ex)
Generated nerves app
==> hot_upload_test
Resolving Nerves artifacts...
  Cached nerves_system_rpi3
  Cached nerves_toolchain_arm_unknown_linux_gnueabihf
```

もしホストとターゲット(Raspberry Pi 3)をLANケーブルで直結する場合には，`config/target.exs`の次の部分を編集します。

```elixir:config/target.exs
# Configure the network using vintage_net
# See https://github.com/nerves-networking/vintage_net for more information
config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :dhcp}
     }},
    {"wlan0", %{type: VintageNetWiFi}}
  ]
```

次のようにします。

```elixir:config/target.exs
# Configure the network using vintage_net
# See https://github.com/nerves-networking/vintage_net for more information
config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"eth0", %{type: VintageNetDirect}},
    {"wlan0", %{type: VintageNetWiFi}}
  ]
```

Micro SDカードをホストに挿入し，`mix firmware.burn` として，ファームウェアを焼きます。途中，returnキーもしくは`Y`を押してreturnキーを押し，パスワード入力ウィンドウが立ち上がるので，パスワードを入れます。

```bash
hot_upload_test ❯ mix firmware.burn
==> nerves
==> nerves_system_br
Generated nerves_system_br app
==> nerves_toolchain_ctng
Compiling 1 file (.ex)
Generated nerves_toolchain_ctng app
==> nerves_toolchain_arm_unknown_linux_gnueabihf
Generated nerves_toolchain_arm_unknown_linux_gnueabihf app
==> nerves_system_rpi3
Generated nerves_system_rpi3 app
==> hot_upload_test

Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

==> ssh_subsystem_fwup
Compiling 4 files (.ex)
Generated ssh_subsystem_fwup app

(中略)

Exportable Squashfs 4.0 filesystem, gzip compressed, data block size 131072
	compressed data, compressed metadata, compressed fragments,
	compressed xattrs, compressed ids
	duplicates are removed
Filesystem size 38364.56 Kbytes (37.47 Mbytes)
	57.40% of uncompressed filesystem size (66834.86 Kbytes)
Inode table size 20529 bytes (20.05 Kbytes)
	28.25% of uncompressed inode table size (72666 bytes)
Directory table size 23922 bytes (23.36 Kbytes)
	41.86% of uncompressed directory table size (57152 bytes)
Number of duplicate files found 13
Number of inodes 2191
Number of files 1795
Number of fragments 226
Number of symbolic links  167
Number of device nodes 0
Number of fifo nodes 0
Number of socket nodes 0
Number of directories 229
Number of ids (unique uids + gids) 4
Number of uids 3
	root (0)
	zacky (501)
	_appstore (33)
Number of gids 3
	wheel (0)
	staff (20)
	_appstore (33)
Building /Users/zacky/hot_upload_test/_build/rpi3_dev/nerves/images/hot_upload_test.fw...
Use 14.48 GiB memory card found at /dev/rdisk4? [Yn] 
100% [====================================] 43.69 MB in / 46.24 MB out       
Success!
Elapsed time: 7.246 s
```

で Micro SD をターゲットに挿入してホストとターゲットをLANケーブルで接続し，Raspberry Pi の電源を入れます。しばらくしたら，`ssh nerves.local` としてログインします。この手間と時間を覚えておいてください。

```bash
hot_upload_test ❯ ssh nerves.local

Interactive Elixir (1.11.2) - press Ctrl+C to exit (type h() ENTER for help)
Toolshed imported. Run h(Toolshed) for more info.
RingLogger is collecting log messages from Elixir and Linux. To see the
messages, either attach the current IEx session to the logger:

  RingLogger.attach

or print the next messages in the log:

  RingLogger.next

iex(1)> 
```

ここで，`HotUploadTest.hello`として `:world`が返ってくることを確認し，`exit`します。

```elixir
iex(1)> HotUploadTest.hello
:world
iex(2)> exit
Connection to nerves.local closed.
```

# `mix firmware && mix upload` を試す

Nervesは標準でファームウェアのSSH経由のリプレースに対応しています。やってみましょう。

`lib/hot_upload_test.ex`の`hello`関数を次のように適当に書き換えます。

```elixir:lib/hot_upload_test.ex
  def hello do
    :new_world
  end
```

ここで `mix firmware && mix upload` とするとファームウェアをSSH経由でリプレースして再起動します。

`mix firmware`と`mix upload`の実行時間を計測して連続実行するには，次のようにします。

```bash
hot_upload_test ❯ time mix firmware > /dev/null && time mix upload > /dev/null
```


再起動すると`ping`が通るようになりますので，`ping`が開通するまでの時間を計測しましょう。次のようにすると`ping`にタイムスタンプを付与できます。

```
> ping nerves.local | while read pi; do echo "$(date '+[%Y/%m/%d %H:%M:%S]') $pi"; done
```

2つのターミナルでそれぞれ並列実行して，時刻を計測してみました。

```bash
hot_upload_test ❯ time mix firmware > /dev/null && time mix upload > /dev/null
mix firmware > /dev/null  7.95s user 3.80s system 46% cpu 25.380 total
mix upload > /dev/null  4.82s user 1.36s system 38% cpu 16.226 total
```

ここから少しタイムラグがあって，

```bash
❯ ping nerves.local | while read pi; do echo "$(date '+[%Y/%m/%d %H:%M:%S]') $pi"; done
(中略)
[2020/12/21 18:09:55] 64 bytes from 172.31.214.77: icmp_seq=43 ttl=64 time=0.312 ms
[2020/12/21 18:09:56] 64 bytes from 172.31.214.77: icmp_seq=44 ttl=64 time=0.344 ms
[2020/12/21 18:09:58] Request timeout for icmp_seq 45
[2020/12/21 18:09:59] Request timeout for icmp_seq 46
[2020/12/21 18:10:00] Request timeout for icmp_seq 47
[2020/12/21 18:10:01] Request timeout for icmp_seq 48
[2020/12/21 18:10:02] Request timeout for icmp_seq 49
[2020/12/21 18:10:03] Request timeout for icmp_seq 50
[2020/12/21 18:10:04] Request timeout for icmp_seq 51
[2020/12/21 18:10:05] Request timeout for icmp_seq 52
[2020/12/21 18:10:06] Request timeout for icmp_seq 53
[2020/12/21 18:10:07] Request timeout for icmp_seq 54
[2020/12/21 18:10:08] Request timeout for icmp_seq 55
[2020/12/21 18:10:09] Request timeout for icmp_seq 56
[2020/12/21 18:10:10] Request timeout for icmp_seq 57
[2020/12/21 18:10:11] Request timeout for icmp_seq 58
[2020/12/21 18:10:11] 64 bytes from 172.31.214.77: icmp_seq=59 ttl=64 time=0.411 ms
[2020/12/21 18:10:12] 64 bytes from 172.31.214.77: icmp_seq=60 ttl=64 time=0.254 ms
(後略)
```

こんな感じでした。

よって

|コマンド|経過時間(秒)|
|:------|---------:|
|`mix firmware`|7.95|
|`mix upload`|4.82|
|`ping`不通|約13|
|合計|約26|

実際にはタイムラグがあるので，大体30秒くらいはかかる計算になります。

# `mix_tasks_upload_hotswap`のインストール・設定

では次に `mix_tasks_upload_hotswap`をインストール・設定します。

`mix.exs`の`deps`に次の記述を足します。

```elixir:mix.exs
  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.7.0", runtime: false},
      {:shoehorn, "~> 0.7.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},
      {:mix_tasks_upload_hotswap, "~> 0.1.0", only: :dev}, # これを足す
      
      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.0", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi, "~> 1.13", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.13", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.13", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.13", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.13", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi4, "~> 1.13", runtime: false, targets: :rpi4},
      {:nerves_system_bbb, "~> 2.8", runtime: false, targets: :bbb},
      {:nerves_system_osd32mp1, "~> 0.4", runtime: false, targets: :osd32mp1},
      {:nerves_system_x86_64, "~> 1.13", runtime: false, targets: :x86_64}
    ]
  end
```

で，`mix deps.get`を実行しておきます。

```bash
hot_upload_test ❯ mix deps.get
Resolving Hex dependencies...
Dependency resolution completed:
Unchanged:
  dns 2.2.0
  elixir_make 0.6.2
  gen_state_machine 2.1.0
  mdns_lite 0.6.6
  muontrap 0.6.0
  nerves 1.7.1
  nerves_pack 0.4.1
  nerves_runtime 0.11.3
  nerves_ssh 0.2.1
  nerves_system_bbb 2.8.2
  nerves_system_br 1.13.5
  nerves_system_osd32mp1 0.4.2
  nerves_system_rpi 1.13.2
  nerves_system_rpi0 1.13.2
  nerves_system_rpi2 1.13.2
  nerves_system_rpi3 1.13.2
  nerves_system_rpi3a 1.13.2
  nerves_system_rpi4 1.13.2
  nerves_system_x86_64 1.13.3
  nerves_time 0.4.2
  nerves_toolchain_aarch64_unknown_linux_gnu 1.3.2
  nerves_toolchain_arm_unknown_linux_gnueabihf 1.3.2
  nerves_toolchain_armv6_rpi_linux_gnueabi 1.3.2
  nerves_toolchain_ctng 1.7.2
  nerves_toolchain_x86_64_unknown_linux_musl 1.3.2
  one_dhcpd 0.2.5
  ring_logger 0.8.1
  shoehorn 0.7.0
  socket 0.3.13
  ssh_subsystem_fwup 0.5.1
  system_registry 0.8.2
  toolshed 0.2.17
  uboot_env 0.3.0
  vintage_net 0.9.2
  vintage_net_direct 0.9.0
  vintage_net_ethernet 0.9.0
  vintage_net_wifi 0.9.1
New:
  mix_tasks_upload_hotswap 0.1.0
* Getting mix_tasks_upload_hotswap (Hex package)

Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

==> nerves
==> hot_upload_test
Resolving Nerves artifacts...
  Cached nerves_system_rpi3
  Cached nerves_toolchain_arm_unknown_linux_gnueabihf
```

`config/config.exs`に次の記述を足します。

```elixir:config/config.exs
config :mix_tasks_upload_hotswap,
  app_name: :hot_upload_test,
  nodes: [:"hot_upload_test@nerves.local"],
  cookie: :"secret token shared between nodes"

config :hot_upload_test, env: Mix.env()
```

`lib/hot_upload_test/application.ex`の`children(_target)`のところを次のように書き換えます。

```elixir:lib/hot_upload_test/application.ex
  def children(_target) do
    # Start a node through which local code changes are deployed
    # only when the device is running in the develop environment
    if Application.get_env(:hot_upload_test, :env) == :dev do
      System.cmd("epmd", ["-daemon"])
      Node.start(:"hot_upload_test@nerves.local")
      Node.set_cookie(Application.get_env(:mix_tasks_upload_hotswap, :cookie))
    end

    [
      # Children for all targets except host
      # Starts a worker by calling: HotUploadTest.Worker.start_link(arg)
      # {HotUploadTest.Worker, arg},
    ]
  end
```

以上について，`hot_upload_test`はこのプロジェクトのアプリ名を入れます。

ここまで設定したところで，`mix firmware && mix upload`とします。これで準備完了です。

動作を確認しましょう。`lib/hot_upload_test.ex`の`hello`関数を適当に書き換えてください。

```elixir:lib/hot_upload_test.ex
  def hello do
    :a_whole_new_world
  end
```

次に`mix upload.hotswap`とします。

```bash
hot_upload_test ❯ mix upload.hotswap
==> nerves
==> hot_upload_test

Nerves environment
  MIX_TARGET:   rpi3
  MIX_ENV:      dev

Compiling 2 files (.ex)
Generated hot_upload_test app
Successfully connected to hot_upload_test@nerves.local
Successfully deployed Elixir.HotUploadTest to hot_upload_test@nerves.local
Successfully deployed Elixir.HotUploadTest.Application to hot_upload_test@nerves.local
```

あっという間でしたね。`ssh nerves.local`で確認しましょう。

```elixir
hot_upload_test ❯ ssh nerves.local

Interactive Elixir (1.11.2) - press Ctrl+C to exit (type h() ENTER for help)
Toolshed imported. Run h(Toolshed) for more info.
RingLogger is collecting log messages from Elixir and Linux. To see the
messages, either attach the current IEx session to the logger:

  RingLogger.attach

or print the next messages in the log:

  RingLogger.next

iex(hot_upload_test@nerves.local)1> HotUploadTest.hello
:a_whole_new_world
ex(hot_upload_test@nerves.local)2> exit
Connection to nerves.local closed.
```

完璧です！

では再度書き換えて `time mix upload.hotswap > /dev/null`としましょう。

```bash
hot_upload_test ❯ time mix upload.hotswap > /dev/null                mix upload.hotswap > /dev/null  4.93s user 1.72s system 207% cpu 3.199 total
```

# 結果

|コマンド|経過時間(秒)|
|:------|---------:|
|`mix firmware`|7.95|
|`mix upload`|4.82|
|`ping`不通|約13|
|合計|約26|
これに加えて，`mix upload`から再起動までのタイムラグが数秒あります。

|コマンド|経過時間(秒)|
|:------|---------:|
|`mix upload.hotswap`|4.93|

20秒以上も短縮されました！

# おわりに

とても便利ですね！

現状，私が研究開発しているPelemayは`mix upload.hotswap`に対応していません。その理由と，どうやって対応させたらいいかについては，次の Issue に書きましたので，ご興味があればご参照ください。

https://github.com/zeam-vm/pelemay/issues/157

明日の[#NervesJP Advent Calendar 2020](https://qiita.com/advent-calendar/2020/nervesjp) 24日目の記事は， @kikuyuta さんです。お楽しみに！
