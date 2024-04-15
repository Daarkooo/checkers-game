.MODEL SMALL

.STACK 100h

.DATA
    str1    DB  'Awaiting mouse click:', 10, 13, '$'
    str2    DB  'Mouse left click detected!', 10, 13, '$'

.CODE
    __sleep PROC ; CX, DX
        ; [BP + 6]: CX
        ; [BP + 4]: DX
        
        PUSH BP
        MOV BP, SP

        MOV AX, 8600h
        MOV DX, WORD PTR [BP + 4]
        MOV CX, WORD PTR [BP + 6]
        INT 15h

        MOV SP, BP
        POP BP
        RET 4
    __sleep ENDP

    sleep MACRO highW, lowW
        MOV AX, highW
        PUSH AX

        MOV AX, lowW
        PUSH AX

        CALL __sleep
    ENDM

    eventHandler PROC
        MOV AX, 0900h
        LEA DX, str2
        INT 21h

        RET
    eventHandler ENDP

    ; Give function offset as parameter
    __awaitMouseLeftClick PROC ; callback
        PUSH BP
        MOV BP, SP

        __awaitMouseLeftClick_mainLoop:
            MOV AX, 3h          ; Function 3: Get mouse position and button status
            INT 33h             ; Call mouse interrupt

            TEST BL, 1          ; Check if left button is pressed
        JZ __awaitMouseLeftClick_mainLoop

        sleep 0003h, 0D40h

        PUSH CX
        PUSH DX
        CALL [BP + 4]

        MOV SP, BP
        POP BP
        RET 2
    __awaitMouseLeftClick ENDP

    awaitMouseLeftClick MACRO callback
        MOV AX, callback
        PUSH AX

        CALL __awaitMouseLeftClick
    ENDM

    getCoordsFromMouseClick PROC ; xOffset, yOffset, cellSize, xPosition, yPosition
        PUSH BP
        MOV BP, SP

        ; [BP + 12]: xOffset
        ; [BP + 10]: yOffset
        ; [BP + 8]: size
        ; [BP + 6]: xPosition
        ; [BP + 4]: yPosition

        ; x = column * size + xOffset
        ; y = row * size + yOffset

        ; x position 
        XOR DX, DX
        MOV AX, [BP + 6]
        SUB AX, [BP + 12]
        DIV WORD PTR [BP + 8]
        MOV CX, AX

        ; y position
        XOR DX, DX
        MOV AX, [BP + 4]
        SUB AX, [BP + 10]
        DIV WORD PTR [BP + 8]
        MOV DX, AX

        MOV SP, BP
        POP BP
        RET 10
    getCoordsFromMouseClick ENDP
    
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

        ; drawBoard 295, 5, 0Fh, 06h, 34

        ; TESTING FOR ABDOU'S FUNCTION MAKEMOVE_GUI WITH MOUSE, FAILED MISERABLY
        
        ; ; ************************************************************
        ; Board_init_GUI myBoard, 04h, 00h

        ; main_L1:
        ;     LEA AX, getCoordsFromMouseClick
        ;     awaitMouseClick AX, 0, 0, 34

        ;     ; CALL liveUsage

        ;     get_number DL, CL, main, num1

        ;     XOR AX, AX
        ;     MOV AL, num1

        ;     ; CALL liveUsage

        ;     LEA AX, getCoordsFromMouseClick
        ;     awaitMouseClick AX, 0, 0, 34

        ;     get_number DL, CL, main, num2

        ;     XOR AX, AX
        ;     XOR BX, BX

        ;     MOV AL, num1
        ;     MOV BL, num2

        ;     ; CALL liveUsage

        ;     Move_GUI num1, num2, 0000h
        ; JMP main_L1
        ; ; ************************************************************

        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main
