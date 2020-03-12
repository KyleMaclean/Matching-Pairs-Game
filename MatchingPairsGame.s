        B main

seed    DEFW    0x1234567
magic	DEFW	65539
mask	DEFW	0x7FFFFFFF
board	DEFW 	-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1

prompt	DEFB	"Enter square to reveal: ",0
match0	DEFB	"The revealed letters do not match\n",0
match1	DEFB	"Congratulations! The revealed letters match\n",0
press	DEFB	"Press any key to continue",0
row1	DEFB	"     1    2    3    4\n",0
nl	DEFB	"\n",0

        ALIGN
main    
	MOV R13,#0x10000

	ADRL R0,board
	MOV R1,#16	; first index to reveal (init out of range)
	MOV R2,#16	; second index to reveal (init out of range)
	MOV R3,#0	; number of correctly-matched pairs
	MOV R4,#0	; letter of R1 revealed
	MOV R5,#0	; letter of R2 revealed
	MOV R6,#4	; to multiply index to get offset
	MOV R7,#-1	; to replace values of correct matches
	MOV R8,#0	; board address backup

	BL generateBoard
mloop	
	MOV R1,#16
	MOV R2,#16
	BL clearScreen
	ADRL R0,board
	BL printMaskedBoard
	ADRL R0,prompt
	BL boardSquareInput
	MOV R1,R0
	BL clearScreen
	ADRL R0,board
	BL printMaskedBoard
	ADRL R0,prompt
	BL boardSquareInput
	MOV R2,R0
	BL clearScreen
	ADRL R0,board
	BL printMaskedBoard
	MUL R1,R1,R6
	MUL R2,R2,R6
	LDR R4,[R0,R1]
	LDR R5,[R0,R2]
	MOV R8,R0
	CMP R4,R5
	BEQ success
	ADRL R0,match0
	SWI 3
	ADRL R0,press
	SWI 3
	SWI 1
	B mloop
success
	STR R7,[R8,R1]
	STR R7,[R8,R2]
	ADD R3,R3,#1
	ADRL R0,match1
	SWI 3
	ADRL R0,press
	SWI 3
	SWI 1
	CMP R3,#8
	BNE mloop
	
        SWI 2

; cls -- Clears the Screen
; Input : None
; Ouptut: None
clearScreen

	STMFD R13!, {R4,R14}

	MOV R4,#800
	MOV R0,#8
xloop
	SWI 0
	SUBS R4,R4, #1
	BNE xloop

	LDMFD R13!, {R4,PC}

; boardSquareInput -- read the square to reveal from the Keyboard
; Input:  R0 <- address of prompt for user
; Output: R0 <- Array index of entered square
boardSquareInput

	STMFD R13!, {R4-R7,R14}	
	
	MOV R4,R0	; prompt address saved
	MOV R5,#0
	MOV R6,#4	; max columns
	MOV R7,#0
start
	MOV R0,R4	; prompt address loaded
	SWI 3
	SWI 1
	CMP R0,#97
	BLT com
	SUB R0,R0,#32	
com
	SUB R0,R0,#65
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

; generateBoard
; Input R0 -- array to generate board in
generateBoard

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
	LDR R8,[R9,R7]
	CMP R8,#-1
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
        STMFD R13!, {R1-R5, R14}

	LDR R1,seed
	LDR R2,magic
	LDR R3,mask
	MUL R4,R1,R2
	AND R5,R4,R3	
	MOV R0,R5	
	STR R5,seed

	LDMFD R13!, {R1-R5,PC}

; printMaskedBoard -- print the board with only the squares in R1 and R2 visible
; Input: R0 <-- Address of board
;        R1 <-- Number of Cell to reveal
;        R2 <-- Number of Cell to reveal
printMaskedBoard
        
	STMFD R13!, {R4-R7, R14}

	MOV R4,#0 ; rowcounter
	MOV R5,#0 ; colcounter
	MOV R6,#0 ; cellcounter
	MOV R7,R0 ; board address

	ADRL R0,row1
	SWI 3
	ADRL R0,nl
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
	B cover
reveal
	LDR R0,[R7]
	CMP R0,#-1
	BEQ gap
	ADD R0,R0,#65
	SWI 0
	B cont
cover	
	LDR R0,[R7]
	CMP R0,#-1
	BNE ast
gap
	MOV R0,#32
	SWI 0
	B cont
ast
	MOV R0,#42
	SWI 0
cont
	ADD R7,R7,#4
	ADD R6,R6,#1
	ADD R4,R4,#1
	CMP R4,#4
	BLT pr
	ADRL R0,nl
	SWI 3
	ADD R5,R5,#1
	ADRL R0,nl
	SWI 3	
	CMP R5,#1
	BEQ pbee
	CMP R5,#2
	BEQ pcee
	CMP R5,#3
	BEQ pdee	
	CMP R5,#4
	BEQ fin	
pbee
	MOV R0,#66
	SWI 0
	MOV R4,#0
	B pr	
pcee
	MOV R0,#67
	SWI 0
	MOV R4,#0
	B pr		
pdee
	MOV R0,#68
	SWI 0
	MOV R4,#0
	B pr
fin
	ADRL R0,board
	LDMFD R13!, {R4-R7, PC}
