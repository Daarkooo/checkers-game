CaseColor MACRO row, column , Color
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
        MOV Color,'w'
        jmp fin
    
    BlackCase:
        MOV Color,'b'
    
    fin: 
    ENDM

.model small
.data
    row db 3
    column db 2

.code

    mov ax,@data
    mov ds,ax
    
    CaseColor row, column
