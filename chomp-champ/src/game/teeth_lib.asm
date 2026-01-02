
; to do
;	update teeth dmg and dirt tiles when loading level

teeth_init: subroutine
	; called after fresh playfield is drawn
	; requires dirt populated in cells
	; adds up total_dmg for each tooth
	; renders all dirt on playfield
	ldx #$00
	stx tooth_index
	stx temp01 ; cell table offset
.each_tooth
	; total dmg and render cells
	lda #$00
	clc
	sta temp00 ; dmg
	ldx #$10
	ldy temp01
.add_up_dmg
	lda teeth_cell_tables,y
	adc temp00
	sta temp00
	iny
	dex
	bne .add_up_dmg
	sty temp01
	; save total ddmg
	ldx tooth_index
	sta tooth_total_dmg,x 
	lda tooth_total_dmg,x 
	; render appropriately
	bpl .render_dmg
	jsr blackout_render
	jmp .render_done
.render_dmg
	jsr gumline_render
	jsr celldirt_render
.render_done

	; next tooth
	inc tooth_index
	ldx tooth_index
	cpx #$10
	bne .each_tooth

	; set tooth_index in range
	lda #$00
	sta tooth_index
	rts


; xxx need to check for:
;	game over (all teeth gone)
;  level complete (all teeth are clean or gone)
teeth_update: subroutine
	; adds up dirt value of all 16 cells of tooth_index based on frame counter
	; temp00 = addend
	; temp02 = eol
	; destroys x+y
	ldx tooth_index
.next_tooth
	inx
	cpx #$10
	bne .dont_wrap
	ldx #$00
.dont_wrap
	lda tooth_total_dmg,x
	; xxx this bricks
	beq .next_tooth
	bmi .next_tooth
	stx tooth_index
	; update dmg count
	txa
	shift_l 4
	tax
	clc
	adc #$10
	sta temp02
	clc
	lda #$00
	sta temp00
.tooth_loop
	lda teeth_cell_tables,x
	tay
	lda $600,y
	adc temp00
	sta temp00
	inx
	cpx temp02
	bne .tooth_loop
	ldx tooth_index
	sta tooth_total_dmg,x
.tooth_lost
	rts


; xxx no longer in use
tooth_health_update: subroutine
	; a = tooth id
	; temp00 = addend
	; temp01 = tooth_id
	; destroys x+y
	sta temp01
	shift_l 4
	tax
	ldy #$10
	clc
	lda #$00
	sta temp00
.tooth_loop
	lda tooth_cell_dmg,x
	adc temp00
	sta temp00
	inx 
	dey
	bne .tooth_loop
	ldx temp01
	sta tooth_total_dmg,x
	rts





gumline_render: subroutine
	; references tooth_index

	; update gumline tiles
	ldx tooth_index
	lda tooth_total_dmg,x
	bpl .do_render
	; dont bother on blackout
	jmp .gumline_done
.do_render
	ldx tooth_index
	lda tooth_total_dmg,x
	bne .gumline_has_dirt
	jmp .gumline_is_clean
.gumline_has_dirt
	shift_r 5
	cmp #$03
	bcc .dont_threshold
	lda #$03
.dont_threshold
	tay ; tile dmg group value
	ldx tooth_index
	lda gumline_nm_addr_hi,x
	sta PPU_ADDR
	lda gumline_nm_addr_lo,x
	sta PPU_ADDR
	; which row?
	lda tooth_index
	and #$08
	bne .gumline_bottom_row
.gumline_top_row
	lda gumline_top_row_tile_id,y
	jmp .gumline_tile_ready
.gumline_bottom_row
	lda gumline_bottom_row_tile_id,y
.gumline_tile_ready
	tax
	stx PPU_DATA
	inx
	stx PPU_DATA
	inx
	stx PPU_DATA
	inx
	stx PPU_DATA
	inx
	stx PPU_DATA
	inx
	stx PPU_DATA
	inx
	stx PPU_DATA
	inx
	stx PPU_DATA
	jmp .gumline_done
.gumline_is_clean
	ldx tooth_index
	lda gumline_nm_addr_hi,x
	sta PPU_ADDR
	lda gumline_nm_addr_lo,x
	sta PPU_ADDR
	; which row?
	ldx #$00
	lda tooth_index
	and #$08
	bne .gumline_clean_bottom
.gumline_clean_top
	lda tooth_row_upper_top,x
	sta PPU_DATA
	inx
	cpx #$08
	bne .gumline_clean_top
	jmp .gumline_done
.gumline_clean_bottom
	lda tooth_row_lower_bottom,x
	sta PPU_DATA
	inx
	cpx #$08
	bne .gumline_clean_bottom
.gumline_done

	rts



celldirt_render: subroutine
	rts



blackout_render: subroutine
	rts
