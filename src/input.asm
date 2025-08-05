; input.asm - Input handling routines

%include "constants.inc"
%include "macros.inc"

section .data
    input_error_msg db 'Error: Failed to read input!', NEWLINE
    input_error_len equ $ - input_error_msg
    
    buffer_overflow_msg db 'Error: Input exceeds maximum buffer size!', NEWLINE
    buffer_overflow_len equ $ - buffer_overflow_msg

section .text
    global read_user_input
    global clear_buffer
    global trim_input

; Function: read_user_input
; Reads user input with buffer overflow protection
; Parameters:
;   rdi - buffer pointer
;   rsi - maximum buffer size
; Returns:
;   rax - number of bytes read (including newline)
;         -1 on error
read_user_input:
    push_regs
    push rbp
    mov rbp, rsp
    
    ; Save parameters
    push rdi
    push rsi
    
    ; Perform system call
    mov rdx, rsi            ; max size
    mov rsi, rdi            ; buffer
    mov rdi, STDIN
    mov rax, SYS_READ
    syscall
    
    ; Check for error
    cmp rax, 0
    jl .error
    
    ; Check for buffer overflow
    pop rsi                 ; Restore max size
    pop rdi                 ; Restore buffer pointer
    
    cmp rax, rsi
    jge .buffer_overflow
    
    ; Success - null terminate if needed
    mov byte [rdi + rax], 0
    jmp .done
    
.error:
    pop rsi
    pop rdi
    print_error input_error_msg, input_error_len
    mov rax, -1
    jmp .done
    
.buffer_overflow:
    print_error buffer_overflow_msg, buffer_overflow_len
    ; Clear the remaining input from stdin
    call flush_stdin
    mov rax, -1
    
.done:
    mov rsp, rbp
    pop rbp
    pop_regs
    ret

; Function: clear_buffer
; Clears a buffer by filling with zeros
; Parameters:
;   rdi - buffer pointer
;   rsi - buffer size
clear_buffer:
    push_regs
    
    mov rcx, rsi
    xor al, al
    rep stosb
    
    pop_regs
    ret

; Function: trim_input
; Removes leading and trailing whitespace
; Parameters:
;   rdi - string pointer
; Returns:
;   rax - new string length
trim_input:
    push_regs
    push rbp
    mov rbp, rsp
    
    ; Find string length first
    push rdi
    call string_length
    mov rcx, rax            ; Store length in rcx
    pop rdi
    
    test rcx, rcx
    jz .done                ; Empty string
    
    ; Trim trailing whitespace
    dec rcx                 ; Point to last character
.trim_end:
    cmp rcx, 0
    jl .empty_result
    
    mov al, [rdi + rcx]
    cmp al, ' '
    je .next_end
    cmp al, 9              ; Tab
    je .next_end
    cmp al, NEWLINE
    je .next_end
    cmp al, 13             ; Carriage return
    je .next_end
    
    ; Found non-whitespace
    inc rcx                ; Adjust to position after last char
    mov byte [rdi + rcx], 0  ; Null terminate
    jmp .trim_start
    
.next_end:
    dec rcx
    jmp .trim_end
    
.trim_start:
    ; Find first non-whitespace
    xor rsi, rsi           ; Start index
    
.find_start:
    cmp rsi, rcx
    jge .empty_result
    
    mov al, [rdi + rsi]
    cmp al, ' '
    je .next_start
    cmp al, 9              ; Tab
    je .next_start
    cmp al, NEWLINE
    je .next_start
    cmp al, 13             ; Carriage return
    je .next_start
    
    ; Found start of non-whitespace
    test rsi, rsi
    jz .no_shift_needed
    
    ; Shift string to beginning
    push rdi
    push rsi
    push rcx
    
    mov rdx, rdi           ; Destination
    add rsi, rdi           ; Source = rdi + rsi
    sub rcx, rsi           ; Adjust length
    
.shift_loop:
    mov al, [rsi]
    mov [rdx], al
    inc rsi
    inc rdx
    test al, al
    jnz .shift_loop
    
    pop rcx
    pop rsi
    pop rdi
    
.no_shift_needed:
    sub rcx, rsi           ; Final length
    mov rax, rcx
    jmp .done
    
.next_start:
    inc rsi
    jmp .find_start
    
.empty_result:
    mov byte [rdi], 0
    xor rax, rax
    
.done:
    mov rsp, rbp
    pop rbp
    pop_regs
    ret

; Function: flush_stdin
; Flushes remaining input from stdin
flush_stdin:
    push_regs
    
    sub rsp, 256           ; Temporary buffer
    
.flush_loop:
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, rsp
    mov rdx, 256
    syscall
    
    cmp rax, 0
    jle .done
    
    ; Check if we got a newline
    mov rcx, rax
    mov rdi, rsp
.check_newline:
    cmp byte [rdi], NEWLINE
    je .done
    inc rdi
    loop .check_newline
    
    jmp .flush_loop
    
.done:
    add rsp, 256
    pop_regs
    ret

; External function declaration
extern string_length