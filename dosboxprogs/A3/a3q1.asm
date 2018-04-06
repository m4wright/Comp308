.286
.model small
.stack 100h
.data
    PENCOLOR dw 2
.code


; SETMODE
; sets the graphics mode
; on failure, resets to standard text mode and returns false (0) in al
; on success, returns true (1) in al
SETMODE:
    push bp
    mov bp, sp

    push bx

    mov bx, [bp+4]
    mov ax, 4F02h
    int 10h

    cmp ah, 0                   ; ah set to 0 on success, 1 on failure
    je .set_mode_success
    .error_set_mode:
    ; set back to text mode
        mov ax, 4f02h
        mov bx, 3
        int 10h

        mov al, 0
        
        jmp .set_mode_done

    .set_mode_success:
        mov al, 1

    .set_mode_done:
    
    pop bx
    pop bp

    ret 2



; SETPENCOLOR(int color)
; sets the pen color to color
; returns true on success, false on failure in al
SETPENCOLOR:
    push bp
    mov bp, sp

    mov ax, [bp+4]
    mov PENCOLOR, ax
    mov ax, 1

    pop bp

    ret 2



; DRAWPIXEL(int x, int y)
; draws a pixel of color PENCOLOR (set by SETPENCOLOR) at position (x,y)
; returns true on success, faluse on failure in al
drawPixel:
    x1 EQU ss:[bp+4]
    y1 EQU ss:[bp+6]

    push bp
    mov bp, sp

    push bx
    push cx
    push dx
    push es

    ; set ES as segment of graphics frame buffer
    mov ax, 0A000h
    mov es, ax

    ; TODO: Find actual value instead of 320 (different for different modes)

    ; BX = y*320 + x
    mov bx, x1
    mov cx, 320
    xor dx, dx
    mov ax, y1
    mul cx
    add bx, ax

    ; DX = color
    mov dx, PENCOLOR
    

    ; plot the pixel in the graphics frame buffer
    mov BYTE PTR es:[bx], dl

    pop es
    pop dx
    pop cx
    pop bx

    pop bp

    ret 4






; draw a line at a 45 degree angle
drawLine_d:
    color EQU ss:[bp+4]
    x1 EQU ss:[bp+6]
    y1 EQU ss:[bp+8]
    x2 EQU ss:[bp+10]
    up_or_down EQU ss:[bp+12]

    
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx


    mov ax, x1
    mov bx, x2

    mov cx, 1

    cmp ax, bx
    jle dl_done_change_direction
    mov cx, 0
    dl_done_change_direction:
    push cx
    
        


    mov bx, x1
    mov dx, y1

    mov cx, x2
    sub cx, bx
    cmp cx, 0
    jge done_absolute_value
    mov ax, cx
    add ax, ax
    sub cx, ax
    done_absolute_value:
    inc cx

    dl_loop:
        push dx
        push bx
        call drawPixel

        pop ax       
        cmp ax, 0
        jnz left
        right:
            sub bx, 1
            jmp done_left_right_comp
        left:
            add bx, 1
        done_left_right_comp:
        push ax

        mov ax, up_or_down
        cmp ax, 0
        jnz up
        down:
            add dx, 1
            jmp done_up_down_comp
        up:
            sub dx, 1
        done_up_down_comp:

        loopw dl_loop

    dl_end:
        pop ax

        pop dx
        pop cx
        pop bx
        pop ax

        pop bp
        ret 10






; draw a horizontal line
drawLine_h:
    color EQU ss:[bp+4]
    x1 EQU ss:[bp+6]
    y1 EQU ss:[bp+8]
    x2 EQU ss:[bp+10]

    push bp
    mov bp, sp

    push bx
    push cx

    ; if x1 > x2, swap 12 and x2
    mov ax, x1
    mov bx, x2

    cmp ax, bx
    jle dh_done_swap
    xchg ax, bx
    dh_done_swap:
        mov x1, ax
        mov x2, bx

    ; BX keeps track of the X coordinate
    mov bx, x1

    ; CX = number of pixels to draw
    mov cx, x2
    sub cx, bx
    inc cx

    dlh_loop:
        push y1
        push bx

        call drawPixel
        add bx, 1
        loopw dlh_loop

    dlh_end:
        pop cx
        pop bx
        
        pop bp
        ret 8


drawLine_v:
    color EQU ss:[bp+4]
    x1 EQU ss:[bp+6]
    y1 EQU ss:[bp+8]
    y2 EQU ss:[bp+10]

    push bp
    mov bp, sp

    push bx
    push cx

    ; if y1 > y2, swap y1 and y2
    mov ax, y1
    mov bx, y2

    cmp ax, bx
    jle dv_done_swap
    xchg ax, bx
    dv_done_swap:
        mov y1, ax
        mov y2, bx

        

    ; BX keeps track of the y coordinate
    mov bx, y1

    ; CX = number of pixels to draw
    mov cx, y2
    sub cx, bx
    inc cx

    dlv_loop:
        push bx
        push x1

        call drawPixel
        add bx, 1
        loopw dlv_loop

    dlv_end:
        pop cx
        pop bx
        
        pop bp
        ret 8


start:
    ; initialize data segment
    mov ax, @data
    mov ds, ax

    ; set video mode - 320x200 256 color-mode
    ; mov ax, 4F02h
    ; mov bx, 13h
    ; int 10h

    mov bx, 13h
    push bx
    call SETMODE

    push WORD PTR 0004h
    call SETPENCOLOR

    ; floor
    push WORD PTR 260           ; x2
    push WORD PTR 190           ; y1
    push WORD PTR 60            ; x1
    push 0004h                  ; color
    call drawLine_h

    ; left vertical
    push WORD PTR 190           ; y2
    push WORD PTR 110           ; y1
    push WORD PTR 60            ; x1
    push 0009h                  ; color
    call drawLine_v

    ; right vertical
    push WORD PTR 110           ; y2
    push WORD PTR 190           ; y1
    push WORD PTR 260           ; x1
    push 0040h                  ; color
    call drawLine_v   


    ; ceiling
    push WORD PTR 60            ; x2
    push WORD PTR 110           ; y1
    push WORD PTR 260           ; x1
    push 0003h                  ; color
    call drawLine_h 


    ; left roof
    push WORD PTR 1             ; up
    push WORD PTR 160           ; x2
    push WORD PTR 110           ; y1
    push WORD PTR 60            ; x1
    push 0006h
    call drawLine_d

    ; right roof
    push WORD PTR  1            ; up
    push WORD PTR 160           ; x2
    push WORD PTR 110           ; y1
    push WORD PTR 260           ; x1
    push 0021h
    call drawLine_d

    ; prompt for a key
    mov ah, 0
    int 16h

    ; switch back to text mode
    mov ax, 4f02h
    mov bx, 3
    int 10h

    ; exit
    mov ax, 4C00h
    int 21h

END start