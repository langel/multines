


ent_food_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_food_id
	sta ent_type,x
.done
	rts

ent_food_update: subroutine
	; update logic
	; render (reload y?)
	rts
