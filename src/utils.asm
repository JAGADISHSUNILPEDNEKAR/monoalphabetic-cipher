; utils.asm - Utility functions

%include "constants.inc"

section .text
    global remove_newline
    global to_uppercase
    global string_length

; Function: remove_newline
; Removes newline character from string
; Parameters:
;   rdi - string pointer
remove_newline:
    push rax
    push rcx
    
    xor rcx, rcx
.loop:
    mov al, [rdi + rcx]
    test al, al
    jz .done
    
    cmp al, NEWLINE
    je .found_newline
    
    inc rcx
    jmp .loop
    
.found_newline:
    mov byte [rdi + rcx], 0
    
.done:
    pop rcx
    pop rax
    ret

; Function: to_uppercase
; Converts character in AL to uppercase
; Parameters:
;   al - character to convert
; Returns:
;   al - uppercase character
to_uppercase:
    cmp al, 'a'
    jl .done
    cmp al, 'z'
    jg .done
    
    sub al, 0x20        ; Convert to uppercase
    
.done:
    ret

; Function: string_length
; Calculate string length
; Parameters:
;   rdi - string pointer
; Returns:
;   rax - string length
string_length:
    push rcx
    xor rcx, rcx
.loop:
    cmp byte [rdi + rcx], 0
    je .done
    inc rcx
    jmp .loop
.done:
    mov rax, rcx
    pop rcx
    ret