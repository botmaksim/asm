bits 32
section .text
global CalculateCos

CalculateCos:
    push ebp
    mov ebp, esp
    
    sub esp, 24
    
    mov [ebp-16], ecx
    mov [ebp-20], edx

    finit               
    fldpi               
    fld1                
    fadd st0, st0       
    fadd st0, st0       
    fdivp st1, st0      
    
    
    fld st0             
    fmul st0, st0       
    fstp dword [ebp-4]  

    fld1 
    fld1 
    
    mov ecx, [ebp-16]
    cmp ecx, 1
    jle .finish 

    dec ecx     
    mov eax, 1  

.loop_s:
    mov edx, eax
    shl edx, 1             
    mov [ebp-12], edx
    dec edx   
    mov [ebp-8], edx

    fld st1  
    fchs     
    fmul dword [ebp-4]
    
    fild dword [ebp-8]
    fdivp st1, st0    
    
    fild dword [ebp-12]
    fdivp st1, st0     
    fadd st1, st0    
    
    fstp st2

    inc eax
    loop .loop_s

.finish:
    fstp st1           
    
    fld st1          
    fcos             
    fsub st0, st1    
    
    mov edx, [ebp-20]   
    fstp dword [edx]   
    
    fstp st1            
    
    mov esp, ebp
    pop ebp
    ret