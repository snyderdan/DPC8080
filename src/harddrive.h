# define CYL_COUNT   128
# define HEAD_COUNT  16 
# define SECT_COUNT  32
# define RECORD_SIZE 512

// Hard drive statuses
# define IDLE        0x00
# define CMD_ERROR   0xFF
# define NEED_DATA   0x01
# define WRITE_ERROR 0xFE
# define HAVE_DATA   0x02
# define READ_ERROR  0xFD
# define WRITE_DONE  0x03
# define READ_DONE   0x04

// Hard drive commands
# define ENTER_IDLE  0
# define START_WRITE 1
# define END_WRITE   0xFE
# define START_READ  2
# define END_READ    0xFD
# define READ_NEXT   3
# define SEND_NEXT   4

typedef struct hard_drive {
	FILE *disk;
	int   lba,
		  chs,     // In bits: C C C C  C C C H    H H H S  S S S S
		  counter,
		  cmd,
		  status,
		  lrecl;
} HDD;

HDD disk;

void initHardDrive() {
	disk.counter = 0;
	disk.status = IDLE;
	disk.lrecl = RECORD_SIZE;
}

void CHS2LBA() {
	int cylinder, head, sector;
	cylinder = (disk.chs & 0xFE00) >> 9;
	head     = (disk.chs & 0x01E0) >> 5;
	sector   =  disk.chs & 0x001F;
	disk.lba = (cylinder*HEAD_COUNT + head)*SECT_COUNT + sector;
	disk.lba *= RECORD_SIZE;
}

