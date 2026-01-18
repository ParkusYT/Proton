; Simple x86_64 bootloader: enters long mode and halts
; Assembles with NASM: nasm -f bin bootloader.asm -o bootloader.bin

BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Enable A20 via port 0x92 (fast A20)
    in al, 0x92
    or al, 0x02
    out 0x92, al

    ; Setup temporary GDT for protected mode and long mode
    lgdt [gdt_descriptor]

    ; Enable protected mode
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ; Far jump to flush pipeline and load CS
    jmp CODE32_SEL:protected_mode

BITS 32
protected_mode:
    mov ax, DATA32_SEL
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x9FC00

    ; Clear page tables area
    mov edi, 0x1000
    mov ecx, (4096 * 4) / 4
    xor eax, eax
    rep stosd

    ; Build PML4 (0x1000), PDPT (0x2000), PD (0x3000)
    mov dword [0x1000], 0x2003      ; PML4[0] -> PDPT | P R/W
    mov dword [0x2000], 0x3003      ; PDPT[0] -> PD   | P R/W
    mov dword [0x3000], 0x00000083  ; PD[0] -> 2MiB page | P R/W PS

    ; Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Enable Long Mode in EFER
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Load PML4 base
    mov eax, 0x1000
    mov cr3, eax

    ; Enable paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; Far jump to long mode
    jmp CODE64_SEL:long_mode

BITS 64
long_mode:
    mov ax, DATA64_SEL
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov rsp, 0x9FC00

halt:
    hlt
    jmp halt

; ----------------------
; GDT
; ----------------------
ALIGN 8
GDT_START:
    dq 0x0000000000000000
    dq 0x00CF9A000000FFFF ; 32-bit code
    dq 0x00CF92000000FFFF ; 32-bit data
    dq 0x00AF9A000000FFFF ; 64-bit code
    dq 0x00AF92000000FFFF ; 64-bit data
GDT_END:

gdt_descriptor:
    dw GDT_END - GDT_START - 1
    dd GDT_START

CODE32_SEL equ 0x08
DATA32_SEL equ 0x10
CODE64_SEL equ 0x18
DATA64_SEL equ 0x20

; Boot signature
TIMES 510 - ($ - $$) db 0
DW 0xAA55
