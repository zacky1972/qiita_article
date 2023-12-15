---
title: 並行・並列プログラミングと同期・排他制御とイミュータブル性の話〜その3「同期・排他制御の2つの問題点」
tags:
  - C
  - Elixir
private: true
updated_at: '2023-12-16T08:38:14+09:00'
id: b34077c59784b6cfb71a
organization_url_name: null
slide: false
ignorePublish: false
---
大学の授業で講義資料を作ったので，Qiitaにも展開しておきます．

この記事シリーズでは，並行・並列プログラミングについて，要(かなめ)となる同期・排他制御の役割をCとJavaを例に簡単なプログラム例を示します．次に同期・排他制御の問題点をCのプログラム例とともに示します．そしてElixir(エリクサー)によって実現されている，全てをイミュータブルにすることによる利点について示します．

シリーズ

1. [並行・並列プログラミングと同期・排他制御とイミュータブル性の話〜その1「背景: クロック周波数の停滞とコア数の増加」]()
1. [並行・並列プログラミングと同期・排他制御とイミュータブル性の話〜その2「スレッドと同期・排他制御」]()
1. **並行・並列プログラミングと同期・排他制御とイミュータブル性の話〜その3「同期・排他制御の2つの問題点」**(本記事)
1. [並行・並列プログラミングと同期・排他制御とイミュータブル性の話〜その4「イミュータブル性の利点」]()

# 同期・排他制御の2つの問題点

[前回の記事]()に示したように，並行・並列プログラミングにおいて，同期・排他制御は重要な役割を演じます．

しかしこの記事では，**同期・排他制御には不利益がある**という話をします．次の2つの問題点があります．

1. デッドロックの問題
1. 性能低下の問題

以下でそれぞれ見ていきましょう．

## デッドロックの問題

[前回の記事](#同期排他制御)では，コアを擬人化して，「複数の人間が1台のコピー機を共有して使っていて，同時に作業する」という，複数の人間で共同作業する状況で考えてみることをしました．

今度のコピー機は，スキャナーとプリンターに分かれているものとしましょう．そうすると次のような利用シーンが考えられます．

* スキャナーだけを利用する人と，プリンターだけを利用する人が，同時に利用することができるようにしたい
* スキャナーを利用する人が複数いる場合，プリンターを利用する人が複数いる場合は，それぞれ譲り合って使用するようにしたい
* スキャナーとプリンターの両方を利用してコピーをしている時には，スキャナーもプリンターも他の人は同時に利用することがないようにしたい

ところが，このようにすると次のような問題が起きます．

1. ある人Aがスキャナーを先に利用してからプリンターを後から利用する順番でプリントしようとしたとする
1. かつ別の人Bがプリンターを先に利用してからスキャナーを後から利用する順番でプリントしようとしたとする
1. この2人が同時に利用しようとしたとした時に，次の状態に陥ることがある
    1. Aがスキャナーを利用し，Bがプリンターを利用したとする
    1. 次の手順で，Aがプリンターを利用しようとした時には，Bがすでに利用しているので利用できない
    1. 同様に，Bがスキャナーを利用した時にはAがすでにプリンターを利用しているので利用できない

このような状態を **デッドロック(deadlock)** といいます．

もちろん，人間であれば，AとBがお互い利用していることを認識して，譲り合うことができるでしょう．しかし，mutexを利用したプログラムでそのようにプログラミングすることは通常しません．なぜならば，譲り合うために，すでに行った処理を元に戻す処理を記述する必要があり，そのように元に戻す処理を一般に書くことは難しいからです．

なお，現実に同期・排他制御を用いる並行プログラミングを行う場合には，このような設計ではなく，スキャンしたいという要請とプリントしたいという要請，スキャンとプリントを同時にしたいという要請を，それぞれ受けて統合して調停するようなモジュールを作成する方法の方が妥当です．このように，同期・排他制御を単純に用いる場合ではデッドロックに陥ることがあっても，設計を工夫することでデッドロックを回避できる場合があります．

一方で，デッドロックの問題の回避が困難である場合もあります．[前の記事]()で紹介した[Lee and Seshia: Introduction to Embedded Systems](https://ptolemy.berkeley.edu/books/leeseshia/)の第8章ではそのような例も描かれているので，興味があれば参照してください．

### C言語プログラミング例

下記は，C言語とpthreadを用いて，前述のスキャナーとプリンターの例題を模したプログラミングを示しています．このプログラムではエラー処理を省略しています．実務では[前の記事に示したエラー処理を含むプログラム](https://qiita.com/zacky1972/items/bbf1f7bdecbbd0492151#エラー処理を記述したc言語の並行並列プログラミング)に準じてエラー処理を丁寧に記述する必要がある点に注意してください．

```c:copy2.c
#include <pthread.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <sys/time.h>

#define MICROSEC 1000

pthread_t tid[2]; 
int counter[2]; 
pthread_mutex_t scanner_lock; 
pthread_mutex_t printer_lock; 

void job_scanning(int job_no)
{
	/*
	 * 実際の処理を書くところであるが，
	 * 差し当たり何もしないで100マイクロ秒待つようにnanosleep関数を記述する
	 */
	struct timespec req = {0, 100 * MICROSEC};
	if(nanosleep(&req, NULL) != 0) {
		fprintf(stderr, "\n Job %d: error when nanosleep.\n", job_no);	
	}
	return;
}

void job_printing(int job_no)
{
	/*
	 * 実際の処理を書くところであるが，
	 * 差し当たり何もしないで100マイクロ秒待つようにnanosleep関数を記述する
	 */
	struct timespec req = {0, 100 * MICROSEC};
	if(nanosleep(&req, NULL) != 0) {
		fprintf(stderr, "\n Job %d: error when nanosleep.\n", job_no);	
	}
	return;
}

void job_copying(int job_no)
{
	/*
	 * 実際の処理を書くところであるが，
	 * 差し当たり何もしないで100マイクロ秒待つようにnanosleep関数を記述する
	 */
	struct timespec req = {0, 100 * MICROSEC};
	if(nanosleep(&req, NULL) != 0) {
		fprintf(stderr, "\n Job %d: error when nanosleep.\n", job_no);	
	}
	return;
}

void* copy_a(void* arg) 
{
	int job_no = *((int *)arg);
	pthread_mutex_lock(&scanner_lock);
	printf("\n Job %d gets scanner.\n", job_no);
	job_scanning(job_no);
	printf("\n Job %d finished scanning.\n", job_no);

	pthread_mutex_lock(&printer_lock);
	printf("\n Job %d gets printer.\n", job_no);

	printf("\n Job %d is copying.\n", job_no);
	job_copying(job_no);
	printf("\n Job %d finished copying.\n", job_no);

	pthread_mutex_unlock(&printer_lock); 
	pthread_mutex_unlock(&scanner_lock); 
	return NULL; 
} 

void* copy_b(void* arg) 
{
	int job_no = *((int *)arg);
	pthread_mutex_lock(&printer_lock);
	printf("\n Job %d gets printer.\n", job_no);
	job_printing(job_no);
	printf("\n Job %d finished printing.\n", job_no);

	pthread_mutex_lock(&scanner_lock);
	printf("\n Job %d gets scanner.\n", job_no);

	printf("\n Job %d is copying.\n", job_no);
	job_copying(job_no);
	printf("\n Job %d finished copying.\n", job_no);

	pthread_mutex_unlock(&scanner_lock); 
	pthread_mutex_unlock(&printer_lock); 
	return NULL; 
} 

int main(void) 
{ 
	int error; 

	pthread_mutex_init(&scanner_lock, NULL);

	pthread_mutex_init(&printer_lock, NULL);

	counter[0] = 1;
	pthread_create(&(tid[0]), 
					NULL, 
					&copy_a, &counter[0]); 

	counter[1] = 2;
	pthread_create(&(tid[1]), 
					NULL, 
					&copy_b, &counter[1]); 

	pthread_join(tid[0], NULL);
	pthread_join(tid[1], NULL); 
	pthread_mutex_destroy(&scanner_lock); 
	pthread_mutex_destroy(&printer_lock); 

	return 0; 
} 
```

このプログラムをmacOS，Linux，WSLでコンパイルするには次のようにします．

```zsh
gcc copy2.c -o copy2 -pthread
```

実行するには次のようにします．ただし，デッドロックして実行が停止してしまうので，CTRL+Cで強制終了してください．

```zsh
./copy2
```

このプログラム例では，関数`copy_a`はスキャナーのmutexを獲得してからプリンターのmutexを獲得しており，関数`copy_b`はプリンターのmutexを獲得してからスキャナーのmutexを獲得しています．

なお，このプログラム例では単純化のため，mutexのみを用いて実装しましたが，pthreadをすでに知っている人であれば，condition variableを用いたらどうなるか？に興味があるかもしれません．結論を言えば，condition variableを用いたとしても，同様にデッドロックに陥ります．

## 性能低下の問題

次に挙げる問題は，同期・排他制御による性能低下の問題です．

次の図のように複数のコアでデータを共有していると仮定します．なお，図ではコアが2つの場合を示していますが，コアがより多く存在しても同様の問題が起きます．

![cores_share_data.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/2d94a89d-ffe9-678b-8663-011c40534f85.png)

次の図のように，あるコアが共有データを上書きするとします(破壊的更新)．この時に複数のコアで矛盾がないようにするためには同期・排他制御を行う必要があります．これは同期・排他制御によって，他のコアに通知する際に処理を止めるということを意味します．これが実行速度低下につながり，性能が低下します．この現象は，コア数が多くなれば多くなるほど深刻なものになることは想像がつくかと思います．

![core_notify_other_cores.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/55223/cab2fba3-50bf-7f71-ed8b-b144496b544b.png)

# まとめ

同期・排他制御は，並行・並列プログラミングにおいて重要な役割を演じます．しかし，同期・排他制御を含む並行・並列プログラミングでは，次の2つの問題が起こります．

* デッドロックの問題
* 性能低下の問題

次の記事でこれらの問題をElixirではどのように解決しているのかについて説明します．



