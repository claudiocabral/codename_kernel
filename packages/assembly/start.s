global start

extern kmain;

section .text
start:
cli
mov  esp, stack_end  ; Set the stack pointer
call kmain
cli
hlt

section .bss

stack_begin:
RESB 4096  ; Reserve 4 KiB stack space
stack_end:
