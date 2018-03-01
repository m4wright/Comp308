.286
.model small
.stack 100h
.data 
.code

jmp main


; void drawPixel(int x, int y, int color)
;   draws a pixel at location x, y, with the given color
drawPixel:
    x EQU ss:[bp+4]
    y EQU ss:[bp+6]
    color EQU ss:[bp+8]

    push bp
    mov bp, sp

    push ax
    push bx
    push dx
    push es


    ; set ES as the segment for the graphics frame buffer
    mov ax, 0A000h
    mov es, ax

    ; bx = (y * 320) + x
    mov ax, y
    mov bx, 320
    mul bx
    mov bx, x
    add bx, ax

    mov dx, color

    ; plot the pixel in the grapics frame buffer
    mov	BYTE PTR es:[bx], dl

    pop es
    pop dx
    pop bx
    pop ax

    mov sp, bp
    pop bp

    ret 6


main:
    ; setup the data segment
    mov ax, @data
    mov ds, ax

    ; set video mode 
    mov ax, 4F02h
    mov bx, 13h
    int 10h


    mov ax, 100         ; y coordinate
    mov bx, 100         ; start x coordinate
    mov dx, 4           ; color
    
    mov cx, 50          ; number of pixels to draw

    draw_loop:
        push dx
        push ax
        push bx
        call drawPixel

        inc bx
    
        loopw draw_loop



    
    .wait_for_enter_loop:
        ; prompt for a key
        mov ah, 0
        int 16h

        ; check if that key was the enter key
        ; if not, keep waiting
        cmp al, 13
        jne .wait_for_enter_loop
   

    ; terminate the program
    done:
        ; switch to text mode
        mov ax, 4F02h
        mov bx, 3
        int 10h



        ; exit the program
        mov ax, 4c00h
        int 21h
END main
    





