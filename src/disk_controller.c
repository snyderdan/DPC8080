#include "disk_controller.h"

HDD disk = {0};

char serialDiskRead() {
	char value = disk.rx;
	disk.rx = 0;
	
	if (disk.status == READ_PROC && disk.counter >= 2) {
		if (disk.counter == disk.lrecl+2) {
			disk.rx = END_FRAME;
		} else {
			disk.rx = disk.databuffer[disk.counter++];
		}
	}
	
	return value;
}

void serialDiskWrite(char c) {
	
	switch (disk.status) {
		case IDLE:
			if (c == REQUEST_READ || c == REQUEST_WRITE) {
				disk.tx = c;	// record the last command
				disk.status = WAITING;
				disk.rx = ACKOWLEDGE;
			} else if (c == STATUS) {
				disk.rx = disk.status;
				return;
			} else if (c != ENTER_IDLE) {
				disk.rx = NACK_ERROR;
			} else {
				disk.rx = IDLE;
			}
			break;
		case WAITING:
			if (disk.tx == REQUEST_READ && c == START_FRAME) {
				disk.counter = 0;
				disk.status = READ_PROC;
				disk.tx = 0;
			} else if (disk.tx == REQUEST_WRITE && c == START_FRAME) {
				disk.counter = 0;
				disk.status = WRITE_PROC;
				disk.tx = 0;
			} else if (c == STATUS) {
				disk.rx = disk.status;
			} else if (c != ENTER_IDLE) {
				disk.rx = PROC_ERROR;
			} else {
				disk.status = IDLE;
				disk.rx = IDLE;
			}
			break;
		case WRITE_PROC:
			if (disk.counter == disk.lrecl+2) {
				if (c == END_FRAME) {
					disk.chs = ((*(disk.databuffer)) << 8) | (*(disk.databuffer+1));
					CHS2LBA();
					disk.status = WAITING;
					disk.rx = WRITE_OKAY;
					disk.disk = fopen("hdd.bin", "rb+");
					fseek(disk.disk, disk.lba, SEEK_SET);
					fwrite(disk.databuffer+2, 1, disk.lrecl, disk.disk);
					fclose(disk.disk);
				} else if (c == ENTER_IDLE) {
					disk.status = IDLE;
					disk.rx = WRITE_ERROR;
				} else {
					disk.rx = WRITE_ERROR;
				}
			} else {
				disk.databuffer[disk.counter++] = c;
			}
			break;
		case READ_PROC:
		
			if (disk.counter == 2) {
				if (c == END_FRAME) {
					disk.chs = ((*(disk.databuffer)) << 8) | (*(disk.databuffer+1));
					CHS2LBA();
					disk.rx = START_FRAME;
					disk.disk = fopen("hdd.bin", "rb+");
					fseek(disk.disk, disk.lba, SEEK_SET);
					fread(disk.databuffer+2, 1, disk.lrecl, disk.disk);
					fclose(disk.disk);
				} else if (c == ENTER_IDLE) {
					disk.status = IDLE;
					disk.rx = READ_ERROR;
				} else {
					disk.rx = READ_ERROR;
				}
			} else if (disk.counter < 2) {
				disk.databuffer[disk.counter++] = c;
			} else {
				if (disk.counter == 514 && c == ACKOWLEDGE) {
					disk.status = WAITING;
					disk.rx = READ_OKAY;
				} else {
					disk.counter--;
					disk.rx = READ_ERROR;
				}
			}
			break;
	}
}

void initHardDrive() {
	disk.counter = 0;
	disk.status = IDLE;
	disk.lrecl = RECORD_SIZE;
	disk.databuffer = malloc(disk.lrecl + 2);
}

void CHS2LBA() {
	int cylinder, head, sector;
	cylinder = (disk.chs & 0xFE00) >> 9;
	head     = (disk.chs & 0x01D0) >> 6;
	sector   =  disk.chs & 0x003F;
	disk.lba = (cylinder*HEAD_COUNT + head)*SECT_COUNT + sector;
	disk.lba *= RECORD_SIZE;
}
