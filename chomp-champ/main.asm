; 
;	GAME TEMPLATE


	processor 6502

	seg.u ZEROPAGE
	org $0000
	include "./_common/definitions.asm"
	include "./_common/zero_page.asm"
	include "src/memory_map.asm"
	
	seg HEADER
	; $bff0 = 1 PRG ; $7ff0 = 2+ PRG
	org $7ff0
	; mapper, PRGs (16k), CHRs (8k), mirror
	NES_HEADER 0,2,1,NES_MIRR_VERT 

	seg CODE
	; $c000 = 1 PRG ; $8000 = 2+ PRG
	org $8000
cart_start: subroutine
	NES_INITIALIZE
	jsr bootup_clean
	jsr state_init
.idle_cpu
	jmp .idle_cpu
	;   $8080
	include "src/states.asm"
	include "src/palette.asm"

	seg COMMON
	org $c000
	include "./_common/top_bank.asm"

	seg VECTORS
	org $fffa 
	.word nmi_handler ; $fffa vblank nmi
	.word cart_start  ; $fffc reset
	.word cart_start  ; $fffe irq / brk


	seg GRAPHICS
	org $010000
	incbin "assets/main.chr"
	incbin "assets/main.chr"
