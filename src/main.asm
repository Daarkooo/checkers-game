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
    pawn_position DB ?
    isDirect DB ?
    path1 DB ?
    path2 DB ? 
    state DB ?
    turn DB ?
    val1 DB ?
    val2 DB ? 
    main DB ?
    newline DB 10,13,"$"
    verified DB ?
    board DB 50 dup(?) 
    bool DB 0 ; need it in showpaths 
    num DB ?  
    msg_result DB "result: $"
;DATA ENDS

;CODE SEGMENT
.code  
;ASSUME CS:CODE, DS:DATA

;------------get_clumn----------------
get_column MACRO n,result
    LOCAL not_eqaul_zero, not_less_than_6, end

    MOV AL, n
    XOR AH, AH 
    MOV BL, 10
    DIV BL    ; divide AL by BL, q -> AL, r -> AH

    ; check if x == 0
    CMP AH, 0
    JNE not_eqaul_zero
    MOV AL, 8 ; return 8
    JMP end
not_eqaul_zero:

    ; check if x < 6
    CMP AH, 6
    JGE not_less_than_6
    MOV AL, AH
    SHL AL, 1
    DEC AL ; retrun ah * 2 -1
    JMP end
not_less_than_6:

    ; x >= 6
    MOV AL, AH
    SUB AL, 5
    SHL AL, 1
    DEC AL
    DEC AL  ; return (ah-5)*2-1

end:
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
 

;------get_number----------------  
get_number MACRO row, column, main, Num
    LOCAL invalid, end, next
        ; (row % 2 === column % 2) 
        MOV AL,column 
        CMP AL,0
        JB invalid
        CMP AL,9
        JA invalid

        MOV AL,row ;[0002h]
        CMP AL,0
        JB invalid
        CMP AL,9
        JA invalid
        
        MOV AH,'y'
        CMP AH,main
        JNE next
            MOV NUM, 'v'; valid
            JMP end
        next:
        
        ; MOV AL,row ;[0002h]
        xor ah, ah
        mov cl, 2
        div cl
        mov bl, ah  ; Store (column % 2) in bl
        mov al, column
        xor ah, ah
        div cl
        cmp ah, bl  ; Compare (row % 2) with (column % 2)
        jz invalid  ; not a White Square
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
            jmp end
    invalid:
        ; White square || invalid row/column
        mov Num, 0
    end:
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
		get_number DL, DH, main, AL        ; Le macro de la question C (Fait par Abdou & Omar)
		
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
verify_move MACRO board, i, j, x, y, turn, verified, isDirect, val1, val2
    LOCAL impossible_move,done,indirect,second_case,case2,white_turn,black_turn,black_turn1,next,next1,impair,impair1,impair2,down,down1,down2,first_column,last_column,continue,continue1,end
    ;DL=i DH=j BH=x CH=y | i and j must be between 1-10 -> (0-9) 'we do the check in get_number & 'DEC 1' in the main'  

    get_number i, j, main, n1 
        CMP n1,0 ; 0 -> white cell 'invalid' (check get_number)
        JE impossible_move  ; checking if it's a valid input 
    get_cell_state board,i,j,state  
    
    MOV AL, state
    CMP AL, turn ; to make the move -> 'w'='w' / 'b'='b' else impossible_move
    JNE impossible_move  
    
    get_number x, y, main, n2 ; main <- null doesnt effect  
        CMP n2,0
        JE impossible_move ; checking if it's a valid input
    get_cell_state board, x, y, state        
        CMP state,'0' ; to make the move -> board[x,y] needs to be empty '0'
        JNE impossible_move 
    
    MOV AL, i ; i<-DL
    XOR AH, AH  ; I'LL USE AH for (impair/pair) (odd/even) line
    MOV BL, 2 ; TEST BL,01h
    DIV BL ;  divide AL by BL, q -> AL, r -> AH  

    MOV BH,n1
    MOV val1,BH ; need it in move function (to avoid the get_number call)
    MOV BH,n2 ; need it in indirect for checking 1st,2nd,8th,last (9/11)<-(n1-n2)
    MOV val2,BH ; need it in move function (to avoid the get_number call)

    MOV DL,n2 ; neg when it's white's turn
    SUB DL,n1 ; DL <- n2-n1
    CMP turn,'b' ; CH <- turn 
    JE black_turn
        NEG DL ; absolute value----WHITE's TURN---------------------
    black_turn: 
    
    ;----------show_paths (optimization)---------
    CMP isDirect,'n' ; isDirect <- Al
    JE indirect
    
    ;--------------DIRECT_MOVE----------------------------------------
    CMP DL,5 ; the first case of the direct move
    JE done 

    CMP AH, 0 ; we check if it's odd or even (the remainder of 'AL div 2' -> AH )   
    JNE impair 
        CMP turn,'b'
        JE second_case
            ADD DL,2  ; CMP DL,4  if true dl =4 -> (4+2 = 6) ----WHITE's TURN------
        JMP second_case 
    impair: 
        CMP turn,'w'
        JE second_case
            ADD DL,2  ; CMP DL,4  if true dl =4 -> (4+2 = 6) ----BLACK's TURN------

    second_case:
        CMP DL,6 ; the second case of the direct move -----impair-----
        JE done 
        JMP impossible_move

    indirect: ;------------INDIRECT_MOVE------------------------------- 
        cmp state,'0' ; to make the move -> board[x,y] needs to be empty '0'
        JNE impossible_move ; DL contains SUB n1,n2 / n2,n1 
        CMP DL,9  ; check if DL (n1-n2) = 9/11 else impossible
        JE next1
        CMP DL,11
        JNE impossible_move
        next1:

        MOV CL,n1
        CMP CL,BH ; CMP n1,n2
        JB down2 
            MOV CL,BH ; n1>n2 =>------going up-------- NEED IT TO AVOID SUB/DEC
        down2: 
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

        get_column CL, j1 ; for both impair & pair
        get_row CL, i1 ; I used i&j cuz there's no longer a need for the initial i&j
        MOV DL, i1
        MOV DH, j1
        get_number DL ,DH , main, isDirect ; isDirect return makla number (for optimization) 'indirect move'
        get_cell_state board, DL, DH, state ; depends on the colors (white -> black/ black ->white)
        CMP state,'0' ; one step (not for dames)
        JE impossible_move 
        MOV AL,turn 
        CMP AL,state ; to make the move -> state needs to be the color of the opposing player (enemy) 
        JNE done ; make the move
                    
    impossible_move:
        MOV verified,0 
        JMP end
    done:
        MOV verified,1   
    end:
ENDM 


;------move_pawn---------- 
move_pawn MACRO board,i,j,x,y,turn,path1,path2,pawn_position,isDirect
    LOCAL end, indirect, move, move1, no_move
    MOV DL,i
    MOV DH,j
    MOV BH,x ; cant use the other registers cuz are used in get_number 
    MOV CH,y
    

   ; MOV AH,0
   ; INT 16h

    get_number BH,CH,main,num
    MOV BH,num
    CMP BH,path1
    JNE next
        MOV BH,path1 ; BH <- board[x,y]
        JE move1
    next:
    CMP BH,path2 ; BH <- board[x,y]
    JNE no_move
        move1:
        XOR AX, AX   
        MOV AL, pawn_position
        DEC AL   
        MOV DI, AX    
        MOV AL, BH ; BH <- board[x,y]
        DEC AL   
        MOV SI, AX     
        
        CMP isDirect,1
        JNE indirect 
            MOV AL,board[DI] 
            MOV board[DI],'0'
            MOV board[SI],AL                    
            JMP move
        indirect:
            MOV AL,board[DI]
            MOV board[DI],'0'
            MOV board[SI],AL 
            
            MOV AL, isDirect 
            DEC AL  
            MOV DI, AX    
            MOV AL,board[DI]
            MOV board[DI],'0'
    move:
    ;    move_gui 
        JMP end
    no_move:
        MOV AL,-1
        MOV turn,AL
    end:
ENDM


;------show_paths----------
show_paths MACRO board,i1,j1,turn1,path1,path2,pawn_position,isDirect
    LOCAL end, next, next1, not_verified, not_verified1, not_verified2, not_verified3, down, down1 
   
    MOV DL,i1
    MOV DH,j1
    mov i,DL  ;i<-dl
    mov j,DH  ;j<-dh

    MOV x,DL ; BH<-x
    MOV y,DH ; CH<-y 
    MOV BH,x
    MOV CH,y         
    MOV AH,turn1 
    MOV turn,AH   
    
    MOV AL,-1 ;
    MOV path1,AL
    MOV path2,AL ; in case there's no move
    
    ;---------INDIRECT---------------- we prioritize the indirect move  
    CMP turn,'b'
    JE down
        SUB BH,2  ;------WHITE's TURN------- x<-(i-2)
        JMP next
    down: ;------BLACK's TURN-------
        ADD BH,2 ; x<-(i+2)
    next:
    MOV x,BH
    
    MOV AL,'n' ; not direct 
    MOV isDirect,AL
    ADD CH,2 ; CH<-(y+2) 
    MOV y,CH
    ;verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y]      
         
    CMP verified,0
    JE not_verified  
        MOV bool,1
        MOV AH,n2
        MOV path1,AH
    not_verified:

    MOV CH,j
    SUB CH,2 ; CH<-(y-2) 
    MOV y,CH
    ;verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y] 
    
    CMP verified,0
    JE not_verified1 
        MOV bool,1
        MOV AH,n2
        MOV path2,AH
    not_verified1:

    CMP bool,1
    JE end ; if there's a move in indirect, isDirect'll return maklaNum -> isDirect != 'n'
    
    ;---------DIRECT----------------
    MOV BH,i
    MOV CH,j

    CMP turn,'b'
    JE down1
        DEC BH ;------WHITE's TURN------- x<-(i-1)
        JMP next1
    down1: ;------BLACK's TURN-------
        INC BH ; x<-(i+1)
    next1:
    MOV x,BH

    MOV AL,'y' ; direct direct
    MOV isDirect,AL 
    INC CH ; CH<-(j+1)  
    MOV y,CH

    verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y] 

    CMP verified,0
    JE not_verified2  
        MOV AH,n2
        MOV path1,AH
    not_verified2:
 
    MOV CH,j
    DEC CH ; CH<-(j-1) 
    MOV y,CH 
    
    verify_move board,i,j,x,y,turn,verified,isDirect,pawn_position,n2 ; n1[i,j] n2[x,y] 

    CMP verified,0
    JE not_verified3 
        MOV AH,n2 
        MOV path2,AH
    not_verified3:  

    end:
    ; return pawn_position 
ENDM


START:
    MOV AX, @DATA
    MOV DS, AX 
    board_init board 
    
    MOV board[26],'w'
    show_paths board,5,2,'w',path1,path2,pawn_position,isDirect   ;16 
    
    ;----BLACK TEST-------------------
    ;move_pawn board,3,2,4,1,'b',turn,verified,isDirect,n1,n2 ; direct     ; 17->21
    ;move_pawn board,3,2,4,3,'b',turn,verified,isDirect,n1,n2 ; other way  ; 17->22
    ;----indirect----    
    ;mov board[21],'w'; 22<-'w'
    ;move_pawn board,3,4,5,2,'b',turn,verified,isDirect,n1,n2 ;18->27       
    ;mov board[22],'w'; 23<-'w'
    ;move_pawn board,3,4,5,6,'b',turn,verified,isDirect,n1,n2 ;18->29   
  
    
        
    ;----WHITE TEST------------------
    ;move_pawn board,6,1,5,0,'w',turn,verified,isDirect,n1,n2 ; direct     ; 31->26
    ;move_pawn board,6,1,5,2,'w',turn,verified,isDirect,n1,n2 ; other way  ; 31->27


    ;----indirect----      
    ;mov board[27],'b'; 28<-'b'
    ;move_pawn board,6,5,4,3,'w',turn,verified,isDirect,n1,n2 ;33->22       
    ;mov board[28],'b'; 29<-'b'
    ;move_pawn board,6,5,4,7,'w',turn,verified,isDirect,n1,n2 ;33->24      
    ;get_number 3,0,'n',n1

     
    ;MOV al,1
    ;mov path1,1
    
    ;print_board board 
    ;get_number 9,8,'y',n1

;CODE ENDS
END START

