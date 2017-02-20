   1              		.file	"DPC.c"
   2              		.text
   3              	.Ltext0:
   4              		.local	hold
   5              		.comm	hold,4,4
   6              		.comm	video,816,32
   7              		.comm	keyboardbuffer,8,8
   8              		.comm	keyindex,1,1
   9              		.comm	processed,1,1
  10              		.section	.rodata
  11              	.LC0:
  12 0000 53444C5F 		.string	"SDL_Init Error: %s"
  12      496E6974 
  12      20457272 
  12      6F723A20 
  12      257300
  13              	.LC1:
  14 0013 726200   		.string	"rb"
  15              	.LC2:
  16 0016 62696F73 		.string	"bios/BIOS.bin"
  16      2F42494F 
  16      532E6269 
  16      6E00
  17              	.LC3:
  18 0024 52656164 		.string	"Reading error"
  18      696E6720 
  18      6572726F 
  18      7200
  19              		.text
  20              		.globl	main
  22              	main:
  23              	.LFB508:
  24              		.file 1 "DPC.c"
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
  25              		.loc 1 16 0
  26              		.cfi_startproc
  27 0000 55       		pushq	%rbp
  28              		.cfi_def_cfa_offset 16
  29              		.cfi_offset 6, -16
  30 0001 4889E5   		movq	%rsp, %rbp
  31              		.cfi_def_cfa_register 6
  32 0004 4883C480 		addq	$-128, %rsp
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
  33              		.loc 1 26 0
  34 0008 B8000000 		movl	$0, %eax
  34      00
  35 000d E8000000 		call	newCPU
  35      00
  36 0012 488945E0 		movq	%rax, -32(%rbp)
  27:DPC.c         **** 	keyboardbuffer = malloc(1024);
  37              		.loc 1 27 0
  38 0016 BF000400 		movl	$1024, %edi
  38      00
  39 001b E8000000 		call	malloc
  39      00
  40 0020 48890500 		movq	%rax, keyboardbuffer(%rip)
  40      000000
  28:DPC.c         **** 	
  29:DPC.c         **** 	if (SDL_Init(SDL_INIT_EVERYTHING) != 0){
  41              		.loc 1 29 0
  42 0027 BF317200 		movl	$29233, %edi
  42      00
  43 002c E8000000 		call	SDL_Init
  43      00
  44 0031 85C0     		testl	%eax, %eax
  45 0033 7421     		je	.L2
  30:DPC.c         ****         printf("SDL_Init Error: %s", SDL_GetError());
  46              		.loc 1 30 0
  47 0035 E8000000 		call	SDL_GetError
  47      00
  48 003a 4889C6   		movq	%rax, %rsi
  49 003d BF000000 		movl	$.LC0, %edi
  49      00
  50 0042 B8000000 		movl	$0, %eax
  50      00
  51 0047 E8000000 		call	printf
  51      00
  31:DPC.c         ****         return 1;
  52              		.loc 1 31 0
  53 004c B8010000 		movl	$1, %eax
  53      00
  54 0051 E9D30300 		jmp	.L29
  54      00
  55              	.L2:
  32:DPC.c         ****     }
  33:DPC.c         **** 	initCPU(cpu);
  56              		.loc 1 33 0
  57 0056 488B45E0 		movq	-32(%rbp), %rax
  58 005a 4889C7   		movq	%rax, %rdi
  59 005d E8000000 		call	initCPU
  59      00
  34:DPC.c         **** 	initMemory();
  60              		.loc 1 34 0
  61 0062 B8000000 		movl	$0, %eax
  61      00
  62 0067 E8000000 		call	initMemory
  62      00
  35:DPC.c         **** 	initDisplay();
  63              		.loc 1 35 0
  64 006c B8000000 		movl	$0, %eax
  64      00
  65 0071 E8000000 		call	initDisplay
  65      00
  36:DPC.c         **** 	initHardDrive();
  66              		.loc 1 36 0
  67 0076 B8000000 		movl	$0, %eax
  67      00
  68 007b E8000000 		call	initHardDrive
  68      00
  37:DPC.c         **** 	setMMU(cpu, myMMU);
  69              		.loc 1 37 0
  70 0080 488B45E0 		movq	-32(%rbp), %rax
  71 0084 BE000000 		movl	$myMMU, %esi
  71      00
  72 0089 4889C7   		movq	%rax, %rdi
  73 008c E8000000 		call	setMMU
  73      00
  38:DPC.c         **** 	setIOPort(cpu, 1, port01_display_mode);
  74              		.loc 1 38 0
  75 0091 488B45E0 		movq	-32(%rbp), %rax
  76 0095 BA000000 		movl	$port01_display_mode, %edx
  76      00
  77 009a BE010000 		movl	$1, %esi
  77      00
  78 009f 4889C7   		movq	%rax, %rdi
  79 00a2 E8000000 		call	setIOPort
  79      00
  39:DPC.c         **** 	setIOPort(cpu, 2, port02_operation);
  80              		.loc 1 39 0
  81 00a7 488B45E0 		movq	-32(%rbp), %rax
  82 00ab BA000000 		movl	$port02_operation, %edx
  82      00
  83 00b0 BE020000 		movl	$2, %esi
  83      00
  84 00b5 4889C7   		movq	%rax, %rdi
  85 00b8 E8000000 		call	setIOPort
  85      00
  40:DPC.c         **** 	setIOPort(cpu, 3, port03_charin);
  86              		.loc 1 40 0
  87 00bd 488B45E0 		movq	-32(%rbp), %rax
  88 00c1 BA000000 		movl	$port03_charin, %edx
  88      00
  89 00c6 BE030000 		movl	$3, %esi
  89      00
  90 00cb 4889C7   		movq	%rax, %rdi
  91 00ce E8000000 		call	setIOPort
  91      00
  41:DPC.c         **** 	setIOPort(cpu, 4, port04_keyout);
  92              		.loc 1 41 0
  93 00d3 488B45E0 		movq	-32(%rbp), %rax
  94 00d7 BA000000 		movl	$port04_keyout, %edx
  94      00
  95 00dc BE040000 		movl	$4, %esi
  95      00
  96 00e1 4889C7   		movq	%rax, %rdi
  97 00e4 E8000000 		call	setIOPort
  97      00
  42:DPC.c         **** 	setIOPort(cpu, 5, port05_diskrx);
  98              		.loc 1 42 0
  99 00e9 488B45E0 		movq	-32(%rbp), %rax
 100 00ed BA000000 		movl	$port05_diskrx, %edx
 100      00
 101 00f2 BE050000 		movl	$5, %esi
 101      00
 102 00f7 4889C7   		movq	%rax, %rdi
 103 00fa E8000000 		call	setIOPort
 103      00
  43:DPC.c         **** 	setIOPort(cpu, 6, port06_disktx);
 104              		.loc 1 43 0
 105 00ff 488B45E0 		movq	-32(%rbp), %rax
 106 0103 BA000000 		movl	$port06_disktx, %edx
 106      00
 107 0108 BE060000 		movl	$6, %esi
 107      00
 108 010d 4889C7   		movq	%rax, %rdi
 109 0110 E8000000 		call	setIOPort
 109      00
  44:DPC.c         **** 	setIOPort(cpu, 0xA, port0A_switch_bank);
 110              		.loc 1 44 0
 111 0115 488B45E0 		movq	-32(%rbp), %rax
 112 0119 BA000000 		movl	$port0A_switch_bank, %edx
 112      00
 113 011e BE0A0000 		movl	$10, %esi
 113      00
 114 0123 4889C7   		movq	%rax, %rdi
 115 0126 E8000000 		call	setIOPort
 115      00
  45:DPC.c         **** 	
  46:DPC.c         **** 	boot = fopen("bios/BIOS.bin", "rb");
 116              		.loc 1 46 0
 117 012b BE000000 		movl	$.LC1, %esi
 117      00
 118 0130 BF000000 		movl	$.LC2, %edi
 118      00
 119 0135 E8000000 		call	fopen
 119      00
 120 013a 488945D8 		movq	%rax, -40(%rbp)
  47:DPC.c         **** 	fseek(boot , 0 , SEEK_END);
 121              		.loc 1 47 0
 122 013e 488B45D8 		movq	-40(%rbp), %rax
 123 0142 BA020000 		movl	$2, %edx
 123      00
 124 0147 BE000000 		movl	$0, %esi
 124      00
 125 014c 4889C7   		movq	%rax, %rdi
 126 014f E8000000 		call	fseek
 126      00
  48:DPC.c         ****     lSize  = ftell(boot);
 127              		.loc 1 48 0
 128 0154 488B45D8 		movq	-40(%rbp), %rax
 129 0158 4889C7   		movq	%rax, %rdi
 130 015b E8000000 		call	ftell
 130      00
 131 0160 8945D4   		movl	%eax, -44(%rbp)
  49:DPC.c         ****     rewind(boot);
 132              		.loc 1 49 0
 133 0163 488B45D8 		movq	-40(%rbp), %rax
 134 0167 4889C7   		movq	%rax, %rdi
 135 016a E8000000 		call	rewind
 135      00
  50:DPC.c         ****     result = fread(memBanks[0], 1, lSize, boot);
 136              		.loc 1 50 0
 137 016f 8B45D4   		movl	-44(%rbp), %eax
 138 0172 4863D0   		movslq	%eax, %rdx
 139 0175 488B0500 		movq	memBanks(%rip), %rax
 139      000000
 140 017c 488B4DD8 		movq	-40(%rbp), %rcx
 141 0180 BE010000 		movl	$1, %esi
 141      00
 142 0185 4889C7   		movq	%rax, %rdi
 143 0188 E8000000 		call	fread
 143      00
 144 018d 8945D0   		movl	%eax, -48(%rbp)
  51:DPC.c         **** 	
  52:DPC.c         **** 	if (result != lSize) {fputs ("Reading error",stderr); exit (3);}
 145              		.loc 1 52 0
 146 0190 8B45D0   		movl	-48(%rbp), %eax
 147 0193 3B45D4   		cmpl	-44(%rbp), %eax
 148 0196 7428     		je	.L4
 149              		.loc 1 52 0 is_stmt 0 discriminator 1
 150 0198 488B0500 		movq	stderr(%rip), %rax
 150      000000
 151 019f 4889C1   		movq	%rax, %rcx
 152 01a2 BA0D0000 		movl	$13, %edx
 152      00
 153 01a7 BE010000 		movl	$1, %esi
 153      00
 154 01ac BF000000 		movl	$.LC3, %edi
 154      00
 155 01b1 E8000000 		call	fwrite
 155      00
 156 01b6 BF030000 		movl	$3, %edi
 156      00
 157 01bb E8000000 		call	exit
 157      00
 158              	.L4:
  53:DPC.c         **** 	
  54:DPC.c         **** 	fclose(boot);
 159              		.loc 1 54 0 is_stmt 1
 160 01c0 488B45D8 		movq	-40(%rbp), %rax
 161 01c4 4889C7   		movq	%rax, %rdi
 162 01c7 E8000000 		call	fclose
 162      00
  55:DPC.c         **** 	
  56:DPC.c         **** 	cycles_per_loop = EXECUTION_INTERVAL * (CPU_FREQUENCY / 1000.0);
 163              		.loc 1 56 0
 164 01cc C745CCD0 		movl	$2000, -52(%rbp)
 164      070000
  57:DPC.c         **** 	target_cycles   = cycles_per_loop;
 165              		.loc 1 57 0
 166 01d3 8B45CC   		movl	-52(%rbp), %eax
 167 01d6 8945E8   		movl	%eax, -24(%rbp)
  58:DPC.c         **** 	
  59:DPC.c         **** 	target_time = getMicroSeconds();	// set start time of run
 168              		.loc 1 59 0
 169 01d9 B8000000 		movl	$0, %eax
 169      00
 170 01de E8000000 		call	getMicroSeconds
 170      00
 171 01e3 488945F0 		movq	%rax, -16(%rbp)
  60:DPC.c         **** 	
  61:DPC.c         **** 	running = 1;
 172              		.loc 1 61 0
 173 01e7 C745EC01 		movl	$1, -20(%rbp)
 173      000000
  62:DPC.c         **** 	
  63:DPC.c         **** 	while (running) {
 174              		.loc 1 63 0
 175 01ee E9060200 		jmp	.L5
 175      00
 176              	.L27:
  64:DPC.c         **** 		
  65:DPC.c         **** 		while (SDL_PollEvent(&event)) {
  66:DPC.c         **** 			ch = -1;
 177              		.loc 1 66 0
 178 01f3 C645FFFF 		movb	$-1, -1(%rbp)
  67:DPC.c         **** 			switch (event.type) {
 179              		.loc 1 67 0
 180 01f7 8B4580   		movl	-128(%rbp), %eax
 181 01fa 3D000300 		cmpl	$768, %eax
 181      00
 182 01ff 741B     		je	.L8
 183 0201 3D010300 		cmpl	$769, %eax
 183      00
 184 0206 0F84A000 		je	.L9
 184      0000
 185 020c 3D000100 		cmpl	$256, %eax
 185      00
 186 0211 0F841001 		je	.L10
 186      0000
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
 187              		.loc 1 109 0
 188 0217 E9150100 		jmp	.L18
 188      00
 189              	.L8:
  70:DPC.c         **** 						ch = key.sym&0x7F;
 190              		.loc 1 70 0
 191 021c 8B4594   		movl	-108(%rbp), %eax
 192 021f 83F81F   		cmpl	$31, %eax
 193 0222 7E16     		jle	.L11
  70:DPC.c         **** 						ch = key.sym&0x7F;
 194              		.loc 1 70 0 is_stmt 0 discriminator 1
 195 0224 8B4594   		movl	-108(%rbp), %eax
 196 0227 83F87E   		cmpl	$126, %eax
 197 022a 7F0E     		jg	.L11
  71:DPC.c         **** 					} else if (key.sym == SDLK_BACKSPACE) {
 198              		.loc 1 71 0 is_stmt 1
 199 022c 8B4594   		movl	-108(%rbp), %eax
 200 022f 83E07F   		andl	$127, %eax
 201 0232 8845FF   		movb	%al, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 202              		.loc 1 85 0
 203 0235 E9F60000 		jmp	.L30
 203      00
 204              	.L11:
  72:DPC.c         **** 						ch = 0x08;
 205              		.loc 1 72 0
 206 023a 8B4594   		movl	-108(%rbp), %eax
 207 023d 83F808   		cmpl	$8, %eax
 208 0240 7509     		jne	.L13
  73:DPC.c         **** 					} else if (key.sym == SDLK_RETURN) {
 209              		.loc 1 73 0
 210 0242 C645FF08 		movb	$8, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 211              		.loc 1 85 0
 212 0246 E9E50000 		jmp	.L30
 212      00
 213              	.L13:
  74:DPC.c         **** 						ch = 0x0A;
 214              		.loc 1 74 0
 215 024b 8B4594   		movl	-108(%rbp), %eax
 216 024e 83F80D   		cmpl	$13, %eax
 217 0251 7509     		jne	.L14
  75:DPC.c         **** 					} else if (key.sym == SDLK_UP) {
 218              		.loc 1 75 0
 219 0253 C645FF0A 		movb	$10, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 220              		.loc 1 85 0
 221 0257 E9D40000 		jmp	.L30
 221      00
 222              	.L14:
  76:DPC.c         **** 						ch = 0b11000010;
 223              		.loc 1 76 0
 224 025c 8B4594   		movl	-108(%rbp), %eax
 225 025f 3D520000 		cmpl	$1073741906, %eax
 225      40
 226 0264 7509     		jne	.L15
  77:DPC.c         **** 					} else if (key.sym == SDLK_RIGHT) {
 227              		.loc 1 77 0
 228 0266 C645FFC2 		movb	$-62, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 229              		.loc 1 85 0
 230 026a E9C10000 		jmp	.L30
 230      00
 231              	.L15:
  78:DPC.c         **** 						ch = 0b11000011;
 232              		.loc 1 78 0
 233 026f 8B4594   		movl	-108(%rbp), %eax
 234 0272 3D4F0000 		cmpl	$1073741903, %eax
 234      40
 235 0277 7509     		jne	.L16
  79:DPC.c         **** 					} else if (key.sym == SDLK_DOWN) {
 236              		.loc 1 79 0
 237 0279 C645FFC3 		movb	$-61, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 238              		.loc 1 85 0
 239 027d E9AE0000 		jmp	.L30
 239      00
 240              	.L16:
  80:DPC.c         **** 						ch = 0b11000100;
 241              		.loc 1 80 0
 242 0282 8B4594   		movl	-108(%rbp), %eax
 243 0285 3D510000 		cmpl	$1073741905, %eax
 243      40
 244 028a 7509     		jne	.L17
  81:DPC.c         **** 					} else if (key.sym == SDLK_LEFT) {
 245              		.loc 1 81 0
 246 028c C645FFC4 		movb	$-60, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 247              		.loc 1 85 0
 248 0290 E99B0000 		jmp	.L30
 248      00
 249              	.L17:
  82:DPC.c         **** 						ch = 0b11000101;
 250              		.loc 1 82 0
 251 0295 8B4594   		movl	-108(%rbp), %eax
 252 0298 3D500000 		cmpl	$1073741904, %eax
 252      40
 253 029d 0F858D00 		jne	.L30
 253      0000
  83:DPC.c         **** 					}
 254              		.loc 1 83 0
 255 02a3 C645FFC5 		movb	$-59, -1(%rbp)
  85:DPC.c         **** 				case SDL_KEYUP:
 256              		.loc 1 85 0
 257 02a7 E9840000 		jmp	.L30
 257      00
 258              	.L9:
  87:DPC.c         **** 						ch = key.sym&0x7F;
 259              		.loc 1 87 0
 260 02ac 8B4594   		movl	-108(%rbp), %eax
 261 02af 83F81F   		cmpl	$31, %eax
 262 02b2 7E13     		jle	.L19
  87:DPC.c         **** 						ch = key.sym&0x7F;
 263              		.loc 1 87 0 is_stmt 0 discriminator 1
 264 02b4 8B4594   		movl	-108(%rbp), %eax
 265 02b7 83F87E   		cmpl	$126, %eax
 266 02ba 7F0B     		jg	.L19
  88:DPC.c         **** 					} else if (key.sym == SDLK_BACKSPACE) {
 267              		.loc 1 88 0 is_stmt 1
 268 02bc 8B4594   		movl	-108(%rbp), %eax
 269 02bf 83E07F   		andl	$127, %eax
 270 02c2 8845FF   		movb	%al, -1(%rbp)
 271 02c5 EB5A     		jmp	.L20
 272              	.L19:
  89:DPC.c         **** 						ch = 0x08;
 273              		.loc 1 89 0
 274 02c7 8B4594   		movl	-108(%rbp), %eax
 275 02ca 83F808   		cmpl	$8, %eax
 276 02cd 7506     		jne	.L21
  90:DPC.c         **** 					} else if (key.sym == SDLK_RETURN) {
 277              		.loc 1 90 0
 278 02cf C645FF08 		movb	$8, -1(%rbp)
 279 02d3 EB4C     		jmp	.L20
 280              	.L21:
  91:DPC.c         **** 						ch = 0x0A;
 281              		.loc 1 91 0
 282 02d5 8B4594   		movl	-108(%rbp), %eax
 283 02d8 83F80D   		cmpl	$13, %eax
 284 02db 7506     		jne	.L22
  92:DPC.c         **** 					} else if (key.sym == SDLK_UP) {
 285              		.loc 1 92 0
 286 02dd C645FF0A 		movb	$10, -1(%rbp)
 287 02e1 EB3E     		jmp	.L20
 288              	.L22:
  93:DPC.c         **** 						ch = 0b11000010;
 289              		.loc 1 93 0
 290 02e3 8B4594   		movl	-108(%rbp), %eax
 291 02e6 3D520000 		cmpl	$1073741906, %eax
 291      40
 292 02eb 7506     		jne	.L23
  94:DPC.c         **** 					} else if (key.sym == SDLK_RIGHT) {
 293              		.loc 1 94 0
 294 02ed C645FFC2 		movb	$-62, -1(%rbp)
 295 02f1 EB2E     		jmp	.L20
 296              	.L23:
  95:DPC.c         **** 						ch = 0b11000011;
 297              		.loc 1 95 0
 298 02f3 8B4594   		movl	-108(%rbp), %eax
 299 02f6 3D4F0000 		cmpl	$1073741903, %eax
 299      40
 300 02fb 7506     		jne	.L24
  96:DPC.c         **** 					} else if (key.sym == SDLK_DOWN) {
 301              		.loc 1 96 0
 302 02fd C645FFC3 		movb	$-61, -1(%rbp)
 303 0301 EB1E     		jmp	.L20
 304              	.L24:
  97:DPC.c         **** 						ch = 0b11000100;
 305              		.loc 1 97 0
 306 0303 8B4594   		movl	-108(%rbp), %eax
 307 0306 3D510000 		cmpl	$1073741905, %eax
 307      40
 308 030b 7506     		jne	.L25
  98:DPC.c         **** 					} else if (key.sym == SDLK_LEFT) {
 309              		.loc 1 98 0
 310 030d C645FFC4 		movb	$-60, -1(%rbp)
 311 0311 EB0E     		jmp	.L20
 312              	.L25:
  99:DPC.c         **** 						ch = 0b11000101;
 313              		.loc 1 99 0
 314 0313 8B4594   		movl	-108(%rbp), %eax
 315 0316 3D500000 		cmpl	$1073741904, %eax
 315      40
 316 031b 7504     		jne	.L20
 100:DPC.c         **** 					}
 317              		.loc 1 100 0
 318 031d C645FFC5 		movb	$-59, -1(%rbp)
 319              	.L20:
 102:DPC.c         **** # undef key
 320              		.loc 1 102 0
 321 0321 804DFF80 		orb	$-128, -1(%rbp)
 104:DPC.c         **** 				case SDL_QUIT:
 322              		.loc 1 104 0
 323 0325 EB0A     		jmp	.L18
 324              	.L10:
 106:DPC.c         **** 				break;
 325              		.loc 1 106 0
 326 0327 C745EC00 		movl	$0, -20(%rbp)
 326      000000
 107:DPC.c         **** 				default: 
 327              		.loc 1 107 0
 328 032e EB01     		jmp	.L18
 329              	.L30:
  85:DPC.c         **** 				case SDL_KEYUP:
 330              		.loc 1 85 0
 331 0330 90       		nop
 332              	.L18:
 110:DPC.c         **** 			}
 111:DPC.c         **** 			
 112:DPC.c         **** 			if (ch != -1) {
 333              		.loc 1 112 0
 334 0331 807DFFFF 		cmpb	$-1, -1(%rbp)
 335 0335 7431     		je	.L26
 113:DPC.c         **** 				keyboardbuffer[keyindex++] = ch;
 336              		.loc 1 113 0
 337 0337 488B0D00 		movq	keyboardbuffer(%rip), %rcx
 337      000000
 338 033e 0FB60500 		movzbl	keyindex(%rip), %eax
 338      000000
 339 0345 8D5001   		leal	1(%rax), %edx
 340 0348 88150000 		movb	%dl, keyindex(%rip)
 340      0000
 341 034e 0FB6C0   		movzbl	%al, %eax
 342 0351 488D1401 		leaq	(%rcx,%rax), %rdx
 343 0355 0FB645FF 		movzbl	-1(%rbp), %eax
 344 0359 8802     		movb	%al, (%rdx)
 114:DPC.c         **** 				keyindex = keyindex % 1024;
 345              		.loc 1 114 0
 346 035b 0FB60500 		movzbl	keyindex(%rip), %eax
 346      000000
 347 0362 88050000 		movb	%al, keyindex(%rip)
 347      0000
 348              	.L26:
 115:DPC.c         **** 			} 
 116:DPC.c         **** 		
 117:DPC.c         **** 			if (keyindex != processed) {
 349              		.loc 1 117 0
 350 0368 0FB61500 		movzbl	keyindex(%rip), %edx
 350      000000
 351 036f 0FB60500 		movzbl	processed(%rip), %eax
 351      000000
 352 0376 38C2     		cmpb	%al, %dl
 353 0378 7411     		je	.L6
 118:DPC.c         **** 				requestInterrupt(cpu, 0xCF);
 354              		.loc 1 118 0
 355 037a 488B45E0 		movq	-32(%rbp), %rax
 356 037e BECFFFFF 		movl	$-49, %esi
 356      FF
 357 0383 4889C7   		movq	%rax, %rdi
 358 0386 E8000000 		call	requestInterrupt
 358      00
 359              	.L6:
  65:DPC.c         **** 			ch = -1;
 360              		.loc 1 65 0
 361 038b 488D4580 		leaq	-128(%rbp), %rax
 362 038f 4889C7   		movq	%rax, %rdi
 363 0392 E8000000 		call	SDL_PollEvent
 363      00
 364 0397 85C0     		testl	%eax, %eax
 365 0399 0F8554FE 		jne	.L27
 365      FFFF
 119:DPC.c         **** 			}
 120:DPC.c         **** 		}
 121:DPC.c         **** 		
 122:DPC.c         **** 		serviceDisplay();
 366              		.loc 1 122 0
 367 039f B8000000 		movl	$0, %eax
 367      00
 368 03a4 E8000000 		call	serviceDisplay
 368      00
 123:DPC.c         **** 		
 124:DPC.c         **** 		// Attempt to execute x number of cycles (which will most likely overshoot)
 125:DPC.c         **** 		actual_cycles = executeCycles(cpu, target_cycles); 
 369              		.loc 1 125 0
 370 03a9 8B55E8   		movl	-24(%rbp), %edx
 371 03ac 488B45E0 		movq	-32(%rbp), %rax
 372 03b0 89D6     		movl	%edx, %esi
 373 03b2 4889C7   		movq	%rax, %rdi
 374 03b5 E8000000 		call	executeCycles
 374      00
 375 03ba 8945C8   		movl	%eax, -56(%rbp)
 126:DPC.c         ****         // Calculate the target number of cycles to execute for next loop
 127:DPC.c         ****         // Not all instructions are of uniform cycle count, so the last instruction may very well t
 128:DPC.c         **** 		target_cycles = cycles_per_loop + target_cycles - actual_cycles;
 376              		.loc 1 128 0
 377 03bd 8B55CC   		movl	-52(%rbp), %edx
 378 03c0 8B45E8   		movl	-24(%rbp), %eax
 379 03c3 01D0     		addl	%edx, %eax
 380 03c5 2B45C8   		subl	-56(%rbp), %eax
 381 03c8 8945E8   		movl	%eax, -24(%rbp)
 129:DPC.c         **** 		
 130:DPC.c         **** 		// the following code sets up a syncronized delay window
 131:DPC.c         **** 		// using absolute time as opposed to relative for each cycle.
 132:DPC.c         **** 		// this greatly simplifies the code while eliminating the 
 133:DPC.c         **** 		// issue of accumulating time that is unaccounted for
 134:DPC.c         **** 		
 135:DPC.c         **** 		target_time = target_time + EXECUTION_INTERVAL;		// calculate the next absolute time we want to b
 382              		.loc 1 135 0
 383 03cb 488145F0 		addq	$1000, -16(%rbp)
 383      E8030000 
 136:DPC.c         **** 		
 137:DPC.c         **** 		delta_time = getMicroSeconds();						// get current absolute time
 384              		.loc 1 137 0
 385 03d3 B8000000 		movl	$0, %eax
 385      00
 386 03d8 E8000000 		call	getMicroSeconds
 386      00
 387 03dd 488945C0 		movq	%rax, -64(%rbp)
 138:DPC.c         **** 		
 139:DPC.c         **** 		delta_time = target_time - delta_time;				// calculate time difference
 388              		.loc 1 139 0
 389 03e1 488B45F0 		movq	-16(%rbp), %rax
 390 03e5 482B45C0 		subq	-64(%rbp), %rax
 391 03e9 488945C0 		movq	%rax, -64(%rbp)
 140:DPC.c         **** 		
 141:DPC.c         **** 		delayMicroSeconds(delta_time);						// wait for specified time
 392              		.loc 1 141 0
 393 03ed 488B45C0 		movq	-64(%rbp), %rax
 394 03f1 4889C7   		movq	%rax, %rdi
 395 03f4 E8000000 		call	delayMicroSeconds
 395      00
 396              	.L5:
  63:DPC.c         **** 		
 397              		.loc 1 63 0
 398 03f9 837DEC00 		cmpl	$0, -20(%rbp)
 399 03fd 758C     		jne	.L6
 142:DPC.c         **** 		
 143:DPC.c         **** 	}
 144:DPC.c         **** 	
 145:DPC.c         **** 	SDL_Quit();
 400              		.loc 1 145 0
 401 03ff E8000000 		call	SDL_Quit
 401      00
 146:DPC.c         **** 	freeCPU(cpu);
 402              		.loc 1 146 0
 403 0404 488B45E0 		movq	-32(%rbp), %rax
 404 0408 4889C7   		movq	%rax, %rdi
 405 040b E8000000 		call	freeCPU
 405      00
 147:DPC.c         **** 	getchar();
 406              		.loc 1 147 0
 407 0410 E8000000 		call	getchar
 407      00
 148:DPC.c         **** 	fflush(stdin);
 408              		.loc 1 148 0
 409 0415 488B0500 		movq	stdin(%rip), %rax
 409      000000
 410 041c 4889C7   		movq	%rax, %rdi
 411 041f E8000000 		call	fflush
 411      00
 149:DPC.c         **** 	return 0;
 412              		.loc 1 149 0
 413 0424 B8000000 		movl	$0, %eax
 413      00
 414              	.L29:
 150:DPC.c         **** }
 415              		.loc 1 150 0 discriminator 1
 416 0429 C9       		leave
 417              		.cfi_def_cfa 7, 8
 418 042a C3       		ret
 419              		.cfi_endproc
 420              	.LFE508:
 422              	.Letext0:
 423              		.file 2 "/usr/lib/gcc/x86_64-pc-linux-gnu/6.3.1/include/stddef.h"
 424              		.file 3 "/usr/include/bits/types.h"
 425              		.file 4 "/usr/include/stdio.h"
 426              		.file 5 "/usr/include/libio.h"
 427              		.file 6 "/usr/include/bits/sys_errlist.h"
 428              		.file 7 "/usr/include/stdint.h"
 429              		.file 8 "/usr/include/time.h"
 430              		.file 9 "../I8080/I8080.h"
 431              		.file 10 "/usr/include/math.h"
 432              		.file 11 "/usr/include/SDL2/SDL_stdinc.h"
 433              		.file 12 "/usr/include/SDL2/SDL_pixels.h"
 434              		.file 13 "/usr/include/SDL2/SDL_rect.h"
 435              		.file 14 "/usr/include/SDL2/SDL_surface.h"
 436              		.file 15 "/usr/include/SDL2/SDL_video.h"
 437              		.file 16 "/usr/include/SDL2/SDL_scancode.h"
 438              		.file 17 "/usr/include/SDL2/SDL_keycode.h"
 439              		.file 18 "/usr/include/SDL2/SDL_keyboard.h"
 440              		.file 19 "/usr/include/SDL2/SDL_joystick.h"
 441              		.file 20 "/usr/include/SDL2/SDL_touch.h"
 442              		.file 21 "/usr/include/SDL2/SDL_gesture.h"
 443              		.file 22 "/usr/include/SDL2/SDL_events.h"
 444              		.file 23 "/usr/include/SDL2/SDL_messagebox.h"
 445              		.file 24 "video.h"
 446              		.file 25 "keyboard.h"
 447              		.file 26 "disk_controller.h"
 448              		.file 27 "memory.h"
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
   4:video.c       **** Uint32 ReadPixel(SDL_Surface* source, Sint16 X, Sint16 Y) {
  12              		.loc 1 4 0
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
   5:video.c       **** 	return *((Uint32 *) (source->pixels + X + (Y*source->pitch)));
  24              		.loc 1 5 0
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
   6:video.c       **** }
  36              		.loc 1 6 0
  37 0039 5D       		popq	%rbp
  38              		.cfi_def_cfa 7, 8
  39 003a C3       		ret
  40              		.cfi_endproc
  41              	.LFE508:
  43              		.globl	DrawPixel
  45              	DrawPixel:
  46              	.LFB509:
   7:video.c       **** 
   8:video.c       **** void DrawPixel(SDL_Surface *surface, int x, int y, Uint32 color) {
  47              		.loc 1 8 0
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
   9:video.c       **** 	Uint32 *currentpixel = (Uint32 *)(surface->pixels + x + (y*surface->pitch));
  58              		.loc 1 9 0
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
  10:video.c       **** 	*currentpixel = color;
  70              		.loc 1 10 0
  71 0071 488B45F8 		movq	-8(%rbp), %rax
  72 0075 8B55DC   		movl	-36(%rbp), %edx
  73 0078 8910     		movl	%edx, (%rax)
  11:video.c       **** }
  74              		.loc 1 11 0
  75 007a 90       		nop
  76 007b 5D       		popq	%rbp
  77              		.cfi_def_cfa 7, 8
  78 007c C3       		ret
  79              		.cfi_endproc
  80              	.LFE509:
  82              		.globl	LinearScale
  84              	LinearScale:
  85              	.LFB510:
  12:video.c       **** 
  13:video.c       **** SDL_Surface *LinearScale(SDL_Surface *Surface, int scale_factor) {
  86              		.loc 1 13 0
  87              		.cfi_startproc
  88 007d 55       		pushq	%rbp
  89              		.cfi_def_cfa_offset 16
  90              		.cfi_offset 6, -16
  91 007e 4889E5   		movq	%rsp, %rbp
  92              		.cfi_def_cfa_register 6
  93 0081 4883EC30 		subq	$48, %rsp
  94 0085 48897DD8 		movq	%rdi, -40(%rbp)
  95 0089 8975D4   		movl	%esi, -44(%rbp)
  14:video.c       **** 	SDL_Surface *_ret = SDL_CreateRGBSurface(Surface->flags, scale_factor*Surface->w, scale_factor*Sur
  15:video.c       ****         Surface->format->Rmask, Surface->format->Gmask, Surface->format->Bmask, Surface->format->Am
  96              		.loc 1 15 0
  97 008c 488B45D8 		movq	-40(%rbp), %rax
  98 0090 488B4008 		movq	8(%rax), %rax
  14:video.c       **** 	SDL_Surface *_ret = SDL_CreateRGBSurface(Surface->flags, scale_factor*Surface->w, scale_factor*Sur
  99              		.loc 1 14 0
 100 0094 448B4020 		movl	32(%rax), %r8d
 101              		.loc 1 15 0
 102 0098 488B45D8 		movq	-40(%rbp), %rax
 103 009c 488B4008 		movq	8(%rax), %rax
  14:video.c       **** 	SDL_Surface *_ret = SDL_CreateRGBSurface(Surface->flags, scale_factor*Surface->w, scale_factor*Sur
 104              		.loc 1 14 0
 105 00a0 8B781C   		movl	28(%rax), %edi
 106              		.loc 1 15 0
 107 00a3 488B45D8 		movq	-40(%rbp), %rax
 108 00a7 488B4008 		movq	8(%rax), %rax
  14:video.c       **** 	SDL_Surface *_ret = SDL_CreateRGBSurface(Surface->flags, scale_factor*Surface->w, scale_factor*Sur
 109              		.loc 1 14 0
 110 00ab 448B4818 		movl	24(%rax), %r9d
 111              		.loc 1 15 0
 112 00af 488B45D8 		movq	-40(%rbp), %rax
 113 00b3 488B4008 		movq	8(%rax), %rax
  14:video.c       **** 	SDL_Surface *_ret = SDL_CreateRGBSurface(Surface->flags, scale_factor*Surface->w, scale_factor*Sur
 114              		.loc 1 14 0
 115 00b7 448B5014 		movl	20(%rax), %r10d
 116 00bb 488B45D8 		movq	-40(%rbp), %rax
 117 00bf 488B4008 		movq	8(%rax), %rax
 118 00c3 0FB64010 		movzbl	16(%rax), %eax
 119 00c7 0FB6C8   		movzbl	%al, %ecx
 120 00ca 488B45D8 		movq	-40(%rbp), %rax
 121 00ce 8B4014   		movl	20(%rax), %eax
 122 00d1 0FAF45D4 		imull	-44(%rbp), %eax
 123 00d5 89C2     		movl	%eax, %edx
 124 00d7 488B45D8 		movq	-40(%rbp), %rax
 125 00db 8B4010   		movl	16(%rax), %eax
 126 00de 0FAF45D4 		imull	-44(%rbp), %eax
 127 00e2 89C6     		movl	%eax, %esi
 128 00e4 488B45D8 		movq	-40(%rbp), %rax
 129 00e8 8B00     		movl	(%rax), %eax
 130 00ea 4150     		pushq	%r8
 131 00ec 57       		pushq	%rdi
 132 00ed 4589D0   		movl	%r10d, %r8d
 133 00f0 89C7     		movl	%eax, %edi
 134 00f2 E8000000 		call	SDL_CreateRGBSurface
 134      00
 135 00f7 4883C410 		addq	$16, %rsp
 136 00fb 488945E8 		movq	%rax, -24(%rbp)
 137              	.LBB2:
  16:video.c       ****  
  17:video.c       ****     for(Sint32 y = 0; y < Surface->h; y++)
 138              		.loc 1 17 0
 139 00ff C745FC00 		movl	$0, -4(%rbp)
 139      000000
 140 0106 E9920000 		jmp	.L5
 140      00
 141              	.L12:
 142              	.LBB3:
  18:video.c       ****         for(Sint32 x = 0; x < Surface->w; x++)
 143              		.loc 1 18 0
 144 010b C745F800 		movl	$0, -8(%rbp)
 144      000000
 145 0112 EB75     		jmp	.L6
 146              	.L11:
 147              	.LBB4:
  19:video.c       ****             for(Sint32 o_y = 0; o_y < scale_factor; ++o_y)
 148              		.loc 1 19 0
 149 0114 C745F400 		movl	$0, -12(%rbp)
 149      000000
 150 011b EB60     		jmp	.L7
 151              	.L10:
 152              	.LBB5:
  20:video.c       ****                 for(Sint32 o_x = 0; o_x < scale_factor; ++o_x)
 153              		.loc 1 20 0
 154 011d C745F000 		movl	$0, -16(%rbp)
 154      000000
 155 0124 EB4B     		jmp	.L8
 156              	.L9:
  21:video.c       ****                     DrawPixel(_ret, (Sint32) (scale_factor * x) + o_x, 
 157              		.loc 1 21 0 discriminator 3
 158 0126 8B45FC   		movl	-4(%rbp), %eax
 159 0129 0FBFD0   		movswl	%ax, %edx
 160 012c 8B45F8   		movl	-8(%rbp), %eax
 161 012f 0FBFC8   		movswl	%ax, %ecx
 162 0132 488B45D8 		movq	-40(%rbp), %rax
 163 0136 89CE     		movl	%ecx, %esi
 164 0138 4889C7   		movq	%rax, %rdi
 165 013b E8000000 		call	ReadPixel
 165      00
 166 0140 89C7     		movl	%eax, %edi
  22:video.c       ****                         (Sint32) (scale_factor * y) + o_y, ReadPixel(Surface, x, y));
 167              		.loc 1 22 0 discriminator 3
 168 0142 8B45D4   		movl	-44(%rbp), %eax
 169 0145 0FAF45FC 		imull	-4(%rbp), %eax
 170 0149 89C2     		movl	%eax, %edx
  21:video.c       ****                     DrawPixel(_ret, (Sint32) (scale_factor * x) + o_x, 
 171              		.loc 1 21 0 discriminator 3
 172 014b 8B45F4   		movl	-12(%rbp), %eax
 173 014e 01C2     		addl	%eax, %edx
 174 0150 8B45D4   		movl	-44(%rbp), %eax
 175 0153 0FAF45F8 		imull	-8(%rbp), %eax
 176 0157 89C1     		movl	%eax, %ecx
 177 0159 8B45F0   		movl	-16(%rbp), %eax
 178 015c 8D3401   		leal	(%rcx,%rax), %esi
 179 015f 488B45E8 		movq	-24(%rbp), %rax
 180 0163 89F9     		movl	%edi, %ecx
 181 0165 4889C7   		movq	%rax, %rdi
 182 0168 E8000000 		call	DrawPixel
 182      00
  20:video.c       ****                 for(Sint32 o_x = 0; o_x < scale_factor; ++o_x)
 183              		.loc 1 20 0 discriminator 3
 184 016d 8345F001 		addl	$1, -16(%rbp)
 185              	.L8:
  20:video.c       ****                 for(Sint32 o_x = 0; o_x < scale_factor; ++o_x)
 186              		.loc 1 20 0 is_stmt 0 discriminator 1
 187 0171 8B45F0   		movl	-16(%rbp), %eax
 188 0174 3B45D4   		cmpl	-44(%rbp), %eax
 189 0177 7CAD     		jl	.L9
 190              	.LBE5:
  19:video.c       ****                 for(Sint32 o_x = 0; o_x < scale_factor; ++o_x)
 191              		.loc 1 19 0 is_stmt 1 discriminator 2
 192 0179 8345F401 		addl	$1, -12(%rbp)
 193              	.L7:
  19:video.c       ****                 for(Sint32 o_x = 0; o_x < scale_factor; ++o_x)
 194              		.loc 1 19 0 is_stmt 0 discriminator 1
 195 017d 8B45F4   		movl	-12(%rbp), %eax
 196 0180 3B45D4   		cmpl	-44(%rbp), %eax
 197 0183 7C98     		jl	.L10
 198              	.LBE4:
  18:video.c       ****             for(Sint32 o_y = 0; o_y < scale_factor; ++o_y)
 199              		.loc 1 18 0 is_stmt 1 discriminator 2
 200 0185 8345F801 		addl	$1, -8(%rbp)
 201              	.L6:
  18:video.c       ****             for(Sint32 o_y = 0; o_y < scale_factor; ++o_y)
 202              		.loc 1 18 0 is_stmt 0 discriminator 1
 203 0189 488B45D8 		movq	-40(%rbp), %rax
 204 018d 8B4010   		movl	16(%rax), %eax
 205 0190 3B45F8   		cmpl	-8(%rbp), %eax
 206 0193 0F8F7BFF 		jg	.L11
 206      FFFF
 207              	.LBE3:
  17:video.c       ****         for(Sint32 x = 0; x < Surface->w; x++)
 208              		.loc 1 17 0 is_stmt 1 discriminator 2
 209 0199 8345FC01 		addl	$1, -4(%rbp)
 210              	.L5:
  17:video.c       ****         for(Sint32 x = 0; x < Surface->w; x++)
 211              		.loc 1 17 0 is_stmt 0 discriminator 1
 212 019d 488B45D8 		movq	-40(%rbp), %rax
 213 01a1 8B4014   		movl	20(%rax), %eax
 214 01a4 3B45FC   		cmpl	-4(%rbp), %eax
 215 01a7 0F8F5EFF 		jg	.L12
 215      FFFF
 216              	.LBE2:
  23:video.c       ****  
  24:video.c       ****     return _ret;
 217              		.loc 1 24 0 is_stmt 1
 218 01ad 488B45E8 		movq	-24(%rbp), %rax
  25:video.c       **** }
 219              		.loc 1 25 0
 220 01b1 C9       		leave
 221              		.cfi_def_cfa 7, 8
 222 01b2 C3       		ret
 223              		.cfi_endproc
 224              	.LFE510:
 226              		.section	.rodata
 227              	.LC0:
 228 0000 44504320 		.string	"DPC Emulator"
 228      456D756C 
 228      61746F72 
 228      00
 229              	.LC1:
 230 000d 63686172 		.string	"charmap/%d.bmp"
 230      6D61702F 
 230      25642E62 
 230      6D7000
 231              	.LC2:
 232 001c 726200   		.string	"rb"
 233              		.text
 234              		.globl	initDisplay
 236              	initDisplay:
 237              	.LFB511:
  26:video.c       **** 
  27:video.c       **** void initDisplay() {
 238              		.loc 1 27 0
 239              		.cfi_startproc
 240 01b3 55       		pushq	%rbp
 241              		.cfi_def_cfa_offset 16
 242              		.cfi_offset 6, -16
 243 01b4 4889E5   		movq	%rsp, %rbp
 244              		.cfi_def_cfa_register 6
 245 01b7 4883EC20 		subq	$32, %rsp
  28:video.c       **** 	video.charBuffer  = calloc(1680, 1);
 246              		.loc 1 28 0
 247 01bb BE010000 		movl	$1, %esi
 247      00
 248 01c0 BF900600 		movl	$1680, %edi
 248      00
 249 01c5 E8000000 		call	calloc
 249      00
 250 01ca 48890500 		movq	%rax, video+792(%rip)
 250      000000
  29:video.c       **** 	video.pixelBuffer = calloc(0x5000, 1);
 251              		.loc 1 29 0
 252 01d1 BE010000 		movl	$1, %esi
 252      00
 253 01d6 BF005000 		movl	$20480, %edi
 253      00
 254 01db E8000000 		call	calloc
 254      00
 255 01e0 48890500 		movq	%rax, video+784(%rip)
 255      000000
  30:video.c       **** 	video.window 	  = SDL_CreateWindow("DPC Emulator", 0, 0, REAL_WIDTH, REAL_HEIGHT, SDL_WINDOW_SHOWN
 256              		.loc 1 30 0
 257 01e7 41B90400 		movl	$4, %r9d
 257      0000
 258 01ed 41B8C001 		movl	$448, %r8d
 258      0000
 259 01f3 B9D00200 		movl	$720, %ecx
 259      00
 260 01f8 BA000000 		movl	$0, %edx
 260      00
 261 01fd BE000000 		movl	$0, %esi
 261      00
 262 0202 BF000000 		movl	$.LC0, %edi
 262      00
 263 0207 E8000000 		call	SDL_CreateWindow
 263      00
 264 020c 48890500 		movq	%rax, video(%rip)
 264      000000
  31:video.c       **** 	video.screen	  = SDL_GetWindowSurface(video.window);
 265              		.loc 1 31 0
 266 0213 488B0500 		movq	video(%rip), %rax
 266      000000
 267 021a 4889C7   		movq	%rax, %rdi
 268 021d E8000000 		call	SDL_GetWindowSurface
 268      00
 269 0222 48890500 		movq	%rax, video+8(%rip)
 269      000000
  32:video.c       **** 	
  33:video.c       **** 	video.textOperation = APPEND_CHAR;
 270              		.loc 1 33 0
 271 0229 C6050000 		movb	$1, video+800(%rip)
 271      000001
  34:video.c       **** 	video.dirtyBuffer = 1;
 272              		.loc 1 34 0
 273 0230 C7050000 		movl	$1, video+808(%rip)
 273      00000100 
 273      0000
  35:video.c       **** 	video.displayMode = LOW_RES;
 274              		.loc 1 35 0
 275 023a C6050000 		movb	$1, video+801(%rip)
 275      000001
  36:video.c       **** 	
  37:video.c       **** 	int i; 
  38:video.c       **** 	
  39:video.c       **** 	for (i=0;i<95;i++) {
 276              		.loc 1 39 0
 277 0241 C745FC00 		movl	$0, -4(%rbp)
 277      000000
 278 0248 EB70     		jmp	.L15
 279              	.L16:
 280              	.LBB6:
  40:video.c       **** 		char buf[16];
  41:video.c       **** 		sprintf(buf, "charmap/%d.bmp", i);
 281              		.loc 1 41 0 discriminator 3
 282 024a 8B55FC   		movl	-4(%rbp), %edx
 283 024d 488D45E0 		leaq	-32(%rbp), %rax
 284 0251 BE000000 		movl	$.LC1, %esi
 284      00
 285 0256 4889C7   		movq	%rax, %rdi
 286 0259 B8000000 		movl	$0, %eax
 286      00
 287 025e E8000000 		call	sprintf
 287      00
  42:video.c       **** 		SDL_Surface *charimg = SDL_LoadBMP(buf);
 288              		.loc 1 42 0 discriminator 3
 289 0263 488D45E0 		leaq	-32(%rbp), %rax
 290 0267 BE000000 		movl	$.LC2, %esi
 290      00
 291 026c 4889C7   		movq	%rax, %rdi
 292 026f E8000000 		call	SDL_RWFromFile
 292      00
 293 0274 BE010000 		movl	$1, %esi
 293      00
 294 0279 4889C7   		movq	%rax, %rdi
 295 027c E8000000 		call	SDL_LoadBMP_RW
 295      00
 296 0281 488945F0 		movq	%rax, -16(%rbp)
  43:video.c       **** 		video.charMap[i] = LinearScale(charimg, SCALE_FACTOR);
 297              		.loc 1 43 0 discriminator 3
 298 0285 488B45F0 		movq	-16(%rbp), %rax
 299 0289 BE020000 		movl	$2, %esi
 299      00
 300 028e 4889C7   		movq	%rax, %rdi
 301 0291 E8000000 		call	LinearScale
 301      00
 302 0296 4889C2   		movq	%rax, %rdx
 303 0299 8B45FC   		movl	-4(%rbp), %eax
 304 029c 4898     		cltq
 305 029e 4883C002 		addq	$2, %rax
 306 02a2 488914C5 		movq	%rdx, video(,%rax,8)
 306      00000000 
  44:video.c       **** 		SDL_FreeSurface(charimg);
 307              		.loc 1 44 0 discriminator 3
 308 02aa 488B45F0 		movq	-16(%rbp), %rax
 309 02ae 4889C7   		movq	%rax, %rdi
 310 02b1 E8000000 		call	SDL_FreeSurface
 310      00
 311              	.LBE6:
  39:video.c       **** 		char buf[16];
 312              		.loc 1 39 0 discriminator 3
 313 02b6 8345FC01 		addl	$1, -4(%rbp)
 314              	.L15:
  39:video.c       **** 		char buf[16];
 315              		.loc 1 39 0 is_stmt 0 discriminator 1
 316 02ba 837DFC5E 		cmpl	$94, -4(%rbp)
 317 02be 7E8A     		jle	.L16
  45:video.c       **** 	}
  46:video.c       **** 	
  47:video.c       **** 	video.charMap[95] = video.charMap[0];
 318              		.loc 1 47 0 is_stmt 1
 319 02c0 488B0500 		movq	video+16(%rip), %rax
 319      000000
 320 02c7 48890500 		movq	%rax, video+776(%rip)
 320      000000
  48:video.c       **** }
 321              		.loc 1 48 0
 322 02ce 90       		nop
 323 02cf C9       		leave
 324              		.cfi_def_cfa 7, 8
 325 02d0 C3       		ret
 326              		.cfi_endproc
 327              	.LFE511:
 329              		.globl	map_color8to32
 331              	map_color8to32:
 332              	.LFB512:
  49:video.c       **** 
  50:video.c       **** SDL_Color map_color8to32(Uint8 color) {
 333              		.loc 1 50 0
 334              		.cfi_startproc
 335 02d1 55       		pushq	%rbp
 336              		.cfi_def_cfa_offset 16
 337              		.cfi_offset 6, -16
 338 02d2 4889E5   		movq	%rsp, %rbp
 339              		.cfi_def_cfa_register 6
 340 02d5 89F8     		movl	%edi, %eax
 341 02d7 8845EC   		movb	%al, -20(%rbp)
  51:video.c       **** 	SDL_Color new;
  52:video.c       **** 	new.r = (int)(((color & 0b11100000) >> 5) * 36.42857);
 342              		.loc 1 52 0
 343 02da 0FB645EC 		movzbl	-20(%rbp), %eax
 344 02de C0E805   		shrb	$5, %al
 345 02e1 0FB6C0   		movzbl	%al, %eax
 346 02e4 660FEFC0 		pxor	%xmm0, %xmm0
 347 02e8 F20F2AC0 		cvtsi2sd	%eax, %xmm0
 348 02ec F20F100D 		movsd	.LC3(%rip), %xmm1
 348      00000000 
 349 02f4 F20F59C1 		mulsd	%xmm1, %xmm0
 350 02f8 F20F2CC0 		cvttsd2si	%xmm0, %eax
 351 02fc 8845F0   		movb	%al, -16(%rbp)
  53:video.c       **** 	new.g = (int)(((color & 0b00011100) >> 2) * 36.42857);
 352              		.loc 1 53 0
 353 02ff 0FB645EC 		movzbl	-20(%rbp), %eax
 354 0303 C1F802   		sarl	$2, %eax
 355 0306 83E007   		andl	$7, %eax
 356 0309 660FEFC0 		pxor	%xmm0, %xmm0
 357 030d F20F2AC0 		cvtsi2sd	%eax, %xmm0
 358 0311 F20F100D 		movsd	.LC3(%rip), %xmm1
 358      00000000 
 359 0319 F20F59C1 		mulsd	%xmm1, %xmm0
 360 031d F20F2CC0 		cvttsd2si	%xmm0, %eax
 361 0321 8845F1   		movb	%al, -15(%rbp)
  54:video.c       **** 	new.b = (int)((color & 0b00000011) * 85.0);
 362              		.loc 1 54 0
 363 0324 0FB645EC 		movzbl	-20(%rbp), %eax
 364 0328 83E003   		andl	$3, %eax
 365 032b 660FEFC0 		pxor	%xmm0, %xmm0
 366 032f F20F2AC0 		cvtsi2sd	%eax, %xmm0
 367 0333 F20F100D 		movsd	.LC4(%rip), %xmm1
 367      00000000 
 368 033b F20F59C1 		mulsd	%xmm1, %xmm0
 369 033f F20F2CC0 		cvttsd2si	%xmm0, %eax
 370 0343 8845F2   		movb	%al, -14(%rbp)
  55:video.c       **** 	return new;
 371              		.loc 1 55 0
 372 0346 8B45F0   		movl	-16(%rbp), %eax
  56:video.c       **** }
 373              		.loc 1 56 0
 374 0349 5D       		popq	%rbp
 375              		.cfi_def_cfa 7, 8
 376 034a C3       		ret
 377              		.cfi_endproc
 378              	.LFE512:
 380              		.globl	map_color2to32
 382              	map_color2to32:
 383              	.LFB513:
  57:video.c       **** 
  58:video.c       **** SDL_Color map_color2to32(Uint8 color) {
 384              		.loc 1 58 0
 385              		.cfi_startproc
 386 034b 55       		pushq	%rbp
 387              		.cfi_def_cfa_offset 16
 388              		.cfi_offset 6, -16
 389 034c 4889E5   		movq	%rsp, %rbp
 390              		.cfi_def_cfa_register 6
 391 034f 4883EC18 		subq	$24, %rsp
 392 0353 89F8     		movl	%edi, %eax
 393 0355 8845EC   		movb	%al, -20(%rbp)
  59:video.c       **** 	Uint8 map[] = {0xFF,0xAA,0x55,0x00};
 394              		.loc 1 59 0
 395 0358 C645F0FF 		movb	$-1, -16(%rbp)
 396 035c C645F1AA 		movb	$-86, -15(%rbp)
 397 0360 C645F255 		movb	$85, -14(%rbp)
 398 0364 C645F300 		movb	$0, -13(%rbp)
  60:video.c       **** 	return map_color8to32(map[color & 0b11]);
 399              		.loc 1 60 0
 400 0368 0FB645EC 		movzbl	-20(%rbp), %eax
 401 036c 83E003   		andl	$3, %eax
 402 036f 4898     		cltq
 403 0371 0FB64405 		movzbl	-16(%rbp,%rax), %eax
 403      F0
 404 0376 0FB6C0   		movzbl	%al, %eax
 405 0379 89C7     		movl	%eax, %edi
 406 037b E8000000 		call	map_color8to32
 406      00
  61:video.c       **** }
 407              		.loc 1 61 0
 408 0380 C9       		leave
 409              		.cfi_def_cfa 7, 8
 410 0381 C3       		ret
 411              		.cfi_endproc
 412              	.LFE513:
 414              		.globl	updateScreen
 416              	updateScreen:
 417              	.LFB514:
  62:video.c       **** 
  63:video.c       **** void updateScreen() {
 418              		.loc 1 63 0
 419              		.cfi_startproc
 420 0382 55       		pushq	%rbp
 421              		.cfi_def_cfa_offset 16
 422              		.cfi_offset 6, -16
 423 0383 4889E5   		movq	%rsp, %rbp
 424              		.cfi_def_cfa_register 6
 425 0386 4883C480 		addq	$-128, %rsp
  64:video.c       ****     
  65:video.c       ****     if (video.displayMode == LOW_RES) {
 426              		.loc 1 65 0
 427 038a 0FB60500 		movzbl	video+801(%rip), %eax
 427      000000
 428 0391 3C01     		cmpb	$1, %al
 429 0393 0F850301 		jne	.L22
 429      0000
 430              	.LBB7:
  66:video.c       **** 	    int y, x, o_y, o_x;
  67:video.c       **** 	    int scale = SCALE_FACTOR * 2;
 431              		.loc 1 67 0
 432 0399 C745D004 		movl	$4, -48(%rbp)
 432      000000
  68:video.c       **** 	    for (x=0; x<LORES_WIDTH; x++) {
 433              		.loc 1 68 0
 434 03a0 C745F800 		movl	$0, -8(%rbp)
 434      000000
 435 03a7 E9DE0000 		jmp	.L23
 435      00
 436              	.L30:
  69:video.c       **** 			for (y=0; y<LORES_HEIGHT; y++) {
 437              		.loc 1 69 0
 438 03ac C745FC00 		movl	$0, -4(%rbp)
 438      000000
 439 03b3 E9C40000 		jmp	.L24
 439      00
 440              	.L29:
 441              	.LBB8:
  70:video.c       **** 				Uint8 *newpixel = video.pixelBuffer + x + (y*LORES_WIDTH);
 442              		.loc 1 70 0
 443 03b8 488B0500 		movq	video+784(%rip), %rax
 443      000000
 444 03bf 8B55F8   		movl	-8(%rbp), %edx
 445 03c2 4863CA   		movslq	%edx, %rcx
 446 03c5 8B55FC   		movl	-4(%rbp), %edx
 447 03c8 69D2B400 		imull	$180, %edx, %edx
 447      0000
 448 03ce 4863D2   		movslq	%edx, %rdx
 449 03d1 4801CA   		addq	%rcx, %rdx
 450 03d4 4801D0   		addq	%rdx, %rax
 451 03d7 488945C8 		movq	%rax, -56(%rbp)
  71:video.c       **** 				SDL_Color c = map_color8to32(*newpixel);
 452              		.loc 1 71 0
 453 03db 488B45C8 		movq	-56(%rbp), %rax
 454 03df 0FB600   		movzbl	(%rax), %eax
 455 03e2 0FB6C0   		movzbl	%al, %eax
 456 03e5 89C7     		movl	%eax, %edi
 457 03e7 E8000000 		call	map_color8to32
 457      00
 458 03ec 8945A0   		movl	%eax, -96(%rbp)
  72:video.c       **** 				Uint32 pixcol = SDL_MapRGB(video.screen->format, c.r, c.g, c.b);
 459              		.loc 1 72 0
 460 03ef 0FB645A2 		movzbl	-94(%rbp), %eax
 461 03f3 0FB6C8   		movzbl	%al, %ecx
 462 03f6 0FB645A1 		movzbl	-95(%rbp), %eax
 463 03fa 0FB6D0   		movzbl	%al, %edx
 464 03fd 0FB645A0 		movzbl	-96(%rbp), %eax
 465 0401 0FB6F0   		movzbl	%al, %esi
 466 0404 488B0500 		movq	video+8(%rip), %rax
 466      000000
 467 040b 488B4008 		movq	8(%rax), %rax
 468 040f 4889C7   		movq	%rax, %rdi
 469 0412 E8000000 		call	SDL_MapRGB
 469      00
 470 0417 8945C4   		movl	%eax, -60(%rbp)
  73:video.c       **** 				for (o_y=0; o_y<scale; o_y++) {
 471              		.loc 1 73 0
 472 041a C745F400 		movl	$0, -12(%rbp)
 472      000000
 473 0421 EB4D     		jmp	.L25
 474              	.L28:
  74:video.c       **** 					for (o_x=0; o_x<scale; o_x++) {
 475              		.loc 1 74 0
 476 0423 C745F000 		movl	$0, -16(%rbp)
 476      000000
 477 042a EB38     		jmp	.L26
 478              	.L27:
  75:video.c       **** 						DrawPixel(video.screen, x*scale + o_x, y*scale + o_y, pixcol);
 479              		.loc 1 75 0 discriminator 3
 480 042c 8B45FC   		movl	-4(%rbp), %eax
 481 042f 0FAF45D0 		imull	-48(%rbp), %eax
 482 0433 89C2     		movl	%eax, %edx
 483 0435 8B45F4   		movl	-12(%rbp), %eax
 484 0438 8D3C02   		leal	(%rdx,%rax), %edi
 485 043b 8B45F8   		movl	-8(%rbp), %eax
 486 043e 0FAF45D0 		imull	-48(%rbp), %eax
 487 0442 89C2     		movl	%eax, %edx
 488 0444 8B45F0   		movl	-16(%rbp), %eax
 489 0447 8D3402   		leal	(%rdx,%rax), %esi
 490 044a 488B0500 		movq	video+8(%rip), %rax
 490      000000
 491 0451 8B55C4   		movl	-60(%rbp), %edx
 492 0454 89D1     		movl	%edx, %ecx
 493 0456 89FA     		movl	%edi, %edx
 494 0458 4889C7   		movq	%rax, %rdi
 495 045b E8000000 		call	DrawPixel
 495      00
  74:video.c       **** 					for (o_x=0; o_x<scale; o_x++) {
 496              		.loc 1 74 0 discriminator 3
 497 0460 8345F001 		addl	$1, -16(%rbp)
 498              	.L26:
  74:video.c       **** 					for (o_x=0; o_x<scale; o_x++) {
 499              		.loc 1 74 0 is_stmt 0 discriminator 1
 500 0464 8B45F0   		movl	-16(%rbp), %eax
 501 0467 3B45D0   		cmpl	-48(%rbp), %eax
 502 046a 7CC0     		jl	.L27
  73:video.c       **** 				for (o_y=0; o_y<scale; o_y++) {
 503              		.loc 1 73 0 is_stmt 1 discriminator 2
 504 046c 8345F401 		addl	$1, -12(%rbp)
 505              	.L25:
  73:video.c       **** 				for (o_y=0; o_y<scale; o_y++) {
 506              		.loc 1 73 0 is_stmt 0 discriminator 1
 507 0470 8B45F4   		movl	-12(%rbp), %eax
 508 0473 3B45D0   		cmpl	-48(%rbp), %eax
 509 0476 7CAB     		jl	.L28
 510              	.LBE8:
  69:video.c       **** 				Uint8 *newpixel = video.pixelBuffer + x + (y*LORES_WIDTH);
 511              		.loc 1 69 0 is_stmt 1 discriminator 2
 512 0478 8345FC01 		addl	$1, -4(%rbp)
 513              	.L24:
  69:video.c       **** 				Uint8 *newpixel = video.pixelBuffer + x + (y*LORES_WIDTH);
 514              		.loc 1 69 0 is_stmt 0 discriminator 1
 515 047c 837DFC6F 		cmpl	$111, -4(%rbp)
 516 0480 0F8E32FF 		jle	.L29
 516      FFFF
  68:video.c       **** 			for (y=0; y<LORES_HEIGHT; y++) {
 517              		.loc 1 68 0 is_stmt 1 discriminator 2
 518 0486 8345F801 		addl	$1, -8(%rbp)
 519              	.L23:
  68:video.c       **** 			for (y=0; y<LORES_HEIGHT; y++) {
 520              		.loc 1 68 0 is_stmt 0 discriminator 1
 521 048a 817DF8B3 		cmpl	$179, -8(%rbp)
 521      000000
 522 0491 0F8E15FF 		jle	.L30
 522      FFFF
 523              	.LBE7:
  76:video.c       **** 					}
  77:video.c       **** 				}
  78:video.c       **** 			}
  79:video.c       **** 		}
  80:video.c       ****     } else if (video.displayMode == HIGH_RES) {
  81:video.c       **** 		int y, x, o_y, o_x, bi;
  82:video.c       **** 	    for (x=0; x<HIRES_WIDTH; x++) {
  83:video.c       **** 			for (y=0; y<HIRES_HEIGHT; y++) {
  84:video.c       **** 				Uint8 newpixel = * (Uint8 *)(video.pixelBuffer + x + (y*HIRES_WIDTH/4));
  85:video.c       **** 				for (bi=0; bi<4; bi++) {
  86:video.c       **** 					Uint8 id;
  87:video.c       **** 					id = (newpixel & (0x3 << (bi*2))) >> (bi*2);
  88:video.c       **** 					SDL_Color c = map_color2to32(id);
  89:video.c       **** 					Uint32 pixcol = SDL_MapRGB(video.screen->format, c.r, c.g, c.b);
  90:video.c       **** 					for (o_x=0; o_x<SCALE_FACTOR; o_x++) {
  91:video.c       **** 						for (o_y=0; o_y<SCALE_FACTOR; o_y++) {
  92:video.c       **** 							DrawPixel(video.screen, x*SCALE_FACTOR + o_x, y*SCALE_FACTOR + o_y, pixcol);
  93:video.c       **** 						}
  94:video.c       **** 					}
  95:video.c       **** 				}
  96:video.c       **** 			}
  97:video.c       **** 		}
  98:video.c       **** 	} else if (video.displayMode == TEXT_MODE) {
  99:video.c       **** 		int i,j, o;
 100:video.c       **** 		SDL_Rect dest;
 101:video.c       **** 		dest.y = 0;
 102:video.c       **** 		for (i=0;i<SCREEN_CHAR_H;i++){
 103:video.c       **** 			o = i*SCREEN_CHAR_W;
 104:video.c       **** 			dest.x = 0;
 105:video.c       **** 			for (j=0;j<SCREEN_CHAR_W;j++) {
 106:video.c       **** 				SDL_Surface *image = video.charMap[(int)video.charBuffer[o+j]];
 107:video.c       **** 				SDL_BlitSurface(image, NULL, video.screen, &dest);
 108:video.c       **** 				dest.x += CHAR_WIDTH*SCALE_FACTOR;
 109:video.c       **** 			}
 110:video.c       **** 			dest.y += CHAR_HEIGHT*SCALE_FACTOR;
 111:video.c       **** 		}
 112:video.c       **** 	}
 113:video.c       **** }     
 524              		.loc 1 113 0 is_stmt 1
 525 0497 E9F50100 		jmp	.L47
 525      00
 526              	.L22:
  80:video.c       **** 		int y, x, o_y, o_x, bi;
 527              		.loc 1 80 0
 528 049c 0FB60500 		movzbl	video+801(%rip), %eax
 528      000000
 529 04a3 84C0     		testb	%al, %al
 530 04a5 0F853901 		jne	.L32
 530      0000
 531              	.LBB9:
  82:video.c       **** 			for (y=0; y<HIRES_HEIGHT; y++) {
 532              		.loc 1 82 0
 533 04ab C745E800 		movl	$0, -24(%rbp)
 533      000000
 534 04b2 E91B0100 		jmp	.L33
 534      00
 535              	.L42:
  83:video.c       **** 				Uint8 newpixel = * (Uint8 *)(video.pixelBuffer + x + (y*HIRES_WIDTH/4));
 536              		.loc 1 83 0
 537 04b7 C745EC00 		movl	$0, -20(%rbp)
 537      000000
 538 04be E9FE0000 		jmp	.L34
 538      00
 539              	.L41:
 540              	.LBB10:
  84:video.c       **** 				for (bi=0; bi<4; bi++) {
 541              		.loc 1 84 0
 542 04c3 488B1500 		movq	video+784(%rip), %rdx
 542      000000
 543 04ca 8B45E8   		movl	-24(%rbp), %eax
 544 04cd 4863C8   		movslq	%eax, %rcx
 545 04d0 8B45EC   		movl	-20(%rbp), %eax
 546 04d3 69C06801 		imull	$360, %eax, %eax
 546      0000
 547 04d9 8D7003   		leal	3(%rax), %esi
 548 04dc 85C0     		testl	%eax, %eax
 549 04de 0F48C6   		cmovs	%esi, %eax
 550 04e1 C1F802   		sarl	$2, %eax
 551 04e4 4898     		cltq
 552 04e6 4801C8   		addq	%rcx, %rax
 553 04e9 4801D0   		addq	%rdx, %rax
 554 04ec 0FB600   		movzbl	(%rax), %eax
 555 04ef 8845C3   		movb	%al, -61(%rbp)
  85:video.c       **** 					Uint8 id;
 556              		.loc 1 85 0
 557 04f2 C745DC00 		movl	$0, -36(%rbp)
 557      000000
 558 04f9 E9B50000 		jmp	.L35
 558      00
 559              	.L40:
 560              	.LBB11:
  87:video.c       **** 					SDL_Color c = map_color2to32(id);
 561              		.loc 1 87 0
 562 04fe 0FB645C3 		movzbl	-61(%rbp), %eax
 563 0502 8B55DC   		movl	-36(%rbp), %edx
 564 0505 01D2     		addl	%edx, %edx
 565 0507 BE030000 		movl	$3, %esi
 565      00
 566 050c 89D1     		movl	%edx, %ecx
 567 050e D3E6     		sall	%cl, %esi
 568 0510 89F2     		movl	%esi, %edx
 569 0512 21C2     		andl	%eax, %edx
 570 0514 8B45DC   		movl	-36(%rbp), %eax
 571 0517 01C0     		addl	%eax, %eax
 572 0519 89C1     		movl	%eax, %ecx
 573 051b D3FA     		sarl	%cl, %edx
 574 051d 89D0     		movl	%edx, %eax
 575 051f 8845C2   		movb	%al, -62(%rbp)
  88:video.c       **** 					Uint32 pixcol = SDL_MapRGB(video.screen->format, c.r, c.g, c.b);
 576              		.loc 1 88 0
 577 0522 0FB645C2 		movzbl	-62(%rbp), %eax
 578 0526 89C7     		movl	%eax, %edi
 579 0528 E8000000 		call	map_color2to32
 579      00
 580 052d 894590   		movl	%eax, -112(%rbp)
  89:video.c       **** 					for (o_x=0; o_x<SCALE_FACTOR; o_x++) {
 581              		.loc 1 89 0
 582 0530 0FB64592 		movzbl	-110(%rbp), %eax
 583 0534 0FB6C8   		movzbl	%al, %ecx
 584 0537 0FB64591 		movzbl	-111(%rbp), %eax
 585 053b 0FB6D0   		movzbl	%al, %edx
 586 053e 0FB64590 		movzbl	-112(%rbp), %eax
 587 0542 0FB6F0   		movzbl	%al, %esi
 588 0545 488B0500 		movq	video+8(%rip), %rax
 588      000000
 589 054c 488B4008 		movq	8(%rax), %rax
 590 0550 4889C7   		movq	%rax, %rdi
 591 0553 E8000000 		call	SDL_MapRGB
 591      00
 592 0558 8945BC   		movl	%eax, -68(%rbp)
  90:video.c       **** 						for (o_y=0; o_y<SCALE_FACTOR; o_y++) {
 593              		.loc 1 90 0
 594 055b C745E000 		movl	$0, -32(%rbp)
 594      000000
 595 0562 EB45     		jmp	.L36
 596              	.L39:
  91:video.c       **** 							DrawPixel(video.screen, x*SCALE_FACTOR + o_x, y*SCALE_FACTOR + o_y, pixcol);
 597              		.loc 1 91 0
 598 0564 C745E400 		movl	$0, -28(%rbp)
 598      000000
 599 056b EB32     		jmp	.L37
 600              	.L38:
  92:video.c       **** 						}
 601              		.loc 1 92 0 discriminator 3
 602 056d 8B45EC   		movl	-20(%rbp), %eax
 603 0570 8D1400   		leal	(%rax,%rax), %edx
 604 0573 8B45E4   		movl	-28(%rbp), %eax
 605 0576 8D3C02   		leal	(%rdx,%rax), %edi
 606 0579 8B45E8   		movl	-24(%rbp), %eax
 607 057c 8D1400   		leal	(%rax,%rax), %edx
 608 057f 8B45E0   		movl	-32(%rbp), %eax
 609 0582 8D3402   		leal	(%rdx,%rax), %esi
 610 0585 488B0500 		movq	video+8(%rip), %rax
 610      000000
 611 058c 8B55BC   		movl	-68(%rbp), %edx
 612 058f 89D1     		movl	%edx, %ecx
 613 0591 89FA     		movl	%edi, %edx
 614 0593 4889C7   		movq	%rax, %rdi
 615 0596 E8000000 		call	DrawPixel
 615      00
  91:video.c       **** 							DrawPixel(video.screen, x*SCALE_FACTOR + o_x, y*SCALE_FACTOR + o_y, pixcol);
 616              		.loc 1 91 0 discriminator 3
 617 059b 8345E401 		addl	$1, -28(%rbp)
 618              	.L37:
  91:video.c       **** 							DrawPixel(video.screen, x*SCALE_FACTOR + o_x, y*SCALE_FACTOR + o_y, pixcol);
 619              		.loc 1 91 0 is_stmt 0 discriminator 1
 620 059f 837DE401 		cmpl	$1, -28(%rbp)
 621 05a3 7EC8     		jle	.L38
  90:video.c       **** 						for (o_y=0; o_y<SCALE_FACTOR; o_y++) {
 622              		.loc 1 90 0 is_stmt 1 discriminator 2
 623 05a5 8345E001 		addl	$1, -32(%rbp)
 624              	.L36:
  90:video.c       **** 						for (o_y=0; o_y<SCALE_FACTOR; o_y++) {
 625              		.loc 1 90 0 is_stmt 0 discriminator 1
 626 05a9 837DE001 		cmpl	$1, -32(%rbp)
 627 05ad 7EB5     		jle	.L39
 628              	.LBE11:
  85:video.c       **** 					Uint8 id;
 629              		.loc 1 85 0 is_stmt 1 discriminator 2
 630 05af 8345DC01 		addl	$1, -36(%rbp)
 631              	.L35:
  85:video.c       **** 					Uint8 id;
 632              		.loc 1 85 0 is_stmt 0 discriminator 1
 633 05b3 837DDC03 		cmpl	$3, -36(%rbp)
 634 05b7 0F8E41FF 		jle	.L40
 634      FFFF
 635              	.LBE10:
  83:video.c       **** 				Uint8 newpixel = * (Uint8 *)(video.pixelBuffer + x + (y*HIRES_WIDTH/4));
 636              		.loc 1 83 0 is_stmt 1 discriminator 2
 637 05bd 8345EC01 		addl	$1, -20(%rbp)
 638              	.L34:
  83:video.c       **** 				Uint8 newpixel = * (Uint8 *)(video.pixelBuffer + x + (y*HIRES_WIDTH/4));
 639              		.loc 1 83 0 is_stmt 0 discriminator 1
 640 05c1 817DECDF 		cmpl	$223, -20(%rbp)
 640      000000
 641 05c8 0F8EF5FE 		jle	.L41
 641      FFFF
  82:video.c       **** 			for (y=0; y<HIRES_HEIGHT; y++) {
 642              		.loc 1 82 0 is_stmt 1 discriminator 2
 643 05ce 8345E801 		addl	$1, -24(%rbp)
 644              	.L33:
  82:video.c       **** 			for (y=0; y<HIRES_HEIGHT; y++) {
 645              		.loc 1 82 0 is_stmt 0 discriminator 1
 646 05d2 817DE867 		cmpl	$359, -24(%rbp)
 646      010000
 647 05d9 0F8ED8FE 		jle	.L42
 647      FFFF
 648              	.LBE9:
 649              		.loc 1 113 0 is_stmt 1
 650 05df E9AD0000 		jmp	.L47
 650      00
 651              	.L32:
  98:video.c       **** 		int i,j, o;
 652              		.loc 1 98 0
 653 05e4 0FB60500 		movzbl	video+801(%rip), %eax
 653      000000
 654 05eb 3C02     		cmpb	$2, %al
 655 05ed 0F859E00 		jne	.L47
 655      0000
 656              	.LBB12:
 101:video.c       **** 		for (i=0;i<SCREEN_CHAR_H;i++){
 657              		.loc 1 101 0
 658 05f3 C7458400 		movl	$0, -124(%rbp)
 658      000000
 102:video.c       **** 			o = i*SCREEN_CHAR_W;
 659              		.loc 1 102 0
 660 05fa C745D800 		movl	$0, -40(%rbp)
 660      000000
 661 0601 E9810000 		jmp	.L43
 661      00
 662              	.L46:
 103:video.c       **** 			dest.x = 0;
 663              		.loc 1 103 0
 664 0606 8B45D8   		movl	-40(%rbp), %eax
 665 0609 6BC03C   		imull	$60, %eax, %eax
 666 060c 8945B8   		movl	%eax, -72(%rbp)
 104:video.c       **** 			for (j=0;j<SCREEN_CHAR_W;j++) {
 667              		.loc 1 104 0
 668 060f C7458000 		movl	$0, -128(%rbp)
 668      000000
 105:video.c       **** 				SDL_Surface *image = video.charMap[(int)video.charBuffer[o+j]];
 669              		.loc 1 105 0
 670 0616 C745D400 		movl	$0, -44(%rbp)
 670      000000
 671 061d EB55     		jmp	.L44
 672              	.L45:
 673              	.LBB13:
 106:video.c       **** 				SDL_BlitSurface(image, NULL, video.screen, &dest);
 674              		.loc 1 106 0 discriminator 3
 675 061f 488B1500 		movq	video+792(%rip), %rdx
 675      000000
 676 0626 8B4DB8   		movl	-72(%rbp), %ecx
 677 0629 8B45D4   		movl	-44(%rbp), %eax
 678 062c 01C8     		addl	%ecx, %eax
 679 062e 4898     		cltq
 680 0630 4801D0   		addq	%rdx, %rax
 681 0633 0FB600   		movzbl	(%rax), %eax
 682 0636 0FB6C0   		movzbl	%al, %eax
 683 0639 4898     		cltq
 684 063b 4883C002 		addq	$2, %rax
 685 063f 488B04C5 		movq	video(,%rax,8), %rax
 685      00000000 
 686 0647 488945B0 		movq	%rax, -80(%rbp)
 107:video.c       **** 				dest.x += CHAR_WIDTH*SCALE_FACTOR;
 687              		.loc 1 107 0 discriminator 3
 688 064b 488B1500 		movq	video+8(%rip), %rdx
 688      000000
 689 0652 488D4D80 		leaq	-128(%rbp), %rcx
 690 0656 488B45B0 		movq	-80(%rbp), %rax
 691 065a BE000000 		movl	$0, %esi
 691      00
 692 065f 4889C7   		movq	%rax, %rdi
 693 0662 E8000000 		call	SDL_UpperBlit
 693      00
 108:video.c       **** 			}
 694              		.loc 1 108 0 discriminator 3
 695 0667 8B4580   		movl	-128(%rbp), %eax
 696 066a 83C00C   		addl	$12, %eax
 697 066d 894580   		movl	%eax, -128(%rbp)
 698              	.LBE13:
 105:video.c       **** 				SDL_Surface *image = video.charMap[(int)video.charBuffer[o+j]];
 699              		.loc 1 105 0 discriminator 3
 700 0670 8345D401 		addl	$1, -44(%rbp)
 701              	.L44:
 105:video.c       **** 				SDL_Surface *image = video.charMap[(int)video.charBuffer[o+j]];
 702              		.loc 1 105 0 is_stmt 0 discriminator 1
 703 0674 837DD43B 		cmpl	$59, -44(%rbp)
 704 0678 7EA5     		jle	.L45
 110:video.c       **** 		}
 705              		.loc 1 110 0 is_stmt 1 discriminator 2
 706 067a 8B4584   		movl	-124(%rbp), %eax
 707 067d 83C010   		addl	$16, %eax
 708 0680 894584   		movl	%eax, -124(%rbp)
 102:video.c       **** 			o = i*SCREEN_CHAR_W;
 709              		.loc 1 102 0 discriminator 2
 710 0683 8345D801 		addl	$1, -40(%rbp)
 711              	.L43:
 102:video.c       **** 			o = i*SCREEN_CHAR_W;
 712              		.loc 1 102 0 is_stmt 0 discriminator 1
 713 0687 837DD81B 		cmpl	$27, -40(%rbp)
 714 068b 0F8E75FF 		jle	.L46
 714      FFFF
 715              	.L47:
 716              	.LBE12:
 717              		.loc 1 113 0 is_stmt 1
 718 0691 90       		nop
 719 0692 C9       		leave
 720              		.cfi_def_cfa 7, 8
 721 0693 C3       		ret
 722              		.cfi_endproc
 723              	.LFE514:
 725              		.globl	serviceDisplay
 727              	serviceDisplay:
 728              	.LFB515:
 114:video.c       **** 
 115:video.c       **** void serviceDisplay() {
 729              		.loc 1 115 0
 730              		.cfi_startproc
 731 0694 55       		pushq	%rbp
 732              		.cfi_def_cfa_offset 16
 733              		.cfi_offset 6, -16
 734 0695 4889E5   		movq	%rsp, %rbp
 735              		.cfi_def_cfa_register 6
 116:video.c       **** 	if (video.dirtyBuffer) {
 736              		.loc 1 116 0
 737 0698 8B050000 		movl	video+808(%rip), %eax
 737      0000
 738 069e 85C0     		testl	%eax, %eax
 739 06a0 7423     		je	.L50
 117:video.c       **** 			video.dirtyBuffer = 0;
 740              		.loc 1 117 0
 741 06a2 C7050000 		movl	$0, video+808(%rip)
 741      00000000 
 741      0000
 118:video.c       **** 			updateScreen();
 742              		.loc 1 118 0
 743 06ac B8000000 		movl	$0, %eax
 743      00
 744 06b1 E8000000 		call	updateScreen
 744      00
 119:video.c       **** 			SDL_UpdateWindowSurface(video.window);
 745              		.loc 1 119 0
 746 06b6 488B0500 		movq	video(%rip), %rax
 746      000000
 747 06bd 4889C7   		movq	%rax, %rdi
 748 06c0 E8000000 		call	SDL_UpdateWindowSurface
 748      00
 749              	.L50:
 120:video.c       **** 	    }
 121:video.c       **** }       
 750              		.loc 1 121 0
 751 06c5 90       		nop
 752 06c6 5D       		popq	%rbp
 753              		.cfi_def_cfa 7, 8
 754 06c7 C3       		ret
 755              		.cfi_endproc
 756              	.LFE515:
 758              		.section	.rodata
 759 001f 00       		.align 8
 760              	.LC3:
 761 0020 FB05BB61 		.long	1639646715
 762 0024 DB364240 		.long	1078081243
 763              		.align 8
 764              	.LC4:
 765 0028 00000000 		.long	0
 766 002c 00405540 		.long	1079328768
 767              		.text
 768              	.Letext0:
 769              		.file 2 "/usr/lib/gcc/x86_64-pc-linux-gnu/6.3.1/include/stddef.h"
 770              		.file 3 "/usr/include/bits/types.h"
 771              		.file 4 "/usr/include/libio.h"
 772              		.file 5 "/usr/include/stdio.h"
 773              		.file 6 "/usr/include/bits/sys_errlist.h"
 774              		.file 7 "/usr/include/sys/types.h"
 775              		.file 8 "/usr/include/stdint.h"
 776              		.file 9 "/usr/include/math.h"
 777              		.file 10 "/usr/include/SDL2/SDL_stdinc.h"
 778              		.file 11 "/usr/include/SDL2/SDL_pixels.h"
 779              		.file 12 "/usr/include/SDL2/SDL_rect.h"
 780              		.file 13 "/usr/include/SDL2/SDL_surface.h"
 781              		.file 14 "/usr/include/SDL2/SDL_video.h"
 782              		.file 15 "/usr/include/SDL2/SDL_scancode.h"
 783              		.file 16 "/usr/include/SDL2/SDL_messagebox.h"
 784              		.file 17 "video.h"
 785              		.file 18 "/usr/include/time.h"
 786              		.file 19 "../I8080/I8080.h"
   1              		.file	"ioports.c"
   2              		.text
   3              	.Ltext0:
   4              		.local	hold
   5              		.comm	hold,4,4
   6              		.comm	video,816,32
   7              		.comm	keyboardbuffer,8,8
   8              		.comm	keyindex,1,1
   9              		.comm	processed,1,1
  10              		.globl	port01_display_mode
  12              	port01_display_mode:
  13              	.LFB508:
  14              		.file 1 "ioports.c"
   1:ioports.c     **** #include "ioports.h"
   2:ioports.c     **** 
   3:ioports.c     **** void port01_display_mode(I8080 *cpu) {
  15              		.loc 1 3 0
  16              		.cfi_startproc
  17 0000 55       		pushq	%rbp
  18              		.cfi_def_cfa_offset 16
  19              		.cfi_offset 6, -16
  20 0001 4889E5   		movq	%rsp, %rbp
  21              		.cfi_def_cfa_register 6
  22 0004 4883EC10 		subq	$16, %rsp
  23 0008 48897DF8 		movq	%rdi, -8(%rbp)
   4:ioports.c     **** 	if (isOutput(cpu)) {
  24              		.loc 1 4 0
  25 000c 488B45F8 		movq	-8(%rbp), %rax
  26 0010 4889C7   		movq	%rax, %rdi
  27 0013 E8000000 		call	getIOState
  27      00
  28 0018 85C0     		testl	%eax, %eax
  29 001a 741E     		je	.L2
   5:ioports.c     **** 		video.dirtyBuffer = 1;
  30              		.loc 1 5 0
  31 001c C7050000 		movl	$1, video+808(%rip)
  31      00000100 
  31      0000
   6:ioports.c     **** 		video.displayMode = getAccumulator(cpu);
  32              		.loc 1 6 0
  33 0026 488B45F8 		movq	-8(%rbp), %rax
  34 002a 4889C7   		movq	%rax, %rdi
  35 002d E8000000 		call	getAccumulator
  35      00
  36 0032 88050000 		movb	%al, video+801(%rip)
  36      0000
   7:ioports.c     **** 	} else {
   8:ioports.c     **** 		setAccumulator(cpu, video.displayMode);
   9:ioports.c     **** 	}
  10:ioports.c     **** }
  37              		.loc 1 10 0
  38 0038 EB18     		jmp	.L4
  39              	.L2:
   8:ioports.c     **** 	}
  40              		.loc 1 8 0
  41 003a 0FB60500 		movzbl	video+801(%rip), %eax
  41      000000
  42 0041 0FB6D0   		movzbl	%al, %edx
  43 0044 488B45F8 		movq	-8(%rbp), %rax
  44 0048 89D6     		movl	%edx, %esi
  45 004a 4889C7   		movq	%rax, %rdi
  46 004d E8000000 		call	setAccumulator
  46      00
  47              	.L4:
  48              		.loc 1 10 0
  49 0052 90       		nop
  50 0053 C9       		leave
  51              		.cfi_def_cfa 7, 8
  52 0054 C3       		ret
  53              		.cfi_endproc
  54              	.LFE508:
  56              		.globl	port02_operation
  58              	port02_operation:
  59              	.LFB509:
  11:ioports.c     **** 
  12:ioports.c     **** void port02_operation(I8080 *cpu) {
  60              		.loc 1 12 0
  61              		.cfi_startproc
  62 0055 55       		pushq	%rbp
  63              		.cfi_def_cfa_offset 16
  64              		.cfi_offset 6, -16
  65 0056 4889E5   		movq	%rsp, %rbp
  66              		.cfi_def_cfa_register 6
  67 0059 4883EC10 		subq	$16, %rsp
  68 005d 48897DF8 		movq	%rdi, -8(%rbp)
  13:ioports.c     **** 	if (isOutput(cpu)) {
  69              		.loc 1 13 0
  70 0061 488B45F8 		movq	-8(%rbp), %rax
  71 0065 4889C7   		movq	%rax, %rdi
  72 0068 E8000000 		call	getIOState
  72      00
  73 006d 85C0     		testl	%eax, %eax
  74 006f 7414     		je	.L6
  14:ioports.c     **** 		video.textOperation = getAccumulator(cpu);
  75              		.loc 1 14 0
  76 0071 488B45F8 		movq	-8(%rbp), %rax
  77 0075 4889C7   		movq	%rax, %rdi
  78 0078 E8000000 		call	getAccumulator
  78      00
  79 007d 88050000 		movb	%al, video+800(%rip)
  79      0000
  15:ioports.c     **** 	} else {
  16:ioports.c     **** 		setAccumulator(cpu, video.textOperation);
  17:ioports.c     **** 	}
  18:ioports.c     **** }
  80              		.loc 1 18 0
  81 0083 EB18     		jmp	.L8
  82              	.L6:
  16:ioports.c     **** 	}
  83              		.loc 1 16 0
  84 0085 0FB60500 		movzbl	video+800(%rip), %eax
  84      000000
  85 008c 0FB6D0   		movzbl	%al, %edx
  86 008f 488B45F8 		movq	-8(%rbp), %rax
  87 0093 89D6     		movl	%edx, %esi
  88 0095 4889C7   		movq	%rax, %rdi
  89 0098 E8000000 		call	setAccumulator
  89      00
  90              	.L8:
  91              		.loc 1 18 0
  92 009d 90       		nop
  93 009e C9       		leave
  94              		.cfi_def_cfa 7, 8
  95 009f C3       		ret
  96              		.cfi_endproc
  97              	.LFE509:
  99              		.globl	port03_charin
 101              	port03_charin:
 102              	.LFB510:
  19:ioports.c     **** 
  20:ioports.c     **** void port03_charin(I8080 *cpu) {
 103              		.loc 1 20 0
 104              		.cfi_startproc
 105 00a0 55       		pushq	%rbp
 106              		.cfi_def_cfa_offset 16
 107              		.cfi_offset 6, -16
 108 00a1 4889E5   		movq	%rsp, %rbp
 109              		.cfi_def_cfa_register 6
 110 00a4 53       		pushq	%rbx
 111 00a5 4883EC28 		subq	$40, %rsp
 112              		.cfi_offset 3, -24
 113 00a9 48897DD8 		movq	%rdi, -40(%rbp)
  21:ioports.c     **** 	video.dirtyBuffer = 1;
 114              		.loc 1 21 0
 115 00ad C7050000 		movl	$1, video+808(%rip)
 115      00000100 
 115      0000
  22:ioports.c     **** 	if (isOutput(cpu) && (video.textOperation == APPEND_CHAR)) {
 116              		.loc 1 22 0
 117 00b7 488B45D8 		movq	-40(%rbp), %rax
 118 00bb 4889C7   		movq	%rax, %rdi
 119 00be E8000000 		call	getIOState
 119      00
 120 00c3 85C0     		testl	%eax, %eax
 121 00c5 7440     		je	.L10
 122              		.loc 1 22 0 is_stmt 0 discriminator 1
 123 00c7 0FB60500 		movzbl	video+800(%rip), %eax
 123      000000
 124 00ce 3C01     		cmpb	$1, %al
 125 00d0 7535     		jne	.L10
  23:ioports.c     **** 		
  24:ioports.c     **** 		video.charBuffer[video.cursorIndex++] = (getAccumulator(cpu) & 0b01111111) - ' ';
 126              		.loc 1 24 0 is_stmt 1
 127 00d2 488B0D00 		movq	video+792(%rip), %rcx
 127      000000
 128 00d9 8B050000 		movl	video+804(%rip), %eax
 128      0000
 129 00df 8D5001   		leal	1(%rax), %edx
 130 00e2 89150000 		movl	%edx, video+804(%rip)
 130      0000
 131 00e8 4898     		cltq
 132 00ea 488D1C01 		leaq	(%rcx,%rax), %rbx
 133 00ee 488B45D8 		movq	-40(%rbp), %rax
 134 00f2 4889C7   		movq	%rax, %rdi
 135 00f5 E8000000 		call	getAccumulator
 135      00
 136 00fa 83E07F   		andl	$127, %eax
 137 00fd 83E820   		subl	$32, %eax
 138 0100 8803     		movb	%al, (%rbx)
 139 0102 E9490100 		jmp	.L9
 139      00
 140              	.L10:
  25:ioports.c     **** 		
  26:ioports.c     **** 	} else if (video.textOperation == DELETE_CHAR) {
 141              		.loc 1 26 0
 142 0107 0FB60500 		movzbl	video+800(%rip), %eax
 142      000000
 143 010e 84C0     		testb	%al, %al
 144 0110 756D     		jne	.L12
 145              	.LBB2:
  27:ioports.c     **** 		
  28:ioports.c     **** 		char pchar;
  29:ioports.c     **** 		
  30:ioports.c     **** 		if (video.cursorIndex == 0) {
 146              		.loc 1 30 0
 147 0112 8B050000 		movl	video+804(%rip), %eax
 147      0000
 148 0118 85C0     		testl	%eax, %eax
 149 011a 0F842F01 		je	.L20
 149      0000
 150              	.L13:
  31:ioports.c     **** 			return;
  32:ioports.c     **** 		}
  33:ioports.c     **** 		
  34:ioports.c     **** 		do {
  35:ioports.c     **** 			pchar = video.charBuffer[--video.cursorIndex];
 151              		.loc 1 35 0 discriminator 1
 152 0120 488B1500 		movq	video+792(%rip), %rdx
 152      000000
 153 0127 8B050000 		movl	video+804(%rip), %eax
 153      0000
 154 012d 83E801   		subl	$1, %eax
 155 0130 89050000 		movl	%eax, video+804(%rip)
 155      0000
 156 0136 8B050000 		movl	video+804(%rip), %eax
 156      0000
 157 013c 4898     		cltq
 158 013e 4801D0   		addq	%rdx, %rax
 159 0141 0FB600   		movzbl	(%rax), %eax
 160 0144 8845E7   		movb	%al, -25(%rbp)
  36:ioports.c     **** 			video.charBuffer[video.cursorIndex] = 0;
 161              		.loc 1 36 0 discriminator 1
 162 0147 488B1500 		movq	video+792(%rip), %rdx
 162      000000
 163 014e 8B050000 		movl	video+804(%rip), %eax
 163      0000
 164 0154 4898     		cltq
 165 0156 4801D0   		addq	%rdx, %rax
 166 0159 C60000   		movb	$0, (%rax)
  37:ioports.c     **** 		} while (pchar == 95);
 167              		.loc 1 37 0 discriminator 1
 168 015c 807DE75F 		cmpb	$95, -25(%rbp)
 169 0160 74BE     		je	.L13
  38:ioports.c     **** 		
  39:ioports.c     **** 		if (video.cursorIndex < 0) {
 170              		.loc 1 39 0
 171 0162 8B050000 		movl	video+804(%rip), %eax
 171      0000
 172 0168 85C0     		testl	%eax, %eax
 173 016a 0F89E000 		jns	.L9
 173      0000
  40:ioports.c     **** 			video.cursorIndex = 0;
 174              		.loc 1 40 0
 175 0170 C7050000 		movl	$0, video+804(%rip)
 175      00000000 
 175      0000
 176 017a E9D10000 		jmp	.L9
 176      00
 177              	.L12:
 178              	.LBE2:
  41:ioports.c     **** 		}
  42:ioports.c     **** 		
  43:ioports.c     **** 	} else if (video.textOperation == NEW_LINE) {
 179              		.loc 1 43 0
 180 017f 0FB60500 		movzbl	video+800(%rip), %eax
 180      000000
 181 0186 3C02     		cmpb	$2, %al
 182 0188 0F858000 		jne	.L15
 182      0000
 183              	.LBB3:
  44:ioports.c     **** 		
  45:ioports.c     **** 		int i, co = SCREEN_CHAR_W-(video.cursorIndex%SCREEN_CHAR_W);
 184              		.loc 1 45 0
 185 018e 8B0D0000 		movl	video+804(%rip), %ecx
 185      0000
 186 0194 BA898888 		movl	$-2004318071, %edx
 186      88
 187 0199 89C8     		movl	%ecx, %eax
 188 019b F7EA     		imull	%edx
 189 019d 8D040A   		leal	(%rdx,%rcx), %eax
 190 01a0 C1F805   		sarl	$5, %eax
 191 01a3 89C2     		movl	%eax, %edx
 192 01a5 89C8     		movl	%ecx, %eax
 193 01a7 C1F81F   		sarl	$31, %eax
 194 01aa 29C2     		subl	%eax, %edx
 195 01ac 89D0     		movl	%edx, %eax
 196 01ae 6BC03C   		imull	$60, %eax, %eax
 197 01b1 29C1     		subl	%eax, %ecx
 198 01b3 89C8     		movl	%ecx, %eax
 199 01b5 BA3C0000 		movl	$60, %edx
 199      00
 200 01ba 29C2     		subl	%eax, %edx
 201 01bc 89D0     		movl	%edx, %eax
 202 01be 8945E0   		movl	%eax, -32(%rbp)
  46:ioports.c     **** 	    
  47:ioports.c     **** 	    for (i=0; i<co;i++) {
 203              		.loc 1 47 0
 204 01c1 C745EC00 		movl	$0, -20(%rbp)
 204      000000
 205 01c8 EB22     		jmp	.L16
 206              	.L17:
  48:ioports.c     **** 			video.charBuffer[video.cursorIndex++] = 95;
 207              		.loc 1 48 0 discriminator 3
 208 01ca 488B0D00 		movq	video+792(%rip), %rcx
 208      000000
 209 01d1 8B050000 		movl	video+804(%rip), %eax
 209      0000
 210 01d7 8D5001   		leal	1(%rax), %edx
 211 01da 89150000 		movl	%edx, video+804(%rip)
 211      0000
 212 01e0 4898     		cltq
 213 01e2 4801C8   		addq	%rcx, %rax
 214 01e5 C6005F   		movb	$95, (%rax)
  47:ioports.c     **** 			video.charBuffer[video.cursorIndex++] = 95;
 215              		.loc 1 47 0 discriminator 3
 216 01e8 8345EC01 		addl	$1, -20(%rbp)
 217              	.L16:
  47:ioports.c     **** 			video.charBuffer[video.cursorIndex++] = 95;
 218              		.loc 1 47 0 is_stmt 0 discriminator 1
 219 01ec 8B45EC   		movl	-20(%rbp), %eax
 220 01ef 3B45E0   		cmpl	-32(%rbp), %eax
 221 01f2 7CD6     		jl	.L17
  49:ioports.c     **** 		}
  50:ioports.c     **** 		
  51:ioports.c     **** 		video.charBuffer[video.cursorIndex-co] = 0;
 222              		.loc 1 51 0 is_stmt 1
 223 01f4 488B1500 		movq	video+792(%rip), %rdx
 223      000000
 224 01fb 8B050000 		movl	video+804(%rip), %eax
 224      0000
 225 0201 2B45E0   		subl	-32(%rbp), %eax
 226 0204 4898     		cltq
 227 0206 4801D0   		addq	%rdx, %rax
 228 0209 C60000   		movb	$0, (%rax)
 229              	.LBE3:
 230 020c EB42     		jmp	.L9
 231              	.L15:
  52:ioports.c     **** 	} else if (video.textOperation == RESET) {
 232              		.loc 1 52 0
 233 020e 0FB60500 		movzbl	video+800(%rip), %eax
 233      000000
 234 0215 3C03     		cmpb	$3, %al
 235 0217 7537     		jne	.L9
 236              	.LBB4:
  53:ioports.c     **** 		int i;
  54:ioports.c     **** 		for (i=0; i<video.cursorIndex; i++) {
 237              		.loc 1 54 0
 238 0219 C745E800 		movl	$0, -24(%rbp)
 238      000000
 239 0220 EB16     		jmp	.L18
 240              	.L19:
  55:ioports.c     **** 			video.charBuffer[i] = 0;
 241              		.loc 1 55 0 discriminator 3
 242 0222 488B1500 		movq	video+792(%rip), %rdx
 242      000000
 243 0229 8B45E8   		movl	-24(%rbp), %eax
 244 022c 4898     		cltq
 245 022e 4801D0   		addq	%rdx, %rax
 246 0231 C60000   		movb	$0, (%rax)
  54:ioports.c     **** 			video.charBuffer[i] = 0;
 247              		.loc 1 54 0 discriminator 3
 248 0234 8345E801 		addl	$1, -24(%rbp)
 249              	.L18:
  54:ioports.c     **** 			video.charBuffer[i] = 0;
 250              		.loc 1 54 0 is_stmt 0 discriminator 1
 251 0238 8B050000 		movl	video+804(%rip), %eax
 251      0000
 252 023e 3B45E8   		cmpl	-24(%rbp), %eax
 253 0241 7FDF     		jg	.L19
  56:ioports.c     **** 		}
  57:ioports.c     **** 		video.cursorIndex = 0;
 254              		.loc 1 57 0 is_stmt 1
 255 0243 C7050000 		movl	$0, video+804(%rip)
 255      00000000 
 255      0000
 256 024d EB01     		jmp	.L9
 257              	.L20:
 258              	.LBE4:
 259              	.LBB5:
  31:ioports.c     **** 		}
 260              		.loc 1 31 0
 261 024f 90       		nop
 262              	.L9:
 263              	.LBE5:
  58:ioports.c     **** 	}
  59:ioports.c     **** }
 264              		.loc 1 59 0
 265 0250 4883C428 		addq	$40, %rsp
 266 0254 5B       		popq	%rbx
 267 0255 5D       		popq	%rbp
 268              		.cfi_def_cfa 7, 8
 269 0256 C3       		ret
 270              		.cfi_endproc
 271              	.LFE510:
 273              		.globl	port04_keyout
 275              	port04_keyout:
 276              	.LFB511:
  60:ioports.c     **** 
  61:ioports.c     **** void port04_keyout(I8080 *cpu) {
 277              		.loc 1 61 0
 278              		.cfi_startproc
 279 0257 55       		pushq	%rbp
 280              		.cfi_def_cfa_offset 16
 281              		.cfi_offset 6, -16
 282 0258 4889E5   		movq	%rsp, %rbp
 283              		.cfi_def_cfa_register 6
 284 025b 4883EC10 		subq	$16, %rsp
 285 025f 48897DF8 		movq	%rdi, -8(%rbp)
  62:ioports.c     **** 	if (isInput(cpu)) {
 286              		.loc 1 62 0
 287 0263 488B45F8 		movq	-8(%rbp), %rax
 288 0267 4889C7   		movq	%rax, %rdi
 289 026a E8000000 		call	getIOState
 289      00
 290 026f 85C0     		testl	%eax, %eax
 291 0271 7563     		jne	.L24
  63:ioports.c     **** 		if (keyindex == processed) {
 292              		.loc 1 63 0
 293 0273 0FB61500 		movzbl	keyindex(%rip), %edx
 293      000000
 294 027a 0FB60500 		movzbl	processed(%rip), %eax
 294      000000
 295 0281 38C2     		cmpb	%al, %dl
 296 0283 7513     		jne	.L23
  64:ioports.c     **** 			setAccumulator(cpu, 0);
 297              		.loc 1 64 0
 298 0285 488B45F8 		movq	-8(%rbp), %rax
 299 0289 BE000000 		movl	$0, %esi
 299      00
 300 028e 4889C7   		movq	%rax, %rdi
 301 0291 E8000000 		call	setAccumulator
 301      00
  65:ioports.c     **** 		} else {
  66:ioports.c     **** 			setAccumulator(cpu, (char) keyboardbuffer[processed++]);
  67:ioports.c     **** 			processed = processed % 1024;
  68:ioports.c     **** 		}
  69:ioports.c     **** 	}
  70:ioports.c     **** }
 302              		.loc 1 70 0
 303 0296 EB3E     		jmp	.L24
 304              	.L23:
  66:ioports.c     **** 			processed = processed % 1024;
 305              		.loc 1 66 0
 306 0298 488B0D00 		movq	keyboardbuffer(%rip), %rcx
 306      000000
 307 029f 0FB60500 		movzbl	processed(%rip), %eax
 307      000000
 308 02a6 8D5001   		leal	1(%rax), %edx
 309 02a9 88150000 		movb	%dl, processed(%rip)
 309      0000
 310 02af 0FB6C0   		movzbl	%al, %eax
 311 02b2 4801C8   		addq	%rcx, %rax
 312 02b5 0FB600   		movzbl	(%rax), %eax
 313 02b8 0FBED0   		movsbl	%al, %edx
 314 02bb 488B45F8 		movq	-8(%rbp), %rax
 315 02bf 89D6     		movl	%edx, %esi
 316 02c1 4889C7   		movq	%rax, %rdi
 317 02c4 E8000000 		call	setAccumulator
 317      00
  67:ioports.c     **** 		}
 318              		.loc 1 67 0
 319 02c9 0FB60500 		movzbl	processed(%rip), %eax
 319      000000
 320 02d0 88050000 		movb	%al, processed(%rip)
 320      0000
 321              	.L24:
 322              		.loc 1 70 0
 323 02d6 90       		nop
 324 02d7 C9       		leave
 325              		.cfi_def_cfa 7, 8
 326 02d8 C3       		ret
 327              		.cfi_endproc
 328              	.LFE511:
 330              		.globl	port05_diskrx
 332              	port05_diskrx:
 333              	.LFB512:
  71:ioports.c     **** 
  72:ioports.c     **** void port05_diskrx(I8080 *cpu) {
 334              		.loc 1 72 0
 335              		.cfi_startproc
 336 02d9 55       		pushq	%rbp
 337              		.cfi_def_cfa_offset 16
 338              		.cfi_offset 6, -16
 339 02da 4889E5   		movq	%rsp, %rbp
 340              		.cfi_def_cfa_register 6
 341 02dd 4883EC10 		subq	$16, %rsp
 342 02e1 48897DF8 		movq	%rdi, -8(%rbp)
  73:ioports.c     **** 	if (isInput(cpu)) {
 343              		.loc 1 73 0
 344 02e5 488B45F8 		movq	-8(%rbp), %rax
 345 02e9 4889C7   		movq	%rax, %rdi
 346 02ec E8000000 		call	getIOState
 346      00
 347 02f1 85C0     		testl	%eax, %eax
 348 02f3 751B     		jne	.L27
  74:ioports.c     **** 		setAccumulator(cpu, serialDiskRead());
 349              		.loc 1 74 0
 350 02f5 B8000000 		movl	$0, %eax
 350      00
 351 02fa E8000000 		call	serialDiskRead
 351      00
 352 02ff 0FBED0   		movsbl	%al, %edx
 353 0302 488B45F8 		movq	-8(%rbp), %rax
 354 0306 89D6     		movl	%edx, %esi
 355 0308 4889C7   		movq	%rax, %rdi
 356 030b E8000000 		call	setAccumulator
 356      00
 357              	.L27:
  75:ioports.c     **** 	}
  76:ioports.c     **** }
 358              		.loc 1 76 0
 359 0310 90       		nop
 360 0311 C9       		leave
 361              		.cfi_def_cfa 7, 8
 362 0312 C3       		ret
 363              		.cfi_endproc
 364              	.LFE512:
 366              		.globl	port06_disktx
 368              	port06_disktx:
 369              	.LFB513:
  77:ioports.c     **** 
  78:ioports.c     **** void port06_disktx(I8080 *cpu) {
 370              		.loc 1 78 0
 371              		.cfi_startproc
 372 0313 55       		pushq	%rbp
 373              		.cfi_def_cfa_offset 16
 374              		.cfi_offset 6, -16
 375 0314 4889E5   		movq	%rsp, %rbp
 376              		.cfi_def_cfa_register 6
 377 0317 4883EC10 		subq	$16, %rsp
 378 031b 48897DF8 		movq	%rdi, -8(%rbp)
  79:ioports.c     **** 	if (isOutput(cpu)) {
 379              		.loc 1 79 0
 380 031f 488B45F8 		movq	-8(%rbp), %rax
 381 0323 4889C7   		movq	%rax, %rdi
 382 0326 E8000000 		call	getIOState
 382      00
 383 032b 85C0     		testl	%eax, %eax
 384 032d 7416     		je	.L30
  80:ioports.c     **** 		serialDiskWrite(getAccumulator(cpu));
 385              		.loc 1 80 0
 386 032f 488B45F8 		movq	-8(%rbp), %rax
 387 0333 4889C7   		movq	%rax, %rdi
 388 0336 E8000000 		call	getAccumulator
 388      00
 389 033b 0FBEC0   		movsbl	%al, %eax
 390 033e 89C7     		movl	%eax, %edi
 391 0340 E8000000 		call	serialDiskWrite
 391      00
 392              	.L30:
  81:ioports.c     **** 	} 
  82:ioports.c     **** }
 393              		.loc 1 82 0
 394 0345 90       		nop
 395 0346 C9       		leave
 396              		.cfi_def_cfa 7, 8
 397 0347 C3       		ret
 398              		.cfi_endproc
 399              	.LFE513:
 401              		.globl	port0A_switch_bank
 403              	port0A_switch_bank:
 404              	.LFB514:
  83:ioports.c     **** 
  84:ioports.c     **** void port0A_switch_bank(I8080 *cpu) {
 405              		.loc 1 84 0
 406              		.cfi_startproc
 407 0348 55       		pushq	%rbp
 408              		.cfi_def_cfa_offset 16
 409              		.cfi_offset 6, -16
 410 0349 4889E5   		movq	%rsp, %rbp
 411              		.cfi_def_cfa_register 6
 412 034c 4883EC10 		subq	$16, %rsp
 413 0350 48897DF8 		movq	%rdi, -8(%rbp)
  85:ioports.c     **** 	if (isOutput(cpu)) {
 414              		.loc 1 85 0
 415 0354 488B45F8 		movq	-8(%rbp), %rax
 416 0358 4889C7   		movq	%rax, %rdi
 417 035b E8000000 		call	getIOState
 417      00
 418 0360 85C0     		testl	%eax, %eax
 419 0362 7417     		je	.L32
  86:ioports.c     **** 		bankNumber = getAccumulator(cpu) & 0b11;
 420              		.loc 1 86 0
 421 0364 488B45F8 		movq	-8(%rbp), %rax
 422 0368 4889C7   		movq	%rax, %rdi
 423 036b E8000000 		call	getAccumulator
 423      00
 424 0370 83E003   		andl	$3, %eax
 425 0373 89050000 		movl	%eax, bankNumber(%rip)
 425      0000
  87:ioports.c     **** 	} else {
  88:ioports.c     **** 		setAccumulator(cpu, bankNumber);
  89:ioports.c     **** 	}
  90:ioports.c     **** }
 426              		.loc 1 90 0
 427 0379 EB14     		jmp	.L34
 428              	.L32:
  88:ioports.c     **** 	}
 429              		.loc 1 88 0
 430 037b 8B150000 		movl	bankNumber(%rip), %edx
 430      0000
 431 0381 488B45F8 		movq	-8(%rbp), %rax
 432 0385 89D6     		movl	%edx, %esi
 433 0387 4889C7   		movq	%rax, %rdi
 434 038a E8000000 		call	setAccumulator
 434      00
 435              	.L34:
 436              		.loc 1 90 0
 437 038f 90       		nop
 438 0390 C9       		leave
 439              		.cfi_def_cfa 7, 8
 440 0391 C3       		ret
 441              		.cfi_endproc
 442              	.LFE514:
 444              	.Letext0:
 445              		.file 2 "/usr/lib/gcc/x86_64-pc-linux-gnu/6.3.1/include/stddef.h"
 446              		.file 3 "/usr/include/bits/types.h"
 447              		.file 4 "/usr/include/stdio.h"
 448              		.file 5 "/usr/include/libio.h"
 449              		.file 6 "/usr/include/bits/sys_errlist.h"
 450              		.file 7 "/usr/include/stdint.h"
 451              		.file 8 "/usr/include/math.h"
 452              		.file 9 "/usr/include/SDL2/SDL_stdinc.h"
 453              		.file 10 "/usr/include/SDL2/SDL_pixels.h"
 454              		.file 11 "/usr/include/SDL2/SDL_rect.h"
 455              		.file 12 "/usr/include/SDL2/SDL_surface.h"
 456              		.file 13 "/usr/include/SDL2/SDL_video.h"
 457              		.file 14 "/usr/include/SDL2/SDL_scancode.h"
 458              		.file 15 "/usr/include/SDL2/SDL_messagebox.h"
 459              		.file 16 "../I8080/I8080.h"
 460              		.file 17 "video.h"
 461              		.file 18 "keyboard.h"
 462              		.file 19 "disk_controller.h"
 463              		.file 20 "memory.h"
   1              		.file	"memory.c"
   2              		.text
   3              	.Ltext0:
   4              		.local	hold
   5              		.comm	hold,4,4
   6              		.comm	video,816,32
   7              		.comm	memBanks,32,32
   8              		.comm	sharedMem,8,8
   9              		.comm	bankNumber,4,4
  10              		.globl	initMemory
  12              	initMemory:
  13              	.LFB508:
  14              		.file 1 "memory.c"
   1:memory.c      **** #include <stdint.h>
   2:memory.c      **** #include "memory.h"
   3:memory.c      **** 
   4:memory.c      **** char *memBanks[4],*sharedMem;
   5:memory.c      **** int  bankNumber;
   6:memory.c      **** 
   7:memory.c      **** void initMemory() {
  15              		.loc 1 7 0
  16              		.cfi_startproc
  17 0000 55       		pushq	%rbp
  18              		.cfi_def_cfa_offset 16
  19              		.cfi_offset 6, -16
  20 0001 4889E5   		movq	%rsp, %rbp
  21              		.cfi_def_cfa_register 6
   8:memory.c      **** 	memBanks[0] = malloc(BANK_SIZE);
  22              		.loc 1 8 0
  23 0004 BF00C000 		movl	$49152, %edi
  23      00
  24 0009 E8000000 		call	malloc
  24      00
  25 000e 48890500 		movq	%rax, memBanks(%rip)
  25      000000
   9:memory.c      **** 	memBanks[1] = malloc(BANK_SIZE);
  26              		.loc 1 9 0
  27 0015 BF00C000 		movl	$49152, %edi
  27      00
  28 001a E8000000 		call	malloc
  28      00
  29 001f 48890500 		movq	%rax, memBanks+8(%rip)
  29      000000
  10:memory.c      **** 	memBanks[2] = malloc(BANK_SIZE);
  30              		.loc 1 10 0
  31 0026 BF00C000 		movl	$49152, %edi
  31      00
  32 002b E8000000 		call	malloc
  32      00
  33 0030 48890500 		movq	%rax, memBanks+16(%rip)
  33      000000
  11:memory.c      **** 	memBanks[3] = malloc(BANK_SIZE);
  34              		.loc 1 11 0
  35 0037 BF00C000 		movl	$49152, %edi
  35      00
  36 003c E8000000 		call	malloc
  36      00
  37 0041 48890500 		movq	%rax, memBanks+24(%rip)
  37      000000
  12:memory.c      **** 	
  13:memory.c      **** 	sharedMem = malloc(SHARED_SIZE);
  38              		.loc 1 13 0
  39 0048 BF004000 		movl	$16384, %edi
  39      00
  40 004d E8000000 		call	malloc
  40      00
  41 0052 48890500 		movq	%rax, sharedMem(%rip)
  41      000000
  14:memory.c      **** }
  42              		.loc 1 14 0
  43 0059 90       		nop
  44 005a 5D       		popq	%rbp
  45              		.cfi_def_cfa 7, 8
  46 005b C3       		ret
  47              		.cfi_endproc
  48              	.LFE508:
  50              		.globl	myMMU
  52              	myMMU:
  53              	.LFB509:
  15:memory.c      **** 
  16:memory.c      **** 
  17:memory.c      **** int64_t myMMU(I8080 *cpu, int ladr) {
  54              		.loc 1 17 0
  55              		.cfi_startproc
  56 005c 55       		pushq	%rbp
  57              		.cfi_def_cfa_offset 16
  58              		.cfi_offset 6, -16
  59 005d 4889E5   		movq	%rsp, %rbp
  60              		.cfi_def_cfa_register 6
  61 0060 4883EC20 		subq	$32, %rsp
  62 0064 48897DE8 		movq	%rdi, -24(%rbp)
  63 0068 8975E4   		movl	%esi, -28(%rbp)
  18:memory.c      **** 	
  19:memory.c      **** 	int64_t retval;
  20:memory.c      **** 	
  21:memory.c      **** 	if (bankNumber > 0) {
  64              		.loc 1 21 0
  65 006b 8B050000 		movl	bankNumber(%rip), %eax
  65      0000
  66 0071 85C0     		testl	%eax, %eax
  67 0073 7E1F     		jle	.L3
  22:memory.c      **** 		retval = ladr + (int64_t) memBanks[bankNumber];
  68              		.loc 1 22 0
  69 0075 8B45E4   		movl	-28(%rbp), %eax
  70 0078 4863D0   		movslq	%eax, %rdx
  71 007b 8B050000 		movl	bankNumber(%rip), %eax
  71      0000
  72 0081 4898     		cltq
  73 0083 488B04C5 		movq	memBanks(,%rax,8), %rax
  73      00000000 
  74 008b 4801D0   		addq	%rdx, %rax
  75 008e 488945F8 		movq	%rax, -8(%rbp)
  76 0092 EB78     		jmp	.L4
  77              	.L3:
  23:memory.c      **** 	} else if (ladr < 0x0800) {
  78              		.loc 1 23 0
  79 0094 817DE4FF 		cmpl	$2047, -28(%rbp)
  79      070000
  80 009b 7F15     		jg	.L5
  24:memory.c      **** 		retval = ladr + (int64_t) memBanks[0];
  81              		.loc 1 24 0
  82 009d 8B45E4   		movl	-28(%rbp), %eax
  83 00a0 4898     		cltq
  84 00a2 488B1500 		movq	memBanks(%rip), %rdx
  84      000000
  85 00a9 4801D0   		addq	%rdx, %rax
  86 00ac 488945F8 		movq	%rax, -8(%rbp)
  87 00b0 EB5A     		jmp	.L4
  88              	.L5:
  25:memory.c      **** 	} else if (ladr < 0x5800) {
  89              		.loc 1 25 0
  90 00b2 817DE4FF 		cmpl	$22527, -28(%rbp)
  90      570000
  91 00b9 7F38     		jg	.L6
  26:memory.c      **** 		
  27:memory.c      **** 		// If it's in output mode then we know it's writing to the buffer
  28:memory.c      **** 		if (isOutput(cpu)) {
  92              		.loc 1 28 0
  93 00bb 488B45E8 		movq	-24(%rbp), %rax
  94 00bf 4889C7   		movq	%rax, %rdi
  95 00c2 E8000000 		call	getIOState
  95      00
  96 00c7 85C0     		testl	%eax, %eax
  97 00c9 740A     		je	.L7
  29:memory.c      **** 			video.dirtyBuffer = 1;
  98              		.loc 1 29 0
  99 00cb C7050000 		movl	$1, video+808(%rip)
  99      00000100 
  99      0000
 100              	.L7:
  30:memory.c      **** 		}
  31:memory.c      **** 
  32:memory.c      **** 		retval = (int64_t) video.pixelBuffer + ladr - 0x0800;
 101              		.loc 1 32 0
 102 00d5 488B0500 		movq	video+784(%rip), %rax
 102      000000
 103 00dc 4889C2   		movq	%rax, %rdx
 104 00df 8B45E4   		movl	-28(%rbp), %eax
 105 00e2 4898     		cltq
 106 00e4 4801D0   		addq	%rdx, %rax
 107 00e7 482D0008 		subq	$2048, %rax
 107      0000
 108 00ed 488945F8 		movq	%rax, -8(%rbp)
 109 00f1 EB19     		jmp	.L4
 110              	.L6:
  33:memory.c      **** 	} else {
  34:memory.c      **** 		retval = ladr + (int64_t) memBanks[0] - 0x5000;
 111              		.loc 1 34 0
 112 00f3 8B45E4   		movl	-28(%rbp), %eax
 113 00f6 4898     		cltq
 114 00f8 488B1500 		movq	memBanks(%rip), %rdx
 114      000000
 115 00ff 4801D0   		addq	%rdx, %rax
 116 0102 482D0050 		subq	$20480, %rax
 116      0000
 117 0108 488945F8 		movq	%rax, -8(%rbp)
 118              	.L4:
  35:memory.c      **** 	}
  36:memory.c      **** 	
  37:memory.c      **** 	return retval;
 119              		.loc 1 37 0
 120 010c 488B45F8 		movq	-8(%rbp), %rax
  38:memory.c      **** }
 121              		.loc 1 38 0
 122 0110 C9       		leave
 123              		.cfi_def_cfa 7, 8
 124 0111 C3       		ret
 125              		.cfi_endproc
 126              	.LFE509:
 128              	.Letext0:
 129              		.file 2 "/usr/include/stdint.h"
 130              		.file 3 "../I8080/I8080.h"
 131              		.file 4 "/usr/lib/gcc/x86_64-pc-linux-gnu/6.3.1/include/stddef.h"
 132              		.file 5 "/usr/include/bits/types.h"
 133              		.file 6 "/usr/include/libio.h"
 134              		.file 7 "/usr/include/stdio.h"
 135              		.file 8 "/usr/include/bits/sys_errlist.h"
 136              		.file 9 "/usr/include/math.h"
 137              		.file 10 "/usr/include/SDL2/SDL_stdinc.h"
 138              		.file 11 "/usr/include/SDL2/SDL_pixels.h"
 139              		.file 12 "/usr/include/SDL2/SDL_rect.h"
 140              		.file 13 "/usr/include/SDL2/SDL_surface.h"
 141              		.file 14 "/usr/include/SDL2/SDL_video.h"
 142              		.file 15 "/usr/include/SDL2/SDL_scancode.h"
 143              		.file 16 "/usr/include/SDL2/SDL_messagebox.h"
 144              		.file 17 "video.h"
 145              		.file 18 "memory.h"
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
