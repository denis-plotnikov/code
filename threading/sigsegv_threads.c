#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <signal.h>
#include <sys/mman.h>
#include <sys/syscall.h>
#include <sys/types.h>

#define NUM_THREADS 8
#define GET_TID syscall(SYS_gettid)

int *ptrs[NUM_THREADS];

typedef struct thparam {
    int id;
} thparam;

thparam thr_params[NUM_THREADS];

pthread_t thr_info[NUM_THREADS];

pid_t tids[NUM_THREADS];

static void handler(int sig, siginfo_t *si, void *unused)
{
    int page_size = getpagesize();
    void* page = ((unsigned long) si->si_addr) & (~(page_size - 1));
    int i;
    pid_t cur_tid;

    for (i = 0; i < NUM_THREADS; i++) {
        if (page == ptrs[i]) {
            break;
        }
    }

    if (i == NUM_THREADS) {
        printf("Can't find a page\n");
        exit(1);
    }

    cur_tid = GET_TID;

    if (tids[i] != cur_tid) {
        printf("===== Signal handler is in ANOTHER thread: [%d] -> %d\n",
               tids[i], cur_tid);
    }
//    } else {
//        printf("Signal handler is in the same thread: [%d] -> %d\n",
//               tids[i], cur_tid);
//    }

    mprotect(page, page_size, PROT_READ | PROT_WRITE);
}

void *thread_func(void *param)
{
    thparam *p = param;
    int i;

    tids[p->id] = GET_TID;
    *ptrs[p->id] = p->id;

    while (1) {
        for (i = 0; i < 1000000000; i++) {
            (void) 0;
        }

        *ptrs[p->id] = p->id;
    }

    return NULL;
}

void main()
{
    int i, res;
    int page_size = getpagesize();
    struct sigaction sa;


    for (i = 0; i < NUM_THREADS; i++) {
        ptrs[i] = memalign(page_size, page_size);
        if (ptrs[i] == NULL) {
            printf("Can't map memeory\n");
            return;
        }
        printf("%d => %p\n", i, ptrs[i]);
        thr_params[i].id = i;
        res = pthread_create(&thr_info[i], NULL, &thread_func, &thr_params[i]);
        if (res) {
            printf("Can't create a thread\n");
            return;
        }
    }
    sleep(1);
    for (i = 0; i < NUM_THREADS; i++) {
        printf("%d: [%d] %p => %d\n", i, tids[i], ptrs[i], *ptrs[i]);
    }

    sa.sa_flags = SA_SIGINFO;
    sigemptyset(&sa.sa_mask);
    sa.sa_sigaction = handler;
    if (sigaction(SIGSEGV, &sa, NULL) == -1) {
        printf("Can't set sigaction handler");
        return;
    }

    while (1) {
        for (i = 0; i < NUM_THREADS; i++) {
            mprotect(ptrs[i], page_size, PROT_READ);
        }
    }
}

