.MODEL SMALL

.STACK 100h

.DATA
    ; board           DB  20 DUP('b'), 10 DUP('0'), 20 DUP('w')
    ; board           DB  20 DUP('b'), 10 DUP('0'), 20 DUP('w')
    board           DB  3 DUP('B'),'b','b', 40 DUP('0'), 3 DUP('W'),'w','w'
    directMoves     DB  20 dup(?)
    IndMoves        DB  20 dup(?)


    blackCell       DW      0006h ; brown
    whiteCell       DW      000Fh ; white
    blackPiece      DW      0001h ; blue
    whitePiece      DW      0000h ; black

    PColor          DW      0001H ; initial it with black Piece Color
    source_pawn     DB      ?
    turn            DB      'b'
    path1           DB      ?
    path2           DB      ?
    tmp             DB      ?
    num             DB      ?
    maklaD          DB      ?
    makla1          DB      ?
    makla2          DB      ?
    makla3          DB      ?
    makla4          DB      ?
    x1              DB      ?
    y1              DB      ?
    check_direct    DB      ?
    isDirect        DB      ?
    maklaSif        DB      1
    ; countMoves      DB      0
    typePawn        DB      ?  ; 0 -> pawn / 1-> dame
    color           DB      ?

    INCLUDE menu.inc
    INCLUDE print.inc
    INCLUDE logic.inc
    INCLUDE methods.inc

.CODE

    main PROC
        MOV AX, @DATA
        MOV DS, AX
        
        PUSH BP
        MOV BP, SP

        ; set up video mode
        ; MOV AX, 0010h   ; 640x350 16 colors
        ; INT 10h

        ; setupMouse 0, 0, 0, 0, 637, 347

        ; CALL graphicalMenu

        ; CMP AX, 1
        ; JZ startClicked
        ;     JMP main_endLabel
        ; startClicked:

        ; Clear screen by re-setting video mode
        MOV AX, 0010h   ; 640x350 16 colors
        INT 10h


        Board_init_GUI board, blackCell, whiteCell, 008h, 007h

        setupMouse 500, 270, 0, 0, 637, 347

        play:

            ;show_moves board, IndMoves, directMoves
            ;draw_borders IndMoves, directMoves, 0Ah 
            ; MOV AL, 0
            ; MOV countMoves, AL
            reselect:
                
                LEA AX, getCoordsFromMouseClick
                awaitMouseClick AX,0,0,34 ; CX <- y DX <- x   
                
                ; CMP maklaSif, 1
                ; JE maklaBlock
                ;     JMP next
                ; maklaBlock:

                ; makla_sif_check IndMoves, bool, isValid
                
                ; CMP isValid, 1
                ; JE continue
                ;     JMP reselect
                ; continue:
                MOV x1,DL
                MOV y1,CL

                show_path board,x1,y1,turn,path1,path2,source_pawn,makla1,makla2

                CMP typePawn,0
                JE pawn
                    ; PUSH DX
                    ; PUSH CX
                    JMP dame
                pawn:
                ; XOR AX,AX
                ; MOV AL, typePawn
                ; call liveUsage

                ; MOV AL, isDirect
                ; MOV check_direct , AL ; need it in multiple_jumps to check if the previous move was a direct/indirect move 
                MOV AL,0
                CMP path1,-1
                JE label1
                    MOV AL,1
                label1:

                CMP path2,-1
                JE label2
                    MOV AL,1
                label2:

                ; CMP AL,1    
                ; JE next
                ;     JMP reselect
                
                CMP AL,1    
                JNE labe1
                    JMP next
                labe1:
                JMP reselect

                dame:
                ; POP CX
                ; POP DX
               show_path_dame board,x1,y1,turn,dameMoves,dameIndMoves,source_pawn,makla1,makla2,makla3,makla4 
                
                MOV AL, isDirect
                MOV check_direct, AL

                CMP typePawn,1
                JE  continue1
                    ; PUSH DX
                    ; PUSH CX
                    JMP pawn
                continue1:

                MOV AL,0
                LEA BX, dameIndMoves
                CMP BYTE PTR[BX+3],0  
                JE lab5
                    MOV AL,1
                lab5:

                LEA BX, dameMoves                      
                CMP BYTE PTR[BX+3],0
                JE lab4
                    MOV AL,1
                lab4: 
                    
                CMP AL,1
                JE next
                    JMP reselect

            next:
            ;draw_borders IndMoves, directMoves, 06h
           
            multi_jumps_lab:
            drawBorderCell source_pawn, 0Ah, 0, 0, 34 ; green 

            
            ; CALL liveUsage
            ; Use BX to pass 8 bit paraemtre, because AX will be cleared inside MACRO call
            mark_cell_method 04h
            
            ; CALL liveUsage
            reselect2:
                LEA AX,getCoordsFromMouseClick
                awaitMouseClick AX,0,0,34 ; CX <- x DX <- y
                
                MOV x1, DL
                MOV y1, CL

                CMP typePawn,0
                JE pawn1
                    JMP dame1
                pawn1:
                
                move_pawn board,DL,CL,path1,path2,source_pawn,makla1,makla2,dest

                

                promotion dest,turn,boolProm
                CMP boolProm,1
                JE next_promo
                    JMP check
                    next_promo:
                    mark_cell_method 06h
                        ; MOV AL,1
                    MOV typePawn,1
                    JMP promo

                ; JMP check
                dame1:
                
                move_dame board,DL,CL,dameMoves,dameIndMoves,source_pawn,makla1,makla2, makla3, makla4,dest
                
                ; CMP maklaSif, 1
                ; JE checkMove
                ;     JMP continue3
                ; checkMove:    
                ;     LEA SI, dameIndMoves
                ;     CMP BYTE PTR [SI+3],0
                ;     JNE next_move2
                ;         JMP continue3
                ;     next_move2:

                ;     is_value_in_array x1, y1, dameIndMoves, bool
                ;     CMP bool, 1
                ;     JE label3
                ;         JMP reselect2
                ; continue3:
                
                ; XOR AX,AX
                ; XOR BX,BX
                ; XOR CX,CX
                ; XOR DX,DX
                ; MOV AL,dameMoves[2]
                ; MOV BL,dameIndMoves[0]
                ; MOV CL,dameMoves[3]
                ; MOV DL,isDirect

                ; CALL liveUsage
                check:
                CMP dest,-1
                JNE label3
                    JMP reselect2
            label3:
      


            mark_cell_method 06h
            
            ; call liveUsage
            promo:

            drawBorderCell source_pawn, 06h, 0, 0, 34 
            
            Move_GUI source_pawn,dest,PColor ; isDirect <- board[x,y] if the move is valid
            ; CALL liveUsage
            ; XOR AX,AX
            ; mov AL,check_direct
            ; call liveUsage

            ; MOV AL,check_direct
            ; CMP AL, 'n'
            ; JE next_move
            ;     JMP next1
            ; next_move:

            ; show_path_dame board,x1,y1,turn,dameMoves,dameIndMoves,source_pawn,makla1,makla2,makla3,makla4 

            ; ; show_path board,x1,y1,turn,path1,path2,source_pawn,makla1,makla2

            ; ; CMP check_direct, 'n'
            ; ; JNE next1


            ; LEA SI, dameIndMoves
            ; CMP BYTE PTR [SI+3],0
            ; JNE next_move1
            ;     JMP next1
            ; next_move1:
               
            ;     ; MOV AL,countMoves
            ;     ; CMP AL,0
            ;     ; JE nextMove
            ;     ;     is_value_in_array x1, y1, dameIndMoves, bool
            ;     ;     CMP bool, 1
            ;     ;     JE nextMove
            ;     ;         JMP next1
            ;     ; nextMove:

            ;     ; INC countMoves 
                
            ;     JMP multi_jumps_lab
            
            ;     CMP path1,-1
            ;     JE lab1
            ;         MOV AL,1
            ;     lab1:

            ;     CMP path2,-1
            ;     JE lab2
            ;         MOV AL,1
            ;     lab2:

            ;     CMP AL,1    
            ;     JNE next1
            ;         JMP multi_jumps_lab
            next1:

            switch_turn turn 

            ; check_state_game IndMoves, directMoves, winner
            ; CMP winner, 1
            ; JNE continue1
            ;     MOV AL, turn
            ;     MOV winner, AL
            ;     JMP main_endLabel
            ; continue1:
            
        JMP play

        main_endLabel:

        call liveUsage
        ; we have a winner 
       
        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main