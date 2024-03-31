COMMENT @
	EMPTY:			00h

	BLACK: 	PAWN: 	'b'
			QUEEN: 	02h (à changer)

	WHITE: 	PAWN: 	'w'
			QUEEN: 	04h (à changer)
@
board_init MACRO board
	LOCAL L1, L2, L3
	LEA SI, board

	MOV CX, 20
	L1:
		MOV BYTE PTR [SI], 'b'
		INC SI
	LOOP L1
	
	MOV CX, 10
	L2:
		MOV BYTE PTR [SI], 0
		INC SI
	LOOP L2

	MOV CX, 20
	L3:
		MOV BYTE PTR [SI], 'w'
		INC SI
	LOOP L3
ENDM
