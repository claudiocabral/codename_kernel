module libkernel.memory;
pragma(LDC_no_moduleinfo);

import ldc.llvmasm;
import libkernel.conversion;
import ldc.intrinsics;

ptrdiff_t copy_volatile_memory(A, B)(A *dst, B[] src) {
    foreach(i, const ref val; src) {
        store(dst + i, val);
    }
    return src.length;

ptrdiff_t copy_volatile_memory(A, B)(A[] dst, B[] src) {
    foreach(i, const ref val; src) {
        store(dst.ptr + i, val);
    }
    return src.length;
}
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

extern (C) void *memset(void * dest, int c, size_t n)
{
    auto ptr = cast(ubyte *)dest;
    size_t i = 0;
    while (i < n) {
        store(ptr + i, cast(ubyte)c);
        ++i;
    }
    return dest;
}

extern (C) void *memcpy(void * dest, void * src, size_t n)
{
    auto to = cast(ubyte *)dest;
    auto from = cast(ubyte *)src;
    size_t i = 0;
    while (i < n) {
        store(to + i, from + i);
        ++i;
    }
    return dest;
}
