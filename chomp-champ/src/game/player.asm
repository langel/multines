
player_init: subroutine
	rts


player_update: subroutine

	; render
	ldy ent_spr_ptr
	; pattern
	lda wtf
	shift_r 3
	and #$01
	asl
	clc
	adc #$c0
	sta spr_p,y
	adc #$01
	sta spr_p+4,y
	adc #$0f
	sta spr_p+8,y
	adc #$01
	sta spr_p+12,y
	adc #$0f
	sta spr_p+16,y
	adc #$01
	sta spr_p+20,y
	adc #$0f
	sta spr_p+24,y
	adc #$01
	sta spr_p+28,y
	; attr
	lda #$00
	sta spr_a,y
	sta spr_a+4,y
	sta spr_a+8,y
	sta spr_a+12,y
	sta spr_a+16,y
	sta spr_a+20,y
	sta spr_a+24,y
	sta spr_a+28,y
	; x
	lda #$80-8
	sta spr_x,y
	sta spr_x+8,y
	sta spr_x+16,y
	sta spr_x+24,y
	clc
	adc #$08
	sta spr_x+4,y
	sta spr_x+12,y
	sta spr_x+20,y
	sta spr_x+28,y
	; y
	lda #$90
	sta spr_y,y
	sta spr_y+4,y
	clc
	adc #$08
	sta spr_y+8,y
	sta spr_y+12,y
	adc #$08
	sta spr_y+16,y
	sta spr_y+20,y
	adc #$08
	sta spr_y+24,y
	sta spr_y+28,y

	rts
