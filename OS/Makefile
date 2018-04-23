boot: BOOT.ASM
	asm8080 -lBOOT.lst BOOT.ASM

simplec: SIMPLEC.ASM FUNCTION.INC STRING.INC MEMNGR.ASM
	asm8080 -lSIMPLEC.lst SIMPLEC.ASM

clean:
	rm *.lst *.hex *.bin *.m
