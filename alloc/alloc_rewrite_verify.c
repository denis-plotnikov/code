#include "stdlib.h"
#include "stdio.h"

#define PAGE_SIZE 4096

int main(int argc, char *argv[]) {
    unsigned long long  i, counter, pages = atoll(argv[1]);
    char *mem = malloc(pages * PAGE_SIZE);

    fprintf(stdout, "Allocated: %llu MB\n", pages * PAGE_SIZE/(1024 * 1024));

    // fill with values
    for (i = 0; i < pages * PAGE_SIZE; i++) {
        mem[i] = (char) i % 255;
    }

    // verify all the memeory allocates
    counter = 0;
    while(++counter) {
        for (i = 0; i < pages * PAGE_SIZE; i++) {
            if (mem[i] != (char) (i + counter - 1) % 255) {
                fprintf(stdout, "Memory content is *NOT* valid\n");
                return;
            } else {
                // rewrite
                mem[i] = (char) (i + counter) % 255;
            }
        }
        fprintf(stdout, "Check #%llu -- Ok\n", counter);
        fflush(stdout);
    }
}
