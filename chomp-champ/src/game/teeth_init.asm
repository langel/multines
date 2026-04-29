; sets up playfield for level
;

teeth_init_playfield: subroutine

	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill
	lda #$24
	jsr nametable_fill

	inc temp00
	lda #$14
	sta temp02
	lda #$c0
	sta temp03
	lda #$20
	jsr nametable_fill_rows
	lda #$24
	jsr nametable_fill_rows




level_dirty:
	; render dirty teeth cells into nametables
	lda #$00
	sta tooth_index
	sta state00 ; cell counter
	sta state01 ; call counter
.dirty_loop
	ldx state00
	ldy teeth_cell_tables,x
	sty tooth_needs_update
	inx
	ldy teeth_cell_tables,x
	sty tooth_needs_update+1
	inx
	ldy teeth_cell_tables,x
	sty tooth_needs_update+2
	inx
	ldy teeth_cell_tables,x
	sty tooth_needs_update+3
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
	
