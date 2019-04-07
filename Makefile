BIN_FOLDER ?= bin
OBJ_FOLDER ?= objs
IMG_FOLDER ?= imgs
SRC_FOLDER := packages
DEPS_FOLDER := .deps
DC ?= ldc
$(shell mkdir -p $(DEPS_FOLDER) >/dev/null)

DEPFLAGS = -MT $@ -M -MP -MF $(DEPS_FOLDER)/$*.Td
POSTCOMPILE = @mv -f $(DEPS_FOLDER)/$*.Td $(DEPS_FOLDER)/$*.dep && touch $@

KERNEL_NAME ?= kernel

KERNEL_BINARY := $(BIN_FOLDER)/$(KERNEL_NAME)

KERNEL_IMG ?= $(IMG_FOLDER)/$(KERNEL_NAME).iso

MNT_PATH ?= ./mnt

KERNEL_IMG_RULE := $(IMG_FOLDER)/$(KERNEL_IMG)

KERNEL_OBJS := \
	$(OBJ_FOLDER)/drivers/vga.o \
	$(OBJ_FOLDER)/assembly/start.o \
	$(OBJ_FOLDER)/assembly/multiboot.o \
	$(OBJ_FOLDER)/libkernel/memory.o \
	$(OBJ_FOLDER)/kernel/kmain.o

DFLAGS ?= -boundscheck=off \
	  -nodefaultlib \
	  -relocation-model=static \
	  -release \
	  -betterC \
	  -march=x86

LDFLAGS ?= --script linker/kernel.ld \
	   --gc-sections \
	   -m elf_i386 \

ifeq ($(DEBUG),)
	DFLAGS += -O3 \
	-flto=full

	LDFLAGS += -O3 \
		-lto-O3
else
	DFLAGS += -g
endif


all: $(KERNEL_IMG)

$(KERNEL_IMG): $(KERNEL_BINARY)
	@mkdir -p iso/boot/grub || true
	@cp -v config/grub.cfg iso/boot/grub/grub.cfg
	@cp -v $(KERNEL_BINARY) iso/boot/
	@echo Generating $@
	@grub-mkrescue iso -o $@ iso/ 2>&-


$(KERNEL_BINARY): $(KERNEL_OBJS) linker/kernel.ld
	@ld.lld $(LDFLAGS) $(KERNEL_OBJS) -o $(KERNEL_BINARY)

$(OBJ_FOLDER)/%.o : $(SRC_FOLDER)/%.d $(DEPS_FOLDER)/%.dep Makefile
	$(eval DIR := $(dir $@))
	$(eval CURRENT_DEPDIR := $(DIR:objs/%=$(DEPS_FOLDER)/%))
	@touch $(SRC_FOLDER) #makefile dependency generation broken
	@[[ -d $(DIR) ]] || mkdir -p $(DIR)
	@[[ -d $(CURRENT_DEPDIR) ]] || mkdir -p $(CURRENT_DEPDIR)
	@echo [$(DC)]	$@
	@$(DC) $(DFLAGS) -c -I$(SRC_FOLDER) $< -of $@\
		-deps=$(DEPS_FOLDER)/$*.Td
	@$(POSTCOMPILE)

$(OBJ_FOLDER)/%.o: $(SRC_FOLDER)/%.s $(DEPS_FOLDER)/%.dep
	$(eval DIR := $(dir $@))
	$(eval CURRENT_DEPDIR := $(DIR:objs/%=$(DEPS_FOLDER)/%))
	@[[ -d $(DIR) ]] || mkdir -p $(DIR)
	@[[ -d $(CURRENT_DEPDIR) ]] || mkdir -p $(CURRENT_DEPDIR)
	@[[ -d $(DIR) ]] || mkdir -p $(DIR)
	@nasm $< $(DEPFLAGS)
	@echo [nasm]	$@
	@nasm -f elf32 $< -o $@
	@$(POSTCOMPILE)

img: format_img

format_img: mount
	sudo mkfs.ext2 /dev/loop1
	sudo mount /dev/loop1 ./mnt
	sudo grub-install \
		--boot-directory=./mnt/boot \
		--locale-directory=/usr/share/locale/en_US \
		--font=deja_vu \
		--target=i386-pc \
		--modules="normal part_msdos ext2 multiboot2 biosdisk" \
		/dev/loop0
	sudo cp grub.cfg ./mnt/boot/grub/
	sync

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
	@rm -rf $(OBJ_FOLDER)
	@rm -rf $(DEPS_FOLDER)

fclean: clean

re:
	@$(MAKE) fclean
	@$(MAKE)


$(DEPS_FOLDER)/%.dep: ;
.PRECIOUS: $(DEPS_FOLDER)/%.dep

include $(wildcard $(patsubst %,$(DEPS_FOLDER)/%.dep,$(basename $(SRCS))))
