data segment
    MAXSTRSIZE equ 100      
    GRIDCOLOR equ 27
    SQUARECOLOR equ 15 
    strHeader db "gen:000 Live Cells:0000 start exit$"
    strMenu db "Main  Menu$"
    strPlay db "Play$"
    strLoad db "Load$"
    strSave db "Save$"
    strTop5 db "Top  5$"
    strCredits db "*Credits$"
    strExit db "Exit$"
    strDiogo db "Diogo Matos Novais  n", 0A7h, " 62506$"
    strFilipe db "Filipe Silva Cavalheiro n", 0A7h, " 62894$"
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
; clickGrid - Click Grid
; description: Draws a 2X2 square where you click 
; input - none
; output - none
; destroy - nothing
;*****************************************************************
clickGrid proc
    clickGridLoop1:
        call getMousePos
        cmp bx, 02 ; on right click leave proc
        je clickGridEnd1
    
    cmp bx, 01 ; on left click
    jne clickGridLoop1
        cmp dx, 10
        jb clickGridLoop1
        
        shr cx, 2
        shl cx, 1
        
        shr dx, 1
        shl dx, 1
        
        mov al, SQUARECOLOR
        call drawFilledSquare        
    jmp clickGridLoop1
          
    clickGridEnd1:
    ret
clickGrid endp

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
    
    call endProgram
    ret
    skipButton6:
    
    inc ah
    ret
clickMenu endp

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
; paintMenuSqrs - Paint Menu squares
; descricao: Paints the squares that are on the main menu to their propper position 
; input - nada   
; output - nada
; destroy - nada
;*****************************************************************
paintMenuSqrs proc
    push ax
    
    push 30         ; push square color
    push 43         ; push center of y coordinate
    call constructButtonCenterX
    
    push 30         ; push square color
    push 67         ; push center of y coordinate
    call constructButtonCenterX
                    
    push 30         ; push square color
    push 91         ; push center of y coordinate
    call constructButtonCenterX
    
    push 30         ; push square color
    push 115         ; push center of y coordinate
    call constructButtonCenterX
    
    push 30         ; push square color
    xor ah, ah
    mov ax, 139
    push ax        ; push center of y coordinate
    call constructButtonCenterX
    
    push 30         ; push square color
    xor ah, ah
    mov ax, 163
    push ax        ; push center of y coordinate
    call constructButtonCenterX
    
    pop ax
    ret
paintMenuSqrs endp

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
; endProgram - End program
; descricao: rotine that returns control to the opperating system
; input - nada  
; output - nada
; destroi - everything
;*****************************************************************    
endProgram proc
    mov ax, 4c00h
    int 21h
    ret
endProgram endp

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
        
        
        strToIntLoop2:
            
            pop dx
            mov [si], dl
            inc si
            
        loop strToIntLoop2
        
        mov [si], 0
        pop bx
        ret
strToInt endp

;*****************************************************************
; copyToStr - copies a string into another
; descricao: copy an entire string onto a part of another
; input - si = start of string to copy (must end with 0)
;         di = where to satart copying to in destination string (lea of string if beggining lea of string + 3 if 3 bytes after the beggining of string)
; output - nenhum
; destroi - dl, si, di 
;*****************************************************************
copyToStr proc
    
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
; clearString - clears part of a string
; descricao:
; input - si = where to start clearing the string 
;         cx = number of bytes to clear from string
; output - nenhum
; destroi - si, cx 
;*****************************************************************
clearString proc
    
    clearStringLoop:
        
        mov [si], 0
        inc si
        
    loop clearStringLoop
      
    ret 
clearString endp
  
end start
