

;********************************************************************
;
; ALL MEMORY BLOCKS HAVE 2 BYTES IN THE FRONT WHICH DESIGNATE
; THE USAGE OF MEMORY. A 1 IN THE HIGHEST BIT PLACE INDICATES THAT
; THIS MEMORY BLOCK IS ALLOCATED. THE REMAINING 15 BITS CONTAINS
; THE SIZE OF THE CURRENT MEMORY BLOCK.
;
;********************************************************************

	INCLUDE "BIOS_MAP.INC"

what has to happen in the malloc routine:
- need to get memory as fast as possible
- assume that anything like this

MALLOC:
	DI			; THIS MUST BE ATOMIC
	XRA	A		; ZERO REGISTER A
	CALL	SWITCH_BANKS	; GO TO BANK 0 (DIM-1)
	LXI	H,8000H 	; LOAD 8000H (32K MARK)
	MOV	A,M		; LOAD A WITH FIRST BYTE
	CPI	10000000B	; CHECK IF TOP BIT IS SET
	JP	MAL_00		; BIT IS ZERO - CONTINUE



DEALLOC:

CALLOC:
