#include "timing.h"


struct timespec begin, end;

#define TIME0 get_time(&begin);

#define TIME1(msg) get_time(&end);\
	printf("%s : %llf nano-sec\n", msg,\
	1E9 * timespec_diff(begin, end));
