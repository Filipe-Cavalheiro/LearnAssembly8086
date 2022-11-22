data segment
    MAXSTRSIZE equ 100
    GRIDCOLOR equ 27
	SQUARECOLOR equ 15
	MAXCOLLUM equ 320
	MAXLINE equ 200
    handler dw 0
    logFile db "C:\ConwayGame\Log.txt", 0
    strOpenError db "Error on open: $"
    strCreateError db "Error on create: $"
    strCloseError db "Error on close: $"
    strSeekError db "Error on seek: $"
    strReadError db "Error on read: $"
    strWriteError db "Error on write: $"
    strInvFunc db "Invalid function number$"
    strNoFile db "File not found$"
    strNoPath db "Path not found$"
    strHandleBusy db "All available handles in use$"
    strNoAccess db "Access denied$"
    strNoHandle db "Invalid handle$"
    strNoAccessCode db "Invalid access code$"
    strNoDrive db "Invalid drive specified$"
    strRemoveDir db "Attempt to remove current directory$"
    strNoDevice db "Not the same device$"
    strNoFiles db "No more files to be found$"
    strNoError db "Error not describable$"
    strHeader db "gen:000 Live Cells:0000 start exit$"
    strMenu db "Main  Menu$"
    strPlay db "Play$"
    strLoad db "Load$"
    strSave db "Save$"
    strTop5 db "Top  5$"
    strCredits db "*Credits$"
    strExit db "Exit$"
    strGetPlayerName db "Enter username: $"
    strDiogo db "Diogo Matos Novais  n", 0A7h, " 62506$"
    strFilipe db "Filipe Silva Cavalheiro n", 0A7h, " 62894$"
    strLog db 8 dup(0), ":", 6 dup(0), ":", MAXSTRSIZE dup(0), 15 dup(0) 
    strPlayerName db MAXSTRSIZE dup(0)
    strTemp db 10 dup(0)
    genNum dw 122
    cellNum dw 156
    xI dw 1
    yI dw 1
    xF dw 1
    yF dw 1
ends

stack segment
    dw 128 dup(0)
ends

code segment
start:
    mov ax, data
    mov ds, ax
    mov es, ax    
    
    call initGraph
    
    loop1:
        call startMenu
        call initGraph
    jmp loop1
    
    mov ax,4c00h ; terminate program
    int 21h
ends

;*****************************************************************
; checkPixel - Check Pixel
; description: checks if pixel is 'dead' or 'alive'
; input - CX = x coord
;         DX = y coord
; output - color in AL
; destroy - al
;*****************************************************************
checkPixel proc
mov ah, 0Dh
int 10h
ret
checkPixel endp

;*****************************************************************
; storeNextGen - store Next Gen
; description: stores next gen in nextGen
; input - none
; output - next gen in var nextGen
; destroy - ax, bx, cx, dx, si
;*****************************************************************
storeNextGen proc
lea si, nextGen
xor cx, cx
mov dx, 10

storeNextGenLoop1:
xor bx,bx

storeNextGenEnd1:
sub cx, 2
call checkPixel         ;\\\
cmp al, SQUARECOLOR     ;0X\
jne storeNextGenSwich1  ;\\\
inc bx
storeNextGenSwich1:
sub dx, 2
call checkPixel         ;0\\
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich2  ;\\\
inc bx
storeNextGenSwich2:
add cx, 2
call checkPixel         ;\0\
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich3  ;\\\
inc ax
storeNextGenSwich3:
add cx, 2
call checkPixel         ;\\0
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich4  ;\\\
inc bx
storeNextGenSwich4:
add dx, 2
call checkPixel         ;\\\
cmp al, SQUARECOLOR     ;\X0
jne storeNextGenSwich5  ;\\\
inc bx
storeNextGenSwich5:
add dx, 2
call checkPixel         ;\\\
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich6  ;\\0
inc bx
storeNextGenSwich6:
sub cx, 2
call checkPixel         ;\\\
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich7  ;\0\
inc bx
storeNextGenSwich7:
sub cx, 2
call checkPixel         ;\\\
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich8  ;0\\
inc bx
storeNextGenSwich8:
add cx, 2
sub dx, 2

call checkPixel
cmp al, SQUARECOLOR
jne storeNextGenEnd2        ; if dead just check if it can be born

cmp bx, 1
jbe storeNextGenSwich9
mov [si], 0
jmp storeNextGenEnd3  ; if 1 or 0 => kill
storeNextGenSwich9:

cmp bx, 3
jbe storeNextGenSwich10
mov [si], 0
jmp storeNextGenEnd3  ; if 2 or 3 => survive
storeNextGenSwich10:


mov [si], 0             ; more than 3 => kill
jmp storeNextGenEnd3

storeNextGenEnd2:
cmp bx, 3                   ; if 3 => born
jne storeNextGenEnd3
mov [si], 1


storeNextGenEnd3:

inc si
cmp cx, MAXCOLLUM           ; check if end of screen
jbe storeNextGenLoop1
cmp dx, MAXLINE
jbe storeNextGenLoop1

ret
storeNextGen endp

;*****************************************************************
; saveGen - Save Gen
; description: saves current gen
; input - none
; output - current gen in var nextGen
; destroy - si, bx, cx, dx
;*****************************************************************
saveGen proc
lea si, nextGen
xor cx, cx
mov dx, 10
saveGenLoop1:
call checkPixel
mov [si], 1
cmp al, SQUARECOLOR
je saveGenEnd1
mov [si], 0
saveGenEnd1:
add cx, 2
inc si
cmp cx, MAXCOLLUM
jbe saveGenLoop1
xor cx, cx
add dx, 2
cmp dx, MAXLINE
jbe saveGenLoop1
ret
saveGen endp

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
; clearGraph - clear the screen
; description: rotine that clears the screen 
; input - none
; output - none
; destroy - nothing
;*****************************************************************
clearGraph proc
    push ax
	mov ah,06
	mov al,00
	mov BH,00 ; attributes to be used on blanked lines
	mov cx,0 ; CH,CL = row,column of upper left corner of window to scroll
	mov DH,25 ;= row,column of lower right corner of window
	mov DL,40
	int 10h
	pop ax
	ret

clearGraph endp

;*****************************************************************
; drawPixel - draws a pixel
; descricao: 
; input - AL = pixel color
;         CX = column
;         DX = row
; output - pixel on the screen
; destroi - ah
;*****************************************************************
drawPixel proc
    mov ah, 0Ch
    int 10h 
    ret
drawPixel endp

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

;*****************************************************************
; getCursorSizePosition - Cursor size and position
; descricao: rotine that gets the size and position of cursor
; input - Active page (bh)  
; output - Inicio de linha do cursor, final de linha, linha e coluna
;          ch - inicio de linha
;          cl - final de linha
;          dh - linha
;          dl - coluna
; destroi - cx e dx
;*****************************************************************    
getCursorSizePosition proc
    push ax
    
    mov ah, 03h
    int 10h
    
    pop ax
    ret
getCursorSizePosition endp

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
; ci - input character
; descricao: Le um input do utilizador
; input - nada   
; output - al, caracter recebido
; destroi - ax
;*****************************************************************    
ci proc
        
    mov ah, 7
    int 21h
    
    ret    
ci endp

;*****************************************************************
; getChar - get Char
; descricao: wait for user input of a char
; input - DI = deslocamento da string a escrever desde o inicio do segmento de dados
; output - char
; destroi - nada
;*****************************************************************
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
; getCharFromBuffer - get character form keyboard buffer
; descricao: rotine that gets a char from the keyboard buffer
; input - nada  
; output - ZF set a 0 se houver character e retorna em al
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
; getSystemTime - Gets system time
; descricao: rotine that gets the system time
; input - nada  
; output - Hora, minuto, segundo e centesima
;          ch - hora
;          cl - minuto
;          dh - segundo
;          dl - centesima
; destroi - cx e dx
;*****************************************************************       
getSystemTime proc
    push ax
    
    mov ah, 2CH
    int 21h
    
    pop ax
    ret
getSystemTime endp

;*****************************************************************
; getSystemDate - Gets system date
; descricao: rotine that gets the system date
; input - nada  
; output - Ano, dia e mes
;          cx - ano
;          dh - mes
;          dl - dia
; destroi - cx e dx
;*****************************************************************           
getSystemDate proc
    push ax
    
    mov ah, 2AH
    int 21H
    
    pop ax
    ret
getSystemDate endp

;*****************************************************************
; fcreate - Create file
; description: routine that creates a file 
; input - cx - file attribute
;         dx - file location and name
; output - none
; destroy - bx, dx, ax
;*****************************************************************
fcreate proc
                         
    mov ah, 3ch
    int 21h
    
    jnc NoCreateError
        lea dx, strCreateError
        call printf
        call ErrorHandler
    NoCreateError:
    
    mov bx, ax
    call fclose
            
    ret
fcreate endp

;*****************************************************************
; fopen - Open file
; description: routine that opens a file 
; input - al - open mode (0 - readOnly, 1 - writeOnly, 2 - readWrite, 3 - append(WriteOnly))
;         dx - file location and name
; output - bx - file handler
; destroy - dx, cx, ax
;*****************************************************************
fopen proc
    mov cx, 1
    cmp al, 3
    jne NotAppend1
          
        sub al, 2
        dec cx 
    NotAppend1:
    
    mov ah, 3dh
    int 21h
    
    jnc NoOpenError
        lea dx, strOpenError 
        call printf
        call ErrorHandler
        jmp EndFopen
    NoOpenError:
    
    mov bx, ax
    or cx, cx
    jnz EndFopen
        mov al, 2
        xor dx, dx
        call fseek
                       
    EndFopen:       
    ret
fopen endp

;*****************************************************************
; fseek - seek in file
; description: routine that moves the handler position in file 
; input - al - origin of move (0 - start of file, 1 - current file, 2 - end of file)
;         bx - file handler
;         cx:dx - distance from origin
; output - DX:AX - new handler position (from start of file)
; destroy - dx
;*****************************************************************
fseek proc
    mov ah, 42h
    int 21h
    
    jnc NoSeekError
        lea dx, strSeekError
        call printf
        call ErrorHandler
    NoSeekError:
    ret
fseek endp

;*****************************************************************
; fread - reads from file
; description: routine that reads from a file 
; input - bx, file handle
;         cx, number of bytes to read
;         dx, pointer to where to store the data
; output - dx, data in the position pointed by 
; destroy - dx (maybe)
;*****************************************************************
fread proc
    
    mov ah, 3Fh
    int 21h
    jnc NoReadError
        lea dx, strReadError
        call printf
        call ErrorHandler
    NoReadError:
            
    ret   
fread endp

;*****************************************************************
; fwrite - writes to file
; description: routine that writes to a file 
; input - bx, file handle
;         cx, number of bytes to write
;         dx, pointer to data to write
; output - nothing 
; destroy - dx (maybe)
;*****************************************************************
fwrite proc
        
    mov ah, 40h
    int 21h
    jnc NoWriteError
        lea dx, strWriteError
        call printf
        call ErrorHandler
    NoWriteError:
    
    ret 
fwrite endp

;*****************************************************************
; fclose - close file
; description: routine that closes file
; input - bx - file handler
; output - bx - file handler
; destroy - dx
;*****************************************************************    
fclose proc
    mov ah, 3eh
    int 21h
    
    jnc NoCloseError
        lea dx, strCloseError
        call printf
        call ErrorHandler
    NoCloseError:
    ret
fclose endp

;*****************************************************************
; returnOs - returns to operating system
; descricao: routine that returns control to the opperating system
; input - nada  
; output - nada
; destroi - everything
;*****************************************************************    
returnOs proc
    mov ax, 4c00h
    int 21h
    ret
returnOs endp


  
data segment
MAXSTRSIZE equ 100
GRIDCOLOR equ 27
SQUARECOLOR equ 15
MAXCOLLUM equ 320
MAXLINE equ 200
strHeader db "gen:000 Live Cells:0000 start exit$"
strMenu db "Main  Menu$"
strPlay db "Play$"
strLoad db "Load$"
strTop5 db "Top  5$"
strCredits db "*Credits$"
strExit db "Exit$"
nextGen db 14400 dup(?)
ends


stack segment
dw 128 dup(0)
ends

code segment
start:
mov ax, data
mov ds, ax
mov es, ax

call initGraph

call initMouse

call clickGrid

mov ax,4c00h ; terminate program
int 21h
ends

;*****************************************************************
; checkPixel - Check Pixel
; description: checks if pixel is 'dead' or 'alive'
; input - CX = x coord
;         DX = y coord
; output - color in AL
; destroy - al
;*****************************************************************
checkPixel proc
mov ah, 0Dh
int 10h
ret
checkPixel endp

;*****************************************************************
; storeNextGen - store Next Gen
; description: stores next gen in nextGen
; input - none
; output - next gen in var nextGen
; destroy - ax, bx, cx, dx, si
;*****************************************************************
storeNextGen proc
lea si, nextGen
xor cx, cx
mov dx, 10

storeNextGenLoop1:
xor bx,bx

storeNextGenEnd1:
sub cx, 2
call checkPixel         ;\\\
cmp al, SQUARECOLOR     ;0X\
jne storeNextGenSwich1  ;\\\
inc bx
storeNextGenSwich1:
sub dx, 2
call checkPixel         ;0\\
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich2  ;\\\
inc bx
storeNextGenSwich2:
add cx, 2
call checkPixel         ;\0\
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich3  ;\\\
inc ax
storeNextGenSwich3:
add cx, 2
call checkPixel         ;\\0
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich4  ;\\\
inc bx
storeNextGenSwich4:
add dx, 2
call checkPixel         ;\\\
cmp al, SQUARECOLOR     ;\X0
jne storeNextGenSwich5  ;\\\
inc bx
storeNextGenSwich5:
add dx, 2
call checkPixel         ;\\\
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich6  ;\\0
inc bx
storeNextGenSwich6:
sub cx, 2
call checkPixel         ;\\\
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich7  ;\0\
inc bx
storeNextGenSwich7:
sub cx, 2
call checkPixel         ;\\\
cmp al, SQUARECOLOR     ;\X\
jne storeNextGenSwich8  ;0\\
inc bx
storeNextGenSwich8:
add cx, 2
sub dx, 2

call checkPixel
cmp al, SQUARECOLOR
jne storeNextGenEnd2        ; if dead just check if it can be born

cmp bx, 1
jbe storeNextGenSwich9
mov [si], 0
jmp storeNextGenEnd3  ; if 1 or 0 => kill
storeNextGenSwich9:

cmp bx, 3
jbe storeNextGenSwich10
mov [si], 0
jmp storeNextGenEnd3  ; if 2 or 3 => survive
storeNextGenSwich10:


mov [si], 0             ; more than 3 => kill
jmp storeNextGenEnd3

storeNextGenEnd2:
cmp bx, 3                   ; if 3 => born
jne storeNextGenEnd3
mov [si], 1


storeNextGenEnd3:

inc si
cmp cx, MAXCOLLUM           ; check if end of screen
jbe storeNextGenLoop1
cmp dx, MAXLINE
jbe storeNextGenLoop1

ret
storeNextGen endp

;*****************************************************************
; saveGen - Save Gen
; description: saves current gen
; input - none
; output - current gen in var nextGen
; destroy - si, bx, cx, dx
;*****************************************************************
saveGen proc
lea si, nextGen
xor cx, cx
mov dx, 10
saveGenLoop1:
call checkPixel
mov [si], 1
cmp al, SQUARECOLOR
je saveGenEnd1
mov [si], 0
saveGenEnd1:
add cx, 2
inc si
cmp cx, MAXCOLLUM
jbe saveGenLoop1
xor cx, cx
add dx, 2
cmp dx, MAXLINE
jbe saveGenLoop1
ret
saveGen endp

;*****************************************************************
; getCharFromBuffer - get character form keyboard buffer
; description: rotine that gets a char from the keyboard buffer
; input - nothing
; output - ZF set to 0 if there is a char and retorns it in al
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
; clickGrid - Click Grid
; description:
; input - none
; output - none
; destroy - nothing
;*****************************************************************
clickGrid proc
clickGridLoop1:
call getCharFromBuffer
jz clickGridEnd2
cmp al, 0DH ; check if enter was pressed
jne clickGridEnd2
call storeNextGen
clickGridEnd2:

call getMousePos
cmp dx, 10 ; only do something above line 9
jb clickGridLoop1

cmp bx, 01 ; on left click
jne clickGridLoop1

shr cx, 2
shl cx, 1

shr dx, 1
shl dx, 1

mov bh, SQUARECOLOR
call checkPixel
cmp al, SQUARECOLOR
jne clickGridEnd1
mov bh, 0           ; if already 'SQUARECOLOR' paint black
clickGridEnd1:
mov al, bh
call drawFilledSquare
jmp clickGridLoop1

ret
clickGrid endp

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
;            CX = horizontal position (column)
;            DX = Vertical position (row)
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

clearGraph proc
push ax
mov ah,06
mov al,00
mov BH,00 ; attributes to be used on blanked lines
mov cx,0 ; CH,CL = row,column of upper left corner of window to scroll
mov DH,25 ;= row,column of lower right corner of window
mov DL,40
int 10h
pop ax
ret
clearGraph endp

;*****************************************************************
; drawSquareAuto - draws a square
; descricao:
; input - cx = x start position
;         dx = y start position
; output - square on the screen
; destroi - nothing
;*****************************************************************
drawFilledSquare proc
push bp
mov bp, sp
sub sp, 4
mov [bp - 2], cx ; x final position
mov [bp - 4], dx ; y final position
inc [bp - 2]
inc [bp - 4]

drawFilledSquareLoop1:
call drawPixel
inc cx
cmp cx, [bp - 2]
jbe drawFilledSquareLoop1
sub cx, 2
inc dx
cmp dx, [bp - 4]
jbe drawFilledSquareLoop1

add sp, 4
pop bp
ret
drawFilledSquare endp

;*****************************************************************
; drawPixel - draws a pixel
; descricao:
; input - AL = pixel color
;         CX = column
;         DX = row
; output - pixel on the screen
; destroi - ah
;*****************************************************************
drawPixel proc
mov ah, 0Ch
int 10h
ret
drawPixel endp

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

;*****************************************************************
; drawLine - draws a line
; description: draws a line does put 'cursor' in next line
; input - none
; output - line on the screen
; destroy - nada
;*****************************************************************
drawLine proc
mov al, GRIDCOLOR
drawLineLoop1:
call drawPixel ; draws the line
inc cx
cmp cx, MAXCOLLUM
jne drawLineLoop1
xor cx, cx
ret
drawLine endp

;*****************************************************************
; paint2PixelsX - draws two pixels of a squar on screen
; descricao: rotina que desenha dois pixeis da borda do quadrado
; input - posicao inicial do quadrado e posicao final do quadrado
;         push 1 - cor do quadrado
;         push 2 - posicao nao estatica inicial
;         push 3 - posicao estatica inicial
;         push 4 - posicao nao estatica final
;         push 5 - posicao estatica final
;         push 6 - di (incremento do sentido)   
; output - nenhum
; destroi - cx
;*****************************************************************    
paint2PixelsX proc
    push bp
    mov bp, sp
    add bp, 2
    
    mov al, [bp + 12] ; faz load da cor do quadrado para o al
    
    mov cx, [bp + 10] ; move x1 para cx
    add cx, [bp + 2]  ; soma x1 com delta x
    
    cmp cx, [bp + 6]  ; compara x2 com xi            
    ja skipPaint2PX
    
    mov dx, [bp + 8]  ; mov da posicao y onde desenhar o pixel para dx
    call drawPixel
    
    mov cx, [bp + 6] ; move x2 para cx
    sub cx, [bp + 2] ; subtracao de x2 com delta x
    
    mov dx, [bp + 4] ; mov da posicao y onde desenhar o pixel para dx
    call drawPixel
    
    skipPaint2PX:
    pop bp
    ret 12
paint2PixelsX endp

;*****************************************************************
; paint2PixelsY - draws two pixels of a squar on screen
; descricao: rotina que desenha dois pixeis da borda do quadrado
; input - posicao inicial do quadrado e posicao final do quadrado
;         push 1 - cor do quadrado
;         push 2 - posicao nao estatica inicial
;         push 3 - posicao estatica inicial
;         push 4 - posicao nao estatica final
;         push 5 - posicao estatica final
;         push 6 - di (incremento do sentido)   
; output - nenhum
; destroi - cx
;*****************************************************************    
paint2PixelsY proc
    push bp
    mov bp, sp
    add bp, 2
    
    mov al, [bp + 12] ; move da cor do quadrado para al
    
    mov dx, [bp + 10] ; move y1 para dx
    add dx, [bp + 2]  ; soma y1 com delta y
    
    cmp dx, [bp + 6]  ; compara y2 com yi            
    ja skipPaint2PY
    
    mov cx, [bp + 8]  ; mov da posicao x onde desenhar o pixel para cx
    call drawPixel
    
    mov dx, [bp + 6]  ; move x2 para cx
    sub dx, [bp + 2]  ; subtracao de x2 com delta x
    
    mov cx, [bp + 4]  ; mov da posicao x onde desenhar o pixel para cx                
    call drawPixel
    
    skipPaint2PY:
    pop bp
    ret 12
paint2PixelsY endp

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

;*****************************************************************
; waitOrInput - wait 10 seconds or for user inpur
; descricao: rotine waits 10 seconds before ending or waits for user input instead
; input - nada  
; output - nada
; destroi - bx, dx
;*****************************************************************    
waitOrInput proc
    
    call getSystemTime
    mov bh, dh
    
    waitOrInputLoop:
    
        call getSystemTime
    
        sub dh, bh
        cmp dh, 10
        jae endWaitOrInputLoop
        
        call getCharFromBuffer
        jnz endWaitOrInputLoop
    
    jmp waitOrInputLoop
    endWaitOrInputLoop:
    
    ret
waitOrInput endp



;*****************************************************************
; drawGrid - draws the grid (320X200)px
; descricao: 
; input - none
; output - square on the screen
; destroi - nada
;*****************************************************************
drawGrid proc
    mov dh, 0
    mov dl, 3
    mov bl, 0
    call setCursorPosition
    
    push offset strHeader
    call printf
    
    mov al, GRIDCOLOR
    mov cx, 0  ;x position
    mov dx, 10 ;y position
    
    drawGridLoop1:
        
        call drawLine    
        call drawCollum   
        drawGridEnd1:
        cmp dx, 200
        jne drawGridLoop1
    
    ret 
drawGrid endp

;*****************************************************************
; printSquare - draws a square on screen
; descricao: rotina que desenha as bordas de um quadrado para o ecra em modo grafico
; input - posicao inicial do quadrado e posicao final do quadrado
;         push 1 - cor do quadrado
;         push 2 - posicao x inicial
;         push 3 - posicao y inicial
;         push 4 - posicao x final
;         push 5 - posicao y final   
; output - nenhum
; destroi - cx
;*****************************************************************
paintSquare proc
    push bp
    mov bp, sp
    
    ; inicializar variaveis locais a 0
    push 0
    push 0  
    
    paintSquareLoop:
        mov cx, [bp + 8]  ; move y1 para cx
        add cx, [bp - 4]  ; soma y1 com delta y
        
        cmp cx, [bp + 4]  ; compare cx com y2
        
        jbe NotSkip
            mov cx, [bp + 10] ; move x1 para cx
            add cx, [bp - 2]  ; soma x1 com delta x
            
            cmp cx, [bp + 6]  ; compara cx com x2
            
            jb NotSkip                
                jmp endPaintSquareLoop
        NotSkip:
                                        ; push cor do quadrado para usar em paint
            push [bp + 12]              ; posicao nao estatica inicial
            push [bp + 10]              ; posicao estatica inicial
            push [bp + 8]               ; posicao nao estatica final
            push [bp + 6]               ; posicao estatica final
            push [bp + 4]               ; incremento do sentido
            push [bp - 2]
            call paint2PixelsX
        
            push [bp + 12]              ; push cor do quadrado para usar em paint
            push [bp + 8]               ; posicao nao estatica inicial
            push [bp + 10]              ; posicao estatica inicial
            push [bp + 4]               ; posicao nao estatica final
            push [bp + 6]               ; posicao estatica final
            push [bp - 4]               ; incremento do sentido
            call paint2PixelsY  
    
            inc [bp - 2]
            inc [bp - 4]
                    
        jmp paintSquareLoop
    endPaintSquareLoop:
    
    add sp, 4
    pop bp
    ret 10
paintSquare endp

;*****************************************************************
; ErrorHandler - Handles Errors
; description: routine handles file errors
; input - nada
; output - nada
; destroy - dl
;*****************************************************************
ErrorHandler proc
    push dx
    xor dl, dl
    
    cmp ax, 1
    jne skipError1
        lea dx, strInvFunc
        inc dl
    skipError1:
    
    cmp ax, 2h
    jne skipError2:
        lea dx, strNoFile
        inc dl
    skipError2:
    
    cmp ax, 3h
    jne skipError3:
        lea dx, strNoPath
        inc dl
    skipError3:
    
    cmp ax, 4h
    jne skipError4:
        lea dx, strHandleBusy
        inc dl
    skipError4:
    
    cmp ax, 5h
    jne skipError5:
        lea dx, strNoAccess
        inc dl
    skipError5:
    
    cmp ax, 6h
    jne skipError6:
        lea dx, strNoHandle
        inc dl            
    skipError6:
    
    cmp ax, 0Ch
    jne skipError7:
        lea dx, strNoAccessCode
        inc dl
    skipError7:
        
    cmp ax, 0Fh
    jne skipError8:
        lea dx, strNoDrive
        inc dl
    skipError8:
    
    cmp ax, 10h
    jne skipError9:
        lea dx, strRemoveDir
        inc dl
    skipError9:
    
    cmp ax, 11h
    jne skipError10:
        lea dx, strNoDevice
        inc dl
    skipError10:
    
    cmp ax, 12h
    jne skipError11:
        lea dx, strNoFiles
        inc dl
    skipError11:
    
    or dl, dl
    jnz skipError12
        lea dx, strNoError
    skipError12:
            
    call printf 
    
    pop dx     
    ret
ErrorHandler endp

;*****************************************************************
; printfNum - put number in a string
; descricao: routine that converts a number to a string
; input - SI = start of string
;         AX = number to be printed
; output - nenhum
; destroi - cx, dx, ax
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
        
        
        strToIntLoop2:
            
            pop dx
            mov [si], dl
            inc si
            
        loop strToIntLoop2
        
        pop bx
        ret
strToInt endp

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
; constructButtonCenterX - Buttons on the center of the x position
; descricao: creates a button on the center of the screen in the x position
; input - center of the button on the y position and color
;         push 1 - color of the square
;         push 2 - center of y position  
; output - codigo ascii da tecla pressionada em al
; destroi - ax
;*****************************************************************    
constructButtonCenterX proc
    push bp
    mov bp, sp
    add bp, 2
    
    mov dx, [bp + 2] ; move of the center of y position to ax
    sub dx, 8
    
    push [bp + 4]   ; push da cor a ser usada para pintar o quadrado
    
    xor ah, ah
    mov ax, 125
    push ax         ; push da posicao x1 do quadrado
    
    push dx         ; push da posicao y1 do quadrado
    
    add dx, 16
    
    xor ah, ah
    mov ax, 195     ; push da posicao x2 do quadrado
    push ax
    
    push dx         ; push da posicao y2 do quadrado
     
    call paintSquare
    
    pop bp
    ret 4
constructButtonCenterX endp

;*****************************************************************
; paintMenuSqrs - Paint Menu squares
; descricao: Paints the squares that are on the main menu to their propper position 
; input - nada   
; output - nada
; destroy - nada
;*****************************************************************
paintMenuSqrs proc
    push ax
    
    push SQUARECOLOR        ; push square color
    push 43                 ; push center of y coordinate
    call constructButtonCenterX
    
    push SQUARECOLOR        ; push square color
    push 67                 ; push center of y coordinate
    call constructButtonCenterX
                    
    push SQUARECOLOR        ; push square color
    push 91                 ; push center of y coordinate
    call constructButtonCenterX
    
    push SQUARECOLOR        ; push square color
    push 115                ; push center of y coordinate
    call constructButtonCenterX
    
    push SQUARECOLOR        ; push square color
    xor ah, ah
    mov ax, 139
    push ax                 ; push center of y coordinate
    call constructButtonCenterX
    
    push SQUARECOLOR        ; push square color
    xor ah, ah
    mov ax, 163
    push ax                 ; push center of y coordinate
    call constructButtonCenterX
    
    pop ax
    ret
paintMenuSqrs endp

;*****************************************************************
; printMenuStr - Print Menu strings
; descricao: Prints the strings that are on the main menu to their propper position 
; input - nada   
; output - nada
; destroy - bx, dx
;*****************************************************************
printMenuStr proc
    
    xor bh, bh
    mov dh, 1
    mov dl, 15
    call setCursorPosition
    
    lea dx, strMenu
    call printf
    
    mov dh, 5
    mov dl, 18
    call setCursorPosition
    
    lea dx, strPlay
    call printf
    
    mov dh, 8
    mov dl, 18
    call setCursorPosition
    
    lea dx, strLoad
    call printf
    
    mov dh, 11
    mov dl, 18
    call setCursorPosition
    
    lea dx, strSave
    call printf
    
    mov dh, 14
    mov dl, 17
    call setCursorPosition
    
    lea dx, strTop5
    call printf
    
    mov dh, 17
    mov dl, 16
    call setCursorPosition
    
    lea dx, strCredits
    call printf
    
    mov dh, 20
    mov dl, 18
    call setCursorPosition
    
    lea dx, strExit
    call printf
    
    ret
printMenuStr endp

;*****************************************************************
; copyToStr - copies a string into another
; descricao: copy an entire string onto a part of another
; input - si = start of string to copy (must end with 0)
;         di = where to start copying to in destination string (lea of string if beggining lea of string + 3 if 3 bytes after the beggining of string)
; output - nenhum
; destroi - dl, di 
;*****************************************************************
copyToStr proc
    push si
    
    copyToStrLoop:
    
        mov dl, [si]
        or dl, dl
        jz copyToStrEndLoop
        
        mov [di], dl
        inc di
        inc si
        
        jmp copyToStrLoop
    copyToStrEndLoop: 
    
    pop si
    ret    
copyToStr endp

;*****************************************************************
; clearString - clears part of a string
; descricao:
; input - si = where to start clearing the string 
;         cx = number of bytes to clear from string
; output - nenhum
; destroi - cx 
;*****************************************************************
clearString proc
    push si
    
    clearStringLoop:
        
        mov [si], 0
        inc si
        
    loop clearStringLoop
    
    pop si  
    ret 
clearString endp

;*****************************************************************
; strLen - Length of string
; descricao: routine that determines the length of a string
; input - si, start of string (must end in 0)
; output - cx, length of string
; destroi - si, cx 
;*****************************************************************
strLen proc
    push si
    xor cx, cx       
           
    strLenLoop:
        inc cx
        inc si
        
        cmp [si], 0
        je strLenEndLoop
        
        jmp strLenLoop
    strLenEndLoop:
    
    pop si
    ret
strLen endp

;*****************************************************************
; shiftStrRight - shift string to the right
; descricao: routine that shifts every character in the string on byte to the right
; input - si, start of the string
;         cx, length of the string
; output - nenhum
; destroi - cx, dl 
;*****************************************************************       
shiftStrRight proc
    
    add si, cx
    
    shiftStrRightLoop:
    
        mov dl, [si - 1]
        mov [si], dl
        dec si    
    
    loop shiftStrRightLoop
     
    ret
shiftStrRight endp

;*****************************************************************
; assertStrLen - Assert string length
; descricao: routine that checks if the string has the desired length, if not adds zeros to the beggining of it until it does
; input - si, start of the string 
;         cx, lenght of string
;         bx, desired length of the string 
; output - nenhum
; destroi - si, cx 
;*****************************************************************
assertStrLen proc
    push si
    
    cmp cx, bx
    jnb skipAssert
        xchg cx, bx
        sub cx, bx
        
        AssertionLoop:
            push cx
            mov cx, bx
            call shiftStrRight
            pop cx
            mov [si], '0'
            inc si
            
        loop AssertionLoop
    skipAssert:
    
    pop si
    ret
assertStrLen endp

;*****************************************************************
; processIntStr - Process string of intergers
; descricao: routine that transforms a number to a string and processes it
; input - si, start of the temporary string to process the number to convert
;         di, place of destination string to paste
;         bx, desired length of the string to copy
;         ax, number to convert to string 
; output - nenhum
; destroi - cx 
;*****************************************************************
processIntStr proc
    
    push si
    call strToInt
    pop si
    
    call strLen
    cmp cx, bx
        
    jnb pushReal
    push bx 
    jmp pushBX
    
    pushReal:
    push cx
    pushBX:
    
    call assertStrLen
    call copyToStr
    
    pop cx    
    call clearString
    ret
    
processIntStr endp

;*****************************************************************
; insertDateInStr - Insert date in a string
; descricao: routine that inserts current date in string
; input - si, start of string to inster in
; output - di, current position in input string after insertion
; destroi - ax, bx, cx, dx, si, di 
;*****************************************************************
insertDateInStr proc
    
    call getSystemDate
    push dx
    push dx    
    
    mov ax, cx
    call strToInt
    
    mov di, si
    
    pop dx
    xor ah, ah
    mov al, dh
    
    lea si, strTemp
    mov bx, 2
    call processIntStr
    
    pop ax
    xor ah, ah
    mov bx, 2  
    call processIntStr
    
    ret
insertDateInStr endp

;*****************************************************************
; insertTimeInStr - Insert time in a string
; descricao: routine that inserts current time in string
; input - di, place of string to inster in
; output - di, current position in input string after insertion
; destroi - cx, di, dx, ax, bx 
;*****************************************************************
insertTimeInStr proc
    
    call getSystemTime
    push dx
    push cx
    
    mov al, ch
    mov bx, 2    
    call processIntStr
    
    pop ax
    xor ah, ah
    mov bx, 2    
    call processIntStr
    
    pop dx
    mov al, dh
    mov bx, 2     
    call processIntStr
    
    ret
insertTimeInStr endp

;*****************************************************************
; buildLogStr - Build string for the logs
; descricao: routine that Builds strings for the log file
; input - nothing
; output - di, end of Log string
; destroi - si, cx, di, dx, ax, bx 
;*****************************************************************
buildLogStr proc
    
    lea si, strLog
    call insertDateInStr
    
    inc di
    
    call insertTimeInStr
    
    inc di
    push si
    
    lea si, strPlayerName
    call copyToStr
    
    mov [di], ':'
    inc di
    
    pop si
    mov ax, genNum
    mov bx, 3
    call processIntStr
    
    mov [di], ':'
    inc di
    
    mov ax, cellNum
    mov bx, 4
    call processIntStr
    
    mov [di], 0DH
    inc di
    
    mov [di], 0AH
    inc di
    
    mov [di], 0
    ret
buildLogStr endp

;*****************************************************************
; writeLog - writes a log entry
; description: routine that writes a log entry 
; input - nothing
; output - nothing 
; destroy - ax, bx, cx, dx, si, di
;*****************************************************************  
writeLog proc
    
    lea dx, logFile
    mov al, 3
    call fopen
    
    push bx
    call buildLogStr
    pop bx          
              
    lea cx, strLog      ; determines the size of the Log string by checking
    mov dx, cx          ; the last position it was written to and subbing
    xchg cx, di         ; the first position of the Log string in memory
    sub cx, di          ; and writes that string to log file
    call fwrite         
    
    call fclose
    
    ret
writeLog endp

;*****************************************************************
; gamePlay - sets up the game
; descricao: rotine that sets up the game
; input - nada  
; output - nada
; destroi - ax, bx, cx, dx, si, di
;*****************************************************************
initGamePlay proc
    
    call initgraph
    
    xor bx, bx
    mov dx, 0
    call setCursorPosition
    
    lea dx, strGetPlayerName
    call printf
    
    lea di, strPlayerName
    call scanf
    
    ;insert call to game here
    
    call writeLog
    
    ret
initGamePlay endp    

;*****************************************************************
; rollCredits - roll credits
; descricao: rotine that "rolls" the credits
; input - nada  
; output - nada
; destroi - dx, bx
;*****************************************************************
rollCredits proc
    push ax
    
    call initGraph
    
    xor bh, bh
    mov dh, 11
    mov dl, 6
    call setCursorPosition
    
    lea dx, strDiogo
    call printf
    
    mov dh, 13
    mov dl, 4
    call setCursorPosition
    
    lea dx, strFilipe
    call printf
    
    call waitOrInput
    
    pop ax
    ret
rollCredits endp

;*****************************************************************
; clickMenu - Click main menu
; descricao: Implements the buttons for the main menu 
; input - dx   
; output - nada
; destroy - dx, bx
;*****************************************************************
clickMenu proc
    xor ah, ah          
    
    cmp dx, 35
    jbe skipButton1
    cmp dx, 51
    jae skipButton1
    
    call gamePlay
    ret
    skipButton1:
    
    cmp dx, 59
    jbe skipButton2
    cmp dx, 75
    jae skipButton2
              
    ret       
    skipButton2:
    
    cmp dx, 83
    jbe skipButton3
    cmp dx, 99
    jae skipButton3
              
    ret       
    skipButton3:
    
    cmp dx, 107
    jbe skipButton4
    cmp dx, 123
    jae skipButton4
         
    ret             
    skipButton4:
    
    cmp dx, 131
    jbe skipButton5
    cmp dx, 147
    jae skipButton5
    
    call rollCredits
    ret
    skipButton5:
             
    cmp dx, 155
    jbe skipButton6
    cmp dx, 171
    jae skipButton6
    
    call returnOs
    ret
    skipButton6:
    
    inc ah
    ret
clickMenu endp

;*****************************************************************
; stratMenu - Game main menu
; descricao: Creates and opens the main menu 
; input - nada   
; output - ah
; destroy - dx, bx
;*****************************************************************     
startMenu proc
    
    call printMenuStr
    
    call paintMenuSqrs           ; os quadrados tem todos a mesma posicao inicial e final no eixo dos x
    
    startLoop:
        
        call getMousePos
        shr cx, 1
         
        cmp bl, 1
        jne skipButtons      
            mov ah, 1
            
            cmp cx, 119          ; como os quadrados tem todos a mesma posicao no eixo x
            jbe skipButtons      ; so e preciso verificar 1 vez se estamos no sitio certo para clicar nos
            cmp cx, 199          ; quadrados antes de verificar o quadrado que estamos a clicar
            jae skipButtons
            
            call clickMenu
            
            or ah, ah
            jz endStartLoop
             
        skipButtons:        
        jmp startLoop
    endStartLoop:
    
    ret
startMenu endp
  
end start ; set entry point and stop the assembler.
