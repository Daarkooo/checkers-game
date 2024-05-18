STACK SEGMENT PARA STACK
    DB 64 DUP(' ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
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
DATA ENDS

CODE SEGMENT PARA 'CODE'
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

;!________________________________________________________________________________________________________________________

MAIN PROC FAR
    ;?segments:start
        assume cs:CODE,ds:DATA,ss:STACK
        push ds
        sub ax,ax
        push ax
        mov ax,DATA
        mov ds,ax
        pop ax
        pop ax
    ;?segments:end

    ;?board:start the hex of white color is:
        setGraphics 10h;! set graphics mode 10h (640x350, 16 colors)
        ; drawBoard 300, 0Ah, 0Fh, 06h, 33;! draw the board with white and black cells and size 35 for each cell=>the width of the board is 35*10=350 and the height is 35*10=350
    ;?board:start    
        ; call duringGameMenu
        ;call soundEffect
        call drawLogo

    RET
MAIN ENDP
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
;!logo:start
drawLogo PROC NEAR
    ;!the letter c:start
    drawBackGround 90,30,40,20,0Fh
    drawBackGround 80,50,20,20,0Fh
    drawBackGround 70,70,20,20,0Fh
    drawBackGround 70,90,20,20,0Fh
    drawBackGround 80,110,20,20,0Fh
    drawBackGround 90,130,40,20,0Fh
    ;!the letter c:end
    ;!the letter H:start
    drawBackGround 140,30,20,120,0Fh
    drawBackGround 140,60,60,20,0Fh
    drawBackGround 200,30,20,120,0Fh
    ;!the letter H:end

    ;!the letter E:start
    drawBackGround 250,30,40,20,0Fh
    drawBackGround 240,50,20,20,0Fh
    drawBackGround 230,70,20,20,0Fh
    drawBackGround 230,80,60,20,0Fh
    drawBackGround 230,90,20,20,0Fh
    drawBackGround 240,110,20,20,0Fh
    drawBackGround 250,130,40,20,0Fh
    ;!the letter E:end

    ;!the letter c:start
    drawBackGround 320,30,40,20,0Fh
    drawBackGround 310,50,20,20,0Fh
    drawBackGround 300,70,20,20,0Fh
    drawBackGround 300,90,20,20,0Fh
    drawBackGround 310,110,20,20,0Fh
    drawBackGround 320,130,40,20,0Fh
    ;!the letter c:end

    ;!the letter K:start
    drawBackGround 370,30,20,120,0Fh
    drawBackGround 410,50,20,20,0Fh
    drawBackGround 400,70,20,20,0Fh
    drawBackGround 390,90,20,20,0Fh
    drawBackGround 390,90,20,20,0Fh
    drawBackGround 400,110,20,20,0Fh
    drawBackGround 410,130,20,20,0Fh
    ;!the letter K:end

    ;!the letter E:start
    drawBackGround 460,30,40,20,0Fh
    drawBackGround 450,50,20,20,0Fh
    drawBackGround 440,70,20,20,0Fh
    drawBackGround 440,80,60,20,0Fh
    drawBackGround 440,90,20,20,0Fh
    drawBackGround 450,110,20,20,0Fh
    drawBackGround 460,130,40,20,0Fh
    ;!the letter E:end

    ;!the letter R:start
    drawBackGround 510,30,20,120,0Fh

    drawBackGround 530,30,20,20,0Fh
    drawBackGround 540,40,20,20,0Fh
    drawBackGround 550,50,20,20,0Fh
    drawBackGround 560,60,20,20,0Fh
    drawBackGround 550,70,20,20,0Fh
    drawBackGround 540,80,20,20,0Fh
    drawBackGround 530,90,20,20,0Fh
    drawBackGround 530,90,20,20,0Fh
    drawBackGround 540,110,20,20,0Fh
    drawBackGround 550,130,20,20,0Fh
    ;!the letter R:end


    RET
drawLogo ENDP
;!logo:end
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
    drawBackGround 29,31,70,36,04h
    drawBackGround 34,36,60,26,00h
    printGraphicalString scoreWord,0FFh,5,3;!the color of the string will be :Black
    ;!score text:end

    ;!score first player:start
    drawBackGround 181,31,40,36,04h
    drawBackGround 186,36,30,26,00h
    printGraphicalString whitePlayer_score,0FFh,24,3;!the color of the string will be :Black
    ;!score first player:end

    ;!score second player:start
    drawBackGround 231,31,40,36,04h
    drawBackGround 236,36,30,26,00h
    printGraphicalString blackPlayer_score,0FFh,30,3;!the color of the string will be :Black
    ;!score second player:end


    ;!quit button:start
    drawBackGround 29,283,70,36,04h
    drawBackGround 34,288,60,26,00h
    printGraphicalString quit,0FFh,6,21;
    ;!quit button:end

    ;!resign button:start
    drawBackGround 189,283,84,36,04h
    drawBackGround 194,288,74,26,00h
    printGraphicalString resign,0FFh,26,21;
    ;!resign button:end

    ;!turn :start
    drawBackGround 115,154,86,36,04h

    cmp isWhitePlayer,0
    je handleBlackTurn
    
    drawBackGround 120,159,76,26,0Fh
    printGraphicalString whitePlayer,0FFh,17,12;
    jmp everyThingIsHandeled
    handleBlackTurn:
    
    drawBackGround 120,159,76,26,00h
    printGraphicalString blackPlayer,0FFh,17,12;
    everyThingIsHandeled:
    ;!turn :end

    RET
duringGameMenu ENDP

CODE ENDS
END
