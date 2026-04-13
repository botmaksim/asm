; This solution uses SYSTEM V calling convention
; ###SKIP_FILE_NAME_CHECK

                    global  AsmTask1
                    global  AsmTask2
                    global  AsmTask3
                    global  AsmTask4
                    global  AsmTask5
                    global  AsmTask6
                    global  AsmTask7
                    global  AsmTask8

                    section .data
    c42 dd 42.0
    c24 dd 24.0
    c17 dd 17.0
    eps dq 0.000001
    c1_0 dq 1.0
    abs_mask dq 0x7FFFFFFFFFFFFFFF
    log10_e dq 0.4342944819032518
    align 16
    mask511 dd 0xFFFFFE00, 0xFFFFFE00, 0xFFFFFE00, 0xFFFFFE00

                    section .text

    AsmTask1:
        fld dword [rdi]      ; st0 = x
        fmul dword [rel c42] ; st0 = 42x
        fsqrt                ; st0 = sqrt(42x)
        
        fld dword [rsi]      ; st0 = y, st1 = sqrt(42x)
        fmul dword [rel c24] ; st0 = 24y, st1 = sqrt(42x)
        
        fld dword [rsi]      ; st0 = y, st1 = 24y, st2 = sqrt(42x)
        fmul st0, st0        ; st0 = y^2
        fmul dword [rel c24] ; st0 = 24y^2
        
        fsubp st1, st0       ; st0 = 24y - 24y^2, st1 = sqrt(42x)
        fadd dword [rel c17] ; st0 = 24y - 24y^2 + 17
        
        fdivp st1, st0       ; st0 = sqrt(42x) / (24y - 24y^2 + 17)
        fstp dword [rdx]
        ret

    AsmTask2:
        sub rsp, 8
        movsd [rsp], xmm0
        
        fld qword [rsp]      ; st0 = x
        fadd st0, st0        ; st0 = 2x
        fptan                ; st0 = 1, st1 = tan(2x)
        fstp st0             ; st0 = tan(2x)
        
        fld qword [rsp]      ; st0 = x, st1 = tan(2x)
        fcos                 ; st0 = cos(x), st1 = tan(2x)
        fadd st0, st0        ; st0 = 2cos(x), st1 = tan(2x)
        
        fld qword [rsp]      ; st0 = x, st1 = 2cos(x), st2 = tan(2x)
        fsin                 ; st0 = sin(x), st1 = 2cos(x), st2 = tan(2x)
        
        faddp st1, st0       ; st0 = sin(x) + 2cos(x), st1 = tan(2x)
        fsubrp st1, st0      ; st0 = sin(x) + 2cos(x) - tan(2x)
        
        fstp qword [rsp]
        movsd xmm0, [rsp]
        add rsp, 8
        ret

    AsmTask3:
        sub rsp, 16
        movsd [rsp], xmm0
        movsd [rsp+8], xmm1
        
        fldl2e               ; st0 = log2(e)
        fldlg2               ; st0 = log10(2), st1 = log2(e)
        fmulp                ; st0 = log10(e)
        
        fld qword [rsp+8]    ; st0 = y, st1 = log10(e)
        fadd st0, st0        ; st0 = 2y
        fld1                 ; st0 = 1, st1 = 2y
        fsubp st1, st0       ; st0 = 2y - 1
        fabs                 ; st0 = |2y - 1|
        fld1                 ; st0 = 1, st1 = |2y - 1|
        faddp st1, st0       ; st0 = 1 + |2y - 1|
        
        fld qword [rsp]      ; st0 = x, st1 = 1 + |2y - 1|, st2 = log10(e)
        fmul st0, st0        ; st0 = x^2, st1 = 1 + |2y - 1|, st2 = log10(e)
        
        fxch st1             ; st0 = 1 + |2y - 1|, st1 = x^2, st2 = log10(e)
        
        fyl2x                ; st0 = x^2 * log2(1 + |2y - 1|), st1 = log10(e)
        
        fsubrp st1, st0      ; st0 = x^2 * log2(...) - log10(e)
        
        fstp qword [rdi]
        add rsp, 16
        ret

    AsmTask4:
        sub rsp, 8
        fldz                 ; st0 = sum = 0
        
        test edi, edi
        jz .done4
        
        fadd qword [rsi]     ; sum += a[0]
        
        mov ecx, 1           ; i = 1
        
    .loop4:
        cmp ecx, edi
        jge .done4
        
        movsxd rax, dword [rdx + rcx*4]
        imul rax, -2
        push rax
        fild qword [rsp]        ; st0 = -2 * b[i], st1 = sum
        add rsp, 8
        
        fld1                    ; st0 = 1, st1 = -2 * b[i], st2 = sum
        mov r10, rcx
    .pow_loop4:
        test r10, r10
        jz .pow_done4
        fmul st0, st1
        dec r10
        jmp .pow_loop4
    .pow_done4:
        fxch st1
        fstp st0                ; pop. st0 = (-2 * b[i])^i, st1 = sum
        
        fld qword [rsi + rcx*8] ; st0 = a[i], st1 = (-2 * b[i])^i, st2 = sum
        fsqrt                   ; st0 = sqrt(a[i])
        fmulp st1, st0          ; st0 = sqrt(a[i]) * (-2 * b[i])^i, st1 = sum
        
        faddp st1, st0          ; sum += term
        
        inc ecx
        jmp .loop4
        
    .done4:
        fstp qword [rsp]
        movsd xmm0, [rsp]
        add rsp, 8
        ret

    AsmTask5:
        mov rcx, 0
        movsxd r8, edi
    .loop5:
        cmp rcx, r8
        jge .equal5
        
        fld qword [rsi + rcx*8]
        fsub qword [rdx + rcx*8]
        fabs
        fcomp qword [rel eps]
        fstsw ax
        sahf
        ja .not_equal5
        
        inc rcx
        jmp .loop5
        
    .equal5:
        mov rax, 1
        ret
    .not_equal5:
        xor rax, rax
        ret

    AsmTask6:
        ; x in xmm0, y in xmm1, result in rdi
        movsd xmm2, xmm1
        addsd xmm2, xmm2     ; 2y
        movsd xmm3, [rel c1_0]
        subsd xmm2, xmm3     ; 2y - 1
        
        movq xmm4, [rel abs_mask]
        pand xmm2, xmm4      ; |2y - 1|
        
        addsd xmm2, xmm3     ; 1 + |2y - 1|
        
        mulsd xmm0, xmm0     ; x^2
        
        ; compute log2(1 + |2y - 1|) using x87
        sub rsp, 8
        movsd [rsp], xmm2
        fld qword [rsp]
        fld1
        fxch st1
        fyl2x
        fstp qword [rsp]
        movsd xmm2, [rsp]
        add rsp, 8
        
        mulsd xmm0, xmm2     ; x^2 * log2(...)
        
        movsd xmm3, [rel log10_e]
        subsd xmm0, xmm3     ; - log10(e)
        
        movsd [rdi], xmm0
        ret

    AsmTask7:
        movsxd r8, edi
        test r8, r8
        jle .false7
        
        mov rcx, 0
        movdqa xmm1, [rel mask511]
        
        mov r9, r8
        and r9, ~3
    .loop7_sse:
        cmp rcx, r9
        jge .loop7_rem
        
        movdqu xmm0, [rsi + rcx*4]
        pand xmm0, xmm1
        
        pxor xmm2, xmm2
        pcmpeqd xmm0, xmm2
        pmovmskb eax, xmm0
        cmp eax, 0xFFFF
        jne .true7
        
        add rcx, 4
        jmp .loop7_sse
        
    .loop7_rem:
        cmp rcx, r8
        jge .false7
        mov eax, dword [rsi + rcx*4]
        cmp eax, 511
        ja .true7
        inc rcx
        jmp .loop7_rem
        
    .true7:
        mov rax, 1
        ret
    .false7:
        xor rax, rax
        ret

    AsmTask8:
        movsxd r8, edi
        xorpd xmm0, xmm0     ; sum = 0
        mov rcx, 0
        
        mov r9, r8
        and r9, ~1           ; process 2 doubles at a time
    .loop8_sse:
        cmp rcx, r9
        jge .loop8_rem
        
        movupd xmm1, [rsi + rcx*8]
        movupd xmm2, [rdx + rcx*8]
        subpd xmm1, xmm2
        mulpd xmm1, xmm1
        addpd xmm0, xmm1
        
        add rcx, 2
        jmp .loop8_sse
        
    .loop8_rem:
        cmp rcx, r8
        jge .done8
        
        movsd xmm1, [rsi + rcx*8]
        movsd xmm2, [rdx + rcx*8]
        subsd xmm1, xmm2
        mulsd xmm1, xmm1
        addsd xmm0, xmm1
        
        inc rcx
        jmp .loop8_rem
        
    .done8:
        movapd xmm1, xmm0
        unpckhpd xmm1, xmm1
        addsd xmm0, xmm1
        
        sqrtsd xmm0, xmm0
        ret