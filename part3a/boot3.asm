bits 16 ; Tell NASM this is 16-bit code.
org 0x7c00 ; Start output at offset 0x7c00.

boot: ; Start of boot section
    mov ax, 0x2401
    int 0x15 ; enable A20 bit
	mov ax, 0x3
	int 0x10 ; set vga text mode 3
	mov [disk],dl
	mov ah, 0x2    ;read sectors
	mov al, 6      ;sectors to read
	mov ch, 0      ;cylinder idx
	mov dh, 0      ;head idx
	mov cl, 2      ;sector idx
	mov dl, [disk] ;disk idx
	mov bx, copy_target;target pointer
	int 0x13
	lgdt [gdt_pointer]
	mov eax, cr0
	or eax,0x1
	mov cr0, eax
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	jmp CODE_SEG:boot2
gdt_start:
	dq 0x0
gdt_code:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0
gdt_data:
	dw 0xFFFF
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0
gdt_end:
gdt_pointer:
	dw gdt_end - gdt_start
	dd gdt_start
disk:
	db 0x0
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
times 510 - ($-$$) db 0 ; Pad remaining 510 bytes with zeroes
dw 0xaa55 ; Magic bootloader magic - marks this 512 byte sector bootable!
copy_target:
bits 32 ; Go into 32-bit mode
   hello: db "Hello more than 512 bytes world!!",0
boot2:
	mov esi,hello
	mov ebx,0xb8000
.loop:
	lodsb
	or al,al
	jz halt
	or eax,0x0300
	mov word [ebx], ax
	add ebx,2
	jmp .loop
halt:
	cli
	hlt
times 1024 - ($-$$) db 0
