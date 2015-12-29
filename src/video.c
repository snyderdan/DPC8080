#include "video.h"

void initDisplay() {
	video.charBuffer  = malloc(1680);
	video.pixelBuffer = malloc(0x5000);
	video.screen      = SDL_SetVideoMode((SCREEN_WIDTH*HIRES_SCALE_FACTOR),(SCREEN_HEIGHT*HIRES_SCALE_FACTOR),32,SDL_SWSURFACE);
	memset(video.pixelBuffer, 0, 0x5000);
	SDL_EnableUNICODE(1);
	
	video.textOperation = APPEND_CHAR;
	video.dirtyBuffer = 1;
	video.displayMode = HIGH_RES;
	
	int i; 
	
	for (i=0;i<95;i++) {
		char buf[16];
		sprintf(buf, "../charmap/%d.bmp", i);
		SDL_Surface *charimg = SDL_LoadBMP(buf);
		SDL_Surface *formatted = SDL_DisplayFormat(charimg);
		video.charMap[i] = LinearScale(formatted, HIRES_SCALE_FACTOR);
		SDL_FreeSurface(charimg);
		SDL_FreeSurface(formatted);
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
	    for (x=0; x<LORES_PITCH; x++) {
			for (y=0; y<SCREEN_HEIGHT/2; y++) {
				Uint8 *newpixel = video.pixelBuffer + x + (y*LORES_PITCH);
				Uint32 pixeloffset = (x*LORES_SCALE_FACTOR) + (y*LORES_SCALE_FACTOR*video.screen->pitch);
				SDL_Color c = map_color8to32(*newpixel);
				Uint32 pixcol = SDL_MapRGB(video.screen->format, c.r, c.g, c.b);
				for (o_y=0; o_y<LORES_SCALE_FACTOR; o_y++) {
					for (o_x=0; o_x<LORES_SCALE_FACTOR; o_x++) {
						Uint32 *currentpixel = (Uint32 *)(video.screen->pixels + pixeloffset + o_x + (o_y*video.screen->pitch));
						*currentpixel = pixcol;
					}
				}
			}
		}
    } else if (video.displayMode == HIGH_RES) {
		int y, x, o_y, o_x, bi;
	    for (x=0; x<HIRES_PITCH; x++) {
			for (y=0; y<SCREEN_HEIGHT; y++) {
				Uint8 newpixel = * (Uint8 *)(video.pixelBuffer + x + (y*HIRES_PITCH));
				for (bi=0; bi<4; bi++) {
					Uint8 id;
					id    = (newpixel & (0x3 << (bi*2))) >> (bi*2);
					Uint32 pixeloffset = (((x*4)+bi)*HIRES_SCALE_FACTOR) + (y*HIRES_SCALE_FACTOR*video.screen->pitch);
					SDL_Color c = map_color2to32(id);
					Uint32 pixcol = SDL_MapRGB(video.screen->format, c.r, c.g, c.b);
					for (o_x=0; o_x<HIRES_SCALE_FACTOR; o_x++) {
						for (o_y=0; o_y<HIRES_SCALE_FACTOR; o_y++) {
							Uint32 *currentpixel = (Uint32 *)(video.screen->pixels + pixeloffset + o_x + (o_y*video.screen->pitch));
							*currentpixel = pixcol;
						}
					}
				}
			}
		}
	} else if (video.displayMode == TEXT_MODE) {
		int i,j, o;
		SDL_Rect dest;
		dest.y = 0;
		for (i=0;i<SCREEN_CHAR_H;i++){
			o = i*SCREEN_CHAR_W;
			dest.x = 0;
			for (j=0;j<SCREEN_CHAR_W;j++) {
				SDL_Surface *image = video.charMap[(int)video.charBuffer[o+j]];
				SDL_BlitSurface(image, NULL, video.screen, &dest);
				dest.x += CHAR_WIDTH*HIRES_SCALE_FACTOR;
			}
			dest.y += CHAR_HEIGHT*HIRES_SCALE_FACTOR;
		}
	}
}     

void serviceDisplay() {
	if (video.dirtyBuffer) {
			video.dirtyBuffer = 0;
			updateScreen();
			SDL_Flip(video.screen);
	    }
}       
