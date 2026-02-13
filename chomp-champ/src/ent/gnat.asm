
ent_gnat_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_gnat_id
	sta ent_type,x
	; set direction
	lda rng_val0
	and #$03
	sta ent_r3,x
	; set top dog layer
	lda #$ff
	sta ent_r6,x
	sta ent_r7,x
.done
	rts

ent_gnat_update: subroutine

	inc ent_x,x
	bne .not_next_screen
	inc ent_x_hi,x
	lda ent_x_hi,x
	and #$01
	sta ent_x_hi,x
.not_next_screen
	ldy wtf
	lda sine_table,y
	shift_r 6
	clc
	adc #$40
	sta ent_y,x
	
	jmp ent_z_update_return



ent_gnat_render: subroutine
	; RENDER
	jsr ent_calc_position
	; metasprite
	lda wtf
	lsr
	and #$01
	asl
	asl
	clc
	adc #$98
	sta temp00
	; attr
	lda #$03
	sta temp01
	jsr ent_render_generic_8x16

	jmp ent_z_render_return

