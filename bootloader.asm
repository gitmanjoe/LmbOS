; boatloader.asm
bits 16
org 0x7c00

mov bx, Welcome_Msg
call print_string
mov ax, Input
mov bx, 30
call get_string
push ax
call print_crlf
pop ax
mov bx, ax
call print_string
jmp $

get_char:
    mov ah, 0x11
    int 0x16
    jnz key_pressed
    hlt ; wait for next key press
    jmp get_char

key_pressed:
    mov ah, 0x10 ; get key that was pressed
    int 0x16
    ret

print_char:
    mov ah,0x0e ; BIOS teletype output
    push bp
    int 0x10 ; print the character in al
    pop bp
    ret

print_string:
    pusha ; save register ax
    mov ah,0x0e ; BIOS teletype output

print_string_loop:
    mov al,[bx] 
    cmp al,0 ; end of string?
    je done ; jump to done
    call print_char ; print char to screen
    add bx,1 ; Increment BX to the next char in string.
    jmp print_string_loop ; loop to print the next char.

done:
    popa ; restore register ax
    ret

print_crlf:
    mov al,13
    call print_char
    mov al,10
    call print_char
    ret

get_string:
    pusha ; save ax
    ; If the character count is zero, exit
    cmp bx, 0
    je done_string
    mov di, ax ; di = Current position in empty string
    dec bx ; bx = Maximum characters in string
    mov cx, bx ; cx = Remaining character count
get_char_loop:
    call get_char
    cmp al, 13 ; The ENTER key ends input string
    je end_string

    ; the maximum size has been reached
    jcxz get_char_loop

    ; Only add printable characters (ASCII Values 32-126)
    cmp al, ' '
    jb get_char_loop
    cmp al, 126
    ja get_char_loop
    stosb ; store char in empty string at reg di
    call print_char
    dec cx
    jmp get_char_loop
end_string:
    mov al,0 ; add end of string termonator
    stosb ; store char in empty string at reg di
done_string:
    popa ; restore ax
    ret
; Data
Welcome_Msg:
db 'Welcome to BustOS!',13,10,0 

Input:
db 31 dup (0)

times 510 - ($-$$) db 0
dw 0xaa55

