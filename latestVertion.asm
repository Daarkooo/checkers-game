.MODEL SMALL

.STACK 100h

.DATA
    flag db 'b$';
    logoMessage db 'Click Space To Coninue','$';
    ;?infos about board:start
        ;! the board is a 10x10 board =>350x350 pixels
    ;?infos about board:end

    ;?board vars:start
        str1 DB 's:$'
    ;?board vars:end

    ;?menu vars:start
        whitePlayer db 'White$'
        blackPlayer db 'Black$'
        isWhitePlayer db 0
        whitePlayer_score db '0','$'
        blackPlayer_score db '0','$'
        resign db 'Resign','$'
        quit db 'Quit$'
        restart db 'restart','$'
        scoreWord db 'Score:$'
        whitePlayer_score_text db 'White player score: ','$';!<this will be deleted>
        blackPlayer_score_text db 'Black player score: ','$';!<this will be deleted>
    ;?menu vars:end
    ;?border vars:start
        ;?menu border top:start
        menu_border_top_x dw 10
        menu_border_top_y dw 10
        menu_border_top_height dw 0
        menu_border_top_width dw 12;! the width of the border
        ;?menu border top:end
        ;?menu border bottom:start
        menu_border_bottom_x dw 10
        menu_border_bottom_y dw 330
        menu_border_bottom_height dw 0
        menu_border_bottom_width dw 12;! the width of the border
        ;?menu border bottom:end
        ;?menu border left:start
        menu_border_left_x dw 10
        menu_border_left_y dw 40
        menu_border_left_height dw 12
        menu_border_left_width dw 0
        ;?menu border left:end
        ;?menu border right:start
        menu_border_right_x dw 250
        menu_border_right_y dw 40
        menu_border_right_height dw 12
        menu_border_right_width dw 0
        ;?menu border right:end
        ball_size dw 10 ;! the size of the ball ===== the size of the border(height)
        ball_color db 06h;
        ball_black_x dw 0
        ball_black_y dw 0
        ball_white_x dw 0
        ball_white_y dw 0
    ;?border vars:end
    ;todo text background vars :start
        backGround_x dw 0
        backGround_y dw 0
        backGround_width dw 10
        backGround_height dw 5
        backGround_color db 0Fh
    ;todo text background vars :end
    ;?time listener:start
    time_aux db 0;! to check if the time has changed
    ;?time listener:end

.CODE

exit MACRO status
    MOV AH, 4Ch
    MOV AL, status
    INT 21h
ENDM


setGraphics MACRO num
    MOV AX, num
    INT 10h
ENDM

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


;!click procs and macros:start
    __sleep PROC; CX, DX
        PUSH BP
        MOV BP, SP

        MOV AX, 8600h
        MOV DX, [BP + 4]
        MOV CX, [BP + 6]
        INT 15h

        MOV SP, BP
        POP BP
        RET 4
    __sleep ENDP

    sleep MACRO highW, lowW
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV AX, highW
        PUSH AX

        MOV AX, lowW
        PUSH AX

        CALL __sleep

        POP DX
        POP CX
        POP BX
        POP AX
    ENDM

    __setupMouse PROC ; initialX, initialY, minXRange, minYRange, maxXRange, maxYRange
        PUSH BP
        MOV BP, SP

        ; [BP +  4]: maxYRange
        ; [BP +  6]: maxXRange
        ; [BP +  8]: minYRange
        ; [BP + 10]: minXRange
        ; [BP + 12]: initialY
        ; [BP + 14]: initialX

        ; set up mouse drivers
        XOR AX, AX
        INT 33h

        ; set initial mouse position to (0, 0) to avoid distrubing the menu
        MOV AX, 0004h
        MOV CX, [BP + 14]
        MOV DX, [BP + 12]
        INT 33h

        ; display mouse
        MOV AX, 0001h
        INT 33h

        ; will do (maximum range - 3)
        ; horizontal range
        MOV AX, 0007h
        MOV CX, [BP + 10]
        MOV DX, [BP + 6]
        INT 33h

        ; vertical range
        MOV AX, 0008h
        MOV CX, [BP + 8]
        MOV DX, [BP + 4]
        INT 33h

        MOV SP, BP
        POP BP
        RET 12
    __setupMouse ENDP

    setupMouse MACRO initialX, initialY, minXRange, minYRange, maxXRange, maxYRange
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV AX, initialX
        PUSH AX

        MOV AX, initialY
        PUSH AX

        MOV AX, minXRange
        PUSH AX

        MOV AX, minYRange
        PUSH AX

        MOV AX, maxXRange
        PUSH AX

        MOV AX, maxYRange
        PUSH AX

        CALL __setupMouse

        POP DX
        POP CX
        POP BX
        POP AX
    ENDM

    __awaitMouseClick PROC; callback, arg1, arg2, arg3
        PUSH BP
        MOV BP, SP

        MOV AX, [BP + 8]    ; arg1
        PUSH AX

        MOV AX, [BP + 6]    ; arg2
        PUSH AX

        MOV AX, [BP + 4]    ; arg3
        PUSH AX

        __awaitMouseClick_mainLoop:
            MOV AX, 3h          ; Function 3: Get mouse position and button status
            INT 33h             ; Call mouse interrupt

            TEST BL, 1          ; Check if left button is pressed
        JZ __awaitMouseClick_mainLoop

        sleep 0003h, 0D40h

        PUSH CX     ; column (x)
        PUSH DX     ; row (y)

        CALL [BP + 10]

        MOV SP, BP
        POP BP
        RET 8
    __awaitMouseClick ENDP

    ; arg1 and arg2 arguments to callback; order of PUSH: arg1 --> arg2 --> arg3 --> CX (X position) --> DX (Y position)
    ; it is Advisable to push 'arg1', 'arg2' & 'arg3'; even if their values is 0
    awaitMouseClick MACRO callback, arg1, arg2, arg3
        PUSH callback  ; Push the offset of the callback

        MOV AX, arg1
        PUSH AX

        MOV AX, arg2
        PUSH AX

        MOV AX, arg3
        PUSH AX

        CALL __awaitMouseClick
    ENDM

    ; For now, this is the event handler to make moves in game
    ; returns x (column) and y (row) in CX and DX, respectively
    getCoordsFromMouseClick PROC ; xOffset, yOffset, cellSize, xPosition, yPosition
        PUSH BP
        MOV BP, SP

        ; [BP + 12]: xOffset
        ; [BP + 10]: yOffset
        ; [BP + 8]: size
        ; [BP + 6]: xPosition
        ; [BP + 4]: yPosition

        ; x = column * size + xOffset
        ; y = row * size + yOffset

        ; x position
        XOR DX, DX
        MOV AX, [BP + 6]
        SUB AX, [BP + 12]
        DIV WORD PTR [BP + 8]
        MOV CX, AX

        ; y = line * size + offset

        ; y position
        XOR DX, DX
        MOV AX, [BP + 4]
        SUB AX, [BP + 10]
        DIV WORD PTR [BP + 8]
        MOV DX, AX

        MOV SP, BP
        POP BP
        RET 10
    getCoordsFromMouseClick ENDP

    ; For now, this is the event handler that returns which menu button was clicked, returns result in AX
    ; 0: nothing
    ; 1: SP/MP
    ; 2: makla
    ; 3: start
    ; 4: theme1
    ; 5: theme2
    ; 6: theme3
    ; 7: theme4
    ; F: exit
    getMenuOptionClicked_omar PROC ; fakeArg1, fakeArg2, fakeArg3, xPosition, yPosition
        PUSH BP
        MOV BP, SP

        ; [BP + 4]: yPosition
        ; [BP + 6]: xPosition

        
            CMP WORD PTR [BP + 4], 283;!quit button Y
            JL END_LABEL

            MOV AX, 283;!quit button Y
            ADD AX, 36;!quit button height
            CMP [BP + 4], AX
            JG END_LABEL

            CMP WORD PTR [BP + 6], 29;!quit button X
            JL END_LABEL

            MOV AX, 29;!quit button X
            ADD AX, 70;!quit button width
            CMP [BP + 6], AX
            JG END_LABEL

            MOV AX, 0000h
        JMP END_LABEL

        ; SPMP_LABEL:
        ;     CMP WORD PTR [BP + 4], SPMP_Y
        ;     JL MAKLA_LABEL

        ;     MOV AX, SPMP_Y
        ;     ADD AX, 50
        ;     CMP [BP + 4], AX
        ;     JG MAKLA_LABEL

        ;     CMP WORD PTR [BP + 6], SPMP_X
        ;     JL MAKLA_LABEL

        ;     MOV AX, SPMP_X
        ;     ADD AX, 120
        ;     CMP [BP + 6], AX
        ;     JG MAKLA_LABEL

        ;     MOV AX, 0001h
        ; JMP END_LABEL

        ; MAKLA_LABEL:
        ;     CMP WORD PTR [BP + 4], MAKLA_Y
        ;     JL START_LABEL

        ;     MOV AX, MAKLA_Y
        ;     ADD AX, 50
        ;     CMP [BP + 4], AX
        ;     JG START_LABEL

        ;     CMP WORD PTR [BP + 6], MAKLA_X
        ;     JL START_LABEL

        ;     MOV AX, MAKLA_X
        ;     ADD AX, 120
        ;     CMP [BP + 6], AX
        ;     JG START_LABEL

        ;     MOV AX, 0002h
        ; JMP END_LABEL

        ; START_LABEL:
        ;     CMP WORD PTR [BP + 4], START_Y
        ;     JL THEME0_LABEL

        ;     MOV AX, START_Y
        ;     ADD AX, 50
        ;     CMP [BP + 4], AX
        ;     JG THEME0_LABEL

        ;     CMP WORD PTR [BP + 6], START_X
        ;     JL THEME0_LABEL

        ;     MOV AX, START_X
        ;     ADD AX, 120
        ;     CMP [BP + 6], AX
        ;     JG THEME0_LABEL

        ;     MOV AX, 0003h
        ; JMP END_LABEL

        ; THEME0_LABEL:
        ;     CMP WORD PTR [BP + 4], THEME0_Y
        ;     JL THEME1_LABEL

        ;     MOV AX, THEME0_Y
        ;     ADD AX, 34
        ;     CMP [BP + 4], AX
        ;     JG THEME1_LABEL

        ;     CMP WORD PTR [BP + 6], THEME0_X
        ;     JL THEME1_LABEL

        ;     MOV AX, THEME0_X
        ;     ADD AX, 34
        ;     CMP [BP + 6], AX
        ;     JG THEME1_LABEL

        ;     MOV AX, 0004h
        ; JMP END_LABEL

        ; THEME1_LABEL:
        ;     CMP WORD PTR [BP + 4], THEME1_Y
        ;     JL THEME2_LABEL

        ;     MOV AX, THEME1_Y
        ;     ADD AX, 34
        ;     CMP [BP + 4], AX
        ;     JG THEME2_LABEL

        ;     CMP WORD PTR [BP + 6], THEME1_X
        ;     JL THEME2_LABEL

        ;     MOV AX, THEME1_X
        ;     ADD AX, 34
        ;     CMP [BP + 6], AX
        ;     JG THEME2_LABEL

        ;     MOV AX, 0005h
        ; JMP END_LABEL

        ; THEME2_LABEL:
        ;     CMP WORD PTR [BP + 4], THEME2_Y
        ;     JL THEME3_LABEL

        ;     MOV AX, THEME2_Y
        ;     ADD AX, 34
        ;     CMP [BP + 4], AX
        ;     JG THEME3_LABEL

        ;     CMP WORD PTR [BP + 6], THEME2_X
        ;     JL THEME3_LABEL

        ;     MOV AX, THEME2_X
        ;     ADD AX, 34
        ;     CMP [BP + 6], AX
        ;     JG THEME3_LABEL

        ;     MOV AX, 0006h
        ; JMP END_LABEL

        ; THEME3_LABEL:
        ;     CMP WORD PTR [BP + 4], THEME3_Y
        ;     JL NOTHING_LABEL

        ;     MOV AX, THEME3_Y
        ;     ADD AX, 34
        ;     CMP [BP + 4], AX
        ;     JG NOTHING_LABEL

        ;     CMP WORD PTR [BP + 6], THEME3_X
        ;     JL NOTHING_LABEL

        ;     MOV AX, THEME3_X
        ;     ADD AX, 34
        ;     CMP [BP + 6], AX
        ;     JG NOTHING_LABEL

        ;     MOV AX, 0007h
        ; JMP END_LABEL

        ;! NOTHING_LABEL:
        ;!     XOR AX, AX

        END_LABEL:

        MOV SP, BP
        POP BP
        RET 10
    getMenuOptionClicked_omar ENDP
;!click procs and macros:end

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
    call sound_effect
RET
soundEffect ENDP
;?sound effect:end
;?menu procedures:start
clear_screen PROC NEAR
    ; Set video mode for 640x350
    MOV AH, 0
    MOV AL, 10h
    INT 10h

    ; Clear the screen
    MOV AH, 06h
    MOV AL, 0    ; clear entire screen
    MOV BH, 00h  ;!and the background color is black and text color is black to make it white (0Fh)
    MOV CX, 0    ; row, column of upper left corner
    MOV DX, 184Fh ; row, column of lower right corner (25 rows x 80 columns)
    INT 10h

    RET
clear_screen ENDP
;?menu procedures:end
;todo draw text backGround :start
draw_backGround PROC NEAR
   MOV cx,backGround_x;!position x column
   MOV dx,backGround_y;!position y row
    draw_backGround_horizontal:
        MOV AH,0Ch;! set pixel
        MOV AL,backGround_color;! color
        MOV bh,0;! page 0
        INT 10h;! call BIOS

        inc cx;! move to the next column
        mov ax,cx
        sub ax,backGround_x
        cmp ax,backGround_width
        JNG draw_backGround_horizontal

        mov cx,backGround_x;! reset the column position
        inc dx;! move to the next row

        mov ax,dx;
        sub ax,backGround_y;
        cmp ax,backGround_height;
        JNG draw_backGround_horizontal;
 RET
draw_backGround ENDP
drawBackGround MACRO backGround_column , backGround_row , width , height , color
    mov ax,backGround_column
    mov backGround_x,ax
    mov ax,backGround_row
    mov backGround_y,ax
    mov ax,width
    mov backGround_width,ax
    mov ax,height
    mov backGround_height,ax
    mov AL,color
    mov backGround_color,AL
    call draw_backGround
ENDM
;todo draw text backGround :end

;todo during game menu:start

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
	
	; setting initial starting points
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
    setCursorPosition MACRO row, column, page
        MOV AX, 0200h
        MOV BH, page
        MOV DL, column
        MOV DH, row
        INT 10H
    ENDM

;!rahim function string:start
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
;!rahim function string:end
duringGameMenu PROC
    ;!score text:start 
    drawBackGround 365,31,70,36,04h
    drawBackGround 370,36,60,26,00h
    printGraphicalString scoreWord,0FFh,47,3;!the color of the string will be :Black
    ;!score text:end

    ;!score first player:start
    drawBackGround 517,31,40,36,04h
    drawBackGround 522,36,30,26,00h
    printGraphicalString whitePlayer_score,0FFh,66,3;!the color of the string will be :Black
    ;!score first player:end

    ;!score second player:start
    drawBackGround 567,31,40,36,04h
    drawBackGround 572,36,30,26,00h
    printGraphicalString blackPlayer_score,0FFh,72,3;!the color of the string will be :Black
    ;!score second player:end


    ;!quit button:start
    drawBackGround 365,283,70,36,04h
    drawBackGround 370,288,60,26,00h
    printGraphicalString quit,0FFh,48,21;
    ;!quit button:end

    ;!resign button:start
    drawBackGround 525,283,84,36,04h
    drawBackGround 530,288,74,26,00h
    printGraphicalString resign,0FFh,68,21;
    ;!resign button:end

    ;!turn :start
    drawBackGround 451,154,86,36,04h

    cmp isWhitePlayer,0
    je handleBlackTurn
    
    drawBackGround 456,159,76,26,0Fh
    printGraphicalString whitePlayer,0FFh,59,12;
    jmp everyThingIsHandeled
    handleBlackTurn:
    
    drawBackGround 456,159,76,26,00h
    printGraphicalString blackPlayer,0FFh,59,12;
    everyThingIsHandeled:
    ;!turn :end

    RET
duringGameMenu ENDP

;!logo:start
drawLogo PROC NEAR
    ;!the letter c:start
    drawBackGround 50,30,40,20,0Fh
    drawBackGround 40,50,20,20,0Fh
    drawBackGround 30,70,20,20,0Fh
    drawBackGround 30,90,20,20,0Fh
    drawBackGround 40,110,20,20,0Fh
    drawBackGround 50,130,40,20,0Fh
    ;!the letter c:end
    ;!the letter H:start
    drawBackGround 100,30,20,120,0Fh
    drawBackGround 100,80,60,20,0Fh
    drawBackGround 160,30,20,120,0Fh
    ;!the letter H:end

    ;!the letter E:start
    drawBackGround 210,30,40,20,0Fh
    drawBackGround 200,50,20,20,0Fh
    drawBackGround 190,70,20,20,0Fh
    drawBackGround 190,80,60,20,0Fh
    drawBackGround 190,90,20,20,0Fh
    drawBackGround 200,110,20,20,0Fh
    drawBackGround 210,130,40,20,0Fh
    ;!the letter E:end

    ;!the letter c:start
    drawBackGround 280,30,40,20,0Fh
    drawBackGround 270,50,20,20,0Fh
    drawBackGround 260,70,20,20,0Fh
    drawBackGround 260,90,20,20,0Fh
    drawBackGround 270,110,20,20,0Fh
    drawBackGround 280,130,40,20,0Fh
    ;!the letter c:end

    ;!the letter K:start
    drawBackGround 330,30,20,120,0Fh
    drawBackGround 380,30,20,20,0Fh
    drawBackGround 370,50,20,20,0Fh
    drawBackGround 360,70,20,20,0Fh
    drawBackGround 350,90,20,20,0Fh
    drawBackGround 350,90,20,20,0Fh
    drawBackGround 360,110,20,20,0Fh
    drawBackGround 370,130,20,20,0Fh
    ;!the letter K:end

    ;!the letter E:start
    drawBackGround 420,30,40,20,0Fh
    drawBackGround 410,50,20,20,0Fh
    drawBackGround 400,70,20,20,0Fh
    drawBackGround 400,80,60,20,0Fh
    drawBackGround 400,90,20,20,0Fh
    drawBackGround 410,110,20,20,0Fh
    drawBackGround 420,130,40,20,0Fh
    ;!the letter E:end

    ;!the letter R:start
    drawBackGround 470,30,20,120,0Fh
    drawBackGround 490,30,20,20,0Fh
    drawBackGround 500,40,20,20,0Fh
    drawBackGround 510,50,20,20,0Fh
    drawBackGround 520,60,20,20,0Fh
    drawBackGround 510,70,20,20,0Fh
    drawBackGround 500,80,20,20,0Fh
    drawBackGround 490,90,20,20,0Fh
    drawBackGround 490,90,20,20,0Fh
    drawBackGround 500,110,20,20,0Fh
    drawBackGround 510,130,20,20,0Fh
    ;!the letter R:end

    ;!the letter S:start
    drawBackGround 570,30,40,20,0Fh
    drawBackGround 560,50,20,20,0Fh
    drawBackGround 550,70,20,20,0Fh
    drawBackGround 560,90,50,20,0Fh
    drawBackGround 590,100,20,20,0Fh
    drawBackGround 580,120,20,20,0Fh
    drawBackGround 550,130,40,20,0Fh
    ;!the letter S:end
    ;!show message:start
    printGraphicalString logoMessage, 0FFh, 30,21
    ;!show message:end
    ;!get out of logo:start
    mov ah,00h
    int 16h

    check_if_space_clicked:
        cmp al,' '
        je get_out
    jmp check_if_space_clicked
        get_out:
        drawBackGround 0,0,640,350,00h
    ;!get out of logo:end
    RET
drawLogo ENDP
;!logo:end

;!switch turn text:start
switchTurnString MACRO flag
    cmp flag, 'w'
    je is_white_turn
    printGraphicalString whitePlayer,0FFh,59,12
    printGraphicalString blackPlayer,0FFh,59,12
    jmp the_end
    is_white_turn:
    printGraphicalString blackPlayer,0FFh,59,12
    printGraphicalString whitePlayer,0FFh,59,12
    the_end:
ENDM
;!switch turn text:end

MAIN PROC 
    MOV AX, @DATA
    MOV DS, AX

    ;?board:start the hex of white color is:
        setGraphics 10h;! set graphics mode 10h (640x350, 16 colors)
        call drawLogo
        drawBoard 0Ah, 0Ah, 0Fh, 06h, 33;! draw the board with white and black cells and size 35 for each cell=>the width of the board is 35*10=350 and the height is 35*10=350
    ;?board:start    
        call duringGameMenu
        switchTurnString flag
        ;call soundEffect; 
MAIN ENDP

END main
