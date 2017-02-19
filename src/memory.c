#include "memory.h"

char *memBanks[4],*sharedMem;
int  bankNumber;

void initMemory() {
	memBanks[0] = malloc(BANK_SIZE);
	memBanks[1] = malloc(BANK_SIZE);
	memBanks[2] = malloc(BANK_SIZE);
	memBanks[3] = malloc(BANK_SIZE);
	
	sharedMem = malloc(SHARED_SIZE);
}
int myMMU(I8080 *cpu, int ladr) {
	
	int retval;
	
	if (bankNumber > 0) {
		retval = ladr + (int) memBanks[bankNumber];
	} else if (ladr < 0x0800) {
		retval = ladr + (int) memBanks[0];
	} else if (ladr < 0x5800) {
		
		// If it's in output mode then we know it's writing to the buffer
		if (isOutput(cpu)) {
			video.dirtyBuffer = 1;
		}

		retval = (int) video.pixelBuffer + ladr - 0x0800;
	} else {
		retval = ladr + (int) memBanks[0] - 0x5000;
	}
	
	return retval;
}

