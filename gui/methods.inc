.data
    isValid     DB      ?

.code  

makla_sif_check MACRO IndMoves, bool, isValid
    LOCAL no_IndMove,next, end

    CMP IndMoves[0], 0
    JNE next
        JMP no_IndMove
    next:

        PUSH CX
        PUSH DX
        is_value_in_array DL, CL, IndMoves, bool
        POP DX
        POP CX

        CMP bool, 1
        JE no_IndMove ; pawn picked 3ndou makla  
            MOV AL,0
            MOV isValid, AL
            JMP end

    no_IndMove:
        MOV AL,1
        MOV isValid, AL
    end:

ENDM


;--------draw_borders---------------------
draw_borders MACRO IndMoves, directMove, color 
    LOCAL direct, show_M, show_Mm, end_moves, end_moves, end_moves1
    
    MOV AL,0
    MOV count,AL
    LEA SI, IndMoves 
    show_M:
        CMP BYTE PTR [SI], 0
        JE end_moves1
        MOV AL,BYTE PTR [SI]
        MOV pawn_position,AL
        drawBorderCell pawn_position, color, 0, 0, 34 ; GREEN
        INC SI 
        INC count
        JMP show_M
    end_moves1:
    
    CMP count,0
    JE direct
        CMP maklaSif, 1
        JE end_moves   
    direct:
    LEA SI, directMoves 
    show_Mm:
        CMP BYTE PTR [SI], 0
        JE end_moves
        MOV AL,BYTE PTR [SI]
        MOV pawn_position,AL
        drawBorderCell pawn_position, color, 0, 0, 34 ; GREEN
        INC SI 
        JMP show_Mm
    end_moves:

ENDM 

;---------show_moves------------- 
show_moves MACRO board, IndMoves, directMoves
    LOCAL lab1, lab2, lab3, directMove,continue, endL
    
    set_array_null IndMoves
    set_array_null directMoves

    LEA SI, board
    LEA DI, IndMoves
    LEA BX, directMoves  
    
    MOV CX, 50
    lab3:     
        
        ;CMP BYTE PTR [SI], AL
        ;JE continue
       ;     JMP lab1  
        ;continue:

            MOV DL,count
            PUSH CX
            PUSH BX
            
            get_row DL,i
            get_column DL,j 
            
            PUSH SI
            PUSH DI
            show_path board,i,j,turn,path1,path2,source_pawn,makla1,makla2,isDirect
            POP DI
            POP SI
            POP BX
            POP CX
                                       
            CMP path1, -1
            JNE lab2
                CMP path2, -1
                JE lab1 
                    lab2:  
                    MOV AL,source_pawn
                    ; DEC AL
                    CMP isDirect,'y'
                    JE directMove
                        MOV BYTE PTR [DI], AL
                        INC DI
                        JMP lab1
                    directMove:
                        MOV BYTE PTR [BX], AL
                        INC BX
        lab1:
            INC SI  
            INC count
    CMP CX,0
    JE endL
        DEC CX
        JMP lab3
    endL:

ENDM






; mark_cell_method MACRO turn






;-----is_value_in_array-----
is_value_in_array MACRO x, y, array, bool
    LOCAL lab1, exist, not_exist, end

    MOV DL, x
    MOV DH, y
    get_number DL, DH, menu, num
    MOV AL, num

    CMP AL, 0
    JE not_exist

    LEA SI, array
    lab1:
        CMP BYTE PTR [SI], 0
        JE not_exist

        CMP BYTE PTR [SI], AL
        JE exist
        INC SI
        JMP lab1

    exist:
        MOV bool, 1
        JMP end
    not_exist:
        MOV bool, 0
    end:

ENDM

;------set_array_null-----------
set_array_null MACRO array
    LOCAL lab

    LEA SI, array
    lab:
        MOV BYTE PTR [SI], 0
        INC SI 
        CMP BYTE PTR [SI], 0
        JNE lab

ENDM






; multiple_jumps MACRO check_direct, x1, x2, turn
;     LOCAL 

;     MOV AL,check_direct
;             CMP AL, 'n'
;             JE next_move
;                 JMP next1
;             next_move:

;             show_path board,x1,y1,turn,path1,path2,source_pawn,makla,makla2,isDirect

;             CMP isDirect, 'n'
;             JNE next1
            
;                 CMP path1,-1
;                 JE lab1
;                     MOV AL,1
;                 lab1:

;                 CMP path2,-1
;                 JE lab2
;                     MOV AL,1
;                 lab2:

;                 CMP AL,1    
;                 JNE next1
;                     JMP multi_jumps_lab
;             next1:



; ENDM