module libkernel.conversion;

import std.traits: CopyConstness;

auto makeArray(T, Ptr)(Ptr *ptr, size_t size) @nogc nothrow {
    return (cast(CopyConstness!(Ptr, T *)) ptr)[0 .. size];
}
