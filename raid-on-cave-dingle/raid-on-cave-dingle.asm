
	processor 6502

	seg ZEROPAGE
	org $0000
	include "../_common/zero_page.asm"
	include "./src/memory_map.asm"

	include "../_common/definitions.asm"

	seg HEADER
	; $bff0 = 1 PRG ; $7ff0 = 2+ PRG
	org $bff0
	; mapper, PRGs (16k), CHRs (8k), mirror
	NES_HEADER 0,1,1,NES_MIRR_VERT 

	seg CODE
	org $c000
level_nam:
	incbin "assets/level.nam"
	
	include "src/state.asm"
	include "src/level.asm"
	include "src/ents.asm"
	include "src/ent_dingle.asm"

level_pal:
	hex 0f 0c 11 22
	hex 0f 0c 11 22
	hex 0f 0c 11 22
	hex 0f 0c 11 22
	hex 0f 0c 11 22
	hex 0f 0c 11 22
	hex 0f 0c 11 22
	hex 0f 0c 11 22

cart_start: subroutine
	jsr bootup_clean

	; nametable	
	lda #$00
	sta temp00
	lda #$80
	sta temp01
	lda #$20
	jsr nametable_load

	; palette
	PPU_ADDR_SET $3f00
	ldx #$00
.pal_loop
	lda level_pal,x
	sta PPU_DATA
	inx
	cpx #$20
	bne .pal_loop

	jsr state_level_init

	jsr render_enable

.endless
	jmp .endless	; endless loop


nmi_handler: subroutine
	inc wtf
	lda #$02
	sta $4014
	jsr state_level_update
	rti

	seg KERNEL
	org $f000
	include "../_common/common.asm"

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
	incbin "assets/level.chr"
	incbin "assets/level.chr"
	incbin "assets/level.chr"
	incbin "assets/level.chr"
	incbin "assets/level.chr"
