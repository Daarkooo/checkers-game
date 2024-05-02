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
        pusha
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
        popa
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
 
getCellState MACRO board, i, j, result,number
	LOCAL white_cell, end_label
	pusha                           ; LOCAL LABELS
		MOV DL, i
		MOV DH, j
		getNumber DL, DH, result        ;h)macro qui retourne l'etat de la case 0 vide blanche ou noir
		mov al,result
		TEST al, al
		JZ white_cell
		
		XOR ah, ah
		mov number,al
		MOV SI, ax
		MOV AL, board[SI-1]        
		MOV result, AL
		JMP end_label
			
	white_cell:
	    MOV result, 0
	    mov number,0
	
	end_label:
	popa 
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
scan_char macro 
    mov ah,01h
    int 21h
endm

print_board MACRO board
	LOCAL outer_loop, inner_loop1, inner_loop2,row_end
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


pre_deplacement macro i,j,x,y,dep_possible,turn   ;j)macro qui verifie si le deplacement est possible de i,j a x,y    ;indice 0..9;possible 1 oui 0 non;direct 1 indirect 2 ;droite 1 gauche 0
    
LOCAL pion_blanc,deplacement_impossible,deplacement_possible,fin,deplacement_indirect,cologne_gauche2,cologne_droite2,deplacement_direct,blancc,noiree,commun           
pusha
cmp x,0                     ;verifier si la destination est coerente ou non 
jl deplacement_impossible
cmp x,9                
jg deplacement_impossible                                           ;)by rayanch
cmp y,0
jl deplacement_impossible
cmp y,9
jg deplacement_impossible

getCellState board,x,y,result,number1
cmp result,'0'                           ;verifier si la case d'arriver est vide et existe bien
jne deplacement_impossible 
          
mov al,i
mov bl,j    
cmp turn,'w'                   ;selection de pion noire ou blanc
je pion_blanc

inc al                        ;prochaine ligne en incremenatant car pion noire               
cmp x,al                    ;verifier si on est dans un cas de deplacement direct ou indirect
jne deplacement_indirect

deplacement_direct:       ;deplacement direct
mov number2,0             ;sauvegarde du choix direct    
jmp deplacement_possible

deplacement_indirect:                ;deplacement indirect
mov ch,'w'             ;pour verifier en cas de deplacement indirect pour les pion noires

commun:           ;code en commun pour les pion noire et blanc                                       ;sauvegarde du choix indirect        
cmp bl,y
jg cologne_gauche2             ;selection de cologne
inc bl               ;acces a la cologne rechercher y            
jmp cologne_droite2          
cologne_gauche2:
dec bl
cologne_droite2:

getCellState board,al,bl,result,number2
cmp result,ch                        ;verifier si la case d'avant est occuper par un pion approprie pour le deplacement
jne deplacement_impossible                                                                     
jmp deplacement_possible

pion_blanc:                ;party pour les pion blanc same as black diference de parametrage           
dec al                              ;prochaine ligne               
cmp x,al
je deplacement_direct          ;selection de deplacement direct ou indirect
mov ch,'b'
jmp commun:
 
deplacement_possible:
print_string possible
print_string newLine db 13,10,'$'
mov dep_possible,1               ;affichage et affectation des resultat
jmp fin
deplacement_impossible:   
print_string impossible 
print_string newLine db 13,10,'$'
mov dep_possible,0
mov number1,0
mov number2,0         
fin:
popa    
endm    



deplacement macro x,y,turn,tableau,board              ;k)macro qui effectue le deplacement
pusha    
LOCAL etiquette,droite,gauche,impossible,blacke,whitee,fin,finn,continue,deplacement_gauche,not_long,blackee,whiteee,debut                   ;)by rayanch

getNumber x,y,number1
mov al,number1
cmp al,tableau[1]
je droite
cmp al,tableau[3]
jne impossible
mov si,3
jmp gauche
droite:
mov si,1
gauche:
mov bl,tableau[0] 
mov board[bx-1],'0'
mov bl,tableau[si]
mov cl,turn
mov board[bx-1],cl
cmp tableau[si+1],0
je fin
mov bl,tableau[si+1]
mov board[bx-1],'0'

impossible:
fin:

popa
endm



show_path_pion macro i,j,tableau,turn
 pusha
 
Local deplacement_impossible1,direct,white,black,loopp,suite1
cmp j,0
jl deplacement_impossible1
cmp j,9
jg deplacement_impossible1
cmp i,0                          ;verifier si la case de depart est coerente ou non 
jl deplacement_impossible1
cmp i,9                
jg deplacement_impossible1

getCellState board,i,j,result,number1
mov al,turn                        ;verifier si la case de depart est bien un pion du joueur en jeux 
cmp al,result                                         
jne deplacement_impossible1

mov al,number1 
mov sauvegarde[0],al

mov dh,3
direct:

cmp dh,1
je deplacement_impossible1
mov dl,0
mov si,1
mov al,i
mov bl,j
dec dh
mov cx,2

cmp turn,'w'
je white
add al,dh
jmp black
white:
sub al,dh
black:

add bl,dh
mov tmp1,al

loopp:
mov tmp2,bl
pre_deplacement i,j,tmp1,tmp2,dep_possible,turn
cmp dep_possible,0
je suite1
 inc dl
 suite1:
mov bh,number1 
mov sauvegarde[si],bh
mov bh,number2
mov sauvegarde[si+1],bh
add si,2
sub bl,dh
sub bl,dh
loop loopp

cmp dl,0
je direct

deplacement_impossible1:
mov al,sauvegarde[0]

mov bl, sauvegarde[1]

mov cl, sauvegarde[2]

mov dl, sauvegarde[3]

mov ah, sauvegarde[4]

popa
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
 tmp1 db ?
 tmp2 db ?
 dep_possible db ?
 dep_possible2 db ?  
 turn db ?
 direct db ?     ;1 direct 2 indirect
 droite db ?     ;1 droite 0 gauche
 reussie db " deplacement reussie$"
 echouer db " deplacement echouer$"
 long db ?       ;1 long move 0 none
 chaine db "choisie entre la gauche et la droite d pour droite g pour gauche$"
 number1 db 0 ;cas indirect c'est la case destination
 number2 db 0 ; cas indirect c'est la case intermediaire
 sauvegarde db 5 dup(0)
.code

 mov ax,@data
 mov ds,ax
 mov ax,0
        
  board_init board
  mov board[26],'b'
  mov board[10],'0'
  mov board[12],'0'
  print_board board
  mov turn,'w'
  ;deplacement i,j,x,y,turn,droite,direct
  show_path_pion i,j,sauvegarde,turn
  deplacement x,y,turn,sauvegarde,board 
  print_board board
 
 



    