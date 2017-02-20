   1              		.file	"DPC.c"
   2              		.text
   3              	.Ltext0:
   4              		.local	hold
   5              		.comm	hold,4,4
   6              		.comm	keyboardbuffer,8,8
   7              		.comm	keyindex,1,1
   8              		.comm	processed,1,1
   9              		.section	.rodata
  10              	.LC0:
  11 0000 53444C5F 		.string	"SDL_Init Error: %s"
  11      496E6974 
  11      20457272 
  11      6F723A20 
  11      257300
  12              	.LC1:
  13 0013 726200   		.string	"rb"
  14              	.LC2:
  15 0016 62696F73 		.string	"bios/BIOS.bin"
  15      2F42494F 
  15      532E6269 
  15      6E00
  16              	.LC3:
  17 0024 52656164 		.string	"Reading error"
  17      696E6720 
  17      6572726F 
  17      7200
  18              		.text
  19              		.globl	main
  21              	main:
  22              	.LFB508:
  23              		.file 1 "DPC.c"
   1:DPC.c         **** #include <stdio.h>
   2:DPC.c         **** #include <stdint.h>
   3:DPC.c         **** #include <time.h>
   4:DPC.c         **** 
   5:DPC.c         **** #include "../I8080/I8080.h"
   6:DPC.c         **** #include "delay.h"
   7:DPC.c         **** #include "video.h"
   8:DPC.c         **** #include "ioports.h"
   9:DPC.c         **** #include "keyboard.h"
  10:DPC.c         **** 
  11:DPC.c         **** # define EXECUTION_INTERVAL 1000   // microseconds
  12:DPC.c         **** # define CPU_FREQUENCY      2000   // kilohertz
  13:DPC.c         **** 
  14:DPC.c         **** #undef main
  15:DPC.c         **** 
  16:DPC.c         **** int main() {
  24              		.loc 1 16 0
  25              		.cfi_startproc
  26 0000 55       		pushq	%rbp
  27              		.cfi_def_cfa_offset 16
  28              		.cfi_offset 6, -16
  29 0001 4889E5   		movq	%rsp, %rbp
  30              		.cfi_def_cfa_register 6
  31 0004 4883C480 		addq	$-128, %rsp
  17:DPC.c         **** 	
  18:DPC.c         **** 	char  ch;
  19:DPC.c         **** 	I8080 *cpu;
  20:DPC.c         **** 	FILE  *boot;
  21:DPC.c         **** 	int64_t target_time, delta_time;
  22:DPC.c         **** 	int running, lSize, result;
  23:DPC.c         **** 	int target_cycles, actual_cycles, cycles_per_loop;
  24:DPC.c         **** 	SDL_Event event;
  25:DPC.c         **** 	
  26:DPC.c         **** 	cpu  = newCPU();
  32              		.loc 1 26 0
  33 0008 B8000000 		movl	$0, %eax
  33      00
  34 000d E8000000 		call	newCPU
  34      00
  35 0012 488945E0 		movq	%rax, -32(%rbp)
  27:DPC.c         **** 	keyboardbuffer = malloc(1024);
  36              		.loc 1 27 0
  37 0016 BF000400 		movl	$1024, %edi
  37      00
  38 001b E8000000 		call	malloc
  38      00
  39 0020 48890500 		movq	%rax, keyboardbuffer(%rip)
  39      000000
  28:DPC.c         **** 	
  29:DPC.c         **** 	if (SDL_Init(SDL_INIT_EVERYTHING) != 0){
  40              		.loc 1 29 0
  41 0027 BF317200 		movl	$29233, %edi
  41      00
  42 002c E8000000 		call	SDL_Init
  42      00
  43 0031 85C0     		testl	%eax, %eax
  44 0033 7421     		je	.L2
  30:DPC.c         ****         printf("SDL_Init Error: %s", SDL_GetError());
  45              		.loc 1 30 0
  46 0035 E8000000 		call	SDL_GetError
  46      00
  47 003a 4889C6   		movq	%rax, %rsi
  48 003d BF000000 		movl	$.LC0, %edi
  48      00
  49 0042 B8000000 		movl	$0, %eax
  49      00
  50 0047 E8000000 		call	printf
  50      00
  31:DPC.c         ****         return 1;
  51              		.loc 1 31 0
  52 004c B8010000 		movl	$1, %eax
  52      00
  53 0051 E9D30300 		jmp	.L29
  53      00
  54              	.L2:
  32:DPC.c         ****     }
  33:DPC.c         **** 	initCPU(cpu);
  55              		.loc 1 33 0
  56 0056 488B45E0 		movq	-32(%rbp), %rax
  57 005a 4889C7   		movq	%rax, %rdi
  58 005d E8000000 		call	initCPU
  58      00
  34:DPC.c         **** 	initMemory();
  59              		.loc 1 34 0
  60 0062 B8000000 		movl	$0, %eax
  60      00
  61 0067 E8000000 		call	initMemory
  61      00
  35:DPC.c         **** 	initDisplay();
  62              		.loc 1 35 0
  63 006c B8000000 		movl	$0, %eax
  63      00
  64 0071 E8000000 		call	initDisplay
  64      00
  36:DPC.c         **** 	initHardDrive();
  65              		.loc 1 36 0
  66 0076 B8000000 		movl	$0, %eax
  66      00
  67 007b E8000000 		call	initHardDrive
  67      00
  37:DPC.c         **** 	setMMU(cpu, myMMU);
  68              		.loc 1 37 0
  69 0080 488B45E0 		movq	-32(%rbp), %rax
  70 0084 BE000000 		movl	$myMMU, %esi
  70      00
  71 0089 4889C7   		movq	%rax, %rdi
  72 008c E8000000 		call	setMMU
  72      00
  38:DPC.c         **** 	setIOPort(cpu, 1, port01_display_mode);
  73              		.loc 1 38 0
  74 0091 488B45E0 		movq	-32(%rbp), %rax
  75 0095 BA000000 		movl	$port01_display_mode, %edx
  75      00
  76 009a BE010000 		movl	$1, %esi
  76      00
  77 009f 4889C7   		movq	%rax, %rdi
  78 00a2 E8000000 		call	setIOPort
  78      00
  39:DPC.c         **** 	setIOPort(cpu, 2, port02_operation);
  79              		.loc 1 39 0
  80 00a7 488B45E0 		movq	-32(%rbp), %rax
  81 00ab BA000000 		movl	$port02_operation, %edx
  81      00
  82 00b0 BE020000 		movl	$2, %esi
  82      00
  83 00b5 4889C7   		movq	%rax, %rdi
  84 00b8 E8000000 		call	setIOPort
  84      00
  40:DPC.c         **** 	setIOPort(cpu, 3, port03_charin);
  85              		.loc 1 40 0
  86 00bd 488B45E0 		movq	-32(%rbp), %rax
  87 00c1 BA000000 		movl	$port03_charin, %edx
  87      00
  88 00c6 BE030000 		movl	$3, %esi
  88      00
  89 00cb 4889C7   		movq	%rax, %rdi
  90 00ce E8000000 		call	setIOPort
  90      00
  41:DPC.c         **** 	setIOPort(cpu, 4, port04_keyout);
  91              		.loc 1 41 0
  92 00d3 488B45E0 		movq	-32(%rbp), %rax
  93 00d7 BA000000 		movl	$port04_keyout, %edx
  93      00
  94 00dc BE040000 		movl	$4, %esi
  94      00
  95 00e1 4889C7   		movq	%rax, %rdi
  96 00e4 E8000000 		call	setIOPort
  96      00
  42:DPC.c         **** 	setIOPort(cpu, 5, port05_diskrx);
  97              		.loc 1 42 0
  98 00e9 488B45E0 		movq	-32(%rbp), %rax
  99 00ed BA000000 		movl	$port05_diskrx, %edx
  99      00
 100 00f2 BE050000 		movl	$5, %esi
 100      00
 101 00f7 4889C7   		movq	%rax, %rdi
 102 00fa E8000000 		call	setIOPort
 102      00
  43:DPC.c         **** 	setIOPort(cpu, 6, port06_disktx);
 103              		.loc 1 43 0
 104 00ff 488B45E0 		movq	-32(%rbp), %rax
 105 0103 BA000000 		movl	$port06_disktx, %edx
 105      00
 106 0108 BE060000 		movl	$6, %esi
 106      00
 107 010d 4889C7   		movq	%rax, %rdi
 108 0110 E8000000 		call	setIOPort
 108      00
  44:DPC.c         **** 	setIOPort(cpu, 0xA, port0A_switch_bank);
 109              		.loc 1 44 0
 110 0115 488B45E0 		movq	-32(%rbp), %rax
 111 0119 BA000000 		movl	$port0A_switch_bank, %edx
 111      00
 112 011e BE0A0000 		movl	$10, %esi
 112      00
 113 0123 4889C7   		movq	%rax, %rdi
 114 0126 E8000000 		call	setIOPort
 114      00
  45:DPC.c         **** 	
  46:DPC.c         **** 	boot = fopen("bios/BIOS.bin", "rb");
 115              		.loc 1 46 0
 116 012b BE000000 		movl	$.LC1, %esi
 116      00
 117 0130 BF000000 		movl	$.LC2, %edi
 117      00
 118 0135 E8000000 		call	fopen
 118      00
 119 013a 488945D8 		movq	%rax, -40(%rbp)
  47:DPC.c         **** 	fseek(boot , 0 , SEEK_END);
 120              		.loc 1 47 0
 121 013e 488B45D8 		movq	-40(%rbp), %rax
 122 0142 BA020000 		movl	$2, %edx
 122      00
 123 0147 BE000000 		movl	$0, %esi
 123      00
 124 014c 4889C7   		movq	%rax, %rdi
 125 014f E8000000 		call	fseek
 125      00
  48:DPC.c         ****     lSize  = ftell(boot);
 126              		.loc 1 48 0
 127 0154 488B45D8 		movq	-40(%rbp), %rax
 128 0158 4889C7   		movq	%rax, %rdi
 129 015b E8000000 		call	ftell
 129      00
 130 0160 8945D4   		movl	%eax, -44(%rbp)
  49:DPC.c         ****     rewind(boot);
 131              		.loc 1 49 0
 132 0163 488B45D8 		movq	-40(%rbp), %rax
 133 0167 4889C7   		movq	%rax, %rdi
 134 016a E8000000 		call	rewind
 134      00
  50:DPC.c         ****     result = fread(memBanks[0], 1, lSize, boot);
 135              		.loc 1 50 0
 136 016f 8B45D4   		movl	-44(%rbp), %eax
 137 0172 4863D0   		movslq	%eax, %rdx
 138 0175 488B0500 		movq	memBanks(%rip), %rax
 138      000000
 139 017c 488B4DD8 		movq	-40(%rbp), %rcx
 140 0180 BE010000 		movl	$1, %esi
 140      00
 141 0185 4889C7   		movq	%rax, %rdi
 142 0188 E8000000 		call	fread
 142      00
 143 018d 8945D0   		movl	%eax, -48(%rbp)
  51:DPC.c         **** 	
  52:DPC.c         **** 	if (result != lSize) {fputs ("Reading error",stderr); exit (3);}
 144              		.loc 1 52 0
 145 0190 8B45D0   		movl	-48(%rbp), %eax
 146 0193 3B45D4   		cmpl	-44(%rbp), %eax
 147 0196 7428     		je	.L4
 148              		.loc 1 52 0 is_stmt 0 discriminator 1
 149 0198 488B0500 		movq	stderr(%rip), %rax
 149      000000
 150 019f 4889C1   		movq	%rax, %rcx
 151 01a2 BA0D0000 		movl	$13, %edx
 151      00
 152 01a7 BE010000 		movl	$1, %esi
 152      00
 153 01ac BF000000 		movl	$.LC3, %edi
 153      00
 154 01b1 E8000000 		call	fwrite
 154      00
 155 01b6 BF030000 		movl	$3, %edi
 155      00
 156 01bb E8000000 		call	exit
 156      00
 157              	.L4:
  53:DPC.c         **** 	
  54:DPC.c         **** 	fclose(boot);
 158              		.loc 1 54 0 is_stmt 1
 159 01c0 488B45D8 		movq	-40(%rbp), %rax
 160 01c4 4889C7   		movq	%rax, %rdi
 161 01c7 E8000000 		call	fclose
 161      00
  55:DPC.c         **** 	
  56:DPC.c         **** 	cycles_per_loop = EXECUTION_INTERVAL * (CPU_FREQUENCY / 1000.0);
 162              		.loc 1 56 0
 163 01cc C745CCD0 		movl	$2000, -52(%rbp)
 163      070000
  57:DPC.c         **** 	target_cycles   = cycles_per_loop;
 164              		.loc 1 57 0
 165 01d3 8B45CC   		movl	-52(%rbp), %eax
 166 01d6 8945E8   		movl	%eax, -24(%rbp)
  58:DPC.c         **** 	
  59:DPC.c         **** 	target_time = getMicroSeconds();	// set start time of run
 167              		.loc 1 59 0
 168 01d9 B8000000 		movl	$0, %eax
 168      00
 169 01de E8000000 		call	getMicroSeconds
 169      00
 170 01e3 488945F0 		movq	%rax, -16(%rbp)
  60:DPC.c         **** 	
  61:DPC.c         **** 	running = 1;
 171              		.loc 1 61 0
 172 01e7 C745EC01 		movl	$1, -20(%rbp)
 172      000000
  62:DPC.c         **** 	
  63:DPC.c         **** 	while (running) {
 173              		.loc 1 63 0
 174 01ee E9060200 		jmp	.L5
 174      00
 175              	.L27:
  64:DPC.c         **** 		
  65:DPC.c         **** 		while (SDL_PollEvent(&event)) {
  66:DPC.c         **** 			ch = -1;
 176              		.loc 1 66 0
 177 01f3 C645FFFF 		movb	$-1, -1(%rbp)
  67:DPC.c         **** 			switch (event.type) {
 178              		.loc 1 67 0
 179 01f7 8B4580   		movl	-128(%rbp), %eax
 180 01fa 3D000300 		cmpl	$768, %eax
 180      00
 181 01ff 741B     		je	.L8
 182 0201 3D010300 		cmpl	$769, %eax
 182      00
 183 0206 0F84A000 		je	.L9
 183      0000
 184 020c 3D000100 		cmpl	$256, %eax
 184      00
 185 0211 0F841001 		je	.L10
 185      0000
  68:DPC.c         **** 				case SDL_KEYDOWN:
  69:DPC.c         **** # define key event.key.keysym
  70:DPC.c         **** 				    if (key.sym >= ' ' && key.sym <= '~') {// if it's a character
  71:DPC.c         **** 						ch = key.sym&0x7F;
  72:DPC.c         **** 					} else if (key.sym == SDLK_BACKSPACE) {
  73:DPC.c         **** 						ch = 0x08;
  74:DPC.c         **** 					} else if (key.sym == SDLK_RETURN) {
  75:DPC.c         **** 						ch = 0x0A;
  76:DPC.c         **** 					} else if (key.sym == SDLK_UP) {
  77:DPC.c         **** 						ch = 0b11000010;
  78:DPC.c         **** 					} else if (key.sym == SDLK_RIGHT) {
  79:DPC.c         **** 						ch = 0b11000011;
  80:DPC.c         **** 					} else if (key.sym == SDLK_DOWN) {
  81:DPC.c         **** 						ch = 0b11000100;
  82:DPC.c         **** 					} else if (key.sym == SDLK_LEFT) {
  83:DPC.c         **** 						ch = 0b11000101;
  84:DPC.c         **** 					}
  85:DPC.c         **** 				break;
  86:DPC.c         **** 				case SDL_KEYUP:
  87:DPC.c         **** 					if (key.sym >= ' ' && key.sym <= '~') {// if it's a character
  88:DPC.c         **** 						ch = key.sym&0x7F;
  89:DPC.c         **** 					} else if (key.sym == SDLK_BACKSPACE) {
  90:DPC.c         **** 						ch = 0x08;
  91:DPC.c         **** 					} else if (key.sym == SDLK_RETURN) {
  92:DPC.c         **** 						ch = 0x0A;
  93:DPC.c         **** 					} else if (key.sym == SDLK_UP) {
  94:DPC.c         **** 						ch = 0b11000010;
  95:DPC.c         **** 					} else if (key.sym == SDLK_RIGHT) {
  96:DPC.c         **** 						ch = 0b11000011;
  97:DPC.c         **** 					} else if (key.sym == SDLK_DOWN) {
  98:DPC.c         **** 						ch = 0b11000100;
  99:DPC.c         **** 					} else if (key.sym == SDLK_LEFT) {
 100:DPC.c         **** 						ch = 0b11000101;
 101:DPC.c         **** 					}
 102:DPC.c         **** 					ch |= 0b10000000;
 103:DPC.c         **** # undef key
 104:DPC.c         **** 				break;
 105:DPC.c         **** 				case SDL_QUIT:
 106:DPC.c         **** 				    running = 0;
 107:DPC.c         **** 				break;
 108:DPC.c         **** 				default: 
 109:DPC.c         **** 				break;
 186              		.loc 1 109 0
 187 0217 E9150100 		jmp	.L18
 187      00
 188              	.L8:
  70:DPC.c         **** 						ch = key.sym&0x7F;
 189              		.loc 1 70 0
 190 021c 8B4594   		movl	-108(%rbp), %eax
 191 021f 83F81F   		cmpl	$31, %eax
 192 0222 7E16     		jle	.L11
  70:DPC.c         **** 						ch = key.sym&0x7F;
 193              		.loc 1 70 0 is_stmt 0 discriminator 1
 194 0224 8B4594   		movl	-108(%rbp), %eax
 195 0227 83F87E   		cmpl	$126, %eax
 196 022a 7F0E     		jg	.L11
  71:DPC.c         **** 					} else if (key.sym == SDLK_BACKSPACE) {
 197              		.loc 1 71 0 is_stmt 1
 198 022c 8B4594   		movl	-108(%rbp), %eax
 199 022f 83E07F   		andl	$127, %eax
 200 0232 8845FF   		movb	%al, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 201              		.loc 1 85 0
 202 0235 E9F60000 		jmp	.L30
 202      00
 203              	.L11:
  72:DPC.c         **** 						ch = 0x08;
 204              		.loc 1 72 0
 205 023a 8B4594   		movl	-108(%rbp), %eax
 206 023d 83F808   		cmpl	$8, %eax
 207 0240 7509     		jne	.L13
  73:DPC.c         **** 					} else if (key.sym == SDLK_RETURN) {
 208              		.loc 1 73 0
 209 0242 C645FF08 		movb	$8, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 210              		.loc 1 85 0
 211 0246 E9E50000 		jmp	.L30
 211      00
 212              	.L13:
  74:DPC.c         **** 						ch = 0x0A;
 213              		.loc 1 74 0
 214 024b 8B4594   		movl	-108(%rbp), %eax
 215 024e 83F80D   		cmpl	$13, %eax
 216 0251 7509     		jne	.L14
  75:DPC.c         **** 					} else if (key.sym == SDLK_UP) {
 217              		.loc 1 75 0
 218 0253 C645FF0A 		movb	$10, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 219              		.loc 1 85 0
 220 0257 E9D40000 		jmp	.L30
 220      00
 221              	.L14:
  76:DPC.c         **** 						ch = 0b11000010;
 222              		.loc 1 76 0
 223 025c 8B4594   		movl	-108(%rbp), %eax
 224 025f 3D520000 		cmpl	$1073741906, %eax
 224      40
 225 0264 7509     		jne	.L15
  77:DPC.c         **** 					} else if (key.sym == SDLK_RIGHT) {
 226              		.loc 1 77 0
 227 0266 C645FFC2 		movb	$-62, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 228              		.loc 1 85 0
 229 026a E9C10000 		jmp	.L30
 229      00
 230              	.L15:
  78:DPC.c         **** 						ch = 0b11000011;
 231              		.loc 1 78 0
 232 026f 8B4594   		movl	-108(%rbp), %eax
 233 0272 3D4F0000 		cmpl	$1073741903, %eax
 233      40
 234 0277 7509     		jne	.L16
  79:DPC.c         **** 					} else if (key.sym == SDLK_DOWN) {
 235              		.loc 1 79 0
 236 0279 C645FFC3 		movb	$-61, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 237              		.loc 1 85 0
 238 027d E9AE0000 		jmp	.L30
 238      00
 239              	.L16:
  80:DPC.c         **** 						ch = 0b11000100;
 240              		.loc 1 80 0
 241 0282 8B4594   		movl	-108(%rbp), %eax
 242 0285 3D510000 		cmpl	$1073741905, %eax
 242      40
 243 028a 7509     		jne	.L17
  81:DPC.c         **** 					} else if (key.sym == SDLK_LEFT) {
 244              		.loc 1 81 0
 245 028c C645FFC4 		movb	$-60, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 246              		.loc 1 85 0
 247 0290 E99B0000 		jmp	.L30
 247      00
 248              	.L17:
  82:DPC.c         **** 						ch = 0b11000101;
 249              		.loc 1 82 0
 250 0295 8B4594   		movl	-108(%rbp), %eax
 251 0298 3D500000 		cmpl	$1073741904, %eax
 251      40
 252 029d 0F858D00 		jne	.L30
 252      0000
  83:DPC.c         **** 					}
 253              		.loc 1 83 0
 254 02a3 C645FFC5 		movb	$-59, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 255              		.loc 1 85 0
 256 02a7 E9840000 		jmp	.L30
 256      00
 257              	.L9:
  87:DPC.c         **** 						ch = key.sym&0x7F;
 258              		.loc 1 87 0
 259 02ac 8B4594   		movl	-108(%rbp), %eax
 260 02af 83F81F   		cmpl	$31, %eax
 261 02b2 7E13     		jle	.L19
  87:DPC.c         **** 						ch = key.sym&0x7F;
 262              		.loc 1 87 0 is_stmt 0 discriminator 1
 263 02b4 8B4594   		movl	-108(%rbp), %eax
 264 02b7 83F87E   		cmpl	$126, %eax
 265 02ba 7F0B     		jg	.L19
  88:DPC.c         **** 					} else if (key.sym == SDLK_BACKSPACE) {
 266              		.loc 1 88 0 is_stmt 1
 267 02bc 8B4594   		movl	-108(%rbp), %eax
 268 02bf 83E07F   		andl	$127, %eax
 269 02c2 8845FF   		movb	%al, -1(%rbp)
 270 02c5 EB5A     		jmp	.L20
 271              	.L19:
  89:DPC.c         **** 						ch = 0x08;
 272              		.loc 1 89 0
 273 02c7 8B4594   		movl	-108(%rbp), %eax
 274 02ca 83F808   		cmpl	$8, %eax
 275 02cd 7506     		jne	.L21
  90:DPC.c         **** 					} else if (key.sym == SDLK_RETURN) {
 276              		.loc 1 90 0
 277 02cf C645FF08 		movb	$8, -1(%rbp)
 278 02d3 EB4C     		jmp	.L20
 279              	.L21:
  91:DPC.c         **** 						ch = 0x0A;
 280              		.loc 1 91 0
 281 02d5 8B4594   		movl	-108(%rbp), %eax
 282 02d8 83F80D   		cmpl	$13, %eax
 283 02db 7506     		jne	.L22
  92:DPC.c         **** 					} else if (key.sym == SDLK_UP) {
 284              		.loc 1 92 0
 285 02dd C645FF0A 		movb	$10, -1(%rbp)
 286 02e1 EB3E     		jmp	.L20
 287              	.L22:
  93:DPC.c         **** 						ch = 0b11000010;
 288              		.loc 1 93 0
 289 02e3 8B4594   		movl	-108(%rbp), %eax
 290 02e6 3D520000 		cmpl	$1073741906, %eax
 290      40
 291 02eb 7506     		jne	.L23
  94:DPC.c         **** 					} else if (key.sym == SDLK_RIGHT) {
 292              		.loc 1 94 0
 293 02ed C645FFC2 		movb	$-62, -1(%rbp)
 294 02f1 EB2E     		jmp	.L20
 295              	.L23:
  95:DPC.c         **** 						ch = 0b11000011;
 296              		.loc 1 95 0
 297 02f3 8B4594   		movl	-108(%rbp), %eax
 298 02f6 3D4F0000 		cmpl	$1073741903, %eax
 298      40
 299 02fb 7506     		jne	.L24
  96:DPC.c         **** 					} else if (key.sym == SDLK_DOWN) {
 300              		.loc 1 96 0
 301 02fd C645FFC3 		movb	$-61, -1(%rbp)
 302 0301 EB1E     		jmp	.L20
 303              	.L24:
  97:DPC.c         **** 						ch = 0b11000100;
 304              		.loc 1 97 0
 305 0303 8B4594   		movl	-108(%rbp), %eax
 306 0306 3D510000 		cmpl	$1073741905, %eax
 306      40
 307 030b 7506     		jne	.L25
  98:DPC.c         **** 					} else if (key.sym == SDLK_LEFT) {
 308              		.loc 1 98 0
 309 030d C645FFC4 		movb	$-60, -1(%rbp)
 310 0311 EB0E     		jmp	.L20
 311              	.L25:
  99:DPC.c         **** 						ch = 0b11000101;
 312              		.loc 1 99 0
 313 0313 8B4594   		movl	-108(%rbp), %eax
 314 0316 3D500000 		cmpl	$1073741904, %eax
 314      40
 315 031b 7504     		jne	.L20
 100:DPC.c         **** 					}
 316              		.loc 1 100 0
 317 031d C645FFC5 		movb	$-59, -1(%rbp)
 318              	.L20:
 102:DPC.c         **** # undef key
 319              		.loc 1 102 0
 320 0321 804DFF80 		orb	$-128, -1(%rbp)
 104:DPC.c         **** 				case SDL_QUIT:
 321              		.loc 1 104 0
 322 0325 EB0A     		jmp	.L18
 323              	.L10:
 106:DPC.c         **** 				break;
 324              		.loc 1 106 0
 325 0327 C745EC00 		movl	$0, -20(%rbp)
 325      000000
 107:DPC.c         **** 				default: 
 326              		.loc 1 107 0
 327 032e EB01     		jmp	.L18
 328              	.L30:
  85:DPC.c         **** 				case SDL_KEYUP:
 329              		.loc 1 85 0
 330 0330 90       		nop
 331              	.L18:
 110:DPC.c         **** 			}
 111:DPC.c         **** 			
 112:DPC.c         **** 			if (ch != -1) {
 332              		.loc 1 112 0
 333 0331 807DFFFF 		cmpb	$-1, -1(%rbp)
 334 0335 7431     		je	.L26
 113:DPC.c         **** 				keyboardbuffer[keyindex++] = ch;
 335              		.loc 1 113 0
 336 0337 488B0D00 		movq	keyboardbuffer(%rip), %rcx
 336      000000
 337 033e 0FB60500 		movzbl	keyindex(%rip), %eax
 337      000000
 338 0345 8D5001   		leal	1(%rax), %edx
 339 0348 88150000 		movb	%dl, keyindex(%rip)
 339      0000
 340 034e 0FB6C0   		movzbl	%al, %eax
 341 0351 488D1401 		leaq	(%rcx,%rax), %rdx
 342 0355 0FB645FF 		movzbl	-1(%rbp), %eax
 343 0359 8802     		movb	%al, (%rdx)
 114:DPC.c         **** 				keyindex = keyindex % 1024;
 344              		.loc 1 114 0
 345 035b 0FB60500 		movzbl	keyindex(%rip), %eax
 345      000000
 346 0362 88050000 		movb	%al, keyindex(%rip)
 346      0000
 347              	.L26:
 115:DPC.c         **** 			} 
 116:DPC.c         **** 		
 117:DPC.c         **** 			if (keyindex != processed) {
 348              		.loc 1 117 0
 349 0368 0FB61500 		movzbl	keyindex(%rip), %edx
 349      000000
 350 036f 0FB60500 		movzbl	processed(%rip), %eax
 350      000000
 351 0376 38C2     		cmpb	%al, %dl
 352 0378 7411     		je	.L6
 118:DPC.c         **** 				requestInterrupt(cpu, 0xCF);
 353              		.loc 1 118 0
 354 037a 488B45E0 		movq	-32(%rbp), %rax
 355 037e BECFFFFF 		movl	$-49, %esi
 355      FF
 356 0383 4889C7   		movq	%rax, %rdi
 357 0386 E8000000 		call	requestInterrupt
 357      00
 358              	.L6:
  65:DPC.c         **** 			ch = -1;
 359              		.loc 1 65 0
 360 038b 488D4580 		leaq	-128(%rbp), %rax
 361 038f 4889C7   		movq	%rax, %rdi
 362 0392 E8000000 		call	SDL_PollEvent
 362      00
 363 0397 85C0     		testl	%eax, %eax
 364 0399 0F8554FE 		jne	.L27
 364      FFFF
 119:DPC.c         **** 			}
 120:DPC.c         **** 		}
 121:DPC.c         **** 		
 122:DPC.c         **** 		serviceDisplay();
 365              		.loc 1 122 0
 366 039f B8000000 		movl	$0, %eax
 366      00
 367 03a4 E8000000 		call	serviceDisplay
 367      00
 123:DPC.c         **** 		
 124:DPC.c         **** 		// Attempt to execute x number of cycles (which will most likely overshoot)
 125:DPC.c         **** 		actual_cycles = executeCycles(cpu, target_cycles); 
 368              		.loc 1 125 0
 369 03a9 8B55E8   		movl	-24(%rbp), %edx
 370 03ac 488B45E0 		movq	-32(%rbp), %rax
 371 03b0 89D6     		movl	%edx, %esi
 372 03b2 4889C7   		movq	%rax, %rdi
 373 03b5 E8000000 		call	executeCycles
 373      00
 374 03ba 8945C8   		movl	%eax, -56(%rbp)
 126:DPC.c         ****         // Calculate the target number of cycles to execute for next loop
 127:DPC.c         ****         // Not all instructions are of uniform cycle count, so the last instruction may very well t
 128:DPC.c         **** 		target_cycles = cycles_per_loop + target_cycles - actual_cycles;
 375              		.loc 1 128 0
 376 03bd 8B55CC   		movl	-52(%rbp), %edx
 377 03c0 8B45E8   		movl	-24(%rbp), %eax
 378 03c3 01D0     		addl	%edx, %eax
 379 03c5 2B45C8   		subl	-56(%rbp), %eax
 380 03c8 8945E8   		movl	%eax, -24(%rbp)
 129:DPC.c         **** 		
 130:DPC.c         **** 		// the following code sets up a syncronized delay window
 131:DPC.c         **** 		// using absolute time as opposed to relative for each cycle.
 132:DPC.c         **** 		// this greatly simplifies the code while eliminating the 
 133:DPC.c         **** 		// issue of accumulating time that is unaccounted for
 134:DPC.c         **** 		
 135:DPC.c         **** 		target_time = target_time + EXECUTION_INTERVAL;		// calculate the next absolute time we want to b
 381              		.loc 1 135 0
 382 03cb 488145F0 		addq	$1000, -16(%rbp)
 382      E8030000 
 136:DPC.c         **** 		
 137:DPC.c         **** 		delta_time = getMicroSeconds();						// get current absolute time
 383              		.loc 1 137 0
 384 03d3 B8000000 		movl	$0, %eax
 384      00
 385 03d8 E8000000 		call	getMicroSeconds
 385      00
 386 03dd 488945C0 		movq	%rax, -64(%rbp)
 138:DPC.c         **** 		
 139:DPC.c         **** 		delta_time = target_time - delta_time;				// calculate time difference
 387              		.loc 1 139 0
 388 03e1 488B45F0 		movq	-16(%rbp), %rax
 389 03e5 482B45C0 		subq	-64(%rbp), %rax
 390 03e9 488945C0 		movq	%rax, -64(%rbp)
 140:DPC.c         **** 		
 141:DPC.c         **** 		delayMicroSeconds(delta_time);						// wait for specified time
 391              		.loc 1 141 0
 392 03ed 488B45C0 		movq	-64(%rbp), %rax
 393 03f1 4889C7   		movq	%rax, %rdi
 394 03f4 E8000000 		call	delayMicroSeconds
 394      00
 395              	.L5:
  63:DPC.c         **** 		
 396              		.loc 1 63 0
 397 03f9 837DEC00 		cmpl	$0, -20(%rbp)
 398 03fd 758C     		jne	.L6
 142:DPC.c         **** 		
 143:DPC.c         **** 	}
 144:DPC.c         **** 	
 145:DPC.c         **** 	SDL_Quit();
 399              		.loc 1 145 0
 400 03ff E8000000 		call	SDL_Quit
 400      00
 146:DPC.c         **** 	freeCPU(cpu);
 401              		.loc 1 146 0
 402 0404 488B45E0 		movq	-32(%rbp), %rax
 403 0408 4889C7   		movq	%rax, %rdi
 404 040b E8000000 		call	freeCPU
 404      00
 147:DPC.c         **** 	getchar();
 405              		.loc 1 147 0
 406 0410 E8000000 		call	getchar
 406      00
 148:DPC.c         **** 	fflush(stdin);
 407              		.loc 1 148 0
 408 0415 488B0500 		movq	stdin(%rip), %rax
 408      000000
 409 041c 4889C7   		movq	%rax, %rdi
 410 041f E8000000 		call	fflush
 410      00
 149:DPC.c         **** 	return 0;
 411              		.loc 1 149 0
 412 0424 B8000000 		movl	$0, %eax
 412      00
 413              	.L29:
 150:DPC.c         **** }
 414              		.loc 1 150 0 discriminator 1
 415 0429 C9       		leave
 416              		.cfi_def_cfa 7, 8
 417 042a C3       		ret
 418              		.cfi_endproc
 419              	.LFE508:
 421              	.Letext0:
 422              		.file 2 "/usr/lib/gcc/x86_64-pc-linux-gnu/6.3.1/include/stddef.h"
 423              		.file 3 "/usr/include/bits/types.h"
 424              		.file 4 "/usr/include/stdio.h"
 425              		.file 5 "/usr/include/libio.h"
 426              		.file 6 "/usr/include/bits/sys_errlist.h"
 427              		.file 7 "/usr/include/stdint.h"
 428              		.file 8 "/usr/include/time.h"
 429              		.file 9 "../I8080/I8080.h"
 430              		.file 10 "/usr/include/math.h"
 431              		.file 11 "/usr/include/SDL2/SDL_stdinc.h"
 432              		.file 12 "/usr/include/SDL2/SDL_pixels.h"
 433              		.file 13 "/usr/include/SDL2/SDL_rect.h"
 434              		.file 14 "/usr/include/SDL2/SDL_surface.h"
 435              		.file 15 "/usr/include/SDL2/SDL_video.h"
 436              		.file 16 "/usr/include/SDL2/SDL_scancode.h"
 437              		.file 17 "/usr/include/SDL2/SDL_keycode.h"
 438              		.file 18 "/usr/include/SDL2/SDL_keyboard.h"
 439              		.file 19 "/usr/include/SDL2/SDL_joystick.h"
 440              		.file 20 "/usr/include/SDL2/SDL_touch.h"
 441              		.file 21 "/usr/include/SDL2/SDL_gesture.h"
 442              		.file 22 "/usr/include/SDL2/SDL_events.h"
 443              		.file 23 "/usr/include/SDL2/SDL_messagebox.h"
 444              		.file 24 "video.h"
 445              		.file 25 "keyboard.h"
 446              		.file 26 "disk_controller.h"
 447              		.file 27 "memory.h"
   1              		.file	"video.c"
   2              		.text
   3              	.Ltext0:
   4              		.local	hold
   5              		.comm	hold,4,4
   6              		.comm	video,816,32
   7              		.globl	ReadPixel
   9              	ReadPixel:
  10              	.LFB508:
  11              		.file 1 "video.c"
   1:video.c       **** #include "video.h"
   2:video.c       **** #include <time.h>
   3:video.c       **** 
   4:video.c       **** Display video;
   5:video.c       **** 
   6:video.c       **** Uint32 ReadPixel(SDL_Surface* source, Sint16 X, Sint16 Y) {
  12              		.loc 1 6 0
  13              		.cfi_startproc
  14 0000 55       		pushq	%rbp
  15              		.cfi_def_cfa_offset 16
  16              		.cfi_offset 6, -16
  17 0001 4889E5   		movq	%rsp, %rbp
  18              		.cfi_def_cfa_register 6
  19 0004 48897DF8 		movq	%rdi, -8(%rbp)
  20 0008 89F1     		movl	%esi, %ecx
  21 000a 89D0     		movl	%edx, %eax
  22 000c 66894DF4 		movw	%cx, -12(%rbp)
  23 0010 668945F0 		movw	%ax, -16(%rbp)
   7:video.c       **** 	return *((Uint32 *) (source->pixels + X + (Y*source->pitch)));
  24              		.loc 1 7 0
  25 0014 488B45F8 		movq	-8(%rbp), %rax
  26 0018 488B5020 		movq	32(%rax), %rdx
  27 001c 480FBF4D 		movswq	-12(%rbp), %rcx
  27      F4
  28 0021 0FBF75F0 		movswl	-16(%rbp), %esi
  29 0025 488B45F8 		movq	-8(%rbp), %rax
  30 0029 8B4018   		movl	24(%rax), %eax
  31 002c 0FAFC6   		imull	%esi, %eax
  32 002f 4898     		cltq
  33 0031 4801C8   		addq	%rcx, %rax
  34 0034 4801D0   		addq	%rdx, %rax
  35 0037 8B00     		movl	(%rax), %eax
   8:video.c       **** }
  36              		.loc 1 8 0
  37 0039 5D       		popq	%rbp
  38              		.cfi_def_cfa 7, 8
  39 003a C3       		ret
  40              		.cfi_endproc
  41              	.LFE508:
  43              		.globl	DrawPixel
  45              	DrawPixel:
  46              	.LFB509:
   9:video.c       **** 
  10:video.c       **** void DrawPixel(SDL_Surface *surface, int x, int y, Uint32 color) {
  47              		.loc 1 10 0
  48              		.cfi_startproc
  49 003b 55       		pushq	%rbp
  50              		.cfi_def_cfa_offset 16
  51              		.cfi_offset 6, -16
  52 003c 4889E5   		movq	%rsp, %rbp
  53              		.cfi_def_cfa_register 6
  54 003f 48897DE8 		movq	%rdi, -24(%rbp)
  55 0043 8975E4   		movl	%esi, -28(%rbp)
  56 0046 8955E0   		movl	%edx, -32(%rbp)
  57 0049 894DDC   		movl	%ecx, -36(%rbp)
  11:video.c       **** 	Uint32 *currentpixel = (Uint32 *)(surface->pixels + x + (y*surface->pitch));
  58              		.loc 1 11 0
  59 004c 488B45E8 		movq	-24(%rbp), %rax
  60 0050 488B5020 		movq	32(%rax), %rdx
  61 0054 8B45E4   		movl	-28(%rbp), %eax
  62 0057 4863C8   		movslq	%eax, %rcx
  63 005a 488B45E8 		movq	-24(%rbp), %rax
  64 005e 8B4018   		movl	24(%rax), %eax
  65 0061 0FAF45E0 		imull	-32(%rbp), %eax
  66 0065 4898     		cltq
  67 0067 4801C8   		addq	%rcx, %rax
  68 006a 4801D0   		addq	%rdx, %rax
  69 006d 488945F8 		movq	%rax, -8(%rbp)
  12:video.c       **** 	*currentpixel = color;
  70              		.loc 1 12 0
  71 0071 488B45F8 		movq	-8(%rbp), %rax
  72 0075 8B55DC   		movl	-36(%rbp), %edx
  73 0078 8910     		movl	%edx, (%rax)
  13:video.c       **** }
  74              		.loc 1 13 0
  75 007a 90       		nop
  76 007b 5D       		popq	%rbp
  77              		.cfi_def_cfa 7, 8
  78 007c C3       		ret
  79              		.cfi_endproc
  80              	.LFE509:
  82              		.section	.rodata
  83              	.LC0:
  84 0000 726200   		.string	"rb"
  85              		.text
  86              		.globl	loadSurface
  88              	loadSurface:
  89              	.LFB510:
  14:video.c       **** 
  15:video.c       **** SDL_Surface *loadSurface(char *path) {
  90              		.loc 1 15 0
  91              		.cfi_startproc
  92 007d 55       		pushq	%rbp
  93              		.cfi_def_cfa_offset 16
  94              		.cfi_offset 6, -16
  95 007e 4889E5   		movq	%rsp, %rbp
  96              		.cfi_def_cfa_register 6
  97 0081 4883EC40 		subq	$64, %rsp
  98 0085 48897DC8 		movq	%rdi, -56(%rbp)
  16:video.c       **** 	SDL_Surface *loaded, *optimized, *scaled;
  17:video.c       **** 	SDL_Rect dest;
  18:video.c       **** 	
  19:video.c       **** 	loaded = SDL_LoadBMP(path);
  99              		.loc 1 19 0
 100 0089 488B45C8 		movq	-56(%rbp), %rax
 101 008d BE000000 		movl	$.LC0, %esi
 101      00
 102 0092 4889C7   		movq	%rax, %rdi
 103 0095 E8000000 		call	SDL_RWFromFile
 103      00
 104 009a BE010000 		movl	$1, %esi
 104      00
 105 009f 4889C7   		movq	%rax, %rdi
 106 00a2 E8000000 		call	SDL_LoadBMP_RW
 106      00
 107 00a7 488945F8 		movq	%rax, -8(%rbp)
  20:video.c       **** 	optimized = SDL_ConvertSurface(loaded, video.screen->format, 0);
 108              		.loc 1 20 0
 109 00ab 488B0500 		movq	video+8(%rip), %rax
 109      000000
 110 00b2 488B4808 		movq	8(%rax), %rcx
 111 00b6 488B45F8 		movq	-8(%rbp), %rax
 112 00ba BA000000 		movl	$0, %edx
 112      00
 113 00bf 4889CE   		movq	%rcx, %rsi
 114 00c2 4889C7   		movq	%rax, %rdi
 115 00c5 E8000000 		call	SDL_ConvertSurface
 115      00
 116 00ca 488945F0 		movq	%rax, -16(%rbp)
  21:video.c       **** 	
  22:video.c       **** 	dest.x = 0;
 117              		.loc 1 22 0
 118 00ce C745D000 		movl	$0, -48(%rbp)
 118      000000
  23:video.c       **** 	dest.y = 0;
 119              		.loc 1 23 0
 120 00d5 C745D400 		movl	$0, -44(%rbp)
 120      000000
  24:video.c       **** 	dest.h = SCALE_FACTOR*optimized->h;
 121              		.loc 1 24 0
 122 00dc 488B45F0 		movq	-16(%rbp), %rax
 123 00e0 8B4014   		movl	20(%rax), %eax
 124 00e3 01C0     		addl	%eax, %eax
 125 00e5 8945DC   		movl	%eax, -36(%rbp)
  25:video.c       **** 	dest.w = SCALE_FACTOR*optimized->w;
 126              		.loc 1 25 0
 127 00e8 488B45F0 		movq	-16(%rbp), %rax
 128 00ec 8B4010   		movl	16(%rax), %eax
 129 00ef 01C0     		addl	%eax, %eax
 130 00f1 8945D8   		movl	%eax, -40(%rbp)
  26:video.c       **** 	
  27:video.c       **** 	scaled = SDL_CreateRGBSurface(optimized->flags, SCALE_FACTOR*optimized->w, SCALE_FACTOR*optimized-
  28:video.c       ****         optimized->format->Rmask, optimized->format->Gmask, optimized->format->Bmask, optimized->fo
 131              		.loc 1 28 0
 132 00f4 488B45F0 		movq	-16(%rbp), %rax
 133 00f8 488B4008 		movq	8(%rax), %rax
  27:video.c       ****         optimized->format->Rmask, optimized->format->Gmask, optimized->format->Bmask, optimized->fo
 134              		.loc 1 27 0
 135 00fc 8B7020   		movl	32(%rax), %esi
 136              		.loc 1 28 0
 137 00ff 488B45F0 		movq	-16(%rbp), %rax
 138 0103 488B4008 		movq	8(%rax), %rax
  27:video.c       ****         optimized->format->Rmask, optimized->format->Gmask, optimized->format->Bmask, optimized->fo
 139              		.loc 1 27 0
 140 0107 8B481C   		movl	28(%rax), %ecx
 141              		.loc 1 28 0
 142 010a 488B45F0 		movq	-16(%rbp), %rax
 143 010e 488B4008 		movq	8(%rax), %rax
  27:video.c       ****         optimized->format->Rmask, optimized->format->Gmask, optimized->format->Bmask, optimized->fo
 144              		.loc 1 27 0
 145 0112 448B4818 		movl	24(%rax), %r9d
 146              		.loc 1 28 0
 147 0116 488B45F0 		movq	-16(%rbp), %rax
 148 011a 488B4008 		movq	8(%rax), %rax
  27:video.c       ****         optimized->format->Rmask, optimized->format->Gmask, optimized->format->Bmask, optimized->fo
 149              		.loc 1 27 0
 150 011e 448B4014 		movl	20(%rax), %r8d
 151 0122 488B45F0 		movq	-16(%rbp), %rax
 152 0126 488B4008 		movq	8(%rax), %rax
 153 012a 0FB64010 		movzbl	16(%rax), %eax
 154 012e 0FB6D0   		movzbl	%al, %edx
 155 0131 488B45F0 		movq	-16(%rbp), %rax
 156 0135 8B4014   		movl	20(%rax), %eax
 157 0138 448D1400 		leal	(%rax,%rax), %r10d
 158 013c 488B45F0 		movq	-16(%rbp), %rax
 159 0140 8B4010   		movl	16(%rax), %eax
 160 0143 8D3C00   		leal	(%rax,%rax), %edi
 161 0146 488B45F0 		movq	-16(%rbp), %rax
 162 014a 8B00     		movl	(%rax), %eax
 163 014c 56       		pushq	%rsi
 164 014d 51       		pushq	%rcx
 165 014e 89D1     		movl	%edx, %ecx
 166 0150 4489D2   		movl	%r10d, %edx
 167 0153 89FE     		movl	%edi, %esi
 168 0155 89C7     		movl	%eax, %edi
 169 0157 E8000000 		call	SDL_CreateRGBSurface
 169      00
 170 015c 4883C410 		addq	$16, %rsp
 171 0160 488945E8 		movq	%rax, -24(%rbp)
  29:video.c       ****     
  30:video.c       ****     SDL_BlitScaled(optimized, NULL, scaled, &dest);
 172              		.loc 1 30 0
 173 0164 488D4DD0 		leaq	-48(%rbp), %rcx
 174 0168 488B55E8 		movq	-24(%rbp), %rdx
 175 016c 488B45F0 		movq	-16(%rbp), %rax
 176 0170 BE000000 		movl	$0, %esi
 176      00
 177 0175 4889C7   		movq	%rax, %rdi
 178 0178 E8000000 		call	SDL_UpperBlitScaled
 178      00
  31:video.c       ****     free(loaded);
 179              		.loc 1 31 0
 180 017d 488B45F8 		movq	-8(%rbp), %rax
 181 0181 4889C7   		movq	%rax, %rdi
 182 0184 E8000000 		call	free
 182      00
  32:video.c       ****     free(optimized);
 183              		.loc 1 32 0
 184 0189 488B45F0 		movq	-16(%rbp), %rax
 185 018d 4889C7   		movq	%rax, %rdi
 186 0190 E8000000 		call	free
 186      00
  33:video.c       ****     return scaled;
 187              		.loc 1 33 0
 188 0195 488B45E8 		movq	-24(%rbp), %rax
  34:video.c       **** }
 189              		.loc 1 34 0
 190 0199 C9       		leave
 191              		.cfi_def_cfa 7, 8
 192 019a C3       		ret
 193              		.cfi_endproc
 194              	.LFE510:
 196              		.section	.rodata
 197              	.LC1:
 198 0003 44504320 		.string	"DPC Emulator"
 198      456D756C 
 198      61746F72 
 198      00
 199              	.LC2:
 200 0010 63686172 		.string	"charmap/%d.bmp"
 200      6D61702F 
 200      25642E62 
 200      6D7000
 201              		.text
 202              		.globl	initDisplay
 204              	initDisplay:
 205              	.LFB511:
  35:video.c       **** 
  36:video.c       **** void initDisplay() {
 206              		.loc 1 36 0
 207              		.cfi_startproc
 208 019b 55       		pushq	%rbp
 209              		.cfi_def_cfa_offset 16
 210              		.cfi_offset 6, -16
 211 019c 4889E5   		movq	%rsp, %rbp
 212              		.cfi_def_cfa_register 6
 213 019f 4883EC20 		subq	$32, %rsp
  37:video.c       **** 	video.charBuffer  = calloc(1680, 1);
 214              		.loc 1 37 0
 215 01a3 BE010000 		movl	$1, %esi
 215      00
 216 01a8 BF900600 		movl	$1680, %edi
 216      00
 217 01ad E8000000 		call	calloc
 217      00
 218 01b2 48890500 		movq	%rax, video+792(%rip)
 218      000000
  38:video.c       **** 	video.pixelBuffer = calloc(0x5000, 1);
 219              		.loc 1 38 0
 220 01b9 BE010000 		movl	$1, %esi
 220      00
 221 01be BF005000 		movl	$20480, %edi
 221      00
 222 01c3 E8000000 		call	calloc
 222      00
 223 01c8 48890500 		movq	%rax, video+784(%rip)
 223      000000
  39:video.c       **** 	video.window 	  = SDL_CreateWindow("DPC Emulator", 0, 0, REAL_WIDTH, REAL_HEIGHT, SDL_WINDOW_SHOWN
 224              		.loc 1 39 0
 225 01cf 41B90400 		movl	$4, %r9d
 225      0000
 226 01d5 41B8C001 		movl	$448, %r8d
 226      0000
 227 01db B9D00200 		movl	$720, %ecx
 227      00
 228 01e0 BA000000 		movl	$0, %edx
 228      00
 229 01e5 BE000000 		movl	$0, %esi
 229      00
 230 01ea BF000000 		movl	$.LC1, %edi
 230      00
 231 01ef E8000000 		call	SDL_CreateWindow
 231      00
 232 01f4 48890500 		movq	%rax, video(%rip)
 232      000000
  40:video.c       **** 	video.screen	  = SDL_GetWindowSurface(video.window);
 233              		.loc 1 40 0
 234 01fb 488B0500 		movq	video(%rip), %rax
 234      000000
 235 0202 4889C7   		movq	%rax, %rdi
 236 0205 E8000000 		call	SDL_GetWindowSurface
 236      00
 237 020a 48890500 		movq	%rax, video+8(%rip)
 237      000000
  41:video.c       **** 	
  42:video.c       **** 	video.textOperation = APPEND_CHAR;
 238              		.loc 1 42 0
 239 0211 C6050000 		movb	$1, video+800(%rip)
 239      000001
  43:video.c       **** 	video.dirtyBuffer = 1;
 240              		.loc 1 43 0
 241 0218 C7050000 		movl	$1, video+808(%rip)
 241      00000100 
 241      0000
  44:video.c       **** 	video.cursorIndex = 0;
 242              		.loc 1 44 0
 243 0222 C7050000 		movl	$0, video+804(%rip)
 243      00000000 
 243      0000
  45:video.c       **** 	video.displayMode = HIGH_RES;
 244              		.loc 1 45 0
 245 022c C6050000 		movb	$0, video+801(%rip)
 245      000000
  46:video.c       **** 	
  47:video.c       **** 	int i; 
  48:video.c       **** 	
  49:video.c       **** 	for (i=0;i<95;i++) {
 246              		.loc 1 49 0
 247 0233 C745FC00 		movl	$0, -4(%rbp)
 247      000000
 248 023a EB3D     		jmp	.L7
 249              	.L8:
 250              	.LBB2:
  50:video.c       **** 		char buf[16];
  51:video.c       **** 		sprintf(buf, "charmap/%d.bmp", i);
 251              		.loc 1 51 0 discriminator 3
 252 023c 8B55FC   		movl	-4(%rbp), %edx
 253 023f 488D45E0 		leaq	-32(%rbp), %rax
 254 0243 BE000000 		movl	$.LC2, %esi
 254      00
 255 0248 4889C7   		movq	%rax, %rdi
 256 024b B8000000 		movl	$0, %eax
 256      00
 257 0250 E8000000 		call	sprintf
 257      00
  52:video.c       **** 		video.charMap[i] = loadSurface(buf);
 258              		.loc 1 52 0 discriminator 3
 259 0255 488D45E0 		leaq	-32(%rbp), %rax
 260 0259 4889C7   		movq	%rax, %rdi
 261 025c E8000000 		call	loadSurface
 261      00
 262 0261 4889C2   		movq	%rax, %rdx
 263 0264 8B45FC   		movl	-4(%rbp), %eax
 264 0267 4898     		cltq
 265 0269 4883C002 		addq	$2, %rax
 266 026d 488914C5 		movq	%rdx, video(,%rax,8)
 266      00000000 
 267              	.LBE2:
  49:video.c       **** 		char buf[16];
 268              		.loc 1 49 0 discriminator 3
 269 0275 8345FC01 		addl	$1, -4(%rbp)
 270              	.L7:
  49:video.c       **** 		char buf[16];
 271              		.loc 1 49 0 is_stmt 0 discriminator 1
 272 0279 837DFC5E 		cmpl	$94, -4(%rbp)
 273 027d 7EBD     		jle	.L8
  53:video.c       **** 	}
  54:video.c       **** 	
  55:video.c       **** 	video.charMap[95] = video.charMap[0];
 274              		.loc 1 55 0 is_stmt 1
 275 027f 488B0500 		movq	video+16(%rip), %rax
 275      000000
 276 0286 48890500 		movq	%rax, video+776(%rip)
 276      000000
  56:video.c       **** 	video.charBuffer[100] = 33;
 277              		.loc 1 56 0
 278 028d 488B0500 		movq	video+792(%rip), %rax
 278      000000
 279 0294 4883C064 		addq	$100, %rax
 280 0298 C60021   		movb	$33, (%rax)
  57:video.c       **** }
 281              		.loc 1 57 0
 282 029b 90       		nop
 283 029c C9       		leave
 284              		.cfi_def_cfa 7, 8
 285 029d C3       		ret
 286              		.cfi_endproc
 287              	.LFE511:
 289              		.globl	map_color8to32
 291              	map_color8to32:
 292              	.LFB512:
  58:video.c       **** 
  59:video.c       **** SDL_Color map_color8to32(Uint8 color) {
 293              		.loc 1 59 0
 294              		.cfi_startproc
 295 029e 55       		pushq	%rbp
 296              		.cfi_def_cfa_offset 16
 297              		.cfi_offset 6, -16
 298 029f 4889E5   		movq	%rsp, %rbp
 299              		.cfi_def_cfa_register 6
 300 02a2 89F8     		movl	%edi, %eax
 301 02a4 8845EC   		movb	%al, -20(%rbp)
  60:video.c       **** 	SDL_Color new;
  61:video.c       **** 	new.r = (int)(((color & 0b11100000) >> 5) * 36.42857);
 302              		.loc 1 61 0
 303 02a7 0FB645EC 		movzbl	-20(%rbp), %eax
 304 02ab C0E805   		shrb	$5, %al
 305 02ae 0FB6C0   		movzbl	%al, %eax
 306 02b1 660FEFC0 		pxor	%xmm0, %xmm0
 307 02b5 F20F2AC0 		cvtsi2sd	%eax, %xmm0
 308 02b9 F20F100D 		movsd	.LC3(%rip), %xmm1
 308      00000000 
 309 02c1 F20F59C1 		mulsd	%xmm1, %xmm0
 310 02c5 F20F2CC0 		cvttsd2si	%xmm0, %eax
 311 02c9 8845F0   		movb	%al, -16(%rbp)
  62:video.c       **** 	new.g = (int)(((color & 0b00011100) >> 2) * 36.42857);
 312              		.loc 1 62 0
 313 02cc 0FB645EC 		movzbl	-20(%rbp), %eax
 314 02d0 C1F802   		sarl	$2, %eax
 315 02d3 83E007   		andl	$7, %eax
 316 02d6 660FEFC0 		pxor	%xmm0, %xmm0
 317 02da F20F2AC0 		cvtsi2sd	%eax, %xmm0
 318 02de F20F100D 		movsd	.LC3(%rip), %xmm1
 318      00000000 
 319 02e6 F20F59C1 		mulsd	%xmm1, %xmm0
 320 02ea F20F2CC0 		cvttsd2si	%xmm0, %eax
 321 02ee 8845F1   		movb	%al, -15(%rbp)
  63:video.c       **** 	new.b = (int)((color & 0b00000011) * 85.0);
 322              		.loc 1 63 0
 323 02f1 0FB645EC 		movzbl	-20(%rbp), %eax
 324 02f5 83E003   		andl	$3, %eax
 325 02f8 660FEFC0 		pxor	%xmm0, %xmm0
 326 02fc F20F2AC0 		cvtsi2sd	%eax, %xmm0
 327 0300 F20F100D 		movsd	.LC4(%rip), %xmm1
 327      00000000 
 328 0308 F20F59C1 		mulsd	%xmm1, %xmm0
 329 030c F20F2CC0 		cvttsd2si	%xmm0, %eax
 330 0310 8845F2   		movb	%al, -14(%rbp)
  64:video.c       **** 	return new;
 331              		.loc 1 64 0
 332 0313 8B45F0   		movl	-16(%rbp), %eax
  65:video.c       **** }
 333              		.loc 1 65 0
 334 0316 5D       		popq	%rbp
 335              		.cfi_def_cfa 7, 8
 336 0317 C3       		ret
 337              		.cfi_endproc
 338              	.LFE512:
 340              		.globl	map_color2to32
 342              	map_color2to32:
 343              	.LFB513:
  66:video.c       **** 
  67:video.c       **** SDL_Color map_color2to32(Uint8 color) {
 344              		.loc 1 67 0
 345              		.cfi_startproc
 346 0318 55       		pushq	%rbp
 347              		.cfi_def_cfa_offset 16
 348              		.cfi_offset 6, -16
 349 0319 4889E5   		movq	%rsp, %rbp
 350              		.cfi_def_cfa_register 6
 351 031c 4883EC18 		subq	$24, %rsp
 352 0320 89F8     		movl	%edi, %eax
 353 0322 8845EC   		movb	%al, -20(%rbp)
  68:video.c       **** 	Uint8 map[] = {0xFF,0xAA,0x55,0x00};
 354              		.loc 1 68 0
 355 0325 C645F0FF 		movb	$-1, -16(%rbp)
 356 0329 C645F1AA 		movb	$-86, -15(%rbp)
 357 032d C645F255 		movb	$85, -14(%rbp)
 358 0331 C645F300 		movb	$0, -13(%rbp)
  69:video.c       **** 	return map_color8to32(map[color & 0b11]);
 359              		.loc 1 69 0
 360 0335 0FB645EC 		movzbl	-20(%rbp), %eax
 361 0339 83E003   		andl	$3, %eax
 362 033c 4898     		cltq
 363 033e 0FB64405 		movzbl	-16(%rbp,%rax), %eax
 363      F0
 364 0343 0FB6C0   		movzbl	%al, %eax
 365 0346 89C7     		movl	%eax, %edi
 366 0348 E8000000 		call	map_color8to32
 366      00
  70:video.c       **** }
 367              		.loc 1 70 0
 368 034d C9       		leave
 369              		.cfi_def_cfa 7, 8
 370 034e C3       		ret
 371              		.cfi_endproc
 372              	.LFE513:
 374              		.globl	updateScreen
 376              	updateScreen:
 377              	.LFB514:
  71:video.c       **** 
  72:video.c       **** void updateScreen() {
 378              		.loc 1 72 0
 379              		.cfi_startproc
 380 034f 55       		pushq	%rbp
 381              		.cfi_def_cfa_offset 16
 382              		.cfi_offset 6, -16
 383 0350 4889E5   		movq	%rsp, %rbp
 384              		.cfi_def_cfa_register 6
 385 0353 4883C480 		addq	$-128, %rsp
  73:video.c       ****     
  74:video.c       ****     if (video.displayMode == LOW_RES) {
 386              		.loc 1 74 0
 387 0357 0FB60500 		movzbl	video+801(%rip), %eax
 387      000000
 388 035e 3C01     		cmpb	$1, %al
 389 0360 0F850301 		jne	.L14
 389      0000
 390              	.LBB3:
  75:video.c       **** 	    int y, x, o_y, o_x;
  76:video.c       **** 	    int scale = SCALE_FACTOR * 2;
 391              		.loc 1 76 0
 392 0366 C745D004 		movl	$4, -48(%rbp)
 392      000000
  77:video.c       **** 	    for (x=0; x<LORES_WIDTH; x++) {
 393              		.loc 1 77 0
 394 036d C745F800 		movl	$0, -8(%rbp)
 394      000000
 395 0374 E9DE0000 		jmp	.L15
 395      00
 396              	.L22:
  78:video.c       **** 			for (y=0; y<LORES_HEIGHT; y++) {
 397              		.loc 1 78 0
 398 0379 C745FC00 		movl	$0, -4(%rbp)
 398      000000
 399 0380 E9C40000 		jmp	.L16
 399      00
 400              	.L21:
 401              	.LBB4:
  79:video.c       **** 				Uint8 *newpixel = video.pixelBuffer + x + (y*LORES_WIDTH);
 402              		.loc 1 79 0
 403 0385 488B0500 		movq	video+784(%rip), %rax
 403      000000
 404 038c 8B55F8   		movl	-8(%rbp), %edx
 405 038f 4863CA   		movslq	%edx, %rcx
 406 0392 8B55FC   		movl	-4(%rbp), %edx
 407 0395 69D2B400 		imull	$180, %edx, %edx
 407      0000
 408 039b 4863D2   		movslq	%edx, %rdx
 409 039e 4801CA   		addq	%rcx, %rdx
 410 03a1 4801D0   		addq	%rdx, %rax
 411 03a4 488945C8 		movq	%rax, -56(%rbp)
  80:video.c       **** 				SDL_Color c = map_color8to32(*newpixel);
 412              		.loc 1 80 0
 413 03a8 488B45C8 		movq	-56(%rbp), %rax
 414 03ac 0FB600   		movzbl	(%rax), %eax
 415 03af 0FB6C0   		movzbl	%al, %eax
 416 03b2 89C7     		movl	%eax, %edi
 417 03b4 E8000000 		call	map_color8to32
 417      00
 418 03b9 8945A0   		movl	%eax, -96(%rbp)
  81:video.c       **** 				Uint32 pixcol = SDL_MapRGB(video.screen->format, c.r, c.g, c.b);
 419              		.loc 1 81 0
 420 03bc 0FB645A2 		movzbl	-94(%rbp), %eax
 421 03c0 0FB6C8   		movzbl	%al, %ecx
 422 03c3 0FB645A1 		movzbl	-95(%rbp), %eax
 423 03c7 0FB6D0   		movzbl	%al, %edx
 424 03ca 0FB645A0 		movzbl	-96(%rbp), %eax
 425 03ce 0FB6F0   		movzbl	%al, %esi
 426 03d1 488B0500 		movq	video+8(%rip), %rax
 426      000000
 427 03d8 488B4008 		movq	8(%rax), %rax
 428 03dc 4889C7   		movq	%rax, %rdi
 429 03df E8000000 		call	SDL_MapRGB
 429      00
 430 03e4 8945C4   		movl	%eax, -60(%rbp)
  82:video.c       **** 				for (o_y=0; o_y<scale; o_y++) {
 431              		.loc 1 82 0
 432 03e7 C745F400 		movl	$0, -12(%rbp)
 432      000000
 433 03ee EB4D     		jmp	.L17
 434              	.L20:
  83:video.c       **** 					for (o_x=0; o_x<scale; o_x++) {
 435              		.loc 1 83 0
 436 03f0 C745F000 		movl	$0, -16(%rbp)
 436      000000
 437 03f7 EB38     		jmp	.L18
 438              	.L19:
  84:video.c       **** 						DrawPixel(video.screen, x*scale + o_x, y*scale + o_y, pixcol);
 439              		.loc 1 84 0 discriminator 3
 440 03f9 8B45FC   		movl	-4(%rbp), %eax
 441 03fc 0FAF45D0 		imull	-48(%rbp), %eax
 442 0400 89C2     		movl	%eax, %edx
 443 0402 8B45F4   		movl	-12(%rbp), %eax
 444 0405 8D3C02   		leal	(%rdx,%rax), %edi
 445 0408 8B45F8   		movl	-8(%rbp), %eax
 446 040b 0FAF45D0 		imull	-48(%rbp), %eax
 447 040f 89C2     		movl	%eax, %edx
 448 0411 8B45F0   		movl	-16(%rbp), %eax
 449 0414 8D3402   		leal	(%rdx,%rax), %esi
 450 0417 488B0500 		movq	video+8(%rip), %rax
 450      000000
 451 041e 8B55C4   		movl	-60(%rbp), %edx
 452 0421 89D1     		movl	%edx, %ecx
 453 0423 89FA     		movl	%edi, %edx
 454 0425 4889C7   		movq	%rax, %rdi
 455 0428 E8000000 		call	DrawPixel
 455      00
  83:video.c       **** 					for (o_x=0; o_x<scale; o_x++) {
 456              		.loc 1 83 0 discriminator 3
 457 042d 8345F001 		addl	$1, -16(%rbp)
 458              	.L18:
  83:video.c       **** 					for (o_x=0; o_x<scale; o_x++) {
 459              		.loc 1 83 0 is_stmt 0 discriminator 1
 460 0431 8B45F0   		movl	-16(%rbp), %eax
 461 0434 3B45D0   		cmpl	-48(%rbp), %eax
 462 0437 7CC0     		jl	.L19
  82:video.c       **** 				for (o_y=0; o_y<scale; o_y++) {
 463              		.loc 1 82 0 is_stmt 1 discriminator 2
 464 0439 8345F401 		addl	$1, -12(%rbp)
 465              	.L17:
  82:video.c       **** 				for (o_y=0; o_y<scale; o_y++) {
 466              		.loc 1 82 0 is_stmt 0 discriminator 1
 467 043d 8B45F4   		movl	-12(%rbp), %eax
 468 0440 3B45D0   		cmpl	-48(%rbp), %eax
 469 0443 7CAB     		jl	.L20
 470              	.LBE4:
  78:video.c       **** 				Uint8 *newpixel = video.pixelBuffer + x + (y*LORES_WIDTH);
 471              		.loc 1 78 0 is_stmt 1 discriminator 2
 472 0445 8345FC01 		addl	$1, -4(%rbp)
 473              	.L16:
  78:video.c       **** 				Uint8 *newpixel = video.pixelBuffer + x + (y*LORES_WIDTH);
 474              		.loc 1 78 0 is_stmt 0 discriminator 1
 475 0449 837DFC6F 		cmpl	$111, -4(%rbp)
 476 044d 0F8E32FF 		jle	.L21
 476      FFFF
  77:video.c       **** 			for (y=0; y<LORES_HEIGHT; y++) {
 477              		.loc 1 77 0 is_stmt 1 discriminator 2
 478 0453 8345F801 		addl	$1, -8(%rbp)
 479              	.L15:
  77:video.c       **** 			for (y=0; y<LORES_HEIGHT; y++) {
 480              		.loc 1 77 0 is_stmt 0 discriminator 1
 481 0457 817DF8B3 		cmpl	$179, -8(%rbp)
 481      000000
 482 045e 0F8E15FF 		jle	.L22
 482      FFFF
 483              	.LBE3:
  85:video.c       **** 					}
  86:video.c       **** 				}
  87:video.c       **** 			}
  88:video.c       **** 		}
  89:video.c       ****     } else if (video.displayMode == HIGH_RES) {
  90:video.c       **** 		int y, x, o_y, o_x, bi;
  91:video.c       **** 	    for (x=0; x<HIRES_WIDTH; x++) {
  92:video.c       **** 			for (y=0; y<HIRES_HEIGHT; y++) {
  93:video.c       **** 				Uint8 newpixel = * (Uint8 *)(video.pixelBuffer + x + (y*HIRES_WIDTH/4));
  94:video.c       **** 				for (bi=0; bi<4; bi++) {
  95:video.c       **** 					Uint8 id;
  96:video.c       **** 					id = (newpixel & (0x3 << (bi*2))) >> (bi*2);
  97:video.c       **** 					SDL_Color c = map_color2to32(id);
  98:video.c       **** 					Uint32 pixcol = SDL_MapRGB(video.screen->format, c.r, c.g, c.b);
  99:video.c       **** 					for (o_x=0; o_x<SCALE_FACTOR; o_x++) {
 100:video.c       **** 						for (o_y=0; o_y<SCALE_FACTOR; o_y++) {
 101:video.c       **** 							DrawPixel(video.screen, x*SCALE_FACTOR + o_x, y*SCALE_FACTOR + o_y, pixcol);
 102:video.c       **** 						}
 103:video.c       **** 					}
 104:video.c       **** 				}
 105:video.c       **** 			}
 106:video.c       **** 		}
 107:video.c       **** 	} else if (video.displayMode == TEXT_MODE) {
 108:video.c       **** 		int i, j;
 109:video.c       **** 		SDL_Rect dest;
 110:video.c       **** 		dest.y = 0;
 111:video.c       **** 		for (i=0; i<SCREEN_CHAR_H; i++) {
 112:video.c       **** 			dest.x = 0;
 113:video.c       **** 			for (j=0; j<SCREEN_CHAR_W; j++) {
 114:video.c       **** 				SDL_Surface *image = video.charMap[(int)video.charBuffer[j+i*SCREEN_CHAR_W]];
 115:video.c       **** 				SDL_BlitSurface(image, NULL, video.screen, &dest);
 116:video.c       **** 				dest.x += CHAR_WIDTH*SCALE_FACTOR;
 117:video.c       **** 			}
 118:video.c       **** 			dest.y += CHAR_HEIGHT*SCALE_FACTOR;
 119:video.c       **** 		}
 120:video.c       **** 	}
 121:video.c       **** }     
 484              		.loc 1 121 0 is_stmt 1
 485 0464 E9EC0100 		jmp	.L39
 485      00
 486              	.L14:
  89:video.c       **** 		int y, x, o_y, o_x, bi;
 487              		.loc 1 89 0
 488 0469 0FB60500 		movzbl	video+801(%rip), %eax
 488      000000
 489 0470 84C0     		testb	%al, %al
 490 0472 0F853901 		jne	.L24
 490      0000
 491              	.LBB5:
  91:video.c       **** 			for (y=0; y<HIRES_HEIGHT; y++) {
 492              		.loc 1 91 0
 493 0478 C745E800 		movl	$0, -24(%rbp)
 493      000000
 494 047f E91B0100 		jmp	.L25
 494      00
 495              	.L34:
  92:video.c       **** 				Uint8 newpixel = * (Uint8 *)(video.pixelBuffer + x + (y*HIRES_WIDTH/4));
 496              		.loc 1 92 0
 497 0484 C745EC00 		movl	$0, -20(%rbp)
 497      000000
 498 048b E9FE0000 		jmp	.L26
 498      00
 499              	.L33:
 500              	.LBB6:
  93:video.c       **** 				for (bi=0; bi<4; bi++) {
 501              		.loc 1 93 0
 502 0490 488B1500 		movq	video+784(%rip), %rdx
 502      000000
 503 0497 8B45E8   		movl	-24(%rbp), %eax
 504 049a 4863C8   		movslq	%eax, %rcx
 505 049d 8B45EC   		movl	-20(%rbp), %eax
 506 04a0 69C06801 		imull	$360, %eax, %eax
 506      0000
 507 04a6 8D7003   		leal	3(%rax), %esi
 508 04a9 85C0     		testl	%eax, %eax
 509 04ab 0F48C6   		cmovs	%esi, %eax
 510 04ae C1F802   		sarl	$2, %eax
 511 04b1 4898     		cltq
 512 04b3 4801C8   		addq	%rcx, %rax
 513 04b6 4801D0   		addq	%rdx, %rax
 514 04b9 0FB600   		movzbl	(%rax), %eax
 515 04bc 8845C3   		movb	%al, -61(%rbp)
  94:video.c       **** 					Uint8 id;
 516              		.loc 1 94 0
 517 04bf C745DC00 		movl	$0, -36(%rbp)
 517      000000
 518 04c6 E9B50000 		jmp	.L27
 518      00
 519              	.L32:
 520              	.LBB7:
  96:video.c       **** 					SDL_Color c = map_color2to32(id);
 521              		.loc 1 96 0
 522 04cb 0FB645C3 		movzbl	-61(%rbp), %eax
 523 04cf 8B55DC   		movl	-36(%rbp), %edx
 524 04d2 01D2     		addl	%edx, %edx
 525 04d4 BE030000 		movl	$3, %esi
 525      00
 526 04d9 89D1     		movl	%edx, %ecx
 527 04db D3E6     		sall	%cl, %esi
 528 04dd 89F2     		movl	%esi, %edx
 529 04df 21C2     		andl	%eax, %edx
 530 04e1 8B45DC   		movl	-36(%rbp), %eax
 531 04e4 01C0     		addl	%eax, %eax
 532 04e6 89C1     		movl	%eax, %ecx
 533 04e8 D3FA     		sarl	%cl, %edx
 534 04ea 89D0     		movl	%edx, %eax
 535 04ec 8845C2   		movb	%al, -62(%rbp)
  97:video.c       **** 					Uint32 pixcol = SDL_MapRGB(video.screen->format, c.r, c.g, c.b);
 536              		.loc 1 97 0
 537 04ef 0FB645C2 		movzbl	-62(%rbp), %eax
 538 04f3 89C7     		movl	%eax, %edi
 539 04f5 E8000000 		call	map_color2to32
 539      00
 540 04fa 894590   		movl	%eax, -112(%rbp)
  98:video.c       **** 					for (o_x=0; o_x<SCALE_FACTOR; o_x++) {
 541              		.loc 1 98 0
 542 04fd 0FB64592 		movzbl	-110(%rbp), %eax
 543 0501 0FB6C8   		movzbl	%al, %ecx
 544 0504 0FB64591 		movzbl	-111(%rbp), %eax
 545 0508 0FB6D0   		movzbl	%al, %edx
 546 050b 0FB64590 		movzbl	-112(%rbp), %eax
 547 050f 0FB6F0   		movzbl	%al, %esi
 548 0512 488B0500 		movq	video+8(%rip), %rax
 548      000000
 549 0519 488B4008 		movq	8(%rax), %rax
 550 051d 4889C7   		movq	%rax, %rdi
 551 0520 E8000000 		call	SDL_MapRGB
 551      00
 552 0525 8945BC   		movl	%eax, -68(%rbp)
  99:video.c       **** 						for (o_y=0; o_y<SCALE_FACTOR; o_y++) {
 553              		.loc 1 99 0
 554 0528 C745E000 		movl	$0, -32(%rbp)
 554      000000
 555 052f EB45     		jmp	.L28
 556              	.L31:
 100:video.c       **** 							DrawPixel(video.screen, x*SCALE_FACTOR + o_x, y*SCALE_FACTOR + o_y, pixcol);
 557              		.loc 1 100 0
 558 0531 C745E400 		movl	$0, -28(%rbp)
 558      000000
 559 0538 EB32     		jmp	.L29
 560              	.L30:
 101:video.c       **** 						}
 561              		.loc 1 101 0 discriminator 3
 562 053a 8B45EC   		movl	-20(%rbp), %eax
 563 053d 8D1400   		leal	(%rax,%rax), %edx
 564 0540 8B45E4   		movl	-28(%rbp), %eax
 565 0543 8D3C02   		leal	(%rdx,%rax), %edi
 566 0546 8B45E8   		movl	-24(%rbp), %eax
 567 0549 8D1400   		leal	(%rax,%rax), %edx
 568 054c 8B45E0   		movl	-32(%rbp), %eax
 569 054f 8D3402   		leal	(%rdx,%rax), %esi
 570 0552 488B0500 		movq	video+8(%rip), %rax
 570      000000
 571 0559 8B55BC   		movl	-68(%rbp), %edx
 572 055c 89D1     		movl	%edx, %ecx
 573 055e 89FA     		movl	%edi, %edx
 574 0560 4889C7   		movq	%rax, %rdi
 575 0563 E8000000 		call	DrawPixel
 575      00
 100:video.c       **** 							DrawPixel(video.screen, x*SCALE_FACTOR + o_x, y*SCALE_FACTOR + o_y, pixcol);
 576              		.loc 1 100 0 discriminator 3
 577 0568 8345E401 		addl	$1, -28(%rbp)
 578              	.L29:
 100:video.c       **** 							DrawPixel(video.screen, x*SCALE_FACTOR + o_x, y*SCALE_FACTOR + o_y, pixcol);
 579              		.loc 1 100 0 is_stmt 0 discriminator 1
 580 056c 837DE401 		cmpl	$1, -28(%rbp)
 581 0570 7EC8     		jle	.L30
  99:video.c       **** 						for (o_y=0; o_y<SCALE_FACTOR; o_y++) {
 582              		.loc 1 99 0 is_stmt 1 discriminator 2
 583 0572 8345E001 		addl	$1, -32(%rbp)
 584              	.L28:
  99:video.c       **** 						for (o_y=0; o_y<SCALE_FACTOR; o_y++) {
 585              		.loc 1 99 0 is_stmt 0 discriminator 1
 586 0576 837DE001 		cmpl	$1, -32(%rbp)
 587 057a 7EB5     		jle	.L31
 588              	.LBE7:
  94:video.c       **** 					Uint8 id;
 589              		.loc 1 94 0 is_stmt 1 discriminator 2
 590 057c 8345DC01 		addl	$1, -36(%rbp)
 591              	.L27:
  94:video.c       **** 					Uint8 id;
 592              		.loc 1 94 0 is_stmt 0 discriminator 1
 593 0580 837DDC03 		cmpl	$3, -36(%rbp)
 594 0584 0F8E41FF 		jle	.L32
 594      FFFF
 595              	.LBE6:
  92:video.c       **** 				Uint8 newpixel = * (Uint8 *)(video.pixelBuffer + x + (y*HIRES_WIDTH/4));
 596              		.loc 1 92 0 is_stmt 1 discriminator 2
 597 058a 8345EC01 		addl	$1, -20(%rbp)
 598              	.L26:
  92:video.c       **** 				Uint8 newpixel = * (Uint8 *)(video.pixelBuffer + x + (y*HIRES_WIDTH/4));
 599              		.loc 1 92 0 is_stmt 0 discriminator 1
 600 058e 817DECDF 		cmpl	$223, -20(%rbp)
 600      000000
 601 0595 0F8EF5FE 		jle	.L33
 601      FFFF
  91:video.c       **** 			for (y=0; y<HIRES_HEIGHT; y++) {
 602              		.loc 1 91 0 is_stmt 1 discriminator 2
 603 059b 8345E801 		addl	$1, -24(%rbp)
 604              	.L25:
  91:video.c       **** 			for (y=0; y<HIRES_HEIGHT; y++) {
 605              		.loc 1 91 0 is_stmt 0 discriminator 1
 606 059f 817DE867 		cmpl	$359, -24(%rbp)
 606      010000
 607 05a6 0F8ED8FE 		jle	.L34
 607      FFFF
 608              	.LBE5:
 609              		.loc 1 121 0 is_stmt 1
 610 05ac E9A40000 		jmp	.L39
 610      00
 611              	.L24:
 107:video.c       **** 		int i, j;
 612              		.loc 1 107 0
 613 05b1 0FB60500 		movzbl	video+801(%rip), %eax
 613      000000
 614 05b8 3C02     		cmpb	$2, %al
 615 05ba 0F859500 		jne	.L39
 615      0000
 616              	.LBB8:
 110:video.c       **** 		for (i=0; i<SCREEN_CHAR_H; i++) {
 617              		.loc 1 110 0
 618 05c0 C7458400 		movl	$0, -124(%rbp)
 618      000000
 111:video.c       **** 			dest.x = 0;
 619              		.loc 1 111 0
 620 05c7 C745D800 		movl	$0, -40(%rbp)
 620      000000
 621 05ce EB7B     		jmp	.L35
 622              	.L38:
 112:video.c       **** 			for (j=0; j<SCREEN_CHAR_W; j++) {
 623              		.loc 1 112 0
 624 05d0 C7458000 		movl	$0, -128(%rbp)
 624      000000
 113:video.c       **** 				SDL_Surface *image = video.charMap[(int)video.charBuffer[j+i*SCREEN_CHAR_W]];
 625              		.loc 1 113 0
 626 05d7 C745D400 		movl	$0, -44(%rbp)
 626      000000
 627 05de EB58     		jmp	.L36
 628              	.L37:
 629              	.LBB9:
 114:video.c       **** 				SDL_BlitSurface(image, NULL, video.screen, &dest);
 630              		.loc 1 114 0 discriminator 3
 631 05e0 488B1500 		movq	video+792(%rip), %rdx
 631      000000
 632 05e7 8B45D8   		movl	-40(%rbp), %eax
 633 05ea 6BC83C   		imull	$60, %eax, %ecx
 634 05ed 8B45D4   		movl	-44(%rbp), %eax
 635 05f0 01C8     		addl	%ecx, %eax
 636 05f2 4898     		cltq
 637 05f4 4801D0   		addq	%rdx, %rax
 638 05f7 0FB600   		movzbl	(%rax), %eax
 639 05fa 0FB6C0   		movzbl	%al, %eax
 640 05fd 4898     		cltq
 641 05ff 4883C002 		addq	$2, %rax
 642 0603 488B04C5 		movq	video(,%rax,8), %rax
 642      00000000 
 643 060b 488945B0 		movq	%rax, -80(%rbp)
 115:video.c       **** 				dest.x += CHAR_WIDTH*SCALE_FACTOR;
 644              		.loc 1 115 0 discriminator 3
 645 060f 488B1500 		movq	video+8(%rip), %rdx
 645      000000
 646 0616 488D4D80 		leaq	-128(%rbp), %rcx
 647 061a 488B45B0 		movq	-80(%rbp), %rax
 648 061e BE000000 		movl	$0, %esi
 648      00
 649 0623 4889C7   		movq	%rax, %rdi
 650 0626 E8000000 		call	SDL_UpperBlit
 650      00
 116:video.c       **** 			}
 651              		.loc 1 116 0 discriminator 3
 652 062b 8B4580   		movl	-128(%rbp), %eax
 653 062e 83C00C   		addl	$12, %eax
 654 0631 894580   		movl	%eax, -128(%rbp)
 655              	.LBE9:
 113:video.c       **** 				SDL_Surface *image = video.charMap[(int)video.charBuffer[j+i*SCREEN_CHAR_W]];
 656              		.loc 1 113 0 discriminator 3
 657 0634 8345D401 		addl	$1, -44(%rbp)
 658              	.L36:
 113:video.c       **** 				SDL_Surface *image = video.charMap[(int)video.charBuffer[j+i*SCREEN_CHAR_W]];
 659              		.loc 1 113 0 is_stmt 0 discriminator 1
 660 0638 837DD43B 		cmpl	$59, -44(%rbp)
 661 063c 7EA2     		jle	.L37
 118:video.c       **** 		}
 662              		.loc 1 118 0 is_stmt 1 discriminator 2
 663 063e 8B4584   		movl	-124(%rbp), %eax
 664 0641 83C010   		addl	$16, %eax
 665 0644 894584   		movl	%eax, -124(%rbp)
 111:video.c       **** 			dest.x = 0;
 666              		.loc 1 111 0 discriminator 2
 667 0647 8345D801 		addl	$1, -40(%rbp)
 668              	.L35:
 111:video.c       **** 			dest.x = 0;
 669              		.loc 1 111 0 is_stmt 0 discriminator 1
 670 064b 837DD81B 		cmpl	$27, -40(%rbp)
 671 064f 0F8E7BFF 		jle	.L38
 671      FFFF
 672              	.L39:
 673              	.LBE8:
 674              		.loc 1 121 0 is_stmt 1
 675 0655 90       		nop
 676 0656 C9       		leave
 677              		.cfi_def_cfa 7, 8
 678 0657 C3       		ret
 679              		.cfi_endproc
 680              	.LFE514:
 682              		.globl	serviceDisplay
 684              	serviceDisplay:
 685              	.LFB515:
 122:video.c       **** 
 123:video.c       **** void serviceDisplay() {
 686              		.loc 1 123 0
 687              		.cfi_startproc
 688 0658 55       		pushq	%rbp
 689              		.cfi_def_cfa_offset 16
 690              		.cfi_offset 6, -16
 691 0659 4889E5   		movq	%rsp, %rbp
 692              		.cfi_def_cfa_register 6
 124:video.c       **** 	if (video.dirtyBuffer) {
 693              		.loc 1 124 0
 694 065c 8B050000 		movl	video+808(%rip), %eax
 694      0000
 695 0662 85C0     		testl	%eax, %eax
 696 0664 7423     		je	.L42
 125:video.c       **** 			video.dirtyBuffer = 0;
 697              		.loc 1 125 0
 698 0666 C7050000 		movl	$0, video+808(%rip)
 698      00000000 
 698      0000
 126:video.c       **** 			updateScreen();
 699              		.loc 1 126 0
 700 0670 B8000000 		movl	$0, %eax
 700      00
 701 0675 E8000000 		call	updateScreen
 701      00
 127:video.c       **** 			SDL_UpdateWindowSurface(video.window);
 702              		.loc 1 127 0
 703 067a 488B0500 		movq	video(%rip), %rax
 703      000000
 704 0681 4889C7   		movq	%rax, %rdi
 705 0684 E8000000 		call	SDL_UpdateWindowSurface
 705      00
 706              	.L42:
 128:video.c       **** 	    }
 129:video.c       **** }       
 707              		.loc 1 129 0
 708 0689 90       		nop
 709 068a 5D       		popq	%rbp
 710              		.cfi_def_cfa 7, 8
 711 068b C3       		ret
 712              		.cfi_endproc
 713              	.LFE515:
 715              		.section	.rodata
 716 001f 00       		.align 8
 717              	.LC3:
 718 0020 FB05BB61 		.long	1639646715
 719 0024 DB364240 		.long	1078081243
 720              		.align 8
 721              	.LC4:
 722 0028 00000000 		.long	0
 723 002c 00405540 		.long	1079328768
 724              		.text
 725              	.Letext0:
 726              		.file 2 "/usr/lib/gcc/x86_64-pc-linux-gnu/6.3.1/include/stddef.h"
 727              		.file 3 "/usr/include/bits/types.h"
 728              		.file 4 "/usr/include/libio.h"
 729              		.file 5 "/usr/include/stdio.h"
 730              		.file 6 "/usr/include/bits/sys_errlist.h"
 731              		.file 7 "/usr/include/sys/types.h"
 732              		.file 8 "/usr/include/stdint.h"
 733              		.file 9 "/usr/include/math.h"
 734              		.file 10 "/usr/include/SDL2/SDL_stdinc.h"
 735              		.file 11 "/usr/include/SDL2/SDL_pixels.h"
 736              		.file 12 "/usr/include/SDL2/SDL_rect.h"
 737              		.file 13 "/usr/include/SDL2/SDL_surface.h"
 738              		.file 14 "/usr/include/SDL2/SDL_video.h"
 739              		.file 15 "/usr/include/SDL2/SDL_scancode.h"
 740              		.file 16 "/usr/include/SDL2/SDL_messagebox.h"
 741              		.file 17 "video.h"
 742              		.file 18 "/usr/include/time.h"
 743              		.file 19 "../I8080/I8080.h"
   1              		.file	"ioports.c"
   2              		.text
   3              	.Ltext0:
   4              		.local	hold
   5              		.comm	hold,4,4
   6              		.comm	keyboardbuffer,8,8
   7              		.comm	keyindex,1,1
   8              		.comm	processed,1,1
   9              		.globl	port01_display_mode
  11              	port01_display_mode:
  12              	.LFB508:
  13              		.file 1 "ioports.c"
   1:ioports.c     **** #include "ioports.h"
   2:ioports.c     **** 
   3:ioports.c     **** void port01_display_mode(I8080 *cpu) {
  14              		.loc 1 3 0
  15              		.cfi_startproc
  16 0000 55       		pushq	%rbp
  17              		.cfi_def_cfa_offset 16
  18              		.cfi_offset 6, -16
  19 0001 4889E5   		movq	%rsp, %rbp
  20              		.cfi_def_cfa_register 6
  21 0004 4883EC10 		subq	$16, %rsp
  22 0008 48897DF8 		movq	%rdi, -8(%rbp)
   4:ioports.c     **** 	if (isOutput(cpu)) {
  23              		.loc 1 4 0
  24 000c 488B45F8 		movq	-8(%rbp), %rax
  25 0010 4889C7   		movq	%rax, %rdi
  26 0013 E8000000 		call	getIOState
  26      00
  27 0018 85C0     		testl	%eax, %eax
  28 001a 741E     		je	.L2
   5:ioports.c     **** 		video.dirtyBuffer = 1;
  29              		.loc 1 5 0
  30 001c C7050000 		movl	$1, video+808(%rip)
  30      00000100 
  30      0000
   6:ioports.c     **** 		video.displayMode = getAccumulator(cpu);
  31              		.loc 1 6 0
  32 0026 488B45F8 		movq	-8(%rbp), %rax
  33 002a 4889C7   		movq	%rax, %rdi
  34 002d E8000000 		call	getAccumulator
  34      00
  35 0032 88050000 		movb	%al, video+801(%rip)
  35      0000
   7:ioports.c     **** 	} else {
   8:ioports.c     **** 		setAccumulator(cpu, video.displayMode);
   9:ioports.c     **** 	}
  10:ioports.c     **** }
  36              		.loc 1 10 0
  37 0038 EB18     		jmp	.L4
  38              	.L2:
   8:ioports.c     **** 	}
  39              		.loc 1 8 0
  40 003a 0FB60500 		movzbl	video+801(%rip), %eax
  40      000000
  41 0041 0FB6D0   		movzbl	%al, %edx
  42 0044 488B45F8 		movq	-8(%rbp), %rax
  43 0048 89D6     		movl	%edx, %esi
  44 004a 4889C7   		movq	%rax, %rdi
  45 004d E8000000 		call	setAccumulator
  45      00
  46              	.L4:
  47              		.loc 1 10 0
  48 0052 90       		nop
  49 0053 C9       		leave
  50              		.cfi_def_cfa 7, 8
  51 0054 C3       		ret
  52              		.cfi_endproc
  53              	.LFE508:
  55              		.globl	port02_operation
  57              	port02_operation:
  58              	.LFB509:
  11:ioports.c     **** 
  12:ioports.c     **** void port02_operation(I8080 *cpu) {
  59              		.loc 1 12 0
  60              		.cfi_startproc
  61 0055 55       		pushq	%rbp
  62              		.cfi_def_cfa_offset 16
  63              		.cfi_offset 6, -16
  64 0056 4889E5   		movq	%rsp, %rbp
  65              		.cfi_def_cfa_register 6
  66 0059 4883EC10 		subq	$16, %rsp
  67 005d 48897DF8 		movq	%rdi, -8(%rbp)
  13:ioports.c     **** 	if (isOutput(cpu)) {
  68              		.loc 1 13 0
  69 0061 488B45F8 		movq	-8(%rbp), %rax
  70 0065 4889C7   		movq	%rax, %rdi
  71 0068 E8000000 		call	getIOState
  71      00
  72 006d 85C0     		testl	%eax, %eax
  73 006f 7414     		je	.L6
  14:ioports.c     **** 		video.textOperation = getAccumulator(cpu);
  74              		.loc 1 14 0
  75 0071 488B45F8 		movq	-8(%rbp), %rax
  76 0075 4889C7   		movq	%rax, %rdi
  77 0078 E8000000 		call	getAccumulator
  77      00
  78 007d 88050000 		movb	%al, video+800(%rip)
  78      0000
  15:ioports.c     **** 	} else {
  16:ioports.c     **** 		setAccumulator(cpu, video.textOperation);
  17:ioports.c     **** 	}
  18:ioports.c     **** }
  79              		.loc 1 18 0
  80 0083 EB18     		jmp	.L8
  81              	.L6:
  16:ioports.c     **** 	}
  82              		.loc 1 16 0
  83 0085 0FB60500 		movzbl	video+800(%rip), %eax
  83      000000
  84 008c 0FB6D0   		movzbl	%al, %edx
  85 008f 488B45F8 		movq	-8(%rbp), %rax
  86 0093 89D6     		movl	%edx, %esi
  87 0095 4889C7   		movq	%rax, %rdi
  88 0098 E8000000 		call	setAccumulator
  88      00
  89              	.L8:
  90              		.loc 1 18 0
  91 009d 90       		nop
  92 009e C9       		leave
  93              		.cfi_def_cfa 7, 8
  94 009f C3       		ret
  95              		.cfi_endproc
  96              	.LFE509:
  98              		.globl	port03_charin
 100              	port03_charin:
 101              	.LFB510:
  19:ioports.c     **** 
  20:ioports.c     **** void port03_charin(I8080 *cpu) {
 102              		.loc 1 20 0
 103              		.cfi_startproc
 104 00a0 55       		pushq	%rbp
 105              		.cfi_def_cfa_offset 16
 106              		.cfi_offset 6, -16
 107 00a1 4889E5   		movq	%rsp, %rbp
 108              		.cfi_def_cfa_register 6
 109 00a4 53       		pushq	%rbx
 110 00a5 4883EC28 		subq	$40, %rsp
 111              		.cfi_offset 3, -24
 112 00a9 48897DD8 		movq	%rdi, -40(%rbp)
  21:ioports.c     **** 	video.dirtyBuffer = 1;
 113              		.loc 1 21 0
 114 00ad C7050000 		movl	$1, video+808(%rip)
 114      00000100 
 114      0000
  22:ioports.c     **** 	if (isOutput(cpu) && (video.textOperation == APPEND_CHAR)) {
 115              		.loc 1 22 0
 116 00b7 488B45D8 		movq	-40(%rbp), %rax
 117 00bb 4889C7   		movq	%rax, %rdi
 118 00be E8000000 		call	getIOState
 118      00
 119 00c3 85C0     		testl	%eax, %eax
 120 00c5 7440     		je	.L10
 121              		.loc 1 22 0 is_stmt 0 discriminator 1
 122 00c7 0FB60500 		movzbl	video+800(%rip), %eax
 122      000000
 123 00ce 3C01     		cmpb	$1, %al
 124 00d0 7535     		jne	.L10
  23:ioports.c     **** 		
  24:ioports.c     **** 		video.charBuffer[video.cursorIndex++] = (getAccumulator(cpu) & 0b01111111) - ' ';
 125              		.loc 1 24 0 is_stmt 1
 126 00d2 488B0D00 		movq	video+792(%rip), %rcx
 126      000000
 127 00d9 8B050000 		movl	video+804(%rip), %eax
 127      0000
 128 00df 8D5001   		leal	1(%rax), %edx
 129 00e2 89150000 		movl	%edx, video+804(%rip)
 129      0000
 130 00e8 4898     		cltq
 131 00ea 488D1C01 		leaq	(%rcx,%rax), %rbx
 132 00ee 488B45D8 		movq	-40(%rbp), %rax
 133 00f2 4889C7   		movq	%rax, %rdi
 134 00f5 E8000000 		call	getAccumulator
 134      00
 135 00fa 83E07F   		andl	$127, %eax
 136 00fd 83E820   		subl	$32, %eax
 137 0100 8803     		movb	%al, (%rbx)
 138 0102 E9490100 		jmp	.L9
 138      00
 139              	.L10:
  25:ioports.c     **** 		
  26:ioports.c     **** 	} else if (video.textOperation == DELETE_CHAR) {
 140              		.loc 1 26 0
 141 0107 0FB60500 		movzbl	video+800(%rip), %eax
 141      000000
 142 010e 84C0     		testb	%al, %al
 143 0110 756D     		jne	.L12
 144              	.LBB2:
  27:ioports.c     **** 		
  28:ioports.c     **** 		char pchar;
  29:ioports.c     **** 		
  30:ioports.c     **** 		if (video.cursorIndex == 0) {
 145              		.loc 1 30 0
 146 0112 8B050000 		movl	video+804(%rip), %eax
 146      0000
 147 0118 85C0     		testl	%eax, %eax
 148 011a 0F842F01 		je	.L20
 148      0000
 149              	.L13:
  31:ioports.c     **** 			return;
  32:ioports.c     **** 		}
  33:ioports.c     **** 		
  34:ioports.c     **** 		do {
  35:ioports.c     **** 			pchar = video.charBuffer[--video.cursorIndex];
 150              		.loc 1 35 0 discriminator 1
 151 0120 488B1500 		movq	video+792(%rip), %rdx
 151      000000
 152 0127 8B050000 		movl	video+804(%rip), %eax
 152      0000
 153 012d 83E801   		subl	$1, %eax
 154 0130 89050000 		movl	%eax, video+804(%rip)
 154      0000
 155 0136 8B050000 		movl	video+804(%rip), %eax
 155      0000
 156 013c 4898     		cltq
 157 013e 4801D0   		addq	%rdx, %rax
 158 0141 0FB600   		movzbl	(%rax), %eax
 159 0144 8845E7   		movb	%al, -25(%rbp)
  36:ioports.c     **** 			video.charBuffer[video.cursorIndex] = 0;
 160              		.loc 1 36 0 discriminator 1
 161 0147 488B1500 		movq	video+792(%rip), %rdx
 161      000000
 162 014e 8B050000 		movl	video+804(%rip), %eax
 162      0000
 163 0154 4898     		cltq
 164 0156 4801D0   		addq	%rdx, %rax
 165 0159 C60000   		movb	$0, (%rax)
  37:ioports.c     **** 		} while (pchar == 95);
 166              		.loc 1 37 0 discriminator 1
 167 015c 807DE75F 		cmpb	$95, -25(%rbp)
 168 0160 74BE     		je	.L13
  38:ioports.c     **** 		
  39:ioports.c     **** 		if (video.cursorIndex < 0) {
 169              		.loc 1 39 0
 170 0162 8B050000 		movl	video+804(%rip), %eax
 170      0000
 171 0168 85C0     		testl	%eax, %eax
 172 016a 0F89E000 		jns	.L9
 172      0000
  40:ioports.c     **** 			video.cursorIndex = 0;
 173              		.loc 1 40 0
 174 0170 C7050000 		movl	$0, video+804(%rip)
 174      00000000 
 174      0000
 175 017a E9D10000 		jmp	.L9
 175      00
 176              	.L12:
 177              	.LBE2:
  41:ioports.c     **** 		}
  42:ioports.c     **** 		
  43:ioports.c     **** 	} else if (video.textOperation == NEW_LINE) {
 178              		.loc 1 43 0
 179 017f 0FB60500 		movzbl	video+800(%rip), %eax
 179      000000
 180 0186 3C02     		cmpb	$2, %al
 181 0188 0F858000 		jne	.L15
 181      0000
 182              	.LBB3:
  44:ioports.c     **** 		
  45:ioports.c     **** 		int i, co = SCREEN_CHAR_W-(video.cursorIndex%SCREEN_CHAR_W);
 183              		.loc 1 45 0
 184 018e 8B0D0000 		movl	video+804(%rip), %ecx
 184      0000
 185 0194 BA898888 		movl	$-2004318071, %edx
 185      88
 186 0199 89C8     		movl	%ecx, %eax
 187 019b F7EA     		imull	%edx
 188 019d 8D040A   		leal	(%rdx,%rcx), %eax
 189 01a0 C1F805   		sarl	$5, %eax
 190 01a3 89C2     		movl	%eax, %edx
 191 01a5 89C8     		movl	%ecx, %eax
 192 01a7 C1F81F   		sarl	$31, %eax
 193 01aa 29C2     		subl	%eax, %edx
 194 01ac 89D0     		movl	%edx, %eax
 195 01ae 6BC03C   		imull	$60, %eax, %eax
 196 01b1 29C1     		subl	%eax, %ecx
 197 01b3 89C8     		movl	%ecx, %eax
 198 01b5 BA3C0000 		movl	$60, %edx
 198      00
 199 01ba 29C2     		subl	%eax, %edx
 200 01bc 89D0     		movl	%edx, %eax
 201 01be 8945E0   		movl	%eax, -32(%rbp)
  46:ioports.c     **** 	    
  47:ioports.c     **** 	    for (i=0; i<co;i++) {
 202              		.loc 1 47 0
 203 01c1 C745EC00 		movl	$0, -20(%rbp)
 203      000000
 204 01c8 EB22     		jmp	.L16
 205              	.L17:
  48:ioports.c     **** 			video.charBuffer[video.cursorIndex++] = 95;
 206              		.loc 1 48 0 discriminator 3
 207 01ca 488B0D00 		movq	video+792(%rip), %rcx
 207      000000
 208 01d1 8B050000 		movl	video+804(%rip), %eax
 208      0000
 209 01d7 8D5001   		leal	1(%rax), %edx
 210 01da 89150000 		movl	%edx, video+804(%rip)
 210      0000
 211 01e0 4898     		cltq
 212 01e2 4801C8   		addq	%rcx, %rax
 213 01e5 C6005F   		movb	$95, (%rax)
  47:ioports.c     **** 			video.charBuffer[video.cursorIndex++] = 95;
 214              		.loc 1 47 0 discriminator 3
 215 01e8 8345EC01 		addl	$1, -20(%rbp)
 216              	.L16:
  47:ioports.c     **** 			video.charBuffer[video.cursorIndex++] = 95;
 217              		.loc 1 47 0 is_stmt 0 discriminator 1
 218 01ec 8B45EC   		movl	-20(%rbp), %eax
 219 01ef 3B45E0   		cmpl	-32(%rbp), %eax
 220 01f2 7CD6     		jl	.L17
  49:ioports.c     **** 		}
  50:ioports.c     **** 		
  51:ioports.c     **** 		video.charBuffer[video.cursorIndex-co] = 0;
 221              		.loc 1 51 0 is_stmt 1
 222 01f4 488B1500 		movq	video+792(%rip), %rdx
 222      000000
 223 01fb 8B050000 		movl	video+804(%rip), %eax
 223      0000
 224 0201 2B45E0   		subl	-32(%rbp), %eax
 225 0204 4898     		cltq
 226 0206 4801D0   		addq	%rdx, %rax
 227 0209 C60000   		movb	$0, (%rax)
 228              	.LBE3:
 229 020c EB42     		jmp	.L9
 230              	.L15:
  52:ioports.c     **** 	} else if (video.textOperation == RESET) {
 231              		.loc 1 52 0
 232 020e 0FB60500 		movzbl	video+800(%rip), %eax
 232      000000
 233 0215 3C03     		cmpb	$3, %al
 234 0217 7537     		jne	.L9
 235              	.LBB4:
  53:ioports.c     **** 		int i;
  54:ioports.c     **** 		for (i=0; i<video.cursorIndex; i++) {
 236              		.loc 1 54 0
 237 0219 C745E800 		movl	$0, -24(%rbp)
 237      000000
 238 0220 EB16     		jmp	.L18
 239              	.L19:
  55:ioports.c     **** 			video.charBuffer[i] = 0;
 240              		.loc 1 55 0 discriminator 3
 241 0222 488B1500 		movq	video+792(%rip), %rdx
 241      000000
 242 0229 8B45E8   		movl	-24(%rbp), %eax
 243 022c 4898     		cltq
 244 022e 4801D0   		addq	%rdx, %rax
 245 0231 C60000   		movb	$0, (%rax)
  54:ioports.c     **** 			video.charBuffer[i] = 0;
 246              		.loc 1 54 0 discriminator 3
 247 0234 8345E801 		addl	$1, -24(%rbp)
 248              	.L18:
  54:ioports.c     **** 			video.charBuffer[i] = 0;
 249              		.loc 1 54 0 is_stmt 0 discriminator 1
 250 0238 8B050000 		movl	video+804(%rip), %eax
 250      0000
 251 023e 3B45E8   		cmpl	-24(%rbp), %eax
 252 0241 7FDF     		jg	.L19
  56:ioports.c     **** 		}
  57:ioports.c     **** 		video.cursorIndex = 0;
 253              		.loc 1 57 0 is_stmt 1
 254 0243 C7050000 		movl	$0, video+804(%rip)
 254      00000000 
 254      0000
 255 024d EB01     		jmp	.L9
 256              	.L20:
 257              	.LBE4:
 258              	.LBB5:
  31:ioports.c     **** 		}
 259              		.loc 1 31 0
 260 024f 90       		nop
 261              	.L9:
 262              	.LBE5:
  58:ioports.c     **** 	}
  59:ioports.c     **** }
 263              		.loc 1 59 0
 264 0250 4883C428 		addq	$40, %rsp
 265 0254 5B       		popq	%rbx
 266 0255 5D       		popq	%rbp
 267              		.cfi_def_cfa 7, 8
 268 0256 C3       		ret
 269              		.cfi_endproc
 270              	.LFE510:
 272              		.globl	port04_keyout
 274              	port04_keyout:
 275              	.LFB511:
  60:ioports.c     **** 
  61:ioports.c     **** void port04_keyout(I8080 *cpu) {
 276              		.loc 1 61 0
 277              		.cfi_startproc
 278 0257 55       		pushq	%rbp
 279              		.cfi_def_cfa_offset 16
 280              		.cfi_offset 6, -16
 281 0258 4889E5   		movq	%rsp, %rbp
 282              		.cfi_def_cfa_register 6
 283 025b 4883EC10 		subq	$16, %rsp
 284 025f 48897DF8 		movq	%rdi, -8(%rbp)
  62:ioports.c     **** 	if (isInput(cpu)) {
 285              		.loc 1 62 0
 286 0263 488B45F8 		movq	-8(%rbp), %rax
 287 0267 4889C7   		movq	%rax, %rdi
 288 026a E8000000 		call	getIOState
 288      00
 289 026f 85C0     		testl	%eax, %eax
 290 0271 7563     		jne	.L24
  63:ioports.c     **** 		if (keyindex == processed) {
 291              		.loc 1 63 0
 292 0273 0FB61500 		movzbl	keyindex(%rip), %edx
 292      000000
 293 027a 0FB60500 		movzbl	processed(%rip), %eax
 293      000000
 294 0281 38C2     		cmpb	%al, %dl
 295 0283 7513     		jne	.L23
  64:ioports.c     **** 			setAccumulator(cpu, 0);
 296              		.loc 1 64 0
 297 0285 488B45F8 		movq	-8(%rbp), %rax
 298 0289 BE000000 		movl	$0, %esi
 298      00
 299 028e 4889C7   		movq	%rax, %rdi
 300 0291 E8000000 		call	setAccumulator
 300      00
  65:ioports.c     **** 		} else {
  66:ioports.c     **** 			setAccumulator(cpu, (char) keyboardbuffer[processed++]);
  67:ioports.c     **** 			processed = processed % 1024;
  68:ioports.c     **** 		}
  69:ioports.c     **** 	}
  70:ioports.c     **** }
 301              		.loc 1 70 0
 302 0296 EB3E     		jmp	.L24
 303              	.L23:
  66:ioports.c     **** 			processed = processed % 1024;
 304              		.loc 1 66 0
 305 0298 488B0D00 		movq	keyboardbuffer(%rip), %rcx
 305      000000
 306 029f 0FB60500 		movzbl	processed(%rip), %eax
 306      000000
 307 02a6 8D5001   		leal	1(%rax), %edx
 308 02a9 88150000 		movb	%dl, processed(%rip)
 308      0000
 309 02af 0FB6C0   		movzbl	%al, %eax
 310 02b2 4801C8   		addq	%rcx, %rax
 311 02b5 0FB600   		movzbl	(%rax), %eax
 312 02b8 0FBED0   		movsbl	%al, %edx
 313 02bb 488B45F8 		movq	-8(%rbp), %rax
 314 02bf 89D6     		movl	%edx, %esi
 315 02c1 4889C7   		movq	%rax, %rdi
 316 02c4 E8000000 		call	setAccumulator
 316      00
  67:ioports.c     **** 		}
 317              		.loc 1 67 0
 318 02c9 0FB60500 		movzbl	processed(%rip), %eax
 318      000000
 319 02d0 88050000 		movb	%al, processed(%rip)
 319      0000
 320              	.L24:
 321              		.loc 1 70 0
 322 02d6 90       		nop
 323 02d7 C9       		leave
 324              		.cfi_def_cfa 7, 8
 325 02d8 C3       		ret
 326              		.cfi_endproc
 327              	.LFE511:
 329              		.globl	port05_diskrx
 331              	port05_diskrx:
 332              	.LFB512:
  71:ioports.c     **** 
  72:ioports.c     **** void port05_diskrx(I8080 *cpu) {
 333              		.loc 1 72 0
 334              		.cfi_startproc
 335 02d9 55       		pushq	%rbp
 336              		.cfi_def_cfa_offset 16
 337              		.cfi_offset 6, -16
 338 02da 4889E5   		movq	%rsp, %rbp
 339              		.cfi_def_cfa_register 6
 340 02dd 4883EC10 		subq	$16, %rsp
 341 02e1 48897DF8 		movq	%rdi, -8(%rbp)
  73:ioports.c     **** 	if (isInput(cpu)) {
 342              		.loc 1 73 0
 343 02e5 488B45F8 		movq	-8(%rbp), %rax
 344 02e9 4889C7   		movq	%rax, %rdi
 345 02ec E8000000 		call	getIOState
 345      00
 346 02f1 85C0     		testl	%eax, %eax
 347 02f3 751B     		jne	.L27
  74:ioports.c     **** 		setAccumulator(cpu, serialDiskRead());
 348              		.loc 1 74 0
 349 02f5 B8000000 		movl	$0, %eax
 349      00
 350 02fa E8000000 		call	serialDiskRead
 350      00
 351 02ff 0FBED0   		movsbl	%al, %edx
 352 0302 488B45F8 		movq	-8(%rbp), %rax
 353 0306 89D6     		movl	%edx, %esi
 354 0308 4889C7   		movq	%rax, %rdi
 355 030b E8000000 		call	setAccumulator
 355      00
 356              	.L27:
  75:ioports.c     **** 	}
  76:ioports.c     **** }
 357              		.loc 1 76 0
 358 0310 90       		nop
 359 0311 C9       		leave
 360              		.cfi_def_cfa 7, 8
 361 0312 C3       		ret
 362              		.cfi_endproc
 363              	.LFE512:
 365              		.globl	port06_disktx
 367              	port06_disktx:
 368              	.LFB513:
  77:ioports.c     **** 
  78:ioports.c     **** void port06_disktx(I8080 *cpu) {
 369              		.loc 1 78 0
 370              		.cfi_startproc
 371 0313 55       		pushq	%rbp
 372              		.cfi_def_cfa_offset 16
 373              		.cfi_offset 6, -16
 374 0314 4889E5   		movq	%rsp, %rbp
 375              		.cfi_def_cfa_register 6
 376 0317 4883EC10 		subq	$16, %rsp
 377 031b 48897DF8 		movq	%rdi, -8(%rbp)
  79:ioports.c     **** 	if (isOutput(cpu)) {
 378              		.loc 1 79 0
 379 031f 488B45F8 		movq	-8(%rbp), %rax
 380 0323 4889C7   		movq	%rax, %rdi
 381 0326 E8000000 		call	getIOState
 381      00
 382 032b 85C0     		testl	%eax, %eax
 383 032d 7416     		je	.L30
  80:ioports.c     **** 		serialDiskWrite(getAccumulator(cpu));
 384              		.loc 1 80 0
 385 032f 488B45F8 		movq	-8(%rbp), %rax
 386 0333 4889C7   		movq	%rax, %rdi
 387 0336 E8000000 		call	getAccumulator
 387      00
 388 033b 0FBEC0   		movsbl	%al, %eax
 389 033e 89C7     		movl	%eax, %edi
 390 0340 E8000000 		call	serialDiskWrite
 390      00
 391              	.L30:
  81:ioports.c     **** 	} 
  82:ioports.c     **** }
 392              		.loc 1 82 0
 393 0345 90       		nop
 394 0346 C9       		leave
 395              		.cfi_def_cfa 7, 8
 396 0347 C3       		ret
 397              		.cfi_endproc
 398              	.LFE513:
 400              		.globl	port0A_switch_bank
 402              	port0A_switch_bank:
 403              	.LFB514:
  83:ioports.c     **** 
  84:ioports.c     **** void port0A_switch_bank(I8080 *cpu) {
 404              		.loc 1 84 0
 405              		.cfi_startproc
 406 0348 55       		pushq	%rbp
 407              		.cfi_def_cfa_offset 16
 408              		.cfi_offset 6, -16
 409 0349 4889E5   		movq	%rsp, %rbp
 410              		.cfi_def_cfa_register 6
 411 034c 4883EC10 		subq	$16, %rsp
 412 0350 48897DF8 		movq	%rdi, -8(%rbp)
  85:ioports.c     **** 	if (isOutput(cpu)) {
 413              		.loc 1 85 0
 414 0354 488B45F8 		movq	-8(%rbp), %rax
 415 0358 4889C7   		movq	%rax, %rdi
 416 035b E8000000 		call	getIOState
 416      00
 417 0360 85C0     		testl	%eax, %eax
 418 0362 7417     		je	.L32
  86:ioports.c     **** 		bankNumber = getAccumulator(cpu) & 0b11;
 419              		.loc 1 86 0
 420 0364 488B45F8 		movq	-8(%rbp), %rax
 421 0368 4889C7   		movq	%rax, %rdi
 422 036b E8000000 		call	getAccumulator
 422      00
 423 0370 83E003   		andl	$3, %eax
 424 0373 89050000 		movl	%eax, bankNumber(%rip)
 424      0000
  87:ioports.c     **** 	} else {
  88:ioports.c     **** 		setAccumulator(cpu, bankNumber);
  89:ioports.c     **** 	}
  90:ioports.c     **** }
 425              		.loc 1 90 0
 426 0379 EB14     		jmp	.L34
 427              	.L32:
  88:ioports.c     **** 	}
 428              		.loc 1 88 0
 429 037b 8B150000 		movl	bankNumber(%rip), %edx
 429      0000
 430 0381 488B45F8 		movq	-8(%rbp), %rax
 431 0385 89D6     		movl	%edx, %esi
 432 0387 4889C7   		movq	%rax, %rdi
 433 038a E8000000 		call	setAccumulator
 433      00
 434              	.L34:
 435              		.loc 1 90 0
 436 038f 90       		nop
 437 0390 C9       		leave
 438              		.cfi_def_cfa 7, 8
 439 0391 C3       		ret
 440              		.cfi_endproc
 441              	.LFE514:
 443              	.Letext0:
 444              		.file 2 "/usr/lib/gcc/x86_64-pc-linux-gnu/6.3.1/include/stddef.h"
 445              		.file 3 "/usr/include/bits/types.h"
 446              		.file 4 "/usr/include/stdio.h"
 447              		.file 5 "/usr/include/libio.h"
 448              		.file 6 "/usr/include/bits/sys_errlist.h"
 449              		.file 7 "/usr/include/stdint.h"
 450              		.file 8 "/usr/include/math.h"
 451              		.file 9 "/usr/include/SDL2/SDL_stdinc.h"
 452              		.file 10 "/usr/include/SDL2/SDL_pixels.h"
 453              		.file 11 "/usr/include/SDL2/SDL_rect.h"
 454              		.file 12 "/usr/include/SDL2/SDL_surface.h"
 455              		.file 13 "/usr/include/SDL2/SDL_video.h"
 456              		.file 14 "/usr/include/SDL2/SDL_scancode.h"
 457              		.file 15 "/usr/include/SDL2/SDL_messagebox.h"
 458              		.file 16 "../I8080/I8080.h"
 459              		.file 17 "video.h"
 460              		.file 18 "keyboard.h"
 461              		.file 19 "disk_controller.h"
 462              		.file 20 "memory.h"
   1              		.file	"memory.c"
   2              		.text
   3              	.Ltext0:
   4              		.local	hold
   5              		.comm	hold,4,4
   6              		.comm	memBanks,32,32
   7              		.comm	sharedMem,8,8
   8              		.comm	bankNumber,4,4
   9              		.globl	initMemory
  11              	initMemory:
  12              	.LFB508:
  13              		.file 1 "memory.c"
   1:memory.c      **** #include <stdint.h>
   2:memory.c      **** #include "memory.h"
   3:memory.c      **** 
   4:memory.c      **** char *memBanks[4],*sharedMem;
   5:memory.c      **** int  bankNumber;
   6:memory.c      **** 
   7:memory.c      **** void initMemory() {
  14              		.loc 1 7 0
  15              		.cfi_startproc
  16 0000 55       		pushq	%rbp
  17              		.cfi_def_cfa_offset 16
  18              		.cfi_offset 6, -16
  19 0001 4889E5   		movq	%rsp, %rbp
  20              		.cfi_def_cfa_register 6
   8:memory.c      **** 	memBanks[0] = malloc(BANK_SIZE);
  21              		.loc 1 8 0
  22 0004 BF00C000 		movl	$49152, %edi
  22      00
  23 0009 E8000000 		call	malloc
  23      00
  24 000e 48890500 		movq	%rax, memBanks(%rip)
  24      000000
   9:memory.c      **** 	memBanks[1] = malloc(BANK_SIZE);
  25              		.loc 1 9 0
  26 0015 BF00C000 		movl	$49152, %edi
  26      00
  27 001a E8000000 		call	malloc
  27      00
  28 001f 48890500 		movq	%rax, memBanks+8(%rip)
  28      000000
  10:memory.c      **** 	memBanks[2] = malloc(BANK_SIZE);
  29              		.loc 1 10 0
  30 0026 BF00C000 		movl	$49152, %edi
  30      00
  31 002b E8000000 		call	malloc
  31      00
  32 0030 48890500 		movq	%rax, memBanks+16(%rip)
  32      000000
  11:memory.c      **** 	memBanks[3] = malloc(BANK_SIZE);
  33              		.loc 1 11 0
  34 0037 BF00C000 		movl	$49152, %edi
  34      00
  35 003c E8000000 		call	malloc
  35      00
  36 0041 48890500 		movq	%rax, memBanks+24(%rip)
  36      000000
  12:memory.c      **** 	
  13:memory.c      **** 	sharedMem = malloc(SHARED_SIZE);
  37              		.loc 1 13 0
  38 0048 BF004000 		movl	$16384, %edi
  38      00
  39 004d E8000000 		call	malloc
  39      00
  40 0052 48890500 		movq	%rax, sharedMem(%rip)
  40      000000
  14:memory.c      **** }
  41              		.loc 1 14 0
  42 0059 90       		nop
  43 005a 5D       		popq	%rbp
  44              		.cfi_def_cfa 7, 8
  45 005b C3       		ret
  46              		.cfi_endproc
  47              	.LFE508:
  49              		.globl	myMMU
  51              	myMMU:
  52              	.LFB509:
  15:memory.c      **** 
  16:memory.c      **** 
  17:memory.c      **** int64_t myMMU(I8080 *cpu, int ladr) {
  53              		.loc 1 17 0
  54              		.cfi_startproc
  55 005c 55       		pushq	%rbp
  56              		.cfi_def_cfa_offset 16
  57              		.cfi_offset 6, -16
  58 005d 4889E5   		movq	%rsp, %rbp
  59              		.cfi_def_cfa_register 6
  60 0060 4883EC20 		subq	$32, %rsp
  61 0064 48897DE8 		movq	%rdi, -24(%rbp)
  62 0068 8975E4   		movl	%esi, -28(%rbp)
  18:memory.c      **** 	
  19:memory.c      **** 	int64_t retval;
  20:memory.c      **** 	
  21:memory.c      **** 	if (bankNumber > 0) {
  63              		.loc 1 21 0
  64 006b 8B050000 		movl	bankNumber(%rip), %eax
  64      0000
  65 0071 85C0     		testl	%eax, %eax
  66 0073 7E1F     		jle	.L3
  22:memory.c      **** 		retval = ladr + (int64_t) memBanks[bankNumber];
  67              		.loc 1 22 0
  68 0075 8B45E4   		movl	-28(%rbp), %eax
  69 0078 4863D0   		movslq	%eax, %rdx
  70 007b 8B050000 		movl	bankNumber(%rip), %eax
  70      0000
  71 0081 4898     		cltq
  72 0083 488B04C5 		movq	memBanks(,%rax,8), %rax
  72      00000000 
  73 008b 4801D0   		addq	%rdx, %rax
  74 008e 488945F8 		movq	%rax, -8(%rbp)
  75 0092 EB78     		jmp	.L4
  76              	.L3:
  23:memory.c      **** 	} else if (ladr < 0x0800) {
  77              		.loc 1 23 0
  78 0094 817DE4FF 		cmpl	$2047, -28(%rbp)
  78      070000
  79 009b 7F15     		jg	.L5
  24:memory.c      **** 		retval = ladr + (int64_t) memBanks[0];
  80              		.loc 1 24 0
  81 009d 8B45E4   		movl	-28(%rbp), %eax
  82 00a0 4898     		cltq
  83 00a2 488B1500 		movq	memBanks(%rip), %rdx
  83      000000
  84 00a9 4801D0   		addq	%rdx, %rax
  85 00ac 488945F8 		movq	%rax, -8(%rbp)
  86 00b0 EB5A     		jmp	.L4
  87              	.L5:
  25:memory.c      **** 	} else if (ladr < 0x5800) {
  88              		.loc 1 25 0
  89 00b2 817DE4FF 		cmpl	$22527, -28(%rbp)
  89      570000
  90 00b9 7F38     		jg	.L6
  26:memory.c      **** 		
  27:memory.c      **** 		// If it's in output mode then we know it's writing to the buffer
  28:memory.c      **** 		if (isOutput(cpu)) {
  91              		.loc 1 28 0
  92 00bb 488B45E8 		movq	-24(%rbp), %rax
  93 00bf 4889C7   		movq	%rax, %rdi
  94 00c2 E8000000 		call	getIOState
  94      00
  95 00c7 85C0     		testl	%eax, %eax
  96 00c9 740A     		je	.L7
  29:memory.c      **** 			video.dirtyBuffer = 1;
  97              		.loc 1 29 0
  98 00cb C7050000 		movl	$1, video+808(%rip)
  98      00000100 
  98      0000
  99              	.L7:
  30:memory.c      **** 		}
  31:memory.c      **** 
  32:memory.c      **** 		retval = (int64_t) video.pixelBuffer + ladr - 0x0800;
 100              		.loc 1 32 0
 101 00d5 488B0500 		movq	video+784(%rip), %rax
 101      000000
 102 00dc 4889C2   		movq	%rax, %rdx
 103 00df 8B45E4   		movl	-28(%rbp), %eax
 104 00e2 4898     		cltq
 105 00e4 4801D0   		addq	%rdx, %rax
 106 00e7 482D0008 		subq	$2048, %rax
 106      0000
 107 00ed 488945F8 		movq	%rax, -8(%rbp)
 108 00f1 EB19     		jmp	.L4
 109              	.L6:
  33:memory.c      **** 	} else {
  34:memory.c      **** 		retval = ladr + (int64_t) memBanks[0] - 0x5000;
 110              		.loc 1 34 0
 111 00f3 8B45E4   		movl	-28(%rbp), %eax
 112 00f6 4898     		cltq
 113 00f8 488B1500 		movq	memBanks(%rip), %rdx
 113      000000
 114 00ff 4801D0   		addq	%rdx, %rax
 115 0102 482D0050 		subq	$20480, %rax
 115      0000
 116 0108 488945F8 		movq	%rax, -8(%rbp)
 117              	.L4:
  35:memory.c      **** 	}
  36:memory.c      **** 	
  37:memory.c      **** 	return retval;
 118              		.loc 1 37 0
 119 010c 488B45F8 		movq	-8(%rbp), %rax
  38:memory.c      **** }
 120              		.loc 1 38 0
 121 0110 C9       		leave
 122              		.cfi_def_cfa 7, 8
 123 0111 C3       		ret
 124              		.cfi_endproc
 125              	.LFE509:
 127              	.Letext0:
 128              		.file 2 "/usr/include/stdint.h"
 129              		.file 3 "../I8080/I8080.h"
 130              		.file 4 "/usr/lib/gcc/x86_64-pc-linux-gnu/6.3.1/include/stddef.h"
 131              		.file 5 "/usr/include/bits/types.h"
 132              		.file 6 "/usr/include/libio.h"
 133              		.file 7 "/usr/include/stdio.h"
 134              		.file 8 "/usr/include/bits/sys_errlist.h"
 135              		.file 9 "/usr/include/math.h"
 136              		.file 10 "/usr/include/SDL2/SDL_stdinc.h"
 137              		.file 11 "/usr/include/SDL2/SDL_pixels.h"
 138              		.file 12 "/usr/include/SDL2/SDL_rect.h"
 139              		.file 13 "/usr/include/SDL2/SDL_surface.h"
 140              		.file 14 "/usr/include/SDL2/SDL_video.h"
 141              		.file 15 "/usr/include/SDL2/SDL_scancode.h"
 142              		.file 16 "/usr/include/SDL2/SDL_messagebox.h"
 143              		.file 17 "video.h"
 144              		.file 18 "memory.h"
   1              		.file	"disk_controller.c"
   2              		.text
   3              	.Ltext0:
   4              		.local	hold
   5              		.comm	hold,4,4
   6              		.globl	disk
   7              		.bss
   8              		.align 32
  11              	disk:
  12 0000 00000000 		.zero	40
  12      00000000 
  12      00000000 
  12      00000000 
  12      00000000 
  13              		.text
  14              		.globl	serialDiskRead
  16              	serialDiskRead:
  17              	.LFB2:
  18              		.file 1 "disk_controller.c"
   1:disk_controller.c **** #include "disk_controller.h"
   2:disk_controller.c **** 
   3:disk_controller.c **** HDD disk = {0};
   4:disk_controller.c **** 
   5:disk_controller.c **** char serialDiskRead() {
  19              		.loc 1 5 0
  20              		.cfi_startproc
  21 0000 55       		pushq	%rbp
  22              		.cfi_def_cfa_offset 16
  23              		.cfi_offset 6, -16
  24 0001 4889E5   		movq	%rsp, %rbp
  25              		.cfi_def_cfa_register 6
   6:disk_controller.c **** 	char value = disk.rx;
  26              		.loc 1 6 0
  27 0004 0FB60500 		movzbl	disk+21(%rip), %eax
  27      000000
  28 000b 8845FF   		movb	%al, -1(%rbp)
   7:disk_controller.c **** 	disk.rx = 0;
  29              		.loc 1 7 0
  30 000e C6050000 		movb	$0, disk+21(%rip)
  30      000000
   8:disk_controller.c **** 	
   9:disk_controller.c **** 	if (disk.status == READ_PROC && disk.counter >= 2) {
  31              		.loc 1 9 0
  32 0015 8B050000 		movl	disk+12(%rip), %eax
  32      0000
  33 001b 83F804   		cmpl	$4, %eax
  34 001e 754B     		jne	.L2
  35              		.loc 1 9 0 is_stmt 0 discriminator 1
  36 0020 8B050000 		movl	disk+8(%rip), %eax
  36      0000
  37 0026 83F801   		cmpl	$1, %eax
  38 0029 7E40     		jle	.L2
  10:disk_controller.c **** 		if (disk.counter == disk.lrecl+2) {
  39              		.loc 1 10 0 is_stmt 1
  40 002b 8B050000 		movl	disk+8(%rip), %eax
  40      0000
  41 0031 8B150000 		movl	disk+16(%rip), %edx
  41      0000
  42 0037 83C202   		addl	$2, %edx
  43 003a 39D0     		cmpl	%edx, %eax
  44 003c 7509     		jne	.L3
  11:disk_controller.c **** 			disk.rx = END_FRAME;
  45              		.loc 1 11 0
  46 003e C6050000 		movb	$5, disk+21(%rip)
  46      000005
  47 0045 EB24     		jmp	.L2
  48              	.L3:
  12:disk_controller.c **** 		} else {
  13:disk_controller.c **** 			disk.rx = disk.databuffer[disk.counter++];
  49              		.loc 1 13 0
  50 0047 488B0D00 		movq	disk+32(%rip), %rcx
  50      000000
  51 004e 8B050000 		movl	disk+8(%rip), %eax
  51      0000
  52 0054 8D5001   		leal	1(%rax), %edx
  53 0057 89150000 		movl	%edx, disk+8(%rip)
  53      0000
  54 005d 4898     		cltq
  55 005f 4801C8   		addq	%rcx, %rax
  56 0062 0FB600   		movzbl	(%rax), %eax
  57 0065 88050000 		movb	%al, disk+21(%rip)
  57      0000
  58              	.L2:
  14:disk_controller.c **** 		}
  15:disk_controller.c **** 	}
  16:disk_controller.c **** 	
  17:disk_controller.c **** 	return value;
  59              		.loc 1 17 0
  60 006b 0FB645FF 		movzbl	-1(%rbp), %eax
  18:disk_controller.c **** }
  61              		.loc 1 18 0
  62 006f 5D       		popq	%rbp
  63              		.cfi_def_cfa 7, 8
  64 0070 C3       		ret
  65              		.cfi_endproc
  66              	.LFE2:
  68              		.section	.rodata
  69              	.LC0:
  70 0000 72622B00 		.string	"rb+"
  71              	.LC1:
  72 0004 6864642E 		.string	"hdd.bin"
  72      62696E00 
  73              		.text
  74              		.globl	serialDiskWrite
  76              	serialDiskWrite:
  77              	.LFB3:
  19:disk_controller.c **** 
  20:disk_controller.c **** void serialDiskWrite(char c) {
  78              		.loc 1 20 0
  79              		.cfi_startproc
  80 0071 55       		pushq	%rbp
  81              		.cfi_def_cfa_offset 16
  82              		.cfi_offset 6, -16
  83 0072 4889E5   		movq	%rsp, %rbp
  84              		.cfi_def_cfa_register 6
  85 0075 4883EC10 		subq	$16, %rsp
  86 0079 89F8     		movl	%edi, %eax
  87 007b 8845FC   		movb	%al, -4(%rbp)
  21:disk_controller.c **** 	
  22:disk_controller.c **** 	switch (disk.status) {
  88              		.loc 1 22 0
  89 007e 8B050000 		movl	disk+12(%rip), %eax
  89      0000
  90 0084 83F802   		cmpl	$2, %eax
  91 0087 0F842301 		je	.L7
  91      0000
  92 008d 83F802   		cmpl	$2, %eax
  93 0090 7F0A     		jg	.L8
  94 0092 83F801   		cmpl	$1, %eax
  95 0095 7418     		je	.L9
  96 0097 E9950300 		jmp	.L5
  96      00
  97              	.L8:
  98 009c 83F804   		cmpl	$4, %eax
  99 009f 0F843502 		je	.L10
  99      0000
 100 00a5 83F808   		cmpl	$8, %eax
 101 00a8 7466     		je	.L11
 102 00aa E9820300 		jmp	.L5
 102      00
 103              	.L9:
  23:disk_controller.c **** 		case IDLE:
  24:disk_controller.c **** 			if (c == REQUEST_READ || c == REQUEST_WRITE) {
 104              		.loc 1 24 0
 105 00af 807DFC03 		cmpb	$3, -4(%rbp)
 106 00b3 7406     		je	.L12
 107              		.loc 1 24 0 is_stmt 0 discriminator 1
 108 00b5 807DFC02 		cmpb	$2, -4(%rbp)
 109 00b9 7520     		jne	.L13
 110              	.L12:
  25:disk_controller.c **** 				disk.tx = c;	// record the last command
 111              		.loc 1 25 0 is_stmt 1
 112 00bb 0FB645FC 		movzbl	-4(%rbp), %eax
 113 00bf 88050000 		movb	%al, disk+20(%rip)
 113      0000
  26:disk_controller.c **** 				disk.status = WAITING;
 114              		.loc 1 26 0
 115 00c5 C7050000 		movl	$8, disk+12(%rip)
 115      00000800 
 115      0000
  27:disk_controller.c **** 				disk.rx = ACKOWLEDGE;
 116              		.loc 1 27 0
 117 00cf C6050000 		movb	$7, disk+21(%rip)
 117      000007
  28:disk_controller.c **** 			} else if (c == STATUS) {
  29:disk_controller.c **** 				disk.rx = disk.status;
  30:disk_controller.c **** 				return;
  31:disk_controller.c **** 			} else if (c != ENTER_IDLE) {
  32:disk_controller.c **** 				disk.rx = NACK_ERROR;
  33:disk_controller.c **** 			} else {
  34:disk_controller.c **** 				disk.rx = IDLE;
  35:disk_controller.c **** 			}
  36:disk_controller.c **** 			break;
 118              		.loc 1 36 0
 119 00d6 E9560300 		jmp	.L5
 119      00
 120              	.L13:
  28:disk_controller.c **** 			} else if (c == STATUS) {
 121              		.loc 1 28 0
 122 00db 807DFC06 		cmpb	$6, -4(%rbp)
 123 00df 7511     		jne	.L15
  29:disk_controller.c **** 				return;
 124              		.loc 1 29 0
 125 00e1 8B050000 		movl	disk+12(%rip), %eax
 125      0000
 126 00e7 88050000 		movb	%al, disk+21(%rip)
 126      0000
  30:disk_controller.c **** 			} else if (c != ENTER_IDLE) {
 127              		.loc 1 30 0
 128 00ed E93F0300 		jmp	.L5
 128      00
 129              	.L15:
  31:disk_controller.c **** 				disk.rx = NACK_ERROR;
 130              		.loc 1 31 0
 131 00f2 807DFC01 		cmpb	$1, -4(%rbp)
 132 00f6 740C     		je	.L16
  32:disk_controller.c **** 			} else {
 133              		.loc 1 32 0
 134 00f8 C6050000 		movb	$-14, disk+21(%rip)
 134      0000F2
 135              		.loc 1 36 0
 136 00ff E92D0300 		jmp	.L5
 136      00
 137              	.L16:
  34:disk_controller.c **** 			}
 138              		.loc 1 34 0
 139 0104 C6050000 		movb	$1, disk+21(%rip)
 139      000001
 140              		.loc 1 36 0
 141 010b E9210300 		jmp	.L5
 141      00
 142              	.L11:
  37:disk_controller.c **** 		case WAITING:
  38:disk_controller.c **** 			if (disk.tx == REQUEST_READ && c == START_FRAME) {
 143              		.loc 1 38 0
 144 0110 0FB60500 		movzbl	disk+20(%rip), %eax
 144      000000
 145 0117 3C03     		cmpb	$3, %al
 146 0119 7523     		jne	.L17
 147              		.loc 1 38 0 is_stmt 0 discriminator 1
 148 011b 807DFC04 		cmpb	$4, -4(%rbp)
 149 011f 751D     		jne	.L17
  39:disk_controller.c **** 				disk.counter = 0;
 150              		.loc 1 39 0 is_stmt 1
 151 0121 C7050000 		movl	$0, disk+8(%rip)
 151      00000000 
 151      0000
  40:disk_controller.c **** 				disk.status = READ_PROC;
 152              		.loc 1 40 0
 153 012b C7050000 		movl	$4, disk+12(%rip)
 153      00000400 
 153      0000
  41:disk_controller.c **** 				disk.tx = 0;
 154              		.loc 1 41 0
 155 0135 C6050000 		movb	$0, disk+20(%rip)
 155      000000
 156 013c EB6D     		jmp	.L18
 157              	.L17:
  42:disk_controller.c **** 			} else if (disk.tx == REQUEST_WRITE && c == START_FRAME) {
 158              		.loc 1 42 0
 159 013e 0FB60500 		movzbl	disk+20(%rip), %eax
 159      000000
 160 0145 3C02     		cmpb	$2, %al
 161 0147 7523     		jne	.L19
 162              		.loc 1 42 0 is_stmt 0 discriminator 1
 163 0149 807DFC04 		cmpb	$4, -4(%rbp)
 164 014d 751D     		jne	.L19
  43:disk_controller.c **** 				disk.counter = 0;
 165              		.loc 1 43 0 is_stmt 1
 166 014f C7050000 		movl	$0, disk+8(%rip)
 166      00000000 
 166      0000
  44:disk_controller.c **** 				disk.status = WRITE_PROC;
 167              		.loc 1 44 0
 168 0159 C7050000 		movl	$2, disk+12(%rip)
 168      00000200 
 168      0000
  45:disk_controller.c **** 				disk.tx = 0;
 169              		.loc 1 45 0
 170 0163 C6050000 		movb	$0, disk+20(%rip)
 170      000000
 171 016a EB3F     		jmp	.L18
 172              	.L19:
  46:disk_controller.c **** 			} else if (c == STATUS) {
 173              		.loc 1 46 0
 174 016c 807DFC06 		cmpb	$6, -4(%rbp)
 175 0170 7511     		jne	.L20
  47:disk_controller.c **** 				disk.rx = disk.status;
 176              		.loc 1 47 0
 177 0172 8B050000 		movl	disk+12(%rip), %eax
 177      0000
 178 0178 88050000 		movb	%al, disk+21(%rip)
 178      0000
  48:disk_controller.c **** 			} else if (c != ENTER_IDLE) {
  49:disk_controller.c **** 				disk.rx = PROC_ERROR;
  50:disk_controller.c **** 			} else {
  51:disk_controller.c **** 				disk.status = IDLE;
  52:disk_controller.c **** 				disk.rx = IDLE;
  53:disk_controller.c **** 			}
  54:disk_controller.c **** 			break;
 179              		.loc 1 54 0
 180 017e E9AE0200 		jmp	.L5
 180      00
 181              	.L20:
  48:disk_controller.c **** 			} else if (c != ENTER_IDLE) {
 182              		.loc 1 48 0
 183 0183 807DFC01 		cmpb	$1, -4(%rbp)
 184 0187 740C     		je	.L21
  49:disk_controller.c **** 			} else {
 185              		.loc 1 49 0
 186 0189 C6050000 		movb	$-13, disk+21(%rip)
 186      0000F3
 187              		.loc 1 54 0
 188 0190 E99C0200 		jmp	.L5
 188      00
 189              	.L21:
  51:disk_controller.c **** 				disk.rx = IDLE;
 190              		.loc 1 51 0
 191 0195 C7050000 		movl	$1, disk+12(%rip)
 191      00000100 
 191      0000
  52:disk_controller.c **** 			}
 192              		.loc 1 52 0
 193 019f C6050000 		movb	$1, disk+21(%rip)
 193      000001
 194              		.loc 1 54 0
 195 01a6 E9860200 		jmp	.L5
 195      00
 196              	.L18:
 197              		.loc 1 54 0 is_stmt 0 discriminator 2
 198 01ab E9810200 		jmp	.L5
 198      00
 199              	.L7:
  55:disk_controller.c **** 		case WRITE_PROC:
  56:disk_controller.c **** 			if (disk.counter == disk.lrecl+2) {
 200              		.loc 1 56 0 is_stmt 1
 201 01b0 8B050000 		movl	disk+8(%rip), %eax
 201      0000
 202 01b6 8B150000 		movl	disk+16(%rip), %edx
 202      0000
 203 01bc 83C202   		addl	$2, %edx
 204 01bf 39D0     		cmpl	%edx, %eax
 205 01c1 0F85EC00 		jne	.L22
 205      0000
  57:disk_controller.c **** 				if (c == END_FRAME) {
 206              		.loc 1 57 0
 207 01c7 807DFC05 		cmpb	$5, -4(%rbp)
 208 01cb 0F85BA00 		jne	.L23
 208      0000
  58:disk_controller.c **** 					disk.chs = ((*(disk.databuffer)) << 8) | (*(disk.databuffer+1));
 209              		.loc 1 58 0
 210 01d1 488B0500 		movq	disk+32(%rip), %rax
 210      000000
 211 01d8 0FB600   		movzbl	(%rax), %eax
 212 01db 0FBEC0   		movsbl	%al, %eax
 213 01de C1E008   		sall	$8, %eax
 214 01e1 89C2     		movl	%eax, %edx
 215 01e3 488B0500 		movq	disk+32(%rip), %rax
 215      000000
 216 01ea 4883C001 		addq	$1, %rax
 217 01ee 0FB600   		movzbl	(%rax), %eax
 218 01f1 0FBEC0   		movsbl	%al, %eax
 219 01f4 09D0     		orl	%edx, %eax
 220 01f6 89050000 		movl	%eax, disk+4(%rip)
 220      0000
  59:disk_controller.c **** 					CHS2LBA();
 221              		.loc 1 59 0
 222 01fc B8000000 		movl	$0, %eax
 222      00
 223 0201 E8000000 		call	CHS2LBA
 223      00
  60:disk_controller.c **** 					disk.status = WAITING;
 224              		.loc 1 60 0
 225 0206 C7050000 		movl	$8, disk+12(%rip)
 225      00000800 
 225      0000
  61:disk_controller.c **** 					disk.rx = WRITE_OKAY;
 226              		.loc 1 61 0
 227 0210 C6050000 		movb	$8, disk+21(%rip)
 227      000008
  62:disk_controller.c **** 					disk.disk = fopen("hdd.bin", "rb+");
 228              		.loc 1 62 0
 229 0217 BE000000 		movl	$.LC0, %esi
 229      00
 230 021c BF000000 		movl	$.LC1, %edi
 230      00
 231 0221 E8000000 		call	fopen
 231      00
 232 0226 48890500 		movq	%rax, disk+24(%rip)
 232      000000
  63:disk_controller.c **** 					fseek(disk.disk, disk.lba, SEEK_SET);
 233              		.loc 1 63 0
 234 022d 8B050000 		movl	disk(%rip), %eax
 234      0000
 235 0233 4863C8   		movslq	%eax, %rcx
 236 0236 488B0500 		movq	disk+24(%rip), %rax
 236      000000
 237 023d BA000000 		movl	$0, %edx
 237      00
 238 0242 4889CE   		movq	%rcx, %rsi
 239 0245 4889C7   		movq	%rax, %rdi
 240 0248 E8000000 		call	fseek
 240      00
  64:disk_controller.c **** 					fwrite(disk.databuffer+2, 1, disk.lrecl, disk.disk);
 241              		.loc 1 64 0
 242 024d 488B1500 		movq	disk+24(%rip), %rdx
 242      000000
 243 0254 8B050000 		movl	disk+16(%rip), %eax
 243      0000
 244 025a 4898     		cltq
 245 025c 488B0D00 		movq	disk+32(%rip), %rcx
 245      000000
 246 0263 488D7902 		leaq	2(%rcx), %rdi
 247 0267 4889D1   		movq	%rdx, %rcx
 248 026a 4889C2   		movq	%rax, %rdx
 249 026d BE010000 		movl	$1, %esi
 249      00
 250 0272 E8000000 		call	fwrite
 250      00
  65:disk_controller.c **** 					fclose(disk.disk);
 251              		.loc 1 65 0
 252 0277 488B0500 		movq	disk+24(%rip), %rax
 252      000000
 253 027e 4889C7   		movq	%rax, %rdi
 254 0281 E8000000 		call	fclose
 254      00
  66:disk_controller.c **** 				} else if (c == ENTER_IDLE) {
  67:disk_controller.c **** 					disk.status = IDLE;
  68:disk_controller.c **** 					disk.rx = WRITE_ERROR;
  69:disk_controller.c **** 				} else {
  70:disk_controller.c **** 					disk.rx = WRITE_ERROR;
  71:disk_controller.c **** 				}
  72:disk_controller.c **** 			} else {
  73:disk_controller.c **** 				disk.databuffer[disk.counter++] = c;
  74:disk_controller.c **** 			}
  75:disk_controller.c **** 			break;
 255              		.loc 1 75 0
 256 0286 E9A60100 		jmp	.L5
 256      00
 257              	.L23:
  66:disk_controller.c **** 				} else if (c == ENTER_IDLE) {
 258              		.loc 1 66 0
 259 028b 807DFC01 		cmpb	$1, -4(%rbp)
 260 028f 7516     		jne	.L25
  67:disk_controller.c **** 					disk.rx = WRITE_ERROR;
 261              		.loc 1 67 0
 262 0291 C7050000 		movl	$1, disk+12(%rip)
 262      00000100 
 262      0000
  68:disk_controller.c **** 				} else {
 263              		.loc 1 68 0
 264 029b C6050000 		movb	$-16, disk+21(%rip)
 264      0000F0
 265              		.loc 1 75 0
 266 02a2 E98A0100 		jmp	.L5
 266      00
 267              	.L25:
  70:disk_controller.c **** 				}
 268              		.loc 1 70 0
 269 02a7 C6050000 		movb	$-16, disk+21(%rip)
 269      0000F0
 270              		.loc 1 75 0
 271 02ae E97E0100 		jmp	.L5
 271      00
 272              	.L22:
  73:disk_controller.c **** 			}
 273              		.loc 1 73 0
 274 02b3 488B0D00 		movq	disk+32(%rip), %rcx
 274      000000
 275 02ba 8B050000 		movl	disk+8(%rip), %eax
 275      0000
 276 02c0 8D5001   		leal	1(%rax), %edx
 277 02c3 89150000 		movl	%edx, disk+8(%rip)
 277      0000
 278 02c9 4898     		cltq
 279 02cb 488D1401 		leaq	(%rcx,%rax), %rdx
 280 02cf 0FB645FC 		movzbl	-4(%rbp), %eax
 281 02d3 8802     		movb	%al, (%rdx)
 282              		.loc 1 75 0
 283 02d5 E9570100 		jmp	.L5
 283      00
 284              	.L10:
  76:disk_controller.c **** 		case READ_PROC:
  77:disk_controller.c **** 		
  78:disk_controller.c **** 			if (disk.counter == 2) {
 285              		.loc 1 78 0
 286 02da 8B050000 		movl	disk+8(%rip), %eax
 286      0000
 287 02e0 83F802   		cmpl	$2, %eax
 288 02e3 0F85DC00 		jne	.L27
 288      0000
  79:disk_controller.c **** 				if (c == END_FRAME) {
 289              		.loc 1 79 0
 290 02e9 807DFC05 		cmpb	$5, -4(%rbp)
 291 02ed 0F85B000 		jne	.L28
 291      0000
  80:disk_controller.c **** 					disk.chs = ((*(disk.databuffer)) << 8) | (*(disk.databuffer+1));
 292              		.loc 1 80 0
 293 02f3 488B0500 		movq	disk+32(%rip), %rax
 293      000000
 294 02fa 0FB600   		movzbl	(%rax), %eax
 295 02fd 0FBEC0   		movsbl	%al, %eax
 296 0300 C1E008   		sall	$8, %eax
 297 0303 89C2     		movl	%eax, %edx
 298 0305 488B0500 		movq	disk+32(%rip), %rax
 298      000000
 299 030c 4883C001 		addq	$1, %rax
 300 0310 0FB600   		movzbl	(%rax), %eax
 301 0313 0FBEC0   		movsbl	%al, %eax
 302 0316 09D0     		orl	%edx, %eax
 303 0318 89050000 		movl	%eax, disk+4(%rip)
 303      0000
  81:disk_controller.c **** 					CHS2LBA();
 304              		.loc 1 81 0
 305 031e B8000000 		movl	$0, %eax
 305      00
 306 0323 E8000000 		call	CHS2LBA
 306      00
  82:disk_controller.c **** 					disk.rx = START_FRAME;
 307              		.loc 1 82 0
 308 0328 C6050000 		movb	$4, disk+21(%rip)
 308      000004
  83:disk_controller.c **** 					disk.disk = fopen("hdd.bin", "rb+");
 309              		.loc 1 83 0
 310 032f BE000000 		movl	$.LC0, %esi
 310      00
 311 0334 BF000000 		movl	$.LC1, %edi
 311      00
 312 0339 E8000000 		call	fopen
 312      00
 313 033e 48890500 		movq	%rax, disk+24(%rip)
 313      000000
  84:disk_controller.c **** 					fseek(disk.disk, disk.lba, SEEK_SET);
 314              		.loc 1 84 0
 315 0345 8B050000 		movl	disk(%rip), %eax
 315      0000
 316 034b 4863C8   		movslq	%eax, %rcx
 317 034e 488B0500 		movq	disk+24(%rip), %rax
 317      000000
 318 0355 BA000000 		movl	$0, %edx
 318      00
 319 035a 4889CE   		movq	%rcx, %rsi
 320 035d 4889C7   		movq	%rax, %rdi
 321 0360 E8000000 		call	fseek
 321      00
  85:disk_controller.c **** 					fread(disk.databuffer+2, 1, disk.lrecl, disk.disk);
 322              		.loc 1 85 0
 323 0365 488B1500 		movq	disk+24(%rip), %rdx
 323      000000
 324 036c 8B050000 		movl	disk+16(%rip), %eax
 324      0000
 325 0372 4898     		cltq
 326 0374 488B0D00 		movq	disk+32(%rip), %rcx
 326      000000
 327 037b 488D7902 		leaq	2(%rcx), %rdi
 328 037f 4889D1   		movq	%rdx, %rcx
 329 0382 4889C2   		movq	%rax, %rdx
 330 0385 BE010000 		movl	$1, %esi
 330      00
 331 038a E8000000 		call	fread
 331      00
  86:disk_controller.c **** 					fclose(disk.disk);
 332              		.loc 1 86 0
 333 038f 488B0500 		movq	disk+24(%rip), %rax
 333      000000
 334 0396 4889C7   		movq	%rax, %rdi
 335 0399 E8000000 		call	fclose
 335      00
  87:disk_controller.c **** 				} else if (c == ENTER_IDLE) {
  88:disk_controller.c **** 					disk.status = IDLE;
  89:disk_controller.c **** 					disk.rx = READ_ERROR;
  90:disk_controller.c **** 				} else {
  91:disk_controller.c **** 					disk.rx = READ_ERROR;
  92:disk_controller.c **** 				}
  93:disk_controller.c **** 			} else if (disk.counter < 2) {
  94:disk_controller.c **** 				disk.databuffer[disk.counter++] = c;
  95:disk_controller.c **** 			} else {
  96:disk_controller.c **** 				if (disk.counter == 514 && c == ACKOWLEDGE) {
  97:disk_controller.c **** 					disk.status = WAITING;
  98:disk_controller.c **** 					disk.rx = READ_OKAY;
  99:disk_controller.c **** 				} else {
 100:disk_controller.c **** 					disk.counter--;
 101:disk_controller.c **** 					disk.rx = READ_ERROR;
 102:disk_controller.c **** 				}
 103:disk_controller.c **** 			}
 104:disk_controller.c **** 			break;
 336              		.loc 1 104 0
 337 039e E98E0000 		jmp	.L5
 337      00
 338              	.L28:
  87:disk_controller.c **** 				} else if (c == ENTER_IDLE) {
 339              		.loc 1 87 0
 340 03a3 807DFC01 		cmpb	$1, -4(%rbp)
 341 03a7 7513     		jne	.L30
  88:disk_controller.c **** 					disk.rx = READ_ERROR;
 342              		.loc 1 88 0
 343 03a9 C7050000 		movl	$1, disk+12(%rip)
 343      00000100 
 343      0000
  89:disk_controller.c **** 				} else {
 344              		.loc 1 89 0
 345 03b3 C6050000 		movb	$-15, disk+21(%rip)
 345      0000F1
 346              		.loc 1 104 0
 347 03ba EB75     		jmp	.L5
 348              	.L30:
  91:disk_controller.c **** 				}
 349              		.loc 1 91 0
 350 03bc C6050000 		movb	$-15, disk+21(%rip)
 350      0000F1
 351              		.loc 1 104 0
 352 03c3 EB6C     		jmp	.L5
 353              	.L27:
  93:disk_controller.c **** 				disk.databuffer[disk.counter++] = c;
 354              		.loc 1 93 0
 355 03c5 8B050000 		movl	disk+8(%rip), %eax
 355      0000
 356 03cb 83F801   		cmpl	$1, %eax
 357 03ce 7F24     		jg	.L32
  94:disk_controller.c **** 			} else {
 358              		.loc 1 94 0
 359 03d0 488B0D00 		movq	disk+32(%rip), %rcx
 359      000000
 360 03d7 8B050000 		movl	disk+8(%rip), %eax
 360      0000
 361 03dd 8D5001   		leal	1(%rax), %edx
 362 03e0 89150000 		movl	%edx, disk+8(%rip)
 362      0000
 363 03e6 4898     		cltq
 364 03e8 488D1401 		leaq	(%rcx,%rax), %rdx
 365 03ec 0FB645FC 		movzbl	-4(%rbp), %eax
 366 03f0 8802     		movb	%al, (%rdx)
 367              		.loc 1 104 0
 368 03f2 EB3D     		jmp	.L5
 369              	.L32:
  96:disk_controller.c **** 					disk.status = WAITING;
 370              		.loc 1 96 0
 371 03f4 8B050000 		movl	disk+8(%rip), %eax
 371      0000
 372 03fa 3D020200 		cmpl	$514, %eax
 372      00
 373 03ff 7519     		jne	.L33
  96:disk_controller.c **** 					disk.status = WAITING;
 374              		.loc 1 96 0 is_stmt 0 discriminator 1
 375 0401 807DFC07 		cmpb	$7, -4(%rbp)
 376 0405 7513     		jne	.L33
  97:disk_controller.c **** 					disk.rx = READ_OKAY;
 377              		.loc 1 97 0 is_stmt 1
 378 0407 C7050000 		movl	$8, disk+12(%rip)
 378      00000800 
 378      0000
  98:disk_controller.c **** 				} else {
 379              		.loc 1 98 0
 380 0411 C6050000 		movb	$9, disk+21(%rip)
 380      000009
 381 0418 EB16     		jmp	.L31
 382              	.L33:
 100:disk_controller.c **** 					disk.rx = READ_ERROR;
 383              		.loc 1 100 0
 384 041a 8B050000 		movl	disk+8(%rip), %eax
 384      0000
 385 0420 83E801   		subl	$1, %eax
 386 0423 89050000 		movl	%eax, disk+8(%rip)
 386      0000
 101:disk_controller.c **** 				}
 387              		.loc 1 101 0
 388 0429 C6050000 		movb	$-15, disk+21(%rip)
 388      0000F1
 389              	.L31:
 390              		.loc 1 104 0 discriminator 5
 391 0430 90       		nop
 392              	.L5:
 105:disk_controller.c **** 	}
 106:disk_controller.c **** }
 393              		.loc 1 106 0
 394 0431 C9       		leave
 395              		.cfi_def_cfa 7, 8
 396 0432 C3       		ret
 397              		.cfi_endproc
 398              	.LFE3:
 400              		.globl	initHardDrive
 402              	initHardDrive:
 403              	.LFB4:
 107:disk_controller.c **** 
 108:disk_controller.c **** void initHardDrive() {
 404              		.loc 1 108 0
 405              		.cfi_startproc
 406 0433 55       		pushq	%rbp
 407              		.cfi_def_cfa_offset 16
 408              		.cfi_offset 6, -16
 409 0434 4889E5   		movq	%rsp, %rbp
 410              		.cfi_def_cfa_register 6
 109:disk_controller.c **** 	disk.counter = 0;
 411              		.loc 1 109 0
 412 0437 C7050000 		movl	$0, disk+8(%rip)
 412      00000000 
 412      0000
 110:disk_controller.c **** 	disk.status = IDLE;
 413              		.loc 1 110 0
 414 0441 C7050000 		movl	$1, disk+12(%rip)
 414      00000100 
 414      0000
 111:disk_controller.c **** 	disk.lrecl = RECORD_SIZE;
 415              		.loc 1 111 0
 416 044b C7050000 		movl	$512, disk+16(%rip)
 416      00000002 
 416      0000
 112:disk_controller.c **** 	disk.databuffer = malloc(disk.lrecl + 2);
 417              		.loc 1 112 0
 418 0455 8B050000 		movl	disk+16(%rip), %eax
 418      0000
 419 045b 83C002   		addl	$2, %eax
 420 045e 4898     		cltq
 421 0460 4889C7   		movq	%rax, %rdi
 422 0463 E8000000 		call	malloc
 422      00
 423 0468 48890500 		movq	%rax, disk+32(%rip)
 423      000000
 113:disk_controller.c **** }
 424              		.loc 1 113 0
 425 046f 90       		nop
 426 0470 5D       		popq	%rbp
 427              		.cfi_def_cfa 7, 8
 428 0471 C3       		ret
 429              		.cfi_endproc
 430              	.LFE4:
 432              		.globl	CHS2LBA
 434              	CHS2LBA:
 435              	.LFB5:
 114:disk_controller.c **** 
 115:disk_controller.c **** void CHS2LBA() {
 436              		.loc 1 115 0
 437              		.cfi_startproc
 438 0472 55       		pushq	%rbp
 439              		.cfi_def_cfa_offset 16
 440              		.cfi_offset 6, -16
 441 0473 4889E5   		movq	%rsp, %rbp
 442              		.cfi_def_cfa_register 6
 116:disk_controller.c **** 	int cylinder, head, sector;
 117:disk_controller.c **** 	cylinder = (disk.chs & 0xFE00) >> 9;
 443              		.loc 1 117 0
 444 0476 8B050000 		movl	disk+4(%rip), %eax
 444      0000
 445 047c C1F809   		sarl	$9, %eax
 446 047f 83E07F   		andl	$127, %eax
 447 0482 8945FC   		movl	%eax, -4(%rbp)
 118:disk_controller.c **** 	head     = (disk.chs & 0x01D0) >> 6;
 448              		.loc 1 118 0
 449 0485 8B050000 		movl	disk+4(%rip), %eax
 449      0000
 450 048b C1F806   		sarl	$6, %eax
 451 048e 83E007   		andl	$7, %eax
 452 0491 8945F8   		movl	%eax, -8(%rbp)
 119:disk_controller.c **** 	sector   =  disk.chs & 0x003F;
 453              		.loc 1 119 0
 454 0494 8B050000 		movl	disk+4(%rip), %eax
 454      0000
 455 049a 83E03F   		andl	$63, %eax
 456 049d 8945F4   		movl	%eax, -12(%rbp)
 120:disk_controller.c **** 	disk.lba = (cylinder*HEAD_COUNT + head)*SECT_COUNT + sector;
 457              		.loc 1 120 0
 458 04a0 8B45FC   		movl	-4(%rbp), %eax
 459 04a3 8D14C500 		leal	0(,%rax,8), %edx
 459      000000
 460 04aa 8B45F8   		movl	-8(%rbp), %eax
 461 04ad 01D0     		addl	%edx, %eax
 462 04af C1E006   		sall	$6, %eax
 463 04b2 89C2     		movl	%eax, %edx
 464 04b4 8B45F4   		movl	-12(%rbp), %eax
 465 04b7 01D0     		addl	%edx, %eax
 466 04b9 89050000 		movl	%eax, disk(%rip)
 466      0000
 121:disk_controller.c **** 	disk.lba *= RECORD_SIZE;
 467              		.loc 1 121 0
 468 04bf 8B050000 		movl	disk(%rip), %eax
 468      0000
 469 04c5 C1E009   		sall	$9, %eax
 470 04c8 89050000 		movl	%eax, disk(%rip)
 470      0000
 122:disk_controller.c **** }
 471              		.loc 1 122 0
 472 04ce 90       		nop
 473 04cf 5D       		popq	%rbp
 474              		.cfi_def_cfa 7, 8
 475 04d0 C3       		ret
 476              		.cfi_endproc
 477              	.LFE5:
 479              	.Letext0:
 480              		.file 2 "/usr/lib/gcc/x86_64-pc-linux-gnu/6.3.1/include/stddef.h"
 481              		.file 3 "/usr/include/bits/types.h"
 482              		.file 4 "/usr/include/stdio.h"
 483              		.file 5 "/usr/include/libio.h"
 484              		.file 6 "/usr/include/bits/sys_errlist.h"
 485              		.file 7 "disk_controller.h"
 486              		.file 8 "../I8080/I8080.h"
