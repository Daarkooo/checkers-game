;--------------algorithm(C)--------------
;fun find_column(n){
;    x = n mod 10,
;         if(x==0){
;              retourn 9,
;        }
;         else if(x<6){
;             retourn x * 2
;        }
;         else{
;            retourn((x-5)*2-1)
;       }
; }


;-------------assembly--------------
DATA SEGMENT 
    n DB ?   
    msg_result DB "result: $"
DATA ENDS

CODE SEGMENT  
ASSUME CS:CODE, DS:DATA

find_column MACRO n
    LOCAL not_eqaul_zero, not_less_than_6

    MOV AL, n
    XOR AH, AH 
    MOV BL, 10
    DIV BL    ; divide AL by BL, q -> AL, r -> AH

    ; check if x == 0
    CMP AH, 0
    JNE not_eqaul_zero
    MOV AL, 8 ; return 8
    JMP END
not_eqaul_zero:

    ; check if x < 6
    CMP AH, 6
    JGE not_less_than_6
    MOV AL, AH
    SHL AL, 1
    DEC AL ; retrun ah * 2 -1
    JMP END
not_less_than_6:

    ; x >= 6
    MOV AL, AH
    SUB AL, 5
    SHL AL, 1
    DEC AL
    DEC AL  ; return (ah-5)*2-1

END:

ENDM

START:
    MOV AX, @DATA
    MOV DS, AX

    find_column 24; calling 
 
    

CODE ENDS
END START





