data segment
    MAXPLAYERNAME equ 11
    MAXLOGSTRSIZE equ MAXPLAYERNAME + 26
    MAXBUFFERSIZE equ (MAXLOGSTRSIZE * 4) + 2      
    GRIDCOLOR equ 27
    SQUARECOLOR equ 15
    logFile db "C:\ConwayGame\Log.txt", 0        
    TopFile db "C:\ConwayGame\Top5.txt", 0
    FilesPath db "C:\ConwayGame\", 0
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
    strTop5Screen db "Gen Cells   Player   Date    Time$"
    strGetPlayerName db "Enter username: $"
    strDiogo db "Diogo Matos Novais  n", 0A7h, " 62506$"
    strFilipe db "Filipe Silva Cavalheiro n", 0A7h, " 62894$"
    strLog db MAXLOGSTRSIZE dup(0) 
    strPlayerName db MAXPLAYERNAME dup(0)
    strTemp db MAXBUFFERSIZE dup(0)
    genNum dw 137
    cellNum dw 167

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
    call initGamePlay     
    
    ;call initGraph
    ;call initMouse
    ;call showMouseCursor
    
    ;loop1:
    ;    call showMouseCursor
    ;    call startMenu
    ;    call clearGraph
    ;jmp loop1
    
    mov ax,4c00h ; terminate program
    int 21h
ends


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
; destroy - ax
;*****************************************************************
initMouse proc
    xor ax, ax
    int 33h 
    ret
initMouse endp

;*****************************************************************
; showMouseCursor - show mouse cursor
; description: shows the mouse cursor on screen 
; input - none
; output - none
; destroy - ax
;*****************************************************************
showMouseCursor proc
    mov ax, 01
    int 33h 
    ret
showMouseCursor endp

;*****************************************************************
; hideMouseCursor - show mouse cursor
; description: shows the mouse cursor on screen 
; input - none
; output - none
; destroy - ax
;*****************************************************************
hideMouseCursor proc
    mov ax, 01
    int 33h 
    ret
hideMouseCursor endp

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
    mov ah,02H
    mov dl,al
    int 21H
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
; createDir - Create directory
; description: routine that creates a directory 
; input - dx - file location and name
; output - none
; destroy - bx, dx, ax
;*****************************************************************
createDir proc
    
    mov ah, 39h
    int 21h
   
    ret
createDir endp


;*****************************************************************
; fopen - Open file
; description: routine that opens a file 
; input - al - open mode (0 - readOnly, 1 - writeOnly, 2 - readWrite, 3 - append(WriteOnly))
;         dx - file location and name
; output - bx - file handler or jc if error and ax, error code
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
        
        ret
        
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
; output - nada
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
; scanf - string input
; descricao: rotina que faz o input de uma string ate o char ENTER
; input - DI = deslocamento da string a escrever desde o inicio do segmento de dados
;         cx, numero maximo de characteres a receber + 1
; output - string
; destroi - ax, cx, dx, di
;*****************************************************************
scanf proc
    
    mov bx, cx
    
    ScanLoop:
        or cx, cx
        jz endScan
    
        call getCharFromBuffer
        jz ScanLoop
        
        cmp al, 1BH
        STC
        je endScan
        CLC
        
        cmp al, 0Dh
        je endScan
        
        cmp al, 08H
        jne NotBackSpace
        cmp bx, cx
        je ScanLoop
            push cx
            call getCursorSizePosition
            pop cx
            
            dec dl
            push dx
            call setCursorPosition
            
            mov al, 32
            call co
            pop dx
            call setCursorPosition
            
            dec di
            mov [di], 0
            inc cx
            
            jmp ScanLoop
        NotBackSpace:
        
        cmp cx, 1
        je ScanLoop
        
        call co
        
        mov [di], al
        inc di
        dec cx
        
        jmp ScanLoop
    endScan:
    
    mov [di], 0
    ret
scanf endp

;*****************************************************************
; fReadLine - read a line from file
; descricao: rotine that reads a full line from file
; input - bx, file handler to read
;         dx, string to sotre line  
; output - ax, number of bytes read
;          strTemp, string read
;          carry flag if end of file
; destroi - dx, cx, si
;*****************************************************************
fReadLine proc
    push bp
    mov bp, sp
    push 0 ; iniciar variavel local a 0
    
    ReadLineLoop:
        inc [bp - 2]
        xor cx, cx
        inc cx
        
        call fread
        
        mov si, dx
        
        cmp [si], 0H
        jne checkReadEnter
            STC
            jmp ReadLineEndLoop
                
        checkReadEnter:
        cmp [si], 0AH
        je ReadLineEndLoop
        inc dx
        
        jmp ReadLineLoop
    ReadLineEndLoop:
    
    mov [si], 0
    pop ax
    pop bp
    ret
fReadLine endp

;*****************************************************************
; fWriteLine - write a line to file
; descricao: rotine that writes a full line to a file
; input - bx, file handler to read
;         dx, string to write  
; output - strTemp, string read
;          carry flag if end of file
; destroi - cx, di, dx
;*****************************************************************
fWriteLine proc
    
    WriteLineLoop:
        xor cx, cx
        inc cx
        
        mov di, dx
        cmp [di], 0
        je WriteLineEndLoop
        cmp [di], 0DH
        je WriteLineEndLoop
        
        call fwrite
        
        inc dx        
        jmp WriteLineLoop
    WriteLineEndLoop:
    
    push dx
    lea dx, strTemp
    mov di, dx
    mov [di], 0DH
    mov [di+1], 0AH
    mov cx, 2
    call fwrite
    
    mov cx, 2
    call clearString
    
    pop dx
    
    ret
fWriteLine endp

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
    push bx
    xor bx, bx
    
    cmp ax, 1
    jne skipError1
        lea dx, strInvFunc
        inc bl
    skipError1:
    
    cmp ax, 2h
    jne skipError2:
        lea dx, strNoFile
        inc bl
    skipError2:
    
    cmp ax, 3h
    jne skipError3:
        lea dx, strNoPath
        inc bl
    skipError3:
    
    cmp ax, 4h
    jne skipError4:
        lea dx, strHandleBusy
        inc bl
    skipError4:
    
    cmp ax, 5h
    jne skipError5:
        lea dx, strNoAccess
        inc bl
    skipError5:
    
    cmp ax, 6h
    jne skipError6:
        lea dx, strNoHandle
        inc bl            
    skipError6:
    
    cmp ax, 0Ch
    jne skipError7:
        lea dx, strNoAccessCode
        inc bl
    skipError7:
        
    cmp ax, 0Fh
    jne skipError8:
        lea dx, strNoDrive
        inc bl
    skipError8:
    
    cmp ax, 10h
    jne skipError9:
        lea dx, strRemoveDir
        inc bl
    skipError9:
    
    cmp ax, 11h
    jne skipError10:
        lea dx, strNoDevice
        inc bl
    skipError10:
    
    cmp ax, 12h
    jne skipError11:
        lea dx, strNoFiles
        inc bl
    skipError11:
    
    or bl, bl
    jnz skipError12
        lea dx, strNoError
    skipError12:
            
    call printf 
    
    pop bx          
    ret
ErrorHandler endp

;*****************************************************************
; numToStr - put number in a string
; descricao: routine that converts a number to a string
; input - SI = start of string
;         AX = number to be printed
; output - nenhum
; destroi - cx, dx, ax
;*****************************************************************
numToStr proc
    push bx
    
    xor cx, cx
    mov bx, 10
    
    numToStrLoop1:
        
        inc cx
        xor dx, dx
        
        div bx
        add dx, 30h
        push dx
        
        or ax, ax
        jz numToStrEndLoop1
    
        jmp numToStrLoop1
    numToStrEndLoop1:
    
    
    numToStrLoop2:
        
        pop dx
        mov [si], dl
        inc si
        
    loop numToStrLoop2
    
    pop bx
    ret
numToStr endp

;*****************************************************************
; strToNum - put number in a string
; descricao: routine that converts a string to a number
; input - SI = start of string to conver
;         cx = number of bytes to convert
; output - AX, converted number
; destroi - ax, bx, 
;*****************************************************************
strToNum proc
    push bx
    
    xor ax, ax
    mov bx, 10
    
    strToNumLoop:
        mul bx
        
        mov dx, [si]
        sub dx, 30h
        xor dh, dh
        
        add ax, dx
        inc si
    loop strToNumLoop
    
    pop bx
    ret
strToNum endp

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
    mov dx, 010Fh
    call setCursorPosition
    
    lea dx, strMenu
    call printf
    
    mov dx, 0512h
    call setCursorPosition
    
    lea dx, strPlay
    call printf
    
    mov dx, 0812h
    call setCursorPosition
    
    lea dx, strLoad
    call printf
    
    mov dx, 0B12h
    call setCursorPosition
    
    lea dx, strSave
    call printf
    
    mov dx, 0E11h
    call setCursorPosition
    
    lea dx, strTop5
    call printf
    
    mov dx, 1110h
    call setCursorPosition
    
    lea dx, strCredits
    call printf
    
    mov dx, 1412h
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
;         cx = numero de bytes a copiar
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
; input - di = where to start clearing the string 
;         cx = number of bytes to clear from string
; output - nenhum
; destroi - cx 
;*****************************************************************
clearString proc
    push di
    
    mov al, 0
    rep stosb
    
    pop di  
    ret 
clearString endp

;*****************************************************************
; strLen - Length of string
; descricao: routine that determines the length of a string
; input - si, start of string
;         dx, character that ends the string
; output - cx, length of string
; destroi - cx 
;*****************************************************************
strLen proc
    push si
    xor cx, cx       
           
    strLenLoop:
        
        cmp [si], dl
        je strLenEndLoop
        
        inc cx
        inc si
        
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
; destroi - cx 
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
    call numToStr
    pop si
    
    push dx
    xor dx, dx      ; determina o caracter terminal na verificacao do strLen
    call strLen     ; determines length of string
    cmp cx, bx
    pop dx
        
    jnb pushReal
    push bx           ; determina se vai fazer assert da string ou nao
    call assertStrLen ; se fizer push de bx, vai fazer assert pois temos uma string mais pequena que o desejado
    jmp pushBX      
    
    pushReal:
    push cx
    pushBX:
    
    call copyToStr
    
    pop cx    
    push di
    
    mov di, si    
    call clearString
    
    pop di
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
    call numToStr
    
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
    
    mov [di], ":"
    inc di
    
    call insertTimeInStr
    
    mov [di], ":"
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
    ret
buildLogStr endp

;*****************************************************************
; openLogFile - open log file
; description: routine that opens the log file or creates it and it's directory if it doesn't exit 
; input - nada
; output - bx, file handler 
; destroy - ax, bx, dx
;*****************************************************************
openLogFile proc
    
    lea dx, logFile
    mov al, 3
    call fopen
    
    jnc SkipCreateLog
        
        cmp ax, 2h
        je SkipCreateLogPath
        
        cmp ax, 3h
        jne SkipCreateLogPath
            lea dx, FilesPath
            call createDir
        SkipCreateLogPath:
        
        lea dx, logFile
        xor cx, cx
        call fcreate
        
        lea dx, logFile
        mov al, 3
        call fopen
        
        call ci
        cmp al, 27
        jne SkipCreateTop
            call returnOs
            
    SkipCreateLog:
    
    ret
openLogFile endp

;*****************************************************************
; writeLog - writes a log entry
; description: routine that writes a log entry 
; input - bx, file to write the log
; output - nothing 
; destroy - ax, bx, cx, dx, si, di
;*****************************************************************  
writeLog proc
    
    push bx
    call buildLogStr
    pop bx          
              
    lea cx, strLog      ; determines the size of the Log string by checking
    mov dx, cx          ; the last position it was written to and subbing
    xchg cx, di         ; the first position of the Log string in memory
    sub cx, di          ; and writes that string to log file
    call fwrite         
    
    ret
writeLog endp

;*****************************************************************
; openTop5 - open top 5 file
; description: routine that opens the log file or creates it and it's directory if it doesn't exit 
; input - nada
; output - bx, file handler 
; destroy - ax, bx, dx
;*****************************************************************
openTop5 proc
    
    lea dx, TopFile
    mov al, 2
    call fopen
    jnc SkipCreateTop
        
        cmp ax, 2h
        je SkipCreateTopPath
        
        cmp ax, 3h
        jne SkipCreateTopPath
            lea dx, FilesPath
            call createDir
        SkipCreateTopPath:
        
        lea dx, TopFile
        xor cx, cx
        call fcreate
        
        lea dx, TopFile
        mov al, 3
        call fopen
        
        call ci
        cmp al, 27
        jne SkipCreateTop
            call returnOs    
            
    SkipCreateTop:
    
    ret
openTop5 endp

;*****************************************************************
; calcPointsFromLog - Calculates points from log string
; descricao: rotine that calculates the points a user has from a string with the same structure as the log string
; input - si, beggining of the string  
; output - ax, user points
; destroi - si, dx, ax
;*****************************************************************
calcPointsFromLog proc
    push cx
    
    add si, 16
    
    skipCheckUserName:
        inc si
        cmp [si], ":"    ; advances the str pointer until it finds the next :
        jne skipCheckUserName

   
    inc si
    mov cx, 3
    call strToNum
    mov dx, ax
    
    mov ax, [si]
    
    push dx
    inc si
    mov cx, 4
    call strToNum
    pop dx
    add ax, dx
    
    pop cx
    ret
calcPointsFromLog endp

;*****************************************************************
; calcNewTop5 - calculate new user position in top 5
; descricao: rotine that calculates the new user position within the scoreboard
; input - bx, file handler
;         push 1, new user value  
; output - ax, number of bytes read from last line of top 5 file
;          cx, new player position in top 5
;          dx, position in file to write the new user in
;          CF, set if reached end of file
; destroi - ax, cx, dx, si, di
;*****************************************************************
calcNewTop5 proc
    push bp
    mov bp, sp
    ; inicialize local variavel at 0
    push 0
    push 0
    
    xor cx, cx
    
    calcNewTop5Loop: 
        
        inc [bp - 2]
        
        lea dx, strTemp + 2 
        call fReadLine
        jnc skipCheckReadFlagSet
            STC
            jmp calcNewTop5EndLoop
        skipCheckReadFlagSet:
        
        push ax
        
        lea si, strTemp + 2
        call calcPointsFromLog
        
        cmp [bp + 4], ax
        pop ax
        ja calcNewTop5EndLoop
        
        cmp [bp - 2], 5
        je calcNewTop5EndLoop
        
        add [bp - 4], ax
        
        mov dx, [bp - 4]
        xor al, al
        xor cx, cx
        call fseek
        
        lea di, strTemp + 2
        mov cx, MAXLOGSTRSIZE
        call clearString
        
        jmp calcNewTop5Loop 
    calcNewTop5EndLoop:
    
    pop dx
    pop cx
    pop bp
    ret 2
calcNewTop5 endp

;*****************************************************************
; appendToTop5 - add a new entry to the bottom of top 5 
; descricao: rotine that appends an entry to the top 5 file (does not overwrite any data)
; input - bx, file handler
;         dx, position to write in file  
; output - dx, last position writen to file (from beggining)
; destroy - cx, dx, si
;*****************************************************************
appendToTop5 proc
    push dx
    
    xor al, al
    xor cx, cx
    call fseek
    
    lea si, strLog
    mov dx, 0AH
    call strLen
    inc cx
    
    mov dx, si
    call fwrite
    
    pop dx    
    add dx, cx
    ret
appendToTop5 endp

;*****************************************************************
; clearRestOfFile - clear rest of file
; descricao: rotine that erases all data since input position to end of file
; input - bx, file handler
;         dx, position you wish to start deleting from  
; output - nothing
; destroy - cx, dx
;*****************************************************************
clearRestOfFile proc
    push dx
    
    mov al, 2
    xor cx, cx
    xor dx, dx
    call fseek
    
    pop dx
    
    cmp ax, dx
    jbe skipClearFile
    
    sub ax, dx          ; number of bytes to erase
    push ax
    
    xor al, al
    call fseek
    
    pop cx
    lea dx, strTemp
    call fwrite
    
    skipClearFile:
    ret
clearRestOfFile endp

;*****************************************************************
; readRelScor - read relevant scoreboard
; descricao: rotine that loads to memory the players deserving to be on the scoreboard after the new user 
; input - bx, file handler
;         cx, number of lines already read from the file
;         dx, position to start reading from file
; output - dx, last position read from file
;          cx, number of lines not read from file (because they don't exist)
;          ax, number of bytes already in memory
; destroy - ax, cx, dx
;*****************************************************************
readRelScor proc
    
    push si
    mov si, dx
    
    push ax
    push cx
    xor al, al
    xor cx, cx
    call fseek
    
    pop dx
          
    mov cx, 4           ; executa o read loop no maximo 4 vezes (contando com o 0)
    sub cx, dx
    lea dx, strTemp
    
    pop ax
    inc ax
    add dx, ax
    
    readRestOfTop5Loop:
        
        or cx, cx
        jz readRestOfTop5EndLoop
        
        push cx
        push si
        call fReadLine
        pop si
        pushF
        add si, ax
        popF
        pop cx
        jc readRestOfTop5EndLoop
     
        dec cx   
        
        jmp readRestOfTop5Loop
    readRestOfTop5EndLoop: 
    
    mov dx, si
    pop si
    ret
readRelScor endp

;*****************************************************************
; writeRelScor - write relevant scoreboard
; descricao: rotine that writes the memory loaded from the top 5 file 
; input - bx, file handler
;         cx, number of lines not read
;         dx, line to position new user
;         di, position in the file to write the new user
;         push 1, last position read from
; output - ax, number of bytes already in memory
;          push 1, last position written to
; destroy - ax, cx, dx, si
;*****************************************************************
writeRelScor proc
    push bp
    mov bp, sp
    
    mov si, 5
    sub si, cx
    sub si, dx  ; calcula a quantidade de linhas que tenho de escrever
    push si
     
    mov dx, di 
    xor al, al
    xor cx, cx
    call fseek
    
    lea si, strLog
    mov dx, 0AH
    call strLen
    inc cx
    add [bp + 4], cx
    
    mov dx, si
    call fwrite
    
    lea dx, strTemp + 2
    pop cx
    
    writeRestOfTop5Loop:
        
        or cx, cx
        jz writeRestOfTop5EndLoop
        
        push cx
        call fWriteLine
        inc dx
        pop cx
        
        dec cx
        
        jmp writeRestOfTop5Loop
        
    writeRestOfTop5EndLoop:
    
    pop bp
    ret
writeRelScor endp

;*****************************************************************
; checkTop5 - check top 5
; descricao: rotine that sees if the new player should be part of the top 5 file
; input - bx, file handler  
; output - nada
; destroy - bx, cx, dx, si, di
;*****************************************************************
checkTop5 proc
    push bp
    mov bp, sp
    sub sp, 4
    
    mov dx, genNum
    add dx, cellNum                 ; player value for the top 5 scoreboard
    
    push dx
    call calcNewTop5
    
    jnc WriteOver:
        
        cmp cx, 5
        je endCheckTop5
                                               
        call appendToTop5           ; write to file
        
        jmp endCheckTop5
    
    WriteOver:
        
        cmp cx, 5
        je endCheckTop5
        
        mov [bp - 2], cx
        mov [bp - 4], dx
        
        add dx, ax
        call readRelScor
        
        push dx
        mov dx, [bp - 2]
        mov di, [bp - 4]
        call writeRelScor
        
        pop dx
        
        lea si, strTemp
        mov cx, MAXBUFFERSIZE
        call clearString        
        
    endCheckTop5:
    
    call clearRestOfFile
   
    add sp, 4
    pop bp
    ret
checkTop5 endp

;*****************************************************************
; gamePlay - sets up the game
; descricao: rotine that sets up the game and ends the game
; input - nothing  
; output - nothing
; destroy - bx, cx, dx, si, di
;*****************************************************************
initGamePlay proc
    push ax 
    call hideMouseCursor
    call clearGraph
    
    xor bx, bx
    mov dx, 0B0CH
    call setCursorPosition
    
    lea dx, strGetPlayerName
    call printf
    
    mov dx, 0C0FH
    call setCursorPosition
    
    mov cx, MAXPLAYERNAME
    lea di, strPlayerName
    call scanf
    jc endInitGame
    
    call showMouseCursor
    ;insert call to game here
    
    call openLogFile
    call writeLog               
    call fclose
    
    xor bx, bx
    call openTop5
    call checkTop5
    call fclose
    
    mov cx, MAXLOGSTRSIZE
    lea si, strLog
    call clearString
    
    endInitGame:
    
    pop ax
    ret
initGamePlay endp

;*****************************************************************
; processTop5Str - process top 5 string
; descricao: rotine takes a log like string and transforms it into a user friendly string
; input - dx, position of string to alter  
; output - strTemp, string to be printed
; destroy - bx, cx, dx, si, di
;*****************************************************************
processTop5Str proc
    
    mov si, dx
    sub si, 9
    mov cx, 3
    lea di, strTemp
    
    rep movsb                       ; unpacks number of genarations the player had in game
    
    mov cx, 4
    inc si
    inc di
    
    rep movsb                       ; unpacks number of live cells the player had in game
    
    sub si, 9
    
    xor ax, ax
    skipReadUserName:
        inc ax
        dec si                      ; loop that finds out the beggining position
        cmp [si], ':'               ; of the username
        jne skipReadUserName
    
    add di, 2
    inc si
    dec ax
    push si
    
    mov cx, ax                      ; unpacks the username
    rep movsb
    
    pop si
    
    sub si, 14
        
    mov dx, MAXPLAYERNAME
    sub dx, ax                      ; unpacks the year
    add di, dx
    mov cx, 2
    rep movsb
    
    mov [di], '\'
    inc di
    
    mov cx, 2                       ; unpacks the month
    rep movsb
    
    mov [di], '\'
    inc di
                                    ; unpacks the day
    mov cx, 2
    rep movsb
    
    inc si
    inc di
    mov cx, 2                       ; unpacks the hours
    rep movsb
    
    mov [di], ':'
    inc di
    
    mov cx, 2
    rep movsb                       ; unpacks the minutes
    
    mov [di], ':'
    inc di
    
    mov cx, 2                       ; unpacks the seconds
    rep movsb                       ; adds the end character for the printf function
    mov [di], '$'

    ret
processTop5Str endp    

;*****************************************************************
; displayTop5 - display the top 5 players
; descricao: rotine that displays the top 5 players to screen
; input - nothing  
; output - nothing
; destroy - bx, cx, dx, si, di
;*****************************************************************
displayTop5 proc
    push bp
    mov bp, sp
    ; inicialize variables at 0
    push 0
    push 0
    
    push ax
    call hideMouseCursor
    call clearGraph
    
    xor bx, bx
    mov dx, 0301h
    call setCursorPosition
    
    lea dx, strTop5Screen
    call printf
    
    call openTop5
    
    mov [bp - 2], 5
    mov [bp - 4], 0501h
    
    DisplayReadTop5Loop:
        
        or [bp - 2], 0
        jz DisplayReadEndTop5Loop
        
        lea dx, strTemp + MAXLOGSTRSIZE
        call fReadLine
        jc DisplayReadEndTop5Loop  ; termina o loop quando chegar ao final do ficheiro
                         
        call processTop5Str
        
        push bx
        xor bx, bx
        mov dx, [bp - 4]
        call setCursorPosition
        pop bx
        
        lea dx, strTemp
        call printf
        
        mov cx, MAXLOGSTRSIZE + MAXLOGSTRSIZE
        lea di, strTemp
        call clearString
        
        add [bp - 4], 0200h
        
        dec [bp - 2] 
         
        jmp DisplayReadTop5Loop           
    DisplayReadEndTop5Loop: 
    
    call fclose
    
    call waitOrInput
    
    pop ax
    add sp, 4
    pop bp
    ret
displayTop5 endp    

;*****************************************************************
; rollCredits - roll credits
; descricao: rotine that "rolls" the credits
; input - nothing  
; output - nothing
; destroy - dx, bh
;*****************************************************************
rollCredits proc
    push ax
    
    call clearGraph
    call hideMouseCursor
    
    xor bh, bh
    mov dx, 0D06h
    call setCursorPosition
                                ; prints dev 1
    lea dx, strDiogo                   
    call printf
    
    mov dx, 0B04h
    call setCursorPosition
                                ; prints dev 2
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
    cmp dx, 51              ; button 1 (play)
    jae skipButton1
    
    call initGamePlay
    ret
    skipButton1:
    
    cmp dx, 59
    jbe skipButton2
    cmp dx, 75              ; button 2 (load)
    jae skipButton2
              
    ret       
    skipButton2:
    
    cmp dx, 83
    jbe skipButton3
    cmp dx, 99              ; button 3 (save)
    jae skipButton3
              
    ret       
    skipButton3:
    
    cmp dx, 107
    jbe skipButton4
    cmp dx, 123             ; button 4 (Top 5)
    jae skipButton4
    
    call displayTop5     
    ret             
    skipButton4:
    
    cmp dx, 131
    jbe skipButton5
    cmp dx, 147             ; button 5 (credits)
    jae skipButton5
    
    call rollCredits
    ret
    skipButton5:
             
    cmp dx, 155
    jbe skipButton6
    cmp dx, 171             ; button 6 (exit)
    jae skipButton6
    
    call returnOs
    ret
    skipButton6:
    
    inc ah
    ret
clickMenu endp

;*****************************************************************
; keyMenu - Key main menu
; descricao: Implements the keyboard for the main menu 
; input - al, input from keyboard   
; output - dx, location in the y position of the screen of the button mapped to that key
; destroy - dx
;*****************************************************************
keyMenu proc
    xor dx, dx           ; dependendo do valor de al, vamos mudar o valor de dx vai ser 
                         ; mudado para o valor da posicao do botao correspondente no ecra
    cmp al, '1'
    jne stratSwitch1     ; button 1 (play)
        mov dx, 40
    stratSwitch1:
    
    cmp al, '2'
    jne stratSwitch2     ; button 2 (load)
        mov dx, 70
    stratSwitch2:
    
    cmp al, '3'
    jne stratSwitch3     ; button 3 (save)
        mov dx, 90
    stratSwitch3:
    
    cmp al, '4'
    jne stratSwitch4     ; button 4 (top 5)
        mov dx, 110
    stratSwitch4:
    
    cmp al, '5'
    jne stratSwitch5     ; button 5 (credits)
        mov dx, 140
    stratSwitch5:
    
    cmp al, '6'
    jne stratSwitch6     ; button 6 (exit)
        mov dx, 160
    stratSwitch6:
    
    cmp al, 1BH
    jne stratSwitch7     ; button 6 (exit)
        mov dx, 160
    stratSwitch7:
    
    ret
keyMenu endp

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
    
        call getCharFromBuffer
        jz startMousePos
            
            call keyMenu
            
            or dx, dx
            jz startLoop 
            
            jmp startClick
        
        startMousePos:
        call getMousePos
        shr cx, 1
         
        cmp bl, 1
        jne skipButtons      
            mov ah, 1
            
            cmp cx, 119          ; como os quadrados tem todos a mesma posicao no eixo x
            jbe skipButtons      ; so e preciso verificar 1 vez se estamos no sitio certo para clicar nos
            cmp cx, 199          ; quadrados antes de verificar o quadrado que estamos a clicar
            jae skipButtons
            
            startCLick:
            call clickMenu
            
            or ah, ah
            jz endStartLoop
             
        skipButtons:        
        jmp startLoop
    endStartLoop:
    
    ret
startMenu endp
  
end start
 ; set entry point and stop the assembler.
