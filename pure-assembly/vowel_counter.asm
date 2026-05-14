section .bss
    buffer: resb 1024 ; array de 1024 bytes para palavra
    buffer_size: resq 1 ; 1 número inteiro para tamanho da palavra

    qtd_vogais: resq 1
    qtd_numeros: resq 1
    resultado: resb 1024

section .data
    vogais: db "aeiouAEIOU", 0 ; definindo vogais
    numeros: db "0123456789", 0 ; definindo números

    vogais_print: db "Digite uma palavra: ", 0
    vogais_size: equ $-vogais_print
    erro_print: db `\033[1;31mErro! Por favor, digite somente letras.\033[0m`, 10
    erro_size: equ $-erro_print
    encerrando_print: db `\033[1;33m\nEncerrando...\033[0m`, 10
    encerrando_size: equ $-encerrando_print
    quantidade_print: db "A quantidade total de vogais é: ", 0
    quantidade_size: equ $-quantidade_print

section .text
    global _start

    _start:
        .inicio:
            mov rsi, vogais_print ; palavras a serem printadas
            mov rdx, vogais_size ; quantos bytes ler
            call .output

            mov rdx, 1024 ; diz que o valor inicial do buffer é 1024
            call .input

            cmp rax, 1 ; caso usuário só apertar enter, encerra execução
            jle .fim_programa

            dec rax ; tira o line feed
            mov [buffer_size], rax ; diz que o valor do buffer é o retorno da função

            jmp .comparacao

    .input:
        mov rax, 0 ; sys_read
        mov rdi, 0 ; std_in
        mov rdx, 1024 ; tamanho
        mov rsi, buffer ; onde vai ser armazenado
        syscall
        ret
    
    .output:
        mov rax, 1 ; sys_write
        mov rdi, 1 ; std_out
        syscall
        ret
    
    .check_vogal:
        mov rdi, vogais

        .loop_vogal:
            mov bl, [rdi]
            cmp bl, 0
            je .not_vogal

            cmp al, bl
            je .add_vogal

            inc rdi
            jmp .loop_vogal
        
        .not_vogal: ret
        .add_vogal:
            inc qword [qtd_vogais]
            ret
    
    .check_numero:
        mov rdi, numeros

        .loop_numero:
            mov bl, [rdi]
            cmp bl, 0
            je .not_numero

            cmp al, bl
            je .add_numero

            inc rdi
            jmp .loop_numero
        
        .not_numero: ret
        .add_numero: 
            inc qword [qtd_numeros]
            ret
        
    .comparacao:
        xor rcx, rcx

        mov qword [qtd_vogais], 0
        mov qword [qtd_numeros], 0

        .loop_comparacao:
            cmp rcx, [buffer_size]
            jge .valida_comparacao

            mov al, [buffer + rcx]

            call .check_numero
            call .check_vogal

            inc rcx
            jmp .loop_comparacao
        
        .valida_comparacao:
            ; faz a validação: se foram digitados somente 
            mov rax, [qtd_vogais]
            cmp rax, 0
            jne .fim_programa

            mov rax, [qtd_numeros]
            cmp rax, [buffer_size]
            jge .erro_numero

            jmp .fim_programa
    
    .erro_numero:
        mov rsi, erro_print
        mov rdx, erro_size
        call .output
        jmp .inicio

    .conversao:
        mov rax, [qtd_vogais]
        mov rbx, 10 ; divisao por 10
        mov rsi, resultado + 10 ; final do texto + 1 byte, para começar dec para sincronizar o ponteiro

        xor rcx, rcx ; auxiliar usado no loop

        ; por definição, quando usamos div:

        ; rax = quociente da divisão
        ; rdx = resto da divisão

        .loop_conversao:
            xor rdx, rdx ; limpado para ser usado na divisão.
            div rbx
            dec rsi

            add dl, "0"
            mov [rsi], dl

            cmp rax, 0 ; quociente zerou, acabou o problema
            jnz .loop_conversao
        ret
        
    .fim_programa:
        mov rsi, quantidade_print
        mov rdx, quantidade_size
        call .output

        call .conversao
        mov rdx, resultado + 10
        sub rdx, rsi ; fazendo diferença entre última posição do rsi, com o final da string
        call .output

        mov rsi, encerrando_print
        mov rdx, encerrando_size
        call .output

        jmp .encerrar_execucao

    .encerrar_execucao:
        mov rax, 60 ; encerrando programa
        mov rdi, 0 ; status code
        syscall