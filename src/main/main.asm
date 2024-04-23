.MODEL SMALL

.STACK 100h

.DATA
    myBoard         DB  20 DUP('b'), 10 DUP('e'), 20 DUP('w')

    ; MEDJBER'S NEW VARIABLES, FOR CHOSING THEME WHEN GAME STARTS
    blackCell       DW      0006h
    whiteCell       DW      000Fh
    blackPiece      DW      0000h
    whitePiece      DW      000Fh

    INCLUDE print.inc
    INCLUDE menu.inc        ; ALREADY INCLUDES 'mouse.inc' AND 'GUI.inc'

.CODE
    main PROC
        MOV AX, @DATA
        MOV DS, AX

        PUSH BP
        MOV BP, SP

        ; set up video mode
        MOV AX, 0010h   ; 640x350 16 colors
        INT 10h

        ; ***************************************** SETTING UP MOUSE *****************************************
        ; set up mouse
        XOR AX, AX
        INT 33h

        ; set initial mouse position to (0, 0) to avoid distrubing the menu
        MOV AX, 0004h
        XOR CX, CX
        XOR DX, DX
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
        ; ***************************************** END OF SETTING UP MOUSE *****************************************

        CALL graphicalMenu

        CMP AX, 1
        JZ startClicked
        JMP main_endLabel
        startClicked:

            ; Clear screen by re-setting video mode
            MOV AX, 0010h   ; 640x350 16 colors
            INT 10h

            drawBoard 295, 5, blackCell, whiteCell, 34
            drawBorder 0008h, 295, 5, 340, 5

        main_endLabel:

        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main
