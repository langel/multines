nametable_fill: subroutine
	; a = nametable high address
	; temp00 = fill tile
	; temp01 = fill attribute
	; requires render_disable status
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	sta PPU_CTRL
	tax
	lda temp00
.loop0
	sta PPU_DATA
	inx
	bne .loop0
.loop1
	sta PPU_DATA
	inx
	bne .loop1
.loop2
	sta PPU_DATA
	inx
	bne .loop2
.loop3
	sta PPU_DATA
	inx
	cpx #$c0
	bne .loop3
	; attributes here
	lda temp01
.attr_loop
	sta PPU_DATA
	inx
	bne .attr_loop
	rts


nametable_load: subroutine
	; a = nametable high address
	; temp00 = .nam lo address
	; temp01 = .nam hi address
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	sta PPU_CTRL
	tay
.loop0
	lda (temp00),y
	sta PPU_DATA
	iny
	bne .loop0
	inc temp01
.loop1
	lda (temp00),y
	sta PPU_DATA
	iny
	bne .loop1
	inc temp01
.loop2
	lda (temp00),y
	sta PPU_DATA
	iny
	bne .loop2
	inc temp01
.loop3
	lda (temp00),y
	sta PPU_DATA
	iny
	bne .loop3
	rts


pattern_to_nametable: subroutine
	; overwrites $01c0-$01cf for temp data storage
	; temp00 = pattern id
	; temp01 = pattern table
	; temp02 = .nam lo address
	; temp03 = .nam hi address
	; temp04 = color 0 tile
	; temp05 = color 1 tile
	; temp06 = color 2 tile
	; temp07 = color 3 tile

	; first, load data from ppu
	lda #$00
	sta $01c0 ; pattern lo addr
	sta $01c1 ; pattern hi addr
	lda temp00
	asl
	rol $01c1
	asl
	rol $01c1
	asl
	rol $01c1
	asl
	rol $01c1 ; hi ppu addr
	sta $01c0 ; lo ppu addr
	; check pattern table
	lda temp01
	beq .not_table2
	clc
	lda #$10
	adc $01c1
	sta $01c1
.not_table2
	; temp00-temp01 freed up now
	lda $01c1
	sta PPU_ADDR
	lda $01c0
	sta PPU_ADDR
	; buffer garbage read
	lda PPU_DATA
	ldx #$00
.load_pattern_data_loop
	lda PPU_DATA
	sta $01a0,x
	sta $01c0,x
	inx
	cpx #$10
	bne .load_pattern_data_loop

	; second, render tiles to nametable
	lda #$00
	sta temp01 ; counter
.tile_row_loop
	lda temp03
	sta PPU_ADDR
	lda temp02
	sta PPU_ADDR

	ldy #$08
.tile_pixel_loop
	lda #$00
	sta temp00
	ldx temp01
	asl $01c8,x
	rol temp00
	asl $01c0,x
	rol temp00
	ldx temp00
	lda temp04,x
	sta PPU_DATA
	dey
	bne .tile_pixel_loop

	clc
	lda temp02
	adc #$20
	sta temp02
	lda temp03
	adc #$00
	sta temp03
	inc temp01
	lda #$08
	cmp temp01
	bne .tile_row_loop


	rts



pattern_row_to_nametable: subroutine
	; overwrites $01d0-$01d2 for temp data storage
	; temp00 = pattern id
	; temp01 = packed control:
	;          bit0 = pattern table
	;          bits1-3 = pattern row (0-7)
	; temp02 = .nam lo address for destination row
	; temp03 = .nam hi address for destination row
	; temp04 = color 0 tile
	; temp05 = color 1 tile
	; temp06 = color 2 tile
	; temp07 = color 3 tile

	; unpack table + row bits
	lda temp01
	sta $01d0
	and #$01
	sta temp01
	lda $01d0
	lsr
	and #$07
	sta $01d1

	; load pattern row data from ppu
	lda #$00
	sta $01c0 ; pattern lo addr
	sta $01c1 ; pattern hi addr
	lda temp00
	asl
	rol $01c1
	asl
	rol $01c1
	asl
	rol $01c1
	asl
	rol $01c1 ; hi ppu addr
	sta $01c0 ; lo ppu addr
	; check pattern table
	lda temp01
	beq .not_table2
	clc
	lda #$10
	adc $01c1
	sta $01c1
.not_table2
	lda $01c1
	sta PPU_ADDR
	lda $01c0
	sta PPU_ADDR
	; buffer garbage read
	lda PPU_DATA
	ldx #$00
.load_pattern_data_loop
	lda PPU_DATA
	sta $01a0,x
	sta $01c0,x
	inx
	cpx #$10
	bne .load_pattern_data_loop

	; render one row of 8 pixels to nametable
	lda temp03
	sta PPU_ADDR
	lda temp02
	sta PPU_ADDR
	ldy #$08
	ldx $01d1
.tile_pixel_loop
	lda #$00
	sta $01d2
	asl $01c8,x
	rol $01d2
	asl $01c0,x
	rol $01d2
	lda $01d2
	tax
	lda temp04,x
	sta PPU_DATA
	ldx $01d1
	dey
	bne .tile_pixel_loop
	rts



metapattern_to_nametable_8x16: subroutine
	; overwrites $01d0-$01d1 for temp data storage
	; temp00 = pattern id
	; temp01 = pattern table
	; temp02 = .nam lo address
	; temp03 = .nam hi address
	; temp04 = color 0 tile
	; temp05 = color 1 tile
	; temp06 = color 2 tile
	; temp07 = color 3 tile

	; pattern 1
	lda temp00
	sta $01d0
	lda temp01
	sta $01d1
	jsr pattern_to_nametable
	; pattern 2
	lda $01d0
	clc
	adc #$02
	sta temp00
	lda $01d1
	sta temp01
	sec
	lda temp02
	sbc #$f8
	sta temp02
	lda temp03
	sbc #$00
	sta temp03
	jsr pattern_to_nametable
	; pattern 3
	lda $01d0
	clc
	adc #$01
	sta temp00
	lda $01d1
	sta temp01
	sec
	lda temp02
	sbc #$08
	sta temp02
	lda temp03
	sbc #$00
	sta temp03
	jsr pattern_to_nametable
	; pattern 3
	lda $01d0
	clc
	adc #$03
	sta temp00
	lda $01d1
	sta temp01
	sec
	lda temp02
	sbc #$f8
	sta temp02
	lda temp03
	sbc #$00
	sta temp03
	jsr pattern_to_nametable
	rts


