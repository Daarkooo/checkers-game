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
        whitePlayer db 'White player','$'
        blackPlayer db 'Black player','$'
        isWhitePlayer db 1
        whitePlayer_score db 0
        blackPlayer_score db 0
        whitePlayer_score_text db 'White player score: ','$'
        blackPlayer_score_text db 'Black player score: ','$'
        resign db 'Resign','$'
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

        drawBoard 300, 0Ah, 0Fh, 06h, 33;! draw the board with white and black cells and size 35 for each cell=>the width of the board is 35*10=350 and the height is 35*10=350
    ;?board:start    
        call duringGameMenu
    RET
MAIN ENDP

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
;todo draw text backGround :end

;todo during game menu:start
duringGameMenu PROC NEAR
    ;todo which player is playing:start
    mov backGround_x,40
    mov backGround_y,10
    mov backGround_width,113
    mov backGround_height,50
    cmp isWhitePlayer,1
    je whitePlayerPlaying
    mov backGround_color,06h;! black color 
    call draw_backGround
    jmp aa
    whitePlayerPlaying:
    mov backGround_color,0Fh;! white color
    call draw_backGround
    aa:

    ;todo test in side the backGround:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,2;! row
    mov dl,6;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    cmp isWhitePlayer,1
    je displayWhitePlayer
    lea dx,blackPlayer
    jmp tt
    displayWhitePlayer:
    lea dx,whitePlayer
    tt:
    int 21h;! call DOS
    ;todo test in side the backGround:end
    ;todo which player is playing:end


    ;todo set palyers scores:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,10;! row
    mov dl,6;! column
    int 10h;! call BIOS

    mov bl,whitePlayer_score
    add bl,30h
    mov whitePlayer_score_text[19],bl

    mov ah,09h;! print string
    lea dx,whitePlayer_score_text
    int 21h;! call DOS

    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,12;! row
    mov dl,6;! column
    int 10h;! call BIOS

    mov bl ,blackPlayer_score
    add bl,30h
    mov blackPlayer_score_text[19],bl

    mov ah,09h;! print string
    lea dx,blackPlayer_score_text
    int 21h;! call DOS
    ;todo set palyers scores:end
    
;todo during game menu:end

;todo resign button:start
;todo which player is playing:start
    mov backGround_x,40
    mov backGround_y,250
    mov backGround_width,113
    mov backGround_height,50

    mov backGround_color,04h;! red color

    call draw_backGround

     mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,19;! row
    mov dl,9
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,resign
    int 21h;! call DOS

    ;todo test in side the backGround:start
;todo resign button:end
    RET
duringGameMenu ENDP



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

CODE ENDS
END
