/* the following routines were adapted from those in Numerical Recipes in C,
	The Art of Scientific Computing, Press, et. al., Cambridge.  */

#include <math.h>
#define ITMAX 200

static float sqrarg;
#define SQR(a)  (sqrarg=(a),sqrarg*sqrarg)

void powell(p,xi,n,ftol,iter,fret,func)

double *p,**xi,ftol,*fret,(*func)();
long n,*iter;
{
	long i,ibig,j;
	double t,fptt,fp,del;
	double *pt,*ptt,*xit,*vector();
	void linmin(),nrerror(),free_vector();

	pt = vector(n);
	ptt = vector(n);
	xit= vector(n);
	*fret = (*func)(p);
	for (j=0;j<n;j++)
		pt[j] = p[j];
	for(*iter=1;;(*iter)++){
		fp = *fret;
		ibig = 0;
		del = 0.0;
		for (i=0;i<n;i++){
			for(j=0;j<n;j++)
				xit[j] = xi[j][i];
			fptt = *fret;
			linmin(p,xit,n,fret,func);
			if(fabs(fptt-*fret) > del){
				del=fabs(fptt-*fret);
				ibig=i;
			}
		}
		if(2.0*fabs(fp-*fret) <= ftol*(fabs(fp)+fabs(*fret))){
			free_vector(xit);
			free_vector(ptt);
			free_vector(pt);
			return;
			}
		if(*iter == ITMAX)
			nrerror("Too many iterations in routine POWELL");
		for(j=0;j<n;j++){
			ptt[j] = 2.0 * p[j] - pt[j];
			xit[j] = p[j] - pt[j];
			pt[j] = p[j];
		}
		fptt = (*func)(ptt);
		if (fptt < fp){
			t = 2.0 * (fp-2.*(*fret)+fptt) * SQR(fp-(*fret)-del)
				  - del * SQR(fp-fptt);
			if(t < 0.0){
				linmin(p,xit,n,fret,func);
			for(j=0;j<n;j++)xi[j][ibig] = xit[j];
			}
		}
	}
}

