

ent_template_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_template_id
	sta ent_type,x
.done
	rts

ent_template_update: subroutine
	; update logic
	; render (reload y?)
	rts
