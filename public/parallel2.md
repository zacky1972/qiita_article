---
title: 並行・並列プログラミングと同期・排他制御とイミュータブル性の話〜その2「スレッドと同期・排他制御」
tags:
  - Java
  - C
  - Elixir
private: true
updated_at: '2023-12-16T08:38:14+09:00'
id: 1482c8cc091e82f0cc79
organization_url_name: null
slide: false
ignorePublish: false
---
大学の授業で講義資料を作ったので，Qiitaにも展開しておきます．

この記事シリーズでは，並行・並列プログラミングについて，要(かなめ)となる同期・排他制御の役割をCとJavaを例に簡単なプログラム例を示します．次に同期・排他制御の問題点をCのプログラム例とともに示します．そしてElixir(エリクサー)によって実現されている，全てをイミュータブルにすることによる利点について示します．

シリーズ

1. [並行・並列プログラミングと同期・排他制御とイミュータブル性の話〜その1「背景: クロック周波数の停滞とコア数の増加」]()
1. **並行・並列プログラミングと同期・排他制御とイミュータブル性の話〜その2「スレッドと同期・排他制御」**(本記事)
1. [並行・並列プログラミングと同期・排他制御とイミュータブル性の話〜その3「同期・排他制御の2つの問題点」]()
1. [並行・並列プログラミングと同期・排他制御とイミュータブル性の話〜その4「イミュータブル性の利点」]()

# スレッド

従来の普通のプログラミング(逐次プログラミングと呼びます)では，プログラム(正確には実行したい「連続した命令列」)を同時に1つしか実行できませんが，並行・並列プログラミングでは，「連続した命令列」を同時に複数実行できるようにします．このような「連続した命令列」を処理する単位のことを **スレッド(thread)** と呼びます．

一般的な並行・並列プログラミングにはスレッドという概念があり，スレッドを複数作成して同時に実行することができます．

複数のコアを持つCPU(マルチコアCPU)の時には，通常は，1つのスレッドは1つのコアで動作し，OSのカーネルやプログラミング言語処理系の働きにより，1つのコアで複数のスレッドを切り替えながら実行することが一般的です．したがって，自動で並列に実行する仕組みが備わっていないプログラミング言語では，スレッドを複数定義しないと複数あるコアを活用することはできません．

なお，x86系のマルチコアCPUの場合，ハイパースレッディングという技術が採用されており，コアの種類として，物理コアあるいは単にコアと呼ぶものと，論理コアあるいはスレッドと呼ぶものが存在します．後者のスレッドはCPUに備わっている「連続した命令列」を複数処理するハードウェアの仕組みのことです．これに対し，前述のスレッドは，OSのカーネルやプログラミング言語処理系に備わっている「連続した命令列」を複数処理するソフトウェアの仕組みのことです．この両者は，関連はしますが，基本的には別物であると捉えてください．この記事シリーズでは，スレッドをソフトウェアの仕組みである方のスレッドという意味で使います．

# 並行と並列

並行(concurrent)プログラミングも並列(parallel)プログラミングも，連続した命令列を**同時に**実行することを指します．この記事シリーズでは両者を合わせて並行・並列プログラミングと呼びます．「連続した命令列」は，多くの場合，スレッドに対応しますが，Javascriptなどで採用されているPromiseという仕組みでは，スレッドを用いずに並行プログラミングを実現しています．

並行と並列の概念の定義や厳密な違いは，[Lee and Seshia: Introduction to Embedded Systems](https://ptolemy.berkeley.edu/books/leeseshia/)の第8章に詳しく説明が書かれています．この書籍には，並行であるが並列でない場合や，並列であるが並行でない場合が存在することが示唆されています．

なお，授業の時には前までに並行と並列の定義や違いについて説明済みでしたので，本記事でも省略したいと思います．

# 同期・排他制御

並行・並列プログラミングが従来の逐次プログラミングとどのように異なるかを考えるために，コアを擬人化して，複数の人間で共同作業する状況で考えてみることにしましょう．

たとえば，複数の人間が1台のコピー機を共有して使っていて，同時に作業することを考えます．この時にはコピー機を譲り合って使用することが求められます．なぜならば，もし1人がコピーしている最中に，別の1人がコピー機を操作すると混乱が生じるからです．

**複数のスレッドが共通するデータを操作しながら計算する時**にも同じ問題が起こります．たとえば**同時にデータを操作するスレッドを1つに限定する**ようにする必要があります．このような機能を **同期(synchronization)** あるいは **排他制御(mutual exclusion)** と言います．

並行・並列プログラミングでは，さまざまな種類の同期・排他制御の機構が提供されることが一般的です．

# C言語における並行・並列プログラミング

C言語そのものには並行・並列プログラミングのための機能は，最近まで備わっていませんでした．C99以前のC言語で並行・並列プログラミングをするためには **POSIXスレッド(pthread)** のようなライブラリを利用する必要があります．C11以降になって，C言語でスレッドをサポートするようになりました．

下記は，C言語とpthreadを用いて，前述のコピー機の例題「あるスレッド(人)がコピーしている間は他のスレッド(人)が同時にコピー機を使用できない」を模したプログラミングを示しています．ただし，このプログラムは見通しを良くするためにエラー処理を記述していません．本来だと後述する`copy_p.c`のようにエラー処理を記述します．

```c:copy.c
#include <pthread.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <sys/time.h>

#define MICROSEC 1000

pthread_t tid[2]; 
int counter[2]; 
pthread_mutex_t copy_lock; 

void job(int job_no)
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

void* copy(void* arg) 
{
	int job_no = *((int *)arg);
 
	pthread_mutex_lock(&copy_lock); 

	printf("\n Job %d is copying.\n", job_no);
	job(job_no);
	printf("\n Job %d finished copying.\n", job_no);

	pthread_mutex_unlock(&copy_lock); 
	return NULL; 
} 

int main(void) 
{ 
	int i = 0; 

	pthread_mutex_init(&copy_lock, NULL);

	while (i < 2) { 
		counter[i] = i + 1;
		pthread_create(&(tid[i]), 
						NULL, 
						&copy, &counter[i]); 
		i++; 
	} 

	pthread_join(tid[0], NULL);
	pthread_join(tid[1], NULL); 
	pthread_mutex_destroy(&copy_lock); 

	return 0; 
} 
```

このプログラムをmacOS，Linux，WSLでコンパイルするには次のようにします．

```zsh
gcc copy.c -o copy -pthread
```

実行するには次のようにします．

```zsh
./copy
```

このプログラミング例は，単純そうに見えるコピー機の例題であっても，C言語による並行・並列プログラミングを行うと煩雑でわかりにくい，ということを示す例だと思ってくださると良いかと思います．よって，一応，このプログラムの詳細について説明するのですが，この記事シリーズの範囲では深く理解する必要はないです．

* `pthread_t`はスレッドを格納する構造体です．
* `pthread_create`はスレッドを生成する関数です．
    * `pthread_create(&(tid[i]), NULL, &copy, &counter[i]);`によって，`tid[i]`のスレッド構造体に，関数`copy`に`&counter[i]`を引数に渡して実行するようなスレッドを生成し，実行を開始します．
* `pthread_join`は指定したスレッドが完了するのを待って合流した後スレッドを破棄する関数です．
* `pthread_mutex_t`はmutexと呼ばれる同期・排他制御機構を格納する構造体です．
* `pthread_mutex_init`はmutex構造体を初期化する関数です．
* `pthread_mutex_destroy`はmutex構造体を破棄する関数です．
* `pthread_mutex_lock`は指定したmutexを獲得する関数です．
* `pthread_mutex_unlock`は指定したmutexを返却する関数です．
* 同じmutexに対する`pthread_mutex_lock`から`pthread_mutex_unlock`までの区間は，そのmutexを獲得した高々1つのスレッドしか同時に実行できません．このように高々1つのスレッドしか同時に実行できない区間のことを **クリティカル・セクション(critical section)** と呼びます．
* `main`関数では，スレッド`tid[0]`と`tid[1]`と，mutex`copy_lock`，そして`counter[0]`と`counter[1]`を初期化し，`tid[0]`は`&conter[0]`を，`tid[1]`は`&counter[1]`を引数として，それぞれ関数`copy`を実行します．
* `copy`関数では，`copy_thread`に対する`pthread_mutex_lock`と`pthread_mutex_unlock`によるクリティカル・セクションを形成し，その中で次の実行をします．
    * `tid[0]`の時には`"Job 1 is copying.\n"`を表示して`job`を呼び出し`"Job 1 finished copying.\n"`を表示します．
    * `tid[1]`の時には`"Job 2 is copying.\n"`を表示して`job`を呼び出し`"Job 2 finished copying.\n"`を表示します．
* `job`関数では，作業を模して，`usleep`関数を実行します．`usleep`関数は指定した数値をマイクロ秒換算してスレッドを休止します．

このプログラムのポイントは`copy`関数です．`pthread_mutex_lock`と`pthread_mutex_unlock`の間でクリティカル・セクションを形成しているので，同時に1つのスレッドしか実行できません．そのため，実行結果は次のようになります．

```

 Job 1 is copying.

 Job 1 finished copying.

 Job 2 is copying.

 Job 2 finished copying.
```

もし，`pthread_mutex_lock`と`pthread_mutex_unlock`の行を両方ともコメントアウトすると，クリティカル・セクションではなくなるので，同時に複数のスレッドが実行できるようになり，実行結果が変わります．

```

 Job 1 is copying.

 Job 2 is copying.

 Job 1 finished copying.

 Job 2 finished copying.
```

また，`pthread_mutex_lock`を呼び出してクリティカル・セクションを終える時には，必ず同じmutexに対する`pthread_mutex_unlock`を呼び出す必要があります．もし`pthread_mutex_lock`を呼びっぱなしにした状態で，別のスレッドが再度同じmutexに`pthread_mutex_lock`すると，そのスレッドは永遠に実行停止してしまいます．

`pthread_mutex_lock`と`pthread_mutex_unlock`の対応関係を維持することがプログラマにとって負担となります．

## エラー処理を記述したC言語の並行・並列プログラミング

以下に`copy.c`で省略したエラー処理を記述したプログラム`copy_p.c`を示します．実務では，エラー処理を，関数の仕様を見ながら，できるだけ真面目に記述します．ただ，エラー処理が確実に動作することを保証することは一般には難しいものです．下記のプログラム`copy_p.c`は，できるだけ真面目に記述したつもりですが，抜け穴があるかもしれません．もし抜け穴を発見した場合には，コメントにてお知らせください．

```c:copy_p.c
#include <pthread.h> 
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <sys/time.h>

#define MICROSEC 1000

pthread_t tid[2]; 

typedef struct job_s {
	int counter;
	int error_code;
} job_t;

job_t jobs[2];

pthread_mutex_t copy_lock; 

void job(int job_no)
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

void* copy(void* arg) 
{
	job_t *j = (job_t *)arg;
	int job_no = j->counter;
	int error_code = pthread_mutex_lock(&copy_lock);
	if(error_code != 0) {
		fprintf(stderr, "\n Job %d: Locking copy_lock has failed. \n", job_no);
		j->error_code = error_code;
		return (void *)j;
	}

	printf("\n Job %d is copying.\n", job_no);
	job(job_no);
	printf("\n Job %d finished copying.\n", job_no);

	error_code = pthread_mutex_unlock(&copy_lock);
	if(error_code != 0) {
		fprintf(stderr, "\n Job %d: Unlocking copy_lock has failed. \n", job_no);
		j->error_code = error_code;
		return (void *)j;
	}
	j->error_code = 0;
	return (void *)j;
} 

void join_job(pthread_t *t)
{
	void *ret;
	if(t != NULL) {
		if(pthread_join(*t, &ret) != 0) {
			fprintf(stderr, "\n Thread can't be joined\n");
		} else if (ret == NULL) {
			fprintf(stderr, "\nThread return NULL.\n");
		} else {
			job_t *j = (job_t *)ret;
			if(j->error_code != 0) {
				fprintf(stderr, "\n Thread returns error : [%s]",
					strerror(j->error_code));
			}
		}
	}
}

int main(void) 
{ 
	int error;

	if (pthread_mutex_init(&copy_lock, NULL) != 0) { 
		fprintf(stderr, "\n mutex init has failed.\n"); 
		return 1; 
	} 

	for(int i = 0; i < 2; i++) {
		jobs[i].counter = i + 1;
		error = pthread_create(&(tid[i]), 
							NULL, 
							&copy, (void *)&jobs[i]); 
		if (error != 0) {
			fprintf(stderr, "\nThread can't be created :[%s]", 
				strerror(error));
			for(int j = 0; j < i; j++) {
				join_job(&tid[j]);
			}
			if(pthread_mutex_destroy(&copy_lock) != 0) {
				fprintf(stderr, "\n mutex destory has failed. \n");
			}
			return 1;
		}
	}

	for(int i = 0; i < 2; i++) {
		join_job(&tid[i]);
	}

	if(pthread_mutex_destroy(&copy_lock) != 0) {
		fprintf(stderr, "\n mutex destory has failed. \n");
	}

	return 0; 
} 
```


# Javaにおける並行・並列プログラミング

オブジェクト指向プログラミング言語であるJavaには，並行・並列プログラミング機構が標準で備わっています．Javaで前述のようなコピー機の例題を模したプログラム例を示します．

```java:copy.java
import java.io.*; 
import java.util.*; 

class Copy
{
    void job(int counter)
    {
        /*
         * 実際の処理を書くところであるが，
	     * 差し当たり何もしないで100ミリ秒待つThread.sleep関数を記述する
	     */
        try {
            Thread.sleep(100);
        } catch(InterruptedException e) {
            System.err.println("Job " + counter + " is interrpted sleeping.");
        }
    }

    public synchronized void copy(int counter)
    {
        System.out.println("Job " + counter + " is copying.");
        job(counter);
        System.out.println("Job " + counter + " finished copying.");
    }
}

class CopyThread extends Thread
{
    int counter;
    Copy c;

    public CopyThread(Copy c, int counter)
    {
        this.c = c;
        this.counter = counter;
    }

    public void run()
    {
        c.copy(counter);
    }
}

class CopyDemo
{
    public static void main(String args[])
    {
        Copy c = new Copy();
        CopyThread t1 = new CopyThread(c, 1);
        CopyThread t2 = new CopyThread(c, 2);

        t1.start();
        t2.start();
    }
}
```

コンパイルは次のようにします．

```zsh
javac copy.java
```

実行は次のようにします．

```zsh
java CopyDemo
```

プログラムのポイントは次の2つです．

* `extends Thread`もしくは`implements Runnable`としたクラスを定義することで，スレッドを持つオブジェクトを作成できる
* メソッドに`synchronized`をつけることで，そのオブジェクトに対し，そのメソッドの中をクリティカル・セクションとするような同期・排他制御を容易に行える．この同期・排他制御機構をモニタ(monitor)と呼ぶ．

C言語に比べて，Javaだと並行・並列プログラミングがだいぶ容易になります．

# この記事のまとめ

* コアが増えた時に性能向上させるには，並行・並列プログラミングが不可欠
* 普通のプログラミング(逐次プログラミング)では，プログラム(正確には「連続した命令列」)を同時に1つしか実行できない
* **スレッド(thread)**は，連続した命令列を実行する単位の一種である．
* 並行・並列プログラミングでは，スレッドを同時に複数実行できる
* 自動で並列に実行する仕組みが備わっていないプログラミング言語では，スレッドを複数定義しないと複数あるコアを活用することはできない
    * ※なお，スレッドを用いないで並行プログラミングを実現するPromiseでは複数あるコアを活用することはできません．
* 複数の人間が1台のコピー機を使って同時に作業する時には，コピー機を譲り合って使用することが求められる
    * もし1人がコピーしている最中に，別の1人がコピー機を操作すると，混乱する
* 複数のスレッドが共通するデータを操作しながら計算する時にも同じ問題が起こる
* そのため，たとえば同時にデータを操作するスレッドを1つに限定するようにする必要がある
* このような機構を**同期・排他制御**と呼ぶ

このように並行・並列プログラミングにおいて，同期・排他制御は重要な役割を演じるのですが，問題点があります．そのことについて次の記事で紹介します．

