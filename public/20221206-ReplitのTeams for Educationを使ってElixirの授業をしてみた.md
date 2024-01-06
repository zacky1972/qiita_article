---
title: ReplitのTeams for Educationを使ってElixirの授業をしてみた
tags:
  - Elixir
  - 教育
private: false
updated_at: '2022-12-06T02:02:15+09:00'
id: a9afb1c411202d0cd160
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
Replitは複数人でコラボレーションできるブラウザ上で動作するIDEです．

下記のReplitのトップページを表示して下へスクロールさせてみてください．SF好きの人は気に入ると思います．(Replitにログインしている人は一度ログアウトして試してください)

https://replit.com

Teams for EducationはReplitの教育向けソリューションです．
 
https://replit.com/site/teams-for-education

さっそく試して授業で活用してみましたので報告します．

ログインするとサイドバーに次のように出ます．

![Replitサイドバー](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/a5187dda-c515-cdaa-b442-619121526744.png)

Teamsを選択します．すると右側のメイン画面に次のように出ます．

![My Teams / Education](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/1a5de70e-098b-2aef-cf90-9ed0e8d6a9d1.png)

"+ New Education Organization"を選択します．すると次の画面が出ます．

![New Education Organization](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/f98b5007-bbae-3d90-8fab-882d32054765.png)

"Organization name"には組織名を入れます．またその後の選択肢については，私の場合は，大学に勤務していて，大学の授業で使うので，Higher Educationを選択しました．みなさんの場合は，みなさんの状況に合わせて適切な選択肢を選んでください．最後のチェックボックスは，その記載事項(下記)を認める場合にチェックを入れます(虚偽申告はやめましょう)．

> I confirm that I am using Teams for Education for educational purposes.
> 
> 教育目的で Teams for Education を使用していることを私は認めます．

全てが合っていることを確認したら，"Create New Organization"ボタンを押します．

私の場合は，勤務校である北九州市立大学(Univ. of Kitakyushu)で作成しました．下記のスクリーンショットではすでに2つのチームを作っています．チームを作るときには "New team in Univ. of Kitakyushu"を選択します．

![Univ. of Kitakyushu](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/f4d389d9-8aae-d8e1-acee-29c6870d1a32.png)

私はチームを1つの学年の1つの授業の単位であると解釈して，"ProgrammingTheory2022"(「プログラミング論」という授業の2022年度版という意味で命名しました)を作成しました．またそれに先立ち，研究室学生でテストする目的で"zackylab2022"というチームを作成しています．

チームを作成した後，単元(unit)を設定します．単元は1つの授業内容を表します．下記のメニューの中の右側の"+"ボタンを押すと，単元を作ることができます．

![メニュー](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/f1dea4cf-5f79-3872-c1bf-f48dd5bbec14.png)

単元の名前を入れて作成します．

![単元の作成](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/943507ea-2d04-25da-e44a-7994d41b5d17.png)

単元の中にプロジェクトを作ります．プロジェクトは1つのプログラミング演習です．プロジェクトを作るには下記のメニューの左側の"Create project"を押します．

![メニュー](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/f1dea4cf-5f79-3872-c1bf-f48dd5bbec14.png)

プロジェクトの作成画面は下記のとおりです．Languagesを選択すると実に様々なプログラミング言語を選択できます．ここではElixirの授業を作るので，Elixirを選択します．Titleにはプログラミング演習のタイトルを，Descriptionにはプログラミング演習がどのようなものなのかを簡潔に書きます．Descriptionは140文字以内で書かないといけない点に注意してください．なので，詳細な仕様を書く場合には，次の画面に進んでプログラム中にコメントとして記載します．Unitには先ほど作成した単元の中からプロジェクトを配置したい単元を選びます．グループ課題にする場合には，Group projectを有効にします(まだ使ったことがないです)．これらを設定したら，Createを押します．

![プロジェクトの作成](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/d7f58cb4-e474-c412-4563-9ed25bec79a0.png)

プロジェクトを新規作成すると次のようになります．左側のサイドバーにはファイルとツールが表示されています．中央には`main.exs`が配置されています．右側のサイドバーにはConsoleやShellが表示されています．


![プロジェクト(新規作成状態)](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/6e745739-09d4-ed6e-6222-691f8743e7a1.png)

私の授業「プログラミング論」では例えば次のようにプログラミング演習の1つの課題を与えてみました．このようにコメントを使って使用を与えるのがわかりやすいなと思いました．サイドバーのAdd Lesson contentsを使う方法もありそうですが，まだよく調べていません．

![Enum.mapの応用](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/9af18940-ef20-5b57-4e57-0ef097bb56ff.png)

テストについては，左のサイドバーのToolsの中から☑️マークのTestsを選びます．

![プロジェクト(新規作成状態)](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/6e745739-09d4-ed6e-6222-691f8743e7a1.png)

Elixirでは残念ながら単体テスト(Unit tests)を作ることができず，Input output testsのみの選択となります．今後のアップデートに期待します．

![テスト作成](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/15d47560-93f6-b874-70f1-8a2e05a18af3.png)

Input/Output Testsでは，標準入力に与える入力データと標準出力から得られる出力データの組をテストケースとして与えます．下記では既に2つのテストケースを作成した後の画面です．Create Testでテストデータを作成し，Run testsで全てのテストケースを実行した結果を出力します．

![I/Oテスト](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/8cbd0a3b-1ba9-9098-9e0d-fae18631dbfc.png)

Create Testを押すと次のような画面になります．テスト名，標準入力に与える入力データ，期待される出力結果を入れて，テスト方法を選択します．

![テスト作成](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/d5705ae8-91bd-ae83-c23e-b6c25dd54ed4.png)

テスト方法の選択肢は下記のとおりです．私の場合はexactを選びました．

![テスト方法の選択肢](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/1add4981-953d-c142-52be-a1cb707a1f06.png)

実際のテストデータの例です．入力と出力の冒頭の1は，1行目ということを意味します．その後に入力データや出力データが続きます．

![テストデータの例](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/d35c4e20-d4dd-5f3a-2b9f-d5ef1e2c4208.png)

Run testsでテストを実行するとこんな感じです．最初は実装していないので，このようにFailedになります．

![テスト結果(失敗，全体)](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/6fd24c29-8b8d-7ec9-418d-08029f1fe635.png)

Resultsを押して個別のテスト結果を次のようになります．最初は実装していないので，Actual output(実際の出力結果)に"Interactive Elixir 〜"が出力されています．

![テスト結果(失敗，個別)](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/a9469927-bebe-56bc-357c-1091e50069b6.png)

もし下記のように表示される場合には，`main.exs`のファイルが存在しないことを意味します．

![テスト結果(main.exsが存在しない場合)](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/c5a6a3d5-9a70-e185-b089-d766d85fe6e7.png)

下記の左側のサイドバーのFilesに`main.exs`が存在するか，また編集している中央の画面が`main.exs`になっているかを確認します．

![プロジェクト(新規作成状態)](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/6e745739-09d4-ed6e-6222-691f8743e7a1.png)

実装が仕上がって，テストに成功すると次のように表示されます．

![テスト結果(成功，全体)](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/2150da3c-9d1f-bc40-1071-3fe70b979e81.png)

教材を編集し終えたら，下記の全体画面の右上の"Publish project"を押します．

![プロジェクト(新規作成状態)](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/6e745739-09d4-ed6e-6222-691f8743e7a1.png)

受講生の登録は，チームの画面に戻ってから，下記"Manage team members"ボタンを押します．

![チームメンバーの管理](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/b8b9cf71-3e7e-08d3-695c-ea736378c64a.png)

ここでは画面を示しませんが，メンバーの招待(Invite)，個々のチームメンバーの管理，招待リンクの生成，CSVテンプレートのダウンロード，CSVファイルでのインポート，Google Classroom経由の招待ができます．

CSVファイルでインポートをしたのですが，70名以上の登録をした際に，数名の取りこぼしが発生したようでした．具体的には招待状は送られたのですが，Joinしてアカウントを作成・登録してもチームが表示されないという不具合がありました．その場合は，個別に招待しなおすと，登録できました．

使ってみた感触としては，テストで受講生がプログラムの動作を確認できるというのは大きな利点になると思いました．また，ログイン中の受講生の画面を表示して，同じ画面を見ながらペアプログラミングするということもできるようなので，個別指導に向いていると思いました．ただ，今回行ったような70名以上もの受講生がいる状況だと，該当する受講生を探すのに困難を感じました．

単体テストができるともっと幅が広がるだろうと思います．またMixプロジェクトを読み込めるようにできると良いなと思いました．今後に期待です．
