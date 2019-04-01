BIN_FOLDER ?= bin
OBJ_FOLDER ?= objs
IMG_FOLDER ?= img

KERNEL_NAME ?= kernel

KERNEL_BINARY := $(BIN_FOLDER)/$(KERNEL_NAME)

KERNEL_IMG ?= $(KERNEL_NAME).img

MNT_PATH ?= ./mnt

KERNEL_IMG_RULE := $(IMG_FOLDER)/$(KERNEL_IMG)

KERNEL_OBJS := \
	$(OBJ_FOLDER)/multiboot/header.o \
	$(OBJ_FOLDER)/asm/start.o \
	$(OBJ_FOLDER)/kernel/kmain.o

DFLAGS ?= -betterC -boundscheck=off -m32

all: $(KERNEL_NAME).iso

$(KERNEL_NAME).iso: $(KERNEL_BINARY)
	@mkdir -p iso/boot/grub || true
	@cp -v config/grub.cfg iso/boot/grub/grub.cfg
	@cp -v $(KERNEL_BINARY) iso/boot/
	grub-mkrescue iso -o $@ iso/


$(KERNEL_BINARY): $(KERNEL_OBJS) linker/kernel.ld
	ld -T linker/kernel.ld $(KERNEL_OBJS) \
		-m elf_i386 \
		-o $(KERNEL_BINARY)

$(OBJ_FOLDER)/%.o : %.d
	ldc $(DFLAGS) -c $< -of $@

$(OBJ_FOLDER)/%.o : %.s
	$(eval DIR := $(dir $@))
	@[[ -d $(DIR) ]] || mkdir -p $(DIR)
	nasm -f elf32 $< -o $@

img: format_img

format_img: mount
	sudo mkfs.ext2 /dev/loop1
	sudo mount /dev/loop1 ./mnt
	sudo grub-install --locale-directory=/usr/share/locale/en_US \
		--font=deja_vu \
		--target=i386-pc \
		--boot-directory=./mnt/boot \
		--modules="normal part_msdos ext2 multiboot2 biosdisk" \
		/dev/loop0
	sudo cp grub.cfg ./mnt/boot/grub/

partition_img: $(KERNEL_IMG_RULE) umount
	@echo Preparing kernel img $(KERNEL_IMG_RULE)
	parted -s $(KERNEL_IMG_RULE) mklabel msdos
	parted -s $(KERNEL_IMG_RULE) -- mkpart primary 1MiB -1s
	parted -s $(KERNEL_IMG_RULE) set 1 boot on
	sync

mount: umount
	sudo losetup /dev/loop0 $(KERNEL_IMG_RULE)
	sudo losetup /dev/loop1 $(KERNEL_IMG_RULE) -o 1MiB

umount:
	sudo umount $(MNT_PATH) || true
	sudo losetup -D

$(KERNEL_IMG_RULE): umount
	@echo Generating kernel image
	@dd if=/dev/zero of=$@ bs=512 count=40960

clean:
	rm -rf $(OBJ_FOLDER)

fclean: clean

re:
	$(MAKE) fclean
	$(MAKE)
