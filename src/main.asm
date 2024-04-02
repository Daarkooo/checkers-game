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


.model small
;-------------assembly--------------
;DATA SEGMENT 
.data
    n1 db ?
    n2 db ?   
    i DB ?
    j DB ? 
    i1 DB ?
    j1 DB ?
    x DB ?
    y DB ?
    isDirect DB ?
    result1 DB ?  
    result2 DB ? 
    result3 DB ? 
    result4 DB ? 
    state DB ?
    turn DB ?
    newline DB 10,13,"$"
    verified DB ?
    board DB 50 dup(?)  
    num DB ?  
    msg_result DB "result: $"
;DATA ENDS

;CODE SEGMENT
.code  
ASSUME CS:CODE, DS:DATA


;------------get_clumn----------------
get_column MACRO n,result
    LOCAL not_eqaul_zero, not_less_than_6

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
 
 
;--------get_row----------
get_row MACRO Num, result
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
 

;------getNumber----------------  
getNumber MACRO row, column, Num
    LOCAL calculate_number, fin

        ; (row % 2 === column % 2)
        mov al, row ;[0002h]
        xor ah, ah
        mov cl, 2
        div cl
        mov bl, ah  ; Store (column % 2) in bl
        mov al, column
        xor ah, ah
        div cl
        cmp ah, bl  ; Compare (row % 2) with (column % 2)
        jnz calculate_number  ; not a White Square
    
        ; White square
        mov Num, 0
        jmp fin
    
    calculate_number:
    
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
  
  
;-----board_init_board---------- 
board_init MACRO board
	LOCAL L1, L2, L3
	LEA SI, board
		
	MOV CX, 20
	L1:
		MOV BYTE PTR [SI], 'b'
		INC SI
	LOOP L1
	
	MOV CX, 10
	L2:
		MOV BYTE PTR [SI], '0'
		INC SI
	LOOP L2

	MOV CX, 20
	L3:
		MOV BYTE PTR [SI], 'w'
		INC SI
	LOOP L3
ENDM 

;----print_char---------
print_char MACRO asciiCode
	MOV AH, 02h
	MOV DL, asciiCode
	INT 21h
ENDM
 
 
;----print_string-------    
print_string MACRO reference
	MOV AH, 09h
	LEA DX, reference
	INT 21h
ENDM
 
;---print_board-------- 
print_board MACRO board
	LOCAL outer_loop, inner_loop1, inner_loop2
		MOV CX, 10
		XOR SI, SI
	
	outer_loop:
		PUSH CX
		TEST CX, 01h                ; get first bit to know whether it's parity
		MOV CX, 5
		MOV AH, 02h
		
		JZ inner_loop2
		
		inner_loop1:
			print_char board[SI]
			INC SI
			
			print_char ' '
			
			print_char 2EH
			
			print_char ' '          ; space
		LOOP inner_loop1
		
		JMP row_end
		
		inner_loop2:
			print_char 2EH
			
			print_char ' '          ; space
			
			print_char board[SI]
			INC SI
			
			print_char ' '
		LOOP inner_loop2
		
		row_end:
		print_string newLine        ; new line

		POP CX
	LOOP outer_loop
ENDM
   
   
;----CellState----------
get_cell_state MACRO board,i,j,result
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
verify_move MACRO board,i,j,x,y,turn,verified,isDirect,val1,val2
    LOCAL impossible_move,done,direct,indirect,case2,white_turn,next,next1,next2,next3,impair,impair1,impair2,down,down1,first_column,last_column,continue
    ; for pawns only
    ; in place of 'turn' I can compare between i & x (i < x -> Black's turn...) "only pawns"
    ; i and j must be between 1-10 -> (0-9) 'we do the check & 'DEC 1' in the main' 
    MOV DL,i
    MOV DH,j
    getNumber DL,DH,n1
    ;get_cell_state board,DL,DH,state
    ;cmp state,turn ; to make the move -> 'w'='w' / 'b'='b' else impossible_move
    ;JNE impossible_move

    MOV DL,x ; for optimization
    MOV DH,y
    getNumber DL,DH,n2
    get_cell_state board,DL,DH,state
      
    CMP n1,0 ; 0 -> white cell 'invalid' (check getNumber)
    JE impossible_move   ; checking if it's a valid input 
    CMP n2,0
    JE impossible_move  
    
    MOV DH,turn  
    MOV AL, i
    XOR AH, AH   
    MOV BL, 2 ; TEST BL,01h
    DIV BL ;  divide AL by BL, q -> AL, r -> AH  
    ; I'LL USE AH for (impair/pair) (odd/even) line

    MOV BH,n1
    MOV val1,BH ; need it in move function (to avoid the getNumber call)
    MOV BH,n2 ; need it in indirect for checking 1st,2nd,8th,last (9/11)<-(n1-n2)
    MOV val2,BH ; need it in move function (to avoid the getNumber call)
    MOV BH,1
    MOV isDirect,BH ; to check if it's direct/indirect move

    MOV CH, j ; to check if it's the first/last column + 2nd and 8th column for indirect move                
    CMP DH,'w' ; DH <- turn 
    JE white_turn
        MOV DL,n2 ;---BLACK's TURN--------------------------------
        SUB DL,n1 ; n2-n1 for pawn (cuz board[i,j] < board[x,y]) "no dame"
        
        CMP AH, 0 ; we check if it's odd or even (the remainder of 'AL div 2' -> AH )   --2nd version: TEST AH,0  JNZ impair
        JNE impair
            CMP DL,5 ; the first case of the direct move -----pair------
            JE direct  
            CMP CH,9
            JE last_column
                CMP DL,6 ; 2nd case
                JE direct 
            last_column:
            JMP indirect        
        impair:
            CMP CH,0
            JE first_column
                CMP DL,4 ; the first case of the direct move -----impair-----
                JE direct 
            first_column:  
            CMP DL,5 ; 2nd case
            JE direct  
            JMP indirect
    white_turn:  ;----WHITE's TURN---------------------------------
        MOV DL,n1 
        SUB DL,n2 ; n1-n2 for pawn (cuz board[i,j] > board[x,y])
        MOV n1,BH ; for optimization
        CMP AH, 0 ; we check if it's odd or even (the remainder of 'AL div 2' -> AH )   --2nd version: TEST AH,0  JNZ impair
        JNE impair1
            CMP DL,5 ; the first case of the direct move -----pair------
            JE direct  
            CMP CH,9
            JE last_column1
                CMP DL,4 ; 2nd case
                JE direct 
            last_column1:
            JMP indirect        
        impair1:
            CMP CH,0
            JE first_column1
                CMP DL,6 ; the first case of the direct move -----impair-----
                JE direct 
            first_column1:  
            CMP DL,5 ; 2nd case
            JE direct  
            JMP indirect
    ; DL contains SUB n1,n2 / n2,n1

    direct: 
        cmp state,'0' ; to make the move -> board[x,y] the state needs to be '0' (empty)  
        JE done 
        JMP impossible_move

    indirect:  ; DL contains SUB n1,n2 / n2,n1
        cmp state,'0' ; to make the move -> board[x,y] needs to be empty '0'
        JNE impossible_move 

        MOV CL,n1 ; n1 -> board[i,j]
        CMP DL,9  ; check if DL (n1-n2) = 9/11 else impossible
        JE next1
        CMP DL,11
        JNE impossible_move
        next1:
            
        CMP CH,0 ; 1st column
        JE next2
            CMP CH,1 ; 2nd column
            JNE continue
        next2:
            CMP CL,BH ; CMP n1,n2
            JB down
                CMP DL,11 ; n1>n2 =>------going up--------
                JE impossible_move ; 1st/2nd column case, cant move 
            down: ; n1<n2 => -------going down---------
                CMP DL,9
                JE impossible_move ; 1st/2nd column case, cant move 
        CMP CH,8 ; 9th column
        JE next3
            CMP CH,9 ; last column
            JNE continue
        next3:
            CMP CL,BH ; CMP n1,n2
            JB down1
                CMP DL,9 ; n1>n2 =>------going up--------
                JE impossible_move ; last/9th column case, cant move 
            down1: ; n1<n2 => -------going down---------
                CMP DL,11 
                JE impossible_move ; 1st/2nd column case, cant move 
        continue:

        CMP DL,11
        JE case2 
        ;---------case 1------------------
            ADD CL,4 ; now am using the lower value  (works for both white & black) 'only for indirect part'
            JMP next
        case2: ; ---the other way----- 
            ADD CL,5 ;---BLACK's TURN------ ADD n1,5
        next:

        CMP AH, 0 ; we check if it's odd or even (the remainder of 'AL div 2' -> AH )
        JNE impair2 ; for odd lines, no need to inc and dec
            INC CL ; INC n1 (now am using the lower value  (works for both white & black) 'only for indirect part')
        impair2:

        get_column CL,j1 ; for both impair & pair
        get_row CL,i1 ; I used i&j cuz there's no longer a need for the initial i&j
        MOV DL,i1
        MOV DH,j1
        getNumber DL,DH,isDirect ; isDirect return makla number (for optimization) 'indirect move'
        get_cell_state board,DL,DH,state ; depends on the colors (white -> black/ black ->white)
        CMP state,'0' ; one step (not for dames)
        JE impossible_move 
        CMP state,turn ; to make the move -> state needs to be the color of the opposing player (enemy) 
        JNE done ; make the move
                    
    impossible_move:
        MOV verified,0 
        JMP end
    done:
        MOV verified,1   
    end:
ENDM 


;------move----------
move_pawn MACRO board,i,j,x,y,turn
    LOCAL end, indirect
    MOV DL,i
    MOV DH,j
    MOV BH,x
    MOV CH,y
    ;MOV CH,turn
    verify_move board,DL,DH,BH,CH,turn,verified,isDirect,n1,n2 ; n1[i,j] n2[x,y] , in the indirect case isDirect <- numMakla
    
    CMP verified,0
    JE end   
        XOR AX, AX   
        MOV AL, n1 
        DEC AL   
        MOV DI, AX    
        MOV AL, n2
        DEC AL   
        MOV SI, AX     
        
        CMP isDirect,1
        JNE indirect 
            MOV AL,board[DI] 
            MOV board[DI],'0'
            MOV board[SI],AL                    
            JMP end
        indirect:
            MOV AL,board[DI]
            MOV board[DI],'0'
            MOV board[SI],AL 
            
            MOV AL, isDirect 
            DEC AL  
            MOV DI, AX    
            MOV AL,board[DI]
            MOV board[DI],'0'
    end:
ENDM


START:
    MOV AX, @DATA
    MOV DS, AX 
    board_init board
    ;get_column 25,result1 ; calling
    ;getNumber 3,2,result2   
    ;getNumber 4,1,result3  
    ;get_row 40,result3                      
    ;get_cell_state board,4,1,result4                      
    ;MOV board[29],'b'   
    mov board[20],'w'
    ;mov board[
    ;verify_move board,3,0,5,2,'b',verified 
    move_pawn board,3,0,5,2,'b' 
    print_board board 
 
    

;CODE ENDS
END START

