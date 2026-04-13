bits 32
section .text
global CreateVectorB

CreateVectorB:
    push ebp
    mov ebp, esp
    push edi
    push esi
    push ebx

    mov edi, [ebp+16]   
    xor ebx, ebx     

.col_loop:
    cmp ebx, edi
    jge .done
    
    xor esi, esi      
    xor ecx, ecx
    xor edx, edx

.row_loop:
    cmp esi, [ebp+12] 
    jge .compare_sums


    mov eax, esi  
    imul eax, edi 
    add eax, ebx 

    push edx           
    mov edx, [ebp+8] 
    mov eax, [edx + eax*4] 
    pop edx     

    test eax, eax
    js .is_neg
    add ecx, eax       
    jmp .next_row
.is_neg:
    add edx, eax       

.next_row:
    inc esi
    jmp .row_loop

.compare_sums:
    mov eax, edx
    neg eax        
    
    mov esi, [ebp+20] 
    cmp ecx, eax
    jg .set_1
    mov dword [esi + ebx*4], 0
    jmp .continue_col
.set_1:
    mov dword [esi + ebx*4], 1

.continue_col:
    inc ebx
    jmp .col_loop

.done:
    pop ebx
    pop esi
    pop edi
    mov esp, ebp
    pop ebp
    ret