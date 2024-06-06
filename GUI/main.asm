.MODEL SMALL

.STACK 100h

.DATA

    board           DB      50 DUP('?')
    directMoves     DB      20 dup(?)
    IndMoves        DB      20 dup(?)


    blackCell       DW      0006h   ; brown
    whiteCell       DW      000Fh   ; white
    blackPiece      DW      0001h   ; blue
    whitePiece      DW      0000h   ; black

    PColor          DW      ?       ; initial it with black Piece Color
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
    winner          DB      0
    x1              DB      ?
    y1              DB      ?
    check_direct    DB      ?
    isDirect        DB      ?
    maklaSif        DB      1
    typePawn        DB      ?  ; 0 -> pawn / 1-> dame
    color           DB      ?

    INCLUDE menu.inc
    INCLUDE print.inc
    INCLUDE logic.inc
    INCLUDE methods.inc
    INCLUDE sound.inc

.CODE

    main PROC
        MOV AX, @DATA
        MOV DS, AX

        PUSH BP
        MOV BP, SP

        ; set up video mode
        MOV AX, 0010h   ; 640x350 16 colors
        INT 10h

        CALL drawLogo

        ; set up video mode
        MOV AX, 0010h   ; 640x350 16 colors
        INT 10h

        setupMouse 0, 0, 0, 0, 637, 347

        CALL graphicalMenu

        CMP AX, 1
        JZ startClicked
        JMP main_endLabel
        startClicked:
        MOV turn, 'b'
        board_init board

        ; Clear screen by re-setting video mode
        MOV AX, 0010h   ; 640x350 16 colors
        INT 10h

        Board_init_GUI board, blackCell, whiteCell, blackPiece, whitePiece
        drawBorder 0008h, 295, 5, 340, 5
        CALL duringGameMenu
        setupMouse 500, 270, 0, 0, 637, 347
        MOV AX, blackPiece
        MOV PColor, AX

        play:
            ; show_moves board, IndMoves, directMoves
            ; draw_borders IndMoves, directMoves, 0Ah
            ; MOV AL, 0
            ; MOV countMoves, AL

            reselect:

                LEA AX, getOptionClickedInGame
                awaitMouseClick AX, offsetX, offsetY, cellSize

                MAIN_NOTHING1:
                    CMP AX, 0000h
                    JNZ MAIN_RESIGN1
                JMP reselect

                MAIN_RESIGN1:
                    CMP AX, 0002h
                    JNZ MAIN_QUIT1
                JMP MAIN_gameEnd

                MAIN_QUIT1:
                    CMP AX, 0003h
                    JNZ MAIN_BOARD1
                JMP main_endLabel

                MAIN_BOARD1:

                MOV x1,DL
                MOV y1,CL

                show_path board,x1,y1,turn,path1,path2,source_pawn,makla1,makla2

                CMP typePawn,0
                JE pawn
                    JMP dame
                pawn:
                XOR AX,AX
                MOV AL, typePawn

                MOV AL, isDirect
                MOV check_direct , AL ; need it in multiple_jumps to check if the previous move was a direct/indirect move

                MOV AL,0
                CMP path1,-1
                JE label1
                    MOV AL,1
                label1:

                CMP path2,-1
                JE label2
                    MOV AL,1
                label2:

                CMP AL,1
                JNE labe1
                    JMP next
                labe1:
                JMP reselect

                dame:
                show_path_dame board,x1,y1,turn,dameMoves,dameIndMoves,source_pawn,makla1,makla2,makla3,makla4

                MOV AL, isDirect
                MOV check_direct, AL

                ; CMP typePawn,1
                ; JE continue1
                ;     ; PUSH DX
                ;     ; PUSH CX
                ;     JMP pawn
                ; continue1:

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
            ; draw_borders IndMoves, directMoves, 06h

            multi_jumps_lab:
            pushMousePosition
            setMousePosition 0, 0
            drawBorderCell source_pawn, 0Ah, offsetX, offsetY, cellSize
            popMousePosition

            ; Use BX to pass 8 bit paraemtre, because AX will be cleared inside MACRO call
            mark_cell_method 0004h

            reselect2:
                LEA AX,getOptionClickedInGame
                awaitMouseClick AX, offsetX, offsetY, cellSize ; CX <- xCX <- x DX <- y

                MAIN_NOTHING2:
                    CMP AX, 0000h
                    JNZ MAIN_RESIGN2
                JMP reselect2

                MAIN_RESIGN2:
                    CMP AX, 0002h
                    JNZ MAIN_QUIT2
                JMP MAIN_gameEnd

                MAIN_QUIT2:
                    CMP AX, 0003h
                    JNZ MAIN_BOARD2
                JMP main_endLabel

                MAIN_BOARD2:

                MOV x1, DL
                MOV y1, CL

                CMP typePawn,0
                JE pawn1
                    JMP dame1
                pawn1:

                move_pawn board,x1,y1,path1,path2,source_pawn,makla1,makla2,dest

                promotion dest,turn,boolProm
                CMP boolProm,1
                JE next_promo
                    JMP check
                    next_promo:
                    mark_cell_method blackCell
                        ; MOV AL,1
                    MOV typePawn,1
                    JMP promo

                ; MOV AL,0
                ; CMP path1,-1
                ; JE labll1
                ;     MOV AL,1
                ; labll1:

                ; CMP path2,-1
                ; JE labll2
                ;     MOV AL,1
                ; labll2:

                ; CMP AL,1
                ; JNE dame1
                ;     JMP next
                ; labe1:


                JMP check
                dame1:

                move_dame board,x1,y1,dameMoves,dameIndMoves,source_pawn,makla1,makla2, makla3, makla4,dest

                CMP maklaSif, 1
                JE checkMove
                    JMP continue3
                checkMove:
                    LEA SI, dameIndMoves
                    CMP BYTE PTR [SI+3],0
                    JNE next_move2
                        JMP continue3
                    next_move2:

                    is_value_in_array x1, y1, dameIndMoves, bool
                    CMP bool, 1
                    JE label3
                        JMP reselect2
                continue3:

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

            mark_cell_method blackCell

            promo:
            drawBorderCell source_pawn, blackCell, offsetX, offsetY, cellSize

            Move_GUI source_pawn,dest,PColor ; isDirect <- board[x,y] if the move is valid

            CALL soundEffect

            CMP boolProm,1
            JNE check_next
                JMP next1
            check_next:

            MOV AL,check_direct
            CMP AL, 'n'
            JE next_move
                JMP next1
            next_move:

            ; CMP typePawn,0
            ; JE pawn2
            ;     JMP dame2
            ; pawn2:

            show_path board,x1,y1,turn,path1,path2,source_pawn,makla1,makla2

            ; CMP check_direct, 'n'
            ; JNE nextt1
            ;     JMP next1
            ;     nextt1:
                XOR AX,AX
                mov al,isDirect
                    ; CALL liveUsage
                CMP isDirect, 'n'
                JE nextt2
                    JMP next1
                nextt2:
                    MOV AL,0
                    CMP path1,-1
                    JE lab1
                        MOV AL,1
                    lab1:

                    CMP path2,-1
                    JE lab2
                        MOV AL,1
                    lab2:

                    CMP AL,1
                    JE next11
                        JMP next1
                        next11:
                        JMP multi_jumps_lab

            ; dame2:
            ; show_path_dame board,x1,y1,turn,dameMoves,dameIndMoves,source_pawn,makla1,makla2,makla3,makla4

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

            next1:

            switch_turn turn

            ; check_state_game IndMoves, directMoves, winner
            ; CMP winner, 1
            ; JNE continue2
            ;     MOV AL, turn
            ;     MOV winner, AL
            ;     JMP main_endLabel
            ; continue2:
            ; MOV winner, 0


            drawBackGround 115,159,86,26,00h

            cmp turn, 'b'
            je handleBlackTurn

            printGraphicalString whitePlayer,0FFh,16,12;
            jmp everyThingIsHandeled
            handleBlackTurn:

            printGraphicalString blackPlayer,0FFh,16,12;
            everyThingIsHandeled:

        JMP play

        MAIN_gameEnd:
            pushMousePosition
            setMousePosition 0, 0

            drawBackGround 110, 154, 122, 36, 0Eh
            drawBackGround 115, 159, 112, 26, 00h
            CMP turn, 'b'
            JZ MAIN_whiteWin
            printGraphicalString blackWinMsg, 0FFh, 15, 12
            JMP MAIN_continueGame1

            MAIN_whiteWin:
            printGraphicalString whiteWinMsg, 0FFh, 15, 12

            MAIN_continueGame1:

            printGraphicalString resign, 0FFh, 26, 21
            drawBackGround 189, 283, 84, 36, 02h
            drawBackGround 194, 288, 74, 26, 00h
            printGraphicalString restart, 0FFh, 25, 21

            popMousePosition

            printGraphicalString whitePlayer_score,0FFh,24,3
            printGraphicalString blackPlayer_score,0FFh,30,3

            incScore turn

            printGraphicalString whitePlayer_score,0FFh,24,3
            printGraphicalString blackPlayer_score,0FFh,30,3

            LEA AX, getOptionClickedInGame
            awaitMouseClick AX, offsetX, offsetY, cellSize

            reselect3:
                CMP AX, 0000h   ; nothing
                JZ reselect3
                CMP AX, 0001h   ; board (nothing in this case)
                JZ reselect3
                CMP AX, 0003h   ; exit
                JZ main_endLabel
            JMP startClicked    ; If none of these cases, then it is restart

        main_endLabel:

        MOV AX, 0010h
        INT 10h

        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main