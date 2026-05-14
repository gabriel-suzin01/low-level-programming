section .bss
    buffer: resb 1024 ; reservando um array de 1024 bytes para a palavra
    buffer_size: resq 1 ; reservando para 1 número de 64 bits

section .data
    hello: db "Digite uma palavra ou número: ", 0 ; mensagem de início
    hello_size: equ $-hello ; tamanho da mensagem de início
    string_normal: db "String normal: ", 0 ; mensagem de exibição de string normal
    string_normal_len: equ $-string_normal ; tamanho da mensagem de string normal
    string_invertida: db "String invertida: ", 0 ; mensagem de exibição de string invertida
    string_invertida_len: equ $-string_invertida ; tamanho da mensagem de string invertida
    fim_loop: db `\n\033[1;31mVocê digitou um texto inválido! Fim da execução.\033[0m\n`, 0 ; exibindo mensagem de erro
    fim_loop_size: equ $-fim_loop ; tamanho da mensagem de erro

section .text
    global _start

_start:
    .infinito:
        mov rsi, hello_size
        mov rdi, hello
        call .print

        call .get_string
        cmp rax, 3 ; mínimo de letras: 2
        jl .fim_infinito ; é, nem tudo é pra sempre

        mov [buffer_size], rax

        mov rsi, string_normal_len
        mov rdi, string_normal
        call .print

        mov rsi, [buffer_size]
        mov rdi, buffer
        call .print

        mov rsi, string_invertida_len
        mov rdi, string_invertida
        call .print

        call .inverter_string

        mov rsi, [buffer_size]
        mov rdi, buffer
        call .print

        jmp .infinito
    
    .fim_infinito:
        mov rsi, fim_loop_size
        mov rdi, fim_loop
        call .print
        
        jmp .encerrar_execucao

.get_string:
    mov rax, 0 ; sys_read
    mov rdi, 0 ; formato stdin
    mov rsi, buffer ; dizendo em qual lugar armazenar o resultado
    mov rdx, 1024 ; dizendo a capacidade da variável buffer
    syscall
    ret

.inverter_string:
    mov rdx, [buffer_size]
    sub rdx, 2 ; tirando quebras de linha
    xor rcx, rcx ; zerando, limpando rcx
    jmp .loop_inverter

    .loop_inverter:
        cmp rcx, rdx ; continua o loop até chegarem na metade da string
        jge .fim_loop

        mov al, [buffer + rcx] ; armazena "char[0]"
        mov bl, [buffer + rdx] ; armazena "char[-1]"

        mov [buffer + rcx], bl
        mov [buffer + rdx], al

        inc rcx
        dec rdx
        jmp .loop_inverter
        
    .fim_loop:
        ret

.print:
    mov rdx, rsi ; passando tamanho do que quer imprimir 
    mov rsi, rdi ; passando o que quer imprimir
    mov rax, 1 ; sys_write
    mov rdi, 1 ; formato stdout
    syscall
    ret

.encerrar_execucao:
    mov rax, 60 ; chamada do kernel
    mov rdi, 0 ; status code
    syscall