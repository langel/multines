
	processor 6502

	include "definitions.asm"
	include "zero_page.asm"

	; HEADER
	; mapper, PRGs (16k), CHRs (8k), mirror
	NES_HEADER_NROM_128 0,1,1,NES_MIRR_VERT 

grid_nam:
	incbin "assets/grid.nam"

	include "common.asm"

grid_pal:
	hex 0f 01 11 21
	hex 0f 05 15 25
	hex 0f 09 19 29
	hex 0f 0b 1b 2b
	hex 0f 01 11 21
	hex 0f 05 15 25
	hex 0f 09 19 29
	hex 0f 0b 1b 2b

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
	cpx #$20
	bne .pal_loop

	; good stuff
	lda #$ff
	sta rng0

	jsr state_level_init

	jsr render_enable
	lda #$00
	sta PPU_SCROLL
	sta PPU_SCROLL

.endless
	jmp .endless	; endless loop


nmi_handler: subroutine
	inc wtf
	lda #$02
	sta $4014
	jsr state_level_update
	rti

	
	;;;;; CPU VECTORS
	seg VECTORS
	org $fffa ; start at address $fffa
	.word nmi_handler	; $fffa vblank nmi
	.word cart_start	; $fffc reset
	.word cart_start	; $fffe irq / brk


	;;;;; GRAPHX
	org $010000
	incbin "assets/tiles.chr"
	incbin "assets/tiles.chr"
