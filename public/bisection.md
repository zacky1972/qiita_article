---
title: 2分法をElixirで実装してみた
tags:
  - Elixir
private: false
updated_at: '2023-12-27T09:11:20+09:00'
id: fb7e8de1455bb194f769
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
授業で教えている2分法をElixirで実装してみましたので，報告します．

## 解答例

```elixir
fn f, {a, b}, e ->
  if f.(a) * f.(b) < 0 do
    Stream.unfold({a, b}, fn
      {a, b} ->
        c = (a + b) / 2.0

        if f.(a) * f.(c) < 0 do
          {{a, c}, {a, c}}
        else
          {{c, b}, {c, b}}
        end
    end)
    |> Stream.drop_while(fn {a, b} -> abs(a - b) / 2 > e end)
    |> Enum.take(1)
    |> hd()
    |> elem(0)
    |> then(&Tuple.append({:ok}, &1))
  else
    {:error, "Solution is not found."}
  end
end
```

