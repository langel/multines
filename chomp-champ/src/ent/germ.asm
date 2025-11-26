



ent_germ_spawn: subroutine
	jsr ent_find_slot
	lda #ent_germ_id
	bmi .done
	sta ent_type,x
.done
	rts

ent_germ_update: subroutine
	; update logic
	; render (reload y?)
	rts
