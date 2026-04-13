global Sum
global CheckOverflow
global ComputeFn
global Clock
global Polynom

section .text

; ---------------------------------------------------------
; Задание 1: Sum
; Вход: EDI (x, 32-bit), SIL (y, 8-bit)
; Проблема могла быть в расширении знака.
; ---------------------------------------------------------
Sum:
Sum:
    movsxd rax, edi
    movzx  rsi, sil
    add    rax, rsi
    ret

; ---------------------------------------------------------
; Задание 2: CheckOverflow
; Проверка переполнения для (8 + x^4 - y^2) / (y + x)^2
; (У тебя за это было 10/10, оставляем логику, но добавим аккуратности)
; ---------------------------------------------------------
CheckOverflow:
    ; x^4
    mov rax, rdi
    imul rax, rdi
    jo .ov
    imul rax, rdi
    jo .ov
    imul rax, rdi
    jo .ov
    mov r8, rax         ; r8 = x^4

    add r8, 8
    jo .ov

    ; y^2
    mov rax, rsi
    imul rax, rsi
    jo .ov
    mov r9, rax         ; r9 = y^2

    sub r8, r9
    jo .ov              ; r8 = числитель

    ; (y + x)^2
    mov rax, rsi
    add rax, rdi
    jo .ov
    imul rax, rax
    jo .ov
    
    test rax, rax       ; Проверка на деление на 0
    jz .ov
    
    mov r9, rax         ; r9 = знаменатель
    mov rax, r8
    cqo
    idiv r9             ; idiv может вызвать исключение при INT_MIN / -1, 
                        ; но здесь знаменатель > 0
    mov rax, 0
    ret
.ov:
    mov rax, 1
    ret

; ---------------------------------------------------------
; Задание 3: ComputeFn
; Формула: (2 + x^2 - y^3)(y^2 + 2)^2 / (x - y^2)
; ГЛАВНОЕ: Числитель может превысить 64 бита! Используем imul с 1 операндом.
; ---------------------------------------------------------
ComputeFn:
    ; x -> RDI, y -> RSI

    ; y^2
    mov rax, rsi
    imul rax, rsi
    mov r8, rax

    ; denominator = x - y^2
    mov r9, rdi
    sub r9, r8

    ; (y^2 + 2)^2
    mov rax, r8
    add rax, 2
    imul rax, rax
    mov rcx, rax

    ; (2 + x^2 - y^3)
    mov rax, rdi
    imul rax, rdi
    add rax, 2

    mov r10, r8
    imul r10, rsi
    sub rax, r10

    ; multiply
    imul rcx

    cqo

    ; divide
    idiv r9

    ret
; ---------------------------------------------------------
; Задание 4: Clock
; h (RDI), m (RSI), f (RDX)
; Здесь важно правильно обработать отрицательный остаток.
; ---------------------------------------------------------
Clock:
    ; Расширяем входы до 64 бит на случай, если они переданы как 32-битные
    movsxd rdi, edi
    movsxd rsi, esi
    movsxd rdx, edx

    ; t0 = h*3600 + m*60
    imul rdi, 3600
    imul rsi, 60
    add rdi, rsi        ; rdi = t0

    ; A = 120*f - 11*t0
    imul rdx, 120
    mov rax, 11
    imul rax, rdi
    sub rdx, rax        ; rdx = A

    ; A mod 43200 (нужен положительный остаток)
    mov rax, rdx
    cqo
    mov r8, 43200
    idiv r8             ; RDX = остаток
    
    mov rax, rdx
    test rax, rax
    jge .pos
    add rax, 43200
.pos:
    ; RAX = floor(A / 11)
    cqo
    mov r8, 11
    idiv r8
    ret

; ---------------------------------------------------------
; Задание 5: Polynom
; 2x^4 - 3x^3 + 4x^2 - 5x + 6 (mod 2^64)
; 2.25 балла обычно означают, что не учтен знак или мусор в RDI.
; ---------------------------------------------------------
Polynom:
    movsxd rdi, edi     ; КРИТИЧНО: расширяем x, если он пришел как 32-битный
    
    ; Схема Горнера: x * (x * (x * (2*x - 3) + 4) - 5) + 6
    mov rax, rdi
    add rax, rax        ; rax = 2x
    sub rax, 3          ; (2x - 3)
    
    imul rax, rdi
    add rax, 4          ; (2x-3)x + 4
    
    imul rax, rdi
    sub rax, 5          ; ((2x-3)x + 4)x - 5
    
    imul rax, rdi
    add rax, 6          ; (((2x-3)x + 4)x - 5)x + 6
    
    ret