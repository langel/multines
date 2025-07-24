
	processor 6502

	include "definitions.asm"
	include "zero_page.asm"

	; HEADER
	; mapper, PRGs (16k), CHRs (8k), mirror, ram expansion
	NES_HEADER 4, 8, 2, NES_MIRR_VERT, 0

	; BOTTOM 8k BANKS
	seg DATA_BANKS
	org $08000 ; bank #$00
	rorg $8000
	; 7 8k banks
	incbin "quordles.bin"

	; FIXED 16k BANK
	seg CODE_BANK_FIXED
	;org $30000 ; banks #$0e + #$0f
	;rorg $c000
	org $26000 ; banks #$0e + #$0f
	rorg $e000
	include "vectors.asm"
	include "common.asm"
	include "scr_text.asm"
	include "scr_photo.asm"


	;;;;; CPU VECTORS
	seg VECTORS
	org $27ffa	
	rorg $fffa ; start at address $fffa
	.word nmi_handler	; $fffa vblank nmi
	.word cart_start	; $fffc reset
	.word nmi_handler	; $fffe irq / brk


	;;;;; GRAPHX
grfx_offset EQM $28000

	org $0000+grfx_offset
	incbin "text.chr"
	incbin "text.chr"
	incbin "text.chr"
	incbin "text.chr"

;	org $3fff+grfx_offset
;	byte 0

