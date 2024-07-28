; 
;	GAME TEMPLATE


	processor 6502

	include "../_common/definitions.asm"
	include "../_common/zero_page.asm"
	include "./src/memory_map.asm"
	
	; mapper, PRGs (16k), CHRs (8k), mirror
	NES_HEADER 0,1,1,NES_MIRR_VERT 

	seg STATE
	include "./src/states.asm

	seg KERNEL
	org $f000
	include "../_common/kernel.asm"
	include "../_common/common.asm"

	seg VECTORS
	org $fffa 
	.word kernel  ; $fffa vblank nmi
	.word bootup  ; $fffc reset
	.word bootup  ; $fffe irq / brk


	seg GRAPHICS
	org $010000
