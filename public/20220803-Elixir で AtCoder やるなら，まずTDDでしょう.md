---
title: Elixir で AtCoder やるなら，まずTDDでしょう
tags:
  - TDD
  - AtCoder
  - Elixir
private: false
updated_at: '2022-11-07T14:21:02+09:00'
id: 93b6edbe86399d60a90e
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
elixir.jp Slackで質問があったので，AtCoderの問題をElixirで解く初体験をしました．その体験はとても良好で，大学生向けのプログラミング演習課題としてとても良くできているなと思いました．

体験したのは次の問題でした．

https://atcoder.jp/contests/abc262/tasks/abc262_b

さて，この体験を通じて得られた知見を，いくつかの記事に分けてまとめていこうと思います．最初の知見は，AtCoderをテスト駆動開発(Test-Driven Development: TDD)スタイルで解くという方法のElixir版です．ElixirにはTDDのための仕組みが用意されているので，簡単にTDDを導入できます．

さて，先ほどの問題には，次のように入力例と出力例が3つ添付されています．下記は入力例1と出力例1です．

```txt:入力例1
5 6
1 5
4 5
2 3
1 4
3 5
2 5
```

```txt:出力例1
2
```

ElixirによるTDDを導入すると，この入力例を与えたときに出力例通りの出力が得られることを`mix test`というコマンドを実行することで簡単に確認することができます．例えば次のような感じです！

```zsh
% mix test
...

Finished in 2.8 seconds (0.00s async, 2.8s sync)
3 tests, 0 failures

Randomized with seed 567197
```
この出力例は，3つの入力例を与えたとき(3 tests)に，それぞれ得られた出力が出力例通りである(`0 failures` すなわち，失敗がなかった)ということを意味しています．

単に簡単に確認できるだけにとどまりません．アルゴリズムの改良を行いコードの修正をおこなったとしても，`mix test`とするだけで，アルゴリズムの振る舞いが変化していないことを確認することができるのです！

これは便利でしょう？ さっそくやってみましょう！

# 1. AtCoderのElixirプロジェクトの新規作成

Elixirは既にインストールされているものとします．

AtCoderをElixirで解く場合には，`Main`というモジュールの`main`という関数を実装します．したがって，AtCoderのElixirプロジェクトを新規作成するときには，次のコマンドを入力します．

```zsh
mix new main
```

こうすると，カレントディレクトリの下に，mainというディレクトリが作成され，そこにAtCoderのElixirプロジェクトが新規作成されます．

次のコマンドを入力しディレクトリをプロジェクトに移動します．

```zsh
cd main
```

ここでみなさんがお使いのエディタを起動しておくと良いでしょう．

# 2. 不要な`hello`関数を除去する

`lib/main.ex`がソースコードなのですが，最初に雛形として，次のように`hello`関数が作成されます．

```elixir:lib/main.ex
defmodule Main do
  @moduledoc """
  Documentation for `Main`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Main.hello()
      :world

  """
  def hello do
    :world
  end
end
```

ここで先ほど紹介したテスト実行コマンド `mix test` を実行すると次のようになります．

```zsh
main % mix test
Compiling 1 file (.ex)
Generated main app
..

Finished in 0.01 seconds (0.00s async, 0.01s sync)
1 doctest, 1 test, 0 failures

Randomized with seed 152439
```

`1 doctest, 1 test, 0 failures`の部分が緑色に着色されていますね．これは全てのテストがパスしたことを意味します．この状態をよく`GREEN`と呼びます．

`1 doctest`というのは，`lib/main.ex`中にある次のドキュメントの部分をテストだとみなして実行しています．これをDocTestと言います．

```elixir
  @doc """
  Hello world.

  ## Examples

      iex> Main.hello()
      :world

  """
```

この`iex> Main.hello()`という部分は，`Main.hello()`を実行したときに，という意味で，その後の`:world`は実行結果を表しています．

このDocTestという機能もとても使い勝手が良いので，機会あれば使ってみてください．

では，`lib/main.ex`から`hello`関数を取り除いて次のようにしてみてください．

```elixir:lib/main.ex
defmodule Main do
  @moduledoc """
  Documentation for `Main`.
  """
end
```

なお，この`@moduledoc`の部分も取り除いても良いです．これは，この`Main`モジュールの説明を記述するのに使う部分です．`defmodule Main do ... end`は取り除かないでくださいね．

では，この状態で `mix test`を実行してみてください．

```zsh
% mix test
Compiling 1 file (.ex)
warning: Main.hello/0 is undefined or private
  test/main_test.exs:6: MainTest."test greets the world"/1



  1) test greets the world (MainTest)
     test/main_test.exs:5
     ** (UndefinedFunctionError) function Main.hello/0 is undefined or private
     code: assert Main.hello() == :world
     stacktrace:
       (main 0.1.0) Main.hello()
       test/main_test.exs:6: (test)



Finished in 0.02 seconds (0.00s async, 0.02s sync)
1 test, 1 failure

Randomized with seed 163987
```

ところどころ赤文字で出力されました．これは，いくつかのテストに失敗したことを意味します．`1 test, 1 failure`というのは，1つテストをしたら1つ失敗したということを意味します．赤文字で表示されるので，`RED`状態と呼びます．

具体的にどのように失敗したのかが，下記に書かれています．

```elixir
  1) test greets the world (MainTest)
     test/main_test.exs:5
     ** (UndefinedFunctionError) function Main.hello/0 is undefined or private
     code: assert Main.hello() == :world
     stacktrace:
       (main 0.1.0) Main.hello()
       test/main_test.exs:6: (test)
```

英語で書かれているエラーメッセージを読んでみると，`Main.hello`関数が定義されていないというエラーが出ていますね．それはさっき削除したので当然の結果なのですが，それが原因でテストで失敗するのは困ります．

これは`test/main_test.exs`の6行目に書かれていると，最後の1文に出ていますね．ではそのファイルを開いて見てみましょう．

```elixir:test/main_test.exs
defmodule MainTest do
  use ExUnit.Case
  doctest Main

  test "greets the world" do
    assert Main.hello() == :world
  end
end
```

このファイルが，今回の主題TDDの主役となる自動テストのコードです．

`doctest Main`と書かれている部分が，先ほど説明したDocTestを実行する部分です．ここでは，`Main`モジュールのDocTestを実行するという意味になります．

次の部分に注目してください．

```elixir
  test "greets the world" do
    assert Main.hello() == :world
  end
```

ここで`Main.hello()`を呼び出していることがわかりますね．このように自動テストを記述するのです．

では，この部分を削除してしまいましょう．そしてその後，`mix test`を実行してください．

```elixir:test/main_test.exs
defmodule MainTest do
  use ExUnit.Case
  doctest Main
end
```

```zsh
% mix test


Finished in 0.01 seconds (0.00s async, 0.01s sync)
0 failures

Randomized with seed 666471
```

これでGREEN状態に戻りましたね．

# 3. 入力例1と出力例1をテストするコードを記述する

ここからがいよいよ本題です．

まず準備として，`mkdir test/support`といったコマンドを実行するなどをして，`test/support`ディレクトリを作成してください．Elixirでテストをするときに必要な補助ファイルはこのように`test/support`に配置するという

次に，先ほどの入力例1をコピーして

```txt:入力例1
5 6
1 5
4 5
2 3
1 4
3 5
2 5
```

次のように`test/support/input1.txt`というファイルに保存します．

```txt:test/support/input1.txt
5 6
1 5
4 5
2 3
1 4
3 5
2 5
```

これで下準備はできました．

では，`test/main_test.exs`に次のように記述してください．

```elixir:test/main_test.exs
defmodule MainTest do
  use ExUnit.Case
  doctest Main

  test "main input1" do
    assert :os.cmd('cat test/support/input1.txt| mix run -e "Main.main()"') == '2\n'
  end
end
```

20221107追記: Windows(not WSL)の人は，次のように記述してください．

```elixir:test/main_test.exs
defmodule MainTest do
  use ExUnit.Case
  doctest Main

  test "main input1" do
    assert :os.cmd('type test\\support\\input1.txt| mix run -e "Main.main()"') == '2\n'
  end
end
```


このテストコードを説明します．

まず，`test "main input1" do ... end`によって，テストの例を1つ作成し，名称として "main input1" という名称をつけます．`mix test`でこのテストが失敗したときには，この名称"main input1"というのが表示されるので，どのテストが失敗したのかを特定しやすくなります．したがって，一意にわかりやすい名称をつける必要があります．ここでは，`main`関数に`input1`を与えた場合，というような意味合いでつけました．

次の`assert ... == ...`というのは，`==`を挟む左辺と右辺が等しい場合にこのテストがパスし，等しくない場合には，このテストを失敗させるという記述です．

そして，ここからが肝なのですが，AtCoderのElixir版では，`Main`モジュールの`main`関数を実行し，その際に標準入力に入力データを与えて，結果を標準出力で表示する，というルールになっています．そこで，`cat test/support/input1.txt| ...`とすることで，先ほどの作成した入力例1のファイルを標準出力に表示し，UNIXシェルのパイプで繋いで次のコマンドの標準入力として与えることにします．

次に，先ほどの`...`の部分で，Elixirの`Main`モジュールの`main`関数を実行すれば良いわけです．それを表すのが`mix run -e "Main.main()"`という記述です．

で，この`cat test/support/input1.txt| mix run -e "Main.main()"`をUNIXシェルで実行してあげるのですが，それを行うのが，`:os.cmd('...')`という関数になります．これはErlangで提供されている関数です．似たような関数としては，`System.cmd`というElixirが提供する関数もあるのですが，残念ながら`System.cmd`関数では，UNIXシェルのパイプを含むコマンドを実行することができないという制約があります．そのため，`:os.cmd('...')`という関数を利用します．歴史上の経緯で，Erlangの関数に文字列を渡す場合には，`'...'`というようにシングルクォートで囲みます．これはErlangの文字列であることを意味します．

以上をまとめると，左辺に書かれているのは，`:os.cmd('cat test/support/input1.txt| mix run -e "Main.main()"')`という関数呼び出しで，意味としては，UNIXシェルを起動して入力例1を標準入力として与えながら，このElixirプロジェクトの`Main`モジュールの`main`関数を呼び出す，ということになります．

この出力結果を右辺に書くわけなのですが，今回は出力例1である`2`を1行表示するだけなので，`'2\n'`と書きます．これはErlangの文字列で，`2`と改行`\n`を表します．

# 4. テストを実行して，テストが機能していることを確認する


では，`mix test`を実行してみましょう．

```elixir
% mix test                               
Compiling 1 file (.ex)
Generated main app


  1) test main input1 (MainTest)
     test/main_test.exs:5
     Assertion with == failed
     code:  assert :os.cmd('cat test/support/input1.txt| mix run -e "Main.main()"') == '2\n'
     left:  'Compiling 1 file (.ex)\nGenerated main app\n** (UndefinedFunctionError) function Main.main/0 is undefined or private\n    (main 0.1.0) Main.main()\n    (stdlib 4.0.1) erl_eval.erl:744: :erl_eval.do_apply/7\n    (elixir 1.13.4) lib/code.ex:404: Code.validated_eval_string/3\n    (elixir 1.13.4) lib/enum.ex:937: Enum."-each/2-lists^foreach/1-0-"/2\n    (mix 1.13.4) lib/mix/tasks/run.ex:142: Mix.Tasks.Run.run/5\n    (mix 1.13.4) lib/mix/tasks/run.ex:86: Mix.Tasks.Run.run/1\n'
     right: '2\n'
     stacktrace:
       test/main_test.exs:6: (test)



Finished in 0.8 seconds (0.00s async, 0.8s sync)
1 test, 1 failure

Randomized with seed 468273
```

テストが失敗してRED状態になりましたね．

詳細にみていくと，まず`1) test main input1 (MainTest)`と表示しているので，`main_test.exs`の`"main input1"`のテストだとわかります．

次に`test/main_test.exs:5`と表示されているので，`test/main_test.exs`の5行目で失敗していることがわかります．

次の`Assertion with == failed`は，`assert ... == ...`が失敗しているという意味です．

次の`left:  '...'`は読みにくいのですが，入力例1を与えて実行した結果がErlangの文字列として表されています．実際には次のような出力結果が得られたことを意味します．

```txt
Compiling 1 file (.ex)
Generated main app
** (UndefinedFunctionError) function Main.main/0 is undefined or private
    (main 0.1.0) Main.main()
    (stdlib 4.0.1) erl_eval.erl:744: :erl_eval.do_apply/7
    (elixir 1.13.4) lib/code.ex:404: Code.validated_eval_string/3
    (elixir 1.13.4) lib/enum.ex:937: Enum."-each/2-lists^foreach/1-0-"/2
    (mix 1.13.4) lib/mix/tasks/run.ex:142: Mix.Tasks.Run.run/5
    (mix 1.13.4) lib/mix/tasks/run.ex:86: Mix.Tasks.Run.run/1
```

その次の`right: '2\n'`は期待している出力は`2`であることを意味します．

この左辺(left)，よくみると，`Compiling 1 file (.ex)`も含んでいますね．これは表示されないこともあるのですが，Elixirの`mix`コマンドが実行を開始するにあたってコンパイルを実行したという経過メッセージです．これがあると正しい出力結果が得られた場合にもテストが失敗してしまいます．これはまずいので，後でこの問題を修正する方法を提示します．

さて，この左辺のメッセージが何を意味するのかというと，`Main.main()`関数が存在しないということを意味しています．まだ何も作っていないのだから当たり前ですね．

でもこのように`Main.main()`関数が定義されていないときにテストがちゃんと失敗してくれるのか，自動テストが機能しているのかを確認することに大きな意義があります．もし失敗するはずのテストが成功してしまうようであれば，テストの仕方に問題があるということになりますから．

# 5. テストがパスする最小限のコードを書き，テストがパスすることを確認する

ではテストがパスする最小限のコードを書いてみましょう．例えば，`Main`モジュールに`main`関数を定義し，標準入力を読み捨てて，標準出力に`2`を出力して終了する，とすれば，パスしそうですね．

```elixir:lib/main.ex
defmodule Main do
  @moduledoc """
  Documentation for `Main`.
  """

  def main() do
    IO.read(:all)
    IO.puts("2")
  end
end
```

では，`mix test`です．

```zsh
% mix test 
Compiling 1 file (.ex)


  1) test main input1 (MainTest)
     test/main_test.exs:5
     Assertion with == failed
     code:  assert :os.cmd('cat test/support/input1.txt| mix run -e "Main.main()"') == '2\n'
     left:  'Compiling 1 file (.ex)\n2\n'
     right: '2\n'
     stacktrace:
       test/main_test.exs:6: (test)



Finished in 0.7 seconds (0.00s async, 0.7s sync)
1 test, 1 failure

Randomized with seed 92785
```

懸念したように，`Compiling 1 file (.ex)`というメッセージに邪魔されてテストがパスしませんでした．

しかしもう一度実行するとテストがパスします．

```zsh
% mix test
.

Finished in 0.7 seconds (0.00s async, 0.7s sync)
1 test, 0 failures

Randomized with seed 440876
```

`mix clean`を実行してから，`mix test`を実行すると，またRED状態が再発します．

先にこれを解消することをおこなっておきましょうかね．

# 6. 自動テストを実行する前に，あらかじめ`mix compile`を実行しておく

`Compiling 1 file (.ex)`というメッセージに邪魔されてテストがパスしなくなる問題は，自動テストを実行する前にあらかじめ`mix compile`を実行すれば解消されます．

Elixirの自動テストを実行する前に何かを実行させたいときには，`setup_all`関数をテストコードに実装します．例えば次のようにするのはどうでしょうか？

```elixir:test/main_test.exs
defmodule MainTest do
  use ExUnit.Case
  doctest Main

  setup_all %{} do
    :os.cmd('mix compile')
    :ok
  end

  test "main input1" do
    assert :os.cmd('cat test/support/input1.txt| mix run -e "Main.main()"') == '2\n'
  end
end
```

では，`mix clean`の後に`mix test`を実行してみましょう．

```zsh
% mix clean
% mix test
Compiling 1 file (.ex)
Generated main app
.

Finished in 1.5 seconds (0.00s async, 1.5s sync)
1 test, 0 failures

Randomized with seed 406182
```

これで問題は解消されました！

# 7. 3の要領で，入力例2,3と出力例2,3をテストするコードを記述する

手順はわかりますよね？ テストの名称を入力例に合わせて変更するのを忘れないようにしてくださいね．

# 8. テストを実行して，RED状態になることを確認する

`mix test`を実行すると，RED状態になります．当たり前です．`lib/main.ex`では入力に関して何も処理せずに標準出力に決まった値を出力するだけなので．

もしこれでRED状態にならなかったとしたら，追加したテストが機能していないことを意味します．テストコードに誤りがあるか，入力例と出力例が今までのと重複しているかではないでしょうか．その場合，問題を修正して，RED状態になることを確認します．

# 9. 実装する

これで準備が整ったので，おもむろに実装を開始します．

以上の説明のように，RED状態とGREEN状態を行き来しながら，テンポ良く実装していくというのがTDDの醍醐味です．

途中の実装の過程で，内部処理に関してテストを書きたくなることもあるかと思います．そのときにはDocTestが役に立つかもしれません．また今まで説明してきた方法をもとにしてテストを書くこともできます．

一旦実装した後では，高速化のためにコードを改良することに専念できます．もし改良に不具合があった場合でも，テストによって検出することができます．






























