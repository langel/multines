; sets up playfield for level
;
; todo
;	- add random dirt
;	- add food/germs/etc
;	- add dirt around food
;	- create each level population tables or w/e

teeth_init_playfield: subroutine
	lda #$20
	sta temp00
.nametable_loop

	lda temp00
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	; clear head
	lda #$08
	ldx #$c0
.head_clear
	sta PPU_DATA
	dex
	bne .head_clear
	; gumline
	ldx #$20
	lda #$09
.loop_gumline_top
	sta PPU_DATA
	dex
	bne .loop_gumline_top
	; upper_top
	ldx #$00
	ldy #$00
.loop_upper_top
	lda tooth_row_upper_top,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$20
	bne .loop_upper_top
	; generic teefs
	ldx #$00
	ldy #$00
.loop_upper_generics
	lda tooth_row_generic,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$e0
	bne .loop_upper_generics
	; upper_bottom
	ldx #$00
	ldy #$00
.loop_upper_bottom
	lda tooth_row_upper_bottom,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$20
	bne .loop_upper_bottom
	; lower_top
	ldx #$00
	ldy #$00
.loop_lower_top
	lda tooth_row_lower_top,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$20
	bne .loop_lower_top
	; generic teefs
	ldx #$00
	ldy #$00
.loop_lower_generics
	lda tooth_row_generic,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$e0
	bne .loop_lower_generics
	; lower_bottom
	ldx #$00
	ldy #$00
.loop_lower_bottom
	lda tooth_row_lower_bottom,x
	sta PPU_DATA
	inx
	txa
	and #$07
	tax
	iny
	cpy #$20
	bne .loop_lower_bottom
	; gumline
	ldx #$20
	lda #$09
.loop_gumline_bottom
	sta PPU_DATA
	dex
	bne .loop_gumline_bottom

	; clear butt
	lda #$08
	ldx #$80
.butt_clear
	sta PPU_DATA
	dex
	bne .butt_clear
	
	; another nametable?
	lda temp00
	clc
	adc #$04
	cmp #$28
	beq .done_nametabling
	sta temp00
	jmp .nametable_loop
.done_nametabling


	rts
