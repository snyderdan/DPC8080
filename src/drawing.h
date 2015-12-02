#include <SDL\\SDL.h>

Uint32 ReadPixel(SDL_Surface *surf, int x, int y);
void PutPixel(SDL_Surface *, int, int, Uint32);
void PutPixel8(SDL_Surface *, int, int, Uint32);
void PutPixel16(SDL_Surface *, int, int, Uint32);
void PutPixel32(SDL_Surface *, int, int, Uint32);
void PutPixel_nolock(SDL_Surface *, int, int, Uint32);
void PutPixel8_nolock(SDL_Surface *, int, int, Uint32);
void PutPixel16_nolock(SDL_Surface *, int, int, Uint32);
void PutPixel32_nolock(SDL_Surface *, int, int, Uint32);
void PutRect(SDL_Surface *screen, int x, int y, int w, int h, Uint32 color);
SDL_Surface *ScaleSurface(SDL_Surface *src, Uint16 w, Uint16 h);
SDL_Surface *LinearScale(SDL_Surface *Surface, int scale_factor);
SDL_Surface *zoomSurface(SDL_Surface * src, double zoomx, double zoomy, int smooth);
void zoomSurfaceSize(int width, int height, double zoomx, double zoomy, int *dstwidth, int *dstheight);
int _zoomSurfaceRGBA(SDL_Surface * src, SDL_Surface * dst, int flipx, int flipy, int smooth);
Uint32 _colorkey(SDL_Surface *src);
int _zoomSurfaceY(SDL_Surface * src, SDL_Surface * dst, int flipx, int flipy);
