/***************************** delay.h *****************/
#ifndef __DELAY_H__
#define __DELAY_H__

#include <windows.h>

extern void __cdecl delaySeconds( int seconds );
extern void __cdecl delayMilliSeconds( int miliseconds );
extern void __cdecl delayMicroSeconds( int microseconds );
extern void __cdecl delayCycles( int usecs, int cycles );
extern void __cdecl getMicroSeconds( __int64 *us );
extern void __cdecl getMilliSeconds( __int64 *ms );

#endif
/************************************************** *********/
