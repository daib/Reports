/*------------------------------------------------------------------------
  This program opens a file for reading, and then reads a matrix of 
  numbers from the file, reallocating memory as necessary.
--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
/* 
   MAXBUF is a preprocessor variable which determines how big of a 
   buffer the program will use to read its input.  If the value given
   turned out to be too small, you could just change this definition. 
*/

#define MAXBUF  256

double* loadmat(char *fname, int* n, int* m)
{
  int i,j,k,nstart,nread,ncol;
  double dum;
  double *x;
  double *dmalloc(long n);
  FILE *fp;
  char buf[MAXBUF];

/* 
   Open the file, and exit if there's a problem.
   The "r" means to open the file for reading.
*/

  if((fp = fopen(fname,"r")) == NULL){
	printf("Can't open file.  Exiting ...\n");
	exit(1);
	}

/*
   Read the first line of the file into the character string buf
   fgets reads a line (up to a newline) at a time from a file 
   opened by fopen.
*/

  fgets(buf,MAXBUF,fp);

  ncol = 0;
  i = 0;
  while(buf[i] != 0 && buf[i] != '\n'){
	if(sscanf(buf + i,"%lf",&dum))ncol++;
	if(buf[i] == ' ')while(buf[i++] == ' ');
	for(;buf[i] != 0 && buf[i] != '\n';i++)if(buf[i] == ' ')break;
	while(buf[i] == ' ')i++;
	}

  //printf("There are %d numbers on the first line\n",ncol);

/* 
  rewind the file
*/

  fseek(fp,(long)0,0);

  nstart = 10 * ncol;
  x = dmalloc(nstart);


/*
    Read in the values one at a time, checking the return value of
    fscanf.  After the last value is read, fscanf returns EOF.
    (fscanf works exactly like scanf, except that the first argument
     is a file pointer from fopen.)
*/

  i = 0;
  for(i=0;;i++){
	if(fscanf(fp,"%lf",x + i) == EOF)break;
	if(i == nstart - 1){

/* 
    The realloc routine changes the amount of memory allocated to
    a pointer.  When you ask for more memory, it first tries to 
    find it contiguous to the old memory; if it can't, it moves 
    the old allocation to a new location.
*/

		if((x = (double*)realloc((char*)x,
			 (unsigned)((nstart *= 2) * sizeof(double)))) == NULL){
			printf("Error in allocation.  Exiting...\n");
			exit(1);
	   		}
		}
	}

/* 
    The number of items read will be equal to the value of i *after*
    the last item was read, since the array is zero-based.
*/

  nread = i;

	/*
  if(nread % ncol)
	printf("Incomplete matrix.\n");
  else printf("Read %d items (%d x %d array)\n",nread,nread / ncol,ncol);

  k = 0;
  for(i=0;i<nread / ncol;i++){
	for(j=0;j<ncol;j++)printf("%10.5f ",x[k++]);
	printf("\n");
	}
*/	
	*n = nread/ncol;	
	*m = ncol;
	return x;
}

double *dmalloc(long n)
{
  double *x;

  if((x = (double*)malloc((unsigned)(n * sizeof(double)))) == NULL){
	fprintf(stderr,"Error in dmalloc, request was for %ld bytes.\n",n);
	exit(1);
	}

  return(x);
}


