
org 100h
.data
 a dw 10
 b dw 15
 c dw 23

.code


mov cx,b
mov dx,c    
   
boucle:

mov ax,cx
mov cx,dx
mov dx,0 
div cx
cmp dx,0
jne boucle


mov ax,cx



aff:
mov dx,0
div a
push dx
cmp ax,0
jne aff


afff:
pop dx
add dx,30h
mov ah,02
int 21h

cmp sp,0xfffe
jne afff




































ret




