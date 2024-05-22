.MODEL SMALL

.STACK 100h

.DATA
    board           DB  20 DUP('b'), 10 DUP('0'), 20 DUP('w')
    directMoves     DB  20 dup(?)
    IndMoves        DB  20 dup(?)


    blackCell       DW      0006h ; brown
    whiteCell       DW      000Fh ; white
    blackPiece      DW      0000h ; blue
    whitePiece      DW      000Fh ; black

    PColor          DW      ?
    source_pawn     DB      ?
    turn            DB      'b'
    path1           DB      ?
    path2           DB      ?
    num             DB      ?
    makla           DB      ?
    makla2          DB      ?
    isDirect        DB      ?
    multiple_jumps  DB      ?
    maklaSif        DB      1

    INCLUDE menu.inc
    INCLUDE print.inc
    INCLUDE logic.inc
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
        board_init board

        ; Clear screen by re-setting video mode
        MOV AX, 0010h   ; 640x350 16 colors
        INT 10h

        Board_init_GUI board, blackCell, whiteCell, blackPiece, whitePiece
        drawBorder 0008h, offsetX, offsetY, 340, 5
        CALL duringGameMenu
        setupMouse 500, 270, 0, 0, 637, 347

        play:
            show_moves turn, board, IndMoves, directMoves

            check_state_game IndMoves, directMoves, AL
            CMP AL, 0
            JNZ MAIN_continueGame
            JMP MAIN_gameEnd
            MAIN_continueGame:

            draw_borders IndMoves, directMoves, 0Ah

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
                show_path board,DL,CL,turn,path1,path2,source_pawn,makla,makla2,isDirect,multiple_jumps

                CMP path1,-1
                JE label1
                    MOV AL,1
                label1:

                CMP path2,-1
                JE label2
                    MOV AL,1
                label2:

                CMP AL,1
                JE next
                    JMP reselect
            next:

            draw_borders IndMoves, directMoves, blackCell

            pushMousePosition
            setMousePosition 0, 0
            drawBorderCell source_pawn, 0Ah, offsetX, offsetY, cellSize
            popMousePosition

            ; Use BX to pass 8 bit paraemtre, because AX will be cleared inside MACRO call
            XOR BX, BX
            MOV BL, path1
            markCell 04h, offsetX, offsetY, cellSize, BX

            XOR BX, BX
            MOV BL, path2
            markCell 04h, offsetX, offsetY, cellSize, BX

            reselect2:
                LEA AX,getOptionClickedInGame
                awaitMouseClick AX, offsetX, offsetY, cellSize ; CX <- x DX <- y

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

                move_pawn board, DL, CL, path1, path2, source_pawn, makla, makla2, isDirect

                CMP isDirect,-1
                JNE label3
                    JMP reselect2
            label3:

            XOR BX, BX
            MOV BL, path1
            markCell blackCell, offsetX, offsetY, cellSize, BX

            XOR BX, BX
            MOV BL, path2
            markCell blackCell, offsetX, offsetY, cellSize, BX

            switch_turn turn ; make it here to change the color of the pawns (depends on player's turn)
            switchTurnString turn

            drawBorderCell source_pawn, blackCell, offsetX, offsetY, cellSize

            Move_GUI source_pawn,isDirect,PColor ; isDirect <- board[x,y] if the move is valid
            CALL soundEffect
        JMP play

        MAIN_gameEnd:
            pushMousePosition
            setMousePosition 0, 0

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