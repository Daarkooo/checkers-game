.MODEL SMALL

.STACK 100h

.DATA
        xArray  DW  2, 3, 2, 5 DUP(1), 0, 1, 2 DUP(0), 1, 0, 0   
.CODE
    __drawHorizontalLine PROC ; color, startingX, Y, distance
        PUSH BP
        MOV BP, SP
        SUB SP, 2
        
        PUSH BX
        PUSH CX
        PUSH DX
        
        ; column to stop at
        MOV AX, [BP + 8]
        ADD AX, [BP + 4]
        MOV [BP - 2], AX
        
        MOV AH, 0Ch
        MOV AL, BYTE PTR [BP + 10]
        MOV CX, [BP + 8]
        MOV DX, [BP + 6]
        XOR BX, BX
        
        __drawHorizontalLine_L1:
            INT 10h
            INC CX
            CMP CX, [BP - 2]
        JL __drawHorizontalLine_L1            
        
        POP DX
        POP CX
        POP BX
        
        MOV SP, BP
        POP BP
        RET 8
    __drawHorizontalLine ENDP
    
    drawHorizontalLine MACRO color, startingX, Y, distance
        MOV AX, color
        PUSH AX
        
        MOV AX, startingX
        PUSH AX
        
        MOV AX, Y
        PUSH AX
        
        MOV AX, distance
        PUSH AX
        
        CALL __drawHorizontalLine
    ENDM

    __drawCircle PROC ; color, initialX, initialY (last parameters top of stack)
        PUSH BP
        MOV BP, SP
        
        ; [BP + 4] initialY
        ; [BP + 6] initialX
        ; [BP + 8] color
        
        MOV CX, [BP + 6]
        MOV DX, [BP + 4]
        SUB DX, 14

        XOR BX, BX
        XOR SI, SI
        __drawCircle_L1:
            MOV AX, [BP + 8]
            SUB CX, xArray[SI]      ; new X
            
            ADD BX, xArray[SI]      ; distance is double
            ADD BX, xArray[SI]
            
            drawHorizontalLine AX, CX, DX, BX
            
            ADD SI, 2
            INC DX
            CMP SI, 30
        JL __drawCircle_L1
             
            SUB SI, 2 
         ;   SUB SI, 2
         ;   drawHorizontalLine AX, CX, DX, BX
         ;   INC DX
         ;   drawHorizontalLine AX, CX, DX, BX
        __drawCircle_L2:
            MOV AX, [BP + 8]
            ADD CX, WORD PTR xArray[SI]      ; new X
            
            SUB BX, WORD PTR xArray[SI]      ; distance is double
            SUB BX, WORD PTR xArray[SI]
            
            drawHorizontalLine AX, CX, DX, BX
            
            SUB SI, 2
            INC DX
            TEST SI, SI
        JNZ __drawCircle_L2
 
        MOV SP, BP
        POP BP
        RET 6
    __drawCircle ENDP
         
    drawCircle MACRO color, initialX, initialY
        MOV AX, color
        PUSH AX
        
        MOV AX, initialX
        PUSH AX
        
        MOV AX, initialY
        PUSH AX
        
        CALL __drawCircle
    ENDM  

    main PROC
        MOV AX, @DATA
        MOV DS, AX
        
        MOV BP, SP
        
        MOV AX, 0013h
        INT 10h
        
        drawCircle 0Fh, 30, 30
        
        MOV AX, 4Ch
        INT 21h
    main ENDP
END main
