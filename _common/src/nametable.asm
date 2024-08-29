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


