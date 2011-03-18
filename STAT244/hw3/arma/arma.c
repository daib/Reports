#include <stdio.h>
#include <stdlib.h>

#include "nrutil.h"

extern double* loadmat(char *fname, int* n, int* m);

extern armalk(double *xd, double *a, double *b, int n, int p, int q,
		double *lik);

extern void powell(double *p, double **xi, long n, double ftol, long *iter,
		double *fret, double(*func)());

extern void amoeba(double **p, double y[], long ndim, double ftol,
		double(*funk)(double[]), long *nfunk);

#define 	TOLERANCE	1.0E-9	

double* xobs;
int nn, mm;

int p, q;

double armalk_wrapper(double* ab)
{
	double lk;
	double *a, *b;

	//printf("There are %d obs on the file\n",n);

	//intialize parameters
	a = ab;
	b = &ab[p];

	armalk(xobs, a, b, nn, p, q, &lk);

	//powell minizes a function
	//while we want to maximize the likely hood
	//then we need to negate the likelyhood  
	return 1/lk;
}

int main(int argc, char* argv[])
{
	double *params, **xi, **pxi, mlk;
	double *y;
	long n, iter, i, j, nfunk;
	char* fileName = "armasq.dat";

	xobs = loadmat(fileName, &nn, &mm);

	nn *= mm;

	if(argc < 3)
	{
		printf("Need to specify p an q\n");
				exit(0);
	}
	else
	{
		p = atoi(argv[1]);
		q= atoi(argv[2]);
//		printf("%d %d\n", p, q);
	}

	n = p + q;

	if(argc > 5)
	{
	    fileName = argv[4];
	}

	if (argc < 4)
	{
		printf(
				"need to specify the minimization method:\n\tarma p\tfor Powell\n\tarma n\tfor Nelder and Mead\n");
		exit(0);
	}
	else if (argv[3][0] == 'p')
	{

	    printf("Using Powell method\n");
		params = vector(n);

		xi = (double**) malloc(n * sizeof(double*));

		//intialize the initial point and directions
		for (i = 0; i < n; i++)
		{
			params[i] = 0.0;
			xi[i] = vector(n);
			for (j = 0; j < n; j++)
			{
				if (i == j)
					xi[i][j] = .1;
				else
					xi[i][j] = 0;
			}
		}

		powell(params, xi, n, TOLERANCE, &iter, &mlk, armalk_wrapper);

		printf("Maximum LK %E\t after %ld iterations with parameters:\n", 1/mlk,
				iter);
		for (i = 0; i < n; i++)
		{
			printf("%E\n", params[i]);
		}

		free_vector(params);

		for (i = 0; i < n; i++)
		{
			free_vector(xi[i]);
		}
		free(xi);
	}
	else if (argv[3][0] == 'n')
	{
	    printf("Using Nelder & Mead method\n");

		y = vector(n+1);
		xi = (double**) malloc((n + 1) * sizeof(double*));

		//intialize the initial points
		for (i = 0; i < n + 1; i++)
		{
			xi[i] = vector(n);
			for (j = 0; j < n; j++)
			{
				if (i == j)
					xi[i][j] = .1;
				else
					xi[i][j] = 0;
			}
			y[i] = armalk_wrapper(xi[i]);
		}

		amoeba(xi, y, n, TOLERANCE, armalk_wrapper, &nfunk);

		printf("After %ld function evaluations, the converged new points are:\n", nfunk);
		for (i = 0; i < n+1; i++)
		{
			printf("\tPoint %ld: MLK = %E, parameters:", i, 1/y[i]);
			for (j = 0; j < n; j++)
				printf(" %E ", xi[i][j]);
			printf("\n");
		}

		free_vector(y);

		for (i = 0; i < n + 1; i++)
		{
			free_vector(xi[i]);
		}
		free(xi);
	}

	free(xobs);

	return 1;

}
