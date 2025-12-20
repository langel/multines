
gumline_nm_addr_lo:
	hex e0 e8 f0 f8
	hex e0 e8 f0 f8
	hex 00 08 10 18
	hex 00 08 10 18
gumline_nm_addr_hi:
	hex 20 20 20 20
	hex 24 24 24 24
	hex 23 23 23 23
	hex 27 27 27 27
gumline_top_row_tile_id:
	hex 18 28 38 48
gumline_bottom_row_tile_id:
	hex 80 88 90 98

state_game_render: subroutine

	ldx tooth_update_queue_size
	bne .queue_loop
	jmp .tooth_cells_done
.queue_loop
	dex
	; precalc the 4 tiles
	lda tooth_needs_update,x
	tay
	lda tooth_cell_dmg,y
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
	; top row of cell
	lda tooth_needs_update,x
	tay
	lda tooth_cell2nm_hi,y
	sta PPU_ADDR
	lda tooth_cell2nm_lo,y
	sta PPU_ADDR
	lda tooth_tile_cache+0
	sta PPU_DATA
	lda tooth_tile_cache+1
	sta PPU_DATA
	; bottom row of cell
	lda tooth_needs_update,x
	tay
	lda tooth_cell2nm_hi,y
	sta PPU_ADDR
	lda tooth_cell2nm_lo,y
	clc
	adc #$20
	sta PPU_ADDR
	lda tooth_tile_cache+2
	sta PPU_DATA
	lda tooth_tile_cache+3
	sta PPU_DATA
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


	; update gumline tiles
	lda wtf
	and #$0f
	sta temp00
	tax
	lda tooth_total_dmg,x
	shift_r 5
	cmp #$03
	bcc .dont_threshold
	lda #$03
.dont_threshold
	sta temp01 ; tile dmg group value
	ldx temp00
	lda gumline_nm_addr_hi,x
	sta PPU_ADDR
	lda gumline_nm_addr_lo,x
	sta PPU_ADDR
	; which row?
	lda temp00
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
.gumline_done


	; lets dick around with attributes
	lda wtf
	shift_r 4
	and #$03
	sta temp00
	shift_l 2
	ora temp00
	shift_l 2
	ora temp00
	shift_l 2
	ora temp00
	tay
	ldx #$08
	lda tooth_attr_hi,x
	sta PPU_ADDR
	lda tooth_root_attr_lo,x
	sta PPU_ADDR
	sty PPU_DATA
	sty PPU_DATA
	lda tooth_attr_hi,x
	sta PPU_ADDR
	lda tooth_main_attr_top_lo,x
	sta PPU_ADDR
	sty PPU_DATA
	sty PPU_DATA
	lda tooth_attr_hi,x
	sta PPU_ADDR
	lda tooth_main_attr_bottom_lo,x
	sta PPU_ADDR
	sty PPU_DATA
	sty PPU_DATA


.done
	jmp nmi_render_done
