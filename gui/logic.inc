.model small
;DATA SEGMENT 
.data
    n1 db ?
    n2 db ?   
    i DB ?
    j DB ? 
    i1 DB ?
    j1 DB ?
    x DB ?
    y DB ?
    xDame DB ?  ; need to save makla
    yDame DB ?
    pawn_position DB ?
    state DB ?  
    switcher DB 1
    checked DB ?
    dest DB ?
    val1 DB ?
    val2 DB ? 
    menu DB ? 
    verified DB ?
    dameIndMoves DB 20 dup(?)
    dameMoves DB 20 dup(?) ; makla i (i e (1->4))
    bool DB 0 ; need it in showpaths 
    num1 DB ? 
    msg_result DB "result: $"
    valid DB ?
    boolProm DB ?

    ; isValid     DB      ?
    ; count       DB      0
    ; saveData    DW      ?
    
    ; source_pawn     DB      ?
    ; turn            DB      'b'
    ; path1           DB      ?
    ; path2           DB      ?
    ; tmp             DB      ?
    ; num             DB      ?
    ; makla1          DB      ?
    ; makla2          DB      ?
    ; makla3          DB      ?
    ; makla4          DB      ?
    ; x1              DB      ?
    ; y1              DB      ?
    ; check_direct    DB      ?
    ; isDirect        DB      ?
    ; maklaSif        DB      1
    ; typePawn        DB      ?  ; 0 -> pawn / 1-> dame
    ; color           DB      ?
    ; board           DB  20 DUP('b'), 10 DUP('0'), 20 DUP('w') 
    
    ;  directMoves     DB  20 dup(?)
    ; IndMoves        DB  20 dup(?) 


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
get_cell_state MACRO board,i,j,color, typePawn
    LOCAL white_cell, end_label, endColor_label, white_piece, pawn, empty_cell    ; LOCAL LABELS
        
        ; MOV AL,-1
        ; MOV typePawn,AL
        ; MOV color, -1
        
        MOV DL, i
        MOV DH, j
        get_number DL, DH, menu, AL        ; Le macro de la question C (Fait par Abdou & Omar)
        
        XOR AH, AH
        MOV SI, AX
        MOV AL, board[SI - 1]

        CMP board[SI - 1], '0'
        JE empty_cell
        
        CMP board[SI - 1], 'w'
        JZ white_piece
        CMP board[SI - 1], 'W'
        JZ white_piece

        MOV color, 'b'
        JMP endColor_label

        white_piece:
        mov color, 'w'

        endColor_label:

        CMP board[SI - 1], 'w'
        JZ pawn
        CMP board[SI - 1], 'b'
        JZ pawn

        MOV typePawn, 1
        JMP end_label

        pawn:
        MOV typePawn, 0
        JMP end_label

        empty_cell:
        MOV color, '0'
    
    end_label: 
ENDM
   
   
;----------verify_move----------------   
verify_move MACRO board, i, j, x, y, turn, verified, isDirect, val1, val2
    LOCAL impossible_move, done, other_way, down, end, next,impossible_move1,pawn,dame,impossible_move2,continue,continue1,label1
    ;DL=i DH=j BH=x CH=y | i and j must be between 1-10 -> (0-9) 'we do the check in get_number & 'DEC 1' in the main'  

    get_number i, j, menu, n1 
        CMP n1,0 ; 0 -> white cell 'invalid' (check get_number)
        JNE impossible_move1  ; checking if it's a valid input 
            JMP impossible_move
        impossible_move1:
    get_cell_state board, i, j, color, typePawn
        MOV AL, color
        CMP AL, turn ; to make the move -> 'w'='w' / 'b'='b' else impossible_move
        JE continue
            JMP impossible_move
        continue:
    
    get_number x, y, menu, n2 ; menu <- null doesnt effect  
        CMP n2,0 
        JNE impossible_move2 ; checking if it's a valid input
            JMP impossible_move
        impossible_move2:
    get_cell_state board, x, y, color, typePawn        
        CMP color, '0' ; to make the move -> board[x,y] needs to be empty '0'
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
    
    CMP typePawn,0
    JE pawn
       MOV DL,xDame
       MOV DH,yDame   
       JMP dame   
    pawn:
    
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
    
    dame:
    get_number DL,DH , menu, isDirect ; isDirect return makla number (for optimization) 'indirect move'
    get_cell_state board, DL, DH, color, typePawn  ; depends on the colors (white -> black/ black ->white)
    CMP color,'0' ; one step (not for dames)
    JE impossible_move 
    MOV AL,turn 
    CMP AL,color ; to make the move -> state needs to be the color of the opposing player (enemy) 
    JNE done ; make the move
        
    impossible_move:
        MOV verified,0 
        JMP end
    done:
        MOV verified,1   
    end:
ENDM 


;------move_pawn---------- 

move_pawn MACRO board,x,y,path1,path2,pawn_position,makla1,makla2,dest
    LOCAL end, indirect, move, move1, no_move, next  
    MOV BH,x ; cant use the other registers cuz are used in get_number 
    MOV CH,y 

    get_number BH,CH,menu,num1
    MOV BH,num1
    MOV dest,BH
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
        ; MOV AL,num
        ; MOV isDirect, AL
        JMP end
    no_move:
        MOV AL,-1
        MOV dest,AL
    end:
ENDM


;---------move_dame-----------------------------
move_dame MACRO board,x1,y1,dameMoves,dameIndMoves,pawn_position,makla1,makla2, makla3, makla4,dest
    LOCAL end, direct_move, move, move1, no_move, next , next1

    MOV BH,x1 ; cant use the other registers cuz are used in get_number 
    MOV CH,y1

    MOV x,BH
    MOV y,CH 

    get_number x,y,menu,num1
    MOV BH,num1
    MOV dest,BH
    
    is_value_in_array x, y, dameIndMoves, bool
    CMP bool, 1
    JE next1
        JMP direct_move
    next1:
        XOR AX, AX   
        MOV AL, pawn_position
        DEC AL   
        MOV DI, AX  
          
        ;MOV AL, BH ; BH <- board[x,y]
        MOV AL, num ; BH <- board[x,y]
        DEC AL   
        MOV SI, AX   

        MOV AL,board[DI] ;---INDIRECT MOVE---------
        MOV board[DI],'0'
        MOV board[SI],AL 

        find_makla_dame num,maklaD
        XOR AH,AH
        MOV AL, maklaD
        DEC AL  
        MOV DI, AX    
        MOV AL,board[DI]
        MOV board[DI],'0'
        JMP end

    direct_move:

    is_value_in_array x, y, dameMoves, bool
    CMP bool, 1
    JNE no_move
        XOR AX, AX   
        MOV AL, pawn_position
        DEC AL   
        MOV DI, AX    

        ;MOV AL, BH ; BH <- board[x,y]
        MOV AL, num ; BH <- board[x,y]
        DEC AL   
        MOV SI, AX  

        MOV AL,board[DI] ;---DIRECT MOVE---------
        MOV board[DI],'0'
        MOV board[SI],AL                    
        JMP move

    move:
        ; MOV AL,dest
        ; MOV isDirect, AL
        JMP end
    no_move:
        MOV AL,-1
        MOV dest,AL
    end:
ENDM

;----find_makla_dame-------------
find_makla_dame MACRO num,maklaD
    LOCAL up_right, up_left, down_right, down_left, end

    LEA SI, dameIndMoves
    MOV AH,num
 
    DEC SI   
    
    up_right: 
    INC SI
        
    MOV AL, makla1
    CMP BYTE PTR [SI], 'p'
    JE up_left
        CMP BYTE PTR [SI], AH
        JNE up_right
        MOV maklaD, AL ; <- makla1
        JMP end
    
    up_left:
    INC SI

    MOV AL,makla2
    CMP BYTE PTR [SI], 'p'
    JE down_right
        CMP BYTE PTR [SI], AH
        ; INC SI
        JNE up_left
        MOV maklaD, AL ; <- makla2
        JMP end

    down_right:
    INC SI

    MOV AL,makla3
    CMP BYTE PTR [SI], 'p'
    JE down_left
        CMP BYTE PTR [SI], AH
        ; INC SI
        JNE down_right
        MOV maklaD, AL ; <- makla3
        JMP end

    down_left:
    
    INC SI
    MOV AL,makla4
    CMP BYTE PTR [SI], 0
    JE end
        CMP BYTE PTR [SI], AH
        ; INC SI
        JNE down_left
        MOV maklaD, AL ; <- makla4

    end:

ENDM


;------show_path----------
show_path MACRO board,i1,j1,turn1,path1,path2,pawn_position,makla1,makla2
    LOCAL end, next, next1, not_verified, not_verified1, not_verified2,  down, down1, label1, label2, label3, continue, continue1
    
    set_show_values i1,j1,turn1

    MOV BH,x 
    MOV CH,y                  

    get_cell_state board, i, j, color, typePawn
    MOV AL, typePawn
    CMP AL, 0 ; to make the move -> 'w'='w' / 'b'='b' else impossible_move
    JE continue  
        JMP end
    continue:
    
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
        CMP maklaSif, 1
        JE continue1
            CMP makla1, -1
            JE label1
            CMP makla2, -1
            JE label1
        continue1:
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


;----------show_path_dame------------------------------
show_path_dame MACRO board,i1,j1,turn1,dameMoves,dameIndMoves,pawn_position,makla1,makla2,makla3,makla4 
    LOCAL next_direction, long_move, long_move1, next, next1, continue,continue1, end, lab1, lab2, lab3, end1, direct1 
   
    set_array_null dameMoves
    set_array_null dameIndMoves 
    
    MOV DL,i1
    MOV DH,j1
    mov i,DL  ;i<-dl
    mov j,DH  ;j<-dh

    set_show_values i1, j1, turn1
   
    MOV makla3,AL ; <- (-1)
    MOV makla4,AL ; <- (-1)

    get_cell_state board, i, j, color, typePawn 
    MOV AL, typePawn
    CMP AL, 1  ; to make the move -> 'w'='w' / 'b'='b' else impossible_move
    JE continue1
        JMP end
    continue1:

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
        
           dame_4_directions x,y, valid
            CMP n1,1
            JNE lab1  ; checking 
                JMP continue
            lab1:

            PUSH SI
            PUSH CX
            verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]
            POP CX
            POP SI
            
            cmp verified,1
            JNE next
            
            MOV AL,n2
            MOV BYTE PTR [SI],AL ; byte pointer
            INC SI
            
            JMP long_move 

        next: 
        MOV AL,x 
        MOV xDame,AL 
        MOV AL,y
        MOV yDame,AL

        ;dame_4_directions x,y
        dame_4_directions x,y, valid
        CMP n1,1
        JNE lab2  ; checking 
            JMP continue
        lab2:

        MOV AL,'n' ; direct direct
        MOV isDirect,AL 
        
        PUSH SI
        PUSH CX
        verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2     ; n1[i,j] n2[x,y]
        POP CX
        POP SI
        
        POP DI
        CMP verified,1
        JE next1
            JMP continue
        next1: 
           ; get_number xDame,yDame,menu,isDirect       
            
            save_dame_makla isDirect ; isDirect return the makla num (in verify_move)

            ;----------------the long path where we can go after making makla-------------------
            long_move1: ; save the data in direct & indirect move
                
                MOV AL,n2
                MOV BYTE PTR [SI],AL ; direct move
                INC SI
                MOV BYTE PTR [DI],AL ; indirect move
                INC DI

                dame_4_directions x,y, valid
                CMP n1,1
                JNE lab3  ; checking 
                    JMP continue
                lab3:

                MOV AL,'y' ; direct 
                MOV isDirect,AL 

                PUSH DI
                PUSH SI
                PUSH CX
                verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]
                POP CX
                POP SI
                POP DI

                ; MOV AL,'n' ; direct direct
                ; MOV isDirect,AL

                cmp verified,1
                JNE continue
                
            JMP long_move1 

        continue:
        

        MOV BH,i
        MOV CH,j

        MOV x,BH
        MOV y,CH
        
        POP CX
        DEC CX
    CMP CX,0
    JE end
        MOV AL,'p' ; 'p' mark the end of each direction
        MOV BYTE PTR [SI],AL ; direct move
        INC SI
        MOV BYTE PTR [DI],AL ; indirect move
        INC DI

        JMP next_direction
         
    end: 

    LEA SI, dameIndMoves
    CMP BYTE PTR [SI+3],0
    JE direct1
        MOV AL, 'n'
        MOV isDirect, AL
        JMP end1   
    direct1:
        MOV AL, 'y'
        MOV isDirect, AL
    end1:
    ; MOV AL,1
    ; MOV typePawn,AL
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
    MOV makla1,AL
    MOV makla2,AL
    
ENDM


;-----dame_4_directions------------------------------
dame_4_directions MACRO x1,y1,valid
    LOCAL end, up_left, up_right, down_right, check, lab1
    
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
                    JMP check
            down_right:
                INC y ; y<-(j+1)  
                INC x ; x<-(x+1) 
                JMP check
        up_left:
            DEC y ; y<-(j-1)  
            DEC x ; x<-(i-1) 
            JMP check
    up_right:
        INC y ; y<-(j-1)  
        DEC x ; x<-(i+1) 

    check:

    get_number x, y, 'y', n1 
    CMP n1,'v'
    JNE lab1  ; checking 
        MOV valid,1
        JMP end
    lab1:
        MOV valid,0
    end:

ENDM

;-------save_dama_makla----------------------
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
                    MOV makla4, AL
                    JMP end
            down_right:
                MOV makla3, AL
                JMP end
        up_left:
            MOV makla2, AL
            JMP end
    up_right:
        MOV makla1, AL

    end:

ENDM    

;-----promotion-----------
promotion Macro dest,turn,boolProm
    LOCAL blackSide,restB,whiteSide,endPionPromoted


    XOR BX,BX
    MOV BL,dest 
    DEC BL
    MOV DI,BX
    MOV boolProm,0
    blackSide:
        CMP turn,'b'
        JE restB
        JMP whiteSide

        restB:
        get_row dest ,i
        CMP i,9
        JNE endPionPromoted
        MOV board[DI],'B'
        MOV boolProm,1

        ; XOR AX,AX
        ; MOV AL,dest
        ; call liveUsage

        JMP endPionPromoted
    whiteSide:

        get_row dest ,i
        CMP i,0
        JNE endPionPromoted
        MOV board[DI],'W'
        MOV boolProm,1

        ; XOR AX,AX
        ; MOV AL,dest
        ; call liveUsage

    endPionPromoted:

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


; START:
;     MOV AX, @DATA
;       MOV DS, AX        
    
;        MOV board[27],'b'    
        ; show_moves 'b', board, IndMoves, directMoves 
    
    
;     board_init board 
     
     
;     ;MOV al,1
;     ;mov path1,1
    
                                                               
;     move_pawn board,5,8,path1,path2,pawn_position,makla1,isDirect
;    ; show_path board,3,2,'b',path1,path2,pawn_position,makla1,isDirect  
;     print_board board 
;     ;get_number 9,8,'y',n1

; ;CODE ENDS
;  END START