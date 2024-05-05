; Formule pour l'algorithmique (les indexes sont de 1 à 10): (N - 1) / 5 + 1
; Formule pour assembly (les indexes sont de 0 à 9): (N - 1) / 5
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