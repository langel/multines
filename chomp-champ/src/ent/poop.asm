

ent_poop_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_poop_id
	sta ent_type,x
	;position
	lda #$a0
	sta ent_x,x
	lda #$00
	sta ent_x_hi,x
	lda #$60
	sta ent_y,x
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

	jmp ent_z_update_return


ent_poop_render: subroutine
	; render (reload y?)
	jsr ent_calc_position
	lda #$7c
	sta temp00
	lda #$02
	sta temp01
	jsr ent_render_generic_8x16

	jmp ent_z_render_return

