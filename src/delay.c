#include <sys/time.h>
#include <string.h>
#include "delay.h"

uint64_t getMicroSeconds() {
	struct timeval currenttime;
	gettimeofday(&currenttime, NULL);
	return currenttime.tv_sec * (unsigned) 1000000 + currenttime.tv_usec;
}

void delayMicroSeconds(uint64_t us) {
	volatile uint64_t target = getMicroSeconds() + us;
	while (getMicroSeconds() < target);
}