module kernel.kmain;

import std.traits: CopyConstness;
import drivers.vga;
import assembly.includes;
import ldc.llvmasm;

auto makeArray(T, Ptr)(Ptr *ptr, size_t size) @nogc nothrow {
    return (cast(CopyConstness!(Ptr, T *)) ptr)[0 .. size];
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

ptrdiff_t copy_memory(A, B)(A[] dst, B[] src) {
    if (src.length > dst.length)
        src = src[0 .. dst.length];
    foreach(i, const ref val; src) {
        store(dst.ptr + i, val);
    }
    return src.length;
}

enum log_level {
    info = 0
}

bool valid_fmt(Args...)(string fmt, Args args) {
    return 1;
}

ptrdiff_t print_formatted(log_level level, string fmt, Args...)(Args args) {
    static assert(valid_fmt(fmt, args), "invalid format");
    return copy_memory(video_ptr.ptr.makeArray!ushort(32), fmt);
}

alias print_info(string fmt, Args...) = print_formatted!(log_level.info, fmt, Args);

extern (C) void kmain() {
    immutable wstring str = "Hello World!";
    print_info!(str);
}
