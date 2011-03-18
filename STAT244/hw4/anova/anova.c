//	anova.c
//

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#include "tree1.h"
#include "cdflib.h"

#define MAXLINE	256

double* loadmat(char *fname, int* n, int* m);

/* lexical comparison for bsearch */
static int lexcmp(const void *v1, const void *v2)
{
	int i1 = *(int *) v1, i2 = *(int *) v2, c1 = 0, c2 = 0, i;

	/* count # of 1's in each */
	for (i = 0; i < sizeof(int); ++i)
	{
		int j = 1 << i;
		if (i1 & j)
			c1++;
		if (i2 & j)
			c2++;
	}

	/* if counts are equal, return difference in size */
	if (c1 == c2)
		return (i1 - i2);

	/* otherwise, return difference in counts */
	else
		return (c1 - c2);
}

// return 1 if S is subset of T, else 0
static int subsetof(int s, int t)
{
	int i, retval = 0, scopy = s;
	for (i = 1; i <= scopy; i <<= 1)
	{
		int sbit = 0x01 & s, tbit = 0x01 & t;
		if (sbit && !tbit)
			return 0;
		if (sbit & tbit)
			retval = 1;
		s >>= 1;
		t >>= 1;
	}
	return retval;
}

static int search(int val, int *lst, int len)
{
	int i;

	for (i = 0; i < len; ++i)
		if (lst[i] == val)
			return i;

	return -1;
}

int nFactors = 0; // number of independent variables

int lexicalComparision(int* first, int* second)
{
	int i;
	for (i = 0; i < nFactors; i++)
	{
		if (first[i] < second[i])
		{
			return -1;
		}
		if (first[i] > second[i])
		{
			return 1;
		}
	}

	return 0;
}

int printNode(struct NODE* node)
{
	int i;
	//	printf("Node: ");
	for (i = 0; i < nFactors; i++)
	{
		printf("%d ", ((int*) (node->udata))[i]);
	}

	printf("%f\n", node->data[0]);

	//	printf("\tValues:");
	//	for (i = 0; i < node->dataSize; i++)
	//	{
	//		printf("\t %10E", node->data[i]);
	//	}
	//	printf("\n");
}

double getSum(struct NODE* s)
{
	int i;
	double sum = 0;
	for (i = 0; i < s->dataSize; i++)
	{
		sum += s->data[i];
	}

	return sum;
}

double getSquareSum(struct NODE* s)
{
	int i;
	double sum = 0;
	for (i = 0; i < s->dataSize; i++)
	{
		sum += s->data[i] * s->data[i];
	}

	return sum;
}

double getHarmonicMean(struct NODE* s)
{
	return 1. / s->dataSize;
}

//sum all the specify nodes
double traverseSum(struct NODE *s, int* levels, int* factors, int numFactors,
		double(*func)())
{
	double sum = 0;
	int i;
	int selected = 1;

	for (i = 0; i < numFactors; i++)
	{
		int* currentNodeLevels = (int*) s->udata;
		if (currentNodeLevels[factors[i]] != levels[i])
		{
			selected = 0; //not a node wanted
			break;
		}
	}

	if (selected)
	{
		sum = func(s);
	}

	if (s->left != NULL)
		sum += traverseSum(s->left, levels, factors, numFactors, func);
	if (s->right != NULL)
		sum += traverseSum(s->right, levels, factors, numFactors, func);
	return sum;
}

int main(int argc, char *argv[])
{
	int i, j;
	int **factorLevels; //array of levels of factors
	int *numLevels;
	int totalNumCells = 1;
	int *powerset;
	int powersetSize;
	float *powersetSumSquares;
	int **powersetFactors;
	int *nSetFactors;
	char **factorNames = NULL; // factor names

	char* fileName;

	if (argc < 2)
	{
		printf("Need to specify the input file\n");
		exit(0);
	}

	fileName = argv[1];

	int nRows, nCols;

	double* matrix = loadmat(fileName, &nRows, &nCols);

	nFactors = nCols - 1;

	if (argc > 2)
	{
		nFactors = atoi(argv[2]);
	}

	// lexically sort combinations of factors
	powersetSize = (1 << nFactors) - 1;
	powerset = (int *) calloc(powersetSize, sizeof(int));
	powersetSumSquares = (float *) calloc(powersetSize, sizeof(float));
	powersetFactors = (int **) calloc(powersetSize, sizeof(int *));
	nSetFactors = (int *) calloc(powersetSize, sizeof(int));

	for (i = 0; i < powersetSize; ++i)
	{
		powersetFactors[i] = (int *) calloc(nFactors, sizeof(int));
		powerset[i] = i + 1;
	}

	qsort(powerset, powersetSize, sizeof(int), lexcmp);

	// allocate storage for factors
	factorLevels = (int **) calloc(nFactors, sizeof(int *));
	numLevels = (int *) calloc(nFactors, sizeof(int));

	//cell levels then value
	int *cellLevels = (int *) calloc(nFactors, sizeof(int));

	//name the factors in alphabet
	factorNames = (char **) calloc(nFactors, sizeof(char *));
	for (i = 0; i < nFactors; ++i)
	{
		char name[MAXLINE];
		sprintf(name, "%c", 'A' + (i % 26));
		if (i > 25)
		{
			char num[MAXLINE];
			sprintf(num, "%d", i / 26);
			strcat(name, num);
		}
		factorNames[i] = strdup(name);
	}

	struct NODE * root = NULL;

	//scan levels of each factor
	//and store data in a binary tree
	for (j = 0; j < nRows; j++)
	{
		for (i = 0; i < nFactors; i++)
		{

			int level = (int) (matrix[j * nCols + i]);
			int pos;

			cellLevels[i] = level;

			/* no condition list yet; create it */
			if (!factorLevels[i])
			{
				factorLevels[i] = (int *) malloc(sizeof(int));
				factorLevels[i][0] = level;
				numLevels[i] = 1;
				pos = 0;
			}

			/* list exists, condition not in it yet */
			else if ((pos = search(level, factorLevels[i], numLevels[i])) == -1)
			{
				pos = numLevels[i]++;
				factorLevels[i] = (int *) realloc(factorLevels[i], numLevels[i]
						* sizeof(int));
				factorLevels[i][pos] = level;
			}
		}

		// scan cell value
		//insert into the binary tree
		struct NODE* node = insert(&root, (char*) cellLevels, (nFactors
				* sizeof(int)), lexicalComparision);

		if (node->dataSize == 0)
		{
			node->data = (double *) malloc(sizeof(double));
		}
		else
		{
			node->data = (double*) realloc(node->data, (node->dataSize + 1)
					* sizeof(double));
		}

		node->data[node->dataSize] = matrix[j * nCols + nCols - 1];
		node->dataSize++;
	}

	free(cellLevels);

	//	traverse((char*) root, printNode);

	/* compute total number of condition cells */
	for (i = 0; i < nFactors; ++i)
		totalNumCells *= numLevels[i];

	//compute s harmonic
	double sh = traverseSum(root, NULL, NULL, 0, getHarmonicMean);
	sh = totalNumCells / sh;

	//compute sums over factor/level combinations
	printf("Computing sums of square ...\n");

	//compute SS_M
	double SS_M = traverseSum(root, NULL, NULL, 0, getSum);
	SS_M = (SS_M * SS_M) / (totalNumCells * sh);

	//compute TSS
	double TSS = traverseSum(root, NULL, NULL, 0, getSquareSum) - SS_M;

	double SS_E = TSS;

	for (i = 0; i < powersetSize; i++)
	{
		//		printf("\nPowerset %d\n", i);
		int j, set = powerset[i];
		double denom = sh;
		int nFac = 0, *currentFactors = powersetFactors[i];

		//compute factors of the set
		for (j = 0; j < nFactors; j++)
		{
			int power = 1 << j;
			if (set & power)
				currentFactors[nFac++] = j;
			else
				denom *= numLevels[j];
		}
		nSetFactors[i] = nFac;

		int* currentSetLevels = (int*) calloc(nFac, sizeof(int));
		int* currentSetLevelIndices = (int*) calloc(nFac, sizeof(int));

		for (j = 0; j < nFac; j++)
		{
			currentSetLevelIndices[j] = 0;
			currentSetLevels[j] = factorLevels[currentFactors[j]][0];
		}

		int done = 0;
		double sumOfSquares = 0;

		//iterate through all combinations
		while (!done)
		{
			//compute the sum by traversing the tree
			double sum = traverseSum(root, currentSetLevels, currentFactors,
					nFac, getSum);
			//			int k;
			//			for(k = 0; k < nFac; k++)
			//				printf("%d ", currentSetLevels[k]);
			//			printf("\n");
			//			printf("Sum: %f\n", sum);
			sumOfSquares += sum * sum;

			//find next combination
			currentSetLevelIndices[0]++;
			for (j = 0; j < nFac; j++)
			{
				if (currentSetLevelIndices[j] >= numLevels[currentFactors[j]])
				{
					currentSetLevelIndices[j] = 0;
					currentSetLevels[j] = factorLevels[currentFactors[j]][0];
					if (j < nFac - 1)
					{
						currentSetLevelIndices[j + 1]++; //increase next level
					}
					else
					{
						done = 1; //this is already the last level
					}
				}
				else
				{
					currentSetLevels[j]
							= factorLevels[currentFactors[j]][currentSetLevelIndices[j]];
					break;
				}
			}
		}

		free(currentSetLevels);
		free(currentSetLevelIndices);

		//		printf("Sum of squares %E\n", sumOfSquares);

		powersetSumSquares[i] = sumOfSquares / denom - SS_M;

		for (j = 0; j < i; ++j)
			if (subsetof(powerset[j], powerset[i]))
			{
				powersetSumSquares[i] -= powersetSumSquares[j];
			}

		SS_E -= powersetSumSquares[i];
	}

	//print out the result
	printf("\nSource\t\tDF\tSS\t\tMean Square\tF Value\t\tPr > F\n\n");
	int dfe = (int) (sh - 1);
	for (i = 0; i < nFactors; i++)
	{
		dfe *= numLevels[i];
	}

	double MS_E = SS_E / dfe;
	printf("Error\t\t%d\t%f\t%f\n", dfe, SS_E, MS_E);

	int dfm = 1;
	for (i = 0; i < nFactors; i++)
	{
		dfm *= numLevels[i];
	}

	dfm -= 1;
	double MS_M = (TSS - SS_E) / dfm;

	//compute F and Pr > F
	int status;
	double f, p, q, dfn, dfd, bound;

	i = 1;
	f = MS_M / MS_E;
	dfd = dfe;
	dfn = dfm;

	cdff(&i, &p, &q, &f, &dfn, &dfd, &status, &bound);

	printf("Model\t\t%d\t%f\t%f\t%lf\t%lf\n", dfm, (TSS - SS_E), MS_M, f, q);

	printf("Corrected Total\t%d\t%f\t%f\n\n", dfe + dfm, TSS, TSS / (dfe + dfm));

	for (i = 0; i < powersetSize; i++)
	{
		//		printf("\nPowerset %d\n", i);
		int j;
		double denom = sh;
		int nFac = nSetFactors[i], *currentFactors = powersetFactors[i];

		int df = 1;
		//compute df
		for (j = 0; j < nFac; ++j)
			df *= numLevels[currentFactors[j]] - 1;

		j = 1;
		f = powersetSumSquares[i] / df / MS_E;
		dfd = dfe;
		dfn = df;

		cdff(&j, &p, &q, &f, &dfn, &dfd, &status, &bound);

		printf(factorNames[currentFactors[0]]);

		for (j = 1; j < nFactors; j++)
		{
			if (j < nFac)
				printf(" x %s", factorNames[currentFactors[j]]);
			else
				printf("    ");
		}
		printf("\t%d\t%f\t%f\t%f\t%f\n", df, powersetSumSquares[i],
				powersetSumSquares[i] / df, f, q);

	}

	//	traverse(root, printNode);
	delete((char*) root, NULL);
	free(matrix);

	exit(0);
}
