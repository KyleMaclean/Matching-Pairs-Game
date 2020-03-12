    B main

prompt  DEFB "Enter square to reveal: ",0
mesg    DEFB "You entered the index ",0

    ALIGN
main    
	MOV R13, #0x10000
	ADR R0, prompt
        BL  boardSquareInput

        MOV R1, R0
        ADR R0, mesg
        SWI 3
        MOV R0,R1
        SWI 4
        MOV R0,#10
        SWI 0
        SWI 2


; boardSquareInput -- read board position from keyboard
; Input:  R0 ---> prompt string address
; Ouptut: R0 <--- index

boardSquareInput

	STMFD R13!, {R4-R7,R14}	
	
	MOV R4,R0	; prompt address saved
	MOV R5,#0
	MOV R6,#4	; max columns
	MOV R7,#0

start	MOV R0,R4	; prompt loaded
	SWI 3
	SWI 1
	CMP R0,#97
	BLT com
	
	SUB R0,R0,#32
	
com	SUB R0,R0,#65
	CMP R0,#0
	BLT start
	CMP R0,#3
	BGT start
	MOV R5,R0

	SWI 1
	SUB R0,R0,#49
	CMP R0,#0
	BLT start
	CMP R0,#3
	BGT start
	MOV R7,R0

	SWI 1
	CMP R0,#10
	BNE start

	MUL R5,R5,R6
	ADD R5,R5,R7
	MOV R0,R5

	LDMFD R13!, {R4-R7,PC}
