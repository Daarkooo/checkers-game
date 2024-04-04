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
        menu_column_to_start db 06h
        show_menu db 1;! 0=>not showing the menu, 1=>showing the menu
        side_menu_title db 'MENU:', '$'
        side_menu_new_game_multi_player db 'click - M - to play with friend', '$'
        side_menu_new_game_single_player db 'click - S - to play with computer', '$'
        mlti_player_str db 'multi player function invoked press - R - to get back', '$'
        single_player_str db 'single player function invoked press - R - to get back', '$'
        side_menu_exit db 'click - E - to exit', '$'
    ;?menu vars:end
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

drawBoard MACRO whiteColor, blackColor, size
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

    ;?board:start
        setGraphics 10h;! set graphics mode 10h (640x350, 16 colors)
        drawBoard 0Fh, 06h, 35;! draw the board with white and black cells and size 35 for each cell=>the width of the board is 35*10=350 and the height is 35*10=350
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
    ;?title:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,04h;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,side_menu_title;! load the address of the string
    int 21h;! call DOS
    ;?title:end
    ;?new game multi player:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,06h;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,side_menu_new_game_multi_player;! load the address of the string
    int 21h;! call DOS
    ;?new game multi player:end
    ;?new game single player:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,08h;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,side_menu_new_game_single_player;! load the address of the string
    int 21h;! call DOS
    ;?new game single player:end

    ;?exit:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,0Ah;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,side_menu_exit;! load the address of the string
    int 21h;! call DOS
    ;?exit:end

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
    cmp al,'E'
    je exit_game
    cmp al,'e'
    je exit_game
    cmp al,'S'
    je single_player_game
    cmp al,'s'
    je single_player_game
    jmp check_key
    multi_player_game:
    call multi_player_Function
    ;!mov show_menu,0
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
    call clear_screen
    ;?title:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    mov dh,04h;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,mlti_player_str;
    int 21h;! call DOS
    ;?title:end
    ;?wait for key:start
    mov ah,00h
    int 16h
    ;?wait for key:end
    ;?catch the key:start
    wait_to_ret_to_menu:
    cmp al,'r'
    je ret_menu
    cmp al,'R'
    je ret_menu
    jmp wait_to_ret_to_menu
    ret_menu:
    call side_menu
    RET
multi_player_Function ENDP
single_player_function PROC NEAR
    call clear_screen
    ;?title:start
    mov ah,02h;! set cursor position
    mov bh,0;! page 0
    ;!get in center row and col
    mov dh,04h;! row
    mov dl,menu_column_to_start;! column
    int 10h;! call BIOS

    mov ah,09h;! print string
    lea dx,single_player_str;
    int 21h;! call DOS
    ;?title:end
    ;?wait for key:start
    mov ah,00h
    int 16h
    ;?wait for key:end
    ;?catch the key:start
    wait_to_ret_to_menu_s:
    cmp al,'r'
    je ret_menu_s
    cmp al,'R'
    je ret_menu_s
    jmp wait_to_ret_to_menu_s
    ret_menu_s:
    call side_menu
    RET
single_player_function ENDP
;?mock functions:end

exit MACRO status
    MOV AH, 4Ch
    MOV AL, status
    INT 21h
ENDM

setGraphics MACRO num
    MOV AX, num
    INT 10h
ENDM

__drawCell PROC ;? color, x, y, size  (last parameteres are top of stack)
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



__drawBoard PROC ;? whiteCell, blackCell, size (last parameteres are top of stack)
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





CODE ENDS
END