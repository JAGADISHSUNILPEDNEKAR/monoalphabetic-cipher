; validation.asm - Input validation functions

%include "constants.inc"
%include "macros.inc"

section .data
    key_length_error db 'Error: Key must be exactly 26 characters!', NEWLINE
    key_length_error_len equ $ - key_length_error
    
    key_alpha_error db 'Error: Key must contain only alphabetic characters!', NEWLINE
    key_alpha_error_len equ $ - key_alpha_error
    
    key_unique_error db 'Error: Key must contain 26 unique letters!', NEWLINE
    key_unique_error_len equ $ - key_unique_error

section .bss
    char_count resb 26      ; Array to track character usage

section .text
    global validate_key
    extern string_length
    extern to_uppercase

; Function: validate_key
; Validates the substitution key
; Parameters:
;   rdi - key pointer
; Returns:
;   rax - 1 if valid, 0 if invalid
validate_key:
    push_regs
    push rbp
    mov rbp, rsp
    
    ; Check key length
    push rdi
    call string_length
    pop rdi
    
    cmp rax, ALPHABET_SIZE
    jne .invalid_length
    
    ; Convert key to uppercase for validation
    push rdi
    call convert_key_to_upper
    pop rdi
    
    ; Check all characters are alphabetic and unique
    call check_key_validity
    test rax, rax
    jz .invalid_key
    
    ; Key is valid
    mov rax, 1
    jmp .done
    
.invalid_length:
    print_error key_length_error, key_length_error_len
    xor rax, rax
    jmp .done
    
.invalid_key:
    xor rax, rax
    
.done:
    mov rsp, rbp
    pop rbp
    pop_regs
    ret

; Function: convert_key_to_upper
; Converts entire key to uppercase
; Parameters:
;   rdi - key pointer
convert_key_to_upper:
    push_regs
    
    xor rcx, rcx
.loop:
    mov al, [rdi + rcx]
    test al, al
    jz .done
    
    call to_uppercase
    mov [rdi + rcx], al
    
    inc rcx
    jmp .loop
    
.done:
    pop_regs
    ret

; Function: check_key_validity
; Checks if key contains only unique alphabetic characters
; Parameters:
;   rdi - key pointer
; Returns:
;   rax - 1 if valid, 0 if invalid
check_key_validity:
    push_regs
    
    ; Clear character count array
    push rdi
    mov rdi, char_count
    mov rcx, 26
    xor al, al
    rep stosb
    pop rdi
    
    xor rcx, rcx
.check_loop:
    mov al, [rdi + rcx]
    test al, al
    jz .check_complete
    
    ; Check if alphabetic
    cmp al, ASCII_UPPERCASE_A
    jl .not_alpha
    cmp al, ASCII_UPPERCASE_Z
    jg .not_alpha
    
    ; Calculate index and check if already used
    sub al, ASCII_UPPERCASE_A
    movzx rax, al
    
    cmp byte [char_count + rax], 0
    jne .duplicate_found
    
    ; Mark character as used
    mov byte [char_count + rax], 1
    
    inc rcx
    jmp .check_loop
    
.not_alpha:
    print_error key_alpha_error, key_alpha_error_len
    xor rax, rax
    jmp .done
    
.duplicate_found:
    print_error key_unique_error, key_unique_error_len
    xor rax, rax
    jmp .done
    
.check_complete:
    ; Verify all 26 characters are present
    mov rcx, 26
    mov rsi, char_count
    xor rdx, rdx
.count_loop:
    lodsb
    add dl, al
    loop .count_loop
    
    cmp dl, 26
    jne .duplicate_found
    
    mov rax, 1
    
.done:
    pop_regs
    ret

; Function: string_length (if not defined elsewhere)
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