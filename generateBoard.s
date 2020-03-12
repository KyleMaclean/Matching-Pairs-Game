        B main

seed	DEFW	5
magic	DEFW	65539
mask	DEFW	0x7FFFFFFF
board	DEFW 	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
row1	DEFB	"     1    2    3    4\n",0
nl		DEFB	"\n",0

        ALIGN
main    MOV R13,#0x10000     ; Setup stack
        ADR R0, board
        BL  generateBoard

        ADR R0, board
        BL printBoard
        SWI 2

; printBoard -- print the board 
; Input: R0 <-- Address of board
printBoard
        ; Copy your implementation of printBoard here from the firsrt exercise

	STMFD R13!, {R3-R5, R14}

		MOV R4,#0 ; rowcounter
		MOV R5,#0 ; colcounter
		MOV R3,R0 ; board address

		ADR R0,row1
		SWI 3
		ADRL R0,nl
		SWI 3
		
pay		MOV R0,#65
		SWI 0
		
pr		MOV R0,#32
		SWI 0
		SWI 0
		SWI 0
		SWI 0

		LDR R0,[R3]
		ADD R0,R0,#65
		SWI 0
		ADD R3,R3,#4

		ADD R4,R4,#1
		CMP R4,#4
		BLT pr

		ADRL R0,nl
		SWI 3
		SWI 3
		ADD R5,R5,#1
		
		CMP R5,#1
		BEQ pbee
		
		CMP R5,#2
		BEQ pcee
		
		CMP R5,#3
		BEQ pdee
		
		CMP R5,#4
		BEQ kla
		
pbee		MOV R0,#66
		SWI 0
		MOV R4,#0
	B pr
		
pcee		MOV R0,#67
		SWI 0
		MOV R4,#0
	B pr
		
pdee		MOV R0,#68
		SWI 0
		MOV R4,#0
	B pr

kla     LDMFD R13!, {R3-R5, PC}
	
; generateBoard
; Input R0 -- array to generate board in
generateBoard
     ; Copy and convert your generateBoard routine into a subroutine here

	STMFD R13!, {R4-R9, R14}

	MOV R4,#0 ; iloop counter (i)
	MOV R5,#0 ; jloop counter (j)
	MOV R6,#4 ; to multiply by
	MOV R7,#0 ; offset
	MOV R8,#0 ; board[offset]
	MOV R9,R0 ; board address
iloop
	MOV R5,#0
jloop
justdoit
	BL randu
	MOV R0, R0 ASR #8
	AND R0, R0, #0xf
	MUL R7,R0,R6
	MOV R0,R7
	LDRB R8,[R9,R7]
	CMP R8,#255
	BNE justdoit
	STR R4,[R9,R7]

	ADD R5,R5,#1
	CMP R5,#2
BLT jloop
	ADD R4,R4,#1
	CMP R4,#8
BLT iloop
	LDMFD R13!, {R4-R9, PC}

; randu -- Generates a random number
; Input: None
; Ouptut: R0 -> Random number
randu
        ; Copy your implementation of randu from the previous coursework here

	STMFD R13!, {R1-R5, R14}

	LDR R1,seed
	LDR R2,magic
	LDR R3,mask
		
	MUL R4,R1,R2
	AND R5,R4,R3
		
	MOV R0,R5	
	STR R5,seed

	LDMFD R13!, {R1-R5,PC}
