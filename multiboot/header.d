module multiboot.header;

extern (C):
immutable multiboot_header = get_architecture.make_header();

private:
uint get_architecture() {
    version(X86) {
        return 0;
    } else {
        return 0;
    }
}

auto make_header(uint architecture) {
    enum magic = 0xE85250D6;
    immutable uint header_length = header.sizeof;
    immutable checksum = uint.max
        - magic - architecture - header_length + 1;

    return header(magic,
                  architecture,
                  header_length,
                  checksum,
                  t_tag()
                 );
                  
}

struct t_tag {
    ushort type;
    ushort flags;
    uint size = t_tag.sizeof;
}


struct header {
    uint magic;
    uint architecture;
    uint header_length;
    uint checksum;
    t_tag end_tag;
}
