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

;---getCellState--------------  
getCellState MACRO board, i, j, result
	LOCAL white_cell, end_label     ; LOCAL LABELS
		MOV DL, i
		MOV DH, j
		getNumber DL, DH, AL        ; Le macro de la question C (Fait par Abdou & Omar)
		
		TEST AL, AL
		JZ white_cell
		
		XOR AH, AH
		MOV SI, AX
		MOV AL, board[SI - 1]        
		MOV result, AL
		JMP end_label
			
	white_cell:
	    MOV result, 0
	
	end_label: 
ENDM   
;----------verify_move----------------   
verify_move MACRO i,j,x,y,turn  
    ; in place of turn I can compare between i & x (i < x -> Black's turn...) "only pawns"
    ; check the color dame[i,j]
    getNumber i,j,n1 
    getNumber x,y,n2
    ; check if it's a valid input
    ; else jmp end
    MOV DH,turn 
    
    MOV AL, i
    XOR AH, AH   
    MOV BL, 2 ; TEST BL,01h
    DIV BL ;  divide AL by BL, q -> AL, r -> AH  
    ; I'LL USE AH for (impair/pair) (odd/even) line
                      
    CMP DH,'w' 
    JE white_turn
        MOV DL,n2   
        SUB DL,n1 ;---BLACK's TURN------
        JMP next 
    white_turn:  ;---WHITE's TURN------
        MOV DL,n1   
        SUB DL,n2
    next:
    
    CMP AH, 0
    JNE impair
    CMP DL,5 ; the first case of the direct move -----pair-----------------
    JE direct  
    CMP DL,6 ; 2nd case
    JNE indirect        
    impair:
        CMP DL,4 ; the first case of the direct move
        JE direc t    
        CMP DL,5 ; 2nd case
        JNE indirect 
    direct:       
      check_state_cell x,y ; FUN H
      getCellState x,y,result
        JMP end
    indirect: 
        check_state_cell x,y ; need to be free 
        CMP DL,9
        JE case1 ; 
        CMP DL,11
        JE case2 
        JNE end ; cant do the move
            ; it requires to be free to make the move &.. else jump end
            case1:
            MOV CL,n1

            CMP DL,'w'
            JE white_turn1
            ADD CL,4 ;---BLACK's TURN------
            JMP next1
            white_turn1:
            SUB CL,4 ;---WHITE's TURN------
            next1:

            CMP AH, 0
            JNE impair ; --in odd lines, no need for inc and dec
            CMP DL,'w'
            JE white_turn2
            INC CL ;---BLACK's TURN------
            JMP next2
            white_turn2:
            DEC CL ;---WHITE's TURN------
            next2:
            impair:
            find_column CL,j1
            find_line CL,i1
            check_state_cell i1,j1  
            ; depends on the colors (white -> black/ black ->white)
            JMP end
            
            case2: ; ---the other way----- 
            MOV CL,n1

            CMP DL,'w'
            JE white_turn4 
            ADD CL,5 ;---BLACK's TURN------
            JMP next4
            white_turn4:
            SUB CL,5 ;---WHITE's TURN------
            next4:
            JNE impair
                
            CMP DL,'w'
            JE white_turn5
            INC CL ; 
            JMP next5
            white_turn5:
            DEC CL
            next5:

            impair:
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





