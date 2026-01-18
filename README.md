# Proton

Proton is a tiny OS experiment. Right now it includes a single boot sector that enters 64-bit long mode and halts (no kernel yet).

## Requirements
- `nasm`
- `make`
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
- `build/proton.img`: output disk image

## Notes
- The bootloader identity-maps the first 2 MiB and halts in long mode.