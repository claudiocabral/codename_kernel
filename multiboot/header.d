module multiboot.header;

extern (C):
immutable header multiboot_header;

private:
uint get_architecture() {
    version(X86) {
        return 0;
    } else {
        return 1;
    }
}

struct header {
    immutable uint magic = 0xE85250D6;
    immutable uint architecture = get_architecture();
    immutable uint header_length = header.sizeof;
    immutable uint checksum = uint.max
        - magic - architecture - header_length;
}
