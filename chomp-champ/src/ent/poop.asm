

ent_poop_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_poop_id
	sta ent_type,x
.done
	rts

ent_poop_from_germ: subroutine
	jsr ent_find_slot
	bmi .done
	txa
	tay
	lda #ent_poop_id
	sta ent_type,y
	ldx ent_slot
	lda ent_x_hi,x
	sta ent_x_hi,y
	lda ent_x,x
	sta ent_x,y
	lda ent_x_lo,x
	sta ent_x_lo,y
	lda ent_y_hi,x
	sta ent_y_hi,y
	lda ent_y,x
	sta ent_y,y
	lda ent_y_lo,x
	sta ent_y_lo,y
.done
	ldx ent_slot
	ldy ent_spr_ptr
	rts

ent_poop_update: subroutine
	; update logic
	; render (reload y?)
	rts
