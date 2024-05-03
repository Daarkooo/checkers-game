
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

.data
msj db "1er nbr : $"
msj1 db 10,13,"2eme nbr : $" 
a dw 10
c dw 0
b dw 0
q dw 0

.code

;saisire le premier nbr
mov cx,0
lea dx,msj
mov ah,09h
int 21h

nbr1:
mov bx,0
mov ah,01h
int 21h
cmp al,0Dh
je saut
sub al,30h 
mov bl,al
mov ax,cx
mul a
add ax,bx
mov cx,ax
jmp nbr1
saut:

mov b,cx


;saisire le 2eme nbr
mov cx,0
lea dx,msj1
mov ah,09h
int 21h
 
 
nbr2:
mov bx,0
mov ah,01h
int 21h
cmp al,0Dh
je saut1
sub al,30h 
mov bl,al
mov ax,cx
mul a
add ax,bx
mov cx,ax
jmp nbr2 


saut1:
mov c,cx
mov dx,0
mov ax,b
mul c
mov q,ax
 

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

cmp sp,ef
jne afff



ret




