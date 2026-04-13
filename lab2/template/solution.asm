bits 64
global Positivity
global CheckOverflow
global Function
global IsInCircle
global TwoIntegers
global CountNumbers
global Switch
global MagicMetric

section .data
    str_pos   db "Yeah) It's positive :D", 0
    str_neg   db "Ohh.. so much negative :(", 0

    str_bad   db "That's bad", 0
    str_nocom db "No comments.", 0
    str_notb  db "Not bad...", 0
    str_nice  db "Nice :)", 0
    str_perf  db "Perfecto!!!", 0
    str_oops  db "Ooops", 0

section .text

; ------------------------------------------------------------------------------
; 1. Positivity
; ------------------------------------------------------------------------------
Positivity:
    cmp rdi, 0
    jg .pos
    lea rax, [rel str_neg]
    ret
.pos:
    lea rax, [rel str_pos]
    ret

; ------------------------------------------------------------------------------
; 2. CheckOverflow
; ------------------------------------------------------------------------------
CheckOverflow:
    mov rax, rdi
    add rax, rsi
    jo .overflow
    imul rax, rax
    jo .overflow
    mov rcx, rax

    cmp rcx, 0
    je .overflow

    mov rax, rdi
    imul rax, rax
    jo .overflow
    imul rax, rax
    jo .overflow
    mov r8, rax

    mov rax, rsi
    imul rax, rax
    jo .overflow
    mov r9, rax

    mov rax, 8
    add rax, r8
    jo .overflow
    sub rax, r9
    jo .overflow

    cqo
    idiv rcx

    xor rax, rax
    ret

.overflow:
    mov rax, 1
    ret

; ------------------------------------------------------------------------------
; 3. Function
; ------------------------------------------------------------------------------
Function:
    cmp rdi, -1
    jl .case1
    cmp rdi, 17
    jg .case3

    mov rax, rdi
    imul rax, rax
    mov rcx, 36
    sub rcx, rax

    mov rax, 3
    imul rax, rdi
    mov r8, 10
    sub r8, rax

    mov rax, rcx
    cqo
    idiv r8

    cmp rdx, 0
    je .done
    xor rdx, r8
    js .done
    add rax, 1
    ret

.case1:
    mov rax, rdi
    imul rax, rax
    imul rax, 2
    sub rax, 3
    ret

.case3:
    mov rax, rdi
    imul rax, rax
    imul rax, rdi
    neg rax
    sub rax, 2

.done:
    ret

; ------------------------------------------------------------------------------
; 4. IsInCircle
; ------------------------------------------------------------------------------
IsInCircle:
    ; Вычисляем X^2
    mov rax, rdi
    imul rax, rax

    ; Вычисляем Y^2
    mov rcx, rsi
    imul rcx, rcx

    ; Вычисляем 4 * (X^2 + Y^2)
    add rcx, rax
    shl rcx, 2      ; сдвиг влево на 2 работает быстрее и эквивалентен умножению на 4

    ; Вычисляем D^2 (128-битное беззнаковое умножение)
    mov rax, rdx
    mul rax         ; умножает rax на rax, результат сохраняется в rdx:rax

    ; Проверяем старшие 64 бита от D^2
    test rdx, rdx
    jnz .in         ; если rdx > 0, то D^2 >= 2^64, точка точно внутри круга

    ; Если D^2 поместился в 64 бита, сравниваем с 4*(X^2+Y^2)
    cmp rcx, rax
    jbe .in         ; используем jbe (беззнаковое <=), так как D^2 может быть >= 2^63

    xor rax, rax
    ret

.in:
    mov rax, 1
    ret
; ------------------------------------------------------------------------------
; 5. TwoIntegers
; ------------------------------------------------------------------------------
TwoIntegers:
    cmp rsi, 0
    je .check2

    mov rax, rdi
    cqo
    idiv rsi
    cmp rdx, 0
    je .yes

.check2:
    cmp rdi, 0
    je .no

    mov rax, rsi
    cqo
    idiv rdi
    cmp rdx, 0
    je .yes

.no:
    xor rax, rax
    ret
.yes:
    mov rax, 1
    ret

; ------------------------------------------------------------------------------
; 6. CountNumbers
; ------------------------------------------------------------------------------
CountNumbers:
    mov r8, rdi
    mov r9, rsi
    mov r10, rdx

    mov rcx, r8
    cmp r9, rcx
    jge .m1
    mov rcx, r9
.m1:
    cmp r10, rcx
    jge .m2
    mov rcx, r10
.m2:

    xor r11, r11

    mov rax, r8
    cqo
    idiv rcx
    and rdx, 1
    add r11, rdx

    mov rax, r9
    cqo
    idiv rcx
    and rdx, 1
    add r11, rdx

    mov rax, r10
    cqo
    idiv rcx
    and rdx, 1
    add r11, rdx

    mov rax, r11
    ret

; ------------------------------------------------------------------------------
; 7. Switch
; ------------------------------------------------------------------------------
Switch:
    cmp rdi, 0
    je .bad
    cmp rdi, 1
    je .bad
    cmp rdi, 2
    je .bad
    cmp rdi, 5
    je .bad

    cmp rdi, 4
    je .nocom
    cmp rdi, 42
    je .nocom
    cmp rdi, 43
    je .nocom

    cmp rdi, 13
    je .notbad

    cmp rdi, -99
    je .nice
    cmp rdi, -100
    je .nice

    cmp rdi, 10
    je .perf
    cmp rdi, 100
    je .perf
    cmp rdi, 1000
    je .perf

    lea rax, [rel str_oops]
    ret

.bad:
    lea rax, [rel str_bad]
    ret
.nocom:
    lea rax, [rel str_nocom]
    ret
.notbad:
    lea rax, [rel str_notb]
    ret
.nice:
    lea rax, [rel str_nice]
    ret
.perf:
    lea rax, [rel str_perf]
    ret

; ------------------------------------------------------------------------------
; 8. MagicMetric
; ------------------------------------------------------------------------------
MagicMetric:
    mov rax, rdi

    ; Проверка на восьмизначность
    cmp rax, 10000000
    jl .not8
    cmp rax, 99999999
    jg .not8

    sub rsp, 16

    mov rcx, 10
    xor r8, r8

.extract:
    xor rdx, rdx
    div rcx
    mov byte [rsp + r8], dl
    inc r8
    cmp r8, 8
    jl .extract

    xor r9, r9

    ; --- cond1 ---
    ; среди младших четырех цифр (разряды 0, 1, 2, 3) есть хотя бы одна двойка
    cmp byte [rsp], 2
    je .c1
    cmp byte [rsp+1], 2
    je .c1
    cmp byte [rsp+2], 2
    je .c1
    cmp byte [rsp+3], 2
    jne .c2
.c1:
    inc r9

.c2:
    ; --- cond2 ---
    ; сумма пятой и седьмой цифр (разряды 5 и 7) больше 5
    movzx eax, byte [rsp+5]
    movzx ecx, byte [rsp+7]
    add eax, ecx
    cmp eax, 5
    jle .c3
    inc r9

.c3:
    ; --- cond3 ---
    ; вторая и шестая цифра равны (разряды 2 и 6)
    mov al, [rsp+2]
    cmp al, [rsp+6]
    jne .c4
    inc r9

.c4:
    ; --- cond4 ---
    ; число является палиндромом
    mov al, [rsp]
    cmp al, [rsp+7]
    jne .done
    mov al, [rsp+1]
    cmp al, [rsp+6]
    jne .done
    mov al, [rsp+2]
    cmp al, [rsp+5]
    jne .done
    mov al, [rsp+3]
    cmp al, [rsp+4]
    jne .done
    inc r9

.done:
    mov rax, r9
    add rsp, 16
    ret

.not8:
    xor rax, rax
    ret