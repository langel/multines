

ent__template_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent__template_id
	sta ent_type,x
.done
	rts

ent__template_update: subroutine
	; update logic
	; render (reload y?)
	rts
