.MODEL SMALL

.STACK 100h

.DATA
    board           DB  25 DUP('b'), 5 DUP('0'), 20 DUP('w')
    ; board           DB  20 DUP('b'), 25 DUP('w')

    SPMP_X          EQU     260
    SPMP_Y          EQU     80
    MP_MSG          DB      "Multi player$"
    SP_MSG          DB      "Single player$"
    isSP            DB      1

    MAKLA_X         EQU     260
    MAKLA_Y         EQU     150
    MKLASIF_MSG     DB      "makla sif$"
    MKLANSIF_MSG    DB      "machi sif$"
    isMaklaSif      DB      1

    START_X         EQU     260
    START_Y         EQU     220
    START_MSG       DB      "START$"

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


    EXIT_X          EQU     5
    EXIT_Y          EQU     312
    EXIT_MSG        DB      "EXIT$"

    ; INCLUDE mouse.inc
    ; INCLUDE GUI.inc
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

        ; set up mouse
        XOR AX, AX
        INT 33h

        ; ; set initial mouse position to (0, 0) to avoid distrubing the menu
        MOV AX, 0004h
        XOR CX, 100
        XOR DX, 100
        INT 33h

        ; display mouse
        MOV AX, 0001h
        INT 33h

        ; will do (maximum range - 3)
        ; horizontal range
        MOV AX, 0007h
        MOV CX, 0
        MOV DX, 637
        INT 33h

        ; vertical range
        MOV AX, 0008h
        MOV CX, 0
        MOV DX, 347
        INT 33h

        Board_init_GUI board,0000h,0001h

        ; MOV CX,6
        play:
            reselect:
                LEA AX,getCoordsFromMouseClick
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


            drawBorder path1, 0Ah, 0, 0, 34
            drawBorder path2, 0Ah, 0, 0, 34
            
            reselect2:
            LEA AX,getCoordsFromMouseClick
            awaitMouseClick AX,0,0,34 ; CX <- x DX <- y

            move_pawn board,DL,CL,path1,path2,source_pawn,makla,makla2,isDirect

            CMP isDirect,-1
            JNE label3
                JMP reselect2
            label3:

            drawBorder path1, 06h, 0, 0, 34
            drawBorder path2, 06h, 0, 0, 34
            

            ; drawCell 000CH, 2*34, 3*34, 34
            ; drawCircle 00001H, 2*40, 3*40
            ; drawCell 000AH, 3*34, 34*4, 34
            ; drawCell color, x, y, size
            
            switch_turn turn ; make it here to change the color of the pawns (depends on player's turn)
            
            Move_GUI source_pawn,isDirect,PColor ; isDirect <- board[x,y] if the move is valid

           

        ; DEC CX
        ; CMP CX,0
        ; JNZ next
        JMP play
        ; next:



        ; ***************************************** DRAWING MENU *****************************************
        ; ; SP/MP TOGGLE
        ; drawRectangle SPMP_X, SPMP_Y, 120, 50, 0006h
        ; printGraphicalString SP_MSG, 0F1h, 34, 7

        ; ; MAKLA TOGGLE
        ; drawRectangle MAKLA_X, MAKLA_Y, 120, 50, 0002h
        ; printGraphicalString MKLASIF_MSG, 0F2h, 35, 12

        ; ; START BUTTON
        ; drawRectangle START_X, START_Y, 120, 50, 0001h
        ; printGraphicalString START_MSG, 0F6h, 37, 17

        ; ; EXIT BUTTON
        ; drawRectangle EXIT_X, EXIT_Y, 70, 30, 0004h
        ; printGraphicalString EXIT_MSG, 0F4h, 3, 23

        ; MAIN_L1:
        ;     LEA AX, getMenuOptionClicked
        ;     awaitMouseClick AX, 0, 0, 0

        ;     CMP AX, 0001h
        ;     JZ SPMP_clicked

        ;     CMP AX, 0002h
        ;     JNZ MAKLA_notClicked
        ;     JMP MAKLA_clicked
        ;     MAKLA_notClicked:

        ;     CMP AX, 0003h
        ;     JNZ START_notClicked
        ;     JMP START_clicked
        ;     START_notClicked:

        ;     CMP AX, 000Fh
        ;     JNZ MAIN_L1
        ;     JMP EXIT_clicked

        ;     SPMP_clicked:
        ;         CMP isSP, 1
        ;         JZ SP_TOGGLE
        ;             printGraphicalString MP_MSG, 0F1h, 34, 7
        ;             printGraphicalString SP_MSG, 0F1h, 34, 7
        ;             MOV isSP, 1
        ;             JMP SPMP_end

        ;         SP_TOGGLE:
        ;             printGraphicalString SP_MSG, 0F1h, 34, 7
        ;             printGraphicalString MP_MSG, 0F1h, 34, 7
        ;             MOV isSP, 0

        ;         SPMP_end:
        ;         JMP MAIN_L1

        ;     MAKLA_clicked:
        ;         CMP isMaklaSif, 1
        ;         JZ MAKLA_TOGGLE
        ;             printGraphicalString MKLASIF_MSG , 0F2h, 35, 12
        ;             printGraphicalString MKLANSIF_MSG, 0F2h, 35, 12
        ;             MOV isMaklaSif, 1
        ;             JMP MAKLA_end

        ;         MAKLA_TOGGLE:
        ;             printGraphicalString MKLANSIF_MSG, 0F2h, 35, 12
        ;             printGraphicalString MKLASIF_MSG , 0F2h, 35, 12
        ;             MOV isMaklaSif, 0

        ;         MAKLA_end:
        ;         JMP MAIN_L1

        ;     START_clicked:
        ;         ; START_GAME
        ;         JMP EXIT_clicked
        ;         JMP MAIN_L1

        ;     EXIT_clicked:
        ; ***************************************** END OF DRAWING MENU *****************************************
       
        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main