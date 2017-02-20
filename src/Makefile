default: all

all: dpc

dpc: DPC.c delay
	gcc -Wall -o ../DPC DPC.c video.c ioports.c memory.c disk_controller.c delay.o ../I8080/I8080.o -lSDL2
	
delay:
	gcc -c delay.c
	
debug:
	gcc -o ../DPC -Wa,-adhln -g DPC.c video.c ioports.c memory.c disk_controller.c delay.o ../I8080/I8080.o -lSDL2 > DPC.asm