
#define TOL 2.0e-4

int ncom = 0;
double *pcom = 0,*xicom = 0,(*nrfunc)();

void linmin(p,xi,n,fret,func)
double *p,*xi,*fret,(*func)();
long n;
{
	long j;
	double xx,xmin,fx,fb,fa,bx,ax,tol=1.0e-4;
	double brent(),f1dim(),*vector();
	void mnbrak(),free_vector();

	ncom=n;
	pcom = vector(n);
	xicom = vector(n);
	nrfunc = func;
	for (j=0;j<n;j++){
		pcom[j] = p[j];
		xicom[j] = xi[j];
		}

	ax = 0.;
	xx = 1.0;
	bx = 2.0;
	mnbrak(&ax,&xx,&bx,&fa,&fx,&fb,f1dim);
	*fret=brent(ax,xx,bx,f1dim,TOL,&xmin);
	for(j=0;j<n;j++){
		xi[j] *= xmin;
		p[j] += xi[j];
	}
	free_vector(xicom);
	free_vector(pcom);
}

double f1dim(x)
  double x;

{

	int j;
	double f,*xt,*vector();
	void free_vector();

	xt = vector(ncom);
	for(j=0;j<ncom;j++)xt[j] = pcom[j] + x * xicom[j];
	f = (*nrfunc)(xt);
	free_vector(xt);
	return f;
}

