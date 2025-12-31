
state_game_render: subroutine
	; uses popslide
	; 1st byte : number of steps
	;            0 = no more tasks
	; 2nd byte : ppu addr hi
	; 3rd byte : ppu addr lo
	; then step bytes
	tsx
	stx temp00
	ldx #$ff
	txs
.task_next
	pla
	beq .done
	tay
	pla
	sta PPU_ADDR
	pla 
	sta PPU_ADDR
.yloop
	pla
	sta PPU_DATA
	dey
	bne .yloop
	jmp .task_next
.done
	ldx temp00
	txs
	lda #$00
	sta tooth_update_queue_size
	jmp nmi_render_done



state_game_prerender: subroutine

	; reset render queue
	; store in temp03
	ldy #$00
	sty $100
	sty temp03

	; check for tooth blackout
	ldx tooth_index
	lda tooth_total_dmg,x
	bmi .no_blackout
	cmp #$40
	bcc .no_blackout
	jmp .do_blackout
.no_blackout

	; update cells
	ldx tooth_update_queue_size
	bne .queue_loop
	jmp .tooth_cells_done
.queue_loop
	dex
	; precalc the 4 tiles
	lda tooth_needs_update,x
	tay
	lda tooth_cell_dmg,y
	bne .render_dirt
	jmp .render_clean
.render_dirt
	sta temp01
	tya
	adc rng_val0
	sta temp00
	; cell quadrant 0
	and #$03
	shift_l 4
	clc
	adc #$a0
	adc temp01
	sta tooth_tile_cache+0
	; cell quadrant 1
	inc temp00
	lda temp00
	and #$03
	shift_l 4
	clc
	adc #$a0
	adc temp01
	sta tooth_tile_cache+1
	; cell quadrant 2
	inc temp00
	lda temp00
	and #$03
	shift_l 4
	clc
	adc #$a0
	adc temp01
	sta tooth_tile_cache+2
	; cell quadrant 3
	inc temp00
	lda temp00
	and #$03
	shift_l 4
	clc
	adc #$a0
	adc temp01
	sta tooth_tile_cache+3

	; check tooth side edges
	tya
	and #$03
	bne .not_left_edge
	; on left edge
	lda temp01
	shift_r 2
	shift_l 4
	clc
	adc #$16
	sta tooth_tile_cache+0
	sta tooth_tile_cache+2
	jmp .not_right_edge
.not_left_edge
	cmp #$03
	bne .not_right_edge
	; on right edge
	lda temp01
	shift_r 2
	shift_l 4
	clc
	adc #$17
	sta tooth_tile_cache+1
	sta tooth_tile_cache+3
.not_right_edge
	; check bottom edge of top teeth
	tya
	and #$e0
	cmp #$60
	bne .top_edge_check_done
	lda temp01
	tya
	and #$03
	bne .not_top_tooth_bottom_left
	lda #$35
	sta tooth_tile_cache+2
	jmp .edge_check_done
.not_top_tooth_bottom_left
	cmp #$03
	bne .not_top_tooth_bottom_right
	lda #$45
	sta tooth_tile_cache+3
.not_top_tooth_bottom_right
.top_edge_check_done
	; check top edge of bottom teeth
	tya
	and #$e0
	cmp #$80
	bne .edge_check_done
	lda temp01
	shift_r 2
	clc
	adc #$7c
	sta tooth_tile_cache+0
	sta tooth_tile_cache+1
	tya
	and #$03
	bne .not_bottom_tooth_top_left
	lda #$06
	sta tooth_tile_cache+0
	jmp .edge_check_done
.not_bottom_tooth_top_left
	cmp #$03
	bne .not_bottom_tooth_top_right
	lda #$07
	sta tooth_tile_cache+1
.not_bottom_tooth_top_right
.edge_check_done
	jmp .plot_render

.render_clean
	; empty cell of dirt
	lda #$0b
	sta tooth_tile_cache+0
	sta tooth_tile_cache+1
	sta tooth_tile_cache+2
	sta tooth_tile_cache+3
	; check tooth side edges
	tya
	and #$03
	bne .not_clean_left_edge
	lda #$e6
	sta tooth_tile_cache+0
	sta tooth_tile_cache+2
	jmp .not_clean_right_edge
.not_clean_left_edge
	cmp #$03
	bne .not_clean_right_edge
	lda #$e7
	sta tooth_tile_cache+1
	sta tooth_tile_cache+3
.not_clean_right_edge
	; check bottom edge of top teeth
	tya
	and #$e0
	cmp #$60
	bne .top_edge_clean_check_done
	lda temp01
	tya
	and #$03
	bne .not_top_tooth_bottom_left_clean
	lda #$e8
	sta tooth_tile_cache+2
	jmp .edge_check_clean_done
.not_top_tooth_bottom_left_clean
	cmp #$03
	bne .not_top_tooth_bottom_right_clean
	lda #$e9
	sta tooth_tile_cache+3
.not_top_tooth_bottom_right_clean
.top_edge_clean_check_done
	; check top edge of bottom teeth
	tya
	and #$e0
	cmp #$80
	bne .edge_check_clean_done
	lda #$f7
	sta tooth_tile_cache+0
	sta tooth_tile_cache+1
	tya
	and #$03
	bne .not_bottom_tooth_top_left_clean
	lda #$f6
	sta tooth_tile_cache+0
	jmp .edge_check_clean_done
.not_bottom_tooth_top_left_clean
	cmp #$03
	bne .not_bottom_tooth_top_right_clean
	lda #$f8
	sta tooth_tile_cache+1
.not_bottom_tooth_top_right_clean
.edge_check_clean_done

.plot_render
	; top row of cell
	ldy temp03
	lda #$02 ; number of render steps
	PUSHY
	lda tooth_needs_update,x
	stx temp00
	tax
	lda tooth_cell2nm_hi,x
	PUSHY
	lda tooth_cell2nm_lo,x
	PUSHY
	lda tooth_tile_cache+0
	PUSHY
	lda tooth_tile_cache+1
	PUSHY
	; bottom row of cell
	lda #$02 ; number of render steps
	PUSHY
	ldx temp00
	lda tooth_needs_update,x
	tax
	lda tooth_cell2nm_hi,x
	PUSHY
	lda tooth_cell2nm_lo,x
	clc
	adc #$20
	PUSHY
	lda tooth_tile_cache+2
	PUSHY
	lda tooth_tile_cache+3
	PUSHY
	sty temp03
	ldx temp00
	jmp .render_cell_done

.render_cell_done
	; next cell
	txa
	bne .do_loop
	; loop done
	ldx #$00
	stx tooth_update_queue_size
	jmp .tooth_cells_done
.do_loop
	jmp .queue_loop
.tooth_cells_done
	ldy temp03


	; update gumline tiles
	ldx tooth_index
	lda tooth_total_dmg,x
	bpl .gumline_update
	jmp .gumline_done
.gumline_update
	lda #$08 ; always update 8 tiles
	PUSHY
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
	sta temp01 ; tile dmg group value
	ldx tooth_index
	lda gumline_nm_addr_hi,x
	PUSHY
	lda gumline_nm_addr_lo,x
	PUSHY
	; which row?
	lda tooth_index
	and #$08
	bne .gumline_bottom_row
.gumline_top_row
	ldx temp01
	lda gumline_top_row_tile_id,x
	jmp .gumline_tile_ready
.gumline_bottom_row
	ldx temp01
	lda gumline_bottom_row_tile_id,x
.gumline_tile_ready
	tax
	PUSHY
	inx
	txa
	PUSHY
	inx
	txa
	PUSHY
	inx
	txa
	PUSHY
	inx
	txa
	PUSHY
	inx
	txa
	PUSHY
	inx
	txa
	PUSHY
	inx
	txa
	PUSHY
	jmp .gumline_done
.gumline_is_clean
	ldx tooth_index
	lda gumline_nm_addr_hi,x
	PUSHY
	lda gumline_nm_addr_lo,x
	PUSHY
	; which row?
	ldx #$00
	lda tooth_index
	and #$08
	bne .gumline_clean_bottom
.gumline_clean_top
	lda tooth_row_upper_top,x
	PUSHY
	inx
	cpx #$08
	bne .gumline_clean_top
	jmp .gumline_done
.gumline_clean_bottom
	lda tooth_row_lower_bottom,x
	PUSHY
	inx
	cpx #$08
	bne .gumline_clean_bottom
.gumline_done


	; lets dick around with attributes
	ldx tooth_index
	lda tooth_total_dmg,x
	shift_r 4
	sta temp00
	cmp #$04
	bcc .choose_palette
	lda #$03
.choose_palette
	sta temp00
	shift_l 2
	ora temp00
	shift_l 2
	ora temp00
	shift_l 2
	ora temp00
	sta temp00 ; attr val
	ldx tooth_index
	; tooth root row attr
	lda #$02 ; render steps
	sta $100,y
	iny
	lda tooth_attr_hi,x
	sta $100,y
	iny
	lda tooth_root_attr_lo,x
	sta $100,y
	iny
	lda temp00
	sta $100,y
	iny
	sta $100,y
	iny
	; tooth top row attr
	lda #$02 ; render steps
	sta $100,y
	iny
	lda tooth_attr_hi,x
	sta $100,y
	iny
	lda tooth_main_attr_top_lo,x
	sta $100,y
	iny
	lda temp00
	sta $100,y
	iny
	sta $100,y
	iny
	; tooth bottom row attr
	lda #$02 ; render steps
	sta $100,y
	iny
	lda tooth_attr_hi,x
	sta $100,y
	iny
	lda tooth_main_attr_bottom_lo,x
	sta $100,y
	iny
	lda temp00
	sta $100,y
	iny
	sta $100,y
	iny
	
	jmp .skip_black_out


	; xxx check tooth for cleared
.do_blackout
	ora #$80
	sta tooth_total_dmg,x
	; gumline
	lda #$08
	PUSHY
	lda gumline_nm_addr_hi,x
	PUSHY
	lda gumline_nm_addr_lo,x
	PUSHY
	lda tooth_index
	and #$08
	bne .gumline_empty_bottom
.gumline_empty_top
	ldx #$00
	MAC GUMTOP_PRERENDER
	lda gumline_top_empty_tile_pattern,x
	PUSHY
	inx
	ENDM
	GUMTOP_PRERENDER
	GUMTOP_PRERENDER
	GUMTOP_PRERENDER
	GUMTOP_PRERENDER
	GUMTOP_PRERENDER
	GUMTOP_PRERENDER
	GUMTOP_PRERENDER
	GUMTOP_PRERENDER
	jmp .gumline_empty_done
.gumline_empty_bottom
	ldx #$00
	MAC GUMBOTTOM_PRERENDER
	lda gumline_bottom_empty_tile_pattern,x
	PUSHY
	inx
	ENDM
	GUMBOTTOM_PRERENDER
	GUMBOTTOM_PRERENDER
	GUMBOTTOM_PRERENDER
	GUMBOTTOM_PRERENDER
	GUMBOTTOM_PRERENDER
	GUMBOTTOM_PRERENDER
	GUMBOTTOM_PRERENDER
	GUMBOTTOM_PRERENDER
.gumline_empty_done
	; main row 0
	lda #$08
	PUSHY
	lda tooth_index
	shift_l 3
	tax
	lda tooth_tile_rows_hi,x
	PUSHY
	lda tooth_tile_rows_lo,x
	PUSHY
	lda #$08
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	; main row 1
	inx
	lda #$08
	PUSHY
	lda tooth_tile_rows_hi,x
	PUSHY
	lda tooth_tile_rows_lo,x
	PUSHY
	lda #$08
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	; main row 2
	inx
	lda #$08
	PUSHY
	lda tooth_tile_rows_hi,x
	PUSHY
	lda tooth_tile_rows_lo,x
	PUSHY
	lda #$08
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	; main row 3
	inx
	lda #$08
	PUSHY
	lda tooth_tile_rows_hi,x
	PUSHY
	lda tooth_tile_rows_lo,x
	PUSHY
	lda #$08
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	; main row 4
	inx
	lda #$08
	PUSHY
	lda tooth_tile_rows_hi,x
	PUSHY
	lda tooth_tile_rows_lo,x
	PUSHY
	lda #$08
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	; main row 5
	inx
	lda #$08
	PUSHY
	lda tooth_tile_rows_hi,x
	PUSHY
	lda tooth_tile_rows_lo,x
	PUSHY
	lda #$08
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	; main row 6
	inx
	lda #$08
	PUSHY
	lda tooth_tile_rows_hi,x
	PUSHY
	lda tooth_tile_rows_lo,x
	PUSHY
	lda #$08
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	; main row 7
	inx
	lda #$08
	PUSHY
	lda tooth_tile_rows_hi,x
	PUSHY
	lda tooth_tile_rows_lo,x
	PUSHY
	lda #$08
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
	PUSHY
.skip_black_out

.done
	lda #$00
	sta $100,y

	rts

