#include "math.h"
#include <stdio.h>
#include <stdlib.h>

#define MAX(a,b)  ((a)>(b)?(a):(b))

doarma(xd, a, b, n, p, q, lik)
    double *xd, *a, *b, *lik;int *n, *p, *q;
{
    armalk(xd, a, b, *n, *p, *q, lik);
}

armalk(xd, a, b, n, p, q, lik)
    double *xd, *a, *b, *lik;int n, p, q;
{
    long i, j, k, upd, nit = 0;
    long r, np, nrbar, ifault;
    float sumlog, ssq, delta = 0.01;
    float *v, *aa, *pp, *resid, *e;
    float *thetab, *xnext, *xrow, *rbar, *alpha, *beta, *x;
    float *fmalloc();
    double parms[100];

    r = MAX(p,q + 1);
    np = (r * (r + 1)) / 2;
    nrbar = (np * (np - 1)) / 2;

    alpha = fmalloc(r);
    for (i = 0; i < r; i++)
        alpha[i] = i < p ? (float) a[i] : 0.;
    beta = fmalloc(r);
    for (i = 0; i < r; i++)
        beta[i] = i < q ? (float) b[i] : 0.;

    x = fmalloc(n);
    for (i = 0; i < n; i++)
        x[i] = (float) xd[i];

    thetab = fmalloc(np);
    xnext = fmalloc(np);
    xrow = fmalloc(np);
    rbar = fmalloc(nrbar);

    k = 0;
    for (i = 0; i < p; i++)
        parms[k++] = a[i];
    for (i = 0; i < q; i++)
        parms[k++] = b[i];

    if (chkparms(parms, p, q))
    {
        *lik = 1E-8;
        return;
    }

    v = fmalloc(np);
    aa = fmalloc(r);
    pp = fmalloc(np);

    //preparation
    if (p == 1 && q == 0)
    {
        upd = 0;
        *v = 1.;
        *aa = 0.;
        *pp = 1 / (1 - alpha[0] * alpha[0]);
    }
    else
    {
        upd = 1;
        starma_(&p, &q, &r, &np, alpha, beta, aa, pp, v, thetab, xnext, xrow,
                rbar, &nrbar, &ifault);
        if (ifault)
            printf("after starma, ifault=%d\n", ifault);
    }

    //    printf("after starma, alpha=");
    //    for (i = 0; i < r; i++)
    //        printf(" %g", alpha[i]);
    //    printf("\n              beta=");
    //    for (i = 0; i < r; i++)
    //        printf(" %g", beta[i]);
    //    printf("\n");

    resid = fmalloc(n);
    e = fmalloc(r);
    ssq = sumlog = 0.;
    karma_(&p, &q, &r, &np, alpha, beta, aa, pp, v, &n, x, resid, &sumlog,
            &ssq, &upd, &delta, e, &nit);

    //    printf("sumlog=%f ssq=%f\n", sumlog, ssq);

    *lik = (double) (sumlog * (sumlog != sumlog) ? 0 : 1) + (double) n * log(
            (double) ssq) * ((ssq != ssq) ? 0 : 1);

    free(alpha);
    free(beta);
    free(x);
    free(thetab);
    free(xnext);
    free(xrow);
    free(rbar);
    free(v);
    free(aa);
    free(pp);
    free(resid);
    free(e);
}

float *fmalloc(n)
    long n;
{
    float *x;

    if ((x = (float*) malloc((n * sizeof(float)))) == NULL)
    {
        fprintf(stderr, "Error in fmalloc, request was for %ld bytes.\n", n
                * sizeof(float));
        exit(1);
    }

    return (x);
}

/*
 routine chkparms does a quick check on the validity of
 parameters for an ARMA model.

 input:
 parms      double*       vector of length p+q containing
 the p AR coefficients followed by the
 q MA coefficients
 p          int           order of the AR process
 q          int           order of the MA process

 output:
 returns  0 if the parameters appear ok, 1 if they are bad
 */
chkparms(parms, p, q)
    double *parms;int p, q;
{
    int i, bad;
    double d;

    bad = 0;
    for (i = 0; i < p && bad == 0; i++)
    {
        d = (double) choose(p, i + 1);
        if (fabs(parms[i]) >= d)
            bad = 1;
    }

    for (i = 0; i < q && bad == 0; i++)
    {
        d = (double) choose(q, i + 1);
        if (fabs(parms[p + i]) > d)
            bad = 1;
    }

    return (bad);
}

int choose(n, m)
    int n, m;
{
    int i, c;

    if ((m >= n) || (m <= 0))
        return (1);

    if (m < n - m)
        m = n - m;
    for (i = m + 1, c = 1; i <= n; i++)
        c *= i;
    c /= factorial(n - m);
    return (c);
}
/* factorial number function - only suitable for 
 small values of n (for larger values use a sum
 of logs and exponentiate at the end */

int factorial(n)
    int n;
{
    int i, f;

    if (n < 2)
        return (1);
    for (i = 2, f = 1; i <= n; i++)
        f *= i;
    return (f);
}

