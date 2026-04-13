; This solution uses SYSTEM V calling convention
; ###SKIP_FILE_NAME_CHECK

                    global  AsmStrLen
                    global  AsmStrChr
                    global  AsmStrCpy
                    global  AsmStrNCpy
                    global  AsmStrCmp
                    global  AsmStrCat
                    global  AsmStrStr
                    global  AsmStrToInt64
                    global  AsmIntToStr64
                    global  AsmSafeStrToUInt64

                    section .text

    AsmStrLen:
        mov rax, 0
    .loop1:
        cmp byte [rdi + rax], 0
        je .done1
        inc rax
        jmp .loop1
    .done1:
        ret

    AsmStrChr:
        mov rax, rdi
    .loop2:
        mov cl, byte [rax]
        cmp cl, sil
        je .done2
        cmp cl, 0
        je .not_found2
        inc rax
        jmp .loop2
    .not_found2:
        xor rax, rax
    .done2:
        ret

    AsmStrCpy:
        mov rax, rdi
    .loop3:
        mov cl, byte [rsi]
        mov byte [rdi], cl
        cmp cl, 0
        je .done3
        inc rdi
        inc rsi
        jmp .loop3
    .done3:
        ret

    AsmStrNCpy:
        mov rax, rdi
        mov rcx, 0
    .loop4:
        cmp rcx, rdx
        jae .done4
        mov r8b, byte [rsi]
        mov byte [rdi], r8b
        cmp r8b, 0
        je .pad4
        inc rdi
        inc rsi
        inc rcx
        jmp .loop4
    .pad4:
        inc rcx
        inc rdi
    .pad_loop4:
        cmp rcx, rdx
        jae .done4
        mov byte [rdi], 0
        inc rdi
        inc rcx
        jmp .pad_loop4
    .done4:
        ret

    AsmStrCmp:
    .loop5:
        mov cl, byte [rdi]
        mov dl, byte [rsi]
        cmp cl, dl
        jne .diff5
        cmp cl, 0
        je .equal5
        inc rdi
        inc rsi
        jmp .loop5
    .diff5:
        movzx rax, cl
        movzx rcx, dl
        sub rax, rcx
        ret
    .equal5:
        xor rax, rax
        ret

    AsmStrCat:
        mov rax, rdi
    .find_end6:
        cmp byte [rdi], 0
        je .copy6
        inc rdi
        jmp .find_end6
    .copy6:
        mov cl, byte [rsi]
        mov byte [rdi], cl
        cmp cl, 0
        je .done6
        inc rdi
        inc rsi
        jmp .copy6
    .done6:
        ret

    AsmStrStr:
        cmp byte [rsi], 0
        jne .search7
        mov rax, rdi
        ret
    .search7:
        mov rax, rdi
    .outer7:
        cmp byte [rax], 0
        je .not_found7
        mov rcx, 0
    .inner7:
        mov dl, byte [rsi + rcx]
        cmp dl, 0
        je .found7
        mov r8b, byte [rax + rcx]
        cmp r8b, 0
        je .not_found7
        cmp r8b, dl
        jne .next_outer7
        inc rcx
        jmp .inner7
    .next_outer7:
        inc rax
        jmp .outer7
    .not_found7:
        xor rax, rax
    .found7:
        ret

    AsmStrToInt64:
        xor rax, rax
        mov rcx, 1
    .skip_spaces8:
        cmp byte [rdi], ' '
        je .is_space8
        cmp byte [rdi], 9
        je .is_space8
        cmp byte [rdi], 10
        je .is_space8
        cmp byte [rdi], 13
        je .is_space8
        jmp .check_sign8
    .is_space8:
        inc rdi
        jmp .skip_spaces8
        
    .check_sign8:
        cmp byte [rdi], '-'
        je .negative8
        cmp byte [rdi], '+'
        je .positive_sign8
        jmp .loop8
    .negative8:
        mov rcx, -1
        inc rdi
        jmp .loop8
    .positive_sign8:
        inc rdi
    .loop8:
        movzx rdx, byte [rdi]
        cmp rdx, '0'
        jl .done8
        cmp rdx, '9'
        jg .done8
        sub rdx, '0'
        imul rax, 10
        add rax, rdx
        inc rdi
        jmp .loop8
    .done8:
        imul rax, rcx
        ret

    AsmIntToStr64:
        ; rdi = x, rsi = b, rdx = s
        mov r8, rdx
        mov r9, 0 ; is_negative
        mov rax, rdi
        
        ; Check if negative
        cmp rax, 0
        jge .positive9
        mov r9, 1
        neg rax
    .positive9:
        mov rcx, 0 ; length
    .loop9:
        xor rdx, rdx
        div rsi
        cmp rdx, 10
        jl .digit9
        add rdx, 'a' - 10
        jmp .store9
    .digit9:
        add rdx, '0'
    .store9:
        push rdx
        inc rcx
        cmp rax, 0
        jne .loop9
        
        cmp r9, 0
        je .pop_loop9
        mov byte [r8], '-'
        inc r8
    .pop_loop9:
        cmp rcx, 0
        je .done9
        pop rdx
        mov byte [r8], dl
        inc r8
        dec rcx
        jmp .pop_loop9
    .done9:
        mov byte [r8], 0
        ret

    AsmSafeStrToUInt64:
        ; rdi = s, rsi = result
        xor rax, rax
        mov rcx, 0 ; valid flag
        cmp byte [rdi], 0
        je .invalid10
        cmp byte [rdi], '-'
        je .invalid10
    .loop10:
        movzx rdx, byte [rdi]
        cmp rdx, 0
        je .done10
        cmp rdx, '0'
        jl .invalid10
        cmp rdx, '9'
        jg .invalid10
        sub rdx, '0'
        
        ; check overflow: rax * 10 + rdx > 2^64 - 1
        ; rax * 10 > 2^64 - 1 - rdx
        ; if rax > (2^64 - 1) / 10, overflow
        ; (2^64 - 1) / 10 = 1844674407370955161
        mov r8, 1844674407370955161
        cmp rax, r8
        ja .invalid10
        jb .safe10
        ; if rax == 1844674407370955161, rdx must be <= 5
        cmp rdx, 5
        ja .invalid10
    .safe10:
        imul rax, 10
        add rax, rdx
        inc rdi
        jmp .loop10
    .invalid10:
        xor rax, rax
        ret
    .done10:
        mov qword [rsi], rax
        mov rax, 1
        ret