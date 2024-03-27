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
    n,i,j,x,y,turn,n1,n2,i1,j1,result DB ?   
    result DB ? 
    dame db 50 dup(?)    
    msg_result DB "result: $"
DATA ENDS

CODE SEGMENT  
ASSUME CS:CODE, DS:DATA


;------------find_clumn----------------
find_column MACRO n,result
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
    MOV result,AL

ENDM 


;------getNumber----------------  
getNumber MACRO row, column, Num
    LOCAL calculate_number, fin
        ; (row % 2 === column % 2)
        mov al, column
        xor ah, ah
        div byte ptr 2
        mov bl, ah  ; Store (column % 2) in bl
        mov al, row
        xor ah, ah
        div byte ptr 2
        cmp ah, bl  ; Compare (row % 2) with (column % 2)
        jnz calculate_number  ; not a White Square
    
        ; White square
        mov Num, 0
        jmp fin
    
    calculate_number:
        ; Subtract 1 from row and column to adjust them to the range [1,10]
        dec row
        dec column
    
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
    
    fin: 
ENDM  
   
   
;----------verify_move----------------   
verify_move MACRO i,j,x,y,turn  
    ; in place of turn I can compare between i & x (i < x -> Black's turn...) "only pawns"
    
    CALL getNumber i,j,n1
    CALL getNumber x,y,n2
    ; check if it's a valid input
    MOV DH,turn 
    
    ;---- BLACK's TURN--------------
    MOV AL, i
    XOR AH, AH   
    MOV BL, 2 
    DIV BL ;  divide AL by BL, q -> AL, r -> AH 
                      
    CMP AH, 0
    JNE impair ; i (odd line)
    
    CMP DL,'w'
    JE white_turn1
    MOV DL,n2  ; i (even line) 
    SUB DL,n1
    JMP next1 
    white_turn1:
    MOV DL,n1  ; i (even line) 
    SUB DL,n2
    next1:
    
    CMP DL,5 ; the first case of the direct move
    JE direct ;  
    CMP DL,6 ; 2nd case
    JNE indirect        
    direct:       
      CALL check_state_cell i,j
      ; if else (white black..)------ for a direct move it requires to be free to make the move 
      ; if it's black we jump to the end (cant move) 
      ; if it's white we test in the indirect move
    
    indirect: 
        CMP DL,9
        JE next ; 
        CMP DL,10
        JE next
        CMP DL,11
        JE next
        JNE end ; cant do the move
        next:
            CMP DL,'w'
            JE white_turn2:
                CALL check_state_cell x,y
                ; it requires to be free to make the move &.. else jump end
                
                CMP DL,9
                JE case1
                CMP DL,10
                JE case2
                CMP DL,11
                JE case3
                case1:
                MOV CL,n1
                ADD CL,5
                find_column CL,j1
                find_line CL,i1
                check_state_cell i1,j1  
                ; if it's white we can do the move
                JMP end
                case2:
                MOV CL,n1
                ADD CL,5
                find_column CL,j1
                find_line CL,i1
                check_state_cell i1,j1  
                ; if it's white we can do the move
                ; if it's black we check the other way   
                case3:  ; CASE 3
                INC CL
                find_column CL,j1
                find_line CL,i1 
                check_state_cell i1,j1
                ; if it's white we can do the move
                JMP end

            white_turn2:
                CALL check_state_cell x,y
                    ; it requires to be free to make the move &.. else jump end
                    
                    CMP DL,9
                    JE case1
                    CMP DL,10
                    JE case2
                    CMP DL,11
                    JE case3
                    case1:
                    MOV CL,n1
                    SUB CL,5 ; -------EDIT
                    find_column CL,j1
                    find_line CL,i1
                    check_state_cell i1,j1  
                    ; if it's white we can do the move
                    JMP end
                    case2:
                    MOV CL,n1
                    SUB CL,5
                    find_column CL,j1
                    find_line CL,i1
                    check_state_cell i1,j1  
                    ; if it's white we can do the move
                    ; if it's black we check the other way   
                    case3:  ; CASE 3
                    DEC CL
                    find_column CL,j1
                    find_line CL,i1 
                    check_state_cell i1,j1
                    ; if it's white we can do the move
                    JMP end
    
    
    impair:
        CMP DL,'w'
        JE white_turn3
            MOV DL,n2
            SUB DL,n1
            CMP DL,4 ; the first case of the direct move
            JE next      
            CMP DL,5 ; 2nd case
            JNE indirect        
            next:       
            CALL check_state_cell i,j
            ; if else (white black..)------ for a direct move it requires to be free to make the move 
            ; if it's black we jump to the end (cant move) 
            ; if it's white we test it in the indirect move
            
            indirect: 
                CMP DL,9
                JE next2
                CMP DL,10
                JE next2
                CMP DL,11
                JE next2
                JNE end ; cant do the move
                next2:
                    CALL check_state_cell x,y
                    ; it requires to be free to make the move &.. else jump end
                    
                    CMP DL,9
                    JE case1
                    CMP DL,10
                    JE case2
                    CMP DL,11
                    JE case3
                    case1:
                    MOV CL,n1
                    ADD CL,4 ; ----4
                    find_column CL,j1
                    find_line CL,i1
                    check_state_cell i1,j1  
                    ; if it's white we can do the move
                    JMP end
                    case2:
                    MOV CL,n1
                    ADD CL,4 ;---4
                    find_column CL,j1
                    find_line CL,i1
                    check_state_cell i1,j1  
                    ; if it's white we can do the move
                    ; if it's black we check the other way   
                    case3:  ; CASE 3 & 2 
                    INC CL
                    find_column CL,j1
                    find_line CL,i1 
                    check_state_cell i1,j1
                    ; if it's white we can do the move
                    JMP end
        white_turn3:
            impair:
                MOV DL,n1
                SUB DL,n2
                CMP DL,4 ; the first case of the direct move
                JE next      
                CMP DL,5 ; 2nd case
                JNE indirect        
                next:       
                CALL check_state_cell i,j
                ; if else (white black..)------ for a direct move it requires to be free to make the move 
                ; if it's black we jump to the end (cant move) 
                ; if it's white we test it in the indirect move
                
                indirect: 
                    CMP DL,9
                    JE next2
                    CMP DL,10
                    JE next2
                    CMP DL,11
                    JE next2
                    JNE end ; cant do the move
                    next2:
                        CALL check_state_cell x,y
                        ; it requires to be free to make the move &.. else jump end
                        
                        CMP DL,9
                        JE case1
                        CMP DL,10
                        JE case2
                        CMP DL,11
                        JE case3
                        case1:
                        MOV CL,n1
                        SUB CL,4 ; ----4
                        find_column CL,j1
                        find_line CL,i1
                        check_state_cell i1,j1  
                        ; if it's white we can do the move
                        JMP end
                        case2:
                        MOV CL,n1
                        SUB CL,4 ;---4
                        find_column CL,j1
                        find_line CL,i1
                        check_state_cell i1,j1  
                        ; if it's white we can do the move
                        ; if it's black we check the other way   
                        case3:  ; CASE 3 & 2 
                        DEC CL
                        find_column CL,j1
                        find_line CL,i1 
                        check_state_cell i1,j1
                        ; if it's white we can do the move
                    
            
    end:
ENDM 

START:
    MOV AX, @DATA
    MOV DS, AX

    find_column 24,result; calling 
 
    

CODE ENDS
END START





