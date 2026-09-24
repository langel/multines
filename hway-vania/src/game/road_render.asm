

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
	inc state00
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
	shift_l 4
	sta temp04
	; coarse x
	lda temp03
	shift_r 3
	clc
	adc #$04
	sta temp00
	; store x offset of tile row
	ldy state02
	shift_l 3
	clc
	adc temp05
	sta road_x
	sta road_row_x_offset,y


	; PREPLOT TILES

	; fill row with dirt
	lda #$00
	ldx #$1f
.dirt_pre_loop
	sta tile_row_cache,x
	dex
	bpl .dirt_pre_loop

	; road render with target parity
	ldx temp00
	lda state01
	shift_r 3
	clc
	adc temp02
	and #$03
	beq .plot_stripes
.plot_asphalt
	ldy #$00
.plot_asphalt_loop
	lda road_row_asphalt,y
	clc
	adc temp04
	sta tile_row_cache,x
	inx
	iny
	cpy #$06
	bne .plot_asphalt_loop
	jmp .plot_row_done
.plot_stripes
	ldy #$00
.plot_stripes_loop
	lda road_row_stripes,y
	clc
	adc temp04
	sta tile_row_cache,x
	inx
	iny
	cpy #$06
	bne .plot_stripes_loop
.plot_row_done


; trees ?
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
