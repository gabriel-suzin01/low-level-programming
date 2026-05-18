section .bss
    buffer: resb 1024
    buffer_size: resq 1

    result: resq 1
    result_string: resb 1024

section .data
    numbers: db "0123456789"

    welcome_message: db `\033[1;32m------------------ CALCULADORA DE FATORIAL EM ASSEMBLY ------------------\033[0m\n\n\033[31mO código só aceita até no máximo (20!).\033[0m\nTentar números maiores que esses resultará em valores aleatórios!\n`, 10
    welcome_size: equ $-welcome_message

    prompt_message: db "Digite um número: ", 0
    prompt_size: equ $-prompt_message

    error_message: db `\033[1;31mErro! Para fazer o cálculo, somente serão aceitos dígitos.\033[0m`, 10
    error_size: equ $-error_message

    result_message: db "O resultado final é: ", 0
    result_size: equ $-result_message

section .text
    global _start

    _start:
        mov rsi, welcome_message
        mov rdx, welcome_size

        call .output

        jmp .main_loop

        .main_loop:
            mov rsi, prompt_message
            mov rdx, prompt_size

            call .output
            call .input

            cmp qword [buffer_size], 0
            je .error_not_number

            call .check_number
            call .calculate_factorial

            mov rsi, result_message
            mov rdx, result_size

            call .output

            call .conversion_int_str

            call .output

            jmp .exit

    .check_number:
        xor rcx, rcx

        .loop_number:
            cmp rcx, [buffer_size]
            jge .loop_end

            mov al, [buffer + rcx]

            call .check
            
            inc rcx
            jmp .loop_number

        .loop_end:
            ret
        
        .check:
            cmp al, '0'
            je .leave_check
            cmp al, '1'
            je .leave_check
            cmp al, '2'
            je .leave_check
            cmp al, '3'
            je .leave_check
            cmp al, '4'
            je .leave_check
            cmp al, '5'
            je .leave_check
            cmp al, '6'
            je .leave_check
            cmp al, '7'
            je .leave_check
            cmp al, '8'
            je .leave_check
            cmp al, '9'
            je .leave_check
            jmp .error_not_number
        
        .leave_check:
            ret
    
    .calculate_factorial:
        xor rax, rax
        mov rbx, qword 1

        cmp qword [buffer_size], 2
        je .two_digits

        .one_digit:
            movzx rcx, byte [buffer]
            sub rcx, '0'
            jmp .next_step_factorial
        
        .two_digits:
            movzx rax, byte [buffer]
            sub rax, '0'
            imul rax, 10

            movzx rcx, byte [buffer + 1]
            sub rcx, '0'

            add rcx, rax
            jmp .next_step_factorial

        .next_step_factorial:
            xor rdx, rdx

            mov qword [result], rcx

            .loop_factorial:
                cmp rcx, 1
                jle .loop_factorial_end
                
                mov rax, [result]
                mul rbx

                mov [result], rax

                dec rcx
                mov rbx, rcx

                jmp .loop_factorial

            .zero_result:
                mov qword [result], 1
                ret

            .loop_factorial_end:
                cmp rcx, 0
                jle .zero_result
                ret
    
    .conversion_int_str:
        mov rax, [result]
        mov rbx, 10
        mov rsi, result_string + 1023
        mov byte [rsi], 10

        .loop_conv:
            xor rdx, rdx
            div rbx
            dec rsi
            add dl, '0'
            mov [rsi], dl
            cmp rax, 0
            jnz .loop_conv

        mov rdx, result_string + 1024
        sub rdx, rsi
        ret
    
    .error_not_number:
        mov rsi, error_message
        mov rdx, error_size

        call .output
        jmp .main_loop
    
    .input:
        mov rax, 0
        mov rdi, 0
        mov rsi, buffer
        mov rdx, 1024
        syscall

        dec rax
        mov [buffer_size], rax
        ret
    
    .output:
        mov rax, 1
        mov rdi, 1
        syscall
        ret
    
    .exit:
        mov rax, 60
        mov rdi, 0
        syscall