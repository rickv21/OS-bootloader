section .boot
bits 16 ; Tell NASM this is 16-bit code.
global boot
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
	mov esp,kernel_stack_top
	extern kmain
	call kmain
	cli
	hlt
section .bss
align 4
kernel_stack_bottom: equ $
	resb 16384 ; 16 KB
kernel_stack_top:

section .data
    menu db "1. Option 1", 0xA, "2. Option 2", 0xA, "3. Option 3", 0xA, 0
    option1 db "You selected Option 1", 0xA, 0
    option2 db "You selected Option 2", 0xA, 0
    option3 db "You selected Option 3", 0xA, 0

section .text
    global _start
    _start:
        ; print menu
        mov eax, 4
        mov ebx, 1
        mov ecx, menu
        mov edx, menu_end - menu ; calculate length
        int 0x80

        ; read user input
        mov eax, 3
        mov ebx, 0
        mov ecx, buffer
        mov edx, 1
        int 0x80

        ; print selected option
        mov eax, 4
        mov ebx, 1
        cmp byte [buffer], '1'
        je print_option1
        cmp byte [buffer], '2'
        je print_option2
        cmp byte [buffer], '3'
        je print_option3

    print_option1:
        mov ecx, option1
        mov edx, option1_end - option1 ; calculate length
        jmp print_option

    print_option2:
        mov ecx, option2
        mov edx, option2_end - option2 ; calculate length
        jmp print_option

    print_option3:
        mov ecx, option3
        mov edx, option3_end - option3 ; calculate length

    print_option:
        int 0x80

        ; exit
        mov eax, 1
        xor ebx, ebx
        int 0x80

section .bss
    buffer resb 1

section .data
    menu_end db 0
    option1_end db 0
    option2_end db 0
    option3_end db 0
