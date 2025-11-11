
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
	org $8000
cart_start: subroutine
	NES_INITIALIZE
	jsr bootup_clean
	jsr state_init
	jsr render_enable
.idle_cpu
	jmp .idle_cpu
	;   $8080
	include "src/states.asm"

	include "src/level.asm"
	include "src/ents.asm"
	include "src/ent_dingle.asm"

	org $a000
level_nam:
	incbin "assets/level.nam"


	seg COMMON
	org $c000
	include "./_common/top_bank.asm"

	seg VECTORS
	org $fffa 
	.word nmi_handler ; $fffa vblank nmi
	.word cart_start  ; $fffc reset
	.word cart_start  ; $fffe irq / brk


	;;; GRAPHX
	org $010000
	incbin "assets/level.chr"
	incbin "assets/level.chr"
	incbin "assets/level.chr"
	incbin "../_common/assets/lowerc.chr"
	incbin "assets/level.chr"
	incbin "assets/level.chr"
	incbin "assets/level.chr"
	incbin "../_common/assets/lowerc.chr"
