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

            ; display mouse
            MOV AX, 0001h
            INT 33h

            setMousePosition 0, 0

            Board_init_GUI myBoard, blackCell, whiteCell, blackPiece, whitePiece
            drawBorder 0008h, offsetX, offsetY, 340, 5
            markCell 0004h, offsetX, offsetY, 34, 21
            markCell 0004h, offsetX, offsetY, 34, 26
            markCell 0007h, offsetX, offsetY, 34, 22
            markCell 0007h, offsetX, offsetY, 34, 27

        main_endLabel:

        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main
