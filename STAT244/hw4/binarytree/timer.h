#include "timing.h"

struct timespec begin, end;

#define TIME0 get_time(&begin);

#define TIME1(msg) get_time(&end);\
	printf("%s : %LE nanosec\n", msg,\
	timespec_diff(begin, end));
