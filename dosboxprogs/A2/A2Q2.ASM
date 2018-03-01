.model small
.stack 100h
.data
    buffer db 100 dup(?)
    printIntBuffer db 20 dup(?)
    
    newLine db 10, 13, 0

    svga_info db 560 dup(?)
    svga_mode_info db 512 dup(?)

    VGA_NOT_SUPPORTED db "VGA Info Not Supported", 10, 13, 0
    VGA_ERROR db "Error Getting VGA Info", 10, 13, 0

    SVGA_INFO_TITLE db "SVGA Info:", 10, 13, 0
    signature_label db "Signature: ", 0
    version_l_label db "VersionL: ", 0
    version_h_label db "VersionH: ", 0
    OEMStringPointer db "OEM String Address: ", 0

    SVGA_MODE_TITLE db "SVGA Mode Info:", 10, 13, 0
    X_resolution db "X Resolution: ", 0
    Y_resolution db "Y Resolution: ", 0
    X_char_size db "X Char Size: ", 0
    Y_char_size db "Y Char Size: ", 0
    BitsPerPixel db "Bits Per Pixel: ", 0
    NumberOfBanks db "Number of Banks: ", 0
    MemoryModel db "Memory Model: ", 0

.code

jmp main



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




; ---------------------------------- A2 ---------------------------------- ;


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



; void getVgaInfo()
;   prints the svga information
getVgaInfo:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push di
    push es

    push OFFSET SVGA_INFO_TITLE
    call puts

    mov di, OFFSET svga_info
    mov ax, ds
    mov es, ax
    mov ax, 4f00h
    int 10h

    cmp al, 4fh
    je vga_info_continue_1

    push OFFSET VGA_NOT_SUPPORTED
    call puts
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret

    vga_info_continue_1:

    cmp ah, 0
    je vga_info_continue_2

    push OFFSET VGA_ERROR
    call puts
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret


    vga_info_continue_2:

    push OFFSET signature_label
    call puts

    mov bx, OFFSET svga_info
    mov cx, 4

    print_vga_loop:
        mov BYTE PTR al, [bx]
        push ax
        call putch
        inc bx
        loopw print_vga_loop

    push OFFSET newLine
    call puts

    push OFFSET version_l_label
    call puts

    xor ax, ax
    mov BYTE PTR al, [bx]
    push ax
    call printInt

    inc bx

    push OFFSET newLine
    call puts


    push OFFSET version_h_label
    call puts

    xor ax, ax
    mov BYTE PTR al, [bx]
    push ax
    call printInt

    inc bx

    push OFFSET newLine
    call puts

    push OFFSET OEMStringPointer
    call puts


    push 0                          ; unsigned
    push 2                          ; the base
    push OFFSET printIntBuffer      ; the string buffer
    mov ax, [bx]                    ; the first part of the address
    push ax
    call itoa

    push OFFSET printIntBuffer
    call puts



    push 0                          ; unsigned
    push 2                          ; the base
    push OFFSET printIntBuffer      ; the string buffer
    mov ax, [bx+2]                  ; the second part of the address
    push ax
    call itoa

    mov cx, 16
    mov bx, OFFSET printIntBuffer
    .find_num_zeros_to_add_loop:
        xor ax, ax
        mov BYTE PTR al, [bx]
        cmp al, 0
        je .done_find_zeros
        inc bx
        dec cx
        jmp .find_num_zeros_to_add_loop

    .done_find_zeros:

    cmp cx, 0
    je .done_print_extra_zeros
    .print_extra_zeros_loop:
        push '0'
        call putch
        loopw .print_extra_zeros_loop

    .done_print_extra_zeros:

    push OFFSET printIntBuffer
    call puts






    push OFFSET newLine
    call puts


    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp

    ret

    


    
; void getSvgaModeInfo(int mode)
;   prints the svga mode information
getSvgaModeInfo:
    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push di
    push es

    push OFFSET SVGA_MODE_TITLE
    call puts

    mov cx, [bp+4]

    mov di, OFFSET svga_mode_info
    mov ax, ds
    mov es, ax
    mov ax, 4f01h
    int 10h

    cmp al, 4fh
    je vga_mode_info_continue_1

    push OFFSET VGA_NOT_SUPPORTED
    call puts
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret 2

    vga_mode_info_continue_1:

    cmp ah, 0
    je vga_mode_info_continue_2

    push OFFSET VGA_ERROR
    call puts
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret 2


    vga_mode_info_continue_2:

    mov bx, OFFSET svga_mode_info

    ; x resolution: offset of 12h
    push OFFSET X_resolution
    call puts

    mov WORD PTR ax, [bx+12h]
    push ax
    call printInt

    push OFFSET newLine
    call puts

    ; y resolution: offset of 14h
    push OFFSET Y_resolution
    call puts

    mov WORD PTR ax, [bx+14h]
    push ax
    call printInt

    push OFFSET newLine
    call puts

    ; x char size: offset of 16h
    push OFFSET X_char_size
    call puts

    xor ax, ax
    mov BYTE PTR al, [bx+16h]
    push ax
    call printInt

    push OFFSET newLine
    call puts

    ; y char size: offset of 17h
    push OFFSET Y_char_size
    call puts

    xor ax, ax
    mov BYTE PTR al, [bx+17h]
    push ax
    call printInt

    push OFFSET newLine
    call puts

    ; bits per pixel: offset of 19h
    push OFFSET BitsPerPixel
    call puts

    xor ax, ax
    mov BYTE PTR al, [bx+19h]
    push ax
    call printInt

    push OFFSET newLine
    call puts

    ; number of banks: offset 1Ah
    push OFFSET NumberOfBanks
    call puts

    xor ax, ax
    mov BYTE PTR al, [bx+1Ah]
    push ax
    call printInt

    push OFFSET newLine
    call puts

    ; memory model: offset 1Bh
    push OFFSET MemoryModel
    call puts

    xor ax, ax
    mov BYTE PTR al, [bx+1Bh]
    push ax
    call printInt

    push OFFSET newLine
    call puts  
 


    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp

    ret 2







main:
    ; setup the data segment
    mov ax, @data
    mov ds, ax

    ; save the stack registers
    push bp
    mov bp, sp

    ; ; set video mode 
    ; mov ax, 4F02h
    ; mov bx, 13h
    ; int 10h

    

    call getVgaInfo
    
    push OFFSET newLine
    call puts

    push 100h
    call getSvgaModeInfo

    


    ; mov ah, 0
    ; int 16h

    ; terminate the program
    done:
        ; ; switch to text mode
        ; mov ax, 4F02h
        ; mov bx, 3
        ; int 10h

        ; restore the stack registers
        mov sp, bp
        pop bp

        ; exit the program
        mov ax, 4c00h
        int 21h
END main
    





