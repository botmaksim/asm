bits 32
section .text
global CalculateCos

CalculateCos:
    push ebp
    mov ebp, esp
    
    ; Выделяем 24 байта под локальные переменные:
    ; [ebp-4]  = x^2 (float)
    ; [ebp-8]  = 2i-1 (int)
    ; [ebp-12] = 2i (int)
    ; [ebp-16] = N (int)
    ; [ebp-20] = delta (float*)
    sub esp, 24
    
    ; Сохраняем N и delta в стек (в fastcall они приходят в ECX и EDX)
    mov [ebp-16], ecx
    mov [ebp-20], edx

    ; 1. Вычисляем x = pi/4
    finit               ; Сброс состояния FPU (защита от мусора из C++)
    fldpi               ; st0 = pi
    fld1                ; st0 = 1, st1 = pi
    fadd st0, st0       ; st0 = 2, st1 = pi
    fadd st0, st0       ; st0 = 4, st1 = pi
    fdivp st1, st0      ; st0 = pi / 4  (наш x)
    
    ; 2. Вычисляем x^2
    fld st0             ; st0 = x, st1 = x
    fmul st0, st0       ; st0 = x^2, st1 = x
    fstp dword [ebp-4]  ; [ebp-4] = x^2. В стеке FPU остается st0 = x

    ; 3. Инициализация ряда
    fld1                ; st0 = 1.0 (текущий член a0), st1 = x
    fld1                ; st0 = 1.0 (сумма S), st1 = a0, st2 = x
    
    mov ecx, [ebp-16]
    cmp ecx, 1
    jle .finish         ; Если N <= 1, идем к финалу

    dec ecx             ; Нам нужно N-1 итераций
    mov eax, 1          ; i = 1

.loop_s:
    ; Считаем 2i-1 и 2i (используем EDX вместо EBX, чтобы не уронить C++)
    mov edx, eax
    shl edx, 1          ; 2i
    mov [ebp-12], edx
    dec edx             ; 2i-1
    mov [ebp-8], edx

    ; Считаем новый член ряда: Term = Term * (-x^2) / ((2i-1) * 2i)
    fld st1             ; st0 = Term, st1 = Sum, st2 = Term, st3 = x
    fchs                ; st0 = -Term
    fmul dword [ebp-4]  ; st0 = -Term * x^2
    
    fild dword [ebp-8]  ; st0 = 2i-1
    fdivp st1, st0      ; st0 = (-Term * x^2) / (2i-1)
    
    fild dword [ebp-12] ; st0 = 2i
    fdivp st1, st0      ; st0 = Term_new

    ; Прибавляем к сумме
    fadd st1, st0       ; st1 = Sum + Term_new
    
    ; Магия FPU: обновляем Term_old на Term_new и убираем лишнее из стека
    fstp st2            ; st0 = Sum_new, st1 = Term_new, st2 = x

    inc eax
    loop .loop_s

.finish:
    ; Сейчас в стеке FPU: st0 = Sum, st1 = Term, st2 = x
    fstp st1            ; Удаляем последний Term. Теперь: st0 = Sum, st1 = x
    
    fld st1             ; Копируем x. Теперь: st0 = x, st1 = Sum, st2 = x
    fcos                ; st0 = cos(x), st1 = Sum, st2 = x
    fsub st0, st1       ; st0 = cos(x) - Sum (это наша delta)
    
    mov edx, [ebp-20]   ; Загружаем указатель на delta
    fstp dword [edx]    ; Сохраняем разницу. Теперь: st0 = Sum, st1 = x
    
    fstp st1            ; Удаляем x. В стеке FPU остался только Sum (st0) для C++
    
    mov esp, ebp
    pop ebp
    ret