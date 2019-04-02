module kernel.kmain;

import std.traits: CopyConstness;
import drivers.vga;

auto makeArray(T, Ptr)(Ptr *ptr, size_t size) @nogc nothrow {
    return (cast(CopyConstness!(Ptr, T *)) ptr)[0 .. size];
}

ptrdiff_t copy_memory(A, B)(A[] dst, B[] src) {
    foreach(i, const ref val; src) {
        if (dst.length < i)
            break ;
        dst[i] = val;
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
