#include "stdlib.h"
#include "stdio.h"
#include "fcntl.h"

void main(int argc, char* argv[])
{
    const char* file = argv[1];
    char buf[8];
    int fd, i;

    printf("File name: %s\n", file);

    fd = open(file, O_RDWR);
    if (fd < 0) {
        printf("can't open file: %s\n", file);
        return;
    }

    for (i = 0; i < 8; i++)
        buf[i] = 'a';

    write(fd, buf, 8);

    lseek(fd, 4L * 1024 * 1024 * 1024 , 0);

    write(fd, buf, 8);
    close(fd);
}
