; main.asm - Main program entry point

%include "constants.inc"
%include "macros.inc"

section .data
    welcome_msg db 'Monoalphabetic Substitution Cipher', NEWLINE
                db '==================================', NEWLINE, NEWLINE
    welcome_len equ $ - welcome_msg
    
    mode_prompt db 'Select mode:', NEWLINE
                db '  E - Encrypt', NEWLINE
                db '  D - Decrypt', NEWLINE
                db 'Enter your choice: '
    mode_prompt_len equ $ - mode_prompt
    
    text_prompt db 'Enter text (max 256 characters):', NEWLINE
    text_prompt_len equ $ - text_prompt
    
    key_prompt db 'Enter substitution key (26 unique letters):', NEWLINE
    key_prompt_len equ $ - key_prompt
    
    result_msg db NEWLINE, 'Result:', NEWLINE
    result_msg_len equ $ - result_msg
    
    newline db NEWLINE
    
    invalid_mode_msg db 'Error: Invalid mode selection!', NEWLINE
    invalid_mode_len equ $ - invalid_mode_msg

section .bss
    mode_input resb 2           ; Mode selection buffer
    text_buffer resb MAX_INPUT_SIZE + 1
    key_buffer resb ALPHABET_SIZE + 2
    output_buffer resb MAX_INPUT_SIZE + 1
    mode resb 1                 ; Selected mode (1=encrypt, 2=decrypt)

section .text
    global _start
    
    ; External functions
    extern validate_key
    extern encrypt_text
    extern decrypt_text
    extern remove_newline
    extern to_uppercase

_start:
    ; Display welcome message
    print_string welcome_msg, welcome_len
    
    ; Get mode selection
    print_string mode_prompt, mode_prompt_len
    read_input mode_input, 2
    
    ; Process mode selection
    mov al, [mode_input]
    call to_uppercase
    
    cmp al, 'E'
    je .set_encrypt_mode
    cmp al, 'D'
    je .set_decrypt_mode
    
    ; Invalid mode
    print_error invalid_mode_msg, invalid_mode_len
    exit_program EXIT_FAILURE
    
.set_encrypt_mode:
    mov byte [mode], MODE_ENCRYPT
    jmp .get_text_input
    
.set_decrypt_mode:
    mov byte [mode], MODE_DECRYPT
    
.get_text_input:
    ; Get text input
    print_string text_prompt, text_prompt_len
    read_input text_buffer, MAX_INPUT_SIZE
    
    ; Remove newline from text input
    mov rdi, text_buffer
    call remove_newline
    
    ; Get key input
    print_string key_prompt, key_prompt_len
    read_input key_buffer, ALPHABET_SIZE + 2
    
    ; Remove newline from key input
    mov rdi, key_buffer
    call remove_newline
    
    ; Validate key
    mov rdi, key_buffer
    call validate_key
    test rax, rax
    jz .exit_failure
    
    ; Perform encryption or decryption
    mov al, [mode]
    cmp al, MODE_ENCRYPT
    je .do_encrypt
    
.do_decrypt:
    mov rdi, text_buffer        ; source text
    mov rsi, key_buffer         ; key
    mov rdx, output_buffer      ; destination
    call decrypt_text
    jmp .display_result
    
.do_encrypt:
    mov rdi, text_buffer        ; source text
    mov rsi, key_buffer         ; key
    mov rdx, output_buffer      ; destination
    call encrypt_text
    
.display_result:
    ; Display result
    print_string result_msg, result_msg_len
    
    ; Calculate output length
    mov rdi, output_buffer
    call string_length
    
    ; Print output
    print_string output_buffer, rax
    print_string newline, 1
    
    ; Exit successfully
    exit_program EXIT_SUCCESS
    
.exit_failure:
    exit_program EXIT_FAILURE

; Helper function: Calculate string length
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