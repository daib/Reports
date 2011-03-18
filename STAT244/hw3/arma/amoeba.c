#include <math.h>
#define NRANSI
#include "nrutil.h"
#define NMAX 50000
#define GET_PSUM for (j=0;j<ndim;j++) {for (sum=0.0,i=0;i<mpts;i++) sum += p[i][j]; psum[j]=sum;}
#define SWAP(a,b) {swap=(a);(a)=(b);(b)=swap;}

double amotry(double **p, double y[], double psum[], long ndim,
	double (*funk)(double []), long ihi, double fac)
{
  long j;
  double fac1,fac2,ytry,*ptry;
  
  //  ptry= malloc((ndim+1) * sizeof(double));
  ptry=vector(ndim);
  fac1=(1.0-fac)/ndim;
  fac2=fac1-fac;
  for (j=0;j<ndim;j++) 
    ptry[j]=psum[j]*fac1-p[ihi][j]*fac2;
  ytry=(*funk)(ptry);
  if (ytry < y[ihi]) {
    y[ihi]=ytry;
    for (j=0;j<ndim;j++) {
      psum[j] += ptry[j]-p[ihi][j];
      p[ihi][j]=ptry[j];
    }
  }
  free_vector(ptry);
    //free(ptry);
  return ytry;
}

void amoeba(double **p, double y[], long ndim, double ftol,
	double (*funk)(double []), long *nfunk)
{
  long i,ihi,ilo,inhi,j,mpts=ndim+1;
  double rtol,sum,swap,ysave,ytry,*psum;

  psum=vector(ndim);
  //  psum= malloc((ndim+1) * sizeof(double));
  *nfunk=0;
  GET_PSUM ;
  for (;;) {
    ilo=0;
    ihi = y[0]>y[1] ? (inhi=1,0) : (inhi=0,1);
    for (i=0;i<mpts;i++) {
      if (y[i] <= y[ilo]) 
	ilo=i;
      if (y[i] > y[ihi]) {
	inhi=ihi;
	ihi=i;
      } else if (y[i] > y[inhi] && i != ihi) 
	inhi=i;
    }
    rtol=2.0*fabs(y[ihi]-y[ilo])/(fabs(y[ihi])+fabs(y[ilo]));
    if (rtol < ftol) {
      SWAP(y[0],y[ilo]);
      for (i=0;i<ndim;i++) 
	SWAP(p[1][i],p[ilo][i]) ;
      break;
    }
    if (*nfunk >= NMAX) nrerror("NMAX exceeded");
    *nfunk += 2;
    ytry=amotry(p,y,psum,ndim,funk,ihi,-1.0);
    if (ytry <= y[ilo])
      ytry=amotry(p,y,psum,ndim,funk,ihi,2.0);
    else if (ytry >= y[inhi]) {
      ysave=y[ihi];
      ytry=amotry(p,y,psum,ndim,funk,ihi,0.5);
      if (ytry >= ysave) {
	for (i=0;i<mpts;i++) {
	  if (i != ilo) {
	    for (j=0;j<ndim;j++)
	      p[i][j]=psum[j]=0.5*(p[i][j]+p[ilo][j]);
	    y[i]=(*funk)(psum);
	  }
	}
	*nfunk += ndim;
	GET_PSUM
	  }
    } else --(*nfunk);
  }
  //  free(psum);
  free_vector(psum);
}
#undef SWAP
#undef GET_PSUM
#undef NMAX
#undef NRANSI
/* (C) Copr. 1986-92 Numerical Recipes Software . */
