
scr_text_init: subroutine
	jsr render_disable

	lda #$20
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill

	; load a palette
	lda palette_base
	cmp #$0d
	bne .dont_rotate_pal
	lda #$00
	sta palette_base
.dont_rotate_pal
	sta temp00
	clc
	adc #$10
	sta temp01
	adc #$10
	sta temp02
	adc #$10
	sta temp03
	lda #$3f
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	ldx #$08
.pal_loop
	lda temp00
	sta PPU_DATA
	lda temp01
	sta PPU_DATA
	lda temp02
	sta PPU_DATA
	lda temp03
	sta PPU_DATA
	dex
	bne .pal_loop
	inc palette_base


	; load a poem
	lda #%0000110
	sta BANK_SELECT
	lda poem_id
	shift_r 6
	sta BANK_DATA
	sta poem_bank

	lda poem_id
	shift_r 1
	and #$3f
	clc
	adc #$80
	sta poem_hi
	lda poem_id
	shift_l 7
	sta poem_lo

	lda #$21
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	ldy #$0
.plot_line_1
	lda (poem_lo),y
	sta PPU_DATA
	iny
	cpy #$20
	bne .plot_line_1
	
	lda #$21
	sta PPU_ADDR
	lda #$40
	sta PPU_ADDR
.plot_line_2
	lda (poem_lo),y
	sta PPU_DATA
	iny
	cpy #$40
	bne .plot_line_2

	lda #$21
	sta PPU_ADDR
	lda #$80
	sta PPU_ADDR
.plot_line_3
	lda (poem_lo),y
	sta PPU_DATA
	iny
	cpy #$60
	bne .plot_line_3

	lda #$21
	sta PPU_ADDR
	lda #$c0
	sta PPU_ADDR
.plot_line_4
	lda (poem_lo),y
	sta PPU_DATA
	iny
	cpy #$80
	bne .plot_line_4
	
	jsr render_enable
	rts

scr_text_update: subroutine
	inc timer_lo
	bne .not_higher_inc
	inc timer_hi
.not_higher_inc
	lda #$80
	cmp timer_lo
	bne .not_next
	jmp scr_text_next
.not_next
	rts


scr_text_next: subroutine
	inc poem_id
	jmp scr_text_init
