#include "video.h"
#include "keyboard.h"
#include "disk_controller.h"
#include "memory.h"
#include "..\\I8080\\I8080.h"

void port01_display_mode(I8080 *cpu);
void port02_operation(I8080 *cpu);
void port03_charin(I8080 *cpu);
void port04_keyout(I8080 *cpu);
void port05_diskrx(I8080 *cpu);
void port06_disktx(I8080 *cpu);
void port0A_switch_bank(I8080 *cpu);

