module drivers.vga;

import libkernel.memory: store, copy_volatile_memory;
import libkernel.conversion;

enum vga_base_address = cast(ushort *)0xb8000;
enum vga_columns = 80;
enum vga_rows = 25;
enum number_of_screens = 10;

struct vga_driver_t {
    video_ptr_t video_ptr;
    screen_t!(vga_columns, vga_rows)[number_of_screens] screens;
    size_t current;
    void append(ushort val) {
        screens[current].append(val);
    }
    void flush() {
        video_ptr = screens[current].buffer;
    }
}

struct point_t {
    size_t x;
    size_t y;
}



struct screen_t(size_t cols, size_t lines) {
    ushort[cols * lines] buffer = 0;
    size_t position = 0;
    void append(ushort val) {
        buffer[position] = val;
        ++position;
        //position &= 0xff;
        position %= 80 * 25;
    }
    auto dump() {
        return buffer[0 .. position];
    }
    alias buffer this;
}


struct video_ptr_t {
    auto opAssign(ushort[] buffer) {
        copy_volatile_memory(ptr, buffer);
    }
    auto opIndex(size_t i) {
        return *(cast(ushort *)ptr + i);
    }
    auto opIndex(size_t column, size_t row) {
        if (width < column || height < row)
            return 0;
        return *(cast(ushort *)ptr + column * (row + 1));
    }
    auto opIndex(point_t position) {
        return this[position.x, position.y];
    }
    auto opIndexAssign(ushort value, size_t i) {
        store(ptr + i, value);
        return value;
    }
    auto opIndexAssign(ushort value, size_t column, size_t row) {
        if (width < column || height < row)
            return 0;
        return this[column * (row + 1)] = value;
    }
    auto opIndexAssign(ushort value, point_t position) {
        return this[position.x, position.y] = value;
    }
    size_t length() { return width * height; }
    ushort *ptr = vga_base_address;
    size_t width = 80;
    size_t height = 25;
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

bool switch_screen(size_t n_cols, size_t n_rows)(video_ptr_t video, ref
        screen_t!(n_cols, n_rows) screen) {
    auto ptr = video.toArray;
    ptr = screen.buffer;
}

ushort make_character(ushort character, color_t foreground = color_t.white,
                      color_t background = color_t.black) {
    return cast(ushort)((background << 12)
            + (foreground << 8)
            + character);
}

size_t write_to_screen(video_ptr_t video,
        string str,
        color_t foreground = color_t.white,
        color_t background = color_t.black) {
    foreach(i, val; str) {
        auto col = i % vga_columns;
        auto row = i / vga_columns;
        video[col, row] = make_character(val, foreground, background);
    }
    return str.length;
}
size_t write_to_screen(video_ptr_t video, ushort[] str) {
    foreach(i, val; str) {
        video[i] = val;
    }
    return str.length;
}

size_t write_to_current(
        ref vga_driver_t vga,
        string str,
        color_t foreground = color_t.white,
        color_t background = color_t.black) {
    foreach(val; str) {
        vga.write_to_current(val, foreground, background);
    }
    vga.flush();
    return 1;
}

size_t write_to_current(ref vga_driver_t vga,
        char val,
        color_t foreground = color_t.white,
        color_t background = color_t.black) {
    vga.append(make_character(val, foreground, background));
    return 1;
}
