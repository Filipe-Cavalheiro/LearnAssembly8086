data segment
    MAXSTRSIZE equ 100      
    GRIDCOLOR equ 27
    SQUARECOLOR equ 15 
    strHeader db "gen:000 Live Cells:0000 start exit$"
    strMenu db "Main  Menu$"
    strPlay db "Play$"
    strLoad db "Load$"
    strTop5 db "Top  5$"
    strCredits db "*Credits$"
    strExit db "Exit$"
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
    
    call startMenu
             
    call clearGraph
        
    call drawGrid
        
    mov ah, 1 ; press any key
    int 21h
    
mov ax,4c00h ; terminate program
int 21h
ends   

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
    cmp cx, 320 
    jne drawLineLoop1
    xor cx, cx
    inc dx
    ret
drawLine endp

;*****************************************************************
; drawColum - draws the collum
; description: draws collum does put 'cursor' on the next line
; input - none
; output - collum on the screen
; destroy - nada
;*****************************************************************
drawCollum proc
    
    drawCollumLoop2:
    drawCollumLoop1:
    mov al, GRIDCOLOR
    call drawPixel ; draws the line
    add cx, 10
    cmp cx, 320 
    jb drawCollumLoop1
    xor cx, cx ;put on the start of the next line
    inc dx
    mov ax, dx
    mov bl, 10
    div bl
    cmp ah, 0
    jne drawCollumLoop2 
     
    ret
drawCollum endp

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
        ;mov ax, dx
        ;mov bl, 10
        ;div bl
        ;or ah,ah
        ;jz drawGridEnd1 ; draw collum if dx%10 != 0
        call drawCollum   
        drawGridEnd1:
        cmp dx, 200
        jne drawGridLoop1
    
    ret 
drawGrid endp

;*****************************************************************
; drawSquareAuto - draws a square
; descricao: 
; input - xI = x coord of start
;         yI = y coord of start
;         xF = x coord of end
;         yF = y coord of end 
;         al = color [0, 255]
; output - square on the screen
; destroi - nada
;*****************************************************************
drawFilledSquare proc
    mov al, SQUARECOLOR
    mov cx, xI
    mov dx, yI
    
    drawFilledSquareLoop2:
    drawFilledSquareLoop1:
    call drawPixel
    inc cx
    cmp cx, xF 
    jne drawFilledSquareLoop1 
    mov cx, xI
    inc dx
    cmp dx, yF
    jne drawFilledSquareLoop2 
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
; stratMenu - Game main menu
; descricao: Creates and opens the main menu 
; input - nada   
; output - nada
; destroy - ax, dx
;*****************************************************************     
startMenu proc

    call initGraph
    
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
    
    mov dh, 9
    mov dl, 18
    call setCursorPosition
    
    lea dx, strLoad
    call printf
    
    mov dh, 13
    mov dl, 17
    call setCursorPosition
    
    lea dx, strTop5
    call printf
    
    mov dh, 17
    mov dl, 16
    call setCursorPosition
    
    lea dx, strCredits
    call printf
    
    mov dh, 21
    mov dl, 18
    call setCursorPosition
    
    lea dx, strExit
    call printf
    
    xor bh, bh
    call getCursorSizePosition
    
    push 30         ; push square color
    push 43         ; push center of y coordinate
    call constructButtonCenterX
    
    push 30         ; push square color
    push 75         ; push center of y coordinate
    call constructButtonCenterX
                    
    push 30         ; push square color
    xor ah, ah
    mov ax, 107
    push ax        ; push center of y coordinate
    call constructButtonCenterX
    
    push 30         ; push square color
    xor ah, ah
    mov ax, 139
    push ax        ; push center of y coordinate
    call constructButtonCenterX
    
    push 30         ; push square color
    xor ah, ah
    mov ax, 171
    push ax        ; push center of y coordinate
    call constructButtonCenterX
    
    startLoop:
        
        call ci
        cmp al, 0dh
        je endLoop
        
        jmp startLoop
    endLoop:
    
    ret
startMenu endp    

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
        sub dx, 10
        
        push [bp + 4]   ; push da cor a ser usada para pintar o quadrado
        
        xor ah, ah
        mov ax, 119
        push ax         ; push da posicao x1 do quadrado
        
        push dx         ; push da posicao y1 do quadrado
        
        add dx, 20
        
        xor ah, ah
        mov ax, 199     ; push da posicao x2 do quadrado
        push ax
        
        push dx         ; push da posicao y2 do quadrado
         
        call paintSquare
        
        pop bp
        ret 4
    constructButtonCenterX endp
    
;*****************************************************************
; ci - input character
; descricao: Le um input do utilizador
; input - nada   
; output - codigo ascii da tecla pressionada em al
; destroi - ax
;*****************************************************************    
    ci proc
        
        mov ah, 7
        int 21h
        
        ret    
    ci endp
    
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
            
            jb NotSkip
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
; getSystemDateTime - Gets system date and time
; descricao: rotine that gets the system date and time
; input - nada  
; output - Hora, minuto, dia e mes
;          ch - hora
;          cl - minuto
;          dh - mes
;          dl - dia
; destroi - cx e dx
;*****************************************************************     
    getSystemDateTime proc
        call getSystemTime
        
        push cx
        call getSystemDate
        pop cx
        
        ret
    getSystemDateTime endp
    
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
        int 21H
        
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
  
end start
