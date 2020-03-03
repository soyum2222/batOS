; haribote-ipl ; TAB=4



ORG 0x7c5a
JMP entry
NOP

;    DB "MSDOS5.0"	;OEM
;    DW 0x200		;Bytes_per_sector
;    DB 8		;Sectors_per_cluster
;    DW 0x8F8		;Reserved_sectors (2 - 2296可以使用)
;    DB 2		;Number_of_FATs
;    DW 0		;Root_entries
;    DW 0		;Sectors_small
;    DB 0XF8		;Media_descriptor
;    DW 0		;Number_of_FATs16
;    DW 0x003F		;Sectors per track 
;    DW 255		;Heads
;    DD 0		;Hidden sectors
;    DD 0xEE8C00         ;Sectors total 32
;    
;    ;FAT32 SECTION
;    DD 0x00003B84       ;Number of fat32
;    DW 0                ;mirror flag
;    DW 0                ;version
;    DD 2                ;offclus_root
;    DW 1                ;fsinfo
;    DW 6                ;mbr backup
;    RESB 12             ;fat32 reserverd
;    DB 0x80             ;usb flag
;    DB 0                ;fat16 reserverd
;    DB 0x29             ;boot_sign
;    DD 0x08F85C97       ;Volume id
;    DB "NO NAME    "    ;Volume label
;    DB "FAT32   "       ;File system
;

entry:
	mov ax,0
	mov ss,ax
	mov sp,0x7c00
	mov ds,ax
	mov es,ax


	mov ax,0x0820
	mov es,ax

	;开始读磁盘
;	call rdisk

	mov ax,0x3030
	mov [0x08200],ax
	call wdisk
	
	mov ax,[0x08200]
	push ax
	call printHex

LOOP:
	hit
	jmp LOOP




printHex:
;eg 0xff
;in ax reg 0000000011111111
;ah 00000000
;al 11111111
	push bp
	mov bp,sp
	
	push ax
	push bx
	push cx
	push dx
	push si
	
	mov si,0
	mov cx , [bp+4]
	
	mov dh,0xf0
	
.loop:
	add si,1
		
	mov al,ch
	and al,dh
	shr al,4
	
	add al,0x90	;Magic numbers
	daa		
			;math amazing!!!

	adc al,0x40

	daa
	
	
	mov ah,0x0e
	mov bl,15
	int 0x10
	rol cx,4

	cmp si,4
	jne .loop
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	pop bp
	ret


rdisk:
	push ax
	push bx
	push cx
	push dx
	push si


	mov cl,30	;扇区
	mov ch,0 	;柱面
	mov DH,8	;磁头
.loop
	mov AH,0X02	;ah 读磁盘
	mov AL,1	;1个扇区
	mov DL,0X80	;驱动器编号
	mov bx,0

	int 0x13
	jnc .rdiskNextSector

	push ax
	call printHex
	mov si,.rdiskErro	
	call print
	ret	

.rdiskErro
	DB 0X0A
	DB "load disk error"
	DB 0

.rdiskSuccess
	DB " sector load success"
	DB 0X0A
	DB 0
	

.rdiskNextSector:
	push cx
	call printHex
	pop cx
	mov si,.rdiskSuccess
	call print
	add cl,1
	cmp cl,33
	jnb .rdiskNextCylinder
	mov ax,es
	add ax,0x20	
	mov es,ax
	jmp .loop

.rdiskNextCylinder
	mov cl,1
	add ch,1
	cmp ch,0
	jnb .rdiskRet
	mov ax,es
	add ax,0x20
	mov es,ax
	jmp .loop
	

.rdiskRet:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax	


	RET




print:
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push si

.loop
	mov al,[si]
	add si,1 
	cmp al,0
	JE  .printret
	mov ah,0X0E
	mov bl,15
	INT 0x10
	JMP .loop
.printret:
	call resetCur
	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp

	ret	

wdisk:
	push ax
	push bx
	push cx
	push dx
	
	mov ah,0x03
	mov al,1
	mov ch,0
	mov cl,1
	mov dh,1
	mov bx,0
	int 0x13
	jnc .ret 
	mov si,.wdiskErro
	call print
	
.ret	
	pop dx
	pop cx
	pop bx
	pop ax

	ret

.wdiskErro
	DB 0X0A
	DB "load disk error"
	DB 0




resetCur:
	
	call getCurInfo
	mov ah,0x02
	mov bh,0
	mov dl,0
	int 0x10
	
	ret


getCurInfo:

	mov ah,0x03
	mov bh,0
	int 0x10
	
	ret



msg:
	DB 0X0A
	DB 0X0A
	DB "HELLO" 
	DB 0 


	RESB 0X1FE-0x5a-($-$$)
	DB 0X55,0XAA

;	RESB 0x7dfe-($-$$)

	
