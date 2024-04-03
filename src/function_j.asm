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
 i db 1
 j db 2
 x db 2
 y db 3    