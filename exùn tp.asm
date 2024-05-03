
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
.data

chaine 50 dup ("$")
msj1 db "entre une chaine $"
msj2 db 10,13,"votre voyelle est $"
 
.code 


mov ah,09h
lea dx,msj1
int 21h

mov ah,0Ah
lea dx,chaine
int 21h

mov si,0h
mov ax,0
mov cx, 20

rr:
inc si
cmp chaine[si],"a"
je vrfa

cmp chaine[si],"e"
je vrfe

cmp chaine[si],"i"
je vrfi

cmp chaine[si],"y"
je vrfy

cmp chaine[si],"u"
je vrfu

cmp chaine[si],"o"

je vrfo 

loop rr

vrfa:
vrfo:
vrfu:
vrfi:
vrfy:
vrfe:
mov ax,0

mov al,chaine[si]


mov ah,02h
mov dx,ax
int 21h

mov si,02h
mov bx,00h
mov cx,20 
mov dx,0

lop:

cmp chaine[si],al
je cnt
rtr:
cmp chaine[si],"$"
je aa
inc si
loop lop

mov dx,1 

cnt:
inc bx
cmp dx,1
jne rtr


aa: 
add bx,30h
mov dx,bx
mov ah,02
int 21h 

ret 



