
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h
 .data
 chaine 10 dup ("$")
.code 
mov ah,0Ah
lea dx,chaine
int 21h

lea dx,chaine[2]
MOV AH,09h
int 21h
ret




