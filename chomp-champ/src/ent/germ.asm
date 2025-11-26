



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
	; update logic
	; render (reload y?)

	rts
