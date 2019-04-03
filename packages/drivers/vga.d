module drivers.vga;
import std.traits: CopyConstness;

enum vga_base_address = cast(void *)0xb8000;
enum vga_columns = 80;
enum vga_rows = 25;
enum number_of_screens = 10;

__gshared video_ptr = video_ptr_t(vga_base_address, vga_columns, vga_rows);
screen_t!(vga_columns, vga_rows)[number_of_screens] screens;

struct screen_t(size_t cols, size_t lines) {
    ushort[cols * lines] buffer;
}

struct video_ptr_t {
    auto opIndex(size_t column, size_t row) {
        if (width < column || height < row)
            return 0;
        return *(cast(ushort *)ptr + column * row);
    }
    auto opIndexAssign(ushort value, size_t column, size_t row) {
        if (width < column || height < row)
            return 0;
        return *(cast(ushort *)ptr + column * row) = value;
        //return *(cast(ushort *)ptr + column * row) = value;
    }
    void *ptr;
    size_t width;
    size_t height;
}

auto makeArray(T, Ptr)(Ptr *ptr, size_t size) @nogc nothrow {
    return (cast(CopyConstness!(Ptr, T *)) ptr)[0 .. size];
}
auto make2DArray(T, Ptr)(Ptr *ptr, size_t width, size_t height) @nogc nothrow {
    return (cast(CopyConstness!(Ptr, T *)) ptr)[0 .. width][0 .. height];
}

enum color_t : ushort {
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

ushort make_character(ushort character, color_t foreground,
        color_t background = color_t.black) {
    return cast(ushort)((foreground << 12)
         + (background << 8)
         + character);
}

bool switch_screen(size_t n_cols, size_t n_rows)(video_ptr_t video, ref
        screen_t!(n_cols, n_rows) screen) {
    auto ptr = video.toArray;
    ptr = screen.buffer;
}

size_t write(string str) {
    foreach(i, val; str) {
        auto width = i % vga_columns;
        auto height = i / vga_columns;
        video_ptr[width, height] = make_character(val, color_t.green, color_t.black);
    }
    return str.length;
}
