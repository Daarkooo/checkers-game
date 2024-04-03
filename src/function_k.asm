deplacement macro i,j,x,y,turn,droite,direct              ;k)macro qui effectue le deplacement
    
LOCAL etiquette,droitee,gauchee,impossiblee,blacke,whitee,fin
     
pre_deplacement i,j,x,y,dep_possible,turn,direct,droite     ;verifier si le deplacement est possible
cmp dep_possible,1
jne impossiblee

mov al,i           ;deplacement possible
mov bl,j
mov cl,direct       ;direct represente si c'est un deplecament direct ou indirect
xor ch,ch

etiquette:           ;boucle qui effectue le trajet...
getNumber i,j,result
mov dl,result
xor dh,dh             ;retrouver la valeur de la case dans notre  structure et la remplacer par un vide
mov si,dx
mov board[si-1],'0'
cmp turn,'b'          ;selectionne la direction a emprunter selon notre toure
 je blacke                                                                  
 dec al           ;black en avant  blanc e arriere                                                          
 jmp whitee
 blacke:
 inc al
 whitee:
 
cmp droite,1      ;selectionne si on vas a gauche ou a droite 
je droitee 
dec bl
jmp gauchee
droitee:
inc bl 
gauchee:
mov i,al        ;actualisation de la case de depart
mov j,bl 
loop etiquette

getNumber i,j,result
mov dl,result
xor dh,dh                 ;remplacement de la case d'arriver selon notre pion
mov si,dx
mov al,turn
mov board[si-1],al

print_string reussie
print_string newLine db 13,10,'$'
jmp fin
impossiblee:
print_string echouer
print_string newLine db 13,10,'$'
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
 i db 3
 j db 0
 x db 5
 y db 2 
 dep_possible db ?  
 turn db ?
 direct db ?     ;1 direct 2 indirect
 droite db ?     ;1 droite 0 gauche
 reussie db " deplacement reussie$"
 echouer db " deplacement echouer$"
 