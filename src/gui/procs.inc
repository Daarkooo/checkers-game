.CODE
    __sleep PROC; CX, DX
        PUSH BP
        MOV BP, SP

        MOV AX, 8600h
        MOV DX, [BP + 4]
        MOV CX, [BP + 6]
        INT 15h

        MOV SP, BP
        POP BP
        RET 4
    __sleep ENDP

    sleep MACRO highW, lowW
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV AX, highW
        PUSH AX

        MOV AX, lowW
        PUSH AX

        CALL __sleep

        POP DX
        POP CX
        POP BX
        POP AX
    ENDM

    __awaitMouseClick PROC; callback, arg1, arg2, arg3
        PUSH BP
        MOV BP, SP

        MOV AX, [BP + 8]    ; arg1
        PUSH AX

        MOV AX, [BP + 6]    ; arg2
        PUSH AX

        MOV AX, [BP + 4]    ; arg3
        PUSH AX

        __awaitMouseClick_mainLoop:
            MOV AX, 3h          ; Function 3: Get mouse position and button status
            INT 33h             ; Call mouse interrupt

            TEST BL, 1          ; Check if left button is pressed
        JZ __awaitMouseClick_mainLoop

        sleep 0003h, 0D40h

        PUSH CX     ; column (x) 
        PUSH DX     ; row (y)

        CALL [BP + 10]

        MOV SP, BP
        POP BP
        RET 8
    __awaitMouseClick ENDP

    ; arg1 and arg2 arguments to callback; order of PUSH: arg1 --> arg2 --> arg3 --> CX (X position) --> DX (Y position)
    ; it is Advisable to push 'arg1', 'arg2' & 'arg3'; even if their values is 0
    awaitMouseClick MACRO callback, arg1, arg2, arg3
        PUSH callback  ; Push the offset of the callback
        
        MOV AX, arg1
        PUSH AX

        MOV AX, arg2
        PUSH AX

        MOV AX, arg3
        PUSH AX

        CALL __awaitMouseClick
    ENDM