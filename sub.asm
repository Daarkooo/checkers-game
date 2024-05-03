org 100h

.data 


msj1 db "ecrire un num : $"
msj2 db 10,13,"ecrire le 2eme num :$"
msj3 db 10,13,"la sub est :$"

a dw 0
c dw 0   
b dw 10
tb db 8 dup 0
.code

lea dx, msj1
mov ah,09h
int 21h 
mov cx,0 



entre:

mov ah,01h
int 21h      
cmp al,0Dh    
je trmn1   
mov bx,0
mov bl,al
mov ax,cx
mul b
sub bx,30h          
add ax,bx
mov cx,ax
jmp entre    
    
trmn1:
   
mov a,cx     

lea dx, msj2
mov ah,09h
int 21h 
mov cx,0 
entre2:

mov ah,01h
int 21h      
cmp al,0Dh    
je trmn2   
mov bx,0
mov bl,al
mov ax,cx
mul b
sub bx,30h          
add ax,bx
mov cx,ax
jmp entre2    
    
trmn2:

mov ax,a    
sub ax,cx
mov si,0  
mov cx,10 
mov bx,ax

etq:
mov dx,0

div b             ;04 div 10 <> 0 6666
mov tb[si],dl
inc si

cmp ax,0
jne etq
dec si

lea dx, msj3
mov ah,09h
int 21h 
mov cx,0 


ettq:
mov dl,tb[si]
add dl,30h
mov ah,2
int 21h
dec si
cmp si,-1
jne ettq   
    
    
    







ret