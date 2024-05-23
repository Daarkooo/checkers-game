.model small
;DATA SEGMENT
.stack 100h 
.data
    n1 db ?
    n2 db ? 
    n3 DB ?  
    i DB ?
    j DB ? 
    i1 DB ?
    j1 DB ?
    x DB ?
    y DB ?
    
    pawn_position DB ?
    state DB ?  
    switcher DB 1
    checked DB ?
    count DB 0
    
    val1 DB ?
    val2 DB ? 
    menu DB ? 
    verified DB ?
    indMoves DB 20 dup(?) 
    directMoves DB 20 dup(?)
    aiindMoves DB 20 dup(?) 
    aidirectMoves DB 20 dup(?)
    dameIndMoves DB 20 dup(?)
    dameMoves DB 20 dup(?) ; makla i (i e (1->4))
    bool DB 0 ; need it in showpaths 
    num1 DB ? 
    msg_result DB "result: $"
    winner DB ?

    ;Variable for AI Part
    row DB ?
    column DB ?
    
    
    pathSizeArrayIndex DB 0
    pathSizeArray DB 10 dup(?)

    Path DB 5 dup(?)  
    maxPath DB 5 dup(?)
    pathTaille DB 0
    pileTaille DB 0
    maxWeight DB 0
    weightTmp DB 0
    weight DB 0
    
    iAI DB ?
    jAI DB ?
    root DB 33
    tmp DB ?
    indice DB 0
    maklaSif DB 0
    
    aipathSizeArrayIndex DB 0
    aipathSizeArray DB 10 dup(?)

    aiPath DB 5 dup(?)  
    maxaiPath DB 5 dup(?)
    aipathTaille DB 0
    aipileTaille DB 0
    maxaiWeight DB 0
    aiweightaiTmp DB 0
    aiweight DB 0
    
    iAI1 DB ?
    jAI2 DB ?
    airoot DB 33
    aitmp DB ?
    aiindice DB 0
    ;---------------------------
     PColor DB ?
           
     board           DB  20 DUP('b'), 10 DUP('0'), 20 DUP('w')
     board2           DB  20 DUP('b'), 10 DUP('0'), 20 DUP('w')   
     source_pawn     DB      ?
     turn            DB      'b'
     path1           DB      ?
     path2           DB      ?
     num             DB      ?
     makla1          DB      ?
     makla2          DB      ?
     isDirect        DB      '2'
     multiple_jumps  DB      ? 
     
     aiturn            DB      'w'
     aipath1           DB      ?
     aipath2           DB      ?
     aimakla1          DB      ?
     aimakla2          DB      ?
     
   
     INCLUDE methods.inc
     ;INCLUDE print.inc
.code  

;------------get_clumn----------------
get_column MACRO n,result
    LOCAL not_eqaul_zero, less_than_6, less1_than_6, end

    MOV AL, n
    XOR AH, AH 
    MOV BL, 10
    DIV BL    ; divide AL by BL, q -> AL, r -> AH

    MOV AL,AH
    CMP AH, 0 ; check if x == 0
    JNE not_eqaul_zero
        MOV AL, 8 ; return 8
        JMP end
    not_eqaul_zero:

    CMP AH, 6 
    JB less_than_6
        SUB AL, 5   ; return (ah-5)*2-1 -1
    less_than_6:

    SHL AL, 1
    DEC AL  ; retrun ah * 2 -1

    CMP AH, 6 
    JB less1_than_6
        DEC AL  ; return (ah-5)*2-1 -1
    less1_than_6:

end:
    MOV result,AL
ENDM 
 
 
;--------get_row----------
get_row MACRO Num, result
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
 
;------get_number----------------  
get_number MACRO row, column, menu, Num
        LOCAL invalid, end, next
            ; (row % 2 === column % 2)
            MOV AL,column
            CMP AL,9
            JA invalid

            MOV AL,row ;[0002h]
            CMP AL,9
            JA invalid

            MOV AH,'y'
            CMP AH,menu
                JNE next
                MOV NUM, 'v'; valid
                JMP end
            next:

            ; MOV AL,row ;[0002h]
            xor ah, ah
            mov cl, 2
            div cl
            mov bl, ah  ; Store (column % 2) in bl
            mov al, column
            xor ah, ah
            div cl
            cmp ah, bl  ; Compare (row % 2) with (column % 2)
            jz invalid  ; not a White Square
                ; Calculate the number
                mov al, row
                mov bl, 5
                mul bl  ; AL = row * 5
                mov bl, column
                shr bl, 1  ; Divide column by 2
                add al, bl  ; AL = AL + (column / 2)
                inc al  ;the index starts from 0

                ; Store the number
                mov Num, al
                jmp end
        invalid:
            ; White square || invalid row/column
            mov Num, 0
        end:
ENDM      
;------get_number----------------  
get_Number2 MACRO column, row, Num
    LOCAL calculate_number, fin

        ; (row % 2 === column % 2)
        mov al, column
        xor ah, ah
        mov cl, 2
        div cl
        mov bl, ah  ; Store (column % 2) in bl
        mov al, row
        xor ah, ah
        div cl
        cmp ah, bl  ; Compare (row % 2) with (column % 2)
        jNE calculate_number  ; not a White Square
    
        ; White square
        mov Num, 0
        jmp fin
    
    calculate_number:
    
        ; Calculate the number
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
  
  
;-----board_init_board---------- 
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
        MOV BYTE PTR [SI], '0'
        INC SI
    LOOP L2

    MOV CX, 20
    L3:
        MOV BYTE PTR [SI], 'w'
        INC SI
    LOOP L3
ENDM 

;----print_char---------
print_char MACRO asciiCode
    MOV AH, 02h
    MOV DL, asciiCode
    INT 21h
ENDM
 
 
;----print_string-------    
print_string MACRO reference
    MOV AH, 09h
    LEA DX, reference
    INT 21h
ENDM
 
;---print_board-------- 
print_board MACRO board
    LOCAL outer_loop, inner_loop1, inner_loop2
        MOV CX, 10
        XOR SI, SI
    
    outer_loop:
        PUSH CX
        TEST CX, 01h                ; get first bit to know whether it's parity
        MOV CX, 5
        MOV AH, 02h
        
        JZ inner_loop2
        
        inner_loop1:
            print_char board[SI]
            INC SI
            
            print_char ' '
            
            print_char 2EH
            
            print_char ' '          ; space
        LOOP inner_loop1
        
        JMP row_end
        
        inner_loop2:
            print_char 2EH
            
            print_char ' '          ; space
            
            print_char board[SI]
            INC SI
            
            print_char ' '
        LOOP inner_loop2
        
        row_end:
        print_string newLine        ; new line

        POP CX
    LOOP outer_loop
ENDM
;-----get_cell_color-------------
 get_cell_color MACRO row, column
    LOCAL BlackCase, fin

        ; (row % 2 === column % 2)
        mov al, column
        xor ah, ah
        mov cl, 2
        div cl
        mov bl, ah  ; Store (column % 2) in bl
        mov al, row
        xor ah, ah
        div cl
        cmp ah, bl  ; Compare (row % 2) with (column % 2)
        jnz BlackCase  ; not a White Square
    
        ; White square
        lea dx,White
        mov ah,09
        int 21h
        jmp fin
    
    BlackCase:
        lea dx,Black
        mov ah,09
        int 21h
    
    fin: 
ENDM  
   
;----CellState----------
get_cell_state MACRO board,i,j,result
    LOCAL white_cell, end_label, white_celll     ; LOCAL LABELS
        MOV DL, i
        MOV DH, j
        get_number DL, DH, menu, AL        ; Le macro de la question C (Fait par Abdou & Omar)
        
        TEST AL, AL
        JNZ white_celll
            JMP white_cell
        white_celll:
        
        XOR AH, AH
        MOV SI, AX
        MOV AL, board[SI - 1]        
        MOV result, AL
        JMP end_label
            
    white_cell:
        MOV result, 0
    
    end_label: 
ENDM
   
   
;----------verify_move----------------   
verify_move MACRO board, i, j, x, y, turn, verified, isDirect, val1, val2
    LOCAL impossible_move, done, other_way, down, end, next,impossible_move1,impossible_move2,continue,continue1,label1
    ;DL=i DH=j BH=x CH=y | i and j must be between 1-10 -> (0-9) 'we do the check in get_number & 'DEC 1' in the main'  

    get_number i, j, menu, n1 
        CMP n1,0 ; 0 -> white cell 'invalid' (check get_number)
        JNE impossible_move1  ; checking if it's a valid input 
            JMP impossible_move
        impossible_move1:
    get_cell_state board,i,j,state  
        MOV AL, state
        CMP AL, turn ; to make the move -> 'w'='w' / 'b'='b' else impossible_move
        JE continue
            JMP impossible_move
        continue:
    
    get_number x, y, menu, n2 ; menu <- null doesnt effect  
        CMP n2,0
        JNE impossible_move2 ; checking if it's a valid input
            JMP impossible_move
        impossible_move2:
    get_cell_state board, x, y, state        
        CMP state,'0' ; to make the move -> board[x,y] needs to be empty '0'
        JE continue1        
            JMP impossible_move
        continue1:

    MOV BH,n1
    MOV val1,BH ; need it in move function (to avoid the get_number call)
    MOV BH,n2
    MOV val2,BH ; need it in move function (to avoid the get_number call)
    
    ;----------show_path (optimization)---------(to check only one block direct/indirect)
    CMP isDirect,'n' ; isDirect <- Al
    JE label1 ;-------DIRECT_MOVE-----(always true if the previous checks were true)
        JMP done
    label1:
    ;------------INDIRECT_MOVE------------------------------- 
    MOV DL,i 
    MOV DH,j 
    MOV AH,y 

    MOV CL,n1
    CMP CL,BH ; CMP n1,n2
    JB down
        MOV DL,x ; n1>n2 =>------going up-------- to avoid the check of both cases(up &down) in different blocks
        MOV DH,y
        MOV AH,j
    down:
    CMP DH,AH ; cmp j,y | if we going up we swap 'cmp y,j' 
    JB other_way
        DEC DH ; dec n1[,j] 
        JMP next
    other_way:
        INC DH ; inc n1[,j]
    next:
    INC DL

    get_number DL,DH , menu, isDirect ; isDirect return makla number (for optimization) 'indirect move'
    get_cell_state board, DL, DH, state ; depends on the colors (white -> black/ black ->white)
    CMP state,'0' ; one step (not for dames)
    JE impossible_move 
    MOV AL,turn 
    CMP AL,state ; to make the move -> state needs to be the color of the opposing player (enemy) 
    JNE done ; make the move
        
    impossible_move:
        MOV verified,0 
        JMP end
    done:
        MOV verified,1   
    end:
ENDM 


;------move_pawn---------- 

move_pawn MACRO board,x,y,path1,path2,pawn_position,makla1,makla2,isDirect
    LOCAL end, indirect, move, move1, no_move, next  
    MOV BH,x ; cant use the other registers cuz are used in get_number 
    MOV CH,y 

    get_number BH,CH,menu,num1
    MOV BH,num1
    MOV num,BH
    CMP BH,path1
    JNE next
        MOV BH,path1 ; BH <- board[x,y]
        JE move1
    next:
    CMP BH,path2 ; BH <- board[x,y]     
    JNE no_move
    MOV AH,makla2
    MOV makla1,AH ; isDirect return maklaNum for path2

    move1:
    XOR AX, AX   
    MOV AL, pawn_position
    DEC AL   
    MOV DI, AX    
    MOV AL, BH ; BH <- board[x,y]
    DEC AL   
    MOV SI, AX     
        
    CMP isDirect,'y'
    JNE indirect 
        MOV AL,board[DI] ;---DIRECT MOVE---------
        MOV board[DI],'0'
        MOV board[SI],AL                    
        JMP move
    indirect:
        MOV AL,board[DI] ;---INDIRECT MOVE---------
        MOV board[DI],'0'
        MOV board[SI],AL 
            
        MOV AL, makla1
        DEC AL  
        MOV DI, AX    
        MOV AL,board[DI]
        MOV board[DI],'0'
    move:
        MOV AL,num
        MOV isDirect, AL
        JMP end
    no_move:
        MOV AL,-1
        MOV isDirect,AL
    end:
ENDM


;------show_path----------
show_path MACRO board,i1,j1,turn1,path1,path2,pawn_position,makla1,makla2
    LOCAL end, next, next1, not_verified, not_verified1, not_verified2,  down, down1, label1, label2, label3
           
    MOV DL,i1
    MOV DH,j1
    mov i,DL  ;i<-dl
    mov j,DH  ;j<-dh

    MOV x,DL ; BH<-x
    MOV y,DH ; CH<-y 
    MOV BH,x
    MOV CH,y                
    MOV AH,turn1 
    MOV turn,AH   
    
    MOV AL,-1 ;
    MOV path1,AL
    MOV path2,AL ; in case there's no move
    MOV makla1,AL
    MOV makla2,AL
    
    ;---------INDIRECT---------------- we prioritize the indirect move  
    CMP turn,'b'
    JE down
        SUB BH,2  ;------WHITE's TURN------- x<-(i-2)
        JMP next
    down: ;------BLACK's TURN-------
        ADD BH,2 ; x<-(i+2)
    next:
    MOV x,BH
    MOV AL,'n' ; not direct 
    MOV isDirect,AL
    
    ADD CH,2 ; CH<-(y+2) 
    MOV y,CH
    verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]      

    CMP verified,0
    JE not_verified 
        MOV bool,1
        MOV AH,n2
        MOV path1,AH
        MOV AH,isDirect
        MOV makla1,AH ; return maklaNum for path1
    not_verified:
    MOV AL,'n' ; not direct 
    MOV isDirect,AL

    MOV CH,j
    SUB CH,2 ; CH<-(y-2) 
    MOV y,CH
    verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y] 
    
    CMP verified,0 
    JE not_verified1 
        MOV bool,1 ; isDirect'll return maklaNum for path2
        MOV AH,n2
        MOV path2,AH
        MOV AH,isDirect
        MOV makla2,AH
    not_verified1:

    CMP bool,1
    JNE label1 ; if there's a move in indirect, isDirect'll return maklaNum -> isDirect != 'n'
        MOV bool,0
        MOV AL,'n' ; not direct 
        MOV isDirect,AL
        JMP end
    label1:

    ;---------DIRECT----------------
    MOV BH,i
    MOV CH,j

    CMP turn,'b'
    JE down1
        DEC BH ;------WHITE's TURN------- x<-(i-1)
        JMP next1
    down1: ;------BLACK's TURN-------
        INC BH ; x<-(i+1)
    next1:
    MOV x,BH

    MOV AL,'y' ; direct direct
    MOV isDirect,AL 
    INC CH ; CH<-(j+1)  
    MOV y,CH
    verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y] 

    CMP verified,0
    JE not_verified2  
        MOV AH,n2
        MOV path1,AH
    not_verified2:
 
    MOV CH,j
    DEC CH ; CH<-(j-1) 
    MOV y,CH 
    
    verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y] 

    CMP verified,0
    JE label3
        MOV AH,n2 
        MOV path2,AH
    label3:
        MOV AL,'y' ; not direct 
        MOV isDirect,AL
    end:
ENDM

show_path_dame MACRO board,i1,j1,turn1,path1,path2,pawn_position,makla1
    LOCAL next_direction, long_move, long_move1, next, continue, end
   
    set_array_null dameMoves
    set_array_null dameIndMoves

    set_show_values i1, j1, turn1

    ;-------------DIRECT--------------------------
    LEA DI,dameIndMoves
    LEA SI,dameMoves

    MOV CX,4
    next_direction:
        PUSH CX
        PUSH DI

        MOV AL,'y' ; direct direct
        MOV isDirect,AL 

        long_move:

           dame_4_directions x,y
                            
            PUSH SI
            verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]
            POP SI
            
            cmp verified,1
            JNE next

            MOV BYTE PTR [SI],n2 ; byte pointer
            INC SI
            
            JMP long_move 

        next:

        dame_4_directions x,y
        dame_4_directions x,y ; +2 (to check if there is an indirect move)

        MOV AL,'n' ; direct direct
        MOV isDirect,AL 
        
        verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]

        POP DI
        CMP verified,1
        JNE continue

            save_dame_makla isDirect ; isDirect return the makla num (in verify_move)

            ;----------------the long path where we can go after making makla-------------------
            long_move1: ; save the data in direct & indirect move

                MOV BYTE PTR [SI],n2 ; direct move
                INC SI
                MOV BYTE PTR [DI],n2 ; indirect move
                INC DI

                dame_4_directions x,y 

                MOV AL,'y' ; direct 
                MOV isDirect,AL 

                PUSH DI
                PUSH SI
                verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]
                POP SI
                POP DI

                cmp verified,1
                JNE continue
                
            JMP long_move1 

        continue:
        
        MOV BH,i
        MOV CH,j

        MOV x,BH
        MOV y,CH
        
        POP CX
    LOOP next_direction   

    ; end:
ENDM

;------set_show_values ------------------------
set_show_values MACRO i1,j1,turn1

    MOV DL,i1
    MOV DH,j1
    mov i,DL  ;i<-dl
    mov j,DH  ;j<-dh

    MOV x,DL ; BH<-x
    MOV y,DH ; CH<-y 
                
    MOV AH,turn1 
    MOV turn,AH   
    
    MOV AL,-1 ;
    MOV path1,AL
    MOV path2,AL ; in case there's no move

ENDM


;-----dame_4_directions------------------------------
dame_4_directions MACRO x1,y1
    LOCAL end, up_left, up_right, down_right
    
    MOV AL,x1
    MOV BL,y1
    MOV x,AL
    MOV y,BL

    CMP CX,4
    JE up_right
        CMP CX,3
        JE up_left
            CMP CX,2
            JE down_right
                ;----down_left------
                    DEC y ; y<-(j-1)  
                    INC x ; x<-(i+1) 
                    JMP end
            down_right:
                INC y ; y<-(j+1)  
                INC x ; x<-(x+1) 
                JMP end
        up_left:
            DEC y ; y<-(j-1)  
            DEC x ; x<-(i-1) 
            JMP end
    up_right:
        DEC y ; y<-(j-1)  
        INC x ; x<-(i+1) 

    end:
ENDM

;-------save_dama_makla
save_dame_makla MACRO n
    LOCAL end, up_left, up_right, down_right
    
    MOV AL,n

    CMP CX,4
    JE up_right
        CMP CX,3
        JE up_left
            CMP CX,2
            JE down_right
                ;----down_left------
                    MOV makla3, AL
                    JMP end
            down_right:
                MOV makla4, AL
                JMP end
        up_left:
            MOV makla1, AL
            JMP end
    up_right:
        MOV makla2, AL

    end:

ENDM    



;-----switch_turn--------------------------------
switch_turn MACRO turn
    LOCAL switch,next_move
          
    mov AL,1
    cmp AL,switcher
    JE switch
        mov AL,'b'
        mov turn,AL
        mov AX, blackPiece ; the black side color
        MOV PColor,AX
        JMP next_move
    switch:
        mov AL,'w'
        mov turn,AL
        mov AX,whitePiece ; the white side color
        MOV PColor,AX
    next_move:

    MOV AL,switcher
    MOV BL,-1
    MUL BL
    MOV switcher,AL
ENDM


check_state_game MACRO IndMoves, directMoves, winner ; if winner = 1 -> the opponent is the winner
    LOCAL continue, end
    
    CMP IndMoves[0], 0
    JNE continue
        CMP directMoves[0], 0
        JNE continue
            MOV AL, 1
            MOV winner, AL
            JMP end
    continue:
        MOV AL, 0
        MOV winner, AL    
    end:

ENDM


setCursorPosition MACRO row, column, page
        MOV AX, 0200h
        MOV BH, page
        MOV DL, column
        MOV DH, row
        INT 10H
    ENDM

    __printGraphicalCharacter PROC ; character, color
        PUSH BP
        MOV BP, SP

        ; * [BP + 6]: character
        ; * [BP + 4]: color

        MOV AH, 0Ah
        MOV AL, [BP + 6]
        XOR BH, BH
        MOV CX, 1

        INT 10h

        MOV SP, BP
        POP BP
        RET 4
    __printGraphicalCharacter ENDP

    printGraphicalCharacter MACRO character, color
        MOV AL, character
        XOR AH, AH
        PUSH AX

        MOV AX, color
        PUSH AX

        CALL __printGraphicalCharacter
    ENDM

__printBoardWithOffset PROC ; board, color, xOffset, yOffset
        PUSH BP
        MOV BP, SP
        SUB SP, 2
    
        ; * [BP + 10]: board
        ; * [BP +  8]: color
        ; * [BP +  6]: xOffset
        ; * [BP +  4]: yOffset
    
        MOV WORD PTR [BP - 2], 0505h
    
        MOV SI, [BP + 10]               ; board
        MOV BX, [BP + 8]                ; color
        MOV DL, BYTE PTR [BP + 6]       ; xOffset
        MOV DH, BYTE PTR [BP + 4]       ; yOffset
    
        __printBoardWithOffset_L1:
            
            ; Draw cells in pairs
            __printBoardWithOffset_L2:
                ; First cell in pair
                setCursorPosition DH, DL, 0
                printGraphicalCharacter 2Eh, BX
                
                INC DL
                
                ; First space in pair
                setCursorPosition DH, DL, 0
                printGraphicalCharacter ' ', BX
    
                INC DL
    
                ; Second cell in pair
                setCursorPosition DH, DL, 0
    
                MOV AL, BYTE PTR [SI]
                printGraphicalCharacter AL, BX
    
                INC SI
                INC DL
    
                ; Second space in pair
                setCursorPosition DH, DL, 0
                printGraphicalCharacter ' ', BX
    
                INC DL
    
                DEC WORD PTR [BP - 2]
                TEST WORD PTR [BP - 2], 00FFh
            JNZ __printBoardWithOffset_L2
            
            INC DH
            MOV DL, BYTE PTR [BP + 6]
            DEC BYTE PTR [BP - 3]
            MOV BYTE PTR [BP - 2], 05h
    
            __printBoardWithOffset_L3:
                ; First cell in pair
                setCursorPosition DH, DL, 0
    
                MOV AL, BYTE PTR [SI]
                printGraphicalCharacter AL, BX
    
                INC SI
                INC DL
    
                ; First space in pair
                setCursorPosition DH, DL, 0
                printGraphicalCharacter ' ', BX
    
                INC DL
    
                ; Second cell in pair
                setCursorPosition DH, DL, 0
                printGraphicalCharacter 2Eh, BX
                
                INC DL
                
                ; Second space in pair
                setCursorPosition DH, DL, 0
                printGraphicalCharacter ' ', BX
    
                INC DL
    
                DEC WORD PTR [BP - 2]
                TEST BYTE PTR [BP - 2], 00FFh
            JNZ __printBoardWithOffset_L3
            
            INC DH
            MOV DL, BYTE PTR [BP + 6]
            DEC BYTE PTR [BP - 1]
            MOV BYTE PTR [BP - 2], 05h
            
            TEST [BP - 2], 0FF00h
            JZ __printBoardWithOffset_endLabel
        JMP __printBoardWithOffset_L1
    
        __printBoardWithOffset_endLabel:
    
        MOV SP, BP
        POP BP
        RET 8
    __printBoardWithOffset ENDP
    
    printBoardWithOffset MACRO board, color, xOffset, yOffset
        LEA AX, board
        PUSH AX
    
        MOV AX, color
        PUSH AX
    
        MOV AX, xOffset
        PUSH AX
    
        MOV AX, yOffset
        PUSH AX
    
        CALL __printBoardWithOffset
    ENDM


;-----------------AI-------------------
isPileEmpty MACRO pileTaille,result
    LOCAL empty, notEmpty,endPileEmpty
    CMP pileTaille, 0
    JE empty
        JMP notEmpty
    empty:
        MOV AL, 1
        MOV result,AL
        JMP endPileEmpty
    notEmpty:
        MOV AL, 0
        MOV result,AL
    endPileEmpty:
ENDM
;--------------------------------------
;--------------------------------------
pushPile MACRO pileTaille,node,weight
    MOV AX,0
    MOV AH,weight
    MOV AL,node
    PUSH AX
    INC pileTaille
ENDM
;--------------------------------------
popPile MACRO pileTaille,node,weight
    MOV AX,0
    POP AX
    MOV node,AL
    MOV weight,AH
    DEC pileTaille
ENDM

;--------------------------------------
getPawnQueen MACRO board,node,turn,weightTmp
    LOCAL queen,pawn,next,next2,endGetPawn
    MOV weightTmp,0
    
    MOV BX,0
    MOV BL,node
    DEC BL
    queen:
    MOV AL,Board[BX]
    CMP AL,'B'
    JNE next
    MOV weightTmp,10
    JMP endGetPawn
    next:
    MOV AL,Board[BX]
    CMP AL,'W'
    JNE pawn
    MOV weightTmp,10
    JMP endGetPawn

    pawn:
    MOV AL,Board[BX]
    CMP AL,'b'
    JNE next2
    MOV weightTmp,1
    JMP endGetPawn

    next2:
    CMP Board[BX],'w'
    MOV weightTmp,1

    endGetPawn:
ENDM
;--------------------------------------
copyPath MACRO maxpath,path,pathTaille
    LOCAL boucle
    LEA SI,maxpath
    LEA DI,path
    XOR CX,CX
    MOV CL,pathTaille

    boucle:
        MOV AL,[DI]
        MOV [SI],AL
        INC SI
        INC DI

        LOOP boucle
ENDM
;--------------------------------------
preOrder MACRO pileTaille,root,weight,path
    LOCAL bouclePreOrder,restofcode,rightPre,rest1,left,rest2,feuilles,estFeuilles,cond1,cond2,last,endPreOrder,change
    MOV weight,0
    pushPile pileTaille,root,weight
    MOV pathSizeArrayIndex,1
    MOV pathSizeArray[0],0
    bouclePreOrder:
            isPileEmpty pileTaille,AL
            CMP AL,1
            JNE restofcode
            JMP endPreOrder
        restofcode:
            
            popPile pileTaille,root,weight
            
            MOV BX,0
            DEC pathSizeArrayIndex
            MOV BL,pathSizeArrayIndex
            MOV AL,pathSizeArray[BX]
            MOV pathTaille,AL
            MOV BL,pathTaille
            MOV BH,0
            MOV AL,root
            MOV path[BX],AL
            ADD pathTaille,1
            get_column root , jAI
            get_row root ,  iAI
            ;printBoardWithOffset board, 000fh, 0, 0
            XOR BX,BX
            MOV BL,root
            DEC BL
            MOV AL,board[BX]
            MOV tmp,AL
            MOV AL,turn
            MOV board[BX],AL
            show_path board,iAI,jAI,turn,path1,path2,pawn_position,makla1,makla2
            XOR BX,BX
            MOV BL,root
            DEC BL
            MOV AL,tmp
            MOV board[BX],AL
        
            rightPre:
                CMP makla2,-1
                JNE rest1
                JMP left
                rest1:
                
                getPawnQueen board,makla2,turn,weightTmp
                MOV AL,weight
                ADD weightTmp,AL
                pushPile pileTaille,path2,weightTmp
                MOV BX,0
                MOV BL,pathSizeArrayIndex
                MOV AL,pathTaille
                MOV pathSizeArray[BX],AL
                inc pathSizeArrayIndex
    
            left:
                CMP makla1,-1
                JNE rest2
                JMP feuilles
                rest2:
                
                getPawnQueen board,makla1,turn,weightTmp
                MOV AL,weight
                ADD weightTmp,AL
                pushPile pileTaille,path1,weightTmp
                MOV BX,0
                MOV BL,pathSizeArrayIndex
                MOV AL,pathTaille
                MOV pathSizeArray[BX],AL
                inc pathSizeArrayIndex
            
            estFeuilles:
                cond1:
                    CMP makla2,-1
                    JE cond2
                    JMP bouclePreOrder
                cond2:
                    CMP makla1,-1
                    JE feuilles
                    JMP bouclePreOrder
                

    
            feuilles:
                get_row root ,iAI
                CMP iAI,0
                JNE bturn
                JMP isPromoted
                bturn:
                get_row root ,iAI
                CMP iAI,9
                JNE last
                
                isPromoted:
                ADD weight,9
                last:
                MOV AL, weight
                CMP AL, maxWeight
                JA change
                JMP bouclePreOrder
                change:
                    MOV AL,weight
                    MOV maxWeight,AL
                    copyPath maxpath,path,pathTaille
                    
                JMP bouclePreOrder
    endPreOrder:
ENDM
;--------------------------------------
 pionWeight MACRO root,weight
     LOCAL path1Ver,path2Ver,path3Ver,changeP,endPionWeight   
     
           get_column root , jAI
           get_row root ,  iAI
           show_path board,iAI,jAI,turn,path1,path2,pawn_position,makla1,makla2
           
           path1Ver:
            pionPromoted path1,iAI,al
            CMP al,1
            JNE path2Ver
            MOV weight,9
            JMP path3Ver
            
           path2Ver:
            pionPromoted path2,iAI,al
            CMP al,1
            JNE path3Ver
            MOV weight,9
            
           path3Ver:  
           MOV AL, weight
           CMP AL, maxWeight
           JA changeP
           JMP endPionWeight
              changeP:
                 MOV AL,weight
                 MOV maxWeight,AL
                 
           endPionWeight:
 ENDM   
;--------------------------------------
pionPromoted Macro num,turn,result
    LOCAL blackSide,restB,whiteSide,endPionPromoted
    
    Mov result,0
    blackSide:
        CMP turn,'b'
        JE restB
        JMP whiteSide
        
        restB:
        get_row num ,i
        CMP i,9
        JNE endPionPromoted
        MOV result,1
        
        
        JMP endPionPromoted
    whiteSide:
        
        get_row num ,i
        CMP i,0
        JNE endPionPromoted
        MOV result,1
        
    endPionPromoted:
    
ENDM
;--------------------------------------
enemyMove MACRO board, turn, maklaSif , weight , maxWeight , path , bestPath 
    LOCAL indirectEnemyMove,MaklaSifPart,enemyRest,directEnemyMove,Before,enemyRestP,finEnemyMove 
    
    MOV maxWeight,0
    show_moves  board, indMoves, directMoves
    MOV indice,0
    indirectEnemyMove:   
        MOV BX,0
        MOV BL,indice
        MOV AL,indMoves[BX]
        CMP AL,0
        JNE enemyRest
        JMP Before
        enemyRest:
        
            MOV AL,indMoves[BX]
            MOV root,AL
            preOrder pileTaille,root,weight,path 
        
            INC indice
        JMP indirectEnemyMove 

        MaklaSifPart:
        CMP maklaSif,1
        JNE Before
        JMP finEnemyMove
    
    
    Before:
    
    MOV indice,0
    directEnemyMove:
           
            MOV BX,0
            MOV BL,indice
            MOV AL,directMoves[BX]
            CMP AL,0
            JNE enemyRestP
            JMP finEnemyMove
            enemyRestP:
               
               MOV weight,0
               MOV BX,0
               MOV BL,indice
               MOV AL,directMoves[BX]
               MOV root,AL
               pionWeight root,weight
    
            INC indice                                
            JMP directEnemyMove

    finEnemyMove:


ENDM



;--------------------------------------
aipreOrder MACRO
    LOCAL boucleaiPreOrder,restofcode,rightPre,rest1,left,rest2,feuilles,estFeuilles,cond1,cond2,last,endaiPreOrder,change,isPromoted
    MOV aiweight,0
    pushPile aipileTaille,airoot,aiweight
    MOV aipathSizeArrayIndex,1
    MOV aipathSizeArray[0],0
    boucleaiPreOrder:
            isPileEmpty aipileTaille,AL
            CMP AL,1
            JNE restofcode
            JMP endaiPreOrder
        restofcode:
            
            popPile aipileTaille,airoot,aiweight
            
            MOV BX,0
            DEC aipathSizeArrayIndex
            MOV BL,aipathSizeArrayIndex
            MOV AL,aipathSizeArray[BX]
            MOV aipathTaille,AL
            MOV BL,aipathTaille
            MOV BH,0
            MOV AL,airoot
            MOV aipath[BX],AL
            ADD aipathTaille,1
            get_column airoot , jAI2
            get_row airoot ,  iAI1
            ;printBoardWithOffset board, 000fh, 0, 0
            XOR BX,BX
            MOV BL,airoot
            DEC BL
            MOV AL,board[BX]
            MOV aitmp,AL
            MOV AL,aiturn
            MOV board[BX],AL
            show_path board,iAI1,jAI2,aiturn,aipath1,aipath2,pawn_position,aimakla1,aimakla2
            XOR BX,BX
            MOV BL,airoot
            DEC BL
            MOV AL,aitmp
            MOV board[BX],AL
        
            rightPre:
                CMP aimakla2,-1
                JNE rest1
                JMP left
                rest1:
                
                getPawnQueen board,aimakla2,aiturn,aiweightaiTmp
                MOV AL,aiweight
                ADD aiweightaiTmp,AL
                pushPile aipileTaille,aipath2,aiweightaiTmp
                MOV BX,0
                MOV BL,aipathSizeArrayIndex
                MOV AL,aipathTaille
                MOV aipathSizeArray[BX],AL
                inc aipathSizeArrayIndex
    
            left:
                CMP aimakla1,-1
                JNE rest2
                JMP feuilles
                rest2:
                
                getPawnQueen board,aimakla1,aiturn,aiweightaiTmp
                MOV AL,aiweight
                ADD aiweightaiTmp,AL
                pushPile aipileTaille,aipath1,aiweightaiTmp
                MOV BX,0
                MOV BL,aipathSizeArrayIndex
                MOV AL,aipathTaille
                MOV aipathSizeArray[BX],AL
                inc aipathSizeArrayIndex
            
            estFeuilles:
                cond1:
                    CMP aimakla2,-1
                    JE cond2
                    JMP boucleaiPreOrder
                cond2:
                    CMP aimakla1,-1
                    JE feuilles
                    JMP boucleaiPreOrder
                

    
            feuilles:
                get_row airoot ,iAI1
                CMP iAI1,0
                JNE baiturn
                JMP isPromoted
                baiturn:
                get_row airoot ,iAI1
                CMP iAI1,9
                JNE last
                
                isPromoted:
                ADD aiweight,9
                last:
                copyBoard board,board2
                MakeMoveAI board2,path
                enemyMove board2,turn , maklaSif , weight , maxWeight , path , bestPath
                MOV AL, aiweight
                SUB AL, maxWeight
                
                MOV aiweight,AL
                CMP AL, maxaiWeight
                JA change
                JMP boucleaiPreOrder
                change:
                    MOV AL,aiweight
                    MOV maxaiWeight,AL
                    copyPath maxaipath,aipath,aipathTaille
                    
                JMP boucleaiPreOrder
    endaiPreOrder:
ENDM
;--------------------------------------
 pionaiWeight MACRO airoot,aiweight
     LOCAL aipath1Ver,aipath2Ver,aipath3Ver,changeP,endPionaiWeight   
     
           get_column airoot , jAI2
           get_row airoot ,  iAI1
           show_path board,iAI1,jAI2,aiturn,aipath1,aipath2,pawn_position,aimakla1,aimakla2
           
           aipath1Ver:
            pionPromoted aipath1,iAI1,al
            CMP al,1
            JNE aipath2Ver
            MOV aiweight,9
            JMP aipath3Ver
            
           aipath2Ver:
            pionPromoted aipath2,iAI1,al
            CMP al,1
            JNE aipath3Ver
            MOV aiweight,9
            
           aipath3Ver:  
           MOV AL, aiweight
           CMP AL, maxaiWeight
           JA changeP
           JMP endPionaiWeight
              changeP:
                 MOV AL,aiweight
                 MOV maxaiWeight,AL
                 
           endPionaiWeight:
 ENDM   

;-------------------------------------- 
MakeMoveAI MACRO board,path
   LOCAL boucle22,finMove
    MOV BX,0
    boucle22:
        MOV al,path[bx]
        INC BX
        MOV ah,path[bx]
        CMP ah,0
        JNE next1
        JMP finMove
        
        next1:
        MOV n1,al
        MOV n2,ah
        PUSH BX
        XOR BX,BX
        MOV BL,AL
        DEC BL
        MOV AL,board[BX]
        MOV PColor,AL
        MakeAMove board,n1,n2,PColor
        Move_GUI n1,n2,PColor
        POP BX
        JMP boucle22                
    finMove:
ENDM
;--------------------------------------
aiMove MACRO board, aiturn, maklaSif , aiweight , maxaiWeight , aipath , bestaiPath 
    LOCAL indirectEnemyMove,MaklaSifPart,enemyRest,directEnemyMove,Before,enemyRestP,finEnemyMove 
    
    MOV maxaiWeight,0
    show_moves  board, aiindMoves, aidirectMoves
    MOV aiindice,0
    indirectEnemyMove:   
        MOV BX,0
        MOV BL,aiindice
        MOV AL,aiindMoves[BX]
        CMP AL,0
        JNE enemyRest
        JMP Before
        enemyRest:
        
            MOV AL,aiindMoves[BX]
            MOV airoot,AL
            aipreOrder 
        
            INC aiindice
        JMP indirectEnemyMove 

        MaklaSifPart:
        CMP maklaSif,1
        JNE Before
        JMP finEnemyMove
    
    
    Before:
    
    MOV aiindice,0
    directEnemyMove:
           
            MOV BX,0
            MOV BL,aiindice
            MOV AL,aidirectMoves[BX]
            CMP AL,0
            JNE enemyRestP
            JMP finEnemyMove
            enemyRestP:
               
               MOV aiweight,0
               MOV BX,0
               MOV BL,aiindice
               MOV AL,aidirectMoves[BX]
               MOV airoot,AL
               pionaiWeight airoot,aiweight
    
            INC aiindice                                
            JMP directEnemyMove

    finEnemyMove:


ENDM 
    

MakeAMove Macro board,n1,n2,PColor
        LOCAL MoveApply,MoveG,MoveD,MoveDownD,MoveTopD,MoveDownG,MoveTopG,FinMove,rest23,notMove1, notMove2, notMove3, notMove4
        MoveApply:
            MOV AL,n1
            CMP AL,n2

            JNZ notMove1
            JMP FinMove
            notMove1:

            get_column n1,DL
            get_column n2,DH

            CMP DL,DH

            JB MoveD
            JMP MoveG

            MoveD:
               get_Row n1,CL
               get_Row n2,CH

               CMP CL,CH
               JB MoveDownD
               JMP MoveTopD

               MoveDownD:
                  CMP DL,DH
                  JNZ notMove2
                  JMP FinMove
                  notMove2:
                  PUSH DX
                  PUSH CX

                  MOV x,DL
                  MOV y,CL
                  get_number2 x, y, n3
                  MOV BX,0
                  MOV BL,n3
                  DEC BL
                  MOV board[BX],'0'

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

                  MOV x,DL
                  MOV y,CL
                  get_number2 x, y, n3
                  MOV BX,0
                  MOV BL,n3
                  DEC BL
                  MOV board[BX],'0'   

                  POP CX
                  POP DX
                  ADD DL,1
                  SUB CL,1
                  JMP MoveTopD

            MoveG:
               get_Row n1,CL
               get_Row n2,CH

               CMP CL,CH
               JAE MoveTopG

               MoveDownG:
                  CMP DL,DH
                  JNZ notMove4
                  JMP FinMove
                  notMove4:
                  PUSH DX
                  PUSH CX
                  
                  MOV x,DL
                  MOV y,CL
                  get_number2 x, y, n3
                  MOV BX,0
                  MOV BL,n3
                  DEC BL
                  MOV board[BX],'0'   

                  POP CX
                  POP DX
                  SUB DL,1
                  ADD CL,1
                  JMP MoveDownG

               MoveTopG:
                  CMP DL,DH
                  JNE rest23
                  JMP FinMove
                  rest23:
                  PUSH DX
                  PUSH CX

                  MOV x,DL
                  MOV y,CL
                  get_number2 x, y, n3
                  MOV BX,0
                  MOV BL,n3 
                  DEC BL
                  MOV board[BX],'0'  

                  POP CX
                  POP DX
                  SUB DL,1
                  SUB CL,1
                  JMP MoveTopG
            JMP MoveApply
        FinMove:
            MOV x,DL
            MOV y,CL
            get_number2 x, y, n3
            MOV BX,0
            MOV BL,n3
            DEC BL
            MOV AL,PColor
            MOV board[BX],AL
    

ENDM


copyBoard MACRO board,board2
    LOCAL boucle,finCopy
    MOV BX,49
    boucle:
           CMP BX,-1
           JNE rest
           JMP finCopy
           rest:
           
           MOV al,board[BX]
           MOV board2,al
           
           DEC BX
           JMP boucle
    finCopy:
      
        
ENDM



    START:
       MOV AX, @DATA
       MOV DS, AX    
        
        MOV board[36],'W'
           
            
        
        MOV board[27],'b'
        
        MOV board[31],'W' 
        
        MOV board[41],'W'
        MOV board[46], 'w'
        MOV board[12],'0'
        MOV board[14],'0'
        MOV board[37],'0'
        MOV board[21],'W'
        MOV board[30],'w'
        
        MOV board[26],'0'
        MOV board[35],'0'
        ;MOV board[09],'b'
         MOV n1,32
        MOV n2,23
        ;MOV board[19],'b'
        

         MOV airoot,34
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
        ;MOV indMoves[0],10
        
        ;show_moves  board, indMoves, directMoves      
        ;printBoardWithOffset board, 000fh, 0, 0  
        
        
        ;MakeAMove n1,n2,aiturn
        ;MOV BX,0
        ;MOV BL,n1
        ;DEC BL
        ;MOV AL,board[BX]
        ;MOV PColor,AL
        ;MakeAMove board,n1,n2,PColor
        
        ;printBoardWithOffset board, 000fh, 0, 0
        enemyMove board, turn, maklaSif , weight , maxWeight , path , bestPath
        ;aipreOrder 
        ;aiMove board, aiturn, maklaSif , aiweight , maxaiWeight , aipath , bestaiPath
        MakeMoveAI board,maxpath        
        printBoardWithOffset board, 000fh, 0, 0 

        ;enemyMove board,turn , maklaSif , weight , maxWeight , path , bestPath
END START

   
