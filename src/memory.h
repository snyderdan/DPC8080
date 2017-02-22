#include "../I8080/I8080.h"
#include "video.h"

#ifndef _DPC_MEMORY_
# define _DPC_MEMORY_

# define BANK_SIZE   0x8000

extern char *memBanks[8];
extern int  bankNumber;

void initMemory();
int64_t myMMU(I8080 *cpu, int ladr);
#endif
