---
title: 初 LAPACK！で DGELS (QR 分解もしくは LQ 分解)による最小二乗法を実装してみた
tags:
  - C
  - LAPACK
private: false
updated_at: '2020-05-04T21:38:42+09:00'
id: 15bef7dcd0c2d2abe60d
organization_url_name: fukuokaex
slide: false
ignorePublish: false
---
# LAPACK インストール

## HomeBrew (macOS)

```bash
$ brew install lapack
```

そのあと，次の環境変数にそれぞれ追加します。

```bash
CFLAGS = $CFLAGS -I/usr/local/opt/lapack/include
CPPFLAGS = $CPPFLAGS -I/usr/local/opt/lapack/include
LDFLAGS = $LDFLAGS -L/usr/local/opt/lapack/lib
```

## apt (Ubuntu)

```bash
$ apt install liblapack-dev
```

環境変数はメモし忘れました。

# 最小二乗法プログラム

```c:lsm.c
#include <stdlib.h>
#include <stdio.h>
#ifdef __linux__
  #include <lapacke.h>
#else
  #include <lapack.h>
#endif

void dgels(char *trans, 
  lapack_int *m, lapack_int *n, lapack_int *nrhs,
  double *a, lapack_int *lda,
  double *b, lapack_int *ldb,
  double *work, lapack_int *lwork,
  lapack_int *info )
{
  LAPACK_dgels(trans, m, n, nrhs, a, lda, b, ldb, work, lwork, info);
}

extern void print_matrix(char *description, int m, int n, double *a, int lda);

int max(const int m, const int n)
{
  if (m > n) {
    return m;
  } else {
    return n;
  }
}

int min(const int m, const int n)
{
  if (m < n) {
    return m;
  } else {
    return n;
  }
}

int main() {
  char *trans = "No transpose";
  int m = 5;
  int n = 2;
  int nrhs = 1;

  int lda = max(1, m);
  int ldb = max(max(1, m), n);
  int lwork = max(1, min(m, n) + max(min(m, n), nrhs));
  int info;

  // double work[max(1, lwork)];
  double *work;
  work = (double *)malloc(sizeof(double) * max(1, lwork));

  // double a[m * n];
  double *a;
  a = (double *)malloc(sizeof(double) * m * n);

  // double b[m];
  double *b;
  b = (double *)malloc(sizeof(double) * m);

  a[0] = 1;
  a[1] = 1;
  a[2] = 1;
  a[3] = 1;
  a[4] = 1;

  a[5] = 50.0;
  a[6] = 60.0;
  a[7] = 70.0;
  a[8] = 80.0;
  a[9] = 90.0;

  b[0] = 40.0;
  b[1] = 70.0;
  b[2] = 90.0;
  b[3] = 60.0;
  b[4] = 100.0;

  print_matrix("a" , m, n, a, lda);
  print_matrix("b" , m, 1, b, ldb);

  dgels( "No transpose", &m, &n, &nrhs, 
    a, &lda, b, &ldb, work, &lwork,
    &info );

  if(info > 0) {
    /*
     * a の三角因子の info で示される対角要素が 0 であるため，
     * a は最大階数を持たない。
     * すなわち最小二乗法は計算できない。
     */
    exit(1);
  }

  // print_matrix("a" , m, n, a, lda);
  print_matrix("the least squares", n, nrhs, b, ldb);

  return 0;
}

void print_matrix(char* description, int m, int n, double* a, int lda)
{
  int i, j;
  printf("\n %s\n", description);
  for(i = 0; i < m; i++) {
    for(j = 0; j < n; j++) {
      printf(" %6.2f", a[i + j * lda]);
    }
    printf("\n");
  }
}
```

# コンパイル方法

```bash
$ cc $CFLAGS lsm.c -o lsm $LDFLAGS -llapack
```

# 実行方法

```bash
$ ./lsm
```

# 実行結果

```

 a
   1.00  50.00
   1.00  60.00
   1.00  70.00
   1.00  80.00
   1.00  90.00

 b
  40.00
  70.00
  90.00
  60.00
 100.00

 the least squares
  -5.00
   1.10
```

`y = ax + b` に対して，`a = 1.10, b = -5.00` ということです。

計算速度とかは求めていません。

# 参考文献

最初に見つけた DGELS のプログラム例です。

* https://software.intel.com/sites/products/documentation/doclib/mkl_sa/11/mkl_lapack_examples/dgels_ex.c.htm

最初に見つけた DGELS で最小二乗法をしているプログラム例です。ただし三次元でした。

* http://icl.cs.utk.edu/lapack-forum/viewtopic.php?f=2&t=772

最終的なデータはここから取りました。

* https://sci-pursuit.com/math/statistics/least-square-method.html
