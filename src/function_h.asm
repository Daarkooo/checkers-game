pre_deplacement macro i,j,x,y     ;indice 0..9 
    
LOCAL hors_damier,case_blanche,case_vide,pion_blanc,deplacement_impossible,deplacement_possible1,deplacement_indirect,cologne_gauche,cologne_droite,cologne_gauche1,cologne_droite1,deplacement_indirect1,cologne_gauche3,cologne_droite3,cologne_gauche2,cologne_droite2,fin           

cmp x,0              ;verifier si la destination est coerente ou non 
jl hors_damier:
cmp x,9                
jg hors_damier:
cmp y,0
jl hors_damier:
cmp y,9
jg hors_damier:

cmp j,0
jl hors_damier:
cmp j,9
jg hors_damier:
cmp i,0              ;verifier si la case de depart est coerente ou non 
jl hors_damier:
cmp i,9                
jg hors_damier:

CaseColor x,y
push bx               ;verifier si la case d'arriver est blanche ou noire
xor bx,bx
lea bx,white           
cmp dx,bx
je case_blanche
xor bx,bx
pop bx          
CaseColor i,j              
push bx               ;verifier si la case de depart est blanche ou noire
xor bx,bx
lea bx,white           
cmp dx,bx
je case_blanche 
xor bx,bx
pop bx
    
getCellState board,i,j,result    
cmp result,'0'                      ;verifier si la case est vide ou contient un pion blanc ou noir
je case_vide    
cmp result,'w'    
je pion_blanc
;pion noire    
mov cl,x    
cmp cl,i                           ;verifier si la destination est coerente ou non 2.0 une seule direction de deplacement
jle deplacement_impossible         

mov al,i
mov bl,j
inc al                        ;prochaine ligne               

cmp x,al
jne deplacement_indirect
;deplacement direct
cmp bl,y
jg cologne_gauche
jl cologne_droite

cologne_droite:                
inc bl                               
cmp bl,y                        ;verifier si c'est bien l'indice de la cologne rechercher
jne deplacement_impossible
   
getCellState board,al,bl,result
cmp result,'0'                        ;verifier si la case est vide
jne deplacement_impossible
jmp deplacement_possible

cologne_gauche:
dec bl 
cmp bl,y                        ;verifier si c'est bien l'indice de la cologne rechercher
jne deplacement_impossible

getCellState board,al,bl,result
cmp result,'0'                  ;verifier si la case est vide
jne deplacement_impossible
jmp deplacement_possible

deplacement_indirect:
inc al                 ;2 ligne en dessous
cmp al,x
jne deplacement_impossible    ;pas de deplacement indirect

cmp bl,y
jg cologne_gauche2
jl cologne_droite2

cologne_droite2:          
add bl,2                           
cmp bl,y
jne deplacement_impossible

getCellState board,al,bl,result
cmp result,'0'                  ;verifier si la case est vide
jne deplacement_impossible
dec al
dec bl   

getCellState board,al,bl,result
cmp result,'w'                        ;verifier si la case d'avant est occuper par un piont blanc
jne deplacement_impossible
jmp deplacement_possible

cologne_gauche2:
sub bl,2
cmp bl,y
jne deplacement_impossible

getCellState board,al,bl,result
cmp result,'0'                       ;verifier si la case est vide
jne deplacement_impossible
dec al
inc bl
getCellState board,al,bl,result
cmp result,'w'                        ;verifier si la case d'avant est occuper par un piont blanc
jne deplacement_impossible
jmp deplacement_possible

pion_blanc:
mov cl,x    
cmp cl,i                        ;verifier si la destination est coerente ou non 2.0 une seule direction de deplacement
jge deplacement_impossible        

mov al,i
mov bl,j
dec al                  ;prochaine ligne               

cmp x,al
jne deplacement_indirect1
;deplacement direct
cmp bl,y
jg cologne_gauche1
jl cologne_droite1

cologne_droite1:                          
inc bl                                   
cmp bl,y                        ;verifier si c'est bien l'indice de la cologne rechercher
jne deplacement_impossible
  
getCellState board,al,bl,result
cmp result,'0'                  ;verifier si la case est vide
jne deplacement_impossible
jmp deplacement_possible

cologne_gauche1:
dec bl 
cmp bl,y                        ;verifier si c'est bien l'indice de la cologne rechercher
jne deplacement_impossible

getCellState board,al,bl,result
cmp result,'0'                  ;verifier si la case est vide
jne deplacement_impossible
jmp deplacement_possible

deplacement_indirect1:
dec al
cmp al,x
jne deplacement_impossible      ;pas de deplacement indirect

cmp bl,y
jg cologne_gauche3
jl cologne_droite3


cologne_droite3:          
add bl,2                            
cmp bl,y
jne deplacement_impossible
getCellState board,al,bl,result
cmp result,'0'                  ;verifier si la case est vide
jne deplacement_impossible
inc al
dec bl   

getCellState board,al,bl,result
cmp result,'b'
jne deplacement_impossible
jmp deplacement_possible

cologne_gauche3:
sub bl,2
cmp bl,y
jne deplacement_impossible

getCellState board,al,bl,result
cmp result,'0'                  ;verifier si la case est vide
jne deplacement_impossible
inc al
inc bl
getCellState board,al,bl,result
cmp result,'b'
jne deplacement_impossible
jmp deplacement_possible

deplacement_possible:
print_string possible 
jmp fin

hors_damier:    
case_blanche:
case_vide:
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
 i db 1
 j db 2
 x db 2
 y db 3    