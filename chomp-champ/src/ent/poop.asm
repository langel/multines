

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

	lda #$10
	sta collision_0_w
	sta collision_0_h
	jsr game_ent_collision

	; damage
	lda ent_hp,x
	bpl .dont_despawn
	jsr ent_particle_spawn_from_baddie
	jmp ent_z_update_return
.dont_despawn
	lda ent_damaged
	beq .damage_done
	; shake if taking damage
	lda wtf
	lsr
	and #$03
	beq .damage_done
	cmp #$01
	beq .brush_shake_left
	cmp #$02
	beq .brush_shake_right
	jmp .damage_done
.brush_shake_left
	dec ent_pos_x
	jmp .damage_done
.brush_shake_right
	inc ent_pos_x
.damage_done

	lda ent_y,x
	clc
	adc #$10
	jsr ent_z_calc_sort_vals_9bit



ent_poop_render: subroutine
	ldy ent_spr_ptr

	lda #$7c
	sta temp00
	lda #$02
	sta temp01
	jsr ent_render_generic_8x16

	jmp ent_z_update_return

