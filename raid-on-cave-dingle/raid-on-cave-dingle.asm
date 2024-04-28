
	processor 6502

	include "definitions.asm"
	include "zero_page.asm"

	; HEADER
	; mapper, PRGs (16k), CHRs (8k), mirror
	NES_HEADER_NROM_128 0,1,1,NES_MIRR_VERT 

level_nam:
	incbin "assets/level.nam"
	
	include "common.asm"

level_pal:
	hex 0f 0c 11 22
	hex 0f 0c 11 22
	hex 0f 0c 11 22
	hex 0f 0c 11 22

cart_start: subroutine
	NES_INIT	; set up stack pointer, turn off PPU
	jsr vsync_wait
	jsr vsync_wait
	jsr vsync_wait
	jsr ram_clear
;	jsr sprites_clear

	; ppu setup
	lda #CTRL_INC_1
	sta PPU_CTRL

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
	cpx #$10
	bne .pal_loop

	jsr render_enable
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL

.endless
	jmp .endless	; endless loop


nmi_handler: subroutine
	rti

	
	;;;;; CPU VECTORS
	seg VECTORS
	org $fffa ; start at address $fffa
	.word nmi_handler	; $fffa vblank nmi
	.word cart_start	; $fffc reset
	.word cart_start	; $fffe irq / brk


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
