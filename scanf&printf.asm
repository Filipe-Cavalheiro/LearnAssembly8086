data segment
    strOla db "Ola malta, tudo bem???",0dH,0aH,0
    strPri db "Vamos iniciar a nossa aula!!!",0dH,0aH,0 
    strNew db MAXSTRSIZE dup(?)   
    MAXSTRSIZE equ 100
ends  

stack segment
    dw 128 dup(0)
ends   

code segment
start:
    mov ax, data
    mov ds, ax
    mov es, ax                
    
    mov di, offset strNew
    call scanf  
     
    mov BL, 02h 
    mov si, offset strNew    
    call printf
    
mov ax,4c00h ; terminate program
int 21h   

;*****************************************************************
; printf - string output
; descricao: rotina que faz o output de uma string NULL terminated para o ecra
; input - si = deslocamento da string a escrever desde o inicio do segmento de dados 
; output - nenhum
; destroi - al, si
;*****************************************************************
printf proc
    cmp bl, 00h
    jne switch1
    jmp L1Printf
    
    switch1: 
    cmp bl, 01h
    jne switch2
    call toLower 
    jmp L1Printf 
    
    switch2: 
    cmp bl, 02h
    jne default
    call toUpper 
    jmp L1Printf
    
    default:
    L1Printf: mov al,byte ptr [si]
    or al,al
    jz fimprtstr
    call co
    inc si
    jmp L1Printf
    fimprtstr: ret
printf endp  

;*****************************************************************
; co - caracter output
; descricao: rotina que faz o output de um caracter para o ecra
; input - al=caracter a escrever
; output - nenhum
; destroi - nada
;*****************************************************************
co proc
    push ax
    push dx
    mov ah,02H
    mov dl,al
    int 21H
    pop dx
    pop ax
    ret
co endp

;*****************************************************************
; scanf - string input
; descricao: rotina que faz o input de uma string ate o char ENTER
; input - DI = deslocamento da string a escrever desde o inicio do segmento de dados 
; output - string
; destroi - nada
;*****************************************************************   
scanf proc 
    push ax
    mov ax, MAXSTRSIZE 
    push ax
    push di
    
    L1Scanf:       
    mov ah, 01H
    INT 21H 
    cmp al, 0DH ; cmp with enter
    je endScanf
    mov [DI], al
    INC DI
    
    pop ax
    dec ax
    or ax, ax
    push ax
    je endScanf ; cmp with max size 
    
    jmp L1Scanf   
    
    endScanf:
    mov [DI], 0 
    INC DI
    pop ax
    pop ax
    pop di
        ret
scanf endp  


;*****************************************************************
; toUpper - chars to UPPER case
; descricao: changes all chars to UPPER case
; input - si = deslocamento da string a escrever desde o inicio do segmento de dados
; output - nenhum
; destroi - nada
;*****************************************************************  
toUpper proc  
    push SI
    L1ToUpper: mov al,byte ptr [si]
    or al,al
    jz endToUpper
    cmp al, 97
    jl endL1ToUpper
    cmp al, 122
    ja endL1ToUpper
    
    sub al, 32
    mov [SI], al
    
    endL1ToUpper:
    INC SI
    jmp L1ToUpper
    endToUpper: 
    pop si
    ret
ends 


;*****************************************************************
; toLower - chars to lower case
; descricao: changes all chars to lower case
; input - si = deslocamento da string a escrever desde o inicio do segmento de dados
; output - nenhum
; destroi - nada
;*****************************************************************  
toLower proc  
    push SI
    L1ToLower: mov al,byte ptr [si]
    or al,al
    jz endToLower
    cmp al, 65
    jl endL1ToLower
    cmp al, 90
    ja endL1ToLower
    
    add al, 32
    mov [SI], al
    
    endL1ToLower:
    INC SI
    jmp L1ToLower
    endToLower: 
    pop si
    ret
ends
end start
