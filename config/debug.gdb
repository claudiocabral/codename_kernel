target remote localhost:1234
symbol-file -readnow bin/kernel
set disassembly-flavor intel
layout asm
layout regs
set demangle-style dlang
hbreak start
hbreak kmain
continue
