

; HOW TO ENTER A FUNCTION:
; 'TOP' OF STACK IS RETURN ADDRESS
; BELOW THAT ARE FUNCTION PARAMETERS
; WE HAVE NO REGISTERS TO USE. 
; HOW DO WE DO THIS EFFECTIVELY?
; ENTER SHOULD SAVE ALL REGISTERS AND MOVE TO PARAMETERS
; ANOTHER MACRO SHOULD MOVE US TO SAFE STACK SPACE
; AND FINALLY THE EXIT MACRO SHOULD CLEAN UP EVERYTHING
; AND PLACE US RIGHT AT WHERE THE STACK WAS UPON ENTRY 
; BEFORE FINALLY RETURNING

NUM_PARMS   SET 1

ENTER   MACRO 
        PUSH B          ; SAVE ALL REGISTERS
        PUSH D
        PUSH H
        COPYPARMS
        ENDM

COPYPARMS   MACRO
            ; ADDRESS OF NEW PARM SPACE 
            LXI  H,-(2*NUM_PARMS)
            DAD  SP     ; NEW PARM ADDRESS TO -> HL
            MOV  D,H    ; UPPER BYTE INTO D
            MOV  E,L    ; LOWER BYTE INTO E
            LXI  H,8    ; 8 BYTES TO GET TO PARMS
            DAD  SP     ; CURRENT PARM ADDRESS -> HL
            MVI  C,2*NUM_PARMS

            MOV  A,M    ; LOAD BYTE INTO A
            STAX D      ; STORE BYTE
            INX  H      ; MOVE TO NEXT BYTE
            INX  D      ; MOVE TO NEXT BYTE
            DCR  C      ; DECREMENT
            JNZ  $-5
            LXI  H,-(2*NUM_PARMS)
            DAD  SP     ; HL NOW POINTS TO NEW PARMS
            SPHL        ; MOVE TO PARMS
            ENDM 

EXIT        MACRO
            POP  H
            POP  D
            POP  B
            RET
            ENDM

CLEAREXIT   MACRO
            LXI  H,2*NUM_PARMS
            DAD  SP     ; ADDRESS OF REGISTERS IN HL
            SPHL        ; MOVE TO ADDRESS
            EXIT
            ENDM

EXIT16      MACRO
            POP  D
            POP  D
            POP  B
            ENDM

CLEAREXIT16 MACRO
            LXI  H,2*NUM_PARMS
            DAD  SP     ; ADDRESS OF REGISTERS IN HL
            SPHL        ; MOVE TO ADDRESS
            EXIT16
            ENDM