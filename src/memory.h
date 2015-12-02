#include "..\\I8080\\I8080.h"
#include "video.h"

#ifndef _DPC_MEMORY_
# define _DPC_MEMORY_

# define BANK_SIZE   0xC000
# define SHARED_SIZE 0x10000-BANK_SIZE

extern char *memBanks[4],*sharedMem;
extern int  bankNumber;

void initMemory();
int myMMU(I8080 *cpu, int ladr);
#endif
