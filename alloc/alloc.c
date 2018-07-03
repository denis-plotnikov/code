#include "stdlib.h"
#include "stdio.h"

#define PAGE_SIZE 4096

int main(int argc, char *argv[]) {
    long long i;
    long long  pages = atoll(argv[1]);
    char *mem = malloc(pages * PAGE_SIZE);

    printf("Allocated: %llu MB\n", pages * PAGE_SIZE/(1024 * 1024));

    // fill with values
    for (i = 0; i < pages * PAGE_SIZE; i++) {
        mem[i] = i % 255;
    }

    // touch the first page only
    while(1) {
        for (i = 0; i < PAGE_SIZE; i++) {
            mem[i] = i % 255;
        }
    }
}
