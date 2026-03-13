


ent_eggs_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_eggs_id
	sta ent_type,x
	;position
	lda #$f5
	sta ent_x,x
	lda #$01
	sta ent_x_hi,x
	lda #$a0
	sta ent_y,x
.done
	rts



ent_eggs_update: subroutine
	; update logic

	jmp ent_z_update_return


ent_eggs_render: subroutine
	; render (reload y?)
	jsr ent_calc_position

.left_sprite
	lda ent_visible
	and #$01
	beq .right_sprite
	lda #$30
	sta spr_p,y
	lda #$02
	sta spr_a,y
	lda collision_0_x
	sta spr_x,y
	lda collision_0_y
	sta spr_y,y
	inc_y 4
.right_sprite
	lda ent_visible
	and #$02
	beq .sprites_done
	lda #$30
	sta spr_p,y
	lda #$42
	sta spr_a,y
	lda collision_0_x
	clc
	adc #$08
	sta spr_x,y
	lda collision_0_y
	sta spr_y,y
	inc_y 4
.sprites_done

	jmp ent_z_render_return

