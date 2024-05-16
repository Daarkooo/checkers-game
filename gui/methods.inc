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