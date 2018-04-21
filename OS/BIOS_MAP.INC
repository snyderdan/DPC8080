OS_LOADER_BASE		EQU	05800h
OS_LOADER_SIZE		EQU	00200h
OS_BASE				EQU	05A00H

NULL_INTERRUPT		EQU	00073H

;***********************************************************************
;
; FUNCTION:  SWITCH_BANK
; PARAMS:    BANK NUMBER IN A (1-7)
; RETURNS:   NONE
; NOTES:     SWITCHES THE MEMORY BANK. BE PREPARED.
; PROC TIME: 20 CYCLES
;
;***********************************************************************
SWITCH_BANK			EQU	00074H


;***********************************************************************
;
; FUNCTION:  GET_BANK
; PARAMS:    NONE
; RETURNS:   BANK NUMBER IN A (1-7)
; NOTES:     RETURNS THE CURRENT MEMORY BANK
; PROC TIME: 20 CYCLES
;
;***********************************************************************
GET_BANK			EQU	00077H

;***********************************************************************
;
; FUNCTION:  SET_VIDE0_MODE
; PARAMS:    MODE CODE IN A
; RETURNS:   MODE SENT IN A
; NOTES:     CHANGES THE DISPLAY MODE
; PROC TIME: 27 CYCLES
;
;***********************************************************************
SET_VIDEO_MODE		EQU	0007AH
; AVAILABLE MODES
HI_RES_MODE	EQU 00H
LO_RES_MODE	EQU 01H
TEXT_MODE	EQU 02H

;***********************************************************************
;
; FUNCTION:  SET_INPUT_MODE
; PARAMS:    MODE CODE IN A
; RETURNS:   MODE SENT
; NOTES:     CHANGES THE INPUT MODE TO EITHER INTERRUPT OR POLLING
; PROC TIME: 5702 CYCLES
;
;***********************************************************************
SET_INPUT_MODE		EQU	0007FH
; AVAILABLE MODES
POLLING_MODE	EQU 00H
INTERRUPT_MODE	EQU 01H

;***********************************************************************
;
; FUNCTION:  ZERO_INPUT_BUFFER
; PARAMS:    NONE
; RETURNS:   NONE
; NOTES:     ZEROS THE BUFFER AND COUNTERS
; PROC TIME: 5682 CYCLES
;
;***********************************************************************
ZERO_INPUT_BUFFER	EQU	00084H

;***********************************************************************
;
; FUNCTION:  GETKEY
; PARAMS:    IF IN POLLING MODE, THEN KEY IN A
;	     	 IF IN INTERRUPT MODE, THEN NONE
; RETURNS:   IF IN POLLING MODE, STATE OF KEY IN A
;	     	 OTHERWISE NEXT KEY IN BUFFER IN A OR -1 IF NO KEYS PRESSED
; NOTES:
; PROC TIME: 62/93 CYCLES
;
;***********************************************************************
GETKEY				EQU	000C3H

;***********************************************************************
;
; FUNCTION:  RESET_CURSOR
; PARAMS:    NONE
; RETURNS:   -1 IN A IF NOT IN TEXT MODE, ELSE NONE
; NOTES:     SETS CURSOR TO 0 AND CLEARS SCREEN
; PROC TIME: 28/63 CYCLES
;
;***********************************************************************
RESET_CURSOR		EQU	000FFH

;***********************************************************************
;
; FUNCTION:  DISPCHAR
; PARAMS:    CHAR TO DISPLAY IN A
; RETURNS:   CHAR DISPLAYED OR -1 IF NOT IN TEXT MODE
; NOTES:     DISPLAYS CHARACTER TO SCREEN AT CURSOR POSITION THEN
;	     INCREMENTS CURSOR
; PROC TIME: 45-110 CYCLES
;
;***********************************************************************
DISPCHAR			EQU	0010EH

;***********************************************************************
;
; FUNCTION:  PRINT
; PARAMS:    BASE OF NULL-TERMINATED STRING IN HL
; RETURNS:   0 IN A IF SUCCESSFUL
; NOTES:
; PROC TIME: 127*(STRLEN+1) + 69
;
;***********************************************************************
PRINT				EQU	00128H

;***********************************************************************
;
; FUNCTION:  GETCHAR
; PARAMS:    NONE
; RETURNS:   CHARACTER CODE OF INPUT KEY
; NOTES:     WAITS FOR A KEY TO GET PRESSED AND DISPLAYS IT TO SCREEN
; PROC TIME:
;
;***********************************************************************	
GETCHAR				EQU	00134H

;***********************************************************************
;
; FUNCTION:  GETCH
; PARAMS:    NONE
; RETURNS:   CHARACTER CODE OF INPUT KEY
; NOTES:     RETURNS KEY PRESSED WITHOUT ECHO
; PROC TIME:
;
;***********************************************************************
GETCH				EQU	0013FH

;***********************************************************************
;
; FUNCTION:  READ_SECTOR
; PARAMS:    16-BIT CHS ADDRESS IN DE AND BUFFER ADDRESS IN HL
; RETURNS:   0 IN A IF SUCCESSFUL, ERROR CODE OTHERWISE
; NOTES:     ADDRESS IS IN CHS: 	D	  |	   E
;						 C C C C C C C H  |  H H S S S S S S
;	     THIS IS THE CORE READ OPERATION, WHICH SHOULD ONLY
;	     BE PERFORMED UNDER THE DISGRESSION OF THE OS.
; PROC TIME: BEST CASE: 30883 CYCLES
;
;***********************************************************************
READ_SECTOR			EQU	00148H

;***********************************************************************
;
; FUNCTION:  WRITE_SECTOR
; PARAMS:    16-BIT CHS ADDRESS IN DE AND BUFFER ADDRESS IN HL
; RETURNS:   0 IN A IF SUCCESSFUL, ERROR CODE OTHERWISE
; NOTES:     ADDRESS IS IN CHS: 	D	  |	   E
;						 C C C C C C C H  |  H H S S S S S S
;	     THIS IS THE CORE WRITE OPERATION, WHICH SHOULD ONLY
;	     BE PERFORMED UNDER THE DISGRESSION OF THE OS.
; PROC TIME: BEST CASE: 30883 CYCLES
;
;***********************************************************************
WRITE_SECTOR		EQU	001B6H