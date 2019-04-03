module libkernel.memory;

import ldc.llvmasm;

ptrdiff_t copy_volatile_memory(A, B)(A[] dst, B[] src) {
    if (src.length > dst.length)
        src = src[0 .. dst.length];
    foreach(i, const ref val; src) {
        store(dst.ptr + i, val);
    }
    return src.length;
}

pragma(inline, true)
void store(P, T)(P ptr, T val) {
    static if (val.sizeof == 1u) {
      __asm("movb $1, $0", "=*m,r", ptr, val);
    } else static if (val.sizeof == 2u) {
      __asm("mov $1, $0", "=*m,r", ptr, val);
    } else static if (val.sizeof == 4u) {
      __asm("movl $1, $0", "=*m,r", ptr, val);
    } else {
        static assert(false,
                "Unsupported size: " ~ val.sizeof.stringof);
    }
}

pragma(inline,true)
T load(T, P)(P ptr) {
    static if (val.sizeof == 1u) {
        return __asm!int("movb $1, $0", "=a,*m", &dst);
    } else static if (val.sizeof == 2u) {
        return __asm!int("movb $1, $0", "=a,*m", &dst);
    } else static if (val.sizeof == 4u) {
        return __asm!int("movb $1, $0", "=a,*m", &dst);
    } else {
        static assert(false,
                "Unsupported size: " ~ val.sizeof.stringof);
    }
}
