module libkernel.io;

import libkernel.memory;
import drivers.vga;

enum log_level {
    info = 0,
}

auto output(A, B)(A a, B b) {
}

bool valid_fmt(Args...)(string fmt, Args args) {
    return 1;
}

ptrdiff_t print_formatted(log_level level, string fmt, Args...)(Args args) {
    static assert(valid_fmt(fmt, args), "invalid format");
    static assert(false, "not implemented yet");
    return 0;
}

alias print_info(string fmt, Args...) = print_formatted!(log_level.info, fmt, Args);
