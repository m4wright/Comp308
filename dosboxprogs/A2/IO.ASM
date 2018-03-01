.286
.model small
.stack 200h
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
    ; push bp
    ; mov bp, sp

    mov cx, ax
    push ax


    .get_char_loop:
        call getche

        pop bx

        mov BYTE PTR [bx], al
        inc bx
        push bx

        mov ah, 9h
        mov dx, cx
        int 21h

        cmp al, 0dh
        jnz .get_char_loop



    .done_get_char_loop:
        pop bx
        mov BYTE PTR [bx], '$'




        ; mov sp, bp
        ; pop bp

        ret






start:
    push bp
    mov bp, sp

    ; save 100 bytes on the stack for the input
    sub sp, 100   
    mov bx, sp
    mov BYTE PTR [bx+9], Ah
    mov BYTE PTR [bx+10], '$' 


    ; setup the data segment
    mov ax, @data
    mov ds, ax


    ; print the prompt
    mov ah, 9h
    mov dx, OFFSET prompt
    int 21h

    ; push the address (sp) of the memory allocated for the input and call gets
    ; mov ax, sp
    ; call gets

    mov ah, 9h
    mov dx, sp
    int 21h

    

    ; terminate the program
    done:
        mov ax, 4c00h
        int 21h
END start
    





