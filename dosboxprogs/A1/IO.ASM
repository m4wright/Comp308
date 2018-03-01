.model small
.stack 100h
.data
    prompt db "Enter your name: ", 0
    buffer db 100 dup(?)
.code

jmp main



; getche:
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



; gets:
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


; putch
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



; puts
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





main:
    ; setup the data segment
    mov ax, @data
    mov ds, ax

    ; save the stack registers
    push bp
    mov bp, sp

    ; save the registers used by the function
    push ax
    

    ; print the prompt
    mov ax, OFFSET prompt
    push ax
    call puts




    ; push the address of the buffer onto the stack as an argument to gets
    mov ax, OFFSET buffer
    push ax
    call gets


    ; push the address of the string onto the stack as an argument to puts
    mov ax, OFFSET buffer
    push ax
    call puts

    

    ; terminate the program
    done:
        ; restore the registers
        pop ax

        ; restore the stack registers
        mov sp, bp
        pop bp

        ; exit the program
        mov ax, 4c00h
        int 21h
END main
    





