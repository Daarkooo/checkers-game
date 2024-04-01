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
    x DB ?
    y DB ?
    result1 DB ?  
    result2 DB ? 
    result3 DB ? 
    result4 DB ? 
    state DB ?
    turn DB ?
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
			
			print_char '0'
			
			print_char ' '          ; space
		LOOP inner_loop1
		
		JMP row_end
		
		inner_loop2:
			print_char '0'
			
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
verify_move MACRO board,i,j,x,y,turn,verified 
    LOCAL impossible_move,done,direct,indirect,case1,case2,white_turn,white_turn1,white_turn2,white_turn3,white_turn4,next,next1,next2,next3,next4,next5,impair,impair1,impair2,first_column,last_column
    ; for pawns only
    ; in place of 'turn' I can compare between i & x (i < x -> Black's turn...) "only pawns"
    ; i and j must be between 1-10 -> (0-9) 'we do the check & 'DEC 1' in the main' 
    MOV DL,i
    MOV DH,j
    getNumber DL,DH,n1
    get_cell_state board,DL,DH,state
    cmp state,turn ; to make the move -> 'w'='w' / 'b'='b' else impossible_move
    JNE impossible_move

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
                      
    CMP DH,'w' ; DH <- turn 
    JE white_turn
        MOV DL,n2 ;---BLACK's TURN------  
        SUB DL,n1 ; n2-n1 for pawn (cuz board[i,j] < board[x,y]) "no dame"
        JMP next 
    white_turn:  ;---WHITE's TURN------
        MOV DL,n1 
        SUB DL,n2 ; n1-n2 for pawn (cuz board[i,j] > board[x,y])
    next:
    ; DL contains SUB n1,n2 / n2,n1

    MOV CH, j ; to check if it's the first/last column
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

    direct: 
        cmp state,'0' ; to make the move -> board[x,y] the state needs to be '0' (empty)  
        JE done 
        JMP impossible_move

    indirect:  ; DL contains SUB n1,n2 / n2,n1
        cmp state,'0' ; to make the move -> board[x,y] needs to be empty '0'
        JNE impossible_move 

        MOV CL,n1 ; n1 -> board[i,j]
        CMP DL,9
        JE case1  
        CMP DL,11
        JE case2
        JMP impossible_move ; cant do the move
        
        case1:
            CMP DL,'w'
            JE white_turn1
                ADD CL,4 ;---BLACK's TURN------ ADD n1,4
                JMP next1
            white_turn1:
                SUB CL,4 ;---WHITE's TURN------ SUB n1,4
            JMP next1
        
        case2: ; ---the other way----- 
            CMP DL,'w'
            JE white_turn3 
                ADD CL,5 ;---BLACK's TURN------ ADD n1,5
                JMP next1
            white_turn3:
                SUB CL,5 ;---WHITE's TURN------ SUB n1,5
            next1:

        CMP AH, 0 ; we check if it's odd or even (the remainder of 'AL div 2' -> AH )
        JNE impair1 ; for odd lines, no need to inc and dec
            CMP DL,'w'
            JNE impair1
                INC CL ;---BLACK's TURN(pair)------ INC n1
                JMP impair2
            
        impair1:
            CMP DL,'w'
            JNE impair2
                DEC CL ;---WHITE's TURN(impair)------ DEC n1
            impair2:


        get_column CL,j ; for both impair & pair
        get_row CL,i ; I used i&j cuz there's no longer a need for the initial i&j
        MOV DL,i
        MOV DH,j
        get_cell_state board,DL,DH,state  
        ; depends on the colors (white -> black/ black ->white)
        CMP state,turn ; to make the move -> state needs to be the color of the opposing player (enemy) 
        JNE done ; make the move
                    
    impossible_move:
        MOV verified,0 
        JMP end
    done:
        MOV verified,1   
    end:
ENDM 

START:
    MOV AX, @DATA
    MOV DS, AX 
    board_init board
    ;get_column 25,result1 ; calling
    getNumber 5,8,result2   
    getNumber 4,9,result3  
    ;get_row 40,result3                      
    ;get_cell_state board,4,1,result4                      
    MOV board[29],'b'
    verify_move board,5,8,4,9,'b',verified 
    ;print_board board
 
    

;CODE ENDS
END START

