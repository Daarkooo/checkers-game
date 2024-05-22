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

 __printDecimal PROC
        PUSH BP
        MOV BP, SP

        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX

        MOV AX, [BP + 4]
        MOV CX, 10

        MOV BX, 0FFFFh
        PUSH BX

        printDecimal_L1:
            XOR DX, DX
            DIV CX
            PUSH DX
            TEST AX, AX
        JNZ printDecimal_L1

        POP DX

        printDecimal_L2:
            CMP DX, 0FFFFh
            JZ printDecimal_end

            ADD DL, '0'
            MOV AX, 0200h
            INT 21h

            POP DX
        JMP printDecimal_L2

        printDecimal_end:
        POP DX
        POP CX
        POP BX
        POP AX

        MOV SP, BP
        POP BP
        RET 2
    __printDecimal ENDP
 
printDecimal MACRO num
        
        PUSH AX

        MOV AX, num
        PUSH AX

        CALL __printDecimal
        
        POP AX
        
        
ENDM





find_column MACRO n,result
    
     pusha
    LOCAL errorLabel,not_eqaul_zero, not_less_than_6,fin

    MOV AL, n
    XOR AH, AH
    cmp al,0
    jle errorLabel
    
    cmp al,50
    jg errorLabel
                  ;b) macro qui retourne la cologne 0..9 (hichem)
    MOV BL, 10
    DIV BL      ; divide AL by BL, q -> AL, r -> AH

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
    
    jmp fin
    
    errorLabel:
    mov result,-1
    
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

 switch_dame macro x,y,turn,board
  pusha
  Local fin,white
    
    mov bool,0
     
    cmp turn,'w'
    je white
    
     cmp x,9
     jne fin
         
     getNumber x,y,n
     mov al,n
     xor ah,ah
     mov si,ax     
     mov board[si-1],'D'
     mov bool,1
          
    white:
    
     cmp x,0
     jne fin
     
     mov al,n
     xor ah,ah
     mov si,ax     
     mov board[si-1],'d'
     mov bool,1     
    
    
   fin:
   popa
   
  endm 
        



effacer macro                   ;macro utiliser quant le tour est terminer pour donner la main au joueur adversse
    pusha
    
      
    deplacement_index 9,0  
    print_string effac  
     
    deplacement_index 8,0  
    print_string effac  
    
    deplacement_index 7,0  
    print_string effac 
                             ;effacer toute les ligne des fonctions 
    deplacement_index 6,0       ;donnant le choix au joueur qui vient de finir son tour
    print_string effac  
    
    deplacement_index 5,0    ;pour le donner au joueur adversse
    print_string effac 
    
    deplacement_index 4,0  
    print_string effac 
    
    deplacement_index 3,0  
    print_string effac 
    
    deplacement_index 2,0  
    print_string effac
     
    popa
 endm



pre_deplacement macro i,j,x,y,dep_possible,turn,dame   ;j)macro qui verifie si le deplacement est possible de i,j a x,y    ;indice 0..9;possible 1 oui 0 non;
    
    LOCAL pion_blanc,deplacement_impossible,deplacement_possible,fin,deplacement_indirect,cologne_gauche2,cologne_droite2,deplacement_direct,blancc,noiree,commun,possibilite_garder_n1,fin2,possible_white_dame_pion,           
    
    pusha
    
    cmp x,0                     ;verifier si la destination est coerente ou non 
    jl fin2
    cmp x,9                
    jg fin2                                           ;)by rayanch
    cmp y,0
    jl fin2
    cmp y,9
    jg fin2

    mov al,x    ;pour ne pas changer les valeurs de x,y      
    mov bl,y

    getCellState board,al,bl,result,number1  ;result contiendra la valeur de la case    ;number1 contiendra le numero de case de la ligne al, cologne bl
    cmp result,'0'                           ;verifier si la case d'arriver est vide et existe bien
    jne deplacement_impossible
     
      cmp dame,1              ;verifie si la case de depart est une dame si oui alord on aura un deplacemnt possible directement             
      je deplacement_direct                
          
    mov al,i
    mov bl,j    
    cmp turn,'w'                   ;selection de pion noire ou blanc
    je pion_blanc
                       ;case de pion noire
                     
    inc al                        ;prochaine ligne en incremenatant car pion noire               
    cmp x,al                    ;verifier si on est dans un cas de deplacement direct ou indirect
    jne deplacement_indirect

    deplacement_direct:       ; si on est en deplacement direct  alord le deplacement est possile
    mov number2,0             ;on met le number2 a 0 car on a besois seulement du nombre de case de destination number1    
    jmp deplacement_possible

    deplacement_indirect:                ;deplacement indirect
    
    mov ch,'w'             ;a utiliser pour verifier en cas de deplacement indirect pour les pion noires
    mov cl,'d'             ;d represantant une dame blanche
    
    commun:             ;code en commun pour les pion noire et blanc                                       ;sauvegarde du choix indirect        
    
    cmp bl,y
    jg cologne_gauche2             ;selection de la cologne
    inc bl                                           
    jmp cologne_droite2          
    cologne_gauche2:
    dec bl
    cologne_droite2:

    getCellState board,al,bl,result,number2
    cmp result,ch                        ;verifier si la case obstacle (a manger) est occuper par un pion approprie pour le deplacement
                                         ;example si on a les noire alord ca doit etre un pion obsatcle blanc et vis vers ca
    je deplacement_possible     ;en cas de succes notre deplacement est possible
          
                   
               ;en cas d'echeque on verifie le cas de dame
    cmp result,cl
    jne deplacement_impossible   ;cette fois ci en cas d'echeque notre depl est impossible                                                                  
    jmp deplacement_possible

    pion_blanc:          ;party pour les blanc la meme chose que les noire mais avec des parametrages differents           
    
    dec al                              ;prochaine ligne               
    cmp x,al
    je deplacement_direct          ;selection de deplacement direct ou indirect
    
    mov ch,'b'               ;a utiliser pour verifier en cas de deplacement indirect pour les pion blanc
    mov cl,'D'               ;D represantant une dame noire
    jmp commun:      ;aller a la party de traitement en commun
    
                           
                             ;affectation des resultat
    deplacement_possible:
    mov dep_possible,1        ;cas de deplacement possible        
    jmp fin
    
    deplacement_impossible:   ;cas de deplacement_impossible
    mov dep_possible,0
        
    cmp dame,1                ;prendre en compte le cas de dame. la dame peut de deplacer sur toute la diagonal et donc on souhaiterai garder le number1 meme si le deplacement est impossible
    je possibilite_garder_n1
    
        
    fin2:
    mov number1,0        ;cas d'echeque total meme pour la dame on ne garde rien
    mov number2,0
    mov dep_possible,0
    jmp fin: 
     
    possibilite_garder_n1:          ;traitement pour la dame
     cmp turn,'w'
     je possible_white_dame_pion
        cmp result,'D'
        je fin2          ; en cas de dame noire on verifie si la case d'arriver est un pion\dame noire
        cmp result,'b'   ;si c'est le cas alord il n'y a pas de possibilte de le manger meme plus tard donc on revien a fin2
        je fin2          ;si ca marche on garde number1  sinon on sort avec un number1=0 number2=0
        jmp fin  
        
     possible_white_dame_pion: 
        mov al,result          ; en cas de dame blanche on verifie si la case d'arriver est un pion\dame blanc  
        cmp result,'d'        ;si c'est le cas alord il n'y a pas de possibilte de le manger meme plus tard donc on revien a fin2
        je fin2
        cmp result,'w'      ;si ca marche on garde number1  sinon on sort avec un number1=0 number2=0
        je fin2
         
fin:

popa
    
endm    


deplacement_pion macro x,y,turn,tableau,board               ;k)macro qui effectue le deplacement
    
  pusha    
  LOCAL suite,recolorie_de_1,etiquette,droite,gauche,impossible,blacke,whitee,fin,finn,continue,deplacement_gauche,not_long,blackee,whiteee,debut                   ;)by rayanch
    
  mov dep,0   ;pion toucher pion jouer (si il peut bouger alord il doit bouger)                  ;on suppose qu'on a toujour i,j avant de faire le deplacement don on rentre seulement le x,y

  getNumber x,y,number1     ;on obtient le numero de case de la destiations
 
    mov al,number1               ;les valeurs de deplacement etant deja stoker avant dans un vecteur il nous suffit de comparer avec les valeurs de ce vecteur
    
    cmp al,tableau[1]      ;la val d'indice 1 corespond a la cologne de droite
    je droite 

    cmp al,tableau[3]       ;la val d'indice 3 corespond a la cologne de gauche
    jne impossible          ;pas deplacement                       
    
    mov si,3            ;on garde l'indice de la case de destination
    jmp gauche   
    
    droite:
    mov si,1           ;on garde l'indice de la case de destination
    
    gauche:
                         ;on change les valeurs dans notre damier
    
    mov bl,tableau[0]      ;on recupere le numero de la case de depart 
    mov board[bx-1],'0'    ;et on lui affecte la valeur vide '0'

 

    coolorie i,j,07h,'0'     ;recolorie la case depart par la couleur par default

    mov bl,tableau[si]      ;on recupere le numero de case d'arriver
    mov cl,turn
    mov board[bx-1],cl      ;et on lui affecte la valeur de la cas depart



    mov ligne,cl             ;on recolorie avec la couleur par default + on affecte la valeur de depart
    coolorie x,y,07h,ligne

    cmp tableau[si+1],0    ;on verifie si on a pas manger de pion\dame sur le chemin
    je suite 
     
     
    mov bl,tableau[si+1]      ;si oui alord on recupere le numero de la case obstacle et on lui affectte la valeur vide '0'
    mov board[bx-1],'0'
    mov ligne,1
    
    mov n1,bl               ;on recupere les indice de ligne et colognes de la case obstacle
    find_ligne n1,e
    find_column n1,f

    coolorie  e,f,07h,'0'       ;on recolorie avec la couleur par default + on affecte la valeur vide
      
      suite:
      
    cmp si,3
    je recolorie_de_1
    
     cmp tableau[3],0
     je suite
     
     mov bl,tableau[3]
     mov n1,bl
     
     find_ligne n1,e
     find_column n1,f
     coolorie  e,f,07h,0 
     
     cmp tableau[4],0
     je fin
     
     find_ligne n1,e
     find_column n1,f
     coolorie  e,f,07h,0  
     
     jmp fin
     
    recolorie_de_1:
    
    cmp tableau[1],0
     je fin
      
     mov bl,tableau[1]
     mov n1,bl
     
     find_ligne n1,e
     find_column n1,f
     coolorie  e,f,07h,0 
     
     cmp tableau[2],0
     je fin
     
     find_ligne n1,e
     find_column n1,f
     coolorie  e,f,07h,0 
       
 fin:
 mov dep,1   ; on confirme qu'on a fait un deplacment

 impossible:
 
popa
endm



show_path_pion macro i,j,tableau,turn


 
 pusha
 
 Local deplacement_impossible1,direct,white,black,loopp,suite1,continuee,suuitee

  mov dh,3         ;nous permet de faire et de maniere dinamique le deplacement indirect et direct
  
  direct:

    cmp dh,1                    ;cas de deplacement indirect + direct traiter, alord on quitte
    je deplacement_impossible1
                           ;initialisation des valeurs de depart
        mov dl,0     ;permet de verrifier si il y'a possibilite de faire un deplacement indirect     
        mov si,1     ;l'indice dans le vecteur de stokage de chemin de deplacement possible
        mov al,i     ;affectationde la ligne de depart
        mov bl,j     ;affectation de la cologne de deprt
        dec dh       ;on fait sois un deplacement indirect sois direct a la 2eme boucle
        mov cx,2     ;on fait 2 boucle par type de deplacement

    cmp turn,'w'
    je white
                     ;faire le decalge de ligne en fonction du tour
    add al,dh
    jmp black
    
    white:
    sub al,dh
    
    black:
    
    
    add bl,dh      ;faire un decalage de cologne d'abord a droite ensuite a gauche a la 2eme boucle 
    mov tmp1,al    ;on fixe la valeur da ligne de destination

    loopp:
    
        mov tmp2,bl  ;on fixe la valeur da la cologne de destination
        
        pre_deplacement i,j,tmp1,tmp2,dep_possible,turn,dame   ;on veifie si le deplacement est possible
        
        cmp dep_possible,0   ;verfie si le deplacement est possible
        je continuee
        
             inc dl            ;si oui on stoke ces valeurs qui le montre
             mov pos_dep,1
             
             mov bh,number1          ;on affecte les valeurs de numero de case destination et obsatcle trouver
             mov sauvegarde[si],bh
             mov bh,number2
             mov sauvegarde[si+1],bh
                
             coolorie  tmp1,tmp2,valuee1,0  ;on colorie la case destination
             
             cmp number2,0
             je continuee
             
             find_ligne number2,droite
             find_column number2,long
             coolorie  droite,long,valuee2,0 
             
         
        
        continuee:
        
        add si,2          ;on passe au 2eme cote du vecteur represenant les cologne de gauche
        sub bl,dh         ;on decale au cologne de gauche
        sub bl,dh
    
    loop loopp

  cmp dl,0     ;on verifie si un depalcement indirect est possible si non on verifie le deplacement direct
  je direct
  
  cmp dh,1
  je suuitee     ; la ligne nous permet de savoire si un deplacement indirect est possible pour faire une succession de deplacement
     inc ligne
  suuitee:
     

 deplacement_impossible1:

 popa 

endm 



 
show_path_dame macro i,j,tableau,turn 
    
   pusha
  
   Local suitee,suite,arret_diagonal,arret_diagonal3,arret_diagonal2,deplacement_impossible1,direct,white,black,loopp,suite1,pion_juste,possible_white_dame_pawn,diagonal_svt,diagonal_gauche_bas,diagonal_droite_haut,diagonal_gauche_haut,fin3,obstacle_blanc_noir
 
  
    mov si,1       ;indice du vecteur de sotckge des chemin de deplacement possible commence a 1 
    mov dh,1       ;designe la 1ere diagonal
    
    diagonal_svt:
    
    mov cx,9       ;on a maximum 9 boucle pour chaque diagonal
    mov al,i       ;on affecte l'indice de ligne de depart
    mov bl,j       ;on affecte l'indice de cologne de depart
    mov dl,0       ;indicateur d'obstacle manger max=1 sur une seul cologne
    
    cmp dh,1                         ;selections de diagonal en fonction du dh
    jne diagonal_gauche_bas
    
    mov ah,1                        ;initialisation  de la valeur de decalage de la case depart ++ en fonction de chaque diagonal
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
    
        add al,ah        ;decalage des indice de depart
        add bl,bh
        mov tmp1,al     ;on les stoke dans tmp1 tmp2 pour ne pas perdre leur valeurs
        mov tmp2,bl
        
         pre_deplacement i,j,tmp1,tmp2,dep_possible,turn,dame     ;verifier si le deplacement est possible
         
         cmp dep_possible,1
         jne obstacle_blanc_noir     ;si le deplacement n'est pas possible on doit verifier si on pet manger le pion\dame de la case destination
         
         mov ch,number1          ; si le deplacement est possible on affectte le numero de la case dans le vecteur de sauvgarde de chemein de deplacement possible
         mov tableau[si],ch
         coolorie  tmp1,tmp2,valuee1,0   ;et on colorie la case en fonctions
         
         mov pos_dep,1     ;on part verifier les cases suivantes
         xor ch,ch
         jmp suite
         
         obstacle_blanc_noir:
         cmp number1,0        ;veus dire qu'on ne peut meme pas manger la case -> arret de diagonal
         je arret_diagonal3
         
         cmp dl,0              ;si on a deja stocker la valeur d'une case a manger on quitte la diagonal
         jne arret_diagonal2
         
         inc dl               ;sinon on stocke a l'indice si la valeur 'o' 
         mov tableau[si],'o'
        
         
         inc si
         mov ch,number1        ;et a l'indice si+1 le numero de case obstacle
         mov tableau[si],ch
         xor ch,ch
         coolorie  tmp1,tmp2,valuee2,0  ;on colorie la case 
          
          suite:
         inc si   ;on verifie pour la case de la diagonal suivante
        
    loop loopp  
    
    

  jmp arret_diagonal
    
      arret_diagonal3:
      cmp cx,9            ;cas ou en s'arrette a la premiere iteration (obsatcle non mangable 1ere iteration)
      je arret_diagonal
      
      
      arret_diagonal2:
    
      cmp sauvegarde[si-2],'o' ;cas ou en a 2 obstacle l'un apres l'autre on ne peut pas manger
      je arret_diagonal
      
      mov ligne,1     ;indique qu'on peut manger un obstacle
      

  arret_diagonal:
    
        cmp dl,0
        jne suitee
        
        inc si   ;si on a pas manger on increment le si
        
        suitee:     
        inc dh   ;diagonal suivante
        
        add si,cx  ;decalage vers le debut d la digonal suivante dans le vecteur de stockage de chemin de deplacement possible
        
        jmp diagonal_svt     
    
  fin3:
  
 popa

endm 


 
deplacement_dame macro x,y,tableau
 
 Local cas_spe,suite1,loopp,suite,position_trouver,same_diagonal,deplacement_impossible,cotiinue 
  
  pusha
  
  mov dep,0
  
  mov ligne,0
  
  getNumber x,y,number1 ;on recupere le numero de case destiantion
                     
              ;initialisation des paarmetres
                     
  mov al,number1
  mov cx,40   ;nombre de boucle maximal
  mov si,1    ;indice de la premiere case dans le vecteur de stokage de chemin de deplacement possible
  mov dh,1    ;s'incremente avec le si et permet et revien a 1 en changeant de diagonal
  mov dl,1    ;indice debut de chaque digonal
  mov bx,0    ;indice stokant la position de l'obstacle
  
  loopp:  
  
      cmp sauvegarde[si],'o'
      jne suite              
      
      mov bx,si        ;on sauvegarde l'indice de la case obstacle
      suite:
      
      cmp sauvegarde[si],al
      je position_trouver      ;position de la case destination trouver
      
      cmp sauvegarde[si],0
      je contiinue           
                                  ;si ce n'est pas une case valide on ne recolorie pas
      cmp sauvegarde[si],'o' 
      je contiinue
        
        find_ligne sauvegarde[si],e     ;si on retrouve un numero de case valide apparetenant au vecteur on le recolorie avec la avleu par default
        find_column  sauvegarde[si],f
        coolorie  e,f,07h,0
      
       contiinue:
      
      inc si
      inc dh
      cmp dh,11
      jne same_diagonal
      
      diagonal_svt:
      mov dh,1
      add dl,10
      mov bx,0
          
      same_diagonal:
       
 loop loopp
      
      jmp deplacement_impossible:    ;en cas de fin du parcour de diagonal sans reussite on quitte
      
      
      position_trouver:              ;cas de position de destination retrouver
      
          find_ligne sauvegarde[si],e      ;on recupere les indices de ligne de cologne
          find_column  sauvegarde[si],f
          coolorie  e,f,07h,0           ;onrecolorie avec les couleur par default
            
       push si       ;on stocke ces valeurs pour revenir a la boucle precedente etfinir tous le parcour dans le but de tous reclorier avec les couleurs de base
       push cx
      
       cmp bx,0
       je suite1       ;cas ou en a pas d'obstale a traiter
      
   
       cmp sauvegarde[bx+1],al  ;si on a un obstacle il faut verifier que la destination n'est pas l'obstacle en question
       je cas_spe
      
          find_ligne sauvegarde[bx+1],e      ;on recupere les indices ligne et colognes de l'obstacle 
          find_column  sauvegarde[bx+1],f
          coolorie  e,f,07h,'0'          ;on le recolorie avec la couleur pas defaul + reecris avec le mot vide '0'
          
       
          mov dl,sauvegarde[bx+1]    ;si toute les condition reunnie, on modifie la valeur de la case obstacle par la case vide '0'
          mov bl,dl
          mov board[bx-1],'0'
          mov ligne,1         ;montre qu'on a manger un obstacle
          
     
      suite1:
      
          mov dl,sauvegarde[0]
          xor dh,dh
          mov si,dx
          xor ah,ah              ;on modifie la valeur de la case d'arriver par celle du depart
          
          mov bx,ax
          mov ch,board[si-1]
          mov board[bx-1],ch
          
      
      
      mov dep_possible2,ch
      
      coolorie  x,y,07h,dep_possible2    ;colorie la case d'arriver + reeciriture avec la valeur de depart
      
      coolorie i,j,07h,'0'  ;recolorie la case de depart + reecriture avec la case vide '0'
      
      mov board[si-1],'0' ;affectation de la case vide dans notre damier
      mov dep,1    ;montrer que a etais deplacement fait
      
      cas_spe:
      pop cx
      pop si
      inc si
      dec cx      ;revien a la boucle pour recolorie ce qui n'a pas etais recolorie
       
  jmp loopp
  
  deplacement_impossible:
  
  
  
 popa
endm 
 
 show_path_global macro i,j,sauvegarde,turn,value1,value2
    
     pusha
      
     Local deplacement_impossible1,loopp,suite1,possible_white_dame_pawn
     Local possible_black_pawn_deplacement,suite,possible_white_pawn_deplacement,possibilities_deplacement_for_dame 
     
     mov ligne,0     ;set pour savoire si on a la possibilite de manger
     mov pos_dep,0   ;set pour savoire si on a la possibilite de bouger
  
        
        getCellState board,i,j,result,number1     ;recuperer la valeur de la case source
        cmp turn,'w'
        je possible_white_dame_pawn
        
        cmp result,'D'
        jne possible_black_pawn_deplacement
         mov dame,1              
         jmp suite                                 ;retrouver dans quelle cas on se situe en coordiantion avec le tour
                                                   ;et affecter la valeur de dame en consequence case dame =1
         
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
        
        mov al,number1         ;affecter le numero de case a la premiere case du vecteur de stokage des chemins de deplacement possible
        mov sauvegarde[0],al
        
        cmp dame,1
        je possibilities_deplacement_for_dame
        
         show_path_pion i,j,sauvegarde,turn        ;choisir la verification de chemin en consequence du parametre dame
         
         jmp deplacement_impossible1
         
        possibilities_deplacement_for_dame:
        
         show_path_dame i,j,sauvegarde,turn
        
 deplacement_impossible1:
         
 
 
   popa
       
 endm
 
 
 
 
deplacement_index macro ligne,cologne        ;fonction qui deplace l'index dans le terminal
 
     mov ah,02h   ;interuption de deplacement d'index
     mov bh,0     ;page
     mov dh,ligne     ;ligne
     mov dl,cologne     ;cologne
     int 10h 
 
endm


coolorie macro vall1,vall2,coul,vall3       ;fonction qui colorie l'intersecetion d'une ligne cologne du terminal avec la val coul,val3 distingue si on reecris ou non le caractere
 
 pusha
 Local coloriee,loooppp,suuui,suuuui
 
    mov al,vall1
    mov bl,vall2 
    
    add al,13    ;decale vers la  ligne du damier sur le terminal  (9 debut du damier)
    cmp bl,0
    
    je coloriee
                                        
        mov cl,vall2
        xor ch,ch        ;on retrouve la cologne correspondante sur le terminal
        mov bl,0
        
         loooppp:
        
          add bl,2 
        
         loop loooppp
        
    coloriee:  
    
            add bl,55  ;decaler sur la cologne du terminal,55 etans la cologne de debut du damier
            deplacement_index al,bl     ;on retrouve l'index corespondant
            
            push cx
            
            mov cl,vall3
            cmp cl,0
            jne suuui    ;si vall3 =0 on reecris le meme caractere affiche sur le terminal
            
            
            mov ah,08H      ;lire caractere afficher
            int 10h       ;caracter dans le al ;attribut dans ah
            jmp suuuui
            
            suuui:
            mov al,vall3  ;al etatn le caractere a afficher
            
            suuuui:
            pop cx
            mov ah,coul    ;(changer attribut couleur fond bleu text yellow)
            mov bl,ah
            mov cx,1       ; bl contien parametre couleur
            mov ah,09h
            int 10h
 
 popa
 
endm

init_sauvegarde macro     ;fonction qui initialse le vecteur de sauvegarde
  
  LOCAL boucle,suite
  pusha
  
      mov cx,41
      mov si,0  
      mov dh,10
      
      boucle:
         
      mov sauvegarde[si],0          
      inc si
        
      loop boucle:
        
 popa
    
 endm



selectioner_parametre macro  val,tmp3,tmp4   ;fonction qui donne la main a l'utilisateur pour rentrer ces parametres
    
    
  Local fin,not_fleche_droite,entre_fleche_input,on_est_a_droite,suite3,suite2,suite1,droitee,not_fleche_gauche,init_j
 
 
  
 deplacement_index val,0 ;on deplace l'index a la ligne val et cologne 0
 
 
 print_string choix_index         ;affichage de la prise des parametres
 print_string choix_numero
 print_string newLine
 
 deplacement_index val,0  ;on redeplace au debut de la meme ligne
 
  print_char '>'          ;mettre en evidence le choix courant par default le premier
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
 n2 dw ?
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
 bool db ?
         
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
 select_again db "  change parametres  $"
 
 
.code
 
 main proc
 
 mov ax,@data
 mov ds,ax
 mov ax,0
 
    board_init board      ;initilaiser le damier
 
  mov board[17],'D'
  mov board[21],'w'
  mov board[37],'0'
 
     mov turn,'b'
  
    deplacement_index 13,55    ;deplacer l'index sur le terminal a la ligne 9 cologne 55
   
   
    print_board board         ;afficher le damier   
 
       
 main_loop:
 
 deplacement_index 2,54      ;deplacer l'index sur le terminal a la ligne 2 cologne 54
 
 print_string turn_message  ;afficher le tour
 print_char turn
 
 
 selectioner_parametre 0,i,j  ;appelle a la fonction de selection de parametre  a la ligne 0, les resultats sont retourne dans le i,j
 
 
   functions:
    
   coolorie i,j,1Eh,0   ;colorier la case represenatnt le i,j dans le damier
            
            deplacement_index 2,0   ;deplacer l'index a ligne 2 cologne 0
            
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
                 print_string select_again
                 print_string newLine 
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
  
      cmp bl,0          ;verifier si on a 7 choix ou 8 choix de functions
      je max_6
      
      mov dh,9
      jmp continue   ;max_7
  
      max_6:                     
      mov dh,8
      
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
      cmp dh,8
      jne continue2    ;choix basics
      
           mov dh,2   
           jmp suite4 ;max_7
       
       maxx_6:
           cmp dh,7
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
     je changer_parametre
     
     cmp dh,5
     je couleur_case
     cmp dh,6
     je etatt_case 
     cmp dh,7
     je route_possible
     cmp dh,8 
     je deplacem
     
 on_a_i_j:
 
     cmp dh,2
     je trouv_number
     
     cmp dh,3
     je changer_parametre
        
     cmp dh,4
     je couleur_case 
     
     cmp dh,5              ;fonction a selectione si on a pris les coordone i,j
     je etatt_case
      
     cmp dh,5
     je route_possible 
     
     cmp dh,6 
     je deplacem 
  
 trouv_ligne:                ;fonction de retouver la ligne
 
      find_ligne n, result
      cmp result,0  
      jl reboucle            ;encore a traiter
      
      deplacement_index dh,20
      print_string ligne_trouver
       
      add result,30h
      print_char result
      
 jmp reboucle 
 
 trouv_cologne:                  ;fonction de retouver la cologne
     
       find_column n,result
       cmp result,0
       jl reboucle
       
       deplacement_index dh,25
    
       print_string cologne_trouver
     
       add result,30h
       print_char result
     
       jmp reboucle 
 
  
   couleur_case:
      
          cmp i,0                   ;fonction de retouver la couleur de la case selon i,j
          jl reboucle
          
              deplacement_index dh,35   
              CaseColor i,j
             
     jmp reboucle
         
   
    
 
 etatt_case:                 ;fonction de retouver l'etat  de la case selon i,j
       cmp i,0
       jl reboucle
       
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
     
      
        getNumber i,j,n       ;test
        
        cmp number2,0
        jne case_black  
        deplacement_index dh,35
          
         print_string white
         jmp reboucle
         
         case_black:
        
         deplacement_index dh,35 
         print_string numero_trouver
         push bx
         xor bx,bx
         mov bl,n
         mov n2,bx
         pop bx
         
         printDecimal n2  
         
         
         
  jmp reboucle    
    
 changer_parametre:
 
      mov valuee1,07h   ;on rend la couleur par default
      mov valuee2,07h
            
        init_sauvegarde   ;on initialse le vecteur de sauvegrade
            
            
        show_path_global i,j,sauvegarde,turn  ;on verifie les chemins de la nouvelle positions
            
     mov valuee1,2ch
     mov valuee2,47h      ;reafecte les couleur de base
     
 
       coolorie i,j,07h,0       ;cas ou ne peut pas se deplacer on recolorie avec la couleur par default
       init_sauvegarde          ;on initilase le veteur de sauvegrade 
            
       effacer  ;et on efface les possibilite de fonction
      
   jmp main_loop  ;on lui redonne la main a nouveau     
 
    
    
    
 route_possible:           ;fonctions pour montrer les chemin possible
  
     show_path_global i,j,sauvegarde,turn
    
   
  
  jmp reboucle  
  
  
 deplacem:   ;fonction pour faire le deplacement
  
  
  
   inc dh        ;ligne suivante
   mov selection,dh
   mov cx,3    ;nombre deplacement 

   
    mouvement:
   
           push cx
           
               show_path_global i,j,sauvegarde,turn      ;affceter tous les chemin possible a sauvegarde
           
           cmp pos_dep,0
           jne on_peut_se_deplacer
           
           pop cx
                                                       
               coolorie i,j,07h,0       ;cas ou ne peut pas se deplacer on recolorie avec la couleur par default
               init_sauvegarde          ;on initilase le veteur de sauvegrade 
            
               effacer  ;et on efface les possibilite de fonction
           
                                          
           jmp main_loop  ;on lui redonne la main a nouveau
           
          on_peut_se_deplacer:    ;cas ou on peut se deplacer
                      
                      
                selectioner_parametre selection,x,y   ;on lui donne la main sur les coordonne de destination a rentrer
           
           cmp dame,1        ;on verifie si on est dans le cas dame ou non
           je dameeee
              
                deplacement_pion x,y,turn,sauvegarde,board      ;cas de pion on deplace le pion
           
           cmp dep,0                  ;on verifie si un deplacement a bien u lieu
           je on_peut_se_deplacer    ;si non on lui redonne la main pour rejouer
           
               switch_dame x,y,turn,bord
               cmp bool,1
               je
            
           cmp ligne,1 ;on verifie si on a manger un pion
           jne finnn   
           jmp piion   
           
           dameeee:
                                                  ;deplacement de la dame
            deplacement_dame x,y,sauvegarde
            
            cmp dep,0
            je on_peut_se_deplacer
           
            
            cmp ligne,1
            jne  finnn
                
           piion:  ;si on a manger avec le pion
           
           mov al,x   ;on initialise le nouveau i,j
           mov i,al
           mov al,y
           mov j,al
            
            mov valuee1,07h   ;on rend la couleur par default
            mov valuee2,07h
            
              init_sauvegarde   ;on initialse le vecteur de sauvegrade
            
            
              show_path_global i,j,sauvegarde,turn  ;on verifie les chemins de la nouvelle positions
            
            cmp ligne,1       ;on verifie si on peut manger a partir de la nouvelle position
            jne finnn  ;si non on quitte
            
            pop cx 
            
            mov valuee1,2ch  ;affecter les valeur de coloriage abbituelle
            mov valuee2,47h
            
            coolorie i,j,1Eh,0  ;colorie le i,j
    
    loop mouvement   ;et on refais la meme chose maximum 3 fois
    
   
    
  finnn:
   
    coolorie i,j,07h,0     ;recolorie le i,j
    mov valuee1,2ch
    mov valuee2,47h      ;reafecte les couleur de base
    
    pop cx
    
    cmp turn,'b'
    je turn_white       ;on change de tour
    
    mov turn,'b'
    
      init_sauvegarde 
      
      effacer
    
    jmp main_loop
    
   
    
    turn_white:
    
    mov turn,'w'
    
    init_sauvegarde
    
    effacer
    
   jmp main_loop
   
   
   
