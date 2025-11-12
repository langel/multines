
ent_dingle_update: subroutine

	inc $80
	clc
	lda ent_yp_lo,x
	adc ent_yv_lo,x
	sta ent_yp_lo,x
	lda ent_yp_hi,x
	adc ent_yv_hi,x
	sta ent_yp_hi,x
	cmp #240
	bcc .dont_reset
	jsr rng_update
	lda rng_val0
	and #$03
	clc
	adc #$01
	sta ent_yv_hi,x
	lda rng_val1
	sta ent_yv_lo,x
	lda #$00
	sta ent_yp_hi,x
.dont_reset

	; sprite
	txa
	shift_l 2
	tay
	lda ent_xp_hi,x
	sta spr_x,y
	lda ent_yp_hi,x
	sta spr_y,y
	lda #$02
	sta spr_p,y


	rts

