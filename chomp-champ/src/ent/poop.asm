

ent_poop_spawn: subroutine
	jsr ent_find_slot
	lda #ent_poop_id
	bmi .done
	sta ent_type,x
.done
	rts

ent_poop_update: subroutine
	; update logic
	; render (reload y?)
	rts
