
sprites_clear: subroutine
	lda #$ff
	ldx #$00
.sprite_clear
	sta $0200,x
	inx
	bne .sprite_clear
	rts

sprite_4_render: subroutine
	; temp00 upperleft pattern id
	; temp01 attribute value
	; temp02 x origin
	; temp03 y origin
	; y = ent_spr_ptr
	lda temp01
	shift_r 6
	tax
	; sprite 0
	clc
	lda temp02
	adc sprite_4_x_offsets_left,x
	sta spr_x,y
	clc
	lda temp02
	adc sprite_4_y_offsets_top,x
	sta spr_y,y
	lda temp00
	sta spr_p,y
	lda temp01
	sta spr_a,y
	inc_y 4
	; sprite 1
	clc
	lda temp02
	adc sprite_4_x_offsets_right,x
	sta spr_x,y
	clc
	lda temp02
	adc sprite_4_y_offsets_top,x
	sta spr_y,y
	clc
	lda temp00
	adc #$01
	sta spr_p,y
	lda temp01
	sta spr_a,y
	inc_y 4
	; sprite 2
	clc
	lda temp02
	adc sprite_4_x_offsets_left,x
	sta spr_x,y
	clc
	lda temp02
	adc sprite_4_y_offsets_bottom,x
	sta spr_y,y
	clc
	lda temp00
	adc #$10
	sta spr_p,y
	lda temp01
	sta spr_a,y
	inc_y 4
	; sprite 3
	clc
	lda temp02
	adc sprite_4_x_offsets_right,x
	sta spr_x,y
	clc
	lda temp02
	adc sprite_4_y_offsets_bottom,x
	sta spr_y,y
	clc
	lda temp00
	adc #$11
	sta spr_p,y
	lda temp01
	sta spr_a,y
	inc_y 4
	rts

sprite_4_x_offsets_left:
	hex 00 08 00 08
sprite_4_x_offsets_right:
	hex 08 00 08 00
sprite_4_y_offsets_top:
	hex 00 00 08 08
sprite_4_y_offsets_bottom:
	hex 08 08 00 00
