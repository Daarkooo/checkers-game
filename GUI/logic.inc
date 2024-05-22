.model small

.data
    n1 db ?
    n2 db ?
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
    moves DB 50 dup(?)
    bool DB 0 ; need it in showpaths
    num1 DB ?
    msg_result DB "result: $"

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
        MOV BH,n2 ; need it in indirect for checking 1st,2nd,8th,last (9/11)<-(n1-n2)
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
    move_pawn MACRO board,x,y,path1,path2,pawn_position,makla,makla2,isDirect
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
        MOV makla,AH ; isDirect return maklaNum for path2

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

            MOV AL, makla
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
    show_path MACRO board,i1,j1,turn1,path1,path2,pawn_position,makla,makla2,isDirect_arg,multiple_jumps
        LOCAL end, next, next1, not_verified, not_verified1, not_verified2,  down, down1, label1, label2, label3

        MOV AL,isDirect_arg
        MOV isDirect,AL

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
            MOV makla,AH ; return maklaNum for path1
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

    show_path_dame MACRO board,i1,j1,turn1,path1,path2,pawn_position,makla,isDirect,multiple_jumps
        LOCAL end, next, next1, next2, next3, not_verified, not_verified1, not_verified2, not_verified3, down, down1, long_move, long_move1

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

        ;---------INDIRECT---------------- we prioritize the indirect move
        SUB BH,2  ; x<-(i-2)

        MOV CX,2
        down:
            PUSH CX

            MOV x,BH
            MOV AL,'n' ; not direct
            MOV isDirect,AL

            ADD CH,2 ; CH<-(y+2)
            MOV y,CH
            ;verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]

            CMP verified,0
            JE not_verified
                MOV bool,1
                MOV AH,n2
                MOV path1,AH
                MOV AH,isDirect
                MOV makla,AH ; return maklaNum for path1
            not_verified:
            MOV AL,'n' ; not direct
            MOV isDirect,AL

            MOV CH,j
            SUB CH,2 ; CH<-(y-2)
            MOV y,CH
            ;verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]

            CMP verified,0
            JE not_verified1
                MOV bool,1 ; isDirect'll return maklaNum for path2
                MOV AH,n2
                MOV path2,AH
            not_verified1:

            MOV BH,i
            MOV CH,j

            ADD BH,2 ; x<-(i+2)
            POP CX
        LOOP down

        CMP bool,1
        JE end ; if there's a move in indirect, isDirect'll return maklaNum -> isDirect != 'n'

        CMP multiple_jumps,1 ; need this after making the first move -> to avoid showing direct moves
        JNE end

        ;---------DIRECT----------------
        MOV BH,i
        MOV CH,j

        DEC BH ; x<-(i-1)

        MOV CX,2
        down1:
            PUSH CX
            MOV x,BH

            MOV AL,'y' ; direct direct
            MOV isDirect,AL
            INC CH ; CH<-(j+1)  ; a -> b
            MOV y,CH
            PUSH CX
            LEA SI,moves
            long_move:
                PUSH SI
                verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]
                POP SI

                cmp verified,1
                JNE next2

                MOV BYTE PTR [SI],n2 ; byte pointer
                INC SI

                INC CH ; CH<-(j+1)
                MOV y,CH

                MOV BH,x
                DEC BH ;  BH<-(x-1)
                MOV x,BH
                ; I need to check if I DEC BH (cx=2) or INC BH (cx=1)
                JMP long_move
            next2:

            POP CX

            MOV CH,j
            DEC CH ; CH<-(j-1)
            MOV y,CH

            MOV BH,i
            DEC BH ;  BH<-(i-1)
            MOV x,BH

            long_move1:
                PUSH SI
                verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]
                POP SI

                cmp verified,1
                JNE next3

                MOV BYTE PTR [SI],n2 ; byte pointer
                INC SI

                DEC CH ; CH<-(j-1)
                MOV y,CH

                MOV BH,x
                DEC BH ;  BH<-(x-1)
                MOV x,BH
                ; I need to check if I DEC BH (cx=2) or INC BH (cx=1)
                JMP long_move1

            next3:

            MOV BH,i
            MOV CH,j

            INC BH ; x<-(i+1)
            POP CX
        LOOP down1

        end:
    ENDM

    switch_turn MACRO turn
        LOCAL switch,next_move

        mov AL,1
        cmp AL,switcher
        JE switch
            mov AL,'b'
            mov turn,AL
            mov AX, whitePiece  ; the white side color
            MOV PColor,AX
            JMP next_move
        switch:
            mov AL,'w'
            mov turn,AL
            mov AX, blackPiece ; the black side color
            MOV PColor,AX
        next_move:

        MOV AL,switcher
        MOV BL,-1
        MUL BL
        MOV switcher,AL
    ENDM

    ;--------draw_borders---------------------
    draw_borders MACRO IndMoves, directMove, color
        LOCAL direct, show_M, show_Mm, end_moves, end_moves, end_moves1

        MOV AL,0
        MOV count,AL
        LEA SI, IndMoves
        show_M:
            CMP BYTE PTR [SI], 0
            JE end_moves1
            MOV AL,BYTE PTR [SI]
            MOV pawn_position,AL
            drawBorderCell pawn_position, color, offsetX, offsetY, cellSize
            INC SI
            INC count
            JMP show_M
        end_moves1:

        CMP count,0
        JE direct
            CMP maklaSif, 1
            JE end_moves
        direct:
        LEA SI, directMoves
        show_Mm:
            CMP BYTE PTR [SI], 0
            JE end_moves
            MOV AL,BYTE PTR [SI]
            MOV pawn_position,AL
            drawBorderCell pawn_position, color, offsetX, offsetY, cellSize
            INC SI
            JMP show_Mm
        end_moves:

    ENDM

    ;------set_array_null-----------
    set_array_null MACRO array
        LOCAL lab

        LEA SI, array
        lab:
            MOV BYTE PTR [SI], 0
            INC SI
            CMP BYTE PTR [SI], 0
            JNE lab

    ENDM

    ;---------show_moves-------------
    show_moves MACRO turn, board, IndMoves, directMoves
        LOCAL lab1, lab2, lab3, directMove,continue, endL

        set_array_null IndMoves
        set_array_null directMoves

        LEA SI, board
        LEA DI, IndMoves
        LEA BX, directMoves

        MOV CX, 50
        lab3:
            MOV AL,turn

                MOV DL,count
                PUSH CX
                PUSH BX

                get_row DL,i
                get_column DL,j

                PUSH SI
                PUSH DI
                show_path board,i,j,turn,path1,path2,source_pawn,makla,makla2,isDirect,multiple_jumps
                POP DI
                POP SI
                POP BX
                POP CX

                CMP path1, -1
                JNE lab2
                    CMP path2, -1
                    JE lab1
                        lab2:
                        MOV AL,source_pawn
                        ; DEC AL
                        CMP isDirect,'y'
                        JE directMove
                            MOV BYTE PTR [DI], AL
                            INC DI
                            JMP lab1
                        directMove:
                            MOV BYTE PTR [BX], AL
                            INC BX
            lab1:
                INC SI
                INC count
        CMP CX,0
        JE endL
            DEC CX
            JMP lab3
        endL:
    ENDM

    incScore MACRO turn
        CMP turn, 'w'
        JZ incScore_white
        
        incScore_black:
        MOV AL, blackPlayer_score
        INC AL
        MOV blackPlayer_score, AL

        JMP incScore_end

        incScore_white:
        MOV AL, whitePlayer_score
        INC AL
        MOV whitePlayer_score, AL
        
        incScore_end:
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