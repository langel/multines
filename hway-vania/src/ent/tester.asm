
ent_tester_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_tester_id
	sta ent_type,x
	lda #$40
	sta ent_x,x
	lda #$c0
	sta ent_y,x
.done
	rts


ent_tester_update: subroutine
	; class under the sprite center
	lda ent_y,x
	clc
	adc #$04
	tay
	lda ent_x,x
	clc
	adc #$04
	jsr road_class_lookup_screen
	clc
	adc #$f0
	ldy ent_spr_ptr
	sta spr_p,y
	lda #$00
	sta spr_a,y
	ldx ent_slot
	lda ent_x,x
	sta spr_x,y
	lda ent_y,x
	sta spr_y,y
	inc_y 4
	rts
