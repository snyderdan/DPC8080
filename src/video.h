#include <stdio.h>
#include <SDL2/SDL.h>
#include "../I8080/I8080.h"

#ifndef _DPC_VIDEO_
# define _DPC_VIDEO_

# define SCALE_FACTOR  2

# define VIRTUAL_WIDTH  360
# define VIRTUAL_HEIGHT 224

# define REAL_WIDTH  (VIRTUAL_WIDTH * SCALE_FACTOR)
# define REAL_HEIGHT (VIRTUAL_HEIGHT * SCALE_FACTOR)

# define HIRES_WIDTH 	VIRTUAL_WIDTH
# define HIRES_HEIGHT	VIRTUAL_HEIGHT

# define LORES_WIDTH	(VIRTUAL_WIDTH/2)
# define LORES_HEIGHT	(VIRTUAL_HEIGHT/2)

# define CHAR_WIDTH    6
# define CHAR_HEIGHT   8
# define SCREEN_CHAR_W (VIRTUAL_WIDTH/CHAR_WIDTH)
# define SCREEN_CHAR_H (VIRTUAL_HEIGHT/CHAR_HEIGHT)

# define HIGH_RES      0
# define LOW_RES       1
# define TEXT_MODE     2

# define DELETE_CHAR 0
# define APPEND_CHAR 1
# define NEW_LINE    2
# define RESET       3

typedef struct video_controller {
	SDL_Window  *window;
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
SDL_Surface *LinearScale(SDL_Surface *Surface, int scale_factor);
SDL_Color map_color8to32(Uint8 color);
SDL_Color map_color2to32(Uint8 color);
void updateScreen();
void serviceDisplay();
#endif
