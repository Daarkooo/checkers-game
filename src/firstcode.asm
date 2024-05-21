;1)fonction qui retourne la ligne

ligne macro N,result
  mov al,N
  ;dec al
  dec al           
  mov bl, 5
  mov ah,0
  div bl
  mov result,al
    
endm

 ;2) fonction qui retourne la cologne

;formula N*2 mod10 -1 or -2 selon la parite de la ligne +cas special 2 derniere cologne

cologne macro N,result
mov al,N
add al,4
mov bl,5  ;calcule de la ligne   
div bl
sub al,1
mov cl,al    
mov ax,0    
mov bx,0    

mov dl,2    
mov al,N
mul dl
mov bl,10
mov ah,0
div bl
cmp ah,0
jne suite
add ah,10

suite:
      
mov ch,ah ;calcule de la cologne resultat dans le ah astuce il y'a 5 case noire par ligne
mov ax,0 
mov al,cl      
        ;rectification des resultat par port a la parite des lignes
div dl          
cmp ah,0
jne plus_deux
mov ax,0
dec ch
jmp fin
  
plus_deux:

mov ax,0
sub ch,2

fin:
mov result, ch
    
endm
 
 
 ;3)fonction qui retourne le numero de la case formula E[N=ligne*5 +cologne/2 +1]
numero_case macro i,j,N                      
push ax
push bx
mov ax,0
mov bx,0
    
mov al,i
mov cl,j
mov bl,2
div bl
cmp ah,0
je ligne_paire

mov ax,0
mov al,j
div bl
cmp ah,0
jne case_blanche
je resul
   
   
ligne_paire:
mov ax,0
mov al,j
div bl
cmp ah,0
je case_blanche

resul:
dec i
dec j
mov ax,0
mov al,j
div bl
mov cl,al
mov al,i
mov bl,5
mul bl
mov ah,0
add al,cl
inc al
mov N,al
jmp fin

case_blanche:

                 ;afficher message case blanche cas ou ils i et j ont la meme parite
pop bx
pop ax
hlt

fin:
pop bx
pop ax
 
endm 
    
data_segment segment
    
N db 34
result db 0
i db 3
j db 4
    
data_segment ends 


code_segment segment
        
 assume cs:code_segment,ds:data_segment
 
 start:
 ;test de la ligne
    mov ax,data_segment
    mov ds,ax
    mov ax,0
    mov cx,0
    mov dx,0
    mov bx,0
    
    ;ligne N,result
    ;cologne N,result
    numero_case i,j,N
    mov ax,0
    mov al,N
    
    ;hlt
  ;test cologne
  
           
    
code_segment ends

end start                                                                                              