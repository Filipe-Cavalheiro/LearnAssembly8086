data segment
    num1 dw 10
    num2 dw -10  
    bucket dd 0
ends

stack segment
    dw   128  dup(0)
ends

code segment             
start:          
    mov ax, data
    mov es, ax
    mov ds, ax
    
    MOV AX, num1   ; AL = 0C8h
    MOV BX, num2                           
    call mult
                
    mov ax, 4c00h ; exit to operating system.
    int 21h       
    mult proc  
        cmp ax, bx
        ja axBigger
        mov dx, ax
        mov ax, bx
        mov bx, dx
        axBigger:
        
        multLoop:
        add bucket, ax
        dec bx
        cmp bx, 0
        jz end      
        jmp multLoop
        end:
        RET
    endp
ends

end start ; set entry point and stop the assembler.
