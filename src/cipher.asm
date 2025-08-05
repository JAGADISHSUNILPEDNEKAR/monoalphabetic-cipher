; cipher.asm - Encryption and decryption functions

%include "constants.inc"
%include "macros.inc"

section .bss
    reverse_key resb ALPHABET_SIZE  ; For decryption reverse mapping

section .text
    global encrypt_text
    global decrypt_text
    extern to_uppercase

; Function: encrypt_text
; Parameters:
;   rdi - source text pointer
;   rsi - key pointer
;   rdx - destination buffer pointer
; Returns:
;   rax - number of characters processed
encrypt_text:
    push_regs
    push rbp
    mov rbp, rsp
    
    xor rcx, rcx            ; Counter
    
.process_char:
    mov al, [rdi + rcx]     ; Get current character
    test al, al             ; Check for null terminator
    jz .done
    
    ; Check if character is alphabetic
    push rax
    call is_alpha
    test rax, rax
    pop rax
    jz .copy_char           ; Not alphabetic, copy as-is
    
    ; Save original case info
    push rax
    call is_uppercase
    mov r8b, al             ; Save uppercase flag in r8b
    pop rax
    
    ; Convert to uppercase for processing
    push rax
    call to_uppercase
    mov bl, al              ; Store uppercase version
    pop rax
    
    ; Calculate index (0-25)
    sub bl, ASCII_UPPERCASE_A
    movzx rbx, bl
    
    ; Get substitution character from key
    mov al, [rsi + rbx]
    
    ; Restore original case if needed
    test r8b, r8b
    jnz .store_char         ; Was uppercase, keep as-is
    
    ; Convert to lowercase
    or al, 0x20             ; Set bit 5 to make lowercase
    
.store_char:
    mov [rdx + rcx], al
    inc rcx
    jmp .process_char
    
.copy_char:
    mov [rdx + rcx], al     ; Copy non-alphabetic character
    inc rcx
    jmp .process_char
    
.done:
    mov byte [rdx + rcx], 0 ; Null terminate
    mov rax, rcx
    
    mov rsp, rbp
    pop rbp
    pop_regs
    ret

; Function: decrypt_text
; Parameters:
;   rdi - cipher text pointer
;   rsi - key pointer
;   rdx - destination buffer pointer
; Returns:
;   rax - number of characters processed
decrypt_text:
    push_regs
    push rbp
    mov rbp, rsp
    
    ; First, create reverse key mapping
    call create_reverse_key
    
    xor rcx, rcx            ; Counter
    
.process_char:
    mov al, [rdi + rcx]     ; Get current character
    test al, al             ; Check for null terminator
    jz .done
    
    ; Check if character is alphabetic
    push rax
    call is_alpha
    test rax, rax
    pop rax
    jz .copy_char           ; Not alphabetic, copy as-is
    
    ; Save original case info
    push rax
    call is_uppercase
    mov r8b, al             ; Save uppercase flag in r8b
    pop rax
    
    ; Convert to uppercase for processing
    push rax
    call to_uppercase
    mov bl, al              ; Store uppercase version
    pop rax
    
    ; Find character in key (reverse lookup)
    push rcx
    xor rcx, rcx
.find_char:
    cmp byte [rsi + rcx], bl
    je .found
    inc rcx
    cmp rcx, ALPHABET_SIZE
    jl .find_char
    ; Character not found in key (shouldn't happen with valid key)
    pop rcx
    jmp .copy_char
    
.found:
    ; rcx contains the index, convert back to letter
    add cl, ASCII_UPPERCASE_A
    mov al, cl
    pop rcx
    
    ; Restore original case if needed
    test r8b, r8b
    jnz .store_char         ; Was uppercase, keep as-is
    
    ; Convert to lowercase
    or al, 0x20             ; Set bit 5 to make lowercase
    
.store_char:
    mov [rdx + rcx], al
    inc rcx
    jmp .process_char
    
.copy_char:
    mov [rdx + rcx], al     ; Copy non-alphabetic character
    inc rcx
    jmp .process_char
    
.done:
    mov byte [rdx + rcx], 0 ; Null terminate
    mov rax, rcx
    
    mov rsp, rbp
    pop rbp
    pop_regs
    ret

; Function: create_reverse_key
; Creates reverse mapping for decryption
; Parameters:
;   rsi - key pointer
create_reverse_key:
    push_regs
    
    xor rcx, rcx
.loop:
    mov al, [rsi + rcx]     ; Get key character
    sub al, ASCII_UPPERCASE_A
    movzx rax, al
    
    ; Store index as value at position of key character
    mov [reverse_key + rax], cl
    
    inc rcx
    cmp rcx, ALPHABET_SIZE
    jl .loop
    
    pop_regs
    ret

; Function: is_alpha
; Check if character in AL is alphabetic
; Returns: 1 if alpha, 0 otherwise
is_alpha:
    cmp al, ASCII_UPPERCASE_A
    jl .not_alpha
    cmp al, ASCII_UPPERCASE_Z
    jle .is_alpha
    
    cmp al, ASCII_LOWERCASE_A
    jl .not_alpha
    cmp al, ASCII_LOWERCASE_Z
    jle .is_alpha
    
.not_alpha:
    xor rax, rax
    ret
    
.is_alpha:
    mov rax, 1
    ret

; Function: is_uppercase
; Check if character in AL is uppercase
; Returns: 1 if uppercase, 0 otherwise
is_uppercase:
    cmp al, ASCII_UPPERCASE_A
    jl .not_upper
    cmp al, ASCII_UPPERCASE_Z
    jg .not_upper
    
    mov rax, 1
    ret
    
.not_upper:
    xor rax, rax
    ret