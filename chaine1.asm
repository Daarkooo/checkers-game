
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
.data
tab db 100 dup('$') 
msj1 db "ecrire un num : $"


.code
mov si,0
entre:
mov ah,01h
int 21h      
cmp al,0Dh    
je trmn1   
mov tab[si],al
inc si
jmp entre    

trmn1:

lea dx, msj1
mov ah,09h
int 21h 
mov cx,0 


 mov ah,09h
 lea dx,tab
 int 21h
 inc si

ret




