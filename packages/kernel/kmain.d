module kernel.kmain;
pragma(LDC_no_moduleinfo);

import libkernel.io;
import drivers.vga;
import libkernel.conversion;
import std.traits;

struct kernel_t {
    vga_driver_t vga;
}

auto start(T)(ref T t) {
    static if(isArray!T) {
        foreach(ref val; t) {
            start(val);
        }
    } else static if(isBuiltinType!T || isPointer!T) {
        t = t.init;
    } else {
        foreach (field; FieldNameTuple!T) {
            start(mixin(t.stringof ~ "." ~ field));
        }
    }
}

auto start(T : video_ptr_t)(ref T video) {
    video.ptr = vga_base_address;
    video.width = 80;
    video.height = 25;
}

extern (C) __gshared kernel_t kernel;

extern (C) void kmain() {
    immutable string str = "Kermit, the Kernel";
    start(kernel);
    kernel.vga.write_to_current(str, color_t.bright_green, color_t.yellow);
    ubyte i = 0;
    while (1) {
        kernel.vga.write_to_current(i, color_t.bright_green, color_t.yellow);
        kernel.vga.flush();
        ++i;
    }
}
