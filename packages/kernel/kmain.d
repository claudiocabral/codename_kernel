module kernel.kmain;

import std.traits: CopyConstness;
import libkernel.io;

extern (C) void kmain() {
    immutable wstring str = "Hello World!";
    print_info!(str);
}
