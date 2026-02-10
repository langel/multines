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
.loop_gums_top
	sta PPU_DATA
	dex
	bne .loop_gums_top
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
	; gums
	ldx #$20
	lda #$09
.loop_gums_bottom
	sta PPU_DATA
	dex
	bne .loop_gums_bottom

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


level_dirty:
	; render dirty teeth cells
	lda #$00
	sta tooth_index
	sta state00 ; cell counter
	sta state01 ; call counter
.dirty_loop
	ldx state00
	stx tooth_needs_update
	inx
	stx tooth_needs_update+1
	inx
	stx tooth_needs_update+2
	inx
	stx tooth_needs_update+3
	inx
	stx state00
	lda #$04
	sta tooth_update_queue_size
	jsr state_game_prerender
	jsr state_level_render
	inc state01
	lda state01
	and #$03
	bne .not_next_tooth
	inc tooth_index
.not_next_tooth
	lda tooth_index
	cmp #$10
	bne .dirty_loop

	lda #$00
	sta tooth_index
	sta tooth_update_queue_size

	rts
