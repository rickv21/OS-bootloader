bits 16 ; Vertel NASM dat dit 16-bit code is.
org 0x7c00 ; Begin met uitvoer bij offset 0x7c00.

boot: ; Start boot section
    mov si,hello ; Point si register to hello label memory location.
    mov ah,0x0e ; 0x0e = 'Write Character in TTY mode'
.loop:
    lodsb ; address at si, store its value in al, increment si by 1
    or al,al ; is al == 0 ?
    jz halt  ; if (al == 0) jump to halt label
    int 0x10 ; BIOS interrupt 0x10 - Video Services
    jmp .loop
halt:
    cli ; clear interrupt flag
    hlt ; halt execution
hello: db "Hello world!",0

times 510 - ($-$$) db 0 ; pad remaining 510 bytes with zeroesk
dw 0xaa55 ; magic bootloader magic - marks this 512 byte sector bootable!