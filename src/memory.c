#include <stdint.h>
#include "memory.h"

char *memBanks[8],*sharedMem;
int  bankNumber;

void initMemory() {
	memBanks[0] = malloc(BANK_SIZE);
	memBanks[1] = malloc(BANK_SIZE);
	memBanks[2] = malloc(BANK_SIZE);
	memBanks[3] = malloc(BANK_SIZE);
	memBanks[4] = malloc(BANK_SIZE);
	memBanks[5] = malloc(BANK_SIZE);
	memBanks[6] = malloc(BANK_SIZE);
	memBanks[7] = malloc(BANK_SIZE);
	bankNumber = 1;
}


int64_t myMMU(I8080 *cpu, int ladr) {
	
	int64_t retval;
	
	if (ladr >= BANK_SIZE) {
		retval = ((int64_t) memBanks[bankNumber]) + ladr;
	} else if (ladr < 0x0800) {
		retval = ((int64_t) memBanks[0]) + ladr;
	} else if (ladr < 0x5800) {
		
		// If it's in output mode then we know it's writing to the buffer
		if (isOutput(cpu)) {
			video.dirtyBuffer = 1;
		}

		retval = ((int64_t) video.pixelBuffer) + ladr - 0x0800;
	} else {
		retval = ((int64_t) memBanks[0]) + ladr - 0x5000;
	}
	
	return retval;
}

