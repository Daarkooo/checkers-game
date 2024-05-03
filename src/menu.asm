                                        .model small
;-------------assembly--------------
;DATA SEGMENT 
.data 
menu DB ? 
    
    buffer db 10 ; 
    n1 db ?
    n2 db ?   
    i DB ?
    j DB ? 
    i1 DB ?
    j1 DB ?
    x DB ?
    y DB ?  
    color dw 000Fh
    xOffset Dw ? 
    yOffset Dw ? 
    row db 3
    column db 2
    Black db "A Black Square$"
    White db "A White Square$"
    isDirect DB ?
    result DB ?  
    result1 DB ?  
    result2 DW ? 
    result3 DB ? 
    result4 DB ? 
    state DB ?
    turn DB ?
    newline DB 10,13,"$"
    verified DB ?
    board DB 50 dup(?)  
    num DB ?      
    msg_vide DB "La case est vide","$"    
    msg_Wp DB "Un pion blanc","$" 
    msg_Bp DB "Un poin noire","$" 
    

    msg_case DB "enter le nombre de la case","$"  
    msg_rtr DB "Clickez pour revenire au menu","$"  
    msg_row DB "enter le numero de la ligne","$"  
    msg_column DB "enter le numero de la colone","$"  
    msg_err_input DB "Erreur : entree incorrecte. Veuillez reessayer.","$" 
    msg_err_case DB "C'est une case blanche","$" 
    msg_result DB "result: $"    
    msg_choose DB "choisiez votre pion $"    
    msg_destination DB "choisiez votre distination $"    
    msg_menu DB "Qu'est-ce que vous voulez faire ? $"    
    menu_message db 'Menu:', 13, 10
            db '1. Trouver la ligne', 13, 10
            db '2. Trouver la colonne', 13, 10
            db '3. Trouver le numero de la case', 13, 10
            db '4. Initialiser le plateau', 13, 10
            db '5. Trouver la color d une case', 13, 10
            db '6. Afficher l etat ', 13, 10
            db '7. Afficher le plateau', 13, 10
            db '8. Faire un mouvement', 13, 10
            db '9. Quit', 13, 10
            db '$'
  
  
;DATA ENDS

;CODE SEGMENT
.code  
ASSUME CS:CODE, DS:DATA


;------------get_clumn----------------
get_column MACRO n,result
    LOCAL not_eqaul_zero,fin, not_less_than_6

    MOV AL, n
    XOR AH, AH 
    MOV BL, 10
    DIV BL    ; divide AL by BL, q -> AL, r -> AH

    ; check if x == 0
    CMP AH, 0
    JNE not_eqaul_zero
    MOV AL, 8 ; return 8
    JMP fin
not_eqaul_zero:

    ; check if x < 6
    CMP AH, 6
    JGE not_less_than_6
    MOV AL, AH
    SHL AL, 1
    DEC AL ; retrun ah * 2 -1
    JMP fin
not_less_than_6:

    ; x >= 6
    MOV AL, AH
    SUB AL, 5
    SHL AL, 1
    DEC AL
    DEC AL  ; return (ah-5)*2-1

fin:
    MOV result,AL

ENDM 
 
 
;--------get_row----------
get_row MACRO Num, result
    LOCAL errorLabel, endLabel
    XOR AX, AX

    MOV AL, Num

    TEST AL, AL
    JZ errorLabel

    CMP AL, 50
    JA errorLabel

    DEC AL
    MOV BL, 5
    DIV BL
    JMP endLabel
    
    errorLabel:
        MOV AL, -1    
    
    endLabel:
        MOV result, AL        
ENDM
 

;------getNumber----------------  

get_number MACRO row, column, main, Num
    LOCAL invalid, end, next
        ; (row % 2 === column % 2)
        MOV AL,column
        CMP AL,9
        JA invalid

        MOV AL,row ;[0002h]
        CMP AL,9
        JA invalid

        MOV DL,'y'
        CMP DL,main
        JNE next
            MOV NUM, 'v'; valid
            JMP end
        next:

        ; MOV AL,row ;[0002h]
        MOV AH, row
        AND AH, 01h
        mov al, column
        AND al, 01h
        cmp ah, al  ; Compare (row % 2) with (column % 2)
        jz invalid  ; not a White Square
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
            jmp end
    invalid:
        ; White square || invalid row/column
        mov Num, 0
    end:
ENDM    
  





;-----board_init_board---------- 
board_init MACRO board
	LOCAL L1, L2, L3,ROW_END
	LEA SI, board
		
	MOV CX, 20
	L1:
		MOV BYTE PTR [SI], 'b'
		INC SI
	LOOP L1
	
	MOV CX, 10
	L2:
		MOV BYTE PTR [SI], '0'
		INC SI
	LOOP L2

	MOV CX, 20
	L3:
		MOV BYTE PTR [SI], 'w'
		INC SI
	LOOP L3
ENDM 



;----print_char---------
print_char MACRO asciiCode
	MOV AH, 02h
	MOV DL, asciiCode
	INT 21h
ENDM
 
 
;----print_string-------    
print_string MACRO reference
	MOV AH, 09h
	LEA DX, reference
	INT 21h
ENDM
 
;---print_board-------- 
print_board MACRO board
	LOCAL outer_loop, inner_loop1,row_end, inner_loop2
		MOV CX, 10
		XOR SI, SI
	
	outer_loop:
		PUSH CX
		TEST CX, 01h                ; get first bit to know whether it's parity
		MOV CX, 5
		MOV AH, 02h
		
		JZ inner_loop2
		
		inner_loop1:
			print_char board[SI]
			INC SI
			
			print_char ' '
			
			print_char 2EH
			
			print_char ' '          ; space
		LOOP inner_loop1
		
		JMP row_end
		
		inner_loop2:
			print_char 2EH
			
			print_char ' '          ; space
			
			print_char board[SI]
			INC SI
			
			print_char ' '
		LOOP inner_loop2
		
		row_end:
		print_string newLine        ; new line

		POP CX
	LOOP outer_loop
ENDM
   
   
get_cell_state MACRO board,i,j,result
	LOCAL white_cell, end_label     ; LOCAL LABELS
		MOV cL, i
		MOV cH, j
		get_number cL, cH, menu, AL        ; Le macro de la question C (Fait par Abdou & Omar)
		
		TEST AL, AL
		JZ white_cell
		
		XOR AH, AH
		MOV SI, AX
		MOV AL, board[SI - 1]        
		MOV result, AL
		JMP end_label
			
	white_cell:
	    MOV result, 0
	
	end_label: 
ENDM






display_menu macro
    mov ah, 09h
    mov dx, offset menu_message
    int 21h
endm

scan_char macro
    mov ah, 01h
    int 21h
endm





printTwoDigit MACRO num
    LOCAL label1, print1, exit
    mov ah, 0                ; Clear AH register
    mov al, num              ; Move the number to AL register
    xor cx, cx               ; Clear CX register (counter for digits)
    mov bx, 10               ; Load divisor into BX register
    label1:
        xor dx, dx           ; Clear DX register
        div bx               ; Divide AX by BX, result in AL (quotient) and AH (remainder)
        push dx              ; Push remainder (digit) onto the stack
        inc cx               ; Increment digit counter
        test ax, ax          ; Check if quotient is zero
        jnz label1           ; If not zero, continue loop
    print1:
        pop dx               ; Pop digit from stack into DX register
        add dl, '0'          ; Convert digit to ASCII character
        mov ah, 02h          ; Function 02h - Display character
        int 21h              ; DOS interrupt to display character
        loop print1          ; Loop until all digits are printed
    exit:
ENDM



scan_two_degit macro n1,n2
    LOCAL next,err,exit  
    mov n2,1
    ; Scan the first digit
    mov ah, 01h  ; Function to read character from STDIN
    int 21h      ; Call DOS interrupt
    sub al, 30h  ; Convert ASCII digit to binary
    cmp al, 0
    jl err
    cmp al, 9
    jg err
    mov n1, al   ; Store the first digit in n1
    mov ah, 01h  ; Function to read character from STDIN
    int 21h      ; Call DOS interrupt  
    cmp al, 0Dh
    je next
    sub al, 30h  ; Convert ASCII digit to binary
    mov bl, al   ; Store the second digit in bl
    mov ah, 0    
    mov al, n1   ; Move the first digit to AL register
    mov bh, 10   ; Set BH to 10 (to multiply by 10)
    mul bh       ; Multiply AL by BH (n1 * 10)
    add al, bl   ; Add the second digit (n1 * 10 + n2)
    mov n1,al
    
    next:
    mov dx,0  
    Jmp exit    
    err:
    mov n2,0
    exit:
    
ENDM    




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

  setCursorPosition MACRO row, column, page
                MOV AX, 0200h
                MOV BH, page
                MOV DL, column
                MOV DH, row
                INT 10H
            ENDM
        
        
        __printGraphicalCharacter PROC ; character, color
            PUSH BP
            MOV BP, SP
        
            ; * [BP + 6]: character
            ; * [BP + 4]: color
        
            MOV AH, 0Ah
            MOV AL, [BP + 6]
            XOR BH, BH
            MOV CX, 1
        
            INT 10h
        
            MOV SP, BP
            POP BP
            RET 4
        __printGraphicalCharacter ENDP
        
        printGraphicalCharacter MACRO character, color
            MOV AL, character
            PUSH AX
        
            MOV AX, color
            PUSH AX
        
            CALL __printGraphicalCharacter
        ENDM
        
        __printBoardWithOffset PROC ; board, color, xOffset, yOffset
            PUSH BP
            MOV BP, SP
            SUB SP, 2
        
            ; * [BP + 10]: board
            ; * [BP +  8]: color
            ; * [BP +  6]: xOffset
            ; * [BP +  4]: yOffset
        
            MOV WORD PTR [BP - 2], 0505h
        
            MOV SI, [BP + 10]               ; board
            MOV BX, [BP + 8]                ; color
            MOV DL, BYTE PTR [BP + 6]       ; xOffset
            MOV DH, BYTE PTR [BP + 4]       ; yOffset
        
            __printBoardWithOffset_L1:
                
                ; Draw cells in pairs
                __printBoardWithOffset_L2:
                    ; First cell in pair
                    setCursorPosition DH, DL, 0
                    printGraphicalCharacter 2Eh, BX
                    
                    INC DL
                    
                    ; First space in pair
                    setCursorPosition DH, DL, 0
                    printGraphicalCharacter ' ', BX
        
                    INC DL
        
                    ; Second cell in pair
                    setCursorPosition DH, DL, 0
        
                    MOV AL, BYTE PTR [SI]
                    printGraphicalCharacter AL, BX
        
                    INC SI
                    INC DL
        
                    ; Second space in pair
                    setCursorPosition DH, DL, 0
                    printGraphicalCharacter ' ', BX
        
                    INC DL
        
                    DEC WORD PTR [BP - 2]
                    TEST WORD PTR [BP - 2], 00FFh
                JNZ __printBoardWithOffset_L2
                
                INC DH
                MOV DL, BYTE PTR [BP + 6]
                DEC BYTE PTR [BP - 3]
                MOV BYTE PTR [BP - 2], 05h
        
                __printBoardWithOffset_L3:
                    ; First cell in pair
                    setCursorPosition DH, DL, 0
        
                    MOV AL, BYTE PTR [SI]
                    printGraphicalCharacter AL, BX
        
                    INC SI
                    INC DL
        
                    ; First space in pair
                    setCursorPosition DH, DL, 0
                    printGraphicalCharacter ' ', BX
        
                    INC DL
        
                    ; Second cell in pair
                    setCursorPosition DH, DL, 0
                    printGraphicalCharacter 2Eh, BX
                    
                    INC DL
                    
                    ; Second space in pair
                    setCursorPosition DH, DL, 0
                    printGraphicalCharacter ' ', BX
        
                    INC DL
        
                    DEC WORD PTR [BP - 2]
                    TEST BYTE PTR [BP - 2], 00FFh
                JNZ __printBoardWithOffset_L3
                
                INC DH
                MOV DL, BYTE PTR [BP + 6]
                DEC BYTE PTR [BP - 1]
                MOV BYTE PTR [BP - 2], 05h
                
                TEST [BP - 2], 0FF00h
                JZ __printBoardWithOffset_endLabel
            JMP __printBoardWithOffset_L1
        
            __printBoardWithOffset_endLabel:
        
            MOV SP, BP
            POP BP
            RET 8
        __printBoardWithOffset ENDP
        
        printBoardWithOffset MACRO board, color, xOffset, yOffset
            LEA AX, board
            PUSH AX
        
            MOV AX, color
            PUSH AX
        
            MOV AX, xOffset
            PUSH AX
        
            MOV AX, yOffset
            PUSH AX
        
            CALL __printBoardWithOffset
        ENDM 

;----------verify_move----------------   
verify_move MACRO board, i, j, x, y, turn, verified, isDirect, val1, val2
    LOCAL impossible_move, done, other_way, down, end, next
    ;DL=i DH=j BH=x CH=y | i and j must be between 1-10 -> (0-9) 'we do the check in get_number & 'DEC 1' in the main'  

    get_number i, j, main, n1 
        CMP n1,0 ; 0 -> white cell 'invalid' (check get_number)
        JE impossible_move  ; checking if it's a valid input 
    get_cell_state board,i,j,state  
        MOV AL, state
        CMP AL, turn ; to make the move -> 'w'='w' / 'b'='b' else impossible_move
        JNE impossible_move  
    
    get_number x, y, main, n2 ; main <- null doesnt effect  
        CMP n2,0
        JE impossible_move ; checking if it's a valid input
    get_cell_state board, x, y, state        
        CMP state,'0' ; to make the move -> board[x,y] needs to be empty '0'
        JNE impossible_move 

    MOV BH,n1
    MOV val1,BH ; need it in move function (to avoid the get_number call)
    MOV BH,n2 ; need it in indirect for checking 1st,2nd,8th,last (9/11)<-(n1-n2)
    MOV val2,BH ; need it in move function (to avoid the get_number call)
    
    ;----------show_path (optimization)---------(to check only one block direct/indirect)
    CMP isDirect,'n' ; isDirect <- Al
    JNE done ;-------DIRECT_MOVE-----(always true if the previous checks were true)
    
    ;------------INDIRECT_MOVE------------------------------- 
    MOV DL,i 
    MOV DH,j 
    MOV AH,y 

    MOV CL,n1
    CMP CL,BH ; CMP n1,n2
    JB down
        MOV DL,x ; n1>n2 =>------going up-------- to avoid the check of both cases(up &down) in different blocks
        MOV DH,y
        MOV AH,j
    down:
    CMP DH,AH ; cmp j,y | if we going up we swap 'cmp y,j' 
    JB other_way
        DEC DH ; dec n1[,j] 
        JMP next
    other_way:
        INC DH ; inc n1[,j]
    next:
    INC DL 

    get_number DL,DH , main, isDirect ; isDirect return makla number (for optimization) 'indirect move'
    get_cell_state board, DL, DH, state ; depends on the colors (white -> black/ black ->white)
    CMP state,'0' ; one step (not for dames)
    JE impossible_move  
    MOV AL,turn 
    CMP AL,state ; to make the move -> state needs to be the color of the opposing player (enemy) 
    JNE done ; make the move
        
    impossible_move:
        MOV verified,0 
        JMP end
    done:
        MOV verified,1   
    end:
ENDM 


;------move_pawn---------- 
move_pawn MACRO board,x,y,path1,path2,pawn_position,makla,isDirect
    LOCAL end, indirect, move, move1, no_move, next  
    MOV BH,x ; cant use the other registers cuz are used in get_number 
    MOV CH,y 

    get_number BH,CH,main,num1
    MOV BH,num1

    MOV num,BH
    CMP BH,path1
    JNE next
        MOV BH,path1 ; BH <- board[x,y]
        JE move1
    next:
    CMP BH,path2 ; BH <- board[x,y]     
    JNE no_move
    
    MOV AH,isDirect
    MOV makla,AH ; isDirect return maklaNum for path2

    move1:
    XOR AX, AX   
    MOV AL, pawn_position
    DEC AL   
    MOV DI, AX    
    MOV AL, BH ; BH <- board[x,y]
    DEC AL   
    MOV SI, AX     
        
    CMP isDirect,'y'
    JNE indirect 
        MOV AL,board[DI] ;---DIRECT MOVE---------
        MOV board[DI],'0'
        MOV board[SI],AL                    
        JMP move
    indirect:
        MOV AL,board[DI] ;---INDIRECT MOVE---------
        MOV board[DI],'0'
        MOV board[SI],AL 
            
        MOV AL, makla 
        DEC AL  
        MOV DI, AX    
        MOV AL,board[DI]
        MOV board[DI],'0'
    move:
        MOV AL,num
        MOV isDirect, AL
        JMP end
    no_move:
        MOV AL,-1
        MOV isDirect,AL
    end:
ENDM


main:   

    MOV AX, @DATA
    MOV DS, AX 
   
  
    mov ax, 3
    int 10h
    display_menu 
    mov xOffset,55
    mov yOffset,1   

    printBoardWithOffset board, color, xOffset, yOffset
    print_string newline  
    mov ah, 00h
    scan_two_degit n1,n2
    mov cl ,30h 
    add n1,cl
    mov al,n1
    cmp al, '1'
    je return_row
    cmp al, '2'
    je return_column
    cmp al, '3'
    je return_num
    cmp al, '4'
    je option4
    cmp al, '5'
    je option5
    cmp al, '6'
    je option6
    cmp al, '7'
    je option7
    cmp al, '8'
    je option8
    cmp al, '9'
    je quit
    jmp main

return_row: 

    print_string newline  
    print_string msg_case  ; Print prompt message  
    print_string newline  
    scan_two_degit n1,n2
    cmp n2,0
    je err  
    cmp n1,0
    je err 
    get_row n1, result1 
    add result1,1
    cmp  result1,0
    je err  

    print_string newline  
    print_string msg_result      
    printTwoDigit result1  
    
    
    print_string newline
    print_string newline  
    print_string msg_rtr  
    
    scan_char
   
    jmp main


return_column:   

    print_string newline  
    print_string msg_case  ; Print prompt message
    print_string newline  
    scan_two_degit n1,n2
    cmp n2,0
    je err

    get_column n1, result1 
  
    add result1,1   
    cmp  result1,0
    je err  
      
    print_string newline  
    print_string msg_result      
    printTwoDigit result1  
    print_string newline
    
    
    print_string newline
    print_string newline  
    print_string msg_rtr  
    
    scan_char
   
    jmp main

return_num:    



    print_string newline  
    print_string msg_row  
    print_string newline
    scan_two_degit x,n2 
    print_string newline  
    cmp n2,0
    je err  
    cmp x,10
    jg err   
    cmp x,0
    jle err   
 
    print_string msg_column  
    print_string newline  
    scan_two_degit y,n2 
    cmp y,10
    jg err   
    cmp y,0
    jle err   

    cmp n2,0
    je err
    dec x
    dec y     
    get_number x, y, menu ,result1 
    print_string newline  
    print_string msg_result

    cmp  result1,0
    je err 
    printTwoDigit result1   
    print_string newline
                                                                       


    print_string newline
    print_string newline  
    print_string msg_rtr  
    
    scan_char
    
    false:

    jmp main
          
          
option4:  

    board_init board  
    print_string newline
    print_string newline  
    print_string msg_rtr  
    
    scan_char
    jmp main

option5:    
    print_string newline  
    print_string msg_row  
    print_string newline
    scan_two_degit x,n2  
    print_string newline  
    cmp n2,0
    je err 
    cmp x,10
    jg err   
    cmp x,0
    jl err   

    print_string msg_column  
    print_string newline  
    scan_two_degit y,n2 
    
    cmp n2,0
    je err   
    cmp y,10
    jg err   
    cmp y,0
    jle err   

    dec x
    dec y     

   CaseColor x, y  
   print_string newline  
   print_string newline
   print_string newline  
   print_string msg_rtr  
    
    scan_char

    jmp main

option6:

    print_string newline  
    print_string msg_row  
    print_string newline
    scan_two_degit x,n2  
    print_string newline  
    cmp n2,0
    je err 
    cmp x,10
    jg err   
    cmp x,0
    jle err   

    print_string msg_column  
    print_string newline  
    scan_two_degit y,n2 
    
    cmp n2,0
    je err   
    cmp y,10
    jg err   
    cmp y,0
    jl err   

    dec x
    dec y     
    get_cell_state board,x,y,result1 
    
    cmp result1, '0' 
    jne next1  
        print_string newline  

    print_string msg_result
    print_string msg_vide  
    print_string newline
    jmp cell
    next1:
     

    cmp result1, 0
    jne next2
         print_string newline  

    print_string msg_result
    print_string msg_err_case  
    print_string newline 
    
    jmp cell  
    next2: 
    cmp result1, 'b'  
    jne next3
         print_string newline  

    print_string msg_result
    print_string msg_Bp  
    print_string newline
    jmp cell  
    next3: 
    cmp result1, 'w'  
        print_string newline  

    print_string msg_result
    print_string msg_Wp 
    print_string newline
    jmp cell

               
    cell:

    print_string newline  
    print_string newline
    print_string newline  
    print_string msg_rtr  
    
    scan_char

    jmp main

  
option7:
         
    print_board board  
    print_string newline  
   print_string newline
   print_string newline  
   print_string msg_rtr  
    
    scan_char

    jmp main   
    
    
option8:  
    print_string newline

    print_string msg_choose 
    print_string newline  
    print_string msg_row  
    print_string newline
    scan_two_degit x,n2  
    print_string newline  
    cmp n2,0
    je err 
    cmp x,10
    jg err   
    cmp x,0
    jle err   

    print_string msg_column  
    print_string newline  
    scan_two_degit y,n2 
    
    cmp n2,0
    je err   
    cmp y,10
    jg err   
    cmp y,0
    jle err   

    dec x
    dec y 
    get_number x, y, 'y' ,num  
    
    cmp num,'v' 
    print_string newline

    print_string msg_destination 
    print_string newline  
    print_string msg_row  
    print_string newline
    scan_two_degit i,n2  
    print_string newline  
    cmp n2,0
    je err 
    cmp i,10
    jg err   
    cmp i,0
    jle err   

    print_string msg_column  
    print_string newline  
    scan_two_degit j,n2 
    
    cmp n2,0
    je err   
    cmp j,10
    jg err   
    cmp j,0
    jle err   

    dec i
    dec j 
    get_number i, j, 'y' ,num   
    
    cmp num,'v'
    
    ;move_pawn board,x,y,i,j,turn

    print_string newline


    
    
    
    jmp main

    
err:    

    print_string newline  
    print_string msg_err_input  ; Message d'erreur
    print_string newline
    print_string msg_rtr  
    
    scan_char
   
    jmp main
    
quit:
    mov ah, 4Ch
    int 21h

err_case :    
    print_string newline  
    print_string msg_err_case  ; Message d'erreur
    print_string newline
    print_string newline
    print_string newline
    print_string newline
    print_string msg_rtr  
    


END main
