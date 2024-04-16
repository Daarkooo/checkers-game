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
        menu_column_to_start db 30;! the column to start the menu
        show_menu db 1;! 0=>not showing the menu, 1=>showing the menu
        side_menu_title db 'MENU:', '$'
        side_menu_play_multi_player db 'Multi player - S -', '$'
        side_menu_play_single_player db 'Single player - M -', '$'
        side_menu_theme db 'Choose Theme:','$'
        themes_row dw 167
        wanna_play_multi_player dw 1
        side_menu_makla_machi_sif db 'makla: machi sif - A -','$'
        side_menu_makla_sif db 'makla: sif - B -','$'
        wanna_eat_by_my_choise dw 1
        side_menu_functions db 'functions: - f -', '$'
        side_menu_exit db 'click - E - to exit', '$'
        side_menu_start_game db 'Start - G -','$'
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
        ;drawBoard 0Fh, 06h, 35;! draw the board with white and black cells and size 35 for each cell=>the width of the board is 35*10=350 and the height is 35*10=350
        ; drawBoard 300, 0Ah, 0Fh, 06h, 33;! draw the board with white and black cells and size 35 for each cell=>the width of the board is 35*10=350 and the height is 35*10=350
    ;?board:start
    ;?during game menu:start
    CMP show_menu, 1
    je display_menu
        jmp continue_game
        display_menu:
        call side_menu
        continue_game:
    ;?during game menu:end      

    
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

side_menu PROC NEAR
    call clear_screen
    ;?draw the borders:start
    ; call draw_menu_border_top_bottom
    ; mov ax,menu_border_bottom_x
    ; mov menu_border_top_x,ax
    ; mov ax,menu_border_bottom_y
    ; mov menu_border_top_y,ax
    ; mov ax,menu_border_bottom_width
    ; mov menu_border_top_width,ax
    ; mov ax,menu_border_bottom_height
    ; mov menu_border_top_height,ax
    ; call draw_menu_border_top_bottom;!i will make it draw the bottom border
    ; call draw_menu_border_left;!i will make it draw the right border
    ; mov ax,menu_border_right_x
    ; mov menu_border_left_x,ax
    ; mov ax,menu_border_right_y
    ; mov menu_border_left_y,ax
    ; mov ax,menu_border_right_height
    ; mov menu_border_left_height,ax
    ; mov ax,menu_border_right_width
    ; mov menu_border_left_width,ax
    ; call draw_menu_border_left
    ;?draw the borders:end
    
    ;?title:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,08h;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,side_menu_title;! load the address of the string
    int 21h;! call DOS
    ;?title:end
    ;?new game play:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,0Ah;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    cmp wanna_play_multi_player,1
    je printMult
    lea dx,side_menu_play_single_player;!
    jmp pipit
    printMult:
    lea dx,side_menu_play_multi_player;! load the address of the string
    pipit:
    int 21h;! call DOS
    ;?new game play:end

    ;?themes :start
    ; mov ah,02h;! set cursor position
    ; mov bh,0;! page 0
    ; mov dh,12;! row
    ; mov dl,menu_column_to_start;! column
    ; int 10h;! call BIOS

    ; mov ah,09h;! print string
    ; lea dx,side_menu_theme;!
    ; int 21h;! call DOS
    ;?themes :end
    
    ;?draw the balls like themes:start
    mov ax,10
    mov ball_size,ax
    ;?first theme white black :start
    mov ball_white_x,250
    mov ax,themes_row
    mov ball_white_y,ax
    mov al,0Fh
    mov ball_color,al;
    call draw_ball_white

    mov ax,ball_white_x
    add ax,ball_size
    mov ball_black_x,ax
    mov ax,themes_row
    mov ball_black_y,ax
    mov al,06h
    mov ball_color,al
    call draw_ball_black
    ;?first theme white black :end

    ;?second theme red white :start
    mov ax,ball_black_x
    add ax,ball_size
    add ax,ball_size
    mov ball_white_x,ax
    mov ax,themes_row
    mov ball_white_y,ax
    ;!white ball
    mov ball_color,0Fh
    call draw_ball_white

    mov ax,ball_white_x
    add ax,ball_size
    mov ball_black_x,ax
    mov ax,themes_row
    mov ball_black_y,ax
    ;!red ball
    mov al,04h
    mov ball_color,al
    call draw_ball_black
    ;?second theme red white :end

    ;?third theme red black :start
    mov ax,ball_black_x
    add ax,ball_size
    add ax,ball_size
    mov ball_white_x,ax
    mov ax,themes_row
    mov ball_white_y,ax
    mov ball_color,06h
    call draw_ball_white

    mov ax,ball_white_x
    add ax,ball_size
    mov ball_black_x,ax
    mov ax,themes_row
    mov ball_black_y,ax
    ;!red ball
    mov al,04h
    mov ball_color,al
    call draw_ball_black
    ;?third theme red black :end
    ;?makla types:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,12h;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    cmp wanna_eat_by_my_choise,1
    je self_eat
    lea dx,side_menu_makla_sif
    jmp sot
    self_eat:
    lea dx,side_menu_makla_machi_sif;
    sot:
    int 21h;! call DOS
    ;?makla types:end
    ;?draw the balls like themes:end

    ;?functions:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,14;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,side_menu_functions;!
    int 21h;! call DOS
    ;?functions:end

    ;?exit:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,16;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,side_menu_exit;! load the address of the string
    int 21h;! call DOS
    ;?exit:end
    ;?start game:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,20;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,side_menu_start_game;
    int 21h;! call DOS
    ;?start game:end

    ;?wait for key:start
    mov ah,00h
    int 16h
    ;?wait for key:end
    ;?catch the key:start
    check_key:
    cmp al,'M'
    je multi_player_game
    cmp al,'m'
    je multi_player_game
    cmp al,'A'
    je maklaSif
    cmp al,'a'
    je maklaSif
    cmp al,'B'
    je maklaMashiSif
    cmp al,'b'
    je maklaMashiSif
    cmp al,'E'
    je exit_game
    cmp al,'e'
    je exit_game
    cmp al,'S'
    je single_player_game
    cmp al,'G'
    je startGame
    cmp al,'g'
    je startGame
    cmp al,'s'
    je single_player_game
    jmp check_key
    multi_player_game:
    call multi_player_Function
    ;!mov show_menu,0
    RET
    maklaSif:
    call print_maklaSif
    RET
    maklaMashiSif:
    call print_maklaMashiSif
    RET
    startGame:
    call clear_screen
    drawBoard 300, 0Ah, 0Fh, 06h, 33;! draw the board with white and black cells and size 35 for each cell=>the width of the board is 35*10=350 and the height is 35*10=350
    RET
    exit_game:
    call clear_screen
    exit 0
    RET
    single_player_game:
    call single_player_function
    RET

    ;?catch the key:end
    ;todo RET               ;todo delete this   RET 
side_menu ENDP
;?menu procedures:end

;?mock functions:start
multi_player_Function PROC NEAR
    ; call clear_screen
    mov ax,1
    mov wanna_play_multi_player,ax
    call side_menu
    RET
multi_player_Function ENDP

single_player_function PROC NEAR
    ; call clear_screen
    mov ax,0
    mov wanna_play_multi_player,ax
    call side_menu
    RET
single_player_function ENDP
print_maklaSif PROC NEAR
    mov wanna_eat_by_my_choise,0
    call side_menu
    RET
print_maklaSif ENDP
print_maklaMashiSif PROC NEAR
    mov wanna_eat_by_my_choise,1
    call side_menu
    RET
print_maklaMashiSif ENDP
;?mock functions:end

;?borders :start

draw_ball_black PROC NEAR
 ;todo draw the ball:start
   MOV cx,ball_black_x;!position x column
   MOV dx,ball_black_y;!position y row
    draw_ball_black_horizontal:
        MOV AH,0Ch;! set pixel
        MOV AL,ball_color;
        MOV bh,0;! page 0
        INT 10h;! call BIOS

        inc cx;! move to the next column
        mov ax,cx;! check if we reached the end of the ball
        sub ax,ball_black_x;! calculate the distance from the start
        cmp ax,ball_size;! compare with the size of the ball
        JNG draw_ball_black_horizontal;! if we didn't reach the end, draw the next pixel

        mov cx,ball_black_x;! reset the column position
        inc dx;! move to the next row

        mov ax,dx;! check if we reached the end of the ball
        sub ax,ball_black_y;! calculate the distance from the start
        cmp ax,ball_size;! compare with the size of the ball
        JNG draw_ball_black_horizontal;! if we didn't reach the end, draw the next pixel
    RET
draw_ball_black ENDP

draw_ball_white PROC NEAR
 ;todo draw the ball:start
   MOV cx,ball_white_x;!position x column
   MOV dx,ball_white_y;!position y row
    draw_ball_white_horizontal:
        MOV AH,0Ch;! set pixel
        MOV AL,ball_color;
        MOV bh,0;! page 0
        INT 10h;! call BIOS

        inc cx;! move to the next column
        mov ax,cx;! check if we reached the end of the ball
        sub ax,ball_white_x;! calculate the distance from the start
        cmp ax,ball_size;! compare with the size of the ball
        JNG draw_ball_white_horizontal;! if we didn't reach the end, draw the next pixel

        mov cx,ball_white_x;! reset the column position
        inc dx;! move to the next row

        mov ax,dx;! check if we reached the end of the ball
        sub ax,ball_white_y;! calculate the distance from the start
        cmp ax,ball_size;! compare with the size of the ball
        JNG draw_ball_white_horizontal;! if we didn't reach the end, draw the next pixel
    RET
draw_ball_white ENDP

;?menu border top & bottom:start
draw_menu_border_top_bottom PROC NEAR
    mov ax,menu_border_top_x
    mov ball_white_x,ax
    mov ax,menu_border_top_y
    mov ball_white_y,ax
    mov ax,menu_border_top_x
    mov ball_black_x,ax
    mov ax,menu_border_top_y
    mov ball_black_y,ax
    sub bx,bx;! set the counter to 0
    mov bx,menu_border_top_width;! set the counter to the width of the border
    mov ax,ball_size
    start_border_top:
        ;!draw balls black and white alternately:start
        call draw_ball_black
        add menu_border_top_x,ax
        mov dx,menu_border_top_x
        mov ball_black_x,dx
        call draw_ball_white
        add menu_border_top_x,ax
        mov dx,menu_border_top_x
        mov ball_white_x,dx
        ;!draw balls black and white alternately:end
        dec bx
        cmp bx,0
        jg start_border_top
    RET
draw_menu_border_top_bottom ENDP
;?menu border top & bottom:end

;?menu border left:start
draw_menu_border_left PROC NEAR
    mov ax,menu_border_left_x
    mov ball_white_x,ax
    mov ax,menu_border_left_y
    mov ball_white_y,ax
    mov ax,menu_border_left_x
    mov ball_black_x,ax
    mov ax,menu_border_left_y
    mov ball_black_y,ax
    sub bx,bx;! set the counter to 0
    mov bx,menu_border_left_height;! set the counter to the height of the border
    mov ax,ball_size
    start_border_left:
        ;!draw balls black and white alternately:start
        call draw_ball_black
        add menu_border_left_y,ax
        mov dx,menu_border_left_y
        mov ball_black_y,dx
        call draw_ball_white
        add menu_border_left_y,ax
        mov dx,menu_border_left_y
        mov ball_white_y,dx
        ;!draw balls black and white alternately:end
        dec bx
        cmp bx,0
        jg start_border_left
    RET
draw_menu_border_left ENDP
;?menu border left:end

;?borders :end

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
