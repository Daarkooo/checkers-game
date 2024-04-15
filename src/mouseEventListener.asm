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

    main PROC
        MOV AX, @DATA
        MOV DS, AX

        PUSH BP
        MOV BP, SP

        ; set up video mode
        MOV AX, 0012h   ; 640x480 16-color
        INT 10h

        ; set up mouse
        XOR AX, AX
        INT 33h

        ; display mouse
        MOV AX, 0001h
        INT 33h

        ; went for maximum range
        ; horizontal range
        MOV AX, 0007h
        MOV CX, 0
        MOV DX, 640
        INT 33h

        ; vertical range
        MOV AX, 0008h
        MOV CX, 0
        MOV DX, 480
        INT 33h

        ; print str1
        LEA DX, str1
        MOV AH, 09h
        INT 21h

        LEA AX, eventHandler
        awaitMouseLeftClick AX

        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main
