
big_teef_sprites:
	; upper mandible
	hex 0b 0c 0d 0d 0e 0f
	hex 1b 1c 1d 1d 1e 1f
	; lower mandible
	hex 2b 2c 2d 2d 2e 2f
	hex 3b 3c 3d 3d 3e 3f
	; connective tissue
	hex 0a 1a

big_teef_attrs:
	; upper mandible
	hex 00 00 00 40 00 00
	hex 00 00 00 40 00 00
	; lower mandible
	hex 00 00 40 00 00 00
	hex 00 00 40 00 00 00
	; connective tissue
	hex 00 00


ent_big_teef_spawn: subroutine
	jsr ent_find_slot
	lda #ent_big_teef_id
	bmi .done
	sta ent_type,x
.done
	rts

ent_big_teef_update: subroutine

	inc $3e0

	; big teef
	lda #$16
	sta palette_cache+13
	lda #$14
	sta palette_cache+14
	lda #$27
	sta palette_cache+15


	ldx #$00
	ldy #$00
.big_teef_sprites_attrs
	lda big_teef_sprites,x
	sta spr_p,y
	lda big_teef_attrs,x
	sta spr_a,y
	INC_Y 4
	inx
	cpx #26
	bne .big_teef_sprites_attrs

	; upper mandible
	; x pos
	ldy #$00
	clc
	lda state02 ; x origin
.big_teef_uppers_x
	sta spr_x,y
	sta spr_x+24,y
	adc #$08
	INC_Y 4
	cpy #24
	bne .big_teef_uppers_x
	; y pos
	clc
	lda state03 ; y origin
	sta spr_y
	sta spr_y+4
	sta spr_y+8
	sta spr_y+12
	sta spr_y+16
	sta spr_y+20
	adc #$08
	sta spr_y+24
	sta spr_y+28
	sta spr_y+32
	sta spr_y+36
	sta spr_y+40
	sta spr_y+44

	; lower mandible
	ldy #48
	; x pos
	clc
	lda state02 ; x origin
.big_teef_lowers_x
	sta spr_x,y
	sta spr_x+24,y
	adc #$08
	INC_Y 4
	cpy #72
	bne .big_teef_lowers_x
	; y pos
	ldy #48
	clc
	ldx state04
	lda sine_table,x
	SHIFT_R 5
	adc state03 ; y origin
	adc #$08
	sta spr_y,y
	sta spr_y+4,y
	sta spr_y+8,y
	sta spr_y+12,y
	sta spr_y+16,y
	sta spr_y+20,y
	adc #$08
	sta spr_y+24,y
	sta spr_y+28,y
	sta spr_y+32,y
	sta spr_y+36,y
	sta spr_y+40,y
	sta spr_y+44,y

	; connective tissue
	ldy #96
	; x pos
	lda state02
	sta spr_x,y
	sta spr_x+4,y
	; y pos
	ldx state04
	lda sine_table,x
	SHIFT_R 6
	adc #$04
	adc state03
	sta spr_y,y
	clc
	adc #$08
	sta spr_y+4,y

	; forward the animation counter
	inc state02
	lda state04
	tax
	lda sine_table,x
	shift_r 5
	clc
	adc #$a0
	sta state03
	inc state04
	inc state04
	inc state04
	rts
