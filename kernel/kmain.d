module dma.video;
import std.traits: CopyConstness;

auto makeArray(T, Ptr)(Ptr *ptr, size_t size) @nogc nothrow {
    return (cast(CopyConstness!(Ptr, T *)) ptr)[0 .. size];
}

__gshared video_ptr = t_video_ptr();

struct t_video_ptr {
    void *ptr = cast(void *)0xb8000;
    auto toArray() {
        return makeArray!ushort(ptr, 32);
    }
    alias toArray this;
}

enum color : ubyte {
    black = 0x0,
    blue,
    green,
    cyan,
    red,
    magenta,
    brown,
    gray,
    dark,
    bright_blue,
    bright_green,
    bright_cyan,
    bright_read,
    bright_magenta,
    yellow,
    white,
} 

extern (C) {
    size_t write(string str) {
        auto ptr = video_ptr;
        foreach(i, val; str) {
            ptr[i] = val;
        }
        return str.length;
    }

    void kmain() {
        write("Hello World!");
    }
}
