
;***********************************************************************
;
; HOW THIS SCHEDULER WORKS:
;     ON INITIALIZATION, THE INFOSTRUCTURE FOR STORING CONTEXTS IS 
;     CREATED AND A CONTEXT FOR THE "CURRENT" THREAD IS MADE. AFTER THIS
;     NEW CONTEXTS, AND THEREFORE NEW THREADS, ARE ALLOWED TO BE CREATED.
; 
;     TO CREATE 
;
	
PCB_STRUCT:
	ORG  0
PCB_STATE	DS	1	; ONE BYTE STATE
; POSSIBLE STATES
PCB_WAIT	EQU	1	; PROCESS WAITING
PCB_ACTIVE	EQU	2	; PROCESS RUNNING
PCB_IO		EQU	3	; PROCESS IO BOUND
PCB_TERM	EQU	4	; PROCESS TERMINATED

PCB_ID		DS	1	; ID (256 PROCESSES)
PCB_HANDLE	DS	2	; WHICH IO HANDLE PROCESS IS WAITING ON
PCB_NEXT	DS	2	; POINTER TO NEXT PCB
PCB_BANK	DS	1   ; BANK NUMBER
PCB_STACK	DS  2	; SP WHICH STORES ALL CONTEXT DATA
	
	ORG  PCB_STRUCT
	
;***********************************************************************
;
; FUNCTION:  SWAP_CONTEXT
; PARAMS:    NOTHING
; RETURNS:   NOTHING
; NOTES:     SAVES THE CURRENT CONTEXT TO THE CURRENT CONTEXT PTR.
;
;***********************************************************************
SWAP_CONTEXT:
	DI			; OBVIOUSLY WE DISABLE INTERRUPTS
	; SAVE CONTEXT TO TOP OF STACK
	PUSH PSW
	PUSH B
	PUSH D
	PUSH H
;***********************************************************************
; 
; AT THIS POINT THE STACK LOOKS LIKE THIS:
;          ________
;  SP     |   HL   |
;  SP+2   |   DE   |
;  SP+4   |   BC   |
;  SP+6   |   AF   |
;  SP+8   |   PC   |
;  SP+10  |___...__|
; 
;***********************************************************************
	; SAVE STACK PTR INTO CURRENT CONTEXT
	LXI  H, 0				; ZERO HL
	DAD  SP					; GET STACK PTR
	XCHG					; STORE STACK PTR IN DE
	LXI  H, CURRENT_PCB		; LOAD PCB ADDRESS
	LXI  B, PCB_STACK		; STACK OFFSET
	DAD  B					; LOAD STACK PTR OFFSET IN HL
	MOV  M, E				; STORE LOWER BYTE
	INX  H					;
	MOV  M, D				; STORE UPPER BYTE
	; SAVE BANK NUMBER IN CURRENT PCB
	LXI  H, CURRENT_PCB		; LOAD PCB ADDR
	LXI  D, PCB_BANK		; LOAD BANK OFFSET
	DAD  D					; LOAD EFFECTIVE ADDRESS INTO H
	CALL GET_BANK			; GET BANK NO. IN A
	MOV  M, A				; STORE BANK NUMBER
	; LOAD NEXT PCB 
	LXI  H, CURRENT_PCB		; LOAD PCB ADDRESS
	LXI  D, PCB_NEXT		; OFFSET FOR NEXT PCB
	DAD  D					; GET CORRECT ADDRESS
	MOV  E, M 				; LOAD LOWER BYTE INTO E
	INX  H					; 
	MOV  D, M 				; LOAD UPPER BYTE - DE NOW CONTAINS NEXT PCB
	; SWAP TO CORRECT BANK
	LXI  H, PCB_BANK		; BANK OFFSET
	DAD  D					; LOAD ADDRESS INTO HL
	XCHG					; DE - BANK ADDRESS, HL - NEXT PCB
	LDAX D					; LOAD BANK NO. INTO A
	CALL SWITCH_BANK		; SWITCH TO CORRECT BANK
	; UPDATE CURRENT PCB
	LXI  D, CURRENT_PCB		; LOAD PCB ADDRESS IN D
	MOV  A, L				; LOAD LOWER BYTE INTO A
	STAX D					; STORE LOWER BYTE
	MOV  A, H				; LOAD UPPER BYTE INTO A
	INX  D
	STAX D					; STORE UPPER BYTE
	; SWAP IN NEXT STACK PTR
	LXI  D, PCB_STACK		; STACK OFFSET
	DAD  D					; GET STACK PTR ADDRESS IN HL
	MOV  E, M				; LOAD LOWER BYTE
	INX  H					;
	MOV  D, M				; LOAD UPPER BYTE OF STACK PTR
	XCHG					; MOVE STACK PTR INTO HL
	SPHL					; LOAD NEW STACK PTR
	POP  H					; LOAD REG VALUES
	POP  D
	POP  B
	POP  PSW
	EI						; ENABLE INTERRUPTS
	RET						; RESUME OTHER THREAD
	
CURRENT_PCB DW  0