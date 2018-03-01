.286
.model small
.stack 100h
.data
    prompt db "Enter a string: $"
.code

jmp start



; getche:
;   reads a character from the keyboard and puts it in AL
;   It also prints the character to the screen
;   returns:
;       ASCII encoded character in AL
getche:
    ; ; save the stack pointer
    ; push bp
    ; mov bp, sp

    ; get character from keyboard (saves it to al)
    mov ah, 01
    int 21h

    ; ; print character that was received
    ; mov ah, 6h
    ; mov dl, al
    ; int 21h


    ; ; restore the stack pointer
    ; mov sp, bp
    ; pop bp

    ; return
    ret



; gets:
;   reads a string from the keyboard
;   parameters:
;       1: pointer to buffer (WORD) [bp+2]
;   gets will put the read string into the buffer
gets:
    push bp
    mov bp, sp

    ; save registers that are used

    ; get the pointer off the stack
    ; mov bx, WORD PTR [bp+4]
    mov bx, ax
    mov cx, bx
    push bx
    


    .get_chars_loop:
        ; get a character from the keyboard and store it in al using getche
        call getche


        pop bx

        ; save it in memory, and increment the current pointer
        mov BYTE PTR [bx], al
        inc bx


        ; mov ah, 6h
        ; mov dl, [bx-1]
        ; int 21h

        

        push bx
        
        ; check if the character is the carriage return. If it is, jump to .done_input_loop
        cmp al, 0dh
        jnz .get_chars_loop
        mov ah, 6h
        mov dl, [bx-1]
        int 21h
        jz .done_input_loop
        

        ; go back to the beginning of the loop
        jmp .get_chars_loop

    .done_input_loop:
        ; add a null character to the end of the string
        pop bx
        mov BYTE PTR [bx], '$'

        ; restore the stack pointers
        mov sp, bp
        pop bp


        ; mov ah, 9h
        ; mov dx, cx
        ; int 21h

        ; ret 2 to remove pointer from the stack and return
        ret




start:
    push bp
    mov bp, sp

    ; save 100 bytes on the stack for the input
    sub sp, 100d      


    ; setup the data segment
    mov ax, @data
    mov ds, ax


    ; print the prompt
    mov ah, 9h
    mov dx, OFFSET prompt
    int 21h

    ; push the address (sp) of the memory allocated for the input and call gets
    mov ax, sp
    mov cx, sp
    call gets

    ; mov bx, sp
    ; mov BYTE PTR [bx+5], '$'


    ; mov ah, 9h
    ; mov dx, sp
    ; int 21h

    

    ; terminate the program
    done:
        mov ax, 4c00h
        int 21h
END start
    





