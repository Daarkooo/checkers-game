.MODEL SMALL

.STACK 100h

.DATA
    str1    DB  "After use: $"
    myBoard   DB  20 DUP('b'), 10 DUP('e'), 20 DUP('w')

    num1    DB  0
    num2    DB  0

    INCLUDE procs.inc
    INCLUDE GUI.inc
    INCLUDE print.inc

.CODE
    ; for now, this is the event handler tha I'll use
    ; returns x (column) and y (row) in CX and DX, respectively
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


    ; CHANGED SOMETHING HERE
    ; STORES THE DIVISOR (2) IN DH INSTEAD OF CL, BECAUSE I NEED CL IN INTERING THE ROW, SO HICHEM WAS OVERWRITING IT
    get_number MACRO row, column, main, Num
    LOCAL invalid, end, next
        ; (row % 2 === column % 2) 
        MOV AL,column 
        CMP AL,0
        JB invalid
        CMP AL,9
        JA invalid

        MOV AL,row ;[0002h]
        CMP AL,0
        JB invalid
        CMP AL,9
        JA invalid
        
        MOV AH,'y'
        CMP AH,main
        JNE next
            MOV NUM, 'v'; valid
            JMP end
        next:
        
        ; MOV AL,row ;[0002h]
        xor ah, ah
        mov dh, 2
        div dh
        mov bl, ah  ; Store (column % 2) in bl
        mov al, column
        xor ah, ah
        div dh
        cmp ah, bl  ; Compare (row % 2) with (column % 2)
        jz invalid  ; not a White Square
            ; Calculate the number
            mov al, row
            mov bl, 5
            mul bl  ; AL = row * 5
            mov bl, column
            shr bl, 1  ; Divide column by 2 
            add al, bl  ; AL = AL + (column / 2)
            inc al  ;the index starts from 0
        
            ; Store the number
            mov Num, al
            jmp end
        invalid:
            ; White square || invalid row/column
            mov Num, 0
        end:
    ENDM       

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
        
        ;  ************************************************************
        Board_init_GUI myBoard, 04h, 00h

        main_L1:
            LEA AX, getCoordsFromMouseClick
            awaitMouseClick AX, 0, 0, 34

            ; CALL liveUsage

            get_number DL, CL, main, num1

            XOR AX, AX
            MOV AL, num1

            ; CALL liveUsage

            LEA AX, getCoordsFromMouseClick
            awaitMouseClick AX, 0, 0, 34

            get_number DL, CL, main, num2

            XOR AX, AX
            XOR BX, BX

            MOV AL, num1
            MOV BL, num2

            ; CALL liveUsage

            Move_GUI num1, num2, 0000h
        JMP main_L1
        ;  ************************************************************

        POP BP
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main
