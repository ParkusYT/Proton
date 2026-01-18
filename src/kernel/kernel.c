#include <stdint.h>

__attribute__((noreturn)) void _start(void) {
    const char *message = "Proton x64 C kernel";
    volatile uint8_t *vga = (uint8_t *)0xB8000;

    for (uint32_t i = 0; message[i] != '\0'; i++) {
        vga[i * 2] = (uint8_t)message[i];
        vga[i * 2 + 1] = 0x0F;
    }

    for (;;) {
        __asm__ volatile("hlt");
    }
}
