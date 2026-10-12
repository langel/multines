
road_3lanes_stripes:
	hex 10 0d 02 0a 1f 00
	hex 11 0e 02 0b 02 18
	hex 12 0f 02 0c 02 19
	hex 13 02 08 0d 02 1a
	hex 14 02 09 0e 02 1b
	hex 15 02 0a 0f 02 1c
	hex 16 02 0b 02 08 1d
	hex 17 02 0c 02 09 1e
road_3lanes_asphalt:
	hex 10 02 02 02 1f 00
	hex 11 02 02 02 02 18
	hex 12 02 02 02 02 19
	hex 13 02 02 02 02 1a
	hex 14 02 02 02 02 1b
	hex 15 02 02 02 02 1c
	hex 16 02 02 02 02 1d
	hex 17 02 02 02 02 1e

road_phase_offset_lut:
	hex 00 06 0c 12 18 1e 24 2a

game_road_prerender: subroutine

	; setup next nametable row

	; CALC PPU ADDR
	lda #$00
	sta temp01
	sec
	lda scroll_y
	sbc #$07
	php ; push status
	bcs .y_within_screen
	sbc #$10
.y_within_screen
	and #$f8
	sta temp00 
	cmp state01
	beq .sine_advance_done
	; main road sine
	inc state00
	; left road sine
	clc
	lda road_l_sine_lo
	adc #$63
	sta road_l_sine_lo
	lda road_l_sine_hi
	adc #$00
	sta road_l_sine_hi
	; bound y pos
	dec state02
	lda state02
	and #$1f
	sta state02
	; reset attr row?
	clc
	adc #$01
	and #$03
	bne .sine_advance_done
	ldx #$00
.attr_clear_loop
	sta attr_row_cache,x
	inx
	cpx #$08
	bne .attr_clear_loop
.sine_advance_done
	; calculate ppu_tile_ptr
	lda temp00
	sta state01
	asl
	rol temp01
	asl
	rol temp01
	sta temp00
	; addr hi
	lda scroll_y_hi
	and #$01
	asl
	plp ; pull status
	bcs .nm_off_screen
	eor #$02
.nm_off_screen
	sta temp02 ; target nametable parity
	shift_l 2
	clc
	adc #$20
	adc temp01
	sta ppu_tile_ptr_hi
	lda temp00
	sta ppu_tile_ptr_lo

	; calculate ppu_attr_ptr
	; tile_ptr $%
	lda ppu_tile_ptr_hi
	and #$28
	clc
	adc #$03
	sta ppu_attr_ptr_hi
	lda ppu_tile_ptr_hi
	and #$03
	sta temp06
	lda ppu_tile_ptr_lo
	sta temp07
	ldx #$04
.attr_ptr_loop
	lsr temp06
	ror temp07
	dex
	bne .attr_ptr_loop
	lda temp07
	and #$f8
	clc
	adc #$c0
	sta ppu_attr_ptr_lo

	; CALC ROAD POS
	ldx state00
	lda sine_table,x
	shift_r 1
	sta temp03 ; store offset
	; fine x
	and #$07
	sta temp05
	; coarse x
	lda temp03 ; x offset
	shift_r 3
	clc
	adc #$06   ; lowest coarse x pos
	sta temp00
	; store x offset of tile row
	ldy state02
	shift_l 3
	clc
	adc temp05
	sta road_r_x
	sta road_r_x_offset,y


	; PREPLOT TILES

	; fill row with dirt
	lda #$00
	ldx #$1f
.dirt_pre_loop
	sta tile_row_cache,x
	sta tree_row_cache,x
	dex
	bpl .dirt_pre_loop

	; main road tiles
	ldx temp00
	lda state01
	shift_r 3
	clc
	adc temp02
	and #$03
	beq .plot_stripes
.plot_asphalt
	; src_ptr = asphalt_lut[phase_offset]
	ldx temp05
	lda road_phase_offset_lut,x
	clc
	adc #<road_3lanes_asphalt
	sta temp06
	lda #>road_3lanes_asphalt
	adc #$00
	sta temp07
	ldx temp00
	ldy #$00
.plot_asphalt_loop
	; guard: cache_x 00..1f
	txa
	bmi .plot_asphalt_skip_write
	cpx #$20
	bcs .plot_asphalt_skip_write
	lda (temp06),y
	sta tile_row_cache,x
.plot_asphalt_skip_write
	inx
	iny
	cpy #$06
	bne .plot_asphalt_loop
	jmp .plot_row_done
.plot_stripes
	; src_ptr = stripes_lut[phase_offset]
	ldx temp05
	lda road_phase_offset_lut,x
	clc
	adc #<road_3lanes_stripes
	sta temp06
	lda #>road_3lanes_stripes
	adc #$00
	sta temp07
	ldx temp00
	ldy #$00
.plot_stripes_loop
	; guard: cache_x 00..1f
	txa
	bmi .plot_stripes_skip_write
	cpx #$20
	bcs .plot_stripes_skip_write
	lda (temp06),y
	sta tile_row_cache,x
.plot_stripes_skip_write
	inx
	iny
	cpy #$06
	bne .plot_stripes_loop
.plot_row_done


/*
	; left road tiles
	; left sine offset from right
	ldx road_l_sine_hi
	lda sine_table,x
	shift_r 3
	clc
	adc #$30 ; 6 tiles wide
	sta temp07 ; fine offset from main
	ldy state02
	lda road_r_x_offset,y
	sec
	sbc temp07
	shift_r 3
	tax
	; adjust x and y to be onscreen
	ldy #$00
*/
	
	; left road tiles
	; left_road fine_x/coarse_x
	ldx road_l_sine_hi
	lda sine_table,x
	shift_r 3
	clc
	adc #$30
	sta temp06 ; pixel offset from right road
	and #$07
	sta temp07 ; fine portion of left offset
	lda temp06
	shift_r 3
	sta temp06 ; coarse portion of left offset
	lda temp05
	sec
	sbc temp07
	pha
	lda temp00
	sbc temp06
	tax
	pla
	and #$07
	sta temp03 ; left road fine x
	ldy state02
	txa
	shift_l 3
	clc
	adc temp03
	sta road_l_x
	sta road_l_x_offset,y
	; seg_src starts at y=0
	ldy #$00
	lda state01
	shift_r 3
	clc
	adc temp02
	and #$03
	beq .plot_l_stripes
.plot_l_asphalt
	; src_ptr = asphalt_lut[left_phase]
	stx temp04
	ldx temp03
	lda road_phase_offset_lut,x
	clc
	adc #<road_3lanes_asphalt
	sta temp06
	lda #>road_3lanes_asphalt
	adc #$00
	sta temp07
	ldx temp04
	ldy #$00
.plot_l_asphalt_loop
	; guard: cache_x 00..1f
	txa
	bmi .plot_l_asphalt_skip_write
	cpx #$20
	bcs .plot_l_asphalt_skip_write
	lda (temp06),y
	sta tile_row_cache,x
.plot_l_asphalt_skip_write
	inx
	iny
	cpy #$06
	bne .plot_l_asphalt_loop
	jmp .plot_l_row_done
.plot_l_stripes
	; src_ptr = stripes_lut[left_phase]
	stx temp04
	ldx temp03
	lda road_phase_offset_lut,x
	clc
	adc #<road_3lanes_stripes
	sta temp06
	lda #>road_3lanes_stripes
	adc #$00
	sta temp07
	ldx temp04
	ldy #$00
.plot_l_stripes_loop
	; guard: cache_x 00..1f
	txa
	bmi .plot_l_stripes_skip_write
	cpx #$20
	bcs .plot_l_stripes_skip_write
	lda (temp06),y
	sta tile_row_cache,x
.plot_l_stripes_skip_write
	inx
	iny
	cpy #$06
	bne .plot_l_stripes_loop
.plot_l_row_done
	

	/*
	; tiny left road
	lda #$02
	sta tile_row_cache+3
	sta tile_row_cache+4
*/


; trees ?
	ldx #$00
.tree_loop
	; check target
	lda tile_row_cache,x
	bne .tree_put_done
	; check left of target
	cpx #$00
	beq .tree_left_check_done
	lda tile_row_cache-1,x
	bne .tree_put_done
.tree_left_check_done
	; check right of target
	cpx #$1f
	beq .tree_right_check_done
	lda tile_row_cache+1,x
	bne .tree_put_done
.tree_right_check_done
	lda #$46
	sta temp00
	lda state02
	and #$01
	shift_l 4
	ora temp00
	sta temp00
	txa
	and #$01
	ora temp00
	sta tree_row_cache,x
	txa
	lsr
	and #$01
	bne .right_side
.left_side
	lda #$33
	jmp .side_set
.right_side
	lda #$cc
.side_set
	sta temp02
	txa
	shift_r 2
	tay
	lda attr_row_cache,y
	ora temp02
	sta attr_row_cache,y
.tree_put_done
	inx
	cpx #$20
	bne .tree_loop

	
/*
	lda road_x
	shift_r 3
	sec
	sbc #$02
	sta temp00
	ldx #$00
.tree_loop
	; check trees not on road
	cpx temp00
	bcc .draw_tree_pattern
	lda temp00
	clc
	adc #$09
	sta temp01
	cpx temp01
	bcs .draw_tree_pattern
	jmp .tree_pattern_done
.draw_tree_pattern
	lda state02
	and #$01
	bne .butt_pattern
.top_pattern
	; plot_top pattern
	lda #$64
	sta tile_row_cache+0,x
	lda #$65
	sta tile_row_cache+1,x
	jmp .tree_pattern_attr
.butt_pattern
	; plot bottom pattern
	lda #$74
	sta tile_row_cache+0,x
	lda #$75
	sta tile_row_cache+1,x
.tree_pattern_attr
	txa
	lsr
	and #$01
	bne .right_side
.left_side
	lda #$33
	jmp .side_set
.right_side
	lda #$cc
.side_set
	sta temp02
	txa
	shift_r 2
	tay
	lda attr_row_cache,y
	ora temp02
	sta attr_row_cache,y
.tree_pattern_done
	inx
	inx
	cpx #$20
	bne .tree_loop
*/
	
/*
	; TREES!!
	lda state00
	and #$03
	cmp #$02
	beq .3rd_row
	cmp #$01
	beq .2nd_row
	cmp #$00
	beq .1st_row
	jmp .tree_done
.1st_row
	lda #$70
	sta $7e2
	lda #$71
	sta $7e3
	jmp .tree_done
.2nd_row
	lda #$60
	sta $7e2
	lda #$61
	sta $7e3
	jmp .tree_done
.3rd_row
	lda #$50
	sta $7e2
	lda #$51
	sta $7e3
.tree_done
*/
	; combine road and tree tiles
	lda #$00
	ldx #$1f
.row_amalgamate_loop
	lda tile_row_cache,x
	ora tree_row_cache,x
	sta tile_row_cache,x
	dex
	bpl .row_amalgamate_loop

	rts




game_road_render: subroutine

	; transfer tiles
	lda ppu_tile_ptr_hi
	sta PPU_ADDR
	lda ppu_tile_ptr_lo
	sta PPU_ADDR
	ldx #$00
.plot_loop
	lda tile_row_cache,x
	sta PPU_DATA
	inx
	cpx #$20
	bne .plot_loop

	; transfer attributes
	lda ppu_attr_ptr_hi
	sta PPU_ADDR
	lda ppu_attr_ptr_lo
	sta PPU_ADDR
	ldx #$00
.attr_loop
	lda attr_row_cache,x
	sta PPU_DATA
	inx
	cpx #$08
	bne .attr_loop

	rts
