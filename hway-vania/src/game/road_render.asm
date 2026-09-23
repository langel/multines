

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
.sine_advance_done
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
	sta ppu_ptr_hi
	lda temp00
	sta ppu_ptr_lo

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
	sta $700,y


	; PREPLOT TILES

	; fill row with dirt
	lda #$00
	ldx #$20
.dirt_pre_loop
	sta $7e0,x
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
	sta $7e0,x
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
	sta $7e0,x
	inx
	iny
	cpy #$06
	bne .plot_stripes_loop
.plot_row_done
	
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

	rts




game_road_render: subroutine

	; transfer tiles
	lda ppu_ptr_hi
	sta PPU_ADDR
	lda ppu_ptr_lo
	sta PPU_ADDR
	ldx #$00
.plot_loop
	lda #$7e0,x
	sta PPU_DATA
	inx
	cpx #$20
	bne .plot_loop

	; XXX
	; transfer attributes

	rts
