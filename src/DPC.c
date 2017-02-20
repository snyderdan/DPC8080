#include <stdio.h>
#include <stdint.h>
#include <time.h>

#include "../I8080/I8080.h"
#include "delay.h"
#include "video.h"
#include "ioports.h"
#include "keyboard.h"

# define EXECUTION_INTERVAL 1000   // microseconds
# define CPU_FREQUENCY      2000   // kilohertz

#undef main

int main() {
	
	char  ch;
	I8080 *cpu;
	FILE  *boot;
	int64_t target_time, delta_time;
	int running, lSize, result;
	int target_cycles, actual_cycles, cycles_per_loop;
	SDL_Event event;
	
	cpu  = newCPU();
	keyboardbuffer = malloc(1024);
	
	if (SDL_Init(SDL_INIT_EVERYTHING) != 0){
        printf("SDL_Init Error: %s", SDL_GetError());
        return 1;
    }
	initCPU(cpu);
	initMemory();
	initDisplay();
	initHardDrive();
	setMMU(cpu, myMMU);
	setIOPort(cpu, 1, port01_display_mode);
	setIOPort(cpu, 2, port02_operation);
	setIOPort(cpu, 3, port03_charin);
	setIOPort(cpu, 4, port04_keyout);
	setIOPort(cpu, 5, port05_diskrx);
	setIOPort(cpu, 6, port06_disktx);
	setIOPort(cpu, 0xA, port0A_switch_bank);
	
	boot = fopen("bios/BIOS.bin", "rb");
	fseek(boot , 0 , SEEK_END);
    lSize  = ftell(boot);
    rewind(boot);
    result = fread(memBanks[0], 1, lSize, boot);
	
	if (result != lSize) {fputs ("Reading error",stderr); exit (3);}
	
	fclose(boot);
	
	cycles_per_loop = EXECUTION_INTERVAL * (CPU_FREQUENCY / 1000.0);
	target_cycles   = cycles_per_loop;
	
	target_time = getMicroSeconds();	// set start time of run
	
	running = 1;
	
	while (running) {
		
		while (SDL_PollEvent(&event)) {
			ch = -1;
			switch (event.type) {
				case SDL_KEYDOWN:
# define key event.key.keysym
				    if (key.sym >= ' ' && key.sym <= '~') {// if it's a character
						ch = key.sym&0x7F;
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
					if (key.sym >= ' ' && key.sym <= '~') {// if it's a character
						ch = key.sym&0x7F;
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
				requestInterrupt(cpu, 0xCF);
			}
		}
		
		serviceDisplay();
		
		// Attempt to execute x number of cycles (which will most likely overshoot)
		actual_cycles = executeCycles(cpu, target_cycles); 
        // Calculate the target number of cycles to execute for next loop
        // Not all instructions are of uniform cycle count, so the last instruction may very well take more cycles than we had hoped to execute
		target_cycles = cycles_per_loop + target_cycles - actual_cycles;
		
		// the following code sets up a syncronized delay window
		// using absolute time as opposed to relative for each cycle.
		// this greatly simplifies the code while eliminating the 
		// issue of accumulating time that is unaccounted for
		
		target_time = target_time + EXECUTION_INTERVAL;		// calculate the next absolute time we want to be at
		
		delta_time = getMicroSeconds();						// get current absolute time
		
		delta_time = target_time - delta_time;				// calculate time difference
		
		delayMicroSeconds(delta_time);						// wait for specified time
		
	}
	
	SDL_Quit();
	freeCPU(cpu);
	getchar();
	fflush(stdin);
	return 0;
}
