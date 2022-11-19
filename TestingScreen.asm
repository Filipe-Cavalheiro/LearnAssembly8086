; multi-segment executable file template.

data segment
    posX db "X: ", 3 dup(0), "$"
    posY db "Y: ", 3 dup(0), "$"
    temp db 4 dup(0) 
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    call initGraph
    call initMouse
    
    loop1:
    
        call getMousePos
        shr cx, 1
        
        push dx
        
        lea si, temp
        mov ax, cx
        call strToInt
        
        lea si, temp
        lea di, posX
        call copyToStr
        
        lea si, temp
        mov cx, 4
        call clearString
        
        pop ax
        lea si, temp
        call strToInt
        
        lea si, temp
        lea di, posY
        call copyToStr
        
        lea si, temp
        mov cx, 4
        call clearString
        
        xor bh, bh
        
        mov dx, 0
        call setCursorPosition
        
        lea dx, posX
        call printf
        
        mov dx, 256
        call setCursorPosition
        
        lea dx, posY
        call printf
        
        lea si, temp
        lea di, posY
        call copyToStr
        
        
        lea si, posX
        add si, 3
        mov cx, 3
        call clearString
        
        lea si, posy
        mov cx, 3
        add si, 3
        call clearString        
    
        call getCharFromBuffer
        jnz endLoop1
        
        jmp loop1
    endLoop1:
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

clearString proc
    
    clearStringLoop:
        
        mov [si], 0
        inc si
        
    loop clearStringLoop
      
    ret 
clearString endp

copyToStr proc
    
    add di, 3
    
    copyToStrLoop:
    
        mov dl, [si]
        or dl, dl
        jz copyToStrEndLoop
        
        mov [di], dl
        
        inc di
        inc si
        
        jmp copyToStrLoop
    copyToStrEndLoop: 
    
    ret    
copyToStr endp    


;*****************************************************************
; initGraph - Initiate Graph
; description: starts the graph interface 
; input - none
; output - Graph interface on the screen
; destroy - nothing
;*****************************************************************
initGraph proc
    xor ah, ah
    mov al, 13h
    int 10h
    ret
initGraph endp

;*****************************************************************
; printfNum - put number in a string
; descricao:
; input - SI = start of string
;         AX = number to be printed
; output - nenhum
; destroi - cx, dx, ax e si
;*****************************************************************
strToInt proc
        push bx
        xor cx, cx
        mov bx, 10
        
        strToIntLoop1:
            
            inc cx
            xor dx, dx
            
            div bx
            add dx, 30h
            push dx
            
            or ax, ax
            jz strToIntEndLoop1
        
            jmp strToIntLoop1
        strToIntEndLoop1:
        
        
        
        strToInt2:
            
            pop dx
            mov [si], dl
            inc si
            
        loop strToInt2:
        
        mov [si], 0
        pop bx
        ret
strToInt endp

;*****************************************************************
; printf - prints a string to the screen
; descricao: rotine that prints a string to the screen
; input - dx = offset of sting to print  
; output - nada
; destroi - nada
;*****************************************************************    
printf proc
    push ax
    
    mov ah, 9
    int 21h
    
    pop ax
    ret
printf endp

;*****************************************************************
; getCharFromBuffer - get character form keyboard buffer
; descricao: rotine that gets a char from the keyboard buffer
; input - nada  
; output - ZF set a 0 se houver character e em al o caracter 
; destroi - ax
;*****************************************************************    
getCharFromBuffer proc
    push dx  
    
    mov ah, 6
    mov dl, 255
    int 21h
    
    pop dx
    ret
getCharFromBuffer endp

;*****************************************************************
; initMouse - Initiate Mouse
; description: starts the mouse 
; input - none
; output - none
; destroy - nothing
;*****************************************************************
initMouse proc
    xor ax, ax
    int 33h 
    ret
initMouse endp

;*****************************************************************
; getMousePos - get Mouse Position
; description:  
; input - none
; output - BX = Button pressed (1 - botao da esquerda, 2 - botao da direita e  3 ambos os botoes)
; 	       CX = horizontal position (column)
; 	       DX = Vertical position (row)
; destroy - nothing
;*****************************************************************
getMousePos proc
    push ax
	mov ax,03h
	int 33h
	pop ax
	ret

getMousePos endp

;*****************************************************************
; setCursorSizePosition - Cursor size and position
; descricao: rotine that gets the size and position of cursor
; input - Active page, linha, coluna
;         dh - linha
;         dl - coluna
;         bh - pagina ativa  
; output - nada
; destroi - cx e dx
;*****************************************************************     
setCursorPosition proc
    push ax                  
             
    mov ah, 02h
    int 10h
    
    pop ax
    ret 
setCursorPosition endp

end start ; set entry point and stop the assembler.

