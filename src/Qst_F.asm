.MODEL SMALL

STACK SEGMENT PARA STACK
	DB 64 DUP (0)
STACK ENDS

DATA SEGMENT
	myBoard DB 50 DUP (0)
DATA ENDS

CODE SEGMENT
;		EMPTY:			00h

;		BLACK: 	PAWN: 	'b'
;				QUEEN: 	02h

;		WHITE: 	PAWN: 	'w'
;				QUEEN: 	04h
	board_init MACRO board
		XOR SI, SI

		MOV CX, 20
		L1:
			MOV board[SI], 'b'
			INC SI
		LOOP L1
		
		MOV CX, 10
		L2:
			MOV board[SI], 'w'
			INC SI
		LOOP L2

		MOV CX, 20
		L3:
			MOV board[SI], 02h
			INC SI
		LOOP L3
	ENDM

	MAIN PROC FAR
		
        MOV AX, @DATA
        MOV DS, AX
		
		board_init OFFSET myBoard		

		MOV AH ,4Ch
		INT 21h        
        
		RET
	main ENDP
CODE ENDS
END