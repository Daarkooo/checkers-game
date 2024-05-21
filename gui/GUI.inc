.DATA
    xArray28        DW      2, 3, 2, 5 DUP(1), 0, 1, 2 DUP(0), 1, 2 DUP(0)
    xArray14        DW      2, 2, 2 DUP(1), 0, 1, 0
    xArray11        DW      1, 2, 1, 0, 1
    cellSize        EQU     34
    cellSize2       EQU     17
    offsetX         EQU     0
    offsetY         EQU     0

.CODE

    



    PushReg MACRO
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
    ENDM

    PopReg MACRO
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
    ENDM

    ; *************************************************************************************************************
        get_column MACRO n,result
            LOCAL not_eqaul_zero, not_less_than_6, end

            MOV AL, n
            XOR AH, AH
            MOV BL, 10
            DIV BL    ; divide AL by BL, q -> AL, r -> AH

            ; check if x == 0
            CMP AH, 0
            JNE not_eqaul_zero
            MOV AL, 8 ; return 8
            JMP end
            not_eqaul_zero:

                ; check if x < 6
                CMP AH, 6
                JGE not_less_than_6
                MOV AL, AH
                SHL AL, 1
                DEC AL ; retrun ah * 2 -1
                JMP end
            not_less_than_6:

                ; x >= 6
                MOV AL, AH
                SUB AL, 5
                SHL AL, 1
                DEC AL
                DEC AL  ; return (ah-5)*2-1

            end:
                MOV result,AL

        ENDM

        getRow MACRO Num, result
            LOCAL errorLabel, endLabel
            XOR AX, AX

            MOV AL, Num

            TEST AL, AL
            JZ errorLabel

            CMP AL, 50
            JA errorLabel

            DEC AL
            MOV BL, 5
            DIV BL
            JMP endLabel

            errorLabel:
                MOV AL, -1

            endLabel:
                MOV result, AL
        ENDM

        getNumber MACRO row, column, Num
            LOCAL calculate_number, fin

                ; (row % 2 === column % 2)
                MOV AL, column
                AND AL, 01h
                MOV AH, row
                AND AH, 01h
                CMP AL, AH
                jnz calculate_number  ; not a White Square
            
                ; White square
                mov Num, 0
                jmp fin
            
            calculate_number:
            
                ; Calculate the number
                XOR AX, AX
                mov al, row
                mov bl, 5
                mul bl  ; AL = row * 5
                mov bl, column
                shr bl, 1  ; Divide column by 2 
                add al, bl  ; AL = AL + (column / 2)
                inc al  ;the index starts from 0
            
                ; Store the number
                mov Num, al
            fin: 
        ENDM
    ; *************************************************************************************************************

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
		PushReg

		MOV AX, color
		PUSH AX

		MOV AX, startingX
		PUSH AX

		MOV AX, Y
		PUSH AX

		MOV AX, distance
		PUSH AX

		CALL __drawHorizontalLine

		popReg
	ENDM

    __drawVerticalLine PROC ; color, X, startingY, distance
        PUSH BP
        MOV BP, SP
        SUB SP, 2

        ; row to stop at
        MOV AX, [BP + 6]
        ADD AX, [BP + 4]
        MOV [BP - 2], AX

        MOV AH, 0Ch
        MOV AL, BYTE PTR [BP + 10]
        MOV CX, [BP + 8]
        MOV DX, [BP + 6]
        XOR BX, BX

        __drawVerticalLine_L1:
            INT 10h
            INC DX
            CMP DX, [BP - 2]
        JL __drawVerticalLine_L1

        MOV SP, BP
        POP BP
        RET 8
    __drawVerticalLine ENDP

    drawVerticalLine MACRO color, X, startingY, distance
        PushReg

        MOV AX, color
        PUSH AX

        MOV AX, X
        PUSH AX

        MOV AX, startingY
        PUSH AX

        MOV AX, distance
        PUSH AX

        CALL __drawVerticalLine

        PopReg
    ENDM

    __drawRectangle PROC ; initialX, initialY, width, height, color
        PUSH BP
        MOV BP, SP

        ; [BP +  4]: color
        ; [BP +  6]: height
        ; [BP +  8]: width
        ; [BP + 10]: initialY
        ; [BP + 12]: initialX

        MOV SI, [BP + 12]
        MOV DX, [BP + 10]
        MOV BX, [BP +  8]
        MOV AX, [BP +  4]
        MOV CX, [BP +  6]

        __drawRectangle_L1:
            drawHorizontalLine AX, SI, DX, BX
            INC DX
        LOOP __drawRectangle_L1

        MOV SP, BP
        POP BP
        RET 10
    __drawRectangle ENDP

    drawRectangle MACRO initialX, initialY, width, height, color
        PushReg

        MOV AX, initialX
        PUSH AX

        MOV AX, initialY
        PUSH AX

        MOV AX, width
        PUSH AX

        MOV AX, height
        PUSH AX

        MOV AX, color
        PUSH AX

        CALL __drawRectangle

        popReg
    ENDM

	__drawCell PROC ; color, initialX, initialY, size  (last parameteres are top of stack)
		PUSH BP
		MOV BP, SP

        ; [BP +  4]: size
        ; [BP +  6]: initialY
        ; [BP +  8]: initialX
        ; [BP + 10]: color
        pushReg

        MOV AX, [BP + 8]
        MOV DX, [BP + 6]
        MOV CX, [BP + 10]
        MOV BX, [BP + 4]

        drawRectangle AX, DX, BX, BX, CX

        popReg
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

        ; [BP +  4]: size
        ; [BP +  6]: blackCell
        ; [BP +  8]: whiteCell
        ; [BP + 10]: initialY
        ; [BP + 12]: initialX

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

	drawBoard MACRO initialX, initialY, whiteCellColor, blackCellColor, size
        PushReg

		MOV AX, initialX
		PUSH AX

		MOV AX, initialY
		PUSH AX

		MOV AX, whiteCellColor
		PUSH AX

		MOV AX, blackCellColor
		PUSH AX

		MOV AX, size
		PUSH AX

		CALL __drawBoard

        popReg
	ENDM

	__drawCircle28 PROC ; color, initialX, initialY (last parameters top of stack)
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
		__drawCircle28_L1:
			MOV AX, [BP + 8]
			SUB CX, xArray28[SI]      ; new X

			ADD BX, xArray28[SI]      ; distance is double
			ADD BX, xArray28[SI]

			drawHorizontalLine AX, CX, DX, BX

			ADD SI, 2
			INC DX
			CMP SI, 30
		JL __drawCircle28_L1

			SUB SI, 2

		__drawCircle28_L2:
			MOV AX, [BP + 8]
			ADD CX, WORD PTR xArray28[SI]      ; new X

			SUB BX, WORD PTR xArray28[SI]      ; distance is double
			SUB BX, WORD PTR xArray28[SI]

			drawHorizontalLine AX, CX, DX, BX

			SUB SI, 2
			INC DX
			TEST SI, SI
		JNZ __drawCircle28_L2

		MOV SP, BP
		POP BP
		RET 6
	__drawCircle28 ENDP


    ; ;! ALL PARAMETRES EXCEPT 'cellNumber' ARE 16-BITS
    ; __drawQueen PROC ; cellNumber, xOffset, yOffset, cellSize, outerColor, innerColor
    ;     PUSH BP
    ;     MOV BP, SP
    ;     SUB SP, 4

    ;     ; * [BP +  4]: innerColor
    ;     ; * [BP +  6]: outerColor
    ;     ; * [BP +  8]: cellSize
    ;     ; * [BP + 10]: yOffset
    ;     ; * [BP + 12]: xOffset
    ;     ; * [BP + 14]: cellNumber

    ;     ; * [BP -  2]: real X (columns in px)
    ;     ; * [BP -  4]: real Y (row in px)

    ;     MOV AX, [BP + 14]
    ;     get_column AL, AL       ; send N in AL and get the column in AL
    ;     XOR AH, AH
    ;     XOR DX, DX
    ;     MOV BX, [BP + 8]
    ;     MUL BX
    ;     ADD AX, [BP + 12]
    ;     MOV [BP - 2], AX

    ;     MOV BX, [BP + 14]
    ;     getRow BL, AL       ; send N in AL and get the column in AL
    ;     XOR AH, AH
    ;     XOR DX, DX
    ;     MOV BX, [BP + 8]
    ;     MUL BX
    ;     ADD AX, [BP + 10]
    ;     MOV [BP - 4], AX

    ;     ; Get the center
    ;     MOV CX, [BP + 8]
    ;     SHR CX, 1
    ;     ADD [BP - 4], CX
    ;     ADD [BP - 2], CX

    ;     MOV AX, [BP + 6]
    ;     MOV CX, [BP - 2]
    ;     MOV DX, [BP - 4]
    ;     drawCircle AX, CX, DX

    ;     MOV AX, [BP + 4]
    ;     MOV CX, [BP - 2]
    ;     MOV DX, [BP - 4]
    ;     drawCircle14 AX, CX, DX

    ;     MOV SP, BP
    ;     POP BP
    ;     RET 12
    ; __drawQueen ENDP

    ; drawQueen MACRO cellNumber, xOffset, yOffset, cellSize, outerColor, innerColor
    ;     pushReg

    ;     XOR AX, AX
    ;     MOV AL, cellNumber
    ;     PUSH AX

    ;     MOV AX, xOffset
    ;     PUSH AX

    ;     MOV AX, yOffset
    ;     PUSH AX

    ;     MOV AX, cellSize
    ;     PUSH AX

    ;     MOV AX, outerColor
    ;     PUSH AX

    ;     MOV AX, innerColor
    ;     PUSH AX

    ;     CALL __drawQueen

    ;     popReg
    ; ENDM


	drawCircle MACRO color, initialX, initialY
		PushReg

		MOV AX, color
		PUSH AX

		MOV AX, initialX
		PUSH AX

		MOV AX, initialY
		PUSH AX

		CALL __drawCircle28

		popReg
	ENDM

    __drawCircle14 PROC ; color, initialX, initialY (last parameters top of stack)
		PUSH BP
		MOV BP, SP

		; [BP + 4] initialY
		; [BP + 6] initialX
		; [BP + 8] color

		MOV CX, [BP + 6]
		MOV DX, [BP + 4]
		SUB DX, 7

		XOR BX, BX
		XOR SI, SI
		__drawCircle14_L1:
			MOV AX, [BP + 8]           ;
			SUB CX, xArray14[SI]      ; new X

			ADD BX, xArray14[SI]      ; distance is double
			ADD BX, xArray14[SI]

			drawHorizontalLine AX, CX, DX, BX

			ADD SI, 2
			INC DX
			CMP SI, 14
		JL __drawCircle14_L1

			SUB SI, 2

		__drawCircle14_L2:
			MOV AX, [BP + 8]
			ADD CX, WORD PTR xArray14[SI]      ; new X

			SUB BX, WORD PTR xArray14[SI]      ; distance is double
			SUB BX, WORD PTR xArray14[SI]

			drawHorizontalLine AX, CX, DX, BX

			SUB SI, 2
			INC DX
			TEST SI, SI
		JNZ __drawCircle14_L2

		MOV SP, BP
		POP BP
		RET 6
	__drawCircle14 ENDP

    drawCircle14 MACRO color, initialX, initialY
		PushReg

		MOV AX, color
		PUSH AX

		MOV AX, initialX
		PUSH AX

		MOV AX, initialY
		PUSH AX

		CALL __drawCircle14

		popReg
	ENDM

    __drawCircle11 PROC ; color, initialX, initialY (last parameters top of stack)
		PUSH BP
		MOV BP, SP

		; [BP + 4] initialY
		; [BP + 6] initialX
		; [BP + 8] color

		MOV CX, [BP + 6]
		MOV DX, [BP + 4]
		SUB DX, 5

		XOR BX, BX
		XOR SI, SI
		__drawCircle11_L1:
			MOV AX, [BP + 8]
			SUB CX, xArray11[SI]      ; new X

			ADD BX, xArray11[SI]      ; distance is double
			ADD BX, xArray11[SI]

			drawHorizontalLine AX, CX, DX, BX

			ADD SI, 2
			INC DX
			CMP SI, 10
		JL __drawCircle11_L1

			SUB SI, 2

		__drawCircle11_L2:
			MOV AX, [BP + 8]
			ADD CX, WORD PTR xArray11[SI]      ; new X

			SUB BX, WORD PTR xArray11[SI]      ; distance is double
			SUB BX, WORD PTR xArray11[SI]

			drawHorizontalLine AX, CX, DX, BX

			SUB SI, 2
			INC DX
			TEST SI, SI
		JNZ __drawCircle11_L2

		MOV SP, BP
		POP BP
		RET 6
	__drawCircle11 ENDP

    drawCircle11 MACRO color, initialX, initialY
		PushReg

		MOV AX, color
		PUSH AX

		MOV AX, initialX
		PUSH AX

		MOV AX, initialY
		PUSH AX

		CALL __drawCircle11

		popReg
	ENDM

    setCursorPosition MACRO row, column, page
        MOV AX, 0200h
        MOV BH, page
        MOV DL, column
        MOV DH, row
        INT 10H
    ENDM

    __printGraphicalString PROC ; ref, color, initialX, initialY ; page implicitely set to 0
        PUSH BP
        MOV BP, SP

        ; [BP + 10]: ref
        ; [BP +  8]: color
        ; [BP +  6]: initialX
        ; [BP +  4]: initialY

        MOV SI, [BP + 10]
        MOV BX, [BP + 8]
        MOV DL, BYTE PTR [BP + 6]
        MOV DH, BYTE PTR [BP + 4]

        __printGraphicalString_L1:
            setCursorPosition DH, DL, 0

            MOV AH, 0Ah
            MOV AL, BYTE PTR [SI]
            XOR BH, BH
            MOV CX, 1

            INT 10h
            INC SI
            INC DL

            MOV AL, BYTE PTR [SI]
            CMP AL, '$'
        JNZ __printGraphicalString_L1

        MOV SP, BP
        POP BP
        RET 8
    __printGraphicalString ENDP

    printGraphicalString MACRO ref, color, initialX, initialY ; page should be kept 0, for now at least
        LEA AX, ref
        PUSH AX

        MOV AX, color
        PUSH AX

        MOV AX, initialX
        PUSH AX

        MOV AX, initialY
        PUSH AX

        CALL __printGraphicalString
    ENDM

    __drawBorder PROC ; color, startX, startY, distance, width
        PUSH BP
        MOV BP, SP

        ; [BP +  4]: width
        ; [BP +  6]: distance
        ; [BP +  8]: startY
        ; [BP + 10]: startX
        ; [BP + 12]: color

        ; Upper and left border
        MOV CX, [BP +  4]       ; width (times to run the loop)
        MOV SI, [BP +  6]       ; distance
        MOV DX, [BP +  8]       ; startY
        MOV BX, [BP + 10]       ; startX
        MOV AX, [BP + 12]       ; color

        ADD SI, 2
        DEC DX
        DEC BX

        __drawBorder_upperLeftBorder:
            drawHorizontalLine AX, BX, DX, SI
            drawVerticalLine AX, BX, DX, SI
            ADD SI, 2
            DEC DX
            DEC BX
        LOOP __drawBorder_upperLeftBorder

        ; Right border
        MOV CX, [BP +  4]       ; width (times to run the loop)
        MOV SI, [BP +  6]       ; distance
        MOV DX, [BP +  8]       ; startY
        MOV BX, [BP + 10]       ; startX
        MOV AX, [BP + 12]       ; color

        ADD BX, SI
        DEC DX
        ADD SI, 2

        __drawBorder_rightBorder:
            drawVerticalLine AX, BX, DX, SI
            ADD SI, 2
            DEC DX
            INC BX
        LOOP __drawBorder_rightBorder

        ; Lower border
        MOV CX, [BP +  4]       ; width (times to run the loop)
        MOV SI, [BP +  6]       ; distance
        MOV DX, [BP +  8]       ; startY
        MOV BX, [BP + 10]       ; startX
        MOV AX, [BP + 12]       ; color

        ADD DX, SI
        DEC BX
        ADD SI, 2

        __drawBorder_lowerBorder:
            drawHorizontalLine AX, BX, DX, SI
            ADD SI, 2
            INC DX
            DEC BX
        LOOP __drawBorder_lowerBorder

        MOV SP, BP
        POP BP
        RET 10
    __drawBorder ENDP

    drawBorder MACRO color, startX, startY, distance, width
        pushReg

        MOV AX, color
        PUSH AX

        MOV AX, startX
        PUSH AX

        MOV AX, startY
        PUSH AX

        MOV AX, distance
        PUSH AX

        MOV AX, width
        PUSH AX

        CALL __drawBorder

        popReg
    ENDM

    ; -----------------------------------------------
    
    __drawBorderCell PROC; N, color, xOffset, yOffset, cellSize
        PUSH BP
        MOV BP, SP
        SUB SP, 4

        ; [BP + 12] N
        ; [BP + 10] color
        ; [BP +  8] xOffset
        ; [BP +  6] yOffset
        ; [BP +  4] cellSize

        ; [BP -  2] column (x)
        ; [BP -  4] row (y)

        ; got column (x)
        MOV BL, BYTE PTR [BP + 12]
        get_column BL, AL
        XOR AH, AH
        MOV [BP - 2], AX

        ; got row (y)
        MOV BL, BYTE PTR [BP + 12]
        getRow BL, AL
        XOR AH, AH
        MOV [BP - 4], AX

        ; initial column (px)
        MOV AX, [BP - 2]
        MOV BX, [BP + 4]
        XOR DX, DX
        MUL BX
        ADD AX, [BP + 8]
        MOV CX, AX

        ; initial row (px)
        MOV AX, [BP - 4]
        MOV BX, [BP + 4]
        XOR DX, DX
        MUL BX
        ADD AX, [BP + 6]
        MOV DX, AX

        ; Upper border
        MOV AX, [BP + 10]
        MOV BX, [BP + 4]
        drawHorizontalLine AX, CX, DX, BX
        INC DX
        drawHorizontalLine AX, CX, DX, BX       ; 2 pixels
        DEC DX

        ; Left border
        drawVerticalLine AX, CX, DX, BX
        INC CX
        drawVerticalLine AX, CX, DX, BX
        DEC CX

        ; Right border
        ADD CX, [BP + 4]
        drawVerticalLine AX, CX, DX, BX
        DEC CX
        drawVerticalLine AX, CX, DX, BX         ; 2 pixels
        INC CX

        ; Lower border
        ADD DX, [BP + 4]
        SUB CX, [BP + 4]
        drawHorizontalLine AX, CX, DX, BX
        DEC DX
        drawHorizontalLine AX, CX, DX, BX
        INC DX

        MOV SP, BP
        POP BP
        RET 10
    __drawBorderCell ENDP

    drawBorderCell MACRO N, color, xOffset, yOffset, cellSize 
        PushReg
        
        xor ah,ah
        xor bh,bh

        MOV AL, N
        PUSH AX

        MOV AL, color
        PUSH AX

        MOV AL, xOffset
        PUSH AX

        MOV AL, yOffset
        PUSH AX

        MOV AL, cellSize
        PUSH AX

        CALL __drawBorderCell

        popReg
    ENDM

    __setMousePosition PROC
        PUSH BP
        MOV BP, SP

        ; [BP + 4]: y (row)
        ; [BP + 6]: x (column)

        MOV AX, 0004h
        MOV CX, [BP + 6]
        MOV DX, [BP + 4]
        INT 33h

        MOV SP, BP
        POP BP
        RET 4
    __setMousePosition ENDP

    setMousePosition MACRO x, y
        pushReg
        MOV AX, x
        PUSH AX

        MOV AX, y
        PUSH AX

        CALL __setMousePosition
        PopReg
    ENDM

    __markCell PROC ; color, xOffset, yOffset, cellSize, cellNumber
        PUSH BP
        MOV BP, SP
        SUB SP, 4

        ; [BP +  4]: cellNumber
        ; [BP +  6]: cellSize
        ; [BP +  8]: yOffset
        ; [BP + 10]: xOffset
        ; [BP + 12]: color

        ; [BP - 2]: cell's row
        ; [BP - 4]: cell's column

        ; Getting cell's row
        MOV BX, [BP +  4]
        getRow BL, AL
        XOR AH, AH
        MOV [BP - 2], AX

        ; Getting cell's column
        MOV BX, [BP +  4]
        get_column BL, AL
        XOR AH, AH
        MOV [BP - 4], AX

        ; Getting real x (column)
        XOR DX, DX
        MOV AX, [BP - 4]
        MOV BX, [BP + 6]
        MUL BX
        ADD AX, [BP + 10]
        MOV CX, AX

        MOV AX, [BP + 6]
        SHR AX, 1
        ADD CX, AX

        ; Getting real y (row)
        XOR DX, DX
        MOV AX, [BP - 2]
        MOV BX, [BP + 6]
        MUL BX
        ADD AX, [BP + 8]
        MOV DX, AX

        MOV AX, [BP + 6]
        SHR AX, 1
        ADD DX, AX

        MOV AX, [BP + 12]
        drawCircle11 AX, CX, DX

        MOV SP, BP
        POP BP
        RET 10
    __markCell ENDP

    markCell MACRO color, xOffset, yOffset, cellSize, cellNumber
        pushReg

        MOV AX, color
        PUSH AX

        MOV AX, xOffset
        PUSH AX

        MOV AX, yOffset
        PUSH AX

        MOV AX, cellSize
        PUSH AX

        MOV AX, cellNumber
        PUSH AX

        CALL __markCell

        popReg
    ENDM

    markCellsByArray MACRO array, color, 
        pushReg


        CALL __ markCellsByArray

        popREg
    ENDM

;! ********************************* ABDOU'S WORK *********************************
    Board_init_GUI Macro Board, blackCellColor, whiteCellColor, blackPieceColor, whitePieceColor
        drawBoard Offsetx, Offsety, whiteCellColor, blackCellColor, 34
        MOV CX,offsety
        ADD CX, 17

        Black:

            MOV DX,51
            ADD DX,Offsetx
            MOV BX,5
            Line0:
                PushReg
                drawCircle blackPieceColor,DX,CX
                PopReg
                ADD DX,68 ; 2 CASES
                DEC BX
                CMP BX,0
                JNZ Line0
            ; ADD CX, 34
            ; MOV DX, 17
            ; ADD DX,Offsetx
            ; MOV BX, 5
            ; Line1:
            ;     PushReg
            ;     drawCircle blackPieceColor,DX,CX
            ;     PopReg
            ;     ADD DX,68 ; 2 CASES
            ;     DEC BX
            ;     CMP BX,0
            ;     JNZ Line1
            ; ADD CX, 34
            ; MOV DX, 51
            ; ADD DX,Offsetx
            ; MOV BX, 5
            ; Line2:
            ;     PushReg
            ;     drawCircle blackPieceColor,DX,CX
            ;     PopReg
            ;     ADD DX,68 ; 2 CASES
            ;     DEC BX
            ;     CMP BX,0
            ;     JNZ Line2
            ; ADD CX, 34
            ; MOV DX, 16
            ; ADD DX,Offsetx
            ; MOV BX, 5
            ; Line3:
            ;     PushReg
            ;     drawCircle blackPieceColor,DX,CX
            ;     PopReg
            ;     ADD DX,68 ; 2 CASES
            ;     DEC BX
            ;     CMP BX,0
            ;     JNZ Line3

            ADD CX, 306 ; JUMP TO WHITE PART ;102
         White:

            ; MOV DX,51
            ; ADD DX,Offsetx
            ; MOV BX,5
            ; Line6:
            ;     PushReg
            ;     drawCircle whitePieceColor,DX,CX
            ;     PopReg
            ;     ADD DX,68 ; 2 CASES
            ;     DEC BX
            ;     CMP BX,0
            ;     JNZ Line6
            ; ADD CX, 34
            MOV DX, 17
            ADD DX,Offsetx
            MOV BX, 5
            Line7:
                PushReg
                drawCircle whitePieceColor,DX,CX
                PopReg
                ADD DX,68 ; 2 CASES
                DEC BX
                CMP BX,0
                JNZ Line7
            ; ADD CX, 34
            ; MOV DX, 51
            ; ADD DX,Offsetx
            ; MOV BX, 5
            ; Line8:
            ;     PushReg
            ;     drawCircle whitePieceColor,DX,CX
            ;     PopReg
            ;     ADD DX,68 ; 2 CASES
            ;     DEC BX
            ;     CMP BX,0
            ;     JNZ Line8
            ; ADD CX, 34
            ; MOV DX, 17
            ; ADD DX,Offsetx
            ; MOV BX, 5
            ; Line9:
            ;     PushReg
            ;     drawCircle whitePieceColor,DX,CX
            ;     PopReg
            ;     ADD DX,68 ; 2 CASES
            ;     DEC BX
            ;     CMP BX,0
            ;     JNZ Line9
    ENDM

    getRow MACRO Num, result
        LOCAL errorLabel, endLabel
        XOR AX, AX

        MOV AL, Num

        TEST AL, AL
        JZ errorLabel

        CMP AL, 50
        JA errorLabel

        DEC AL
        MOV BL, 5
        DIV BL
        JMP endLabel

        errorLabel:
            MOV AL, -1

        endLabel:
            MOV result, AL
    ENDM

    get_column MACRO n,result
        LOCAL not_eqaul_zero, not_less_than_6, fin

        MOV AL, n
        XOR AH, AH
        MOV BL, 10
        DIV BL    ; divide AL by BL, q -> AL, r -> AH

        ; check if x == 0
        CMP AH, 0
        JNE not_eqaul_zero
        MOV AL, 8 ; return 8
        JMP fin
        not_eqaul_zero:

            ; check if x < 6
            CMP AH, 6
            JGE not_less_than_6
            MOV AL, AH
            SHL AL, 1
            DEC AL ; retrun ah * 2 -1
            JMP fin
        not_less_than_6:

            ; x >= 6
            MOV AL, AH
            SUB AL, 5
            SHL AL, 1
            DEC AL
            DEC AL  ; return (ah-5)*2-1

        fin:
            MOV result,AL
    ENDM

    GetCase Macro x,y,R,C
            XOR AX, AX
            MOV AL, x
            MOV BL, cellSize
            MUL BL
            MOV R, AX

            XOR AX, AX
            MOV AL, y
            MOV BL, cellSize
            MUL BL
            MOV C, AX
    ENDM

    GetCenter Macro x,y,R,C ; call parametres (DL, CL, DX, CX)
            XOR AX, AX
            MOV AL, x
            MOV BL, cellSize
            MUL BL
            XOR BX, BX
            MOV BL, cellSize2
            ADD AX, BX
            MOV R, AX

            XOR AX, AX
            MOV AL, y
            MOV BL, cellSize
            MUL BL
            XOR BX, BX
            MOV BL, cellSize2
            ADD AX, BX
            MOV C, AX
    ENDM

    Move_GUI Macro n1,n2,PColor
        LOCAL MoveGui,MoveG,MoveD,MoveDownD,MoveTopD,MoveDownG,MoveTopG,FinMove,notMove1, notMove2, notMove3
        MoveGui:
            MOV AL,n1
            CMP AL,n2

            JNZ notMove1
            JMP FinMove
            notMove1:

            get_column n1,DL
            get_column n2,DH

            CMP DL,DH

            JL MoveD
            JMP MoveG

            MoveD:
                getRow n1,CL
                getRow n2,CH

                CMP CL,CH
                JAE MoveTopD

                MoveDownD:
                    CMP DL,DH
                    JNZ notMove2
                    JMP FinMove
                    notMove2:
                    PUSH DX
                    PUSH CX

                    GetCase DL,CL,DX, CX
                    drawCell 0006h, DX, CX, 34

                    POP CX
                    POP DX
                    ADD DL,1
                    ADD CL,1
                    JMP MoveDownD


                MoveTopD:
                    CMP DL,DH
                    JNZ notMove3
                    JMP FinMove
                    notMove3:
                    PUSH DX
                    PUSH CX

                    GetCase DL,CL,DX, CX
                    drawCell 0006h, DX, CX, 34

                    POP CX
                    POP DX
                    ADD DL,1
                    SUB CL,1
                    JMP MoveTopD

            MoveG:
                getRow n1,CL
                getRow n2,CH

                CMP CL,CH
                JAE MoveTopG

                MoveDownG:
                    CMP DL,DH
                    JE FinMove
                    PUSH DX
                    PUSH CX

                    GetCase DL,CL,DX, CX
                    drawCell 0006h, DX, CX, 34

                    POP CX
                    POP DX
                    SUB DL,1
                    ADD CL,1
                    JMP MoveDownG

                MoveTopG:
                    CMP DL,DH
                    JE FinMove
                    PUSH DX
                    PUSH CX

                    GetCase DL,CL,DX, CX
                    drawCell 0006h, DX, CX, 34

                    POP CX
                    POP DX
                    SUB DL,1
                    SUB CL,1
                    JMP MoveTopG
            JMP MoveGui
        FinMove:
            GetCenter DL,CL,DX,CX

            setMousePosition 0, 0

            PUSH CX
            PUSH DX

            ; cmp typePawn,1
            ; JE dame
                drawCircle PColor, DX,CX
            ; JMP next45
            ; dame:
            ;     drawQueen n2, offsetX,  offsetY, cel, DX, CX        cellNumber, xOffset, yOffset, cellSize, outerColor, innerColor
            ; next45:
            POP DX
            POP CX

            setMousePosition DX, CX
    ENDM

    Time Macro
        mov ah, 00h
        int 16h
    ENDM


    ;?sound effect:start
    sound_effect PROC NEAR
        ; Set up the tone parameters
        mov al, 0B6h    ; Set timer 2 mode (square wave generator)
        out 43h, al     ; Send mode command to timer 2
        mov ax, 0E9C4h  ; Set the frequency (adjust this for different tones)
        out 42h, al     ; Send low byte of frequency
        mov al, ah
        out 42h, al     ; Send high byte of frequency

        ; Enable speaker output
        in al, 61h      ; Read current value from port 61h
        or al, 3        ; Set bits 0 and 1 to enable speaker (bits 0 and 1)
        out 61h, al     ; Send the new value to port 61h

        ; Wait a bit for the sound to play
        mov cx, 0FFFFh   ; Adjust this delay for longer or shorter beeps
        delay_loop:
        loop delay_loop

        ; Disable speaker output
        in al, 61h      ; Read current value from port 61h
        and al, 0FCh    ; Clear bits 0 and 1 to disable speaker (bits 0 and 1)
        out 61h, al     ; Send the new value to port 61h

        RET
    sound_effect ENDP

    soundEffect PROC NEAR
        call sound_effect
        call sound_effect
        ; call sound_effect
    RET
    soundEffect ENDP
    ;?sound effect:end