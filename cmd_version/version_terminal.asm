find_ligne MACRO n, result
    pusha
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
     popa          
ENDM 

find_column MACRO n,result
     pusha
    LOCAL not_eqaul_zero, not_less_than_6,fin

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
    
       popa
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
    pusha
	MOV AH, 02h
	MOV DL, asciiCode
	INT 21h
	popa
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
    pusha
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
		mov dl,55
		mov ah,02h
        inc dh           
        int 10h
		;print_string newLine        ; new line

		POP CX
	LOOP outer_loop
	popa
ENDM

effacer macro
    pusha
    
    deplacement_index 7,0  
    print_string effac 
    
    deplacement_index 6,0  
    print_string effac  
    
    deplacement_index 5,0  
    print_string effac 
    
    deplacement_index 4,0  
    print_string effac 
    
    deplacement_index 3,0  
    print_string effac 
    
    deplacement_index 2,0  
    print_string effac
     
    popa
 endm

pre_deplacement macro i,j,x,y,dep_possible,turn,dame   ;j)macro qui verifie si le deplacement est possible de i,j a x,y    ;indice 0..9;possible 1 oui 0 non;direct 1 indirect 2 ;droite 1 gauche 0
    
LOCAL verification_dame,pion_blanc,deplacement_impossible,deplacement_possible,fin,deplacement_indirect,cologne_gauche2,cologne_droite2,deplacement_direct,blancc,noiree,commun,possibilite_garder_n1,fin2,possible_white_dame_pion,           
pusha
cmp x,0                     ;verifier si la destination est coerente ou non 
jl fin2
cmp x,9                
jg fin2                                           ;)by rayanch
cmp y,0
jl fin2
cmp y,9
jg fin2

mov al,x
mov bl,y

getCellState board,al,bl,result,number1
cmp result,'0'                           ;verifier si la case d'arriver est vide et existe bien
jne deplacement_impossible 
cmp dame,1
je deplacement_direct
          
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
mov cl,'d'
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
jne verification_dame
jmp deplacement_possible
verification_dame:
cmp result,cl
jne deplacement_impossible                                                                     
jmp deplacement_possible

pion_blanc:                ;party pour les pion blanc same as black diference de parametrage           
dec al                              ;prochaine ligne               
cmp x,al
je deplacement_direct          ;selection de deplacement direct ou indirect
mov ch,'b'
mov cl,'D'
jmp commun:
 
deplacement_possible:
mov dep_possible,1               ;affichage et affectation des resultat
jmp fin
deplacement_impossible:   
mov dep_possible,0
cmp dame,1
je possibilite_garder_n1

fin2:
mov number1,0
mov number2,0
mov dep_possible,0
jmp fin: 
 
possibilite_garder_n1:
cmp turn,'w'
je possible_white_dame_pion
cmp result,'D'
je fin2
cmp result,'b'
je fin2
jmp fin
possible_white_dame_pion: 
mov al,result            ;si ca marche on garde number1  sinon on sort avec un number1=0 number2=0
cmp result,'d'
je fin2
cmp result,'w'
je fin2
         
fin:
popa    
endm    


deplacement_pion macro x,y,turn,tableau,board              ;k)macro qui effectue le deplacement
pusha    
LOCAL etiquette,droite,gauche,impossible,blacke,whitee,fin,finn,continue,deplacement_gauche,not_long,blackee,whiteee,debut                   ;)by rayanch

mov dep,0

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

mov n1,bl
find_ligne n1,e
find_column n1,f

coolorie e,f,07h,'0'

mov bl,tableau[si]
mov cl,turn
mov board[bx-1],cl

mov n1,bl
find_ligne n1,e
find_column n1,f
  mov ligne,cl
coolorie e,f,07h,ligne

cmp tableau[si+1],0
je fin
mov bl,tableau[si+1]
mov board[bx-1],'0'
mov ligne,1

mov n1,bl
find_ligne n1,e
find_column n1,f

coolorie  e,f,07h,'0'

fin:
 mov dep,1

impossible:
 
popa
endm



show_path_pion macro i,j,tableau,turn
 pusha

 
Local deplacement_impossible1,direct,white,black,loopp,suite1,continuee,suuitee

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
pre_deplacement i,j,tmp1,tmp2,dep_possible,turn,dame
cmp dep_possible,0
je suite1
 inc dl
 mov pos_dep,1
 
 suite1:
mov bh,number1 
mov sauvegarde[si],bh
mov bh,number2
mov sauvegarde[si+1],bh

cmp number1,0
je continuee
coolorie  tmp1,tmp2,valuee1,0     ;2CH

cmp number2,0
je continuee

find_ligne number2,droite
find_column number2,long
coolorie  droite,long,valuee2,0               ;47H

continuee:

add si,2
sub bl,dh
sub bl,dh
loop loopp

cmp dl,0
je direct
 cmp dh,1
 je suuitee
 inc ligne
 suuitee:
 
deplacement_impossible1:

popa
endm 

 
show_path_dame macro i,j,tableau,turn 
 pusha
  
 Local suitee,suite,arret_diagonal,arret_diagonal3,arret_diagonal2,deplacement_impossible1,direct,white,black,loopp,suite1,pion_juste,possible_white_dame_pawn,diagonal_svt,diagonal_gauche_bas,diagonal_droite_haut,diagonal_gauche_haut,fin3,obstacle_blanc_noir
 
  
mov si,1
mov dh,1

diagonal_svt:
mov cx,9
mov al,i
mov bl,j 
mov dl,0

cmp dh,1
jne diagonal_gauche_bas
mov ah,1
mov bh,1
jmp loopp
diagonal_gauche_bas:

cmp dh,2
jne diagonal_droite_haut
mov ah,1
mov bh,-1
jmp loopp
diagonal_droite_haut:

cmp dh,3
jne diagonal_gauche_haut
mov ah,-1
mov bh,1
jmp loopp
diagonal_gauche_haut:

cmp dh,4
jne fin3
mov ah,-1
mov bh,-1

loopp:
add al,ah
add bl,bh
mov tmp1,al
mov tmp2,bl

 pre_deplacement i,j,tmp1,tmp2,dep_possible,turn,dame             ;diagonal droite en bas
 cmp dep_possible,1
 jne obstacle_blanc_noir
 mov ch,number1
 mov tableau[si],ch
 coolorie  tmp1,tmp2,valuee1,0
  mov pos_dep,1
 xor ch,ch
 jmp suite
 
 obstacle_blanc_noir:
 cmp number1,0 
 je arret_diagonal3
 cmp dl,0
 jne arret_diagonal2
 inc dl 
 mov tableau[si],'o'
 coolorie  tmp1,tmp2,valuee2,0
 inc si
 mov ch,number1
 mov tableau[si],ch
 xor ch,ch 
  suite:
 inc si
    
loop loopp

jmp arret_diagonal

  arret_diagonal3:
  cmp cx,9
  je arret_diagonal
  
  arret_diagonal2:

  cmp sauvegarde[si-2],'o'
  je arret_diagonal
  mov ligne,1

arret_diagonal:
cmp dl,0
jne suitee
inc si
suitee:     
inc dh
add si,cx
jmp diagonal_svt     

fin3:
popa
endm 
 
deplacement_dame macro x,y,tableau
 Local cas_spe,suite1,loopp,suite,position_trouver,same_diagonal,deplacement_impossible,cotiinue 
  
  pusha
  mov dep,0
  
  mov ligne,0
  getNumber x,y,number1
  mov al,number1
  mov cx,40
  mov si,1
  mov dh,1
  mov dl,1
  mov bx,0
  
  loopp:
  cmp sauvegarde[si],'o'
  jne suite
  mov bx,si
    
  suite:
  
  cmp sauvegarde[si],al
  je position_trouver
  cmp sauvegarde[si],0
  je contiinue
  cmp sauvegarde[si],'o' 
  je contiinue
    
  find_ligne sauvegarde[si],e
  find_column  sauvegarde[si],f
  coolorie  e,f,07h,0
  
   contiinue:
  
  inc si
  inc dh
  cmp dh,11
  jne same_diagonal
  mov dh,1
  add dl,10
  same_diagonal: 
  loop loopp
  
  jmp deplacement_impossible:
  
  
  position_trouver:
  
  find_ligne sauvegarde[si],e
  find_column  sauvegarde[si],f
  coolorie  e,f,07h,0
    
  push si
  push cx
  
  cmp bx,0
  je suite1
  
  cmp bl,dl
  jl suite1

   cmp sauvegarde[bx+1],al
   je cas_spe
  
  find_ligne sauvegarde[bx+1],e
  find_column  sauvegarde[bx+1],f
  coolorie  e,f,07h,'0'
  
   
  mov dl,sauvegarde[bx+1]
  mov bl,dl
  mov board[bx-1],'0'
  mov ligne,1
  
 
  suite1:
  
   cmp sauvegarde[si-1],'o'
   je cas_spe
   
 
   
   
  mov dl,sauvegarde[0]
  xor dh,dh
  mov si,dx
  xor ah,ah
  
  mov bx,ax
  mov ch,board[si-1]
  mov board[bx-1],ch
  
  
  find_ligne number1,e
  find_column  number1,f
  
  mov dep_possible2,ch
  
  coolorie  e,f,07h,dep_possible2
  
  coolorie i,j,07h,'0'
  
  mov board[si-1],'0'
  mov dep,1
  
  cas_spe:
  pop cx
  pop si
  inc si
  dec cx
   
  jmp loopp
  
  deplacement_impossible:
  
  
  
 popa
endm 
 
 show_path_global macro i,j,sauvegarde,turn,value1,value2
 pusha 
 Local deplacement_impossible1,loopp,suite1,possible_white_dame_pawn
 Local possible_black_pawn_deplacement,suite,possible_white_pawn_deplacement,possibilities_deplacement_for_dame
 mov ligne,0
 mov pos_dep,0
  
cmp j,0
jl deplacement_impossible1
cmp j,9
jg deplacement_impossible1
cmp i,0                         
jl deplacement_impossible1
cmp i,9                
jg deplacement_impossible1

getCellState board,i,j,result,number1
cmp turn,'w'
je possible_white_dame_pawn

cmp result,'D'
jne possible_black_pawn_deplacement
 mov dame,1              
 jmp suite
 
possible_black_pawn_deplacement:
cmp result,'b'
jne deplacement_impossible1
mov dame,0
jmp suite

possible_white_dame_pawn:
cmp result,'d'
jne possible_white_pawn_deplacement

mov dame,1
jmp suite
possible_white_pawn_deplacement:
cmp result,'w'
jne deplacement_impossible1
mov dame,0    

suite:
mov al,number1 
mov sauvegarde[0],al
cmp dame,1
je possibilities_deplacement_for_dame
 show_path_pion i,j,sauvegarde,turn
 jmp deplacement_impossible1
possibilities_deplacement_for_dame:
 show_path_dame i,j,sauvegarde,turn

deplacement_impossible1:
 
 
 
popa    
 endm
 
 
 
 
deplacement_index macro ligne,cologne  
 
 mov ah,02h   ;interuption de deplacement d'index
 mov bh,0     ;page
 mov dh,ligne     ;ligne
 mov dl,cologne     ;cologne
 int 10h 
 
endm


coolorie macro vall1,vall2,coul,vall3
 
 pusha
 Local coloriee,loooppp,suuui,suuuui
 
    mov al,vall1
    mov bl,vall2 
    
    add al,9
    cmp bl,0
    
    je coloriee                                    
        mov cl,vall2
        xor ch,ch
        mov bl,0
        
         loooppp:
        
          add bl,2 
        
         loop loooppp
        
    coloriee:
    
            add bl,55
            deplacement_index al,bl
            push cx
            mov cl,vall3
            cmp cl,0
            jne suuui
            mov ah,08H      ;lire caractere afficher
            int 10h       ;caracter dans le al ;attribut dans ah
            jmp suuuui
            
            suuui:
            mov al,vall3
            suuuui:
            pop cx
            mov ah,coul    ;changer attribut couleur fond bleu text yellow
            mov bl,ah
            mov cx,1
            mov ah,09h
            int 10h
 
 popa
endm

init_sauvegarde macro 
  
  LOCAL boucle,suite
 pusha
  
  mov cx,41
  mov si,0  
  mov dh,10
  
  boucle:   
  mov sauvegarde[si],0         ;manque optimization
  inc si  
  loop boucle:
    
 popa
    
 endm

selectioner_parametre macro  val,tmp3,tmp4
  Local fin,not_fleche_droite,entre_fleche_input,on_est_a_droite,suite3,suite2,suite1,droitee,not_fleche_gauche,init_j
  
 deplacement_index val,0
 
 
 print_string choix_index         ;affichage de la prise des parametres
 print_string choix_numero
 print_string newLine
 
 deplacement_index val,0
 
  print_char '>'          ;mettre en evidence le choix courant par default le prmier
                          ;'>' au debut du  choix courant
 
 deplacement_index val,39    ;se deplacer vere la zone de saisie du premier choix
   
 entre_fleche_input:
  
    mov ah,00h         ;attendre une entre 
    int 16h
    
      mov dh,0
      cmp ah,4Dh             ;voire si l'entre correspond au scaner de la fleche droite
      jne not_fleche_droite
  
      cmp dl,39              ;voire si on est a la zone de saisie du choix de gauche pour faire un deplacement droite
      jne not_fleche_droite
           
           
           deplacement_index val,0       ;se deplacer vers le debut du choix de gauche donc le choix actuelle
           
           print_char ' '          ;effacer le '>' de ce choix 
          
           deplacement_index val,43   ;se redeplacer vers le debut du choix de droite
           
                          ;et montrer que c'est le nouveau choix courant
           
           print_char '>'
           
           deplacement_index val,62      ;se deplacer a la zone de saisie du choix de droite
           
           jmp entre_fleche_input
   
     not_fleche_droite:          ;cas de choix de fleche gauche ou une entre de chifre
   
       cmp ah,4Bh
        jne not_fleche_gauche     ;cas de scane d'entree de fleche gauche
       cmp dl,39
        je not_fleche_gauche      ;verifier qu'on est bien sur le choix de droite pour pouvoire aller a droite
           
           
           deplacement_index val,43     ; se placer au debut du choix courant donc de droite
                        
           print_char ' '          ;effaccer le '>' du choix courant donc de droite
            
           
           deplacement_index val,0          ;se replacer au debut du nouveau choix courant donc de gauche
           
           print_char '>'          ;montrer que c'est le nouveau choix courant
           
           
           deplacement_index val,39           ;se placer sur la zone de saisie du choix courant gauche                    
           
           
           jmp entre_fleche_input
           
           suite2:
           mov ah,00h        ;attendre l'entre du 2 eme coordone soit le y soit le 2 nombre de n
           int 16h
           
   
     not_fleche_gauche:
   
           cmp al,30h
           jl suite1           ;verifie que l'entre  correspond bien a un caractere chifre                                   
           cmp al,39h
           jg suite1
           
               cmp dl,39                 ;voire si on est a la saisie d'un nombre n ou des coordone i,j 
               jne on_est_a_droite
           
                   cmp dh,1
                   je init_j          ;cas coordone i,j
                   
                       mov tmp3,al
                       print_char tmp3 
                       sub tmp3,30h        ;coordonne i
                       inc dh
                       jmp suite2
                   
                       init_j:
                       mov tmp4,al         ;coordonne j a la 2eme iterations
                       print_char tmp4
                       sub tmp4,30h        ;et on saute a la suite
   
                       push dx
                       deplacement_index val,0
                       
                       
                       print_char ' '
   
                    jmp fin
    
             on_est_a_droite:
                                 ;cas d'entre de nombre n
                   mov n,al
                   print_char n
                   
                   mov al,n         ;retouver le nombre entier et non le caractere
                   sub al,30h
                   
                   cmp dh,1
                   je suite3
                       mov bx,10
                       push dx          ;multiplication du 1er nombre par 10
                       mul bx
                       pop dx 
                       mov bl,al
                       inc dh
                       jmp suite2
   
                   suite3:
                       add bl,al       ;addition du 2 nombre entre au premier
                       mov n,bl
   
                       push dx
                       deplacement_index val,43
                                    ;effecer le '>' de debut car choix fait et valide
                      
                       print_char ' '
                       
                       find_ligne n, tmp3
                       find_column n,tmp4
                       
                   jmp fin                        ;et on saute a la suite
   
           suite1:
           
           deplacement_index val,dl    
                  
                          ;cas d'entre invalide on se repositionne au debut de la zone de saisie
           push dx  
                         ;se repositioner au debut de la zone de saisie selon le dl 
               
           print_char ' ' ;effacer le 1er chifre entre si existe
               
           pop dx
           cmp dl,39        ;verifie si l'entre invalide a lieu a la zone de gauche
           jne droitee
                               ;on repositione le curseur sur le debut de zone de saisie gauche
              deplacement_index val,39
              jmp entre_fleche_input
   
           droitee:
   
              deplacement_index val,62   ;on se repositionne sur le debut de zone de saisie droite
              
       
 loop entre_fleche_input


 fin:
endm


.model small
.data

 result db ?
 n db ?
 board db 50 dup('0')
  
 
 possible db " deplacement possible$"
 impossible db " deplacement impossible$"
 
 newLine db 13,10,'$'
 i db ?
 j db ?
 x db ?
 y db ? 
 tmp1 db ?
 tmp2 db ?
 dep_possible db ?
 dep_possible2 db ?  
 turn db ?
 direct db ?     ;1 direct 2 indirect
 droite db ?     ;1 droite 0 gauche
 reussie db ?
 echouer db " deplacement echouer$"
 long db ?       ;1 long move 0 none
 chaine db "choisie entre la gauche et la droite d pour droite g pour gauche$"
 number1 db 0 ;cas indirect c'est la case destination
 number2 db 0 ; cas indirect c'est la case intermediaire
 sauvegarde db 41 dup(0)
 dame db ?
 n1 db ?
 selection db 0
 e db ?
 f db ?
 ligne db ?
 black db " la case est noire$"
 white db "la case est blanche$"
 valuee1 db 2CH
 valuee2 db 47h
 dep  db ?
 pos_dep db ?
         
 touver_ligne db "  trouver la ligne $"
 trouver_cologne db "  trouver la cologne $" 
 touver_numero db "  trouver le numero $"
 trouver_couleur_case db "  trouver la couleur de la case $"
 trouver_etat_case db "  trouver l'etat de la case $"
 verifier_deplacemnt db "  verifier le depalcement $"
 retrouver_chemin_possible db "  retrouver les chemins de deplacement possible $"
 faire_deplacement db "  faire un deplacement $"
 choix_index db "  parametres ligne cologne de la case :    $"
 choix_numero db "  numero de la case : $"
 
 ligne_trouver db " la ligne correspondante i =$" 
 cologne_trouver db " la cologne correspondante j=$"
 numero_trouver db " le numero de case trouver n=$"
 couleur_trouver db " la couleur de case trouver :$" 
 etat_case db " l'etat de la case trouver:$ "
 effac db "                                                                     $"
 turn_message db "turn : $"
 
.code
 
 main proc
 
 mov ax,@data
 mov ds,ax
 mov ax,0
 
 board_init board
  mov board[17],'D'
 mov board[21],'w'
  mov board[37],'0'
 
 mov turn,'b' 
 deplacement_index 9,55
 print_board board
       
 main_loop:
 
 deplacement_index 2,54
 print_string turn_message
 print_char turn
 
 selectioner_parametre 0,i,j
 
 
   functions:
    
   coolorie i,j,1Eh,0
            
            deplacement_index 2,0
            
            pop dx                ;verifier si on a entrer le numero ou les coordonne de case
            cmp dl,39
    
            jne afficher_get_row_cologne
                                               ;afficher les fonction posssible en tant que telle
               print_string touver_numero
               print_string newLine  
               mov bl,0
               
             jmp afficher_get_number_only
               
            afficher_get_row_cologne:
 
                 print_string touver_ligne
                 print_string newLine
                 print_string trouver_cologne             ;affichage des choix possible
                 print_string newLine 
                  mov bl,1
                 afficher_get_number_only:
   
                 print_string trouver_couleur_case
                 print_string newLine
                 print_string trouver_etat_case
                 print_string newLine
                 print_string retrouver_chemin_possible
                 print_string newLine
                 print_string faire_deplacement
  
                push bx
  reboucle:
  
 pop bx
 
     deplacement_index 2,0
                             ;se repositionner sur le premier choix de fonctions
    
     print_char '>'                    ;montrer la fonctions courante

 functions_choice:
 
      mov ah,00h          ;attendre un input sois il monte en haut sois il descend sois il choisie la fonction
      int 16h
      
      cmp al,0Dh          ;si il tappe sur la touche enter la fonction est faite
      je choix_fait
      
      cmp ah,48h          ;verifier si il a taper sur la fleche de haut ou de bas sinon ou autre chose
      jne not_en_haut
                         ;si il tape sur la touche flech haut
       
      deplacement_index dh,0                  
   
                          ;on efface le '>' du choix actuelle
       print_char ' '
   
  cmp dh,02            ;cas basique on se dplace vers le choix d'en haut
  jne continue
  
      cmp bl,0          ;verifier si on a 6 choix ou 7 choix de functions
      je max_6
      
      mov dh,8
      jmp continue   ;max_7
  
      max_6:                     
      mov dh,7
      
      continue:
          dec dh          ;deplecement de ligne
          jmp suite4
          
  not_en_haut:
   
      cmp ah,50h            ;verifier si il a taper la fleche de bas
      jne functions_choice
      
       deplacement_index dh,0       ;on efface le '>' du choix actuelle
       
       print_char ' '
      
      cmp bl,0
      je  maxx_6          
                        ;verifier si on a 6 choix ou 7 choix de functions
      cmp dh,7
      jne continue2    ;choix basics
      
           mov dh,2   
           jmp suite4 ;max_7
       
       maxx_6:
           cmp dh,6
           jne continue2
           mov dh,2
                    
  jmp suite4
  
       continue2:
       inc dh
   
  suite4:
       
       deplacement_index dh,0
                               ;repositioner le curseur sur le choix actuelle
              print_char '>'
       
      xor cx,cx
      
 loop functions_choice
 
 choix_fait:         ;choix de fonctions fait
 
   deplacement_index dh,0
                     ;on efface le '>' du choix selectionne
  
   print_char ' '
  
 push bx 
            ;question de reglage de bug
 
 cmp bl,0
 
 je on_a_i_j
 
 cmp dh,2
 je trouv_ligne                        
 cmp dh,3                ;fonction a selectione si on a pris le nombre
 je trouv_cologne
 cmp dh,4
 je couleur_case
 cmp dh,5
 je etatt_case 
 cmp dh,6
 je route_possible
 cmp dh,7 
 je deplacem
 
 on_a_i_j:
 
 cmp dh,2
 je trouv_number   
 cmp dh,3
 je couleur_case
 cmp dh,4              ;fonction a selectione si on a pris les coordone i,j
 je etatt_case
  
 cmp dh,5
 je route_possible
 cmp dh,6 
 je deplacem 
  
 trouv_ligne:                ;fonction de retouver la ligne
 
      find_ligne n, result
      cmp result,0  
      jl main_loop            ;encore a traiter
      
      deplacement_index dh,20
      print_string ligne_trouver
       
      add result,30h
      print_char result
      
 jmp reboucle 
 
 trouv_cologne:                  ;fonction de retouver la cologne
     
       find_column n,result
       deplacement_index dh,25
    
       print_string cologne_trouver
     
       add result,30h
       print_char result
     
       jmp reboucle 
 
  
   couleur_case:   
                            ;fonction de retouver la couleur de la case selon i,j
     
             deplacement_index dh,35   
              CaseColor i,j
             
             jmp reboucle
         
   
    
 
 etatt_case:                 ;fonction de retouver l'etat  de la case selon i,j
      
      getCellState board, i, j, result,number1
      
       deplacement_index dh,35
     
     cmp result,0
     jne okk 
     
     print_string white
     jmp reboucle
        
     okk:
     print_string etat_case
    
     print_char result
    
     jmp reboucle
       
  trouv_number:                 ;fonction de retouver le numero
     
      
        getNumber i,j,n  
        cmp n,0
        jne case_black  
        deplacement_index dh,35
          
         print_string white
         jmp reboucle
         case_black:
        
         deplacement_index dh,35
          
         print_string numero_trouver
         add n,30h
         print_char n
         
  jmp reboucle    
    
 
 
  route_possible:
  
   show_path_global i,j,sauvegarde,turn
    
   
   
   
  
  
  jmp reboucle  
  
  
 deplacem:
 
   inc dh
   mov selection,dh
   mov cx,3

   
   ssssuite:
   
   push cx
   show_path_global i,j,sauvegarde,turn
   
   cmp pos_dep,0
   jne ssssuitee
   pop cx
   coolorie i,j,08h,0
   init_sauvegarde
    
   effacer
   jmp main_loop
   
    ssssuitee:
   
   selectioner_parametre selection,x,y
   
   cmp dame,1
   je dameeee
      
   deplacement_pion x,y,turn,sauvegarde,board
   
   cmp dep,0
   je ssssuitee
   
  
   cmp ligne,1
   jne finnn
   jmp piion
   
   dameeee:
   
    deplacement_dame x,y,sauvegarde
    
    cmp dep,0
    je ssssuitee
   
    
    cmp ligne,1
    jne  finnn
        
   piion:
   
   mov al,x
   mov i,al
   mov al,y
   mov j,al
    
    mov valuee1,08h
    mov valuee2,08h
    init_sauvegarde
    
    show_path_global i,j,sauvegarde,turn
    cmp ligne,1
    jne finnn
    pop cx
    mov valuee1,2ch
    mov valuee2,47h
    coolorie i,j,1Eh,0
    
    loop ssssuite
    jmp finnn
    
    finnnn:
    pop cx
    jmp reboucle
    
   finnn:
    coolorie i,j,08h,0
    mov valuee1,2ch
    mov valuee2,47h
    pop cx
    
    cmp turn,'b'
    je turn_white
    mov turn,'b'
    effacer
    jmp main_loop
    init_sauvegarde
    
    turn_white:
    mov turn,'w'
    init_sauvegarde
    effacer
    
   jmp main_loop