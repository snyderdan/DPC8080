#include "../I8080/I8080.h"
#include <stdio.h>
#include <stdlib.h>

/**
 *  This provides an interface to an external disk
 *  The protocol is not standardized and is completely made up.
 *  It is loosely based off of SATA -- but it's a little more janky and
 *  doesn't care about timing because I'm not threading this thing. 
 */
 
/*
 * Hand shakes:
 * 
 * Writes from CPU perspective:
 * ->[0 REQUEST_WRITE]		CPU currently in IDLE state
 * <-[0 ACKOWLEDGE(NACK)]	CPU enters WAITING state
 * ->[0 START_FRAME]		CPU enters WRITE_PROC state
 * ->[1 ADDR_HI][2 ADDR_LO][3-514 DATA]
 * ->[515 END_FRAME]
 * <-[0 WRITE_OKAY(WRITE_ERROR)]	CPU enters WAITING state
 * ->[0 ENTER_IDLE]					CPU enters IDLE state
 * <-[0 IDLE]
 * 
 * Reads from CPU perspective:
 * ->[0 REQUEST_READ]		CPU currently in IDLE state
 * <-[0 ACKOWLEDGE(NACK)]	CPU enters WAITING state
 * ->[0 START_FRAME]		CPU enters READ_PROC state
 * ->[1 ADDR_HI][2 ADDR_LO]
 * ->[3 END_FRAME]
 * <-[0 START_FRAME]
 * <-[1-512 DATA]
 * <-[513 END_FRAME]
 * ->[0 ACKNOWLEDGE]
 * <-[0 READ_OKAY(READ_ERROR)]	CPU enters WAITING state
 * ->[0 ENTER_IDLE]				CPU enters IDLE state
 * <-[0 IDLE]
 */
 
#ifndef _DPC_DISK_CONTROLLER_
# define _DPC_DISK_CONTROLLER_

# define CYL_COUNT   128
# define HEAD_COUNT  8 
# define SECT_COUNT  64
# define RECORD_SIZE 512

// Hard drive commands
# define ENTER_IDLE    0x01		// clear status/processing and enter idle state
# define REQUEST_WRITE 0x02		// request to start a write operation
# define REQUEST_READ  0x03		// request to start a read operation
# define START_FRAME   0x04		// tells disk to begin operation
# define END_FRAME     0x05		// tells disk to terminate operation
# define STATUS        0x06		// check status of disk

// Hard drive statuses
# define IDLE        0x01	// indicates that no disk activity is taking place
# define WRITE_PROC  0x02	// indicates the disk is processing a write
# define READ_PROC   0x04	// indicates the disk is processing a read
# define WAITING     0x08	// indicates the disk is waiting for the CPU to respond
// Hard drive responses

# define ACKOWLEDGE  0x07	// indicates the disk is ready to perform operation
# define WRITE_OKAY  0x08	// indicates write terminated properly
# define READ_OKAY   0x09	// indicates read terminated properly
# define WRITE_ERROR 0xF0	// indicates an invalid write sequence/length
# define READ_ERROR  0xF1	// indicates an invalid read sequence/length
# define NACK_ERROR  0xF2	// indicates the requested operation was not accepted
# define PROC_ERROR  0xF3	// indicates an unexpected command sequence

typedef struct hard_drive {
	int   lba,
		  chs,     // In bits: C C C C  C C C H    H H H S  S S S S
		  counter,
		  status,
		  lrecl;
	char  tx,
		  rx;
	FILE *disk;
	char *databuffer;
} HDD;

extern HDD disk;

void initHardDrive();
char serialDiskRead();
void serialDiskWrite(char c);
void CHS2LBA();

#endif

