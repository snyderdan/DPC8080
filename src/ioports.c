#include "ioports.h"

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

void port05_diskrx(I8080 *cpu) {
	if (isInput(cpu)) {
		setAccumulator(cpu, serialDiskRead());
	}
}

void port06_disktx(I8080 *cpu) {
	if (isOutput(cpu)) {
		serialDiskWrite(getAccumulator(cpu));
	} 
}

void port0A_switch_bank(I8080 *cpu) {
	if (isOutput(cpu)) {
		bankNumber = getAccumulator(cpu) & 0b111;
		if (bankNumber == 0) bankNumber = 1;
	} else {
		setAccumulator(cpu, bankNumber);
	}
}
