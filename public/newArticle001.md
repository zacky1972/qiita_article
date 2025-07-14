---
title: 除算を用いない剰余計算アルゴリズムCrandall Reductionについて
tags:
  - Elixir
  - 数学
  - 剰余
  - 暗号
  - アルゴリズム
private: false
updated_at: ''
id: null
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
除算を用いない剰余計算アルゴリズムであるCrandall Reductionについて調べて、Elixirで実装しました。

## Crandall Reductionについて

$p = 2^k + c$の場合の$x\mod p$を、除算を用いずに計算するアルゴリズムです。

初出はRichard E. Crandallが1991年9月17日に出願して1992年10月27日に特許取得した[US5159632A特許 "METHOD AND APPARATUS FOR PUBLIC KEY EXCHANGE IN A CRYPTOGRAPHIC SYSTEM"](https://patentimages.storage.googleapis.com/11/9b/b8/75aa2cab01785d/US5159632.pdf)(暗号システムにおける公開鍵交換の方法および装置)なのだそうです。米国特許は出願日から20年が標準的な有効期間なのだそうなので、本特許は期限切れになっている可能性が高いようです。

## Elixirでの実装

https://github.com/zacky1972/crandall_reduction

本質的には次のようなコードになります。ご覧の通り、ビット演算と加減乗算、条件分岐で構成されており、除算を用いていません。なお、この実装では、`a`, `mask`, `p`を先行して計算した上で関数を生成することで、`a`, `mask`, `p`の定数畳込みを行っています。

```elixir
fn k, c ->
  a = Bitwise.bsl(1, k)
  mask = a - 1
  p = a + c

  fn x ->
    low = Bitwise.band(x, mask)
    high = Bitwise.bsr(x, k)
    r = low - high * c
    if r >= p, do: r - p, else: r
  end
end
```

## 使用例

```elixir
{p, reducer} = CrandallReduction.of(255, -19)

result = reducer.(123456789)
# => 123456789
result = reducer.(p + 123456789)
# => 123456789
```

エドワーズ曲線デジタル署名アルゴリズムの1つである、Ed25519で用いられている、$p = 2^{255} - 19$の場合を計算しています。

