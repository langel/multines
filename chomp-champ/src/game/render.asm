
state_game_render: subroutine

	ldx tooth_update_queue_size
	bne .queue_loop
	jmp .done
.queue_loop
	; precalc the 4 tiles
	lda tooth_needs_update,x
	tay
	lda tooth_cell_dmg,y
	sta temp01
	tya
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
	jmp .edge_check_done
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
	dex
	bpl .do_loop
	; loop done
	ldx #$00
	stx tooth_update_queue_size
	jmp .done
.do_loop
	jmp .queue_loop

.done
	jmp nmi_render_done
