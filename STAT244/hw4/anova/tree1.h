struct NODE
{
	struct NODE *left, *right;
	short bal, dum;
	char *udata;
	double* data;
	int dataSize;
};

/* function prototypes for functions in btree1.c */

struct NODE *insert(struct NODE **pt, char *udata, int usize, int(*comp)());
void traverse(char *t, int(*func)());
void delete(char **pt, int(*delfn)());
