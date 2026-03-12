


ent_eggs_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_eggs_id
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



ent_eggs_update: subroutine
	; update logic

	jmp ent_z_update_return


ent_eggs_render: subroutine
	; render (reload y?)
	jsr ent_calc_position
	lda #$7c
	sta temp00
	lda #$02
	sta temp01
	jsr ent_render_generic_8x16

	jmp ent_z_render_return

