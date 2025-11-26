



ent_germ_spawn: subroutine
	jsr ent_find_slot
	lda #ent_germ_id
	bmi .done
	sta ent_type,x
.done
	jsr rng_update
	lda rng_val0
	sta ent_x,x
	lda rng_val1
	sta ent_y,x
	rts

ent_germ_update: subroutine

	; update animation frame
	inc ent_r0,x
	lda ent_r0,x
	cmp #$0b
	bne .not_next_frame
	lda #$00
	sta ent_r0,x
	inc ent_r1,x
	lda ent_r1,x
	and #$01
	sta ent_r1,x
.not_next_frame

	; RENDER
	; pattern
	lda ent_r1,x
	asl
	clc
	adc #$60
	sta spr_p,y
	adc #$01
	sta spr_p+4,y
	adc #$0f
	sta spr_p+8,y
	adc #$01
	sta spr_p+12,y
	; attr
	lda #$01
	sta spr_a,y
	sta spr_a+4,y
	sta spr_a+8,y
	sta spr_a+12,y
	; x
	lda ent_x,x
	sta spr_x,y
	sta spr_x+8,y
	clc
	adc #$08
	sta spr_x+4,y
	sta spr_x+12,y
	; y
	lda ent_y,x
	sta spr_y,y
	sta spr_y+4,y
	clc
	adc #$08
	sta spr_y+8,y
	sta spr_y+12,y
	
	inc_y 16

	rts
