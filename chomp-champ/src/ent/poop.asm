

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
	lda ent_y,x
	sta ent_y,y
	lda ent_y_lo,x
	sta ent_y_lo,y
	; hp
	lda #$10
	sta ent_hp,y
	; poop causes dirt
	ldy #$05
	jsr ent_sully_cell
.done
	rts


ent_poop_update: subroutine
	; update logic
	jsr ent_calc_position
	lda ent_visible
	sta ent_coll_visible,x
	lda collision_0_x
	sta ent_coll_x,x
	lda collision_0_y
	sta ent_coll_y,x

	; check player collision
	lda player_is_dead
	bne .player_collision_done
	lda player_iframes
	bne .player_collision_done
	clc
	lda collision_0_x
	adc collision_0_w
	cmp player_hit_x
	bcc .player_collision_done
	clc
	lda collision_0_x
	cmp player_hit_x
	bcs .player_collision_done
	clc
	lda collision_0_y
	adc collision_0_h
	cmp player_hit_y
	bcc .player_collision_done
	clc
	lda collision_0_y
	cmp player_hit_y
	bcs .player_collision_done
.player_collides
	lda #player_death_timer
	sta player_is_dead
	lda #$04
	sta ent_r0
.player_collision_done

	; check brush collision
	lda controller1
	and #BRUSH_BUTTON
	beq .brushing_done
	clc
	lda collision_0_x
	adc collision_0_w
	cmp brush_hit_x
	bcc .brushing_done
	clc
	lda collision_0_x
	cmp brush_hit_x
	bcs .brushing_done
	clc
	lda collision_0_y
	adc collision_0_h
	cmp brush_hit_y
	bcc .brushing_done
	clc
	lda collision_0_y
	cmp brush_hit_y
	bcs .brushing_done
.brush_collision
	lda wtf
	lsr
	and #$03
	beq .brushing_done
	cmp #$01
	beq .brush_shake_left
	cmp #$02
	beq .brush_shake_right
	jmp .shake_done
.brush_shake_left
	dec ent_pos_x
	jmp .shake_done
.brush_shake_right
	inc ent_pos_x
.shake_done
	dec ent_hp,x
	lda ent_hp,x
	bpl .brushing_done
	jsr ent_particle_spawn_from_baddie
.brushing_done

	lda ent_y,x
	clc
	adc #$10
	ent_z_calc_sort_vals_9bit



ent_poop_render: subroutine
	ldy ent_spr_ptr

	lda #$7c
	sta temp00
	lda #$02
	sta temp01
	jsr ent_render_generic_8x16

	jmp ent_z_update_return

