---
title: 除算を用いない剰余計算アルゴリズムCrandall Reductionについて
tags:
  - アルゴリズム
  - Elixir
  - 数学
  - 暗号
  - 剰余
private: false
updated_at: '2025-07-15T12:29:51+09:00'
id: e99d14a71dd9cf57f588
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
除算を用いない剰余計算アルゴリズムであるCrandall Reductionについて調べて、Elixirで実装しました。

## Crandall Reductionについて

$p = 2^k + c$の場合の$x\mod p$を、除算を用いずに計算するアルゴリズムです。

初出はRichard E. Crandallが1991年9月17日に出願して1992年10月27日に特許取得した[US5159632A特許 "METHOD AND APPARATUS FOR PUBLIC KEY EXCHANGE IN A CRYPTOGRAPHIC SYSTEM"](https://patentimages.storage.googleapis.com/11/9b/b8/75aa2cab01785d/US5159632.pdf)(暗号システムにおける公開鍵交換の方法および装置)なのだそうです。米国特許は出願日から20年が標準的な有効期間(米国現行法では出願から20年、その改正の端境期に当たる特許については、1995.6.8時点で有効な特許は、出願から20年と、登録から17年の遅く満了する方が有効期間となります)なのだそうなので、本特許は有効期限切れになっています。

## Elixirでの実装

https://github.com/zacky1972/crandall_reduction

本質的には次のようなコードになります。ご覧の通り、ビット演算と加減算、定数倍乗算、条件分岐で構成されており、除算を用いていません。なお、この実装では、`a`, `mask`, `p`を先行して計算した上で関数を生成することで、`a`, `mask`, `p`の定数畳込みを行っています。ここで登場する乗算は定数`c`倍なので、コード最適化を適用すると、論理・シフト演算に置換することができるはずです。

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

