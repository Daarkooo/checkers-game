CaseColor MACRO row, column
    LOCAL BlackCase, fin

        ; (row % 2 === column % 2)
        mov al, column
        xor ah, ah
        mov cl, 2
        div cl
        mov bl, ah  ; Store (column % 2) in bl
        mov al, row
        xor ah, ah
        div cl
        cmp ah, bl  ; Compare (row % 2) with (column % 2)
        jnz BlackCase  ; not a White Square
    
        ; White square
        lea dx,White
        mov ah,09
        int 21h
        jmp fin
    
    BlackCase:
        lea dx,Black
        mov ah,09
        int 21h
    
    fin: 
    ENDM

.model small
.data
    row db 3
    column db 2
    Black db "A Black Square$"
    White db "A White Square$"
.code

    mov ax,@data
    mov ds,ax
    
    CaseColor row, column