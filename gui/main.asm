.MODEL SMALL

.STACK 100h

.DATA
    board           DB  20 DUP('b'), 10 DUP('0'), 20 DUP('w')
    directMoves     DB  20 dup(?)
    IndMoves        DB  20 dup(?)


    blackCell       DW      0006h ; brown
    whiteCell       DW      000Fh ; white
    blackPiece      DW      0001h ; blue
    whitePiece      DW      0000h ; black

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

.CODE

    main PROC
        MOV AX, @DATA
        MOV DS, AX
        
        PUSH BP
        MOV BP, SP

        ; set up video mode
        MOV AX, 0010h   ; 640x350 16 colors
        INT 10h

        setupMouse 0, 0, 0, 0, 637, 347

        CALL graphicalMenu

        CMP AX, 1
        JZ startClicked
        JMP main_endLabel
        startClicked:

        ; Clear screen by re-setting video mode
        MOV AX, 0010h   ; 640x350 16 colors
        INT 10h


        Board_init_GUI board, blackCell, whiteCell, blackPiece, whitePiece

        setupMouse 500, 270, 0, 0, 637, 347

        play:

            show_moves turn, board, IndMoves, directMoves
            draw_borders IndMoves, directMoves, 0Ah 
            
            reselect:
                
                LEA AX, getCoordsFromMouseClick
                awaitMouseClick AX,0,0,34 ; CX <- y DX <- x                
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

            draw_borders IndMoves, directMoves, 06h
            drawBorderCell source_pawn, 0Ah, 0, 0, 34 ; green 

            
            ; Use BX to pass 8 bit paraemtre, because AX will be cleared inside MACRO call
            XOR BX, BX
            MOV BL, path1
            markCell 04h, offsetX, offsetY, cellSize, BX
            
            XOR BX, BX
            MOV BL, path2
            markCell 04h, offsetX, offsetY, cellSize, BX
            

            reselect2:
                LEA AX,getCoordsFromMouseClick
                awaitMouseClick AX,0,0,34 ; CX <- x DX <- y

                move_pawn board,DL,CL,path1,path2,source_pawn,makla,makla2,isDirect

                CMP isDirect,-1
                JNE label3
                    JMP reselect2
            label3:

            XOR BX, BX
            MOV BL, path1
            markCell 06h, offsetX, offsetY, cellSize, BX

            XOR BX, BX
            MOV BL, path2
            markCell 06h, offsetX, offsetY, cellSize, BX
            

            switch_turn turn ; make it here to change the color of the pawns (depends on player's turn)

            drawBorderCell source_pawn, 06h, 0, 0, 34 
            
            Move_GUI source_pawn,isDirect,PColor ; isDirect <- board[x,y] if the move is valid
            ; show_moves turn, board, IndMoves, directMoves

        JMP play

        main_endLabel:
       
        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main