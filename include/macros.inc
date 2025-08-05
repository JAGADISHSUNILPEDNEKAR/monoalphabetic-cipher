; macros.inc - Common assembly macros

; Print string macro
%macro print_string 2
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, %1        ; string address
    mov rdx, %2        ; string length
    syscall
%endmacro

; Print error string macro
%macro print_error 2
    mov rax, SYS_WRITE
    mov rdi, STDERR
    mov rsi, %1        ; string address
    mov rdx, %2        ; string length
    syscall
%endmacro

; Read input macro
%macro read_input 2
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, %1        ; buffer address
    mov rdx, %2        ; buffer size
    syscall
%endmacro

; Exit program macro
%macro exit_program 1
    mov rax, SYS_EXIT
    mov rdi, %1        ; exit code
    syscall
%endmacro

; Preserve registers macro
%macro push_regs 0
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
%endmacro

; Restore registers macro
%macro pop_regs 0
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
%endmacro