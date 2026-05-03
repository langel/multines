
sprites_clear: subroutine
	lda #$ff
	ldx #$00
.sprite_clear
	sta $0200,x
	inx
	bne .sprite_clear
	rts


sprite0_wait: subroutine
	rts
