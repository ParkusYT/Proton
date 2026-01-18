# Proton

Proton is a tiny OS experiment. Right now it boots a minimal C kernel in 64-bit long mode.

## Requirements
- `nasm`
- `make`
- `gcc`
- `ld` (binutils)
- `objcopy` (binutils)
- `qemu-system-x86_64` (to run)

## Build
```bash
make
```

## Run
```bash
make run
```

## Layout
- `src/boot/bootloader.asm`: 512-byte boot sector that switches to long mode
- `src/kernel/`: C kernel and linker script
- `build/proton.img`: output disk image

## Notes
- The bootloader identity-maps the first 2 MiB and jumps to the kernel entry at `0x10000`.
- Keep `KERNEL_SECTORS` in `Makefile` and `KERNEL_SECTORS` in `src/boot/bootloader.asm` in sync.