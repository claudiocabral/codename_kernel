global start

extern kmain;
extern start_bss;
extern end_bss;

section .text
start:
cli
mov  esp, stack_end  ; Set the stack pointer
call enable_sse
call kmain
hlt

enable_sse:
mov eax, cr0
and ax, 0xFFFB		;clear coprocessor emulation CR0.EM
or ax, 0x2			;set coprocessor monitoring  CR0.MP
mov cr0, eax
mov eax, cr4
or ax, 3 << 9		;set CR4.OSFXSR and CR4.OSXMMEXCPT at the same time
mov cr4, eax
ret

clear_bss:
mov eax, start_bss
.loop:
mov byte[eax], 0
inc eax
cmp eax, end_bss
jne .loop
ret

section .bss

stack_begin:
RESB 0x4000  ; Reserve 16 KiB stack space
stack_end:
