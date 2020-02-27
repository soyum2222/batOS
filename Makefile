makeimg:
	mkfs.vfat -n "batos" -F 32 -C batos.img 0x20000
	nasm.exe ipl.asm
	dd if=ipl of=batos.img bs=1 seek=90 conv=notrunc


