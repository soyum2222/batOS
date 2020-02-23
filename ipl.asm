; haribote-ipl ; TAB=4



ORG 0x7c00
JMP entry
NOP
	DB "SHUNIX  " ;文件名字和版本号
	DW 0x200 	;扇区字节数
	DB 0x08		;没簇扇区数
	DW 0x0c22	;保留扇区
	DB 0x02		;FAT表个数
	DW 0x00		;FAT12/16中 根目录的个数  FAT32为0
	DW 0x00		;FAT12/16中 总扇区	  FAT32为0
	DB 0xf8		;那种存储介质，0xf8标准值
	DW 0x00		;FAT32必须为0，FAT12/FAT16为一个FAT 表所占的扇区数
	DW 0X003F	;每磁道扇区数，只对于“特殊形状”（由磁头和柱面分割为若干磁道）的存储介质有效，0x003F=63。
	DW 0x00FF	;磁头数，只对特殊的介质才有效，0x00FF=255。	
	DD 0x0004a800   ;EBR分区之前所隐藏的扇区数，0x0004A800=305152又出现了呢，与MBR中地址0x1C6开始的4个字节数值相等。
	DD 0x00080000	;文件系统总扇区数，0x00E83800=15218688
	DD 0x000039EF	;每个FAT表占用扇区数，0x000039EF=14831
	DW "  "		;标记，此域FAT32 特有。
	DW 0x0000	;FAT32版本号0.0，FAT32特有。
	DD 0x02		;根目录所在第一个簇的簇号，0x02。（虽然在FAT32文件系统下，根目录可以存放在数据区的任何位置，但是通常情况下还是起始于2号簇）
	DW 0x01		;FSINFO（文件系统信息扇区）扇区号0x01，该扇区为操作系统提供关于空簇总数及下一可用簇的信息。
	DW 0x0006	;备份引导扇区的位置。备份引导扇区总是位于文件系统的6号扇区。
	RESB 0x12	;用于以后FAT 扩展使用。
	DB 0		;与FAT12/16 的定义相同，只不过两者位于启动扇区不同的位置而已。
	DB 0		;与FAT12/16 的定义相同，只不过两者位于启动扇区不同的位置而已 。
	DB 0X29		;扩展引导标志，0x29。与FAT12/16 的定义相同，只不过两者位于启动扇区不同的位置而已
	DD 0		;卷序列号。通常为一个随机值。
	RESB 11		;卷标（ASCII码），如果建立文件系统的时候指定了卷标，会保存在此。0x52~0x59：
	DB "FAT32   "	;8字节，文件系统格式的ASCII码，FAT32。
entry:
	mov ax,0
	mov ss,ax
	mov sp,0x7c00
	mov ds,ax
	mov es,ax


	mov ax,0x0820
	mov es,ax

	;开始读磁盘
	mov cl,2	;扇区
	call rdisk



L:
	HLT
	jmp L





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

	mov AH,0X02	;ah 读磁盘
	mov AL,1	;1个扇区
	mov CH,0	;柱面
	mov DH,0	;磁头
	mov BX,0	
	mov DL,0X80	;驱动器编号

	int 0x13
	jnc .rdiskNext

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
	

.rdiskNext:
	push cx
	call printHex
	pop cx
	mov si,.rdiskSuccess
	call print
	add cl,1
	cmp cl,18
	jeb .rdiskRet
	mov ax,es
	add ax,0x20	
	mov es,ax
	jmp rdisk


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


	RESB 0X1FE-($-$$)
	DB 0X55,0XAA

	RESB 0x20000000-($-$$)

	
