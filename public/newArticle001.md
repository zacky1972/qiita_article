---
title: リストをStream化する
tags:
  - Elixir
private: false
updated_at: '2023-12-30T12:51:46+09:00'
id: 72eacdd66a3452d9280d
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
有限長のリストを，あたかも無限長のStreamであるかのように扱いたい時があったので，実装してみたところ，うまくいきましたので，ご報告します．

## 実装例

```elixir
fn list, default_value ->
  Stream.unfold(list, fn
    [] -> {default_value, []}
    [h | t] -> {h, t}
  end)
end
```

## 使用例

```elixir
iex> f = 
...>   fn list, default_value ->
...>     Stream.unfold(list, fn
...>       [] -> {default_value, []}
...>       [h | t] -> {h, t}
...>     end)
...>   end
#Function<41.105768164/2 in :erl_eval.expr/6>
iex> s = f.([1, 2], 0)
#Function<63.53678557/2 in Stream.unfold/2>
iex> Enum.take(s, 10)
[1, 2, 0, 0, 0, 0, 0, 0, 0, 0]
iex> 
```
