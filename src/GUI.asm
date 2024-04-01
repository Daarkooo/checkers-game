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

__drawBoard PROC ; whiteCell, blackCell, size (last parameteres are top of stack)
	PUSH BP
	MOV BP, SP
	SUB SP, 2
	
	MOV AX, [BP + 4]    ; size
	MOV BX, 10
	MUL BX
	
	MOV [BP - 2], AX    ; final x, y
	
	XOR CX, CX          ; initial y
	MOV BX, [BP + 4]
	outer_loop:
	  XOR DX, DX      ; initial x
	
	  inner_loop1:
		  MOV AX, [BP + 8]        ; white color
		  drawCell AX, DX, CX, BX
		  ADD DX, BX
	
		  MOV AX, [BP + 6]        ; black color
		  drawCell AX, DX, CX, BX
		  ADD DX, BX
	
		  CMP DX, [BP - 2]
	  JL inner_loop1
	
	  XOR DX, DX
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
	  CMP CX, [BP - 2]
	JL outer_loop
	
	MOV SP, BP
	POP BP
	RET 6
__drawBoard ENDP

drawBoard MACRO whiteColor, blackColor, size
	MOV AX, whiteColor
	PUSH AX
	
	MOV AX, blackColor
	PUSH AX
	
	MOV AX, size
	PUSH AX
	
	CALL __drawBoard
ENDM
