section .bss
    buffer: resb 1024
    buffer_size: resq 1

    is_pal: resq 1 ; boolean value

section .data
    prompt: db "Digite uma palavra: ", 0
    prompt_size: equ $-prompt

    error_message: db `\033[1;31mErro! Por favor, digite uma palavra...\033[0m`, 10
    error_m_size: equ $-error_message

    palindromo_message: db "É um palíndromo!", 10
    palindromo_size: equ $-palindromo_message

    not_palindromo_message: db "Não é um palíndromo!", 10
    not_palindromo_size: equ $-not_palindromo_message

section .text
    global _start

    _start:
        .loop_start:
            mov rsi, prompt
            mov rdx, prompt_size
            call .output

            mov rsi, buffer
            mov rdx, 1024
            call .input

            cmp rax, 2
            jle .error
            mov [buffer_size], rax
            
            call .check_letter

            jmp .encerrar_execucao
    
    .check_letter:
        xor rcx, rcx
        mov rdx, [buffer_size]
        sub rdx, 2 ; removendo line feed

        .loop_letter:
            cmp rcx, rdx
            jge .end_loop_letter

            mov al, [buffer + rcx]
            mov bl, [buffer + rdx]

            cmp al, bl
            jne .is_not_pal  

            inc rcx
            dec rdx

            jmp .loop_letter
        
        .is_not_pal:
            mov rsi, not_palindromo_message
            mov rdx, not_palindromo_size
            call .output
            ret

        .end_loop_letter:
            mov rsi, palindromo_message
            mov rdx, palindromo_size
            call .output
            ret
        
    .output:
        mov rax, 1 ; sys_write
        mov rdi, 1 ; std_out
        syscall
        ret
    
    .input:
        mov rax, 0 ; sys_read
        mov rdi, 0 ; std_in
        syscall
        ret

    .error:
        mov rsi, error_message
        mov rdx, error_m_size
        call .output
        jmp .loop_start
    
    .encerrar_execucao:
        mov rax, 60 ; sys_exit
        mov rdi, 0 ; status code
        syscall
        ret