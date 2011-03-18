struct NODE
{
    struct NODE *left, *right;
    short bal, dum;
    char *udata;
};

/* function prototypes for functions in btree1.c */

char *insert(char **pt, char *udata, int usize, int(*comp)());
void traverse(char *t, int(*func)());
void delete(char **pt,int (*delfn)());
