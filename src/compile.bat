@echo off

rem I know this is a bad way to link the DLLs but I'm too lazy to fix the linking issues
copy ..\bin\delay.dll
copy ..\bin\SDL.dll
copy ..\bin\drawing.dll
copy ..\I8080\I8080.dll

rem gcc -Wall -O3 -o DPC.exe DPC.c I8080.dll delay.dll drawing.dll -g -Wa,-adhls > out.asm
gcc -Wall -o ..\bin\DPC.exe DPC.c video.c ioports.c memory.c disk_controller.c I8080.dll delay.dll drawing.dll -lSDL
rem gcc -Wall -O3 -o ..\bin\GPU.exe gpu.c delay.dll drawing.dll -lSDL -lws2_32 

del delay.dll
del SDL.dll
del drawing.dll
move I8080.dll ..\bin\I8080.dll


pause