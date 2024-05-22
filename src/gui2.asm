.MODEL SMALL

.STACK 100h

.DATA
    xArray      DW  2, 3, 2, 5 DUP(1), 0, 1, 2 DUP(0), 1, 0, 0
    CaseSize    DB  34
    CaseSize2   DB  17
    board       DB  10 DUP('w'), 20 DUP('0'), 20 DUP('b')
    blackColor  DW  06h
    innerColor DW 03H
    whiteColor DW 10H
    xOffset DW 0
    yOffset DW 0

.CODE
    PushReg MACRO 
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
    ENDM

    PopReg MACRO
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
    ENDM

    __drawCell PROC ; color, x, y, size  (last parameteres are top of stack)
        PUSH BP
        MOV BP, SP
        SUB SP, 4
        
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        MOV AL, BYTE PTR [BP + 10]
        MOV AH, 0Ch
        
        MOV BX, [BP + 4]
        ADD BX, [BP + 6]
        MOV [BP - 2], BX        ; final y
        
        MOV BX, [BP + 4]
        ADD BX, [BP + 8]
        MOV [BP - 4], BX        ; final x
        
        MOV DX, [BP + 6]        ; initial y
        MOV CX, [BP + 8]        ; initial x
        
        XOR BH, BH
        L1:
        MOV CX, [BP + 8]    ; reseting the x
        L2:
        INT 10h
        INC CX
        
        CMP CX, [BP - 4]
        JLE L2
        
        INC DX
        CMP DX, [BP - 2]
        JLE L1
        
        POP DX
        POP CX
        POP BX
        POP AX
        
        MOV SP, BP
        POP BP
        RET 8                   ; cleaning the stack
        __drawCell ENDP
        
        drawCell MACRO color, x, y, size
        MOV AX, color
        PUSH AX
        
        MOV AX, x
        PUSH AX
        
        MOV AX, y
        PUSH AX
        
        MOV AX, size
        PUSH AX
        
        CALL __drawCell
    ENDM

    __drawBoard PROC ; initialX, initialY, whiteCell, blackCell, size (last parameteres are top of stack)
        PUSH BP
        MOV BP, SP
        SUB SP, 4
        
        ; getting the final X
        MOV AX, [BP + 4]        ; size
        MOV BX, 10
        MUL BX
        
        ADD AX, [BP + 12]       
        MOV [BP - 2], AX        ; final X
        
        ; getting the final Y
        MOV AX, [BP + 4]        ; size
        MOV BX, 10
        MUL BX
        
        ADD AX, [BP + 10]       
        MOV [BP - 4], AX        ; final Y


        MOV CX, [BP + 10]       ; initial y
        MOV BX, [BP + 4]
        outer_loop:
            MOV DX, [BP + 12]       ; initial x
            
            inner_loop1:
                MOV AX, [BP + 8]        ; white color
                drawCell AX, DX, CX, BX
                ADD DX, BX
            
                MOV AX, [BP + 6]        ; black color
                drawCell AX, DX, CX, BX
                ADD DX, BX
            
                CMP DX, [BP - 2]
            JL inner_loop1
            
            MOV DX, [BP + 12]
            ADD CX, BX
            inner_loop2:
                MOV AX, [BP + 6]        ; black color
                drawCell AX, DX, CX, BX
                ADD DX, BX
            
                MOV AX, [BP + 8]        ; white color
                drawCell AX, DX, CX, BX
                ADD DX, BX
            
                CMP DX, [BP - 2]
            JL inner_loop2
            
            
            ADD CX, BX
            CMP CX, [BP - 4]
        JL outer_loop
        
        MOV SP, BP
        POP BP
        RET 10
    __drawBoard ENDP

    drawBoard MACRO initialX, initialY, whiteColor, blackColor, size
        MOV AX, initialX
        PUSH AX

        MOV AX, initialY
        PUSH AX        
        
        MOV AX, whiteColor
        PUSH AX
        
        MOV AX, blackColor
        PUSH AX
        
        MOV AX, size
        PUSH AX
        
        CALL __drawBoard
    ENDM

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

    Board_init_GUI Macro Board,whiteColor,blackColor,innerColor,xOffset,yOffset
        drawBoard 0, 0, 000Fh, 0006h, 34
        MOV CX,16
        ADD CX,xOffset
        LEA SI,board
        Black:
        
            MOV DX,52
            ADD DX,yOffset
            MOV BX,5
            Line0:
       
                PushReg
                MOV al,[SI]
                CMP AL,'b'
                JNE white0
                black0:
                    drawCircle blackColor,DX,CX  
                    JMP finCircle0
                white0:
                    CMP AL,'w'
                    JNE blackqueen0
                    drawCircle whiteColor,DX,CX 
                    JMP finCircle0
                blackqueen0:
                    CMP AL,'B'
                    JNE whitequeen0
                    MOV AX,SI
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    JMP finCircle0
                whitequeen0:
                    CMP AL,'W'
                    JNE finCircle0
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    JMP finCircle0
                        
                finCircle0:
                PopReg
                
                ADD DX,68 ; 2 CASES
                INC SI
                DEC BX
                CMP BX,0
                JNZ Line0
            ADD CX, 34
            MOV DX, 16
            ADD DX,yOffset
            MOV BX, 5
            Line1:
                PushReg
                MOV al,[SI]
                CMP AL,'b'
                JNE white1
                black1:
                    drawCircle blackColor,DX,CX  
                    JMP finCircle1
                white1:
                    CMP AL,'w'
                    JNE blackqueen1
                    drawCircle whiteColor,DX,CX 
                    JMP finCircle1
                blackqueen1:
                    CMP AL,'B'
                    JNE whitequeen1
                    MOV AX,SI
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    JMP finCircle1
                whitequeen1:
                    CMP AL,'W'
                    JNE finCircle1
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    
                finCircle1:
                PopReg
                
                ADD DX,68 ; 2 CASES
                INC SI
                DEC BX
                CMP BX,0
                JNZ Line1
            ADD CX, 34
            MOV DX, 52
            ADD DX,yOffset
            MOV BX, 5
            Line2:
                PushReg
                MOV al,[SI]
                CMP AL,'b'
                JNE white2
                black2:
                    drawCircle blackColor,DX,CX  
                    JMP finCircle2
                white2:
                    CMP AL,'w'
                    JNE blackqueen2
                    drawCircle whiteColor,DX,CX
                    JMP finCircle2
                blackqueen2:
                    CMP AL,'B'
                    JNE whitequeen2
                    MOV AX,SI
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    JMP finCircle2
                whitequeen2:
                    CMP AL,'W'
                    JNE finCircle2
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    
                finCircle2:
                PopReg
                ADD DX,68 ; 2 CASES
                INC SI
                DEC BX
                CMP BX,0
                JNZ Line2    
            ADD CX, 34
            MOV DX, 16
            ADD DX,yOffset
            MOV BX, 5
            Line3:
                PushReg
                MOV al,[SI]
                CMP AL,'b'
                JNE white3
                black3:
                    drawCircle blackColor,DX,CX  
                    JMP finCircle3
                white3:
                    CMP AL,'w'
                    JNE blackqueen3
                    drawCircle whiteColor,DX,CX 
                    JMP finCircle3
                blackqueen3:
                    CMP AL,'B'
                    JNE whitequeen3
                    MOV AX,SI
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor 
                    JMP finCircle3
                whitequeen3:
                    CMP AL,'W'
                    JNE finCircle3
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    
                finCircle3:
                PopReg
                ADD DX,68 ; 2 CASES
                INC SI
                DEC BX
                CMP BX,0
                JNZ Line3
            ADD CX, 34
            MOV DX,52
            ADD DX,yOffset
            MOV BX,5
            Line4:
                PushReg
                MOV al,[SI]
                CMP AL,'b'
                JNE white4
                black4:
                    drawCircle blackColor,DX,CX  
                    JMP finCircle4
                white4:
                    CMP AL,'w'
                    JNE blackqueen4
                    drawCircle whiteColor,DX,CX 
                    JMP finCircle4
                blackqueen4:
                    CMP AL,'B'
                    JNE whitequeen4
                    MOV AX,SI
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor 
                    JMP finCircle4
                whitequeen4:
                    CMP AL,'W'
                    JNE finCircle4
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    
                finCircle4:
                PopReg
                ADD DX,68 ; 2 CASES
                INC SI
                DEC BX
                CMP BX,0
                JNZ Line4 
            ADD CX, 34
            MOV DX, 16
            ADD DX,yOffset
            MOV BX, 5           
            Line5:
                PushReg
                MOV al,[SI]
                CMP AL,'b'
                JNE white5
                black5:
                    drawCircle blackColor,DX,CX  
                    JMP finCircle5
                white5:
                    CMP AL,'w'
                    JNE blackqueen5
                    drawCircle whiteColor,DX,CX 
                    JMP finCircle5
                blackqueen5:
                    CMP AL,'B'
                    JNE whitequeen5
                    MOV AX,SI
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    JMP finCircle5
                whitequeen5:
                    CMP AL,'W'
                    JNE finCircle5
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    
                finCircle5:
                PopReg
                ADD DX,68 ; 2 CASES
                INC SI
                DEC BX
                CMP BX,0
                JNZ Line5
            ADD CX, 34
            MOV DX,52
            ADD DX,yOffset
            MOV BX,5
            Line6:
                PushReg
                MOV al,[SI]
                CMP AL,'b'
                JNE white6
                black6:
                    drawCircle blackColor,DX,CX  
                    JMP finCircle6
                white6:
                    CMP AL,'w'
                    JNE blackqueen6
                    drawCircle whiteColor,DX,CX
                    JMP finCircle6
                blackqueen6:
                    CMP AL,'B'
                    JNE whitequeen6
                    MOV AX,SI
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor 
                    JMP finCircle6
                whitequeen6:
                    CMP AL,'W'
                    JNE finCircle6
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    
                finCircle6:
                PopReg
                ADD DX,68 ; 2 CASES
                INC SI
                DEC BX
                CMP BX,0
                JNZ Line6
            ADD CX, 34
            MOV DX, 16
            ADD DX,yOffset
            MOV BX, 5
            Line7:
                PushReg
                MOV al,[SI]
                CMP AL,'b'
                JNE white7
                black7:
                    drawCircle blackColor,DX,CX  
                    JMP finCircle7
                white7:
                    CMP AL,'w'
                    JNE blackqueen7
                    drawCircle whiteColor,DX,CX  
                    JMP finCircle7
                blackqueen7:
                    CMP AL,'B'
                    JNE whitequeen7
                    MOV AX,SI
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor 
                    JMP finCircle7
                whitequeen7:
                    CMP AL,'W'
                    JNE finCircle7
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    
                finCircle7:
                PopReg
                ADD DX,68 ; 2 CASES
                INC SI
                DEC BX
                CMP BX,0
                JNZ Line7
            ADD CX, 34
            MOV DX, 52
            ADD DX,yOffset
            MOV BX, 5
            Line8:
                PushReg
                MOV al,[SI]
                CMP AL,'b'
                JNE white8
                black8:
                    drawCircle blackColor,DX,CX  
                    JMP finCircle8
                white8:
                    CMP AL,'w'
                    JNE blackqueen8
                    drawCircle whiteColor,DX,CX
                    JMP finCircle8
                blackqueen8:
                    CMP AL,'B'
                    JNE whitequeen8
                    MOV AX,SI
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    JMP finCircle8
                whitequeen8:
                    CMP AL,'W'
                    JNE finCircle8
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    
                finCircle8:
                PopReg
                ADD DX,68 ; 2 CASES
                INC SI
                DEC BX
                CMP BX,0
                JNZ Line8    
            ADD CX, 34
            MOV DX, 16
            ADD DX,yOffset
            MOV BX, 5
            Line9:
                PushReg
                MOV al,[SI]
                CMP AL,'b'
                JNE white9
                black9:
                    drawCircle blackColor,DX,CX  
                    JMP finCircle9
                white9:
                    CMP AL,'w'
                    JNE blackqueen9
                    drawCircle whiteColor,DX,CX
                    JMP finCircle9
                blackqueen9:
                    CMP AL,'B'
                    JNE whitequeen9
                    MOV AX,SI
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    JMP finCircle9
                whitequeen9:
                    CMP AL,'W'
                    JNE finCircle9
                    drawQueen AL, xOffset, yOffset, 34, blackColor, innerColor
                    
                finCircle9:
                PopReg
                ADD DX,68 ; 2 CASES
                INC SI
                DEC BX
                CMP BX,0
                JNZ Line9     
    ENDM

    getRow MACRO Num, result
        LOCAL errorLabel, endLabel
        XOR AX, AX

        MOV AL, Num

        TEST AL, AL
        JZ errorLabel

        CMP AL, 50
        JA errorLabel

        DEC AL
        MOV BL, 5
        DIV BL
        JMP endLabel
        
        errorLabel:
            MOV AL, -1    
        
        endLabel:
            MOV result, AL        
    ENDM

    get_column MACRO n,result
        LOCAL not_eqaul_zero, not_less_than_6, fin

        MOV AL, n
        XOR AH, AH 
        MOV BL, 10
        DIV BL    ; divide AL by BL, q -> AL, r -> AH

        ; check if x == 0
        CMP AH, 0
        JNE not_eqaul_zero
        MOV AL, 8 ; return 8
        JMP fin
        not_eqaul_zero:

            ; check if x < 6
            CMP AH, 6
            JGE not_less_than_6
            MOV AL, AH
            SHL AL, 1
            DEC AL ; retrun ah * 2 -1
            JMP fin
        not_less_than_6:

            ; x >= 6
            MOV AL, AH
            SUB AL, 5
            SHL AL, 1
            DEC AL
            DEC AL  ; return (ah-5)*2-1

        fin:
            MOV result,AL
    ENDM

    
    GetCase Macro x,y,R,C
            XOR AX, AX
            MOV AL, x
            MOV BL, CaseSize
            MUL BL 
            MOV R, AX
            
            XOR AX, AX
            MOV AL, y
            MOV BL, CaseSize
            MUL BL 
            MOV C, AX
    ENDM
    
    GetCenter Macro x,y,R,C
            XOR AX, AX
            MOV AL, x
            MOV BL, CaseSize
            MUL BL
            XOR BX, BX
            MOV BL, CaseSize2 
            ADD AX, BX
            MOV R, AX

            XOR AX, AX
            MOV AL, y
            MOV BL, CaseSize
            MUL BL 
            XOR BX, BX
            MOV BL, CaseSize2 
            ADD AX, BX
            MOV C, AX
    ENDM
        
    
    Move_GUI Macro n1,n2,PColor
            LOCAL MoveGui,MoveG,MoveD,MoveDownD,MoveTopD,MoveDownG,MoveTopG,FinMove,      notMove1, notMove2, notMove3
            MoveGui:
                MOV AL,n1
                CMP AL,n2
                
                JNZ notMove1
                JMP FinMove
                notMove1:
                
                get_column n1,DL
                get_column n2,DH
                
                CMP DL,DH
                
                JL MoveD
                JMP MoveG
                
                MoveD:
                   getRow n1,CL
                   getRow n2,CH
                   
                   CMP CL,CH
                   JAE MoveTopD
                   
                   MoveDownD:
                      CMP DL,DH
                      JNZ notMove2
                      JMP FinMove
                      notMove2:
                      PUSH DX
                      PUSH CX
                      
                         GetCase DL,CL,DX, CX
                         drawCell 0006h, DX, CX, 34
                      
                      POP CX
                      POP DX
                      ADD DL,1
                      ADD CL,1
                      JMP MoveDownD

                      
                   MoveTopD:
                      CMP DL,DH
                      JNZ notMove3
                      JMP FinMove
                      notMove3:
                      PUSH DX
                      PUSH CX
                      
                         GetCase DL,CL,DX, CX
                         drawCell 0006h, DX, CX, 34
                      
                      POP CX
                      POP DX
                      ADD DL,1
                      SUB CL,1
                      JMP MoveTopD
                      
                MoveG:
                   getRow n1,CL
                   getRow n2,CH
                   
                   CMP CL,CH
                   JAE MoveTopG
                   
                   MoveDownG:
                      CMP DL,DH
                      JE FinMove
                      PUSH DX
                      PUSH CX
                      
                         GetCase DL,CL,DX, CX
                         drawCell 0006h, DX, CX, 34
                      
                      POP CX
                      POP DX
                      SUB DL,1
                      ADD CL,1
                      JMP MoveDownG
                   
                   MoveTopG:
                      CMP DL,DH
                      JE FinMove
                      PUSH DX
                      PUSH CX
                      
                        GetCase DL,CL,DX, CX
                        drawCell 0006h, DX, CX, 34
                      
                      POP CX
                      POP DX
                      SUB DL,1
                      SUB CL,1
                      JMP MoveTopG
                JMP MoveGui
            FinMove:
                GetCenter Dh,Ch,DX,CX
                drawCircle PColor, DX,CX
                
    ENDM
    
    Time Macro
        mov ah, 00h 
        int 16h
    ENDM
    main PROC
        MOV AX, @DATA
        MOV DS, AX
        
        MOV BP, SP
        
        MOV AX, 0012h
        INT 10h
        
        Board_init_GUI Board,whiteColor,blackColor,innerColor,xOffset,yOffset

             
        MOV AX, 4C00h
        INT 21h
    main ENDP
END main
