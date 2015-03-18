#include "video.h"
#include "keyboard.h"
#include "harddrive.h"
#include "memory.h"

void port00_disk_data(I8080 *cpu) {

	if (disk.status != NEED_DATA && disk.status != HAVE_DATA) {
		disk.status = CMD_ERROR;
		return;
	}
	
	fseek(disk.disk, disk.lba+disk.counter, SEEK_SET);
	disk.counter++;
	
	if (disk.counter == disk.lrecl) {
		disk.counter = 0;
		if (isOutput(cpu)) {
			disk.status = WRITE_DONE;
		} else {
			disk.status = READ_DONE;
		}
	}
	
	if (disk.cmd == READ_NEXT) { // we're being told to receive a byte
	
	    if (disk.status == HAVE_DATA || isInput(cpu)) {  // If we're reading back to the CPU, we're wrong
			disk.status = WRITE_ERROR;
			setAccumulator(cpu, 0);
			return;
		}
		fputc(getAccumulator(cpu), disk.disk);
		
	} else if (disk.cmd == SEND_NEXT) {
		
		if (disk.status == NEED_DATA || isOutput(cpu)) {  // If the CPU is sending us things
			disk.status = READ_ERROR;
			setAccumulator(cpu, 0);
			return;
		}
		setAccumulator(cpu, fgetc(disk.disk));
		
	} else {
		if (disk.status == HAVE_DATA) {
			disk.status = READ_ERROR;
		} else {
			disk.status = WRITE_ERROR;
		}
	}
}

void port05_disk_status(I8080 *cpu) {
	if (isInput(cpu)) {
		setAccumulator(cpu, disk.status);
	}
}

void port06_disk_cmd(I8080 *cpu) {
	if (isInput(cpu)) {
		disk.status = CMD_ERROR;
	}
	
	int newcmd = getAccumulator(cpu);
	
	switch (newcmd) {
		case ENTER_IDLE:
			if (disk.status == NEED_DATA || disk.status == HAVE_DATA) {
				disk.status = CMD_ERROR;
			} else {
				fclose(disk.disk);
				disk.counter = 0;
				disk.status = IDLE;
			}
			break;
		case START_WRITE:
			if (disk.status != IDLE) {
				disk.status = CMD_ERROR;
			} else {
				disk.disk = fopen("hdd.bin", "rb+");
				disk.status = NEED_DATA;
			}
			break;
		case END_WRITE:
			if (disk.status != WRITE_DONE) {
				disk.status = CMD_ERROR;
			} else {
				fclose(disk.disk);
				disk.status = IDLE;
			}
			break;
		case START_READ:
			if (disk.status != IDLE) {
				disk.status = CMD_ERROR;
			} else {
				disk.disk = fopen("hdd.bin", "rb");
				disk.status = HAVE_DATA;
			}
			break;
		case END_READ:
			if (disk.status != READ_DONE) {
				disk.status = CMD_ERROR;
			} else {
				fclose(disk.disk);
				disk.status = IDLE;
			}
			break;
		case READ_NEXT:
			if (disk.status != NEED_DATA) {
				disk.status = CMD_ERROR;
			}
			break;
	}
	
	disk.cmd = newcmd;
}

void port07_hdd_hiaddr(I8080 *cpu) {
	if (isInput(cpu) || disk.status != IDLE) {
		setAccumulator(cpu, 0);
		return;
	}
	disk.chs &= 0x00FF;
	disk.chs |= (getAccumulator(cpu) << 8);
	CHS2LBA();
}

void port08_hdd_loaddr(I8080 *cpu) {
	if (isInput(cpu) || disk.status != IDLE) {
		setAccumulator(cpu, 0);
		return;
	}
	disk.chs &= 0xFF00;
	disk.chs |= getAccumulator(cpu);
	CHS2LBA();
}

void port01_display_mode(I8080 *cpu) {
	if (isOutput(cpu)) {
		video.dirtyBuffer = 1;
		video.displayMode = getAccumulator(cpu);
	} else {
		setAccumulator(cpu, video.displayMode);
	}
}

void port02_operation(I8080 *cpu) {
	if (isOutput(cpu)) {
		video.textOperation = getAccumulator(cpu);
	} else {
		setAccumulator(cpu, video.textOperation);
	}
}

void port03_charin(I8080 *cpu) {
	video.dirtyBuffer = 1;
	if (isOutput(cpu) && (video.textOperation == APPEND_CHAR)) {
		
		video.charBuffer[video.cursorIndex++] = (getAccumulator(cpu) & 0b01111111) - ' ';
		
	} else if (video.textOperation == DELETE_CHAR) {
		
		char pchar;
		
		if (video.cursorIndex == 0) {
			return;
		}
		
		do {
			pchar = video.charBuffer[--video.cursorIndex];
			video.charBuffer[video.cursorIndex] = 0;
		} while (pchar == 95);
		
		if (video.cursorIndex < 0) {
			video.cursorIndex = 0;
		}
		
	} else if (video.textOperation == NEW_LINE) {
		
		int i, co = SCREEN_CHAR_W-(video.cursorIndex%SCREEN_CHAR_W);
	    
	    for (i=0; i<co;i++) {
			video.charBuffer[video.cursorIndex++] = 95;
		}
		
		video.charBuffer[video.cursorIndex-co] = 0;
	} else if (video.textOperation == RESET) {
		int i;
		for (i=0; i<video.cursorIndex; i++) {
			video.charBuffer[i] = 0;
		}
		video.cursorIndex = 0;
	}
}

void port04_keyout(I8080 *cpu) {
	if (isInput(cpu)) {
		if (keyindex == processed) {
			setAccumulator(cpu, 0);
		} else {
			setAccumulator(cpu, (char) keyboardbuffer[processed++]);
			processed = processed % 1024;
		}
	}
}

void port0A_switch_bank(I8080 *cpu) {
	if (isOutput(cpu)) {
		bankNumber = getAccumulator(cpu) & 0b11;
	} else {
		setAccumulator(cpu, bankNumber);
	}
}
