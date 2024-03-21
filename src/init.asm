.data
    msg db "Hello, world!$"
.code
    mov ax,@data
    mov ds,ax

    mov ah,9
    lea dx,msg
    int 21h 
