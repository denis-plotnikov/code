#include <stdlib.h>
#include <stdio.h>
#define ARRAY_SIZE	4096
#define DEFAULT_LOOPS	1000000

static char a[ARRAY_SIZE];

void iterate_static_array(long loops)
{
	for(long i = 0; i < loops; i++)
		for(int j = 0; j < ARRAY_SIZE; j++)
			a[j] = (char) j;
}

int main(int argc, char* argv[]) 
{
	printf("Please, press ENTER for a new iteration\n");
	while(getchar() == '\n') {
		long loops = DEFAULT_LOOPS;
		if (argc > 1)
			loops = atol(argv[1]);
		printf("loops to run: %ld\n", loops);
		iterate_static_array(loops);
		printf("DONE! Please, press ENTER for a new iteration\n");
	}
}
