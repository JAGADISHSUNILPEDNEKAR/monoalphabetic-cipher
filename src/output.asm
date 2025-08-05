; output.asm - Output display routines

%include "constants.inc"
%include "macros.inc"

section .data
    hex_chars db '0123456789ABCDEF'
    
    ; Output formatting strings
    divider db '----------------------------------------', NEWLINE
    divider_len equ $ - divider
    
    hex_prefix db '0x'
    hex_prefix_len equ $ - hex_prefix
    
    space db ' '
    
    ; Buffer for number to string conversion
    num_buffer times 32 db 0

section .text
    global print_formatted_output
    global print_hex_dump
    global print_statistics
    global number_to_string

; Function: print_formatted_output
; Prints the output with proper formatting
; Parameters:
;   rdi - output buffer pointer
;   rsi - length of output
print_formatted_output:
    push_regs
    push rbp
    mov rbp, rsp
    
    ; Print divider
    print_string divider, divider_len
    
    ; Print the output text
    mov rdx, rsi            ; length
    mov rsi, rdi            ; buffer
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    syscall
    
    ; Print newline if not already present
    mov rax, rsi
    add rax, rdi
    dec rax
    cmp byte [rax], NEWLINE
    je .skip_newline
    
    print_string newline, 1
    
.skip_newline:
    ; Print divider
    print_string divider, divider_len
    
    mov rsp, rbp
    pop rbp
    pop_regs
    ret

; Function: print_hex_dump
; Prints a hex dump of the buffer (useful for debugging)
; Parameters:
;   rdi - buffer pointer
;   rsi - number of bytes to dump
print_hex_dump:
    push_regs
    push rbp
    mov rbp, rsp
    
    mov rcx, rsi            ; Counter
    mov rsi, rdi            ; Save buffer pointer
    
    xor rbx, rbx            ; Offset counter
    
.dump_loop:
    test rcx, rcx
    jz .done
    
    ; Print offset if at beginning of line
    test bl, 0x0F
    jnz .print_byte
    
    ; Print offset in hex
    push rcx
    push rsi
    
    mov rdi, rbx
    call print_hex_number
    print_string space, 1
    print_string space, 1
    
    pop rsi
    pop rcx
    
.print_byte:
    ; Print byte in hex
    push rcx
    push rsi
    
    movzx rdi, byte [rsi]
    call print_hex_byte
    print_string space, 1
    
    pop rsi
    pop rcx
    
    inc rsi
    inc rbx
    dec rcx
    
    ; Check if end of line (16 bytes)
    test bl, 0x0F
    jnz .dump_loop
    
    ; End of line - print ASCII representation
    push rcx
    push rsi
    
    print_string space, 1
    print_string space, 1
    
    ; Go back 16 bytes
    sub rsi, 16
    mov rcx, 16
    
.ascii_loop:
    mov al, [rsi]
    
    ; Check if printable
    cmp al, 0x20
    jl .non_printable
    cmp al, 0x7E
    jg .non_printable
    
    ; Print character
    push rax
    print_string rsi, 1
    pop rax
    jmp .next_ascii
    
.non_printable:
    push rax
    print_string dot, 1
    pop rax
    
.next_ascii:
    inc rsi
    loop .ascii_loop
    
    print_string newline, 1
    
    pop rsi
    pop rcx
    
    jmp .dump_loop
    
.done:
    ; Handle partial last line
    test bl, 0x0F
    jz .really_done
    
    ; Pad with spaces
    mov rax, rbx
    and rax, 0x0F
    mov rcx, 16
    sub rcx, rax
    
.pad_loop:
    print_string space, 1
    print_string space, 1
    print_string space, 1
    loop .pad_loop
    
    ; Print ASCII for partial line
    print_string space, 1
    print_string space, 1
    
    sub rsi, rax
    mov rcx, rax
    jmp .ascii_loop
    
.really_done:
    mov rsp, rbp
    pop rbp
    pop_regs
    ret

; Function: print_hex_byte
; Prints a single byte in hexadecimal
; Parameters:
;   rdi - byte value
print_hex_byte:
    push_regs
    
    mov rax, rdi
    and rax, 0xFF
    
    ; High nibble
    mov rbx, rax
    shr rbx, 4
    mov bl, [hex_chars + rbx]
    push rbx
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rbx
    
    ; Low nibble
    mov rbx, rax
    and rbx, 0x0F
    mov bl, [hex_chars + rbx]
    push rbx
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rbx
    
    pop_regs
    ret

; Function: print_hex_number
; Prints a number in hexadecimal format
; Parameters:
;   rdi - number to print
print_hex_number:
    push_regs
    
    print_string hex_prefix, hex_prefix_len
    
    mov rax, rdi
    mov rcx, 16             ; Number of nibbles in 64-bit
    
.skip_leading_zeros:
    rol rax, 4
    mov rbx, rax
    and rbx, 0x0F
    jnz .print_digits
    loop .skip_leading_zeros
    
    ; All zeros - print at least one
    mov bl, '0'
    push rbx
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rbx
    jmp .done
    
.print_digits:
    ; Print this digit
    mov bl, [hex_chars + rbx]
    push rbx
    push rax
    push rcx
    
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall
    
    pop rcx
    pop rax
    pop rbx
    
    dec rcx
    jz .done
    
.print_remaining:
    rol rax, 4
    mov rbx, rax
    and rbx, 0x0F
    mov bl, [hex_chars + rbx]
    push rbx
    push rax
    push rcx
    
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, rsp
    mov rdx, 1
    syscall
    
    pop rcx
    pop rax
    pop rbx
    
    loop .print_remaining
    
.done:
    pop_regs
    ret

; Function: print_statistics
; Prints encryption/decryption statistics
; Parameters:
;   rdi - number of characters processed
;   rsi - number of alphabetic characters
;   rdx - number of non-alphabetic characters
print_statistics:
    push_regs
    push rbp
    mov rbp, rsp
    
    ; Save parameters
    push rdi
    push rsi
    push rdx
    
    ; Print header
    print_string stats_header, stats_header_len
    
    ; Print total characters
    print_string total_chars_msg, total_chars_msg_len
    pop rdx
    pop rsi
    pop rdi
    push rdi
    push rsi
    push rdx
    
    call number_to_string
    print_string num_buffer, rax
    print_string newline, 1
    
    ; Print alphabetic characters
    print_string alpha_chars_msg, alpha_chars_msg_len
    pop rdx
    pop rsi
    pop rdi
    push rdi
    push rsi
    push rdx
    
    mov rdi, rsi
    call number_to_string
    print_string num_buffer, rax
    print_string newline, 1
    
    ; Print non-alphabetic characters
    print_string non_alpha_chars_msg, non_alpha_chars_msg_len
    pop rdx
    pop rsi
    pop rdi
    
    mov rdi, rdx
    call number_to_string
    print_string num_buffer, rax
    print_string newline, 1
    
    mov rsp, rbp
    pop rbp
    pop_regs
    ret

; Function: number_to_string
; Converts a number to decimal string
; Parameters:
;   rdi - number to convert
; Returns:
;   rax - string length
number_to_string:
    push_regs
    
    mov rax, rdi
    mov rdi, num_buffer
    mov rcx, 31             ; Start at end of buffer
    mov byte [rdi + rcx], 0 ; Null terminate
    dec rcx
    
    test rax, rax
    jnz .convert_loop
    
    ; Handle zero
    mov byte [rdi + rcx], '0'
    mov rax, 1
    jmp .done
    
.convert_loop:
    test rax, rax
    jz .reverse_string
    
    xor rdx, rdx
    mov rbx, 10
    div rbx
    
    add dl, '0'
    mov [rdi + rcx], dl
    dec rcx
    jmp .convert_loop
    
.reverse_string:
    inc rcx
    lea rsi, [rdi + rcx]
    
    ; Calculate length
    mov rax, 31
    sub rax, rcx
    
    ; Copy to beginning of buffer
    mov rdi, num_buffer
    push rax
    
.copy_loop:
    mov bl, [rsi]
    mov [rdi], bl
    inc rsi
    inc rdi
    test bl, bl
    jnz .copy_loop
    
    pop rax
    
.done:
    pop_regs
    ret

section .data
    dot db '.'
    
    stats_header db NEWLINE, 'Processing Statistics:', NEWLINE
                 db '=====================', NEWLINE
    stats_header_len equ $ - stats_header
    
    total_chars_msg db 'Total characters: '
    total_chars_msg_len equ $ - total_chars_msg
    
    alpha_chars_msg db 'Alphabetic characters: '
    alpha_chars_msg_len equ $ - alpha_chars_msg
    
    non_alpha_chars_msg db 'Non-alphabetic characters: '
    non_alpha_chars_msg_len equ $ - non_alpha_chars_msg
    
    newline db NEWLINE