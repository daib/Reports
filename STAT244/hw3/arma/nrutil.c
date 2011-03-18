#include <stdio.h>

void nrerror(error_text)
 char error_text[];
{
  void exit();
  fprintf(stderr,"Numerical Recipes run-time error...\n");
  fprintf(stderr,"%s\n",error_text);
  fprintf(stderr,"...now exiting to system...\n");
  exit(1);
}

double *vector(n)
 int n;
{
  double *v;

  v = (double*)malloc((unsigned)(n * sizeof(double)));
  if(!v)nrerror("allocation failure in vector()");
  return v;
}

void free_vector(v)
 double *v;
{
 free((char*)v);
}

