//main.c

/**
 * The main program for finding eigenvalues and eigenvectors of a program.
 * Author: Dai Bui
 */

#include <stdio.h>

#include <stdlib.h>
#include <lapack.h>

#include "timer.h"

extern void eigenVV(double* x, int n, int lapack);
extern double* loadmat(char *fname, int* n, int* m);

#define COL_MAJOR(i,j, col_len) ((j) * (col_len) + i)
#define ROW_MAJOR(i,j, row_len) ((i) * (row_len) + j)
#define LOC(i,j, ld) COL_MAJOR(i,j, ld)

int main(int argc, char** argv)
{
    int n, p;
    int lapack = 0;
    char* fname = "mymat.dat";

    if (argc > 1)
    {
        fname = argv[1];
    }
    if (argc > 2)
    {
        if (argv[2][0] == 'l')
            lapack = 1;
        else if (argv[2][0] == 'g')
            lapack = 0;
        else if (argv[2][0] == 'd')
            lapack = 2;
        else
        {
            printf(
                    "Invalid second option  ...\
                    \n\t\'g\' for using Gram - Schmidt orthogonalization\
                    \n\t\'l\' for LAPACK routines with QR iterations\
                    \n\t\'d\' for using LAPACK DSYEV to compute\n");
            exit(0);
        }
    }

    double* x = loadmat(fname, &n, &p);

    TIME0;
    if (lapack == 1 || lapack == 0)
    {
        eigenVV(x, n, lapack);
    }
    else if (lapack == 2)
    {
        printf("Using LAPACK DSYEV to computer eigenvalues and eigenvectors\n\n");
        int lwork = 32 * n;
        int info;
        int i;
        double* work = (double*) calloc(lwork, sizeof(double));
        double* w = (double*) calloc(n, sizeof(double));

        dsyev("V", "U", &n, x, &n, w, work, &lwork, &info);
        for (i = 0; i < n; i++)
        {
            int j;
            printf("Eigenvector for eigenvalue %lf:\n", w[i]);
            for (j = 0; j < n; j++)
            {
                printf("%10lf\t", x[i*n+j]);
            }
            printf("\n\n");
        }
        free(w);
        free(work);
    }
    TIME1("Total computation time");
    free(x);
    return 0;
}
