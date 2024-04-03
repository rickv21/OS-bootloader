bits 16 ; Tell NASM this is 16-bit code.
org 0x7c00 ; Start output at offset 0x7c00.

boot: ; Start of boot section
    mov si,menu ; Point si register to memory location of menu label.
    mov ah,0x0e ; 0x0e = 'Write Character in TTY mode'
.loop:
    lodsb ; Address at si, store its value in al, increment si by 1
    or al,al ; Is al == 0 ?
    jz get_input  ; If (al == 0) jump to get_input label
    int 0x10 ; BIOS interrupt 0x10 - Video Services
    jmp .loop ; Jump back to start of loop
get_input:
    mov ah, 0x00 ; BIOS function to get key press
    int 0x16 ; Call BIOS
    cmp al, '1' ; Compare al with '1'
    je option1 ; If equal (Jump if Equal), go to option1
    cmp al, '2' ; Compare al with '2'
    je option2 ; If equal, go to option2
    cmp al, '3' ; Compare al with '3'
    je option3 ; If equal, go to option3
    cmp al, '4' ; Compare al with '4', secret option :)
    je option4 ; If equal, go to option4
    jmp get_input ; If none of the above, get another input
option1:
    mov si,option1_text ; Point si to option1_text
    jmp print_text ; Jump to print_text
option2:
    mov si,option2_text ; Point si to option2_text
    jmp print_text ; Jump to print_text
option3:
    mov si,option3_text ; Point si to option3_text
    jmp print_text ; Jump to print_text
option4:
    mov si,option4_text ; Point si to option3_text
    jmp print_text ; Jump to print_text
print_text:
    lodsb ; Load string byte at address si into al, increment si
    or al, al ; Logical OR al with itself
    jz halt ; If result is zero (meaning al was zero), jump to halt
    mov ah, 0x0e ; Set ah to 'Write Character in TTY mode'
    int 0x10 ; BIOS interrupt 0x10 - Video Services
    jmp print_text ; Jump back to start of print_text
halt:
    cli ; Clear interrupt flag
    hlt ; Halt execution
menu:  ; Show options
    db "Wat is je favoriete console?",13,10
    db "Druk op 1 voor Nintendo",13,10
    db "Druk op 2 voor Playstation",13,10
    db "Druk op 3 voor Xbox",13,10
	db "", 13,10,0
option1_text: db "Nintendo is je favoriete console.", 0
option2_text: db "Playstation is je favoriete console.", 0
option3_text: db "Xbox is je favoriete console.", 0
option4_text: db "PC is de betere keuze :)", 0

times 510 - ($-$$) db 0 ; Pad remaining 510 bytes with zeroes
dw 0xaa55 ; Magic bootloader magic - marks this 512 byte sector bootable!
