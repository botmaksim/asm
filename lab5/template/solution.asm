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
        push rbx
        
        mov edi, edi
        mov esi, esi
        movsxd rdx, edx
        mov ecx, ecx
        mov r8d, r8d
        
        ; Point 1: (rcx, r8)
        mov rax, rdi
        sub rax, rcx
        imul rax, rax
        mov r10, rax
        
        mov rax, rsi
        sub rax, r8
        imul rax, rax
        
        add r10, rax
        setc r11b
        movzx r11, r11b
        
        mov r12, r10
        mov r13, r11
        mov rbx, 0
        
        cmp rdx, 1
        jle .done1
        
        ; Point 2: (r9, [rsp+48])
        mov r9d, r9d
        mov r14d, dword [rsp+48]
        
        mov rax, rdi
        sub rax, r9
        imul rax, rax
        mov r10, rax
        
        mov rax, rsi
        sub rax, r14
        imul rax, rax
        
        add r10, rax
        setc r11b
        movzx r11, r11b
        
        cmp r11, r13
        ja .next2
        jb .update2
        cmp r10, r12
        jae .next2
    .update2:
        mov r12, r10
        mov r13, r11
        mov rbx, 1
    .next2:
        cmp rdx, 2
        jle .done1
        
        mov r15, 2
        mov r14, 56
    .loop1:
        cmp r15, rdx
        jge .done1
        
        mov rax, rdi
        mov ecx, dword [rsp+r14]
        sub rax, rcx
        imul rax, rax
        mov r10, rax
        
        mov rax, rsi
        mov ecx, dword [rsp+r14+8]
        sub rax, rcx
        imul rax, rax
        
        add r10, rax
        setc r11b
        movzx r11, r11b
        
        cmp r11, r13
        ja .next_i1
        jb .update_i1
        cmp r10, r12
        jae .next_i1
    .update_i1:
        mov r12, r10
        mov r13, r11
        mov rbx, r15
    .next_i1:
        inc r15
        add r14, 16
        jmp .loop1
        
    .done1:
        mov rax, rbx
        pop rbx
        pop r15
        pop r14
        pop r13
        pop r12
        ret

    AsmSummarizeRows:
        movsxd rsi, esi
        movsxd rdx, edx
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
        movsxd rsi, esi
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
        push rbx
        
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
        push rbx
        
        mov r12, rdi
        mov esi, esi
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
        ; rdi = N, rsi = K
        ; we want C(N - K + 1, K)
        mov rax, rdi
        sub rax, rsi
        inc rax ; rax = n = N - K + 1
        
        cmp rax, rsi
        jl .zero6
        
        ; C(n, k) where n = rax, k = rsi
        mov rcx, rax
        sub rcx, rsi
        cmp rsi, rcx
        jle .k_ok6
        mov rsi, rcx
    .k_ok6:
        mov r8, 1 ; result
        mov r9, 1 ; i
    .loop6:
        cmp r9, rsi
        jg .done6
        
        mov r10, rax
        sub r10, r9
        inc r10 ; r10 = n - i + 1
        
        push rax
        mov rax, r8
        mul r10 ; rdx:rax = r8 * r10
        div r9  ; rax = rdx:rax / r9
        mov r8, rax
        pop rax
        
        inc r9
        jmp .loop6
    .zero6:
        mov rax, 0
        ret
    .done6:
        mov rax, r8
        ret

