

ent__template_spawn: subroutine
	jsr ent_find_slot
	lda #ent__template_id
	bmi .done
	sta ent_type,x
.done
	rts

ent__template_update: subroutine
	; update logic
	; render (reload y?)
	rts
