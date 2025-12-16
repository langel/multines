nmi_handler: subroutine
	lda nmi_lockout
	beq no_lock
	jmp nmi_end
no_lock
	inc nmi_lockout
	; ~2250 cycles for PPU access
	; (PAL is 7450 cycles)
	; NTSC ~= 160 bytes of PPU writes
	inc wtf
	lda #$02
	; OAM DMA         513 cycles
	sta $4014
	; PALETTE         236 cycles??
	PPU_ADDR_SET $3f00
	ldx #0
	ldy #8
palette_loop
	lda palette_cache
	sta PPU_DATA
	inx
	lda palette_cache,x
	sta PPU_DATA
	inx
	lda palette_cache,x
	sta PPU_DATA
	inx
	lda palette_cache,x
	sta PPU_DATA
	dey
	bne palette_loop
	; STATE RENDER     ?? cycles
	jmp (state_render_lo)
nmi_render_done
	; SCROLL POS	    17 cycles
	bit PPU_STATUS
	lda scroll_x
	sta PPU_SCROLL
	lda scroll_y
	sta PPU_SCROLL
	; hope everything above was under
	; ~2250 cycles!
	jmp (state_update_lo)
nmi_update_done
	dec nmi_lockout
nmi_end
	rti


