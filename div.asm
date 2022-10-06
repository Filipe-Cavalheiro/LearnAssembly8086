data segment
    bucket dd 0 
    resto dw 0
ends

stack segment
    dw   128  dup(0)
ends

code segment             
start:          
    mov ax, data
    mov es, ax
    mov ds, ax
    
    MOV AX, 5
    MOV BX, 10   
    cmp AX, 0
    cmp BX, 0
    jz notAllowed    
    call division
    
    notAllowed:
    mov ax, 4c00h
    int 21h    
       
    division proc  
        cmp ax, bx
        ja axBigger
        mov dx, ax
        mov ax, bx
        mov bx, dx
        axBigger:
        
        multLoop:
            sub ax, bx  
            inc bucket        
            cmp ax, bx
            jb end     
            jmp multLoop
        end:   
            mov resto, ax
            RET
    endp
ends

end start
