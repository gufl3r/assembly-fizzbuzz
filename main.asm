; nasm -f elf64 -o main.o main.asm
; ld main.o -o main
; nasm -f elf64 -o main.o main.asm && ld main.o -o main

; Setting up constants for system calls and file descriptors
OUTPUT_FILEDESCRIPTOR EQU 1d
SC_WRITE EQU 1d

; Declaring global entry point
global _start

section .data ; Initialized variables
    countdisplayunit db 48d              ; Holds units place of the count to be displayed
    countdisplayten db 48d               ; Holds tens place of the count to be displayed
    realcount dw 0d                      ; Actual count
    fizzorbuzz db 0d                     ; Flag to determine if it's a Fizz, Buzz, or FizzBuzz
    fizz db "Fizz", 0              ; String "Fizz"
    buzz db "Buzz", 0              ; String "Buzz"

    char_newline db 10d                  ; Newline character

section .bss ; Uninitialized variables

section .text ; Code
    _start: 
        mainloop:
            ; Writing newline character to stdout
            mov rax, SC_WRITE
            mov rdi, OUTPUT_FILEDESCRIPTOR
            mov rsi, char_newline         ; Pointer to string
            mov rdx, 1d                   ; String size
            syscall

            ; Resetting variables for next iteration
            mov byte [fizzorbuzz], 0d
            inc byte [countdisplayunit]
            inc word [realcount]
            cmp word [realcount], 101d   ; Check if we've reached 101
            je loopend

            ; Checking if countdisplayunit exceeds 9, incrementing countdisplayten accordingly
            cmp byte [countdisplayunit], 58d
            jne checkfizz
            sub byte [countdisplayunit], 10d
            inc byte [countdisplayten]

        checkfizz:
            ; Checking if the current count is divisible by 3
            mov dx, 0d
            mov ax, word [realcount]
            mov bx, 3d
            div bx
            cmp dx, 0d
            je isfizz

        checkbuzz:
            ; Checking if the current count is divisible by 5
            mov dx, 0d
            mov ax, word [realcount]
            mov bx, 5d
            div bx
            cmp dx, 0d
            je isbuzz
            jmp endfizzbuzz

        isfizz:
            ; Writing "Fizz" to stdout
            mov rax, SC_WRITE
            mov rdi, OUTPUT_FILEDESCRIPTOR
            mov rsi, fizz           ; Pointer to string
            mov rdx, 5d                   ; String size
            syscall
            inc byte [fizzorbuzz]
            jmp checkbuzz

        isbuzz:
            ; Writing "Buzz" to stdout
            mov rax, SC_WRITE
            mov rdi, OUTPUT_FILEDESCRIPTOR
            mov rsi, buzz           ; Pointer to string
            mov rdx, 5d                   ; String size
            syscall
            inc byte [fizzorbuzz]

        endfizzbuzz:
            ; Checking if Fizz, Buzz, or FizzBuzz has been printed
            cmp byte [fizzorbuzz], 0d
            jne mainloop

            ; Writing countdisplayten to stdout
            mov rax, SC_WRITE
            mov rdi, OUTPUT_FILEDESCRIPTOR
            mov rsi, countdisplayten      ; Pointer to string
            mov rdx, 1d                   ; String size
            syscall

            ; Writing countdisplayunit to stdout
            mov rax, SC_WRITE
            mov rdi, OUTPUT_FILEDESCRIPTOR
            mov rsi, countdisplayunit     ; Pointer to string
            mov rdx, 1d                   ; String size
            syscall

            ; Restarting the loop
            jmp mainloop

        loopend:
            ; Exiting the program
            mov rax, 60                   ; Exit syscall number
            mov rdi, 0                    ; Exit status
            syscall