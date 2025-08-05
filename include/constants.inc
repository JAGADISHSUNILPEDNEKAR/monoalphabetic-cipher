; constants.inc - Program constants and definitions

%define MAX_INPUT_SIZE 256
%define ALPHABET_SIZE 26
%define ASCII_UPPERCASE_A 65
%define ASCII_LOWERCASE_A 97
%define ASCII_UPPERCASE_Z 90
%define ASCII_LOWERCASE_Z 122
%define NEWLINE 10
%define NULL 0

; System call numbers for Linux x86-64
%define SYS_READ 0
%define SYS_WRITE 1
%define SYS_EXIT 60

; File descriptors
%define STDIN 0
%define STDOUT 1
%define STDERR 2

; Exit codes
%define EXIT_SUCCESS 0
%define EXIT_FAILURE 1

; Operation modes
%define MODE_ENCRYPT 1
%define MODE_DECRYPT 2