; This solution uses SYSTEM V calling convention
; ###SKIP_FILE_NAME_CHECK

                    global  AsmProduct
                    global  AsmSpecialXor
                    global  AsmSpecialSum
                    global  AsmNeighboursCount
                    global  AsmArrayFormula
                    global  AsmCompare
                    global  AsmSimpleModify
                    global  AsmSetToSequence
                    global  AsmReverse
                    global  AsmRotateInGroups
                    global  AsmInsertElement
                    global  AsmRemoveIfSimilar
                    global  AsmReplaceWithGroup
                    global  AsmMerge
                    global  AsmFindSpecial
                    global  AsmFindSorted
                    global  AsmModify2D

                    section .text

    AsmProduct:
        movsxd rsi, esi
        movsxd r9, edx
        mov rax, 1
        test rsi, rsi
        jle .done1
        mov rcx, 0
    .loop1:
        movsxd r8, dword [rdi + rcx*4]
        imul rax, r8
        cqo
        idiv r9
        mov rax, rdx
        inc rcx
        cmp rcx, rsi
        jl .loop1
    .done1:
        ret

    AsmSpecialXor:
        mov esi, esi
        xor rax, rax
        test rsi, rsi
        jle .done2
        mov rcx, 0
    .loop2:
        mov r8d, dword [rdi + rcx*4]
        test r8d, r8d
        jz .next2
        mov r9d, r8d
        dec r9d
        test r8d, r9d
        jnz .next2
        xor eax, r8d
    .next2:
        inc rcx
        cmp rcx, rsi
        jl .loop2
    .done2:
        ret

    AsmSpecialSum:
        mov r9, rdx
        xor r10, r10
        test rsi, rsi
        jle .done3
        mov rcx, 0
    .loop3:
        mov r8, qword [rdi + rcx*8]
        mov rax, r8
        mov r11, 3
        cqo
        idiv r11
        
        ; Adjust remainder for negative numbers (modulo arithmetic)
        cmp rdx, 0
        jge .pos_mod3
        add rdx, 3
    .pos_mod3:
        test rdx, 1
        jz .next3
        
        mov rax, r8
        mov r11, 5
        cqo
        idiv r11
        
        ; Adjust remainder for negative numbers
        cmp rdx, 0
        jge .pos_mod5
        add rdx, 5
    .pos_mod5:
        test rdx, 1
        jz .next3
        
        ; Now modulo the element itself by M before adding
        mov rax, r8
        cqo
        idiv r9
        cmp rdx, 0
        jge .pos_modM
        add rdx, r9
    .pos_modM:
        
        add r10, rdx
        mov rax, r10
        xor rdx, rdx ; r10 is positive, so xor rdx, rdx is enough
        div r9
        mov r10, rdx
    .next3:
        inc rcx
        cmp rcx, rsi
        jl .loop3
    .done3:
        mov rax, r10
        ret

    AsmNeighboursCount:
        push r12
        xor rax, rax
        cmp rsi, 3
        jl .done4
        mov r9, rdx
        mov rcx, 0
        mov r10, rsi
        sub r10, 2
        xor r12, r12
    .loop4:
        mov rax, qword [rdi + rcx*8]
        xor rdx, rdx
        div r9
        mov r11, rdx
        
        mov rax, qword [rdi + rcx*8 + 8]
        xor rdx, rdx
        div r9
        cmp rdx, r11
        jne .next4
        
        mov rax, qword [rdi + rcx*8 + 16]
        xor rdx, rdx
        div r9
        cmp rdx, r11
        jne .next4
        
        inc r12
    .next4:
        inc rcx
        cmp rcx, r10
        jl .loop4
        mov rax, r12
    .done4:
        pop r12
        ret

    AsmArrayFormula:
        movsxd rsi, esi
        xor r8, r8
        mov rcx, 0
        mov r9, 1
    .loop5:
        mov r10, rcx
        add r10, 2
        cmp r10, rsi
        jg .done5
        
        movsxd rax, dword [rdi + rcx*4]
        mov r11, rcx
        inc r11
        imul rax, r11
        
        movsxd r10, dword [rdi + rcx*4 + 4]
        mov r11, rcx
        add r11, 2
        imul r10, r11
        
        imul rax, r10
        imul rax, r9
        add r8, rax
        
        neg r9
        add rcx, 2
        jmp .loop5
    .done5:
        mov rax, r8
        ret

    AsmCompare:
        push r12
        xor r8, r8
        mov r9, 0
    .loop6_1:
        cmp r9, rsi
        jge .done6
        mov r10, qword [rdi + r9*8]
        
        mov r11, 0
        mov r12, 0
    .loop6_2:
        cmp r11, rcx
        jge .end_loop6_2
        cmp r10, qword [rdx + r11*8]
        jne .next6_2
        mov r12, 1
        jmp .end_loop6_2
    .next6_2:
        inc r11
        jmp .loop6_2
    .end_loop6_2:
        test r12, r12
        jnz .next6_1
        inc r8
    .next6_1:
        inc r9
        jmp .loop6_1
    .done6:
        mov rax, r8
        pop r12
        ret

    AsmSimpleModify:
        movsxd rsi, esi
        mov rcx, 0
        mov r9, 5
    .loop7:
        cmp rcx, rsi
        jge .done7
        movsxd rax, dword [rdi + rcx*4]
        cqo
        idiv r9
        test rdx, rdx
        jnz .check_even7
        mov dword [rdi + rcx*4], 0
        jmp .next7
    .check_even7:
        movsxd rax, dword [rdi + rcx*4]
        test rax, 1
        jnz .odd7
        mov dword [rdi + rcx*4], 1
        jmp .next7
    .odd7:
        mov dword [rdi + rcx*4], -1
    .next7:
        inc rcx
        jmp .loop7
    .done7:
        ret

    AsmSetToSequence:
        push r12
        movsxd rsi, esi
        cmp rsi, 0
        jle .done8
        
        mov r8, qword [rdi]
        mov r9, qword [rdi]
        mov r10, 0
        mov r11, 0
        
        mov rcx, 1
    .loop8_1:
        cmp rcx, rsi
        jge .found8
        mov rax, qword [rdi + rcx*8]
        cmp rax, r8
        jge .check_max8
        mov r8, rax
        mov r10, rcx
    .check_max8:
        cmp rax, r9
        jle .next8_1
        mov r9, rax
        mov r11, rcx
    .next8_1:
        inc rcx
        jmp .loop8_1
        
    .found8:
        cmp r10, r11
        jle .set_bounds8
        mov rax, r10
        mov r10, r11
        mov r11, rax
    .set_bounds8:
        mov rcx, r10
        mov r12, 1
    .loop8_2:
        cmp rcx, r11
        jg .done8
        mov qword [rdi + rcx*8], r12
        inc r12
        inc rcx
        jmp .loop8_2
    .done8:
        pop r12
        ret

    AsmReverse:
        movsxd rsi, esi
        mov rcx, 0
        mov rdx, rsi
        dec rdx
    .loop9:
        cmp rcx, rdx
        jge .done9
        mov r8, qword [rdi + rcx*8]
        mov r9, qword [rdi + rdx*8]
        mov qword [rdi + rcx*8], r9
        mov qword [rdi + rdx*8], r8
        inc rcx
        dec rdx
        jmp .loop9
    .done9:
        ret

    AsmRotateInGroups:
        push r12
        movsxd rsi, esi
        movsxd rdx, edx
        cmp rdx, 1
        jle .done10
        mov rcx, 0
    .loop10:
        cmp rcx, rsi
        jge .done10
        mov r8, rsi
        sub r8, rcx
        cmp r8, rdx
        cmovg r8, rdx
        
        cmp r8, 1
        jle .next10
        
        mov r9, qword [rdi + rcx*8]
        mov r10, 1
    .rot_loop10:
        cmp r10, r8
        jge .rot_done10
        mov r11, rcx
        add r11, r10
        mov r12, qword [rdi + r11*8]
        mov qword [rdi + r11*8 - 8], r12
        inc r10
        jmp .rot_loop10
    .rot_done10:
        mov r11, rcx
        add r11, r8
        dec r11
        mov qword [rdi + r11*8], r9
        
    .next10:
        add rcx, rdx
        jmp .loop10
    .done10:
        pop r12
        ret

    AsmInsertElement:
        movsxd rcx, dword [rsi]
        movsxd r8, edx
        cmp r8, 0
        jl .insert_first11
        cmp r8, rcx
        jge .insert_last11
        jmp .do_insert11
    .insert_first11:
        mov r8, 0
        jmp .do_insert11
    .insert_last11:
        mov r8, rcx
    .do_insert11:
        mov r9, rcx
    .shift_loop11:
        cmp r9, r8
        jle .shift_done11
        mov r10, qword [rdi + r9*8 - 8]
        mov qword [rdi + r9*8], r10
        dec r9
        jmp .shift_loop11
    .shift_done11:
        movsxd rax, edx
        mov qword [rdi + r8*8], rax
        inc rcx
        mov dword [rsi], ecx
        ret

    AsmRemoveIfSimilar:
        push r12
        movsxd rsi, esi
        mov r8, 0
        mov r9, 0
    .loop12:
        cmp r8, rsi
        jge .done12
        mov r10, qword [rdi + r8*8]
        
        cmp r10, 0
        jle .keep12
        test r10, 1
        jz .keep12
        
        mov r11, r10
        sub r11, rdx
        
        mov rax, r11
        mov r12, rax
        sar r12, 63
        xor rax, r12
        sub rax, r12
        
        cmp rax, rcx
        jle .skip12
        
    .keep12:
        mov qword [rdi + r9*8], r10
        inc r9
    .skip12:
        inc r8
        jmp .loop12
    .done12:
        mov rax, r9
        pop r12
        ret

    AsmReplaceWithGroup:
        push r12
        movsxd rcx, dword [rsi]
        movsxd r12, edx
        cmp r12, 0
        jle .done13
        mov r8, 0
        mov r9, 0
    .calc_loop13:
        cmp r9, rcx
        jge .calc_done13
        mov rax, qword [rdi + r9*8]
        mov r10, rax
        add r10, r12
        dec r10
        mov rax, r10
        cqo
        idiv r12
        add r8, rax
        inc r9
        jmp .calc_loop13
    .calc_done13:
        mov dword [rsi], r8d
        
        mov r9, rcx
        dec r9
        mov r10, r8
        dec r10
    .shift_loop13:
        cmp r9, 0
        jl .done13
        mov rax, qword [rdi + r9*8]
        
        mov r11, rax
        add r11, r12
        dec r11
        mov rax, r11
        cqo
        idiv r12
        mov r11, rax
        
        mov rax, qword [rdi + r9*8]
    .copy_loop13:
        cmp r11, 0
        jle .copy_done13
        mov qword [rdi + r10*8], rax
        dec r10
        dec r11
        jmp .copy_loop13
    .copy_done13:
        dec r9
        jmp .shift_loop13
    .done13:
        pop r12
        ret

    AsmMerge:
        push r12
        mov r9, 0
        mov r10, 0
        mov r11, 0
    .loop14:
        cmp r9, rsi
        jge .copy_arr2_14
        cmp r10, rcx
        jge .copy_arr1_14
        
        mov rax, qword [rdi + r9*8]
        mov r12, qword [rdx + r10*8]
        cmp rax, r12
        jle .take_arr1_14
    .take_arr2_14:
        mov qword [r8 + r11*8], r12
        inc r10
        inc r11
        jmp .loop14
    .take_arr1_14:
        mov qword [r8 + r11*8], rax
        inc r9
        inc r11
        jmp .loop14
        
    .copy_arr1_14:
        cmp r9, rsi
        jge .done14
        mov rax, qword [rdi + r9*8]
        mov qword [r8 + r11*8], rax
        inc r9
        inc r11
        jmp .copy_arr1_14
        
    .copy_arr2_14:
        cmp r10, rcx
        jge .done14
        mov rax, qword [rdx + r10*8]
        mov qword [r8 + r11*8], rax
        inc r10
        inc r11
        jmp .copy_arr2_14
        
    .done14:
        pop r12
        ret

    AsmFindSpecial:
        push r12
        mov r12, rdx
        mov rcx, 0
    .loop_i15:
        cmp rcx, rsi
        jge .not_found15
        mov r8, qword [rdi + rcx*8]
        mov r9, 0
    .loop_j15:
        cmp r9, r12
        jge .next_i15
        mov rax, qword [r8 + r9*8]
        
        mov r10, rax
        mov r11, 7
        cqo
        idiv r11
        test rdx, rdx
        jnz .next_j15
        
        mov rax, r10
        mov r11, 4
        cqo
        idiv r11
        test rdx, rdx
        jz .next_j15
        
        mov rax, 1
        pop r12
        ret
    .next_j15:
        inc r9
        jmp .loop_j15
    .next_i15:
        inc rcx
        jmp .loop_i15
    .not_found15:
        xor rax, rax
        pop r12
        ret

    AsmFindSorted:
        push r12
        push r13
        movsxd rsi, esi
        movsxd rdx, edx
        mov r12, rdx
        mov rcx, 0
        xor r8, r8
    .loop_i16:
        cmp rcx, rsi
        jge .done16
        mov r9, qword [rdi + rcx*8]
        mov r10, 1
        mov r11, 1
    .loop_j16:
        cmp r11, r12
        jge .check_sorted16
        movsxd rax, dword [r9 + r11*4 - 4]
        movsxd r13, dword [r9 + r11*4]
        cmp rax, r13
        jl .next_j16
        mov r10, 0
        jmp .check_sorted16
    .next_j16:
        inc r11
        jmp .loop_j16
    .check_sorted16:
        test r10, r10
        jz .next_i16
        add r8, rcx
    .next_i16:
        inc rcx
        jmp .loop_i16
    .done16:
        mov rax, r8
        pop r13
        pop r12
        ret

    AsmModify2D:
        push r12
        mov r12, rdx
        mov rcx, 0
    .loop_i17:
        cmp rcx, rsi
        jge .done17
        mov r8, qword [rdi + rcx*8]
        mov r9, 0
    .loop_j17:
        cmp r9, r12
        jge .next_i17
        mov rax, qword [r8 + r9*8]
        cmp rax, 0
        jl .negative17
        shl rax, 1
        mov qword [r8 + r9*8], rax
        jmp .next_j17
    .negative17:
        inc rax
        mov qword [r8 + r9*8], rax
    .next_j17:
        inc r9
        jmp .loop_j17
    .next_i17:
        inc rcx
        jmp .loop_i17
    .done17:
        pop r12
        ret

