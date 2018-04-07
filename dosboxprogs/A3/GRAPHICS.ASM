.286
.model small
.stack 250h
.data
    PENCOLOR dw 2
    card_info_buffer db 560 dup(?)
    mode_x dw 640                     ; x resolution of current mode
    buffer db 100 dup(?)
    printIntBuffer db 20 dup(?)

    mode_prompt db "Enter the mode (note: works best with modes 19 and 256): ", 0
    border_color_prompt db "Enter the border color: ", 0
    fill_color_prompt db "Enter the fill color: ", 0

    newLine db 10, 13, 0
.code

jmp start


; ----------------------------------------------------------- IO CODE FROM PREVIOUS ASSIGNMENTS ----------------------------------------------------------- ;

; char getche(void)
;   reads a character from the keyboard and puts it in DL
;   It also prints the character to the screen
;   returns:
;       ASCII encoded character in DL
getche:
    ; save the stack pointer
    push bp
    mov bp, sp

    ; save registers used in the function
    push ax

    ; get character from keyboard (saves it to al)
    mov ah, 01
    int 21h

    ; put the character to be returned in the dl register
    mov dl, al

    ; restore the registers
    pop ax

    ; restore the stack pointer
    mov sp, bp
    pop bp

    ; return from the function
    ret



; void gets(char *)
;   reads a string from the keyboard
;   parameters:
;       1: pointer to buffer (WORD) [bp+4]
;   gets will put the read string into the buffer
gets:
    ; save the stack pointer
    push bp
    mov bp, sp

    ; save registers used in the function
    push bx
    push dx


    ; get the address off of the stack and store it in bx
    mov bx, [bp+4]          

   

    .get_char_loop:
        ; get one character from the keyboard and store it in al
        call getche


        ; store the character at that address and increment the pointer
        mov BYTE PTR [bx], dl
        inc bx


        ; check if the last character was a new line
        ; if not, go to the beginning of the loop
        ; if it is, continue to the code that exits
        cmp dl, 0dh
        jnz .get_char_loop



    .end_gets:
        ; add new line and null characters to the end 
        mov BYTE PTR [bx], 10
        mov BYTE PTR [bx+1], 0

        ; restore the registers
        pop dx
        pop bx

        ; restore the stack registers
        mov sp, bp
        pop bp

        ; return from the function and remove the parameter from the stack
        ret 2


; void putch(char)
;   prints a character to the screen
;   parameters:
;       1: the ASCII code of the character on the stack in the low byte of [bp+4]
; 
putch:
    ; save the stack pointer
    push bp
    mov bp, sp

    ; save the registers used in the function
    push dx
    push ax

    ; get the character off of the stack
    mov dl, [bp+4]

    ; print the character in dl (which is the character to print)
    mov ah, 6h
    int 21h

    ; restore the registers
    pop ax
    pop dx

    ; restore the stack
    mov sp, bp
    pop bp

    ; return from the function, and remove the character from the stack
    ret 2



; void puts(char *)
;   prints a null terminated string to the screen
;   parameters:
;       1: pointer to the string (WORD) [bp+4]
;
puts:
    ; save the stack pointer
    push bp
    mov bp, sp

    ; save the registers used in the function
    push bx
    push ax

    ; get the address parameter
    mov bx, [bp+4] 


    .print_loop:
        ; get the character from the address
        mov BYTE PTR al, [bx]


        ; if the character is 0 (the terminating character), exit the printing loop
        cmp al, 0
        jz .done_print_loop


        ; put the character on the stack and call putch to print it
        push ax
        call putch

        ; increment bx to point to the next character
        inc bx

        ; go back to the beginning of the loop
        jmp .print_loop



    .done_print_loop:
        ; restore the registers
        pop ax
        pop bx

        ; restore the stack registers
        mov sp, bp
        pop bp

        ; return from the function, and remove the parameter from the stack
        ret 2




; int atoi(char *s)
;   helper function to getInt
;   Takes as input a pointer to a null terminated string, representing an integer,
;       and returns the integer in the AX register.
;   Note:
;       This function stops reading new characters once it hits a non-integer character
;       So "-123\n\0" will return -123, "4552dasdfadfasdfa\0" will return 4552
;   Parameter:
;       address of null terminated string
;   Return:
;       integer value in AX
atoi:
    ; save the stack pointer
    push bp
    mov bp, sp

    ; save registers that get used
    push bx
    push cx
    push dx

    mov bx, [bp+4]          ; address of string
    mov cx, 1               ; sign of number
    mov dx, 0               ; the number itself



    mov BYTE PTR al, [bx]
    cmp al, '-'
    jnz .done_sign_comp
    ; number is negative
        mov cx, -1
        inc bx

    .done_sign_comp:
        ; push the sign on the stack
        push cx
        

    .atoi_loop:
        ; check if still integer characters
        mov cx, 0
        mov BYTE PTR cl, [bx]
        cmp cl, '0'
        jl .done_atoi_loop
        cmp cl, '9'
        jg .done_atoi_loop
        
        ; get integer value of current digit
        sub cl, '0'

        ; multiply dx by 10
        mov ax, dx
        mov dx, 10
        mul dx
        mov dx, ax

        ; add current digit to dx
        add dx, cx

        ; increment the address
        inc bx
        jmp .atoi_loop

    
    .done_atoi_loop:
        ; done the loop. Multiply dx by the sign, and return
        mov ax, dx
        ; get the sign from the stack
        pop cx
        imul cx
        ; ax now holds the result


        ; restore modified registers
        pop dx
        pop cx
        pop bx

        ; restore the stack registers
        mov sp, bp
        pop bp

        ret 2




; int getInt(void)
;   reads an integer from the keyboard
;   The function takes no input
;   It returns the integer in the AX register
getInt:
    ; save the stack pointer
    push bp
    mov bp, sp

    ; read a string into the buffer using gets
    mov ax, OFFSET buffer
    push ax
    call gets

    ; using atoi, convert this string into a number
    mov ax, OFFSET buffer
    push ax
    call atoi
    ; ax now holds the integer value

    ; restore the stack and return
    mov sp, bp
    pop bp

    ret



    
; void itoa(int, char *, int, int)
;   converts an integer to a string
;   Parameters:
;       integer
;       address of buffer to hold the string
;       the base
;       whether or not it's a signed integer
itoa:
    ; save the stack pointer
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    mov cx, [bp+4]              ; the integer value
    mov bx, [bp+6]              ; the address of the buffer
    base EQU ss:[bp+8]          ; the base
    signed EQU ss:[bp+10]       ; 1 if a signed integer, 0 if unsigned



    ; check if the number is 0, since this is a special case

    cmp cx, 0
    jnz .itoa_not_zero
        mov BYTE PTR [bx], '0'
        inc bx
        mov BYTE PTR [bx], 0
        jmp .itoa_done


    .itoa_not_zero:

    ; handle sign
    mov ax, signed
    cmp ax, 0
    je .itoa_loop

    cmp cx, 0
    jge .itoa_loop
        ; if negative, put '-' and increment pointer
        mov BYTE PTR [bx], '-'
        ; multiply the number by -1
        mov ax, cx
        mov cx, -1
        mul cx
        mov cx, ax
        
        ; increment the buffer address
        inc bx
        mov [bp+6], bx



    .itoa_loop:
        ; store the integer as a string, but in reverse order
        cmp cx, 0
        je .itoa_reverse
        mov ax, cx
        mov cx, base
        xor dx, dx
        div cx
        ; ax now holds n/base, and dx holds n % base

        ; write the character representing the digit to the buffer
        add dl, '0'
        mov BYTE PTR [bx], dl
        inc bx



        ; ax currently holds n / 10. Store this value into cx
        mov cx, ax

        ; go back to the beginning of the loop
        jmp .itoa_loop


    ; reverse the string in place
    .itoa_reverse:
        ; first, add a null character at the end of the string
        mov BYTE PTR [bx], 0
        ; decrement bx, so that it points to the last non-null character
        dec bx
        
        ; get the address of the beggining of the buffer
        mov cx, [bp+6]


        ; calculate the mid point between the two
        ; ax = (bx - cx) / 2 + cx
        
        ; ax = bx - cx
        mov ax, bx
        sub ax, cx
        
        ; ax = ax / 2 (using shift)
        shr ax, 1

        ; ax = ax + cx
        ; this is the final computation, ie ax = (bx - cx) / 2 + cx
        add ax, cx
        push ax



        .itoa_reverse_loop:
            ; if (cx > mid_point): goto done
            pop dx
            cmp cx, dx
            jg .itoa_done
            push dx


            ; swap values ax bx, cx
            mov ax, 0
            mov dx, 0
            mov BYTE PTR ax, [bx]
            push bx
            mov bx, cx
            mov BYTE PTR dx, [bx]
            mov BYTE PTR [bx], al
            pop bx
            mov BYTE PTR [bx], dl

            inc cx
            dec bx

            jmp .itoa_reverse_loop



    .itoa_done:
        ; restore the registers
        pop dx
        pop cx
        pop bx
        pop ax

        ; restore the stack registers and return
        mov sp, bp
        pop bp

        ret 8



; void printInt(int)
;   prints a signed 16 bit integer
;   Parameter: 
;       the integer to print
printInt:
    ; save the stack pointer
    push bp
    mov bp, sp

    ; store registers used in the function
    push ax
    
    
    ; convert the integer to a string using itoa
    push 1                                          ; 1 for signed
    push 10                                         ; the base
    mov ax, OFFSET printIntBuffer
    push ax
    mov ax, [bp+4]
    push ax
    call itoa

    ; print the string using puts
    mov ax, OFFSET printIntBuffer
    push ax
    call puts

    ; restore the registers used
    pop ax

    ; restore the stack registers
    mov sp, bp
    pop bp

    ret 2








; ----------------------------------------------------------- CODE FOR A3 ----------------------------------------------------------- ;




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
        call GET_CARDINFO
        mov al, 1

    .set_mode_done:
    
    pop bx
    pop bp

    ret 2



; GET_CARDINFO
;   gets the card information and stores it into card_info_buffer in the data segment
;   this function also sets mode_x and mode_y
GET_CARDINFO:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push di
    push es

    ; get current mode
    mov ax, 4f03h
    int 10h
    ; now bx = video mode



    ; get mode info
    mov cx, bx
    mov di, OFFSET card_info_buffer
    mov ax, ds
    mov es, ax
    mov ax, 4f01h
    int 10h


    ; get x and y values
    mov bx, OFFSET card_info_buffer
    mov WORD PTR ax, [bx+12h]
    cmp ax, 0
    jne .done_set_mode_x
    mov ax, 320
    .done_set_mode_x:
    mov mode_x, ax



    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax    

    pop bp

    ret



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
DRAWPIXEL:
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


    ; BX = y*mode_x + x
    mov bx, x1
    mov cx, mode_x
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

; GETPIXEL(int x, int y)
; gets the pixel color at position (x,y)
; returns the color in ax
GETPIXEL:
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


    ; BX = y*mode_x + x
    mov bx, x1
    mov cx, mode_x
    xor dx, dx
    mov ax, y1
    mul cx
    add bx, ax

    
    xor ax, ax
    ; plot the pixel in the graphics frame buffer
    mov BYTE PTR al, es:[bx]

    pop es
    pop dx
    pop cx
    pop bx

    pop bp

    ret 4



; drawFromX(int x1, int y1, int x2, int y2)
;   draws a line stepping along the x axis
drawFromX:
    push bp
    mov bp, sp

    x1 EQU ss:[bp+4]
    y1 EQU ss:[bp+6]
    x2 EQU ss:[bp+8]
    y2 EQU ss:[bp+10]

    ; if x1 > x2 swap points
    mov ax, x1
    mov bx, x2
    cmp ax, bx
    jle .continue_draw_from_x
    mov ax, x1
    mov bx, x2
    mov x2, ax
    mov x1, bx

    mov ax, y1
    mov bx, y2
    mov y2, ax
    mov y1, bx

    .continue_draw_from_x:

    ; calculate m and b in y = mx + b
    mov cx, x2      ; delta x
    sub cx, x1
    


    mov ax, y2      ; delta y
    sub ax, y1



    cwd             ; m = (delta y) / (delta x)
    idiv cx
    push ax
    m EQU ss:[bp-2]




    mov bx, m
    mov ax, x1      ; b = y1 - m*x1
    xor dx, dx
    mul bx
    mov dx, y1
    sub dx, ax
    push dx
    b EQU ss:[bp-4]


    



    
    ; note: cx still holds delta x. Will be used for the counter index
    mov bx, x1
    inc cx
    
    .draw_x_loop:
        ; calculate y from x in bx
        mov ax, m
        xor dx, dx
        mul bx          ; ax now holds mx
        add ax, b       ; ax now holds mx + b = y

        push ax

        push ax         ; y
        push bx         ; x
        call DRAWPIXEL

        pop ax

        ; push bx
        ; call printInt
        ; push ' '
        ; call putch

        ; push ax
        ; call printInt
        ; push OFFSET newLine
        ; call puts
        
        inc bx
        loopw .draw_x_loop

    


    add sp, 4           ; clear the stack of m and b

    pop bp
    ret 8


; drawFromY(int x1, int y1, int x2, int y2)
;   draws a line stepping along the y axis
drawFromY:
    push bp
    mov bp, sp

    x1 EQU ss:[bp+4]
    y1 EQU ss:[bp+6]
    x2 EQU ss:[bp+8]
    y2 EQU ss:[bp+10]

    

    ; if y1 > y2 swap points
    mov ax, y1
    mov bx, y2
    cmp ax, bx
    jle .continue_draw_from_y
    mov ax, y1
    mov bx, y2
    mov y2, ax
    mov y1, bx

    mov ax, x1
    mov bx, x2
    mov x2, ax
    mov x1, bx

    .continue_draw_from_y:


    ; calculate m and b in x = my + b
    mov cx, y2      ; delta y
    sub cx, y1


    mov ax, x2      ; delta x
    sub ax, x1



    cwd             ; ax = (delta x) / (delta y) = m
    idiv cx
    push ax
    m EQU ss:[bp-2]
    
     

    mov bx, m
    mov ax, y1      ; b = x1 - m*y1
    xor dx, dx
    mul bx
    mov dx, x1
    sub dx, ax
    push dx
    b EQU ss:[bp-4]



    ; note: cx still holds delta y. Will be used for the counter index
    mov bx, y1
    inc cx
    
    .draw_y_loop:
        ; calculate x from y in bx
        mov ax, m
        xor dx, dx
        mul bx          ; ax now holds my
        add ax, b       ; ax now holds my + b = x
        
        push ax

        push bx         ; y
        push ax         ; x
        call DRAWPIXEL

        pop ax

        
        inc bx
        ; jmp done_y_loop
        loopw .draw_y_loop

    done_y_loop:
    add sp, 4           ; clear the stack of m and b

    pop bp
    ret 8


; DRAWLINE(int x1, int y1, int x2, int y2)
DRAWLINE:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx

    x1 EQU ss:[bp+4]
    y1 EQU ss:[bp+6]
    x2 EQU ss:[bp+8]
    y2 EQU ss:[bp+10]

    ; calculate |x1 - x2|
    mov ax, x1
    sub ax, x2
    cmp ax, 0
    jge .done_abs_x
    neg ax
    .done_abs_x:
    mov bx, ax
    

    ; calculate |y1 - y2|
    mov ax, y1
    sub ax, y2
    cmp ax, 0
    jge .done_abs_y
    neg ax
    .done_abs_y:

    push y2
    push x2
    push y1
    push x1

    cmp ax, bx
    jge draw_from_y
    call drawFromX

    jmp .done_drawline

    draw_from_y:
    call drawFromY
        
    .done_drawline:

    pop dx
    pop cx
    pop bx
    pop ax

    pop bp
    ret 8


; SIMPLEFILL(int x, int y, int border_color)
SIMPLEFILL:
    push bp
    mov bp, sp

    x EQU ss:[bp+4]
    y EQU ss:[bp+6]
    border_color EQU ss:[bp+8]

    push ax
    push bx
    push cx


    push y
    push x
    call GETPIXEL
    cmp ax, border_color
    je .done_simple_fill
    cmp ax, PENCOLOR
    je .done_simple_fill

    push y
    push x
    call DRAWPIXEL



    mov cx, y
    inc cx
    push border_color
    push cx
    push x
    call SIMPLEFILL

    mov cx, y
    dec cx
    push border_color
    push cx
    push x
    call SIMPLEFILL

    

    mov bx, x
    inc bx
    push border_color
    push y
    push bx
    call SIMPLEFILL

    mov bx, x
    dec bx
    push border_color
    push y
    push bx
    call SIMPLEFILL


    .done_simple_fill:

    pop cx
    pop bx
    pop ax

    pop bp
    ret 6



start:
    ; initialize data segment
    mov ax, @data
    mov ds, ax

    push OFFSET mode_prompt
    call puts
    call getInt
    mov bx, ax

    push OFFSET border_color_prompt
    call puts
    call getInt
    push ax

    push ax
    call SETPENCOLOR

    push OFFSET fill_color_prompt
    call puts
    call getInt
    push ax


    push bx
    call SETMODE

    
    ; draw the triangle border

    push WORD PTR 10
    push WORD PTR 60
    push WORD PTR 10
    push WORD PTR 120
    call DRAWLINE

    push WORD PTR 10
    push WORD PTR 60
    push WORD PTR 40
    push WORD PTR 90
    call DRAWLINE

    push WORD PTR 40
    push WORD PTR 90
    push WORD PTR 10
    push WORD PTR 120
    call DRAWLINE


    ; the fill color is on the top of the stack
    call SETPENCOLOR

    ; the border color is on top of the stack
    push 15                     ; interior point of the above triangle
    push 90
    call SIMPLEFILL



    ; prompt for a key
    mov ah, 0
    int 16h

    ; switch back to text mode
    mov bx, 3
    push bx
    call SETMODE
    

    ; exit
    mov ax, 4C00h
    int 21h

END start