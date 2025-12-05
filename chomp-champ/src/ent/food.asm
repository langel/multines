
; food behaviors

; static position
; can be behind/between teeth
; has hp against brush/floss
; falls downwards on death
; germs can eat it too

; ent_r0 is subtype
; ent_r6 z pos sort up
; ent_r7 z pos sort down

ent_food_sprite:
	hex 00 04 08 0c
	hex 20 24 28 2c

ent_food_attr:
	hex 02 01 01 00
	hex 00 03 02 03


ent_food_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_food_id
	sta ent_type,x
	jsr ent_random_spawn_pos
	; set subtype
	txa
	and #$07
	sta ent_r0,x
.done
	rts


ent_food_update: subroutine
	; update logic

	; set z position
	lda ent_y,x
	clc
	adc #$10
	ent_z_calc_sort_vals
	
	jmp ent_z_update_return


ent_food_render: subroutine
	; RENDER
	jsr ent_calc_position
	lda ent_r0,x
	tay
	lda ent_food_sprite,y
	sta temp00
	lda ent_food_attr,y
	sta temp01
	ldy ent_spr_ptr
	jsr ent_render_generic_8x16

	jmp ent_z_render_return
