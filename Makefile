BUILD_DIR := build
IMAGE := $(BUILD_DIR)/proton.img
BOOTLOADER := src/boot/bootloader.asm
BOOT_BIN := $(BUILD_DIR)/bootloader.bin
KERNEL_DIR := src/kernel
KERNEL_SRC := $(KERNEL_DIR)/kernel.c
KERNEL_LDS := $(KERNEL_DIR)/linker.ld
KERNEL_OBJ := $(BUILD_DIR)/kernel.o
KERNEL_ELF := $(BUILD_DIR)/kernel.elf
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
KERNEL_SECTORS ?= 32
IMAGE_SECTORS := $(shell echo $$((1 + $(KERNEL_SECTORS))))

NASM ?= nasm
CC ?= gcc
LD ?= ld
OBJCOPY ?= objcopy
QEMU ?= qemu-system-x86_64

CFLAGS := -ffreestanding -fno-pic -fno-stack-protector -mno-red-zone -m64 -O2 -Wall -Wextra
LDFLAGS := -T $(KERNEL_LDS) -nostdlib

.PHONY: all run clean

all: $(IMAGE)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT_BIN): $(BOOTLOADER) | $(BUILD_DIR)
	$(NASM) -f bin $(BOOTLOADER) -o $(BOOT_BIN)

$(KERNEL_OBJ): $(KERNEL_SRC) | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $(KERNEL_SRC) -o $(KERNEL_OBJ)

$(KERNEL_ELF): $(KERNEL_OBJ) $(KERNEL_LDS)
	$(LD) $(LDFLAGS) $(KERNEL_OBJ) -o $(KERNEL_ELF)

$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $(KERNEL_ELF) $(KERNEL_BIN)

$(IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$(IMAGE) bs=512 count=$(IMAGE_SECTORS) status=none
	dd if=$(BOOT_BIN) of=$(IMAGE) conv=notrunc status=none
	dd if=$(KERNEL_BIN) of=$(IMAGE) bs=512 seek=1 conv=notrunc status=none

run: $(IMAGE)
	$(QEMU) -drive format=raw,file=$(IMAGE)

clean:
	rm -rf $(BUILD_DIR)
