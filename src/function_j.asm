pre_deplacement macro i,j,x,y,dep_possible,turn,direct,droite;j)macro qui verifie si le deplacement est possible de i,j a x,y    ;indice 0..9;possible 1 oui 0 non;direct 1 indirect 2 ;droite 1 gauche 0
    
LOCAL pion_blanc,deplacement_impossible,deplacement_possible,deplacement_indirect,cologne_gauche,cologne_droite,cologne_gauche2,cologne_droite2,fin,deplacement_direct,blancc,noiree,commun           

cmp x,0                     ;verifier si la destination est coerente ou non 
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
cmp i,0                          ;verifier si la case de depart est coerente ou non 
jl deplacement_impossible
cmp i,9                
jg deplacement_impossible

getCellState board,x,y,result
cmp result,'0'                   ;verifier si la case d'arriver est vide et existe bien
jne deplacement_impossible 

getCellState board,i,j,result
mov al,turn                      ;verifier si la case de depart est bien un pion du joueur en jeux 
cmp al,result
jne deplacement_impossible 

mov al,i
mov bl,j    
cmp result,'w'                   ;selection de pion noire ou blanc
je pion_blanc

;pion noire
cmp al,x                           ;verifier si la destination est coerente une seule direction de deplacement
jge deplacement_impossible
         
inc al                        ;prochaine ligne en incremenatant car pion noire               
cmp x,al                    ;verifier si on est dans un cas de deplacement direct ou indirect
jne deplacement_indirect

deplacement_direct:      ;deplacement direct
mov direct,1            ;sauvegarde du choix direct    
cmp bl,y                   
jg cologne_gauche
mov droite,1                   ;sauvegarde du choix cologne droite
inc bl                           ;recherche de la cologne souhaite
jmp cologne_droite                             
cologne_gauche:
mov droite,0            ;sauvegarde du choix cologne gauche
dec bl
cologne_droite: 
cmp bl,y                        ;verifier si c'est bien l'indice de la cologne rechercher
jne deplacement_impossible
jmp deplacement_possible

deplacement_indirect:                ;deplacement indirect
mov ch,'w'             ;pour verifier en cas de deplacement indirect pour les pion noires
inc al                          ;2 ligne au dessus

commun:           ;code en commun pour les pion noire et blanc
mov direct,2                                       ;sauvegarde du choix indirect        
cmp al,x
jne deplacement_impossible      ;deplacement indirect impossible
cmp bl,y
jg cologne_gauche2             ;selection de cologne
mov droite,1             ;sauvegarde du choix cologne droite
add bl,2               ;acces a la cologne rechercher y            
cmp bl,y
jne deplacement_impossible    ;ce n'est pas la cologne rechercher y
dec bl                ;selectionne l'indice de la cologne de la case d'avant
jmp cologne_droite2          
cologne_gauche2:
mov droite,0             ;condition pour la cologne de gauche same as right
sub bl,2
cmp bl,y
jne deplacement_impossible
inc bl
cologne_droite2:
cmp al,i            ;verifier si on est avec le pion blanc ou noir question d'optimization
jl blancc
dec al               ;pour selectionner la case d'avant et savoire si elle est libre
jmp noiree
blancc:
inc al
noiree:
getCellState board,al,bl,result
cmp result,ch                        ;verifier si la case d'avant est occuper par un pion approprie pour le deplacement
jne deplacement_impossible                                                                     
jmp deplacement_possible

pion_blanc:                ;party pour les pion blanc same as black diference de parametrage
    
cmp al,x                        ;verifier si la destination est coerente une seule direction de deplacement
jle deplacement_impossible        
dec al                              ;prochaine ligne               
cmp x,al
je deplacement_direct          ;selection de deplacement direct ou indirect
dec al
mov direct,2                  ;deplacement indirect
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