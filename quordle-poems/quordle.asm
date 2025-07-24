
	processor 6502

	include "definitions.asm"
	include "zero_page.asm"

	; HEADER
	; mapper, PRGs (16k), CHRs (8k), mirror, ram expansion
	NES_HEADER 4, 16, 2, NES_MIRR_VERT, 0

	; BOTTOM 8k BANKS
	seg DATA_BANKS
	org $08000 ; bank #$00
	rorg $8000
	; 7 8k banks
	incbin "quordles.bin"

	org $26000 ; bank #$0d
	rorg $a000

	; FIXED 16k BANK
	seg CODE_BANK_FIXED
	org $28000 ; banks #$0e + #$0f
	rorg $c000
	include "vectors.asm"
	include "common.asm"
	include "state.asm"


	;;;;; CPU VECTORS
	seg VECTORS
	org $29ffa	
	rorg $fffa ; start at address $fffa
	.word nmi_handler	; $fffa vblank nmi
	.word cart_start	; $fffc reset
	.word irq_handler	; $fffe irq / brk


	;;;;; GRAPHX
grfx_offset EQM $30000

	org $0000+grfx_offset

	org $3fff+grfx_offset
	byte 0

