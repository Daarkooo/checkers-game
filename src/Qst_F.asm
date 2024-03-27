.MODEL SMALL

STACK SEGMENT PARA STACK
	DB 64 DUP (0)
STACK ENDS

.DATA
	myBoard DB 50 DUP (0)

.CODE
;		EMPTY:			00h

;		BLACK: 	PAWN: 	'b'
;				QUEEN: 	02h

;		WHITE: 	PAWN: 	'w'
;				QUEEN: 	04h
	board_init MACRO
		LEA SI, myBoard

		MOV CX, 20
		L1:
			MOV BYTE PTR [SI], 'b'
			INC SI
		LOOP L1
		
		MOV CX, 10
		L2:
			MOV BYTE PTR [SI], 'w'
			INC SI
		LOOP L2

		MOV CX, 20
		L3:
			MOV BYTE PTR [SI], 02h
			INC SI
		LOOP L3
		RET
	ENDM

	main PROC FAR
		
        MOV AX, @DATA
        MOV DS, AX
		
		board_init

		MOV AH ,4Ch
		INT 21h        
        
		RET
	main ENDP
END
