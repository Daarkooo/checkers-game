.MODEL SMALL

.STACK 100h

.DATA
    board           DB  20 DUP('b'), 10 DUP('0'), 20 DUP('w')

    ;? ****************************************************************
    ;? MEDJBER'S NEW VARIABLES, FOR CHOSING THEME WHEN GAME STARTS
    blackCell       DW      0006h
    whiteCell       DW      000Fh
    blackPiece      DW      0000h
    whitePiece      DW      000Fh
    ;? ****************************************************************

    ;? ****************************************************************
    ;? Hichem's logic variables
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
    ;? ****************************************************************

    INCLUDE menu.inc
    INCLUDE print.inc
    INCLUDE logic.inc

.CODE
    main PROC
        MOV AX, @DATA
        MOV DS, AX

        PUSH BP
        MOV BP, SP

        ; set up video mode
        MOV AX, 0010h   ; 640x350 16 colors
        INT 10h

        ; setting up mouse
        setupMouse 0, 0, 0, 0, 637, 347

        CALL graphicalMenu

        CMP AX, 1
        JZ startClicked
        JMP main_endLabel
        startClicked:

        ; Clear screen by re-setting video mode
        MOV AX, 0010h   ; 640x350 16 colors
        INT 10h

        ; re-settingup mouse
        Board_init_GUI myBoard, blackCell, whiteCell, blackPiece, whitePiece
        drawBorder 0008h, offsetX, offsetY 340, 5
        setupMouse 500, 270, 0, 0, 637, 347

        play:
            PUSH CX
            reselect:
                LEA AX,getCoordsFromMouseClick
                awaitMouseClick AX, offsetX, offsetY, cellSize ; CX <- y DX <- x

                show_path board,DL,CL,turn,path1,path2,source_pawn,makla,isDirect,multiple_jumps

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

            ; Use BX to pass paraemtre, because AX will be cleared inside MACRO call
            XOR BX, BX
            MOV BL, path1
            markCell 0Ah, offsetX, offsetY, cellSize, BX

            XOR BX, BX
            MOV BL, path2
            markCell 0Ah, offsetX, offsetY, cellSize, BX

            reselect2:
            LEA AX,getCoordsFromMouseClick
            awaitMouseClick AX, offsetX, offsetY, cellSize ; CX <- x DX <- y

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

            Move_GUI source_pawn, isDirect, PColor ; isDirect <- board[x,y] if the move is valid

            POP CX
            DEC CX
            JCXZ main_endLabel
        JMP play

        main_endLabel:

        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main
