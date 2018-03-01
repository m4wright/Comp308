jmp 111                     ; 111 address of code

db 'Hello World!', 0d, 0a, 0


mov bx, 0102                ; 0102: start address

mov ah, 6
mov dl, [bx]
int 21

inc bx
mov al, [bx]
cmp al, 0
jnz 0114                    ; address of mov ah, 6


mov ax, 4c                  ; exit
int 21