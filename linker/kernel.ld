ENTRY(start)

SECTIONS{
    . = 1M;
 
    .multiboot : ALIGN(4K) 
    {
        
	    *(.multiboot_header)
	    *(.rodata.multiboot_header)
	    KEEP(*(.multiboot_header))
	    KEEP(*(.rodata.multiboot_header))
    }

    .text ALIGN(4K) : {
        *(.ctors)
        *(.dtors)
        *(.ctors*)
        *(.dtors*)
        *(.text)
        *(.text*)
    }
 
    .rodata ALIGN(4K) : {
        *(.rodata)
        *(.rodata*)
    }
 
    .data ALIGN (4K) : {
        *(.data)
	start_ctors = .; *(.ctors)   end_ctors = .;
	start_dtors = .; *(.dtors)   end_dtors = .;

    }
 
    .bss ALIGN(4K) : {
        start_bss = .;
        *(COMMON)
        *(.bss)
        end_bss = .;
    }
}
