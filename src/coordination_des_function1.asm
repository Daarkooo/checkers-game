find_ligne MACRO n, result
    LOCAL errorLabel, endLabel
    XOR AX, AX
    
    MOV AL, n          ;a) macro qui retourne la ligne 0..9 (rahim)
    CMP AL, 50
    JA errorLabel
    cmp al,1
    jl errorLabel
    DEC AL
    MOV BL, 5
    DIV BL
    JMP endLabel
    
    errorLabel:
        MOV AL, -1    
    
    endLabel:
        MOV result, AL        
ENDM 

find_column MACRO n,result
    LOCAL not_eqaul_zero, not_less_than_6

    MOV AL, n
    XOR AH, AH            ;b) macro qui retourne la cologne 0..9 (hichem)
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


getNumber MACRO i,j, n        ;c)macro qui retourne le num N ,0 si case blanche (abdou)
    LOCAL calculate_number, fin       ;0..9

        ; (row % 2 === column % 2)
        mov al, j
        xor ah, ah
        mov cl, 2
        div cl
        mov bl, ah  ; Store (column % 2) in bl
        mov al, i
        xor ah, ah
        div cl
        cmp ah, bl  ; Compare (row % 2) with (column % 2)
        jnz calculate_number  ; not a White Square
    
        ; White square
        mov n, 0
        jmp fin
    
    calculate_number:
    
        ; Calculate the number
        mov al,i
        mov bl, 5
        mul bl  ; AL = row * 5
        mov bl,j
        shr bl, 1  ; Divide column by 2 
        add al, bl  ; AL = AL + (column / 2)
        inc al  ;the index starts from 0
    
        ; Store the number
        mov n, al
    
    fin: 
    ENDM

;e) on utilisera une structure de tableau de 50 case representant uniquement les cases noire et leur etat
    ;0 -> vide  'b'->pion noire   'w'->pion blanc

;le code -> board db 50 dup(?) 

board_init MACRO board                ;f)macro qui initialise le damier figure1 (rahim)
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
CaseColor MACRO i,j                    ;0...9
    LOCAL BlackCase, fin

        ; (row % 2 === column % 2)
        mov al,j
        xor ah, ah
        mov cl, 2
        div cl
        mov bl, ah  ; Store (column % 2) in bl
        mov al,i
        xor ah, ah
        div cl
        cmp ah, bl  ; Compare (row % 2) with (column % 2)
        jnz BlackCase  ; not a White Square
    
        ; White square
        lea dx,white
        mov ah,09
        int 21h
        jmp fin
    
    BlackCase:
         
        lea dx,black
        mov ah,09
        int 21h
    
    fin: 
    ENDM
 
getCellState MACRO board, i, j, result
	LOCAL white_cell, end_label     ; LOCAL LABELS
		MOV DL, i
		MOV DH, j
		getNumber DL, DH, al        ;h)macro qui retourne l'etat de la case 0 vide blanche ou noir
		
		TEST al, al
		JZ white_cell
		
		XOR ah, ah
		MOV SI, ax
		MOV AL, board[SI-1]        
		MOV result, AL
		JMP end_label
			
	white_cell:
	    MOV result, 0
	
	end_label: 
ENDM


print_char MACRO asciiCode
	MOV AH, 02h
	MOV DL, asciiCode
	INT 21h
ENDM

    
print_string MACRO reference
	MOV AH, 09h
	LEA DX, reference
	INT 21h
ENDM


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
			
			print_char '-'
			
			print_char ' '          ; space
		LOOP inner_loop1
		
		JMP row_end
		
		inner_loop2:
			print_char '-'
			
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

pre_deplacement macro i,j,x,y           ;indice 0..9 
    
LOCAL pion_blanc,deplacement_impossible,deplacement_possible,deplacement_indirect,cologne_gauche,cologne_droite,cologne_gauche2,cologne_droite2,fin,deplacement_direct,blancc,noiree           

cmp x,0              ;verifier si la destination est coerente ou non 
jl deplacement_impossible
cmp x,9                
jg deplacement_impossible
cmp y,0
jl deplacement_impossible
cmp y,9
jg deplacement_impossible

cmp j,0
jl deplacement_impossible
cmp j,9
jg deplacement_impossible
cmp i,0              ;verifier si la case de depart est coerente ou non 
jl deplacement_impossible
cmp i,9                
jg deplacement_impossible

getCellState board,x,y,result
cmp result,0
je deplacement_impossible
cmp result,'0'                      ;verifier si la case est vide ou contient un pion blanc ou noir
jne deplacement_impossible 

getCellState board,i,j,result
mov al,i
mov bl,j    
cmp result,0
je deplacement_impossible
cmp result,'0'                      ;verifier si la case est vide ou contient un pion blanc ou noir
je deplacement_impossible    
cmp result,'w'    
je pion_blanc

;pion noire
mov ch,'w'        
cmp al,x                           ;verifier si la destination est coerente ou non 2.0 une seule direction de deplacement
jge deplacement_impossible         
inc al                        ;prochaine ligne               
cmp x,al
jne deplacement_indirect

deplacement_direct:                  ;deplacement direct
cmp bl,y
jg cologne_gauche
inc bl
jmp cologne_droite                             
cologne_gauche:
dec bl
cologne_droite: 
cmp bl,y                        ;verifier si c'est bien l'indice de la cologne rechercher
jne deplacement_impossible
jmp deplacement_possible

deplacement_indirect:
inc al
commun:                         ;2 ligne en dessous
cmp al,x
jne deplacement_impossible      ;pas de deplacement indirect
cmp bl,y
jg cologne_gauche2
add bl,2                           
cmp bl,y
jne deplacement_impossible
dec bl   
jmp cologne_droite2          
cologne_gauche2:
sub bl,2
cmp bl,y
jne deplacement_impossible
inc bl
cologne_droite2:
cmp al,i
jl blancc
dec al
jmp noiree
blancc:
inc al
noiree:
getCellState board,al,bl,result
cmp result,ch                        ;verifier si la case d'avant est occuper par un piont blanc
jne deplacement_impossible
jmp deplacement_possible

pion_blanc:
mov ch,'b'    
cmp al,x                        ;verifier si la destination est coerente ou non 2.0 une seule direction de deplacement
jle deplacement_impossible        
dec al                              ;prochaine ligne               
cmp x,al
je deplacement_direct                                    ;deplacement direct
dec al
jmp commun:
 
deplacement_possible:
print_string possible 
jmp fin
deplacement_impossible:    
print_string impossible        
fin:    
endm    

.model small
.data

 result db ?
 n db ?
 board db 50 dup(?)
  
 black db " black$"
 
 white db " white$" 
 
 possible db " deplacement possible$"
 impossible db " deplacement impossible$"
 
 newLine db 13,10,'$'
 i db 6
 j db 1
 x db 4
 y db 3 
   
 
.code

 mov ax,@data
 mov ds,ax
 mov ax,0
        
 
 

 ;mov Bl,46
 ;find_ligne BL,result
 ;find_column bl,result
 ;getNumber 3,2,result
  board_init board
  mov board[26],'b'
 ;CaseColor 4,3
 ;getCellState board,3,8,result
  print_board board
  pre_deplacement i,j,x,y
 
 
 
 



    