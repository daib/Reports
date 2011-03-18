//gs.c

#include <math.h>
#define LOC(a,b)  ((b) * p + (a))

/*  
 function gs performs a Gram - Schmidt orthogonalization
 of an n x p matrix, x.  The orthogonal (q) part of the
 decomposition is returned in x, and the lower triangular
 part in r.  (Both x and r must be allocated by the calling
 program, and r should be filled with zeroes.)  The matrix
 x is assumed to be stored by columns.
 */

void gs(x, r, n, p)
    double *x, *r;long n, p;
{
    long i, j, k;
    double t;
    double *xnow;

    for (j = 0; j < p; j++)
    {
        t = 0.;
        xnow = x + j * n;
        for (i = 0; i < n; i++, xnow++)
            t += *xnow * *xnow;
        t = sqrt(t);
        r[LOC(j,j)] = t;
        xnow = x + j * n;

        for (i = 0; i < n; i++, xnow++)
            *xnow /= t;
        for (k = j + 1; k < p; k++)
        {
            t = 0;
            for (i = 0; i < n; i++)
                t += x[j * n + i] * x[k * n + i];
            r[LOC(j,k)] = t;
            for (i = 0; i < n; i++)
                x[k * n + i] -= t * x[j * n + i];
        }
    }
}
