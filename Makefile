makeimg:
	rm -rf bat
	mkdir bat
	mkfs.vfat -n "batos" -F 32 -C batos.img 0x2000
	nasm ipl.asm
	dd if=ipl of=batos.img bs=1 seek=90 conv=notrunc
	mount -o loop batos.img bat
	cp print bat
	umount bat
