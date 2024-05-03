
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

;3. Saisie et affichage d'une chaîne de caractères
org 100h
.data 
; Declarer les variables
message db "Entrez une chaine de caracteres: $"
message2 db 10,13,"La chaine de caracteres est: $"
chaine dw 50 dup ('$')

.code
; Afficher le premier message
mov ah, 09h
lea dx, message
int 21h

; Lire une chaine de caracteres a partir du clavier
mov ah, 10  ;sisire yune chain de chr
mov dx, offset chaine
int 21h

; Afficher le deuxieme message
mov ah, 09h    ;09 aff chaine  ;;;02 aff chr  ;;; 01 S ta3 chr
lea dx, message2
int 21h

; Afficher la chaîne de caractères
mov ah, 09h
lea dx, chaine+2  ; On ajoute 2 pour sauter les 2 premiers octets qui contiennent la longueur de la chaine
int 21h

ret

ret




