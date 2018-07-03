#include "stdlib.h"
#include "stdio.h"
#include <sys/eventfd.h>
#include "sys/mman.h"
#include "stdbool.h"
#include "malloc.h"
#define _GNU_SOURCE
#include <unistd.h>
#include <sys/syscall.h>
#include <pthread.h>
#include <asm-generic/ioctl.h>
#include <linux/userfaultfd.h>
#include <poll.h>
#include <fcntl.h>
#include <signal.h>

#define PSIZE 4096
#define PNUM 10
#define PATTERN 'a'
#define WRITE_PATTERN 'b'
#define MID_ELEMENT PSIZE/2

#define __NR_userfaultfd 323

static int pagefault_fd;
static pthread_t thread_id;

void fill_page(char *page, char pattern)
{
	int i;
	for (i = 0; i < PSIZE; i++) {
		page[i] = pattern;
	}
}

void print_page_addresses(char **p)
{
	int i;
	for (i = 0; i < PNUM; i++)
		printf("page #%d: %p\n", i, p[i]);
}

void write_page_in_the_middle(char *page, char pattern)
{
	page[MID_ELEMENT] = pattern;
}

bool verify_page(char *page, char pattern)
{
	if (page[MID_ELEMENT] == pattern)
		return true;
	else
		return false;
}

void verify_all_pages(char **pages, char pattern)
{
	int i;
	printf("Verifying for pattern '%c':", pattern);
	for (i = 0; i < PNUM; i++) {
		if (!verify_page(pages[i], pattern))
			printf("page #%d is wrong\n", i);
	}
	printf("done\n");
}

void set_page_readonly(char *p)
{
	printf("Setting readonly: %p\n", p);
	if (mprotect((void *)p, PSIZE-1, PROT_READ) == -1)
		printf("Error on setting the page readonly\n");
}

void set_page_readwrite(char *p)
{
	void* page = (void*)((unsigned long long)p & ~(PSIZE-1));
	printf("Setting read/write: %p\n", p);
	if (mprotect(page, PSIZE-1, PROT_READ | PROT_WRITE) == -1)
		printf("Error on setting the page read/write\n");
}

static void* fault_thread(void* arg)
{
	struct uffd_msg msg;

	while (true) {
		int ret;
		struct pollfd p;

		p.fd = pagefault_fd;
		p.events = POLLIN;
		p.revents = 0;

		printf("fault_thread: on poll\n");
		if (poll(&p, 1, -1) == -1) {
			printf("Error on polling. fault_tread exiting...\n");
			return NULL;
		}

		printf("revents: %d\n", p.revents);
		ret = read(pagefault_fd, &msg, sizeof(msg));
		printf("ret: %d\n", ret);

		if (ret != sizeof(msg)) {
			printf("Error on pagefault message getting. fault_thread exiting...\n");
			return NULL;
		}

		printf("Fault on %p\n", msg.arg.pagefault.address);
	}
}

static void
handler(int sig, siginfo_t *si, void *unused)
{
	printf("SIGSEGV at 0x%lx\n", si->si_addr);
	set_page_readwrite(si->si_addr);
	//exit(0);
	return;
}

void main()
{
	int i, err;
	char *p[PNUM];
	void* pntr = malloc(1);
	struct sigaction sa;

	sa.sa_flags = SA_SIGINFO;
	sigemptyset(&sa.sa_mask);
	sa.sa_sigaction = handler;

	if (sigaction(SIGSEGV, &sa, NULL) == -1) {
		printf("sigaction\n");
		return;
	}

        for (i = 0; i < PNUM; i++) {
		p[i] = (char*) memalign(PSIZE, PSIZE);
                fill_page(p[i], PATTERN);
	}

	print_page_addresses(p);

	verify_all_pages(p, PATTERN);
	set_page_readonly(p[2]);

	for (i = 0; i < PNUM; i++) {
		write_page_in_the_middle(p[i], WRITE_PATTERN);
	}

	verify_all_pages(p, WRITE_PATTERN);
}
