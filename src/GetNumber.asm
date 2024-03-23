getNumber MACRO row, column, Num
    LOCAL calculate_number, fin

        ; (row % 2 === column % 2)
        mov al, column
        xor ah, ah
        div byte ptr 02h
        mov bl, dl  ; Store (column % 2) in bl
        mov al, row
        xor ah, ah
        div byte ptr 02h
        cmp dl, bl  ; Compare (row % 2) with (column % 2)
        jnz calculate_number  ; not a White Square
    
        ; White square
        mov Num, 0
        jmp fin
    
    calculate_number:
        ; Subtract 1 from row and column to adjust them to the range [1,10]
        dec row
        dec column
    
        ; Calculate the number
        mov al, row
        mov bl, 5
        mul bl  ; AL = row * 5
        mov bl, column
        shr bl, 1  ; Divide column by 2 
        add al, bl  ; AL = AL + (column / 2)
        inc al  ;the index starts from 0
    
        ; Store the number
        mov Num, al
    
    fin: 
    ENDM
