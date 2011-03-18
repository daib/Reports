/*
 * main.c
 *
 *      Author: dai
 */
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

#include "tree1.h"
#include "timer.h"

typedef unsigned char byte;

typedef struct treeNodetag
{
	struct treeNodetag *leftNode, *rightNode;
	byte* data;
} treeNode;

extern double* loadmat(char *fname, int* n, int* m);

int intCompare(int* d1, int* d2, int size)
{
	if (*d1 < *d2)
		return -1;
	else if (*d1 > *d2)
		return 1;
	else
		return 0;
}

int doubleCompare(const double *a, const double *b)
{
	double temp = *a - *b;
	if (temp > 0)
		return 1;
	else if (temp < 0)
		return -1;
	else
		return 0;
}

int insertData(treeNode** pNode, byte* data, int size, int(*comp)())
{
	if (*pNode == NULL)
	{
		*pNode = (treeNode*) calloc(1, sizeof(treeNode));
		(*pNode)->data = (byte*) malloc(size);
		int i;
		for (i = 0; i < size; i++)
		{
			(*pNode)->data[i] = data[i];
		}
		return 1; //successful
	}

	int cc = comp((*pNode)->data, data, size);
	if (cc > 0)
	{
		//insert to the right
		return insertData(&(*pNode)->rightNode, data, size, comp);
	}
	else if (cc < 0)
	{
		//insert to the left
		return insertData(&(*pNode)->leftNode, data, size, comp);
	}
	else
	{
		//		fprintf(stderr, "Data duplication\n");
		return 0;
	}
}

void traverseBinTree(treeNode *pNode, int(*func)())
{
	if (pNode->leftNode != NULL)
		traverseBinTree(pNode->leftNode, func);
	func(pNode);
	if (pNode->rightNode != NULL)
		traverseBinTree(pNode->rightNode, func);
}

int printNode(treeNode* pNode)
{
	if (pNode != NULL)
	{
		printf("%d\t", *(int*) (pNode->data));
		return 1;
	}
	return 0;
}

void deleteTree(treeNode* pNode)
{
	if (pNode->leftNode != NULL)
		deleteTree(pNode->leftNode);
	if (pNode->rightNode != NULL)
		deleteTree(pNode->rightNode);

	free(pNode->data);
	free(pNode);
}

int main(int argc, char* argv[])
{
	char* fileName;

	if (argc < 2)
	{
		printf("Need to specify the input file\n");
		exit(0);
	}

	fileName = argv[1];

	int n, m;

	double* x = loadmat(fileName, &n, &m);

	n *= m;
	printf("Loaded %d numbers\n", n);

	treeNode* root = NULL;

	int i, k;
	TIME0;
	for (i = 0; i < n; i++)
	{
		k = (int) x[i];
		insertData(&root, (byte*) &k, sizeof(int), intCompare);
	}
	
	TIME1("Non-self-balancing tree on unsorted sequence");
	//traverseBinTree(root, printNode);

	struct NODE* balancedTreeRoot = NULL;

	TIME0;
	for (i = 0; i < n; i++)
	{
		k = (int) x[i];
		insert(&balancedTreeRoot, (char*) &k, sizeof(int), intCompare);
	}
	TIME1("Self-balancing tree on unsorted sequence");

	printf("\nSorting input data\n");

	qsort(x, n, sizeof(double), doubleCompare);

	deleteTree(root);

	root = NULL;

	delete(&balancedTreeRoot, NULL);

	balancedTreeRoot = NULL;

	TIME0;
	for (i = 0; i < n; i++)
	{
		k = (int) x[i];
		insertData(&root, (byte*) &k, sizeof(int), intCompare);
		//printf("%d\t", k);
		//if(n % 15)
			//printf("\n");
	}

	TIME1("Non-self-balancing tree on sorted sequence");

	//traverseBinTree(root, printNode);

	balancedTreeRoot = NULL;

	TIME0;
	for (i = 0; i < n; i++)
	{
		k = (int) x[i];
		insert(&balancedTreeRoot, (char*) &k, sizeof(int), intCompare);
	}

	TIME1("Self-balancing tree on sorted sequence");

	free(x);
	delete(&balancedTreeRoot, NULL);
	deleteTree(root);
	return 1;
}
