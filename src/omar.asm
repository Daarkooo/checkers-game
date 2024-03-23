;useful functions:start
;print number macro:start
print_number_dw macro number;using word (number should be dw)
mov ax,number
mov bx,0Ah
mov cx,0

start:
mov dx,0
cmp ax,0
je fin:
div bx
push dx  
inc cx
jmp start:
fin:
omar:  
pop dx
add dx,30h
mov ah,2

int 21h
loop omar: 
endm
;print number macro:end  

;built in print :start
include emu8086.inc
;print 'String to print'
;built in print :end

init_table_db macro tab ,length ;using bites in tab cells (db) 
mov si,0h
mov cx,length
read:
mov ah,1h
int 21h
mov tab[si],al
inc si
loop read:
endm

print_table_db macro tab ,length ;using bitesin tab cells (db)
mov si,0h
mov cx,length 
mov ah,2
mov dl,0Ah
int 21h

back_to_the_start:
mov ah,2
mov dl,8
int 21h
loop back_to_the_start: 

affiche:
mov ah,2
mov dl,tab[si]
int 21h
inc si
loop affiche:
endm  
;useful functions:end   

;important functions:start
cell_content macro row ,col
    mov ax,row
    mov bx,col
    shr ax,1
    jc axCond:
    mov ax,0h
    jmp fina:
    axCond:
    mov ax,1
    fina:
    shr bx,1
    jc bxCond:
    mov bx,0h
    jmp finb:
    bxCond:
    mov bx,1
    finb: 
    cmp ax,bx
    jne ifEqual:
    print 'err'
    mov bx,1
    jmp endPrint:
    ifEqual:
    mov ax,row
    mov bx,col
    sub ax,1
    sub bx,1 
    mov dx,5h
    mul dx
    shr bx,1
    add ax,bx
    inc ax
    mov bx,ax
    endPrint: 
endm  
    
;important functions:end
cell_content 8,5    
mov ah,2
mov dl,0Ah
int 21h
print_number_dw bx 

;testing:start
;cell_content 2,2
;pilila db 3 dup(0)     
;init_table_db pilila, 3     
;print_table_db pilila,3      
;testing:end