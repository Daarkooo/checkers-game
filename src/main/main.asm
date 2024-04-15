.MODEL SMALL

.STACK 100h

.DATA

    INCLUDE procs.inc
    INCLUDE GUI.inc
    INCLUDE print.inc

.CODE
    eventHandler PROC ; arg1, arg2, xPosition, yPosition
        PUSH BP
        MOV BP, SP

        MOV DX, [BP + 4]
        MOV CX, [BP + 6]

        drawCircle 04h, CX, DX

        MOV SP, BP
        POP BP
        RET 8
    eventHandler ENDP

    main PROC
        MOV AX, @DATA
        MOV DS, AX

        PUSH BP
        MOV BP, SP

        ; set up video mode
        MOV AX, 0012h
        INT 10h

        ; set up mouse
        XOR AX, AX
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
        MOV DX, 477
        INT 33h

        drawBoard 0, 0, 0Fh, 06h, 34

        LEA AX, eventHandler
        awaitMouseClick AX, 0, 0, 2

        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main