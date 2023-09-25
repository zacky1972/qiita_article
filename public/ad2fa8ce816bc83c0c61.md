---
title: CPU Info を開発している時にわかった Nerves 対応のコツ
tags:
  - Elixir
  - Nerves
private: false
updated_at: '2019-12-12T01:22:15+09:00'
id: ad2fa8ce816bc83c0c61
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
この記事は[「#NervesJP Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/nervesjp)5日目の記事です。

昨日は[「Pelemayを開発している時にわかった Nerves 対応のコツ」](https://qiita.com/zacky1972/items/b2beeeb5fd8689faba84)でした。今日も Nerves 対応のコツについてご紹介します。

# Nerves 対応のコツその2: 外部コマンドを極力使わない

当初，CPU Info では，下記のウェブサイトの方針にしたがい，外部コマンドを使って CPU の情報を取得していました。

[物理 CPU、CPU コア、および論理 CPU の数を確認する https://access.redhat.com/ja/solutions/2159401](https://access.redhat.com/ja/solutions/2159401)

また，`uname` を使ってカーネル情報を取得していました。

結果，下記の外部コマンドを使用していました。

* `cat`
* `grep`
* `sort`
* `wc`
* `uname`

ところが，Nerves ではこれらの外部コマンドはデフォルトで備わっていません。その理由は，ファームイメージのサイズを小さくするためだと思います。

そこで，これらの外部コマンドを用いず，Elixir で同等機能を実装してあげました。

## カーネルのリリース番号 (`uname -r`)

```elixir
    kernel_release = case File.read("/proc/sys/kernel/osrelease") do
      {:ok, result} -> result
      _ -> nil
    end
```

## カーネルバージョン (`uname -v`)

```elixir
    kernel_version = case File.read("/proc/sys/kernel/version") do
      {:ok, result} -> result
      _ -> nil
    end
```

## CPU タイプ (`uname -m`)

```elixir
    cpu_type =
      :erlang.system_info(:system_architecture) |> List.to_string() |> String.split("-") |> hd
```

## CPU モデル (`grep model.name /proc/cpuinfo | sort -u`)

```elixir
    info =
      File.read!("/proc/cpuinfo")
      |> String.split("\n\n")
      # drop last (emtpy) item
      |> Enum.reverse()
      |> tl()
      |> Enum.reverse()
      |> Enum.map(fn cpuinfo ->
        String.split(cpuinfo, "\n")
        |> Enum.map(fn item ->
          [k | v] = String.split(item, ~r"\t+: ")
          {k, v}
        end)
        |> Map.new()
      end)

    cpu_models = Enum.map(info, &Map.get(&1, "model name")) |> List.flatten()

    cpu_model = hd(cpu_models)
```

## CPU の数 (`grep physical.id /proc/cpuinfo | sort -u | wc -l`)

```elixir
    # info は CPU モデルと共通　

    num_of_processors =
      Enum.map(info, &Map.get(&1, "physical id"))
      |> Enum.uniq()
      |> Enum.count()
```

## CPU1つあたりのコア数 (`grep cpu.cores /proc/cpuinfo | sort -u`)，全コア数

```elixir
    # num_of_processors は共通

    t =
      Enum.map(info, &Map.get(&1, "cpu cores"))
      |> Enum.uniq()
      |> Enum.reject(& is_nil(&1))
      |> Enum.map(&(&1 |> hd |> String.to_integer()))
      |> Enum.sum()
    total_num_of_cores = if t == 0, do: 1, else: t

    num_of_cores_of_a_processor = div(total_num_of_cores, num_of_processors)
```

## 全スレッド数 (`grep processor /proc/cpuinfo | wc -l`)

```elixir
    total_num_of_threads =
      Enum.map(info, &Map.get(&1, "processor"))
      |> Enum.count()
```

# Nerves 対応のコツその3: `/etc/os-release` でディストリビューション情報を取る

Nerves でディストリビューション情報を取るときには，`/etc/issue` は存在しないので使えません。代わりに `/etc/os-release` を用います。

## システムバージョン (`cat /etc/issue`)

```elixir
    os_info = File.read!("/etc/os-release")
    |> String.split("\n")
    |> Enum.reverse |> tl |> Enum.reverse
    |> Enum.map(& String.split(&1, "="))
    |> Enum.map(fn [k, v] -> {k, v |> String.trim("\"")} end)
    |> Map.new()

    system_version = Map.get(os_info, "PRETTY_NAME")
```

# おわりに

Nerves では通常の Linux と色々異なるので注意が必要という話でした。

明日は @Yoosuke さんの[「Nerves と GraphQLsever の組み合わせを考える「ポエム」」](https://qiita.com/Yoosuke/items/50fc77bf8230109cfa88)です。よろしくお願いします。

次も[「#NervesJP Advent Calendar 2019」](https://qiita.com/advent-calendar/2019/nervesjp)12日目に[Nerves の可能性は IoT だけじゃない(前編)〜ElixirとPelemayで世界の消費電力を抑える](https://qiita.com/zacky1972/items/2c82a593fbb2e4c949d2)をお送りします。お楽しみに。

