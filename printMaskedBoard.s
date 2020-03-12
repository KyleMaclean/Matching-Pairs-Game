        B main

board	DEFW 	3, 1, 4, 7, 5, 1, 7, 6, 6, 0, 2, 5, 0, 4, 2, 3
row1	DEFB	"     1    2    3    4\n",0
nl		DEFB	"\n",0

	ALIGN
main    MOV R13, #0x10000
	ADR R0, board 
        MOV R1, #3
        MOV R2, #5
        BL printMaskedBoard
        SWI 2

; printMaskedBoard -- print the board with only the squares in R1 and R2 visible
; Input: R0 <-- Address of board
;        R1 <-- Number of Cell to reveal
;        R2 <-- Number of Cell to reveal
printMaskedBoard
; Insert your implementation of printMaskedBoard here.

	STMFD R13!, {R4-R7, R14}

	MOV R4,#0 ; rowcounter
	MOV R5,#0 ; colcounter
	MOV R6,#0 ; cellcounter
	MOV R7,R0 ; board address

	ADR R0,row1
	SWI 3
	ADR R0,nl
	SWI 3
		
pay
	MOV R0,#65
	SWI 0		
		
pr
	MOV R0,#32
	SWI 0
	SWI 0
	SWI 0
	SWI 0
	CMP R6,R1
	BEQ reveal
	CMP R6,R2
	BEQ reveal
	B mask

reveal
	LDR R0,[R7]
	CMP R0,#-1
	BEQ gap
	ADD R0,R0,#65
	SWI 0
	B cont

mask	LDR R0,[R7]
	CMP R0,#-1
	BNE ast

gap	MOV R0,#32
	SWI 0
	B cont

ast	MOV R0,#42
	SWI 0

cont	ADD R7,R7,#4
	ADD R6,R6,#1
	ADD R4,R4,#1
	CMP R4,#4
	BLT pr
	ADR R0,nl
	SWI 3
	ADD R5,R5,#1
	ADR R0,nl
	SWI 3
		
	CMP R5,#1
	BEQ pbee
	
	CMP R5,#2
	BEQ pcee
	
	CMP R5,#3
	BEQ pdee
		
	CMP R5,#4
	BEQ fin
		
pbee	MOV R0,#66
	SWI 0
	MOV R4,#0
	B pr
		
pcee	MOV R0,#67
	SWI 0
	MOV R4,#0
	B pr
		
pdee	MOV R0,#68
	SWI 0
	MOV R4,#0
	B pr
	ADR R0, board

fin	LDMFD R13!, {R4-R6, R7, PC}
