#include <stdio.h>
#include <windows.h>
#include "drawing.h"
#include "..\\I8080\\I8080.h"

#ifndef _DPC_VIDEO_
# define _DPC_VIDEO_

# define HIRES_SCALE_FACTOR  3
# define LORES_SCALE_FACTOR  (HIRES_SCALE_FACTOR*2)

# define SCREEN_WIDTH  360
# define SCREEN_HEIGHT 224

# define LORES_PITCH   (SCREEN_WIDTH/2)
# define HIRES_PITCH   (SCREEN_WIDTH*2/8)

# define CHAR_WIDTH    6
# define CHAR_HEIGHT   8
# define SCREEN_CHAR_W (SCREEN_WIDTH/CHAR_WIDTH)
# define SCREEN_CHAR_H (SCREEN_HEIGHT/CHAR_HEIGHT)

# define HIGH_RES      0
# define LOW_RES       1
# define TEXT_MODE     2

# define DELETE_CHAR 0
# define APPEND_CHAR 1
# define NEW_LINE    2
# define RESET       3

typedef struct video_controller {
	SDL_Surface *screen, *charMap[96];
	Uint8       *pixelBuffer,
				*charBuffer,
				 textOperation,
				 displayMode;
	int cursorIndex,
		dirtyBuffer;
} Display;

Display video;

void initDisplay();
SDL_Color map_color8to32(Uint8 color);
SDL_Color map_color2to32(Uint8 color);
void updateScreen();
void serviceDisplay();
#endif
