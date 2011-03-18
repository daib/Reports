#include <stdio.h>

#include <stdlib.h>

extern void eigenVV(double* x, int n);
extern double* loadmat(char *fname, int* n, int* m);

#define COL_MAJOR(i,j, col_len) ((j) * (col_len) + i)
#define ROW_MAJOR(i,j, row_len) ((i) * (row_len) + j)
#define LOC(i,j, ld) COL_MAJOR(i,j, ld)

int main(int argc, char** argv)
{
    int n, p;
    char* fname = "mymat.dat";

    if (argc > 1)
    {
        fname = argv[1];
    }

    double* x = loadmat(fname, &n, &p);

    eigenVV(x, n);

    free(x);
    return 1;
}
