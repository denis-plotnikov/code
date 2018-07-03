#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <errno.h>

void main()
{
    void *p;
    int res;
    char *s = malloc(100*sizeof(char));
    size_t i, size = (size_t) 1000 * 4096;

    printf("Before allocation. Press any key...\n");
    gets(s);

    p = mmap(0, size, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0);
    for (i = 0; i < size; i++)
        ((char*) p)[i] = i % 255;

    printf("After allocation. Press any key...\n");
    gets(s);
    res = madvise(p, size, MADV_DONTNEED);
    printf("After madvice (%d:%d). Press any key...\n", res, errno);
    gets(s);
}
