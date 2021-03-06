#include <stdio.h>
#include <stdlib.h>
#include <lapack.h>
#include <blas.h>
#include <math.h>

// multiply matrix a (n x m) with matrix b (m x p) to matrix c (n x p)
#define COL_MAJOR(i,j, col_len) ((j) * (col_len) + i)
#define ROW_MAJOR(i,j, row_len) ((i) * (row_len) + j)
#define LOC(i,j, ld) COL_MAJOR(i, j, ld)

extern void gs(double* x, double* r, long n, long p);

#define TOLERANCE   1e-8

//matrix multiplication routine
void matmul(double *a, double* b, double* c, int n, int m, int p)
{
    int i, j, k;
    double total;

    for (i = 0; i < n; i++)
    {
        for (k = 0; k < p; k++)
        {
            total = 0;
            for (j = 0; j < m; j++)
            {
                total += (a[LOC(i, j, m)] * b[LOC(j, k, p)]);
            }
            c[LOC(i, k, p)] = total;
        }
    }
}

//copy upper triangle of a matrix
void upcopy(double* a, double* b, int n)
{
    int i, j;
    for (i = 0; i < n; i++)
    {
        for (j = i; j < n; j++)
        {
            b[LOC(i, j, n)] = a[LOC(i, j, n)];
        }
    }

}

//copy all matrix
void copy(double* a, double* b, int n, int m)
{
    int i, j;
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < m; j++)
        {
            b[LOC(i, j, n)] = a[LOC(i, j, n)];
        }
    }
}

//print the whole matrix
void printMat(double* x, int n, int m)
{
    int i, j;
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < m; j++)
        {
            printf("  %e\t", x[LOC(i, j, n)]);
        }
        printf("\n");
    }

    printf("\n");
}

//find eigen values of a symetric matrix a of size n x n

/*
 tst = x
 while 1
 tst = x * tst;
 [q,r] = qr(tst);
 if sum(sum(abs(triu(r,1)))) < 1.e-8
 break
 end
 tst = q;
 end;
 */

void eigenVV(double* x, int n)
{
    int i, j, k;
    double ratio;

    double *q = (double*) calloc(n * n, sizeof(double));
    double *r = (double*) calloc(n * n, sizeof(double));
    double* storeMatrix = (double*) calloc(n * n, sizeof(double));
    double* ev = (double*) calloc(n, sizeof(double));

    //store the matrix to use for finding eigenvectors
    copy(x, storeMatrix, n, n);

    int count = 0;

    printf("\n QR iteration\n\n");
    while (count++ <= 100)
    {
        //qr decomposition

        //dgeqrf(&n, &n, x, &n, tau, work, &ldwork, &info);

        //copy the upper part of x to r
        //upcopy(x, r, n);

        //reconstruct q
        //dorgqr(&n, &n, &n, x, &n, tau, work, &ldwork, &info);

        gs(x, r, n, n);

        //check the convergence condition
        double sum = 0;
        for (i = 0; i < n; i++)
        {

            for (j = i + 1; j < n; j++)
            {
                sum += fabs(r[LOC(i, j, n)]);
            }

        }

        //printf("%d-th iteration current error %e\n", count, sum);

        //copy the q part of x to q
        copy(x, q, n, n);

        matmul(r, q, x, n, n, n);

        if (sum < TOLERANCE)
            break;

    }

    printMat(x, n, n);

    //store the result
    copy(x, r, n, n);

    printf("\nFinding eigenvectors\n");

    //for each eigenvalue
    for (k = 0; k < n; k++)
    {
        copy(storeMatrix, x, n, n);

        for (i = 0; i < n; i++)
        {
            x[LOC(i,i,n)] -= r[LOC(k,k,n)];
        }

        //        printMat(x, n, n);

        // Gaussian elimination
        for (i = 0; i < (n - 1); i++)
        {
            for (j = (i + 1); j < n; j++)
            {
                ratio = x[LOC(j, i, n)] / x[LOC(i, i, n)];
                for (count = i; count < n; count++)
                {
                    x[LOC(j, count, n)] -= (ratio * x[LOC(i,count, n)]);
                }
            }
        }

        //        printMat(x, n, n);

        // Back substitution
        ev[n - 1] = 1;
        for (i = (n - 2); i >= 0; i--)
        {
            double temp = 0;
            for (j = (i + 1); j < n; j++)
            {
                temp -= (x[LOC(i,j,n)] * ev[j]);
            }
            ev[i] = temp / x[LOC(i,i,n)];
        }
        printf("Eigenvector for eigenvalue %lf:\n", r[LOC(k,k,n)]);
        for (i = 0; i < n; i++)
        {
            printf("%10lf\t", ev[i]);
        }
        printf("\n");
        matmul(storeMatrix, ev, x, n, n, 1);
        for (i = 0; i < n; i++)
        {
            printf("%10lf\t", x[i]);
        }
        printf("\n\n");
    }

    printf("\n");

    free(q);
    free(r);
    free(storeMatrix);
    free(ev);
}

