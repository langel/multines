
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
	; Persist missing teeth across levels:
	; if tooth_total_dmg already has sign bit set, keep it missing.
	ldx tooth_index
	lda tooth_total_dmg,x
	bmi .persist_missing_tooth

	; total dmg and render cells
	lda #$00
	clc
	sta temp00 ; dmg
	ldx #$10
	ldy temp01
.add_up_dmg
	stx temp02
	lda teeth_cell_tables,y
	tax
	lda $600,x
	adc temp00
	sta temp00
	iny
	ldx temp02
	dex
	bne .add_up_dmg
	sty temp01
	; save total ddmg
	ldx tooth_index
	sta tooth_total_dmg,x 
	lda tooth_total_dmg,x
	bne .not_true_clean_init
	lda #$01
	sta tooth_true_clean,x
	lda tooth_total_dmg,x
	jmp .init_true_clean_done
.not_true_clean_init
	lda #$00
	sta tooth_true_clean,x
	lda tooth_total_dmg,x
.init_true_clean_done
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

.persist_missing_tooth
	; Skip damage recompute but keep cell-table offset aligned.
	lda temp01
	clc
	adc #$10
	sta temp01
	; Missing teeth are never truly clean.
	lda #$00
	sta tooth_true_clean,x
	jsr blackout_render
	jmp .render_done


teeth_update: subroutine
	; adds up dirt value of all 16 cells of tooth_index based on frame counter
	; temp00 = addend
	; temp02 = eol
	; destroys x+y

;check_mouth_state BEGIN
	; check for game over
	; or next level
	lda #$00
	sta temp00 ; dead counter
	sta temp01 ; clean counter
	ldx #$0f
.loop
	lda tooth_total_dmg,x
	bpl .not_dead
	inc temp00
	jmp .tooth_checked
.not_dead
	lda tooth_true_clean,x
	beq .tooth_checked
	inc temp01
.tooth_checked
	dex
	bpl .loop
	; check for game over
	lda temp00
	cmp #$10
	bne .not_gameover
	jsr state_gameover_init
.not_gameover
	; check for next level
	; authoritative condition: missing_teeth + truly_clean_teeth == 16
	lda temp00
	clc
	adc temp01
	cmp #$10
	bne .not_nextlevel
	jsr state_nextlevel_init
.not_nextlevel
;check_mouth_state FINISH

	; add up dirt on current tooth
	ldx tooth_index
.next_tooth
	inx
	cpx #$10
	bne .dont_wrap
	ldx #$00
.dont_wrap
	stx tooth_index
	lda tooth_total_dmg,x
	bmi .tooth_lost
	; xxx this bricks
	;beq .next_tooth
	;bmi .next_tooth
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
	clc
	adc temp00
	sta temp00
	inx
	cpx temp02
	bne .tooth_loop
	ldx tooth_index
	sta tooth_total_dmg,x
.tooth_lost
	ldx tooth_index
	lda tooth_total_dmg,x
	bmi .mark_not_true_clean
	bne .mark_not_true_clean
	lda #$01
	sta tooth_true_clean,x
	ldy #$1f
.food_check_loop
	lda ent_type,y
	cmp #ent_food_id
	bne .food_check_next
	lda ent_r0,y
	bmi .food_check_next
	lda ent_r4,y
	cmp tooth_index
	beq .food_blocks_clean
	lda ent_r5,y
	cmp tooth_index
	bne .food_check_next
.food_blocks_clean
	lda #$00
	sta tooth_true_clean,x
	jmp .true_clean_done
.food_check_next
	dey
	bpl .food_check_loop
.true_clean_done
	rts
.mark_not_true_clean
	lda #$00
	sta tooth_true_clean,x
	rts





	; XXX this should probably be cached!
	; this is prelevel rendering?!?!
gumline_render: subroutine
	; update gumline tiles
	; references tooth_index
	ldx tooth_index
	lda tooth_total_dmg,x
	bpl .do_render
	; dont bother on blackout
	jmp .gumline_done
.do_render
	lda tooth_true_clean,x
	bne .gumline_is_clean
.gumline_has_dirt
	lda tooth_total_dmg,x
	shift_r 4
	cmp #$03
	bcc .dont_threshold
	lda #$03
.dont_threshold
	tay ; tile dmg group value
	lda gumline_nm_addr_hi,x
	sta PPU_ADDR
	lda gumline_nm_addr_lo,x
	sta PPU_ADDR
	; which row?
	txa
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
