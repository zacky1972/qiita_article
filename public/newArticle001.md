---
title: SME日記その8 __arm_new("za")について調べる
tags:
  - assembly
  - M4
  - AppleSilicon
  - SME
private: false
updated_at: ''
id: null
organization_url_name: null
slide: false
ignorePublish: false
---
[ArmのScalable Matrix Extension (SME)を試す](https://zenn.dev/mod_poppo/articles/arm-scalable-matrix-extension)で示されているSMEによる行列乗算を実行するには，`__arm_new("za")`に相応する前処理・後処理を行う必要があるので，`__arm_new("za")`について，ドキュメントを読んでみました．

SMEシリーズ

- [Apple Silicon M4はM3シリーズからScalable Matrix Extension (SME)命令などが足されている](https://qiita.com/zacky1972/items/69fd802fd41ae4d7d469)
- [SME日記その1: Apple Silicon M4に搭載されたScalable Matrix Extension(SME)のベクトル長(SVL)を取得する](https://qiita.com/zacky1972/items/231fd22a1fdef15d4108)
- [SME日記その2: Apple Silicon M4にはCVTW命令は備わっていない？](https://qiita.com/zacky1972/items/a4fc98614df085586175)
- [SME日記その3: Apple Silicon M4にどの命令が実装されているかをsysctl hwの実行結果とドキュメントから推測する](https://qiita.com/zacky1972/items/427035001554cb9768bc)
- [SME日記その4 Streaming SVE modeでCNTWを実行してみる．](https://qiita.com/zacky1972/items/3182fa1693983846205d)
- [SME日記その5 Streaming SVE modeでCNTWを実行してみる Part 2](https://qiita.com/zacky1972/items/b7b5dd456fe021b30eb2)
- [SME日記その6 Streaming SVE modeでsvcntw()とsvcntsw()を実行してみる](https://qiita.com/zacky1972/items/7d4ec630d54564ebb9b3)
- [SME日記その7 svcntw()とRDSVL命令の実行結果の関係性を考察する](https://qiita.com/zacky1972/items/48cf7577e254b8c3a0b6)

## `__arm_new("za")`に関するドキュメント

https://clang.llvm.org/docs/AttributeReference.html#arm-new

> __arm_new
> 
> Supported Syntaxes
> 
> * GNU
> * C++11
> * C23
> * `__declspec`
> 
> Keyword
> 
> * `#pragma`
> 
> HLSL Annotation
>
> `#pragma clang attribute`
> 
> `__arm_new`
>
> The `__arm_new` keyword applies to function declarations and specifies that the function will create a new scope for state S.
> 
> The attribute takes string arguments to instruct the compiler for which state to create new scope. The supported states for S are:
> 
> * `"za"` for Matrix Storage (requires SME)
> 
> For state `"za"`, this means that:
> 
> * the function requires that the target processor implements the Scalable Matrix Extension (SME).
> * the function will commit any lazily saved ZA data.
> * the function will create a new ZA context and enable PSTATE.ZA.
> * the function will disable PSTATE.ZA (by setting it to 0) before returning.
>
> For `__arm_new("za")` functions Clang will set up the ZA context automatically on entry to the function and disable it before returning. For example, if ZA is in a dormant state Clang will generate the code to commit a lazy-save and set up a new ZA state before executing user code.
> 
> `__arm_new` キーワードは関数宣言に適用され、関数が状態 S の新しいスコープを作成することを指定します。
>
> この属性は、どの状態に対して新しいスコープを作成するかをコンパイラに指示する文字列引数を取ります。S でサポートされている状態は次のとおりです。
>
> * マトリックス ストレージの場合は `"za"` (SME が必要)
>
> 状態 `"za"` の場合、次のようになります。
>
> * 関数では、ターゲット プロセッサが Scalable Matrix Extension (SME) を実装している必要があります。
> * 関数は、遅延保存された ZA データをコミットします。
> * 関数は新しい ZA コンテキストを作成し、PSTATE.ZA を有効にします。
> * 関数は、戻る前に PSTATE.ZA を無効にします (0 に設定)。
>
> `__arm_new("za")` 関数の場合、Clang は関数に入るときに ZA コンテキストを自動的に設定し、戻る前に無効にします。たとえば、ZA が休止状態にある場合、Clang は遅延保存をコミットし、ユーザー コードを実行する前に新しい ZA 状態を設定するためのコードを生成します。

## 考察と将来課題

そうすると，次の処理それぞれをどのように行うかを調べれば良さそうです．

> * 関数は、遅延保存された ZA データをコミットします。
> * 関数は新しい ZA コンテキストを作成し、PSTATE.ZA を有効にします。
> * 関数は、戻る前に PSTATE.ZA を無効にします (0 に設定)。

次にこれらについて調べていきます．