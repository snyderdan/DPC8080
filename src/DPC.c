#include <stdio.h>
#include <SDL.h>
#include <time.h>
#include <windows.h>
#include <WinSock2.h>

#include "..\\I8080\\I8080.h"
#include "delay.h"
#include "drawing.h"
#include "ioports.h"

//#define DEBUG_LOOP
//#define DEBUG_REG_DUMP

# define EXECUTION_INTERVAL 500 // microseconds

int executeCycles(I8080 *cpu, int numberOfCycles) {
	cpu->counter = 0;
	while (numberOfCycles > cpu->counter) {
		stepCPU(cpu);
#ifdef DEBUG_REG_DUMP
#define ubyte unsigned char
#define ushort unsigned short
        printf("A: 0x%02X PC: 0x%04X\nB: 0x%02X C:  0x%02X\nD: 0x%02X E:  0x%02X\nH: 0x%02X L:  0x%02X\nSP: 0x%02X\n\n", 
        (ubyte)cpu->a, (ushort)cpu->pc, (ubyte)cpu->b, (ubyte)cpu->c, (ubyte)cpu->d, (ubyte)cpu->e, (ubyte)cpu->h, (ubyte)cpu->l, (ushort)cpu->sp);
#undef ubyte
#undef ushort
		//getchar();
#endif
	}
	
	return cpu->counter;
}

#undef main

int main() {
	
	char  ch;
	I8080 *cpu;
	FILE  *boot;
	int64_t previous_cycle_start, cycle_start, cycle_end;
	int actual_time, target_time, running, lSize, result;
	double target_cycles, actual_cycles, cycles_per_loop;
	SDL_Event event;
	
	SetThreadAffinityMask(GetCurrentThread(), 1);
	
	cpu  = newCPU();	
	keyboardbuffer = malloc(1024);
	
	initCPU(cpu);
	initDisplay();
	initHardDrive();
	initMemory();
	setMMU(cpu, myMMU);
	setIOPort(cpu, 0, port00_disk_data);
	setIOPort(cpu, 1, port01_display_mode);
	setIOPort(cpu, 2, port02_operation);
	setIOPort(cpu, 3, port03_charin);
	setIOPort(cpu, 4, port04_keyout);
	setIOPort(cpu, 5, port05_disk_status);
	setIOPort(cpu, 6, port06_disk_cmd);
	setIOPort(cpu, 7, port07_hdd_hiaddr);
	setIOPort(cpu, 8, port08_hdd_loaddr);
	
	boot   = fopen("bios/bios.bin", "rb");
	fseek(boot , 0 , SEEK_END);
    lSize  = ftell(boot);
    rewind(boot);
    result = fread(memBanks[0], 1, lSize, boot);
	
	if (result != lSize) {fputs ("Reading error",stderr); exit (3);}
	
	fclose(boot);
	
	
	cycles_per_loop = EXECUTION_INTERVAL * (2000000 / 1000000.0);
	target_cycles   = cycles_per_loop;
	
	getMicroSeconds(&cycle_start); // get initial start time for loop entry
	// This is because the next time cycle_start is set is at the end of the loop
	// to account for any time consumed with branches.
	
	cycle_end            = EXECUTION_INTERVAL + cycle_start;
	previous_cycle_start = cycle_start;
	target_time          = EXECUTION_INTERVAL;
	
	running = 1;
	
	while (running) {
		
		while (SDL_PollEvent(&event)) {
			ch = -1;
			switch (event.type) {
				case SDL_KEYDOWN:
# define key event.key.keysym
				    if (key.unicode >= ' ' && key.unicode <= '~') {// if it's a character
						ch = key.unicode&0x7F;
					} else if (key.sym == SDLK_BACKSPACE) {
						ch = 0x08;
					} else if (key.sym == SDLK_RETURN) {
						ch = 0x0A;
					} else if (key.sym == SDLK_UP) {
						ch = 0b11000010;
					} else if (key.sym == SDLK_RIGHT) {
						ch = 0b11000011;
					} else if (key.sym == SDLK_DOWN) {
						ch = 0b11000100;
					} else if (key.sym == SDLK_LEFT) {
						ch = 0b11000101;
					}
				break;
				case SDL_KEYUP:
					if (key.unicode >= ' ' && key.unicode <= '~') {// if it's a character
						ch = key.unicode&0x7F;
					} else if (key.sym == SDLK_BACKSPACE) {
						ch = 0x08;
					} else if (key.sym == SDLK_RETURN) {
						ch = 0x0A;
					} else if (key.sym == SDLK_UP) {
						ch = 0b11000010;
					} else if (key.sym == SDLK_RIGHT) {
						ch = 0b11000011;
					} else if (key.sym == SDLK_DOWN) {
						ch = 0b11000100;
					} else if (key.sym == SDLK_LEFT) {
						ch = 0b11000101;
					}
					ch |= 0b10000000;
# undef key
				break;
				case SDL_QUIT:
				    running = 0;
				break;
				default: 
				break;
			}
			
			if (ch != -1) {
				keyboardbuffer[keyindex++] = ch;
				keyindex = keyindex % 1024;
			} 
		
			if (keyindex != processed) {
				requestInterrupt(cpu, 0xD7);
			}
		}
		
		serviceDisplay();
		
		// Attempt to execute x number of cycles (which will most likely overshoot)
		actual_cycles = (double) executeCycles(cpu, (int) target_cycles); 
		
#ifdef DEBUG_LOOP
		printf("\nTarget cycles: %i Actual cycles: %i ", (int) target_cycles, (int) actual_cycles);
#endif
        // Calculate the target number of cycles to execute for next loop
        // Not all instructions are of uniform cycle count, so the last instruction may very well take more cycles than we had hoped to execute
		target_cycles = cycles_per_loop + target_cycles - actual_cycles;   
		
#ifdef DEBUG_LOOP
		printf("Next target:   %i\n", (int) target_cycles);
#endif
        // Account for any error in the previous delay function
        // Time calculations are done at the end of current loop for previous loop in order to better account for time
        // taken in function calls and loops
		actual_time = cycle_end - previous_cycle_start; 
		
#ifdef DEBUG_LOOP
		printf("Target time:   %i Actual time:   %i ", target_time, actual_time);
#endif

		// If our actual time was perfect, then the emulator will be set to execute every EXECUTION_INTERVAL number of microseconds
		target_time = EXECUTION_INTERVAL + target_time - actual_time;
		
#ifdef DEBUG_LOOP
		printf("Next target:   %i\n", target_time);
#endif
		
		// Get number of microseconds used for the calculations, and execution of emulator
		getMicroSeconds(&cycle_end); 
		// Delay to achieve the 'target' amount of time that should be consumed (cycle_end - cycle_start is calculation time)
		delayMicroSeconds(target_time - (cycle_end - cycle_start)); 
		
		// Record current start time for use at the start of next loop
		previous_cycle_start = cycle_start;
		// Recalculate cycle_end to account for any overshooting in the delay
		getMicroSeconds(&cycle_end);
		// Set this cycle start as the end of the last cycle
		cycle_start = cycle_end;
	}
	
	SDL_Quit();
	freeCPU(cpu);
	getchar();
	fflush(stdin);
	return 0;
}
