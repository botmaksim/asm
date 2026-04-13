; ###SKIP_FILE_NAME_CHECK

                        global AsmSimpleFn
                        global AsmSimpleFn_NoMulA
                        global AsmOverflow
                        global AsmFxy
                        global AsmArray
                        global AsmEvenOdd
                        global AsmAlpha
                        global AsmRecursion
                        global Asm2dIgnore
                        global Asm2dReplaceIfNull
                        global Asm2dAdvanced
                        global Asm2d

                        extern malloc
                        extern free

                        extern Gamma

                    section .data

is_overflow db 'Overflow',0
is_none db 'None',0

                    section .text

; k = 104042026, args: rdi=a, rsi=b, rdx=c (uint32, zero-extended)
AsmSimpleFn:
                        mov eax, esi
                        lea rax, [rax + rax + 12]
                        mov r8d, edx
                        add rax, r8

                        mov ecx, 104042026
                        xor edx, edx
                        div rcx ; rdx = (12 + 2*b + c) % k

                        mov rax, rdx
                        imul rax, rax
                        xor edx, edx
                        div rcx ; rdx = t^2 % k

                        mov rax, rdx
                        mov r8d, edi
                        imul rax, r8
                        xor edx, edx
                        div rcx ; rdx = a*t^2 % k

                        mov eax, edx
                        ret

AsmSimpleFn_NoMulA:
                        mov eax, esi
                        lea rax, [rax + rax + 12]
                        mov r8d, edx
                        add rax, r8

                        mov ecx, 104042026
                        xor edx, edx
                        div rcx ; rdx = (12 + 2*b + c) % k

                        mov rax, rdx
                        imul rax, rax
                        xor edx, edx
                        div rcx ; rdx = t^2 % k

                        mov eax, edx
                        ret

AsmOverflow:
                        mov eax, edi
                        cmp eax, 0x7fffffff
                        ja .overflow

                        mov ecx, eax
                        add ecx, 3

                        mov eax, edi
                        mul rcx ; unsigned: rdx:rax = x * (x + 3)

                        test rdx, rdx
                        jnz .overflow
                        cmp rax, 0x7fffffff
                        ja .overflow

                        lea rax, [rel is_none]
                        ret

.overflow:
                        lea rax, [rel is_overflow]
                        ret

AsmFxy:
                        movsxd r8, edi ; x
                        movsxd rcx, esi ; y

                        xor rax, rax ; result = 0
                        cmp rcx, 0
                        jle .fxy_done

                        mov r9, 1 ; x_pow
                        mov r10, -1 ; coeff

.fxy_loop:
                        neg r10 ; coeff *= -1
                        imul r9, r8 ; x_pow *= x

                        mov r11, r9
                        imul r11, r10
                        add rax, r11

                        dec rcx
                        jnz .fxy_loop

.fxy_done:
                        ret

AsmArray:
                        movsx rcx, si ; size
                        xor rax, rax ; result
                        xor rdx, rdx ; i

                        cmp rcx, 0
                        jle .array_done

.array_loop:
                        movsx r8, word [rdi + rdx * 2]
                        cmp r8, rdx
                        jle .array_next

                        add rax, r8

.array_next:
                        inc rdx
                        cmp rdx, rcx
                        jl .array_loop

.array_done:
                        ret

AsmEvenOdd:
                        xor rax, rax ; write index
                        xor rcx, rcx ; read index

                        cmp rsi, 0
                        jle .evenodd_done

.evenodd_loop:
                        mov r8, [rdi + rcx * 8]
                        test r8, 1
                        jnz .evenodd_skip

                        sar r8, 1
                        mov [rdi + rax * 8], r8
                        inc rax

.evenodd_skip:
                        inc rcx
                        cmp rcx, rsi
                        jl .evenodd_loop

.evenodd_done:
                        ret

AsmAlpha:
                        push rbx
                        push r12
                        push r13
                        push r14
                        push r15

                        mov r12, rdi ; x
                        mov r13, rsi ; y
                        mov r14, rdx ; z
                        mov rbx, rcx ; Delta pointer

                        mov rdi, r12
                        call Gamma
                        mov r15, rax ; Gamma(x)

                        mov rdi, r12
                        call Gamma

                        mov rdi, rax
                        call rbx ; Delta(Gamma(x))

                        mov rcx, rax ; delta
                        mov rax, r13 ; min candidate = y
                        cmp r14, rax
                        cmovl rax, r14 ; min(y, z)
                        cmp rcx, rax
                        cmovl rax, rcx ; min(y, z, delta)

                        add rax, r15 ; Gamma(x) + min(...)

                        pop r15
                        pop r14
                        pop r13
                        pop r12
                        pop rbx
                        ret

; rdi = m (int16), rsi = n (uint64)
AsmRecursion:
                        push rbx
                        push r12
                        push r13
                        push r14
                        push r15

                        movsx r12, di ; m > 0
                        mov r13, rsi ; n

                        test r13, r13
                        jnz .rec_alloc

                        mov eax, 5
                        jmp .rec_ret

.rec_alloc:
                        mov rdi, r13
                        inc rdi
                        shl rdi, 3 ; bytes = (n + 1) * 8
                        call malloc

                        test rax, rax
                        jz .rec_malloc_fail

                        mov r14, rax ; dp pointer
                        mov qword [r14], 5 ; dp[0] = 5

                        mov r15, 1 ; i = 1

.rec_loop:
                        ; a = (i >= 3) ? dp[i - 3] : 5
                        cmp r15, 3
                        jb .rec_a_base
                        mov rax, r15
                        sub rax, 3
                        mov r8, [r14 + rax * 8]
                        jmp .rec_a_done

.rec_a_base:
                        mov r8, 5

.rec_a_done:
                        ; b = dp[i / 2]
                        mov rax, r15
                        shr rax, 1
                        mov r9, [r14 + rax * 8]

                        ; c = dp[i - 1]
                        mov rax, r15
                        dec rax
                        mov r10, [r14 + rax * 8]

                        ; dp[i] = (a + b * c) % m
                        mov rax, r9
                        imul rax, r10
                        add rax, r8

                        xor rdx, rdx
                        div r12 ; remainder in rdx
                        mov [r14 + r15 * 8], rdx

inc r15
                        cmp r15, r13
                        jbe .rec_loop

                        mov rbx, [r14 + r13 * 8]
                        mov rdi, r14
                        call free
                        mov rax, rbx
                        jmp .rec_ret

.rec_malloc_fail:
                        xor eax, eax

.rec_ret:
                        pop r15
                        pop r14
                        pop r13
                        pop r12
                        pop rbx
                        ret

; rdi = row pointers, rsi = rows, rdx = cols — first bypass direction (row-major)
Asm2dIgnore:
                        test rsi, rsi
                        jle .a2di_done
                        test rdx, rdx
                        jle .a2di_done

                        xor r8, r8 ; i = 0

.a2di_row_loop:
                        xor r9, r9 ; j = 0

.a2di_col_loop:
                        mov r10, [rdi + r8 * 8] ; row ptr
                        mov r11, [r10 + r9 * 8] ; element

                        ; top neighbour
                        test r8, r8
                        jz .a2di_chk_bottom
                        mov rax, [rdi + r8 * 8 - 8]
                        mov rcx, [rax + r9 * 8]
                        cmp r11, rcx
                        jge .a2di_next

.a2di_chk_bottom:
                        mov rax, r8
                        inc rax
                        cmp rax, rsi
                        jge .a2di_chk_left
                        mov rax, [rdi + r8 * 8 + 8]
                        mov rcx, [rax + r9 * 8]
                        cmp r11, rcx
                        jge .a2di_next

.a2di_chk_left:
                        test r9, r9
                        jz .a2di_chk_right
                        mov rcx, [r10 + r9 * 8 - 8]
                        cmp r11, rcx
                        jge .a2di_next

.a2di_chk_right:
                        mov rax, r9
                        inc rax
                        cmp rax, rdx
                        jge .a2di_replace
                        mov rcx, [r10 + r9 * 8 + 8]
                        cmp r11, rcx
                        jge .a2di_next

.a2di_replace:
                        mov qword [r10 + r9 * 8], 42

.a2di_next:
                        inc r9
                        cmp r9, rdx
                        jl .a2di_col_loop

                        inc r8
                        cmp r8, rsi
                        jl .a2di_row_loop

.a2di_done:
                        ret

Asm2dReplaceIfNull:
                        test rsi, rsi
                        jle .a2dr_done
                        test rdx, rdx
                        jle .a2dr_done

                        xor r8, r8 ; i = 0

.a2dr_row_loop:
                        xor r9, r9 ; j = 0

.a2dr_col_loop:
                        mov r10, [rdi + r8 * 8] ; row ptr

                        ; if any neighbour is missing => set 42
                        test r8, r8
                        jz .a2dr_replace
                        test r9, r9
                        jz .a2dr_replace

                        mov rax, r8
                        inc rax
                        cmp rax, rsi
                        jge .a2dr_replace

                        mov rax, r9
                        inc rax
                        cmp rax, rdx
                        jge .a2dr_replace

                        ; all neighbours exist => local minimum check
                        mov r11, [r10 + r9 * 8]

                        mov rax, [rdi + r8 * 8 - 8]
                        mov rcx, [rax + r9 * 8]
                        cmp r11, rcx
                        jge .a2dr_next

                        mov rax, [rdi + r8 * 8 + 8]
                        mov rcx, [rax + r9 * 8]
                        cmp r11, rcx
                        jge .a2dr_next

                        mov rcx, [r10 + r9 * 8 - 8]
                        cmp r11, rcx
                        jge .a2dr_next

mov rcx, [r10 + r9 * 8 + 8]
                        cmp r11, rcx
                        jge .a2dr_next

.a2dr_replace:
                        mov qword [r10 + r9 * 8], 42

.a2dr_next:
                        inc r9
                        cmp r9, rdx
                        jl .a2dr_col_loop

                        inc r8
                        cmp r8, rsi
                        jl .a2dr_row_loop

.a2dr_done:
                        ret

Asm2dAdvanced:
                        test rsi, rsi
                        jle .a2da_done
                        test rdx, rdx
                        jle .a2da_done

                        push rbx
                        push r12
                        push r13
                        push r14
                        push r15

                        mov r12, rdi ; matrix
                        mov r13, rsi ; rows
                        mov r14, rdx ; cols

                        ; allocate snapshot: rows * cols * 8
                        mov rax, r13
                        imul rax, r14
                        mov rdi, rax
                        shl rdi, 3
                        call malloc

                        test rax, rax
                        jz .a2da_cleanup

                        mov r15, rax ; snapshot ptr

                        ; copy original matrix to snapshot
                        xor r8, r8 ; i = 0

.a2da_copy_rows:
                        xor r9, r9 ; j = 0
                        mov r10, [r12 + r8 * 8] ; row ptr

.a2da_copy_cols:
                        mov r11, [r10 + r9 * 8]
                        mov rax, r8
                        imul rax, r14
                        add rax, r9
                        mov [r15 + rax * 8], r11

                        inc r9
                        cmp r9, r14
                        jl .a2da_copy_cols

                        inc r8
                        cmp r8, r13
                        jl .a2da_copy_rows

                        ; process output matrix using snapshot for comparisons
                        xor r8, r8 ; i = 0

.a2da_rows:
                        xor r9, r9 ; j = 0
                        mov r10, [r12 + r8 * 8] ; output row ptr

.a2da_cols:
                        ; border => replace
                        test r8, r8
                        jz .a2da_replace
                        test r9, r9
                        jz .a2da_replace

                        mov rax, r8
                        inc rax
                        cmp rax, r13
                        jge .a2da_replace

                        mov rax, r9
                        inc rax
                        cmp rax, r14
                        jge .a2da_replace

                        ; interior => compare against snapshot
                        mov rax, r8
                        imul rax, r14
                        add rax, r9 ; idx

                        mov r11, [r15 + rax * 8]

                        mov rbx, rax
                        sub rbx, r14 ; idx - cols
                        mov rcx, [r15 + rbx * 8]
                        cmp r11, rcx
                        jge .a2da_next

                        mov rbx, rax
                        add rbx, r14 ; idx + cols
                        mov rcx, [r15 + rbx * 8]
                        cmp r11, rcx
                        jge .a2da_next

                        mov rbx, rax
                        dec rbx ; idx - 1
                        mov rcx, [r15 + rbx * 8]
                        cmp r11, rcx
                        jge .a2da_next

                        mov rbx, rax
                        inc rbx ; idx + 1
                        mov rcx, [r15 + rbx * 8]
                        cmp r11, rcx
                        jge .a2da_next

.a2da_replace:
                        mov qword [r10 + r9 * 8], 42

.a2da_next:
                        inc r9
                        cmp r9, r14
                        jl .a2da_cols

                        inc r8
                        cmp r8, r13
                        jl .a2da_rows

                        mov rdi, r15
                        call free

.a2da_cleanup:
                        pop r15
                        pop r14
                        pop r13
                        pop r12
                        pop rbx

.a2da_done:
                        ret

Asm2d:
                        jmp Asm2dAdvanced

                    section .note.GNU-stack noalloc noexec nowrite progbits