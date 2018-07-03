#include "stdlib.h"
#include "stdio.h"

#define PAGE_SIZE 4096

int main(int argc, char *argv[]) {
    unsigned long long  i, j, counter, pages = atoll(argv[1]);
    char *mem = malloc(pages * PAGE_SIZE);

    fprintf(stdout, "Allocated: %llu MB\n", pages * PAGE_SIZE/(1024 * 1024));

    // fill with values
    for (i = 0; i < pages; i++) {
        for (j = 0; j < PAGE_SIZE; j++) {
            mem[i*PAGE_SIZE + j] = (char) (j % 255);
        }
    }

    // verify all the memeory allocates
    counter = 0;
    while(++counter) {
        for (i = 0; i < pages; i++) {
            // the first byte of the page
            unsigned long n = i * PAGE_SIZE;
            if (mem[n] != (char) ((counter-1) % 255)) {
                fprintf(stdout, "Memory content is *NOT* valid\n");
                return;
            } else {
                // rewrite
                mem[n] = (char) (counter % 255);
            }
        }
        fprintf(stdout, "Check #%llu -- Ok\n", counter);
        fflush(stdout);
    }
}
