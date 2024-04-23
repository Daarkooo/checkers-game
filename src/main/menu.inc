.DATA
    SPMP_X          EQU     164
    SPMP_Y          EQU     66
    MP_MSG          DB      "Multi player$"
    SP_MSG          DB      "Single player$"
    isSP            DB      1

    MAKLA_X         EQU     164
    MAKLA_Y         EQU     136
    MKLASIF_MSG     DB      "makla sif$"
    MKLANSIF_MSG    DB      "machi sif$"
    isMaklaSif      DB      1

    START_X         EQU     265
    START_Y         EQU     234
    START_MSG       DB      "START$"

    EXIT_X          EQU     5
    EXIT_Y          EQU     312
    EXIT_MSG        DB      "EXIT$"

    THEMES_TITLE_X  EQU     59
    THEMES_TITLE_Y  EQU     4
    THEMES_TITLE    DB      "THEMES:$"

    THEME0_X        EQU     440
    THEME0_Y        EQU     088

    THEME1_X        EQU     524
    THEME1_Y        EQU     088

    THEME2_X        EQU     440
    THEME2_Y        EQU     158

    THEME3_X        EQU     524
    THEME3_Y        EQU     158

    INCLUDE GUI.inc
    INCLUDE MOUSE.inc
.CODE
    ; Not put in 'GUI.inc' because it is needed only in the menu
    __drawThemeTemplate PROC ; initialX, initialY, blackCellColor, whiteCellColor, blackPieceColor, whitePieceColor, cellSize
        PUSH BP
        MOV BP, SP
        SUB SP, 2

        ; cellSize:         [BP +  4]
        ; whitePieceColor:  [BP +  6]
        ; blackPieceColor:  [BP +  8]
        ; whiteCellColor:   [BP + 10]
        ; blackCellColor:   [BP + 12]
        ; initialY:         [BP + 14]
        ; initialX:         [BP + 16]

        MOV CX, [BP + 16]
        MOV DX, [BP + 14]
        MOV BX, [BP +  4]
        SHR BX, 1
        MOV [BP - 2], BX
        MOV BX, [BP + 4]

        MOV AX, [BP + 10]
        drawCell AX, CX, DX, BX

        ADD CX, BX
        MOV AX, [BP + 12]
        drawCell AX, CX, DX, BX
        
        ADD CX, [BP - 2]
        ADD DX, [BP - 2]
        MOV AX, [BP + 8]
        drawCircle14 AX, CX, DX

        MOV CX, [BP + 16]
        MOV DX, [BP + 14]
        ADD DX, BX
        MOV AX, [BP + 12]
        drawCell AX, CX, DX, BX

        ADD CX, [BP -  2]
        ADD DX, [BP -  2]
        MOV AX, [BP + 10]
        drawCircle14 AX, CX, DX

        MOV CX, [BP + 16]
        ADD CX, BX
        MOV DX, [BP + 14]
        ADD DX, BX
        MOV AX, [BP + 10]
        drawCell AX, CX, DX, BX

        MOV SP, BP
        POP BP
        RET 14
    __drawThemeTemplate ENDP

    drawThemeTemplate MACRO initialX, initialY, blackCellColor, whiteCellColor, blackPieceColor, whitePieceColor, cellSize
        MOV AX, initialX
        PUSH AX

        MOV AX, initialY
        PUSH AX

        MOV AX, blackCellColor
        PUSH AX

        MOV AX, whiteCellColor
        PUSH AX

        MOV AX, blackPieceColor
        PUSH AX

        MOV AX, whitePieceColor
        PUSH AX

        MOV AX, cellSize
        PUSH AX

        CALL __drawThemeTemplate
    ENDM

    graphicalMenu PROC
        PUSH BP
        MOV BP, SP

        ; SP/MP TOGGLE
        drawRectangle SPMP_X, SPMP_Y, 120, 50, 0006h
        printGraphicalString SP_MSG, 0F1h, 22, 6

        ; MAKLA TOGGLE
        drawRectangle MAKLA_X, MAKLA_Y, 120, 50, 0002h
        printGraphicalString MKLASIF_MSG, 0F2h, 23, 11

        ; START BUTTON
        drawRectangle START_X, START_Y, 120, 50, 0001h
        printGraphicalString START_MSG, 0F6h, 38, 18

        ; EXIT BUTTON
        drawRectangle EXIT_X, EXIT_Y, 70, 30, 0004h
        printGraphicalString EXIT_MSG, 0F4h, 3, 23

        ; THEMES TITLE
        printGraphicalString THEMES_TITLE, 0FFh, THEMES_TITLE_X, THEMES_TITLE_Y

        ; THEMES LIST
        drawThemeTemplate THEME0_X, THEME0_Y, 0006h, 000Fh, 0000h, 000Fh, 17 ; THEME 1
        drawBorder 0008h, THEME0_X, THEME0_Y, 34, 3

        drawThemeTemplate THEME1_X, THEME1_Y, 0000h, 000Fh, 0007h, 000Fh, 17 ; THEME 2
        drawBorder 0008h, THEME1_X, THEME1_Y, 34, 3
        
        drawThemeTemplate THEME2_X, THEME2_Y, 0002h, 000Fh, 0000h, 000Fh, 17 ; THEME 3
        drawBorder 0008h, THEME2_X, THEME2_Y, 34, 3

        drawThemeTemplate THEME3_X, THEME3_Y, 0000h, 000Fh, 0004h, 0001h, 17 ; THEME 4
        drawBorder 0008h, THEME3_X, THEME3_Y, 34, 3

        MAIN_L1:
            LEA AX, getMenuOptionClicked
            awaitMouseClick AX, 0, 0, 0

            CMP AX, 0001h
            JNZ SPMP_notClicked
            JMP SPMP_clicked
            SPMP_notClicked:

            CMP AX, 0002h
            JNZ MAKLA_notClicked
            JMP MAKLA_clicked
            MAKLA_notClicked:

            CMP AX, 0003h
            JNZ START_notClicked
            MOV AX, 1       ; START BUTTON CLICKED
            JMP menu_endLabel
            START_notClicked:

            CMP AX, 0004h
            JNZ THEME0_notClicked
            JMP THEME0_clicked
            THEME0_notClicked:

            CMP AX, 0005h
            JNZ THEME1_notClicked
            JMP THEME1_clicked
            THEME1_notClicked:

            CMP AX, 0006h
            JNZ THEME2_notClicked
            JMP THEME2_clicked
            THEME2_notClicked:

            CMP AX, 0007h
            JNZ THEME3_notClicked
            JMP THEME3_clicked
            THEME3_notClicked:

            CMP AX, 000Fh
            JNZ MAIN_L1
            MOV AX, 0           ; EXIT BUTTON CLICKED
            JMP menu_endLabel

            SPMP_clicked:
                CMP isSP, 1
                JZ SP_TOGGLE
                    printGraphicalString MP_MSG, 0F1h, 22, 6
                    printGraphicalString SP_MSG, 0F1h, 22, 6
                    MOV isSP, 1
                    JMP SPMP_end

                SP_TOGGLE:
                    printGraphicalString SP_MSG, 0F1h, 22, 6
                    printGraphicalString MP_MSG, 0F1h, 22, 6
                    MOV isSP, 0

                SPMP_end:
                JMP MAIN_L1

            MAKLA_clicked:
                CMP isMaklaSif, 1
                JZ MAKLA_TOGGLE
                    printGraphicalString MKLASIF_MSG , 0F2h, 23, 11
                    printGraphicalString MKLANSIF_MSG, 0F2h, 23, 11
                    MOV isMaklaSif, 1
                    JMP MAKLA_end

                MAKLA_TOGGLE:
                    printGraphicalString MKLANSIF_MSG, 0F2h, 23, 11
                    printGraphicalString MKLASIF_MSG , 0F2h, 23, 11
                    MOV isMaklaSif, 0

                MAKLA_end:
                JMP MAIN_L1

            THEME0_clicked:
                MOV blackCell , 0006h
                MOV whiteCell , 000Fh
                MOV blackPiece, 0000h
                MOV whitePiece, 000Fh

                JMP MAIN_L1

            THEME1_clicked:
                MOV blackCell , 0000h
                MOV whiteCell , 000Fh
                MOV blackPiece, 0007h
                MOV whitePiece, 000Fh
                
                JMP MAIN_L1

            THEME2_clicked:
                MOV blackCell , 0002h
                MOV whiteCell , 000Fh
                MOV blackPiece, 0000h
                MOV whitePiece, 000Fh

                JMP MAIN_L1

            THEME3_clicked:
                MOV blackCell , 0000h
                MOV whiteCell , 000Fh
                MOV blackPiece, 0004h
                MOV whitePiece, 0001h

                JMP MAIN_L1

        menu_endLabel:
        MOV SP, BP
        POP BP
        RET
    graphicalMenu ENDP
