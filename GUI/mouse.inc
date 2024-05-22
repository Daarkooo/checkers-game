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

    __setupMouse PROC ; initialX, initialY, minXRange, minYRange, maxXRange, maxYRange
        PUSH BP
        MOV BP, SP

        ; [BP +  4]: maxYRange
        ; [BP +  6]: maxXRange
        ; [BP +  8]: minYRange
        ; [BP + 10]: minXRange
        ; [BP + 12]: initialY
        ; [BP + 14]: initialX

        ; set up mouse drivers
        XOR AX, AX
        INT 33h

        ; set initial mouse position to (0, 0) to avoid distrubing the menu
        MOV AX, 0004h
        MOV CX, [BP + 14]
        MOV DX, [BP + 12]
        INT 33h

        ; display mouse
        MOV AX, 0001h
        INT 33h

        ; will do (maximum range - 3)
        ; horizontal range
        MOV AX, 0007h
        MOV CX, [BP + 10]
        MOV DX, [BP + 6]
        INT 33h

        ; vertical range
        MOV AX, 0008h
        MOV CX, [BP + 8]
        MOV DX, [BP + 4]
        INT 33h

        MOV SP, BP
        POP BP
        RET 12
    __setupMouse ENDP

    setupMouse MACRO initialX, initialY, minXRange, minYRange, maxXRange, maxYRange
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV AX, initialX
        PUSH AX

        MOV AX, initialY
        PUSH AX

        MOV AX, minXRange
        PUSH AX

        MOV AX, minYRange
        PUSH AX

        MOV AX, maxXRange
        PUSH AX

        MOV AX, maxYRange
        PUSH AX

        CALL __setupMouse

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


        sleep 0000h, 0C350h     ; 50000  MicroSecond


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

    ; For now, this is the event handler to make moves in game
    ; returns x (column) and y (row) in CX and DX, respectively
    __getCoordsFromMouseClick PROC ; xOffset, yOffset, cellSize, xPosition, yPosition
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

        ; y = line * size + offset

        ; y position
        XOR DX, DX
        MOV AX, [BP + 4]
        SUB AX, [BP + 10]
        DIV WORD PTR [BP + 8]
        MOV DX, AX

        MOV SP, BP
        POP BP
        RET 10
    __getCoordsFromMouseClick ENDP

    getCoordsFromMouseClick MACRO xOffset, yOffset, cellSize, xPosition, yPosition
        MOV AX, xOffset
        PUSH AX

        MOV AX, yOffset
        PUSH AX

        MOV AX, cellSize
        PUSH AX

        MOV AX, xPosition
        PUSH AX

        MOV AX, yPosition
        PUSH AX

        CALL __getCoordsFromMouseClick
    ENDM

    ; For now, this is the event handler that returns which menu button was clicked, returns result in AX
    ; 0: nothing
    ; 1: SP/MP
    ; 2: makla
    ; 3: start
    ; 4: theme1
    ; 5: theme2
    ; 6: theme3
    ; 7: theme4
    ; F: exit
    getMenuOptionClicked PROC ; fakeArg1, fakeArg2, fakeArg3, xPosition, yPosition
        PUSH BP
        MOV BP, SP

        ; [BP + 4]: yPosition
        ; [BP + 6]: xPosition

        EXIT_LABEL:
            CMP WORD PTR [BP + 4], EXIT_Y
            JL SPMP_LABEL

            MOV AX, EXIT_Y
            ADD AX, 30
            CMP [BP + 4], AX
            JG SPMP_LABEL

            CMP WORD PTR [BP + 6], EXIT_X
            JL SPMP_LABEL

            MOV AX, EXIT_X
            ADD AX, 70
            CMP [BP + 6], AX
            JG SPMP_LABEL

            MOV AX, 000Fh
        JMP END_LABEL

        SPMP_LABEL:
            CMP WORD PTR [BP + 4], SPMP_Y
            JL MAKLA_LABEL

            MOV AX, SPMP_Y
            ADD AX, 50
            CMP [BP + 4], AX
            JG MAKLA_LABEL

            CMP WORD PTR [BP + 6], SPMP_X
            JL MAKLA_LABEL

            MOV AX, SPMP_X
            ADD AX, 120
            CMP [BP + 6], AX
            JG MAKLA_LABEL

            MOV AX, 0001h
        JMP END_LABEL

        MAKLA_LABEL:
            CMP WORD PTR [BP + 4], MAKLA_Y
            JL START_LABEL

            MOV AX, MAKLA_Y
            ADD AX, 50
            CMP [BP + 4], AX
            JG START_LABEL

            CMP WORD PTR [BP + 6], MAKLA_X
            JL START_LABEL

            MOV AX, MAKLA_X
            ADD AX, 120
            CMP [BP + 6], AX
            JG START_LABEL

            MOV AX, 0002h
        JMP END_LABEL

        START_LABEL:
            CMP WORD PTR [BP + 4], START_Y
            JL THEME0_LABEL

            MOV AX, START_Y
            ADD AX, 50
            CMP [BP + 4], AX
            JG THEME0_LABEL

            CMP WORD PTR [BP + 6], START_X
            JL THEME0_LABEL

            MOV AX, START_X
            ADD AX, 120
            CMP [BP + 6], AX
            JG THEME0_LABEL

            MOV AX, 0003h
        JMP END_LABEL

        THEME0_LABEL:
            CMP WORD PTR [BP + 4], THEME0_Y
            JL THEME1_LABEL

            MOV AX, THEME0_Y
            ADD AX, 34
            CMP [BP + 4], AX
            JG THEME1_LABEL

            CMP WORD PTR [BP + 6], THEME0_X
            JL THEME1_LABEL

            MOV AX, THEME0_X
            ADD AX, 34
            CMP [BP + 6], AX
            JG THEME1_LABEL

            MOV AX, 0004h
        JMP END_LABEL

        THEME1_LABEL:
            CMP WORD PTR [BP + 4], THEME1_Y
            JL THEME2_LABEL

            MOV AX, THEME1_Y
            ADD AX, 34
            CMP [BP + 4], AX
            JG THEME2_LABEL

            CMP WORD PTR [BP + 6], THEME1_X
            JL THEME2_LABEL

            MOV AX, THEME1_X
            ADD AX, 34
            CMP [BP + 6], AX
            JG THEME2_LABEL

            MOV AX, 0005h
        JMP END_LABEL

        THEME2_LABEL:
            CMP WORD PTR [BP + 4], THEME2_Y
            JL THEME3_LABEL

            MOV AX, THEME2_Y
            ADD AX, 34
            CMP [BP + 4], AX
            JG THEME3_LABEL

            CMP WORD PTR [BP + 6], THEME2_X
            JL THEME3_LABEL

            MOV AX, THEME2_X
            ADD AX, 34
            CMP [BP + 6], AX
            JG THEME3_LABEL

            MOV AX, 0006h
        JMP END_LABEL

        THEME3_LABEL:
            CMP WORD PTR [BP + 4], THEME3_Y
            JL NOTHING_LABEL

            MOV AX, THEME3_Y
            ADD AX, 34
            CMP [BP + 4], AX
            JG NOTHING_LABEL

            CMP WORD PTR [BP + 6], THEME3_X
            JL NOTHING_LABEL

            MOV AX, THEME3_X
            ADD AX, 34
            CMP [BP + 6], AX
            JG NOTHING_LABEL

            MOV AX, 0007h
        JMP END_LABEL

        NOTHING_LABEL:
            XOR AX, AX

        END_LABEL:

        MOV SP, BP
        POP BP
        RET 10
    getMenuOptionClicked ENDP


    ; For now, this is the event handler that returns what was clicked while inGame, if board was 
    ; clicked, it returns row & column in DX & CX, respectively
    ; Returns status code in AX following the following codification:
    ; 0000h: Nothing
    ; 0001h: Board (regular move)
    ; 0002h: Resign
    ; 0003h: Quit
    getOptionClickedInGame PROC ; fakeArg1, fakeArg2, fakeArg3, xPosition, yPosition
        PUSH BP
        MOV BP, SP

        ; [BP +  4]: yPosition
        ; [BP +  6]: xPosition
        ; [BP +  8]: cellSize
        ; [BP + 10]: offsetY
        ; [BP + 12]: offsetX

        GOCIG_QUIT_LABEL:
            CMP WORD PTR [BP + 6], 29
            JL GOCIG_RESIGN_LABEL

            CMP WORD PTR [BP + 6], 99
            JG GOCIG_RESIGN_LABEL
            
            CMP WORD PTR [BP + 4], 283
            JL GOCIG_RESIGN_LABEL

            CMP WORD PTR [BP + 4], 319
            JG GOCIG_RESIGN_LABEL

            MOV AX, 0003h
        JMP GOCIG_END_LABEL

        GOCIG_RESIGN_LABEL:
            CMP WORD PTR [BP + 6], 189
            JL GOCIG_BOARD_LABEL

            CMP WORD PTR [BP + 6], 273
            JG GOCIG_BOARD_LABEL
            
            CMP WORD PTR [BP + 4], 283
            JL GOCIG_BOARD_LABEL

            CMP WORD PTR [BP + 4], 319
            JG GOCIG_BOARD_LABEL

            MOV AX, 0002h
        JMP END_LABEL

        GOCIG_BOARD_LABEL:
            CMP WORD PTR [BP + 6], offsetX      ; minimum X
            JL GOCIG_NOTHING_LABEL

            MOV AX, offsetX
            ADD AX, 340
            CMP WORD PTR [BP + 6], AX           ; maximum X
            JG GOCIG_NOTHING_LABEL

            CMP WORD PTR [BP + 4], offsetY      ; minimum Y
            JL GOCIG_NOTHING_LABEL

            MOV AX, offsetY
            ADD AX, 340
            CMP WORD PTR [BP + 4], AX           ; maximum Y
            JG GOCIG_NOTHING_LABEL

            ; ! ****************************************************************
            PUSH BX
            PUSH DI

            MOV AX, [BP + 12]               ; xOffset
            MOV BX, [BP + 10]               ; yOffset
            MOV CX, [BP + 8]                ; cellSize
            MOV DX, [BP + 6]                ; xPosition
            MOV DI, [BP + 4]                ; yPosition
            getCoordsFromMouseClick AX, BX, CX, DX, DI

            POP DI
            POP BX
            ; ! ****************************************************************

            MOV AX, 0001h
        JMP GOCIG_END_LABEL

        GOCIG_NOTHING_LABEL:
            MOV AX, 0000h

        GOCIG_END_LABEL:

        MOV SP, BP
        POP BP
        RET 10
    getOptionClickedInGame ENDP