BUILD_DIR := build
IMAGE := $(BUILD_DIR)/proton.img
BOOTLOADER := src/boot/bootloader.asm
BOOT_BIN := $(BUILD_DIR)/bootloader.bin

NASM ?= nasm
QEMU ?= qemu-system-x86_64

.PHONY: all run clean

all: $(IMAGE)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT_BIN): $(BOOTLOADER) | $(BUILD_DIR)
	$(NASM) -f bin $(BOOTLOADER) -o $(BOOT_BIN)

$(IMAGE): $(BOOT_BIN)
	dd if=/dev/zero of=$(IMAGE) bs=512 count=1 status=none
	dd if=$(BOOT_BIN) of=$(IMAGE) conv=notrunc status=none

run: $(IMAGE)
	$(QEMU) -drive format=raw,file=$(IMAGE)

clean:
	rm -rf $(BUILD_DIR)
