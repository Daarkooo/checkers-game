.DATA
    xArray  DW  2, 3, 2, 5 DUP(1), 0, 1, 2 DUP(0), 1, 0, 0

.CODE
	__drawCell PROC ; color, x, y, size  (last parameteres are top of stack)
		PUSH BP
		MOV BP, SP
		SUB SP, 4

		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX

		MOV AL, BYTE PTR [BP + 10]
		MOV AH, 0Ch

		MOV BX, [BP + 4]
		ADD BX, [BP + 6]
		MOV [BP - 2], BX        ; final y

		MOV BX, [BP + 4]
		ADD BX, [BP + 8]
		MOV [BP - 4], BX        ; final x

		MOV DX, [BP + 6]        ; initial y
		MOV CX, [BP + 8]        ; initial x

		XOR BH, BH
		L1:
		MOV CX, [BP + 8]    ; reseting the x
		L2:
		INT 10h
		INC CX

		CMP CX, [BP - 4]
		JLE L2

		INC DX
		CMP DX, [BP - 2]
		JLE L1

		POP DX
		POP CX
		POP BX
		POP AX

		MOV SP, BP
		POP BP
		RET 8                   ; cleaning the stack
	__drawCell ENDP

	drawCell MACRO color, x, y, size
		MOV AX, color
		PUSH AX

		MOV AX, x
		PUSH AX

		MOV AX, y
		PUSH AX

		MOV AX, size
		PUSH AX

		CALL __drawCell
	ENDM

	__drawBoard PROC ; initialX, initialY, whiteCell, blackCell, size (last parameteres are top of stack)
		PUSH BP
		MOV BP, SP
		SUB SP, 4

		; getting the final X
		MOV AX, [BP + 4]        ; size
		MOV BX, 10
		MUL BX

		ADD AX, [BP + 12]
		MOV [BP - 2], AX        ; final X

		; getting the final Y
		MOV AX, [BP + 4]        ; size
		MOV BX, 10
		MUL BX

		ADD AX, [BP + 10]
		MOV [BP - 4], AX        ; final Y


		MOV CX, [BP + 10]       ; initial y
		MOV BX, [BP + 4]
		outer_loop:
			MOV DX, [BP + 12]       ; initial x

			inner_loop1:
				MOV AX, [BP + 8]        ; white color
				drawCell AX, DX, CX, BX
				ADD DX, BX

				MOV AX, [BP + 6]        ; black color
				drawCell AX, DX, CX, BX
				ADD DX, BX

				CMP DX, [BP - 2]
			JL inner_loop1

			MOV DX, [BP + 12]
			ADD CX, BX
			inner_loop2:
				MOV AX, [BP + 6]        ; black color
				drawCell AX, DX, CX, BX
				ADD DX, BX

				MOV AX, [BP + 8]        ; white color
				drawCell AX, DX, CX, BX
				ADD DX, BX

				CMP DX, [BP - 2]
			JL inner_loop2


			ADD CX, BX
			CMP CX, [BP - 4]
		JL outer_loop

		MOV SP, BP
		POP BP
		RET 10
	__drawBoard ENDP

	drawBoard MACRO initialX, initialY, whiteColor, blackColor, size
		MOV AX, initialX
		PUSH AX

		MOV AX, initialY
		PUSH AX

		MOV AX, whiteColor
		PUSH AX

		MOV AX, blackColor
		PUSH AX

		MOV AX, size
		PUSH AX

		CALL __drawBoard
	ENDM

	__drawHorizontalLine PROC ; color, startingX, Y, distance
		PUSH BP
		MOV BP, SP
		SUB SP, 2

		; column to stop at
		MOV AX, [BP + 8]
		ADD AX, [BP + 4]
		MOV [BP - 2], AX

		MOV AH, 0Ch
		MOV AL, BYTE PTR [BP + 10]
		MOV CX, [BP + 8]
		MOV DX, [BP + 6]
		XOR BX, BX

		__drawHorizontalLine_L1:
			INT 10h
			INC CX
			CMP CX, [BP - 2]
		JL __drawHorizontalLine_L1

		MOV SP, BP
		POP BP
		RET 8
	__drawHorizontalLine ENDP

	drawHorizontalLine MACRO color, startingX, Y, distance
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX

		MOV AX, color
		PUSH AX

		MOV AX, startingX
		PUSH AX

		MOV AX, Y
		PUSH AX

		MOV AX, distance
		PUSH AX

		CALL __drawHorizontalLine

		POP DX
		POP CX
		POP BX
		POP AX
	ENDM

	__drawCircle PROC ; color, initialX, initialY (last parameters top of stack)
		PUSH BP
		MOV BP, SP

		; [BP + 4] initialY
		; [BP + 6] initialX
		; [BP + 8] color

		MOV CX, [BP + 6]
		MOV DX, [BP + 4]
		SUB DX, 14

		XOR BX, BX
		XOR SI, SI
		__drawCircle_L1:
			MOV AX, [BP + 8]
			SUB CX, xArray[SI]      ; new X

			ADD BX, xArray[SI]      ; distance is double
			ADD BX, xArray[SI]

			drawHorizontalLine AX, CX, DX, BX

			ADD SI, 2
			INC DX
			CMP SI, 30
		JL __drawCircle_L1

			SUB SI, 2

		__drawCircle_L2:
			MOV AX, [BP + 8]
			ADD CX, WORD PTR xArray[SI]      ; new X

			SUB BX, WORD PTR xArray[SI]      ; distance is double
			SUB BX, WORD PTR xArray[SI]

			drawHorizontalLine AX, CX, DX, BX

			SUB SI, 2
			INC DX
			TEST SI, SI
		JNZ __drawCircle_L2

		MOV SP, BP
		POP BP
		RET 6
	__drawCircle ENDP

	drawCircle MACRO color, initialX, initialY
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX

		MOV AX, color
		PUSH AX

		MOV AX, initialX
		PUSH AX

		MOV AX, initialY
		PUSH AX

		CALL __drawCircle

		POP DX
		POP CX
		POP BX
		POP AX
	ENDM