; This solution uses SYSTEM V calling convention
; ###SKIP_FILE_NAME_CHECK

                    global  AsmFindNearest
                    global  AsmSummarizeRows
                    global  AsmCountIfNot
                    global  AsmGetMoreMagic
                    global  AsmCopy
                    global  AsmSequencesCount

                    section .text

    AsmFindNearest:
        push r12
        push r13
        push r14
        push r15
        
        mov edi, edi
        mov esi, esi
        mov edx, edx
        
        ; Point 1: (rcx, r8)
        mov ecx, ecx
        mov r8d, r8d
        
        mov r10, rdi
        sub r10, rcx
        imul r10, r10
        mov r11, rsi
        sub r11, r8
        imul r11, r11
        add r10, r11
        
        mov r12, r10
        mov r13, 0
        
        cmp rdx, 1
        jle .done1
        
        ; Point 2: (r9, [rsp+40])
        mov r9d, r9d
        mov r14d, dword [rsp+40]
        
        mov r10, rdi
        sub r10, r9
        imul r10, r10
        mov r11, rsi
        sub r11, r14
        imul r11, r11
        add r10, r11
        
        cmp r10, r12
        jge .next2
        mov r12, r10
        mov r13, 1
    .next2:
        cmp rdx, 2
        jle .done1
        
        mov r15, 2
        mov r14, 48
    .loop1:
        cmp r15, rdx
        jge .done1
        
        mov r10, rdi
        mov ecx, dword [rsp+r14]
        sub r10, rcx
        imul r10, r10
        
        mov r11, rsi
        mov ecx, dword [rsp+r14+8]
        sub r11, rcx
        imul r11, r11
        
        add r10, r11
        
        cmp r10, r12
        jge .next_i1
        mov r12, r10
        mov r13, r15
    .next_i1:
        inc r15
        add r14, 16
        jmp .loop1
        
    .done1:
        mov rax, r13
        pop r15
        pop r14
        pop r13
        pop r12
        ret

    AsmSummarizeRows:
        mov r8, 0
    .loop_i2:
        cmp r8, rsi
        jge .done2
        mov r9, qword [rdi + r8*8]
        mov r10, 0
        xor r11, r11
    .loop_j2:
        cmp r10, rdx
        jge .next_i2
        add r11, qword [r9 + r10*8]
        inc r10
        jmp .loop_j2
    .next_i2:
        mov qword [rcx + r8*8], r11
        inc r8
        jmp .loop_i2
    .done2:
        ret

    AsmCountIfNot:
        push r12
        push r13
        push r14
        push r15
        push rbx
        
        mov r12, rdi
        mov r13, rsi
        mov r14, rdx
        xor r15, r15
        xor rbx, rbx
        
    .loop3:
        cmp rbx, r13
        jge .done3
        
        movzx rdi, word [r12 + rbx*2]
        call r14
        
        test al, al
        jnz .next3
        inc r15
    .next3:
        inc rbx
        jmp .loop3
        
    .done3:
        mov rax, r15
        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12
        ret

    extern GetMagic
    
    AsmGetMoreMagic:
        push r12
        push r13
        push r14
        push r15
        push rbx ; 5 pushes = 40 bytes. + 8 (ret addr) = 48 bytes. Aligned to 16 bytes.
        
        mov rdi, 1
        call GetMagic
        mov r12, rax
        
        mov rdi, 2
        call GetMagic
        mov rdi, rax
        call GetMagic
        mov r13, rax
        
        mov rdi, 3
        call GetMagic
        mov rdi, rax
        call GetMagic
        mov rdi, rax
        call GetMagic
        mov r14, rax
        
        mov rax, r12
        imul rax, r13
        imul rax, r14
        
        imul rax, rax
        
        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12
        ret

    extern malloc
    extern free
    
    AsmCopy:
        push r12
        push r13
        push r14
        push r15
        push rbx ; 5 pushes = 40 bytes. + 8 (ret addr) = 48 bytes. Aligned to 16 bytes.
        
        mov r12, rdi
        mov r13, rsi
        
        mov rdi, rsi
        call malloc
        mov r14, rax
        
        test r14, r14
        jz .done5
        
        mov rcx, r13
        mov rsi, r12
        mov rdi, r14
        rep movsb
        
    .done5:
        mov rax, r14
        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12
        ret

    AsmSequencesCount:
        ; rdi = n, rsi = k
        mov rax, 0
        test rsi, rsi
        jl .done6
        
        mov rcx, rdi
        sub rcx, rsi
        inc rcx      ; rcx = N = n - k + 1
        
        cmp rcx, rsi
        jl .done6     ; if N < K, return 0
        
        mov rax, 1
        mov r8, 1    ; i = 1
    .loop6:
        cmp r8, rsi
        jg .done6
        
        mov r9, rcx
        sub r9, r8
        inc r9       ; r9 = N - i + 1
        
        mul r9       ; rdx:rax = rax * r9
        div r8       ; rax = rax / i
        
        inc r8
        jmp .loop6
        
    .done6:
        ret