#include "video.h"
#include <time.h>

Display video;

Uint32 ReadPixel(SDL_Surface* source, Sint16 X, Sint16 Y) {
	return *((Uint32 *) (source->pixels + X + (Y*source->pitch)));
}

void DrawPixel(SDL_Surface *surface, int x, int y, Uint32 color) {
	Uint32 *currentpixel = (Uint32 *)(surface->pixels + x + (y*surface->pitch));
	*currentpixel = color;
}

SDL_Surface *loadSurface(char *path) {
	SDL_Surface *loaded, *optimized, *scaled;
	SDL_Rect dest;
	
	loaded = SDL_LoadBMP(path);
	optimized = SDL_ConvertSurface(loaded, video.screen->format, 0);
	
	dest.x = 0;
	dest.y = 0;
	dest.h = SCALE_FACTOR*optimized->h;
	dest.w = SCALE_FACTOR*optimized->w;
	
	scaled = SDL_CreateRGBSurface(optimized->flags, SCALE_FACTOR*optimized->w, SCALE_FACTOR*optimized->h, optimized->format->BitsPerPixel,
        optimized->format->Rmask, optimized->format->Gmask, optimized->format->Bmask, optimized->format->Amask);
    
    SDL_BlitScaled(optimized, NULL, scaled, &dest);
    free(loaded);
    free(optimized);
    return scaled;
}

void initDisplay() {
	video.charBuffer  = calloc(1680, 1);
	video.pixelBuffer = calloc(0x5000, 1);
	video.window 	  = SDL_CreateWindow("DPC Emulator", 0, 0, REAL_WIDTH, REAL_HEIGHT, SDL_WINDOW_SHOWN);
	video.screen	  = SDL_GetWindowSurface(video.window);
	
	video.textOperation = APPEND_CHAR;
	video.dirtyBuffer = 1;
	video.cursorIndex = 0;
	video.displayMode = HIGH_RES;
	
	int i; 
	
	for (i=0;i<95;i++) {
		char buf[16];
		sprintf(buf, "charmap/%d.bmp", i);
		video.charMap[i] = loadSurface(buf);
	}
	
	video.charMap[95] = video.charMap[0];
}

SDL_Color map_color8to32(Uint8 color) {
	SDL_Color new;
	new.r = (int)(((color & 0b11100000) >> 5) * 36.42857);
	new.g = (int)(((color & 0b00011100) >> 2) * 36.42857);
	new.b = (int)((color & 0b00000011) * 85.0);
	return new;
}

SDL_Color map_color2to32(Uint8 color) {
	Uint8 map[] = {0xFF,0xAA,0x55,0x00};
	return map_color8to32(map[color & 0b11]);
}

void updateScreen() {
    
    if (video.displayMode == LOW_RES) {
	    int y, x, o_y, o_x;
	    int scale = SCALE_FACTOR * 2;
	    for (x=0; x<LORES_WIDTH; x++) {
			for (y=0; y<LORES_HEIGHT; y++) {
				Uint8 *newpixel = video.pixelBuffer + x + (y*LORES_WIDTH);
				SDL_Color c = map_color8to32(*newpixel);
				Uint32 pixcol = SDL_MapRGB(video.screen->format, c.r, c.g, c.b);
				for (o_y=0; o_y<scale; o_y++) {
					for (o_x=0; o_x<scale; o_x++) {
						DrawPixel(video.screen, x*scale + o_x, y*scale + o_y, pixcol);
					}
				}
			}
		}
    } else if (video.displayMode == HIGH_RES) {
		int y, x, o_y, o_x, bi;
	    for (x=0; x<HIRES_WIDTH; x++) {
			for (y=0; y<HIRES_HEIGHT; y++) {
				Uint8 newpixel = * (Uint8 *)(video.pixelBuffer + x + (y*HIRES_WIDTH/4));
				for (bi=0; bi<4; bi++) {
					Uint8 id;
					id = (newpixel & (0x3 << (bi*2))) >> (bi*2);
					SDL_Color c = map_color2to32(id);
					Uint32 pixcol = SDL_MapRGB(video.screen->format, c.r, c.g, c.b);
					for (o_x=0; o_x<SCALE_FACTOR; o_x++) {
						for (o_y=0; o_y<SCALE_FACTOR; o_y++) {
							DrawPixel(video.screen, x*SCALE_FACTOR + o_x, y*SCALE_FACTOR + o_y, pixcol);
						}
					}
				}
			}
		}
	} else if (video.displayMode == TEXT_MODE) {
		int i, j;
		SDL_Rect dest;
		dest.y = 0;
		for (i=0; i<SCREEN_CHAR_H; i++) {
			dest.x = 0;
			for (j=0; j<SCREEN_CHAR_W; j++) {
				SDL_Surface *image = video.charMap[(int)video.charBuffer[j+i*SCREEN_CHAR_W]];
				SDL_BlitSurface(image, NULL, video.screen, &dest);
				dest.x += CHAR_WIDTH*SCALE_FACTOR;
			}
			dest.y += CHAR_HEIGHT*SCALE_FACTOR;
		}
	}
}     

void serviceDisplay() {
	if (video.dirtyBuffer) {
			video.dirtyBuffer = 0;
			updateScreen();
			SDL_UpdateWindowSurface(video.window);
	    }
}       
