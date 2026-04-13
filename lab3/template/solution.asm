global AsmBitCount
global AsmFactorial
global AsmIsSquare
global AsmRemoveDigits
global AsmFormula
global AsmBankDeposit
global AsmEvenDivisors
global AsmInfiniteManipulations

section .text

; Task 1: Количество единиц в битовом представлении
AsmBitCount:
    xor rax, rax
.loop1:
    test rdi, rdi
    jz .done1
    mov rdx, rdi
    dec rdx
    and rdi, rdx
    inc rax
    jmp .loop1
.done1:
    ret

; Task 2: Наименьшее число вида r!, превосходящее n
AsmFactorial:
    movsxd rdi, edi
    mov rax, 1
    mov rcx, 1
.loop2:
    cmp rax, rdi
    jg .done2
    inc rcx
    imul rax, rcx
    jmp .loop2
.done2:
    ret

; Task 3: Является ли число полным квадратом O(log X)
AsmIsSquare:
    test rdi, rdi
    js .not_found3
    mov rsi, 0
    mov rcx, 4294967295
.loop3:
    cmp rsi, rcx
    ja .not_found3
    
    mov r8, rsi
    add r8, rcx
    shr r8, 1
    
    mov rax, r8
    mul r8
    
    cmp rdx, 0
    jne .too_big3
    
    cmp rax, rdi
    je .found3
    ja .too_big3
    
.too_small3:
    mov rsi, r8
    inc rsi
    jmp .loop3
    
.too_big3:
    mov rcx, r8
    dec rcx
    jmp .loop3

.found3:
    mov rax, 1
    ret
.not_found3:
    xor rax, rax
    ret

; Task 4: Выбросить все четные цифры
AsmRemoveDigits:
    movsxd rdi, edi
    mov r8, rdi
    mov r9, 1
    test rdi, rdi
    jns .positive4
    mov r9, -1
    neg rdi
.positive4:
    mov rcx, 10
    xor r10, r10
    mov r11, 1
    
.loop4:
    test rdi, rdi
    jz .done4
    
    mov rax, rdi
    xor rdx, rdx
    div rcx
    mov rdi, rax
    
    test rdx, 1
    jz .loop4
    
    mov rax, rdx
    mul r11
    add r10, rax
    
    mov rax, r11
    mul rcx
    mov r11, rax
    
    jmp .loop4
    
.done4:
    mov rax, r10
    imul rax, r9
    ret

; Task 5: Вычисление произведения с проверкой переполнения
AsmFormula:
    mov rcx, 1
    mov r8, 1
    mov r9, 1
    
.loop5:
    cmp rcx, rsi
    jg .done5
    
    mov rax, r8
    imul rax, rdi
    jo .overflow5
    
    mov r10, rcx
    inc r10
    
    test rcx, 1
    jnz .odd5
.even5:
    add rax, r10
    jo .overflow5
    jmp .next_pk5
.odd5:
    sub rax, r10
    jo .overflow5
    
.next_pk5:
    mov r8, rax
    
    mov rax, r9
    imul rax, r8
    jo .overflow5
    mov r9, rax
    
    inc rcx
    jmp .loop5
    
.done5:
    mov rax, r9
    ret
    
.overflow5:
    mov rax, -1
    ret

; Task 6: Капитализация вклада
AsmBankDeposit:
    movsxd r10, edx     ; ИСПРАВЛЕНИЕ: сохраняем Z (rdx) в r10, так как div затирает rdx
    movsxd rsi, esi
    mov rax, rdi
    mov rcx, 0
    mov r8, 100
    
.loop6:
    cmp rcx, r10     ; Сравниваем с сохраненным Z
    jae .done6
    
    mov r9, rax
    mul rsi          ; rdx:rax = rax * rsi
    div r8           ; rax = (rdx:rax) / 100
    
    add rax, r9      ; rax = rax + original_amount
    
    inc rcx
    jmp .loop6
    
.done6:
    ret

; Task 7: Количество ровных делителей
AsmEvenDivisors:
    movzx rdi, di
    xor r8, r8
    mov rcx, 1
    
.loop7:
    mov rax, rcx
    mul rcx
    test rdx, rdx    ; ИСПРАВЛЕНИЕ: проверка переполнения rcx*rcx для очень больших n
    jnz .done7
    cmp rax, rdi
    jae .done7
    
    mov rax, rdi
    xor rdx, rdx
    div rcx
    
    test rdx, rdx
    jnz .next7
    
    mov r9, rax
    dec r9
    cmp rcx, r9
    jae .next7
    
    inc r8
    
.next7:
    inc rcx
    jmp .loop7
    
.done7:
    mov rax, r8
    ret

; Task 8: Бесконечные манипуляции с битами
AsmInfiniteManipulations:
    mov r8, rdi
    xor rcx, rcx
.count_loop8:
    test r8, r8
    jz .count_done8
    mov rdx, r8
    dec rdx
    and r8, rdx
    inc rcx
    jmp .count_loop8
.count_done8:
    
    cmp rcx, 64
    je .all_ones8
    cmp rcx, 0
    je .zero8
    
    mov r9, 1
    shl r9, cl
    dec r9
    
    mov r10, 64
    sub r10, rcx
    mov rcx, r10
    mov r10, r9
    shl r10, cl
    
    mov rax, r10
    sub rax, r9
    ret

.all_ones8:
.zero8:
    xor rax, rax
    ret