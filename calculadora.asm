data segment
strWelcome db "Bem vindo/a a nossa calculadora", 10, 13, 0
strFirstNum db "Intruduza o primeiro operando: ", 0
var1 dw ?
strOp db 10, 13, "Intruduza a operacao a realizar: ", 0
Op db 2 dup (?)
strSecNum db 10, 13, "Intruduza o segundo operando: ", 0
var2 dw ?
strFinal db 10, 13, "O resultado e: ", 0
strObg db 10, 13, "Obrigado", 0
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

call calculator

mov ax,4c00h ; terminate program
int 21h

;*****************************************************************
; calculator - calculate 2 value with an operator
; descricao:
; input - none
; output - result of operation
; destroi - ax, dx
;*****************************************************************
calculator proc
mov SI, offset strWelcome
mov bl, 00H
call printf

mov SI, offset strFirstNum
mov bl, 00H
call printf
mov bl, 01H
call scanf
mov var1, ax

mov SI, offset strOp
mov bl, 00H
call printf
mov DI, offset Op
mov bl, 00H
call scanf ; get the operator and store in Op

mov SI, offset strSecNum
mov bl, 00H
call printf
mov bl, 01H
call scanf
mov var2, ax

mov DI, offset Op
call calculatorOperator

mov SI, offset strFinal
mov bl, 00H
call printf
mov bl, 03H
call printf

;mov SI, offset strObg
;mov bl, 00H
;call printf
ret
calculator endp

calculatorOperator proc
cmp [DI], '+'
jne calculatorOperatorSwitch1
mov ax, var1
add ax, var2
mov var1, ax

calculatorOperatorSwitch1:
ret
calculatorOperator endp

;*****************************************************************
; printf - string output
; descricao: rotina que faz o output de uma string NULL terminated para o ecra
; input - si = deslocamento da string a escrever desde o inicio do segmento de dados
; output - nenhum
; destroi - si
;*****************************************************************
printf proc
push ax
cmp bl, 00h
jne printfSwitch1
jmp L1Printf

printfSwitch1:
cmp bl, 01h
jne printfSwitch2
call toLower
jmp L1Printf

printfSwitch2:
cmp bl, 02h
jne printfSwitch3
call toUpper
jmp L1Printf

printfSwitch3:
cmp bl, 03h
jne printfSwitch4
call printfNum
jmp L1Printf

printfSwitch4:
L1Printf: mov al,byte ptr [si]
or al,al
jz fimprtstr
call co
inc si
jmp L1Printf
fimprtstr:
pop ax
ret
printf endp

;*****************************************************************
; printfNum - put number in string
; descricao:
; input - SI= start of string
;         AX = number to be printed
; output - nenhum
; destroi - nada
;*****************************************************************
printfNum proc
push bx
push si
mov cx, 0

L1PrintfNum:
mov bl, 10
div bl
inc cx
mov dl, al
mov al, 00H
add ah, '0'
push ax
mov al, dl
mov ah, 00H
cmp al, 0
je endL1PrintfNum
jmp L1PrintfNum

endL1PrintfNum:
L2PrintfNum:
dec cx
pop ax
mov [si], ah
INC SI
cmp cx, 0
je endL2PrintfNum
jmp L2PrintfNum
endL2PrintfNum:

mov [SI], 00H
pop si
pop bx
ret
printfNum endp

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
cmp bl, 01h ; check if its a numb and not a string
jne jmpScanfNumb
call scanfNumb
jmp endScanf2

jmpScanfNumb:
push ax
mov ax, MAXSTRSIZE
push ax
push di

L1Scanf:
call getChar
cmp [DI-1], 0DH ; cmp with enter
je endScanf

pop ax
dec ax
or ax, ax
push ax
je endScanf ; cmp with max size

jmp L1Scanf

endScanf:
mov [DI-1], 0
INC DI
pop ax
pop ax
pop di
endScanf2:
ret
scanf endp

getChar proc
push ax
mov ah, 01H
INT 21H
mov [DI], al
INC DI
pop ax
ret
getChar endp

;*****************************************************************
; scanfNumb - scanf for int
; descricao:
; input - nothing
; output - number in int placed in AX
; destroi - ax
;*****************************************************************
scanfNumb proc
push bx
mov ax, 0
mov bl, 10

L1ScanfNumb:
call getChar
cmp [DI-1], 0DH ; cmp with enter
je endScanfNumb
mul bl
sub [DI-1], 30H
add al, [DI-1]
jmp L1ScanfNumb

endScanfNumb:
pop bx
ret
scanfNumb endp


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
toUpper endp


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

toLower endp

;*****************************************************************
; swap - swap to chars
; descricao: changes the chars of a string on with the other
; input - SI = first to be swaped
;         DI = second to be swaped
; output - nenhum
; destroi - DI, SI
;*****************************************************************
swap proc
push dx
mov dl, [SI]
mov dh, [DI]
mov [SI], dh
mov [DI], dl
pop ax
ret
swap endp

ends
end start
