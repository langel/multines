


ent_car_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_car_id
	sta ent_type,x
.done
	lda #$7e
	sta ent_x,x
	lda #$80
	sta ent_y,x
	rts

ent_car_update: subroutine
	; update logic
	; render (reload y?)

	lda #$00
	sta spr_p,y
	lda #$10
	sta spr_p+4,y
	lda #$01
	sta spr_a,y
	sta spr_a+4,y
	lda ent_x,x
	sta spr_x,y
	sta spr_x+4,y
	lda ent_y,x
	sta spr_y,y
	clc
	adc #$08
	sta spr_y+4,y

	inc_y 8

	rts
