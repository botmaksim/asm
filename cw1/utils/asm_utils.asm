    global JunkRegistersWindows
    global JunkRegistersUnix

    section .text

JunkRegistersWindows:
    mov rax, 116966976965896461
    mov rcx, 113464543745754739
    mov rdx, 111235648598785348
    mov r8, 111453856868588644
    mov r9, 111235872357685235
    mov r10, 114645785698544245
    mov r11, 111222333444555666
    ret

JunkRegistersUnix:
    mov rax, 116966976965896461
    mov rcx, 113464543745754739
    mov rdx, 111235648598785348
    mov r8, 111453856868588644
    mov r9, 111235872357685235
    mov r10, 114645785698544245
    mov r11, 111222333444555666
    mov rdi, 111238598723553527
    mov rsi, 116587236786928355
    ret

; ----------------------

extract_addr_windows:
    mov rax, rcx
    mov rcx, rdx
    mov rdx, r8
    mov r8, r9
    mov r9, rax
    ret

extract_addr_unix:
    mov rax, rdi
    mov rdi, rsi
    mov rsi, rdx
    mov rdx, rcx
    mov rcx, r8
    mov r8, r9
    mov r9, rax
    ret

; ----------------------

%macro reg_test_begin 1
    push %1
    mov %1, rsp
%endmacro

%macro reg_test_end 1
    mov rsp, %1
    pop %1
%endmacro

%macro reg_test 1
    reg_test_begin rbx
    reg_test_begin r12
    reg_test_begin r13
    reg_test_begin r14
    reg_test_begin r15

    ; Extract address to RAX
    call %1

    ; Set all arithmetic flags
    pushf
    or QWORD [rsp], 0x08C5 ; CF+PF+ZF+SF+OF
    popf

    ; Align stack pointer for SSE
    push rbp
    mov rbp, rsp
    and rsp, 0xFFFFFFFFFFFFFFF0

    ; Call solution
    call rax

    mov rsp, rbp
    pop rbp

    ; Check that direction flag is cleared after return
    pushf
    and QWORD [rsp], 0x0400 ; DF
    cmp QWORD [rsp], 0
    jne FatalFailure
    add rsp, 8

    reg_test_end r15
    reg_test_end r14
    reg_test_end r13
    reg_test_end r12
    reg_test_end rbx
%endmacro

    global ConvertArgsToWindowsConvention
    global RunWinedAsmFunction
    global RunWinedAsmFunctionWithChecks

    global RunWindowsAsmFunctionWithChecks
    global RunUnixAsmFunctionWithChecks

; Convert arguments from Windows convention to System-V convention
ConvertArgsToWindowsConvention:
    mov r9, rcx  ; arg4
    mov r8, rdx  ; arg3
    mov rdx, rsi ; arg2
    mov rcx, rdi ; arg1
    mov rdi, 43898546385
    mov rsi, 36456989748
    ret

RunWinedAsmFunctionWithChecks:
    call ConvertArgsToWindowsConvention
    reg_test extract_addr_unix
    ret

RunWinedAsmFunction:
    call ConvertArgsToWindowsConvention
    call extract_addr_unix

    ; Align stack pointer for SSE
    push rbp
    mov rbp, rsp
    and rsp, 0xFFFFFFFFFFFFFFF0

    ; Call solution
    call rax

    mov rsp, rbp
    pop rbp

    ret

RunWindowsAsmFunctionWithChecks:
    reg_test extract_addr_windows
    ret

RunUnixAsmFunctionWithChecks:
    reg_test extract_addr_unix
    ret

FatalFailure:
    mov rsp, 0
    mov rbp, 0
    ret
