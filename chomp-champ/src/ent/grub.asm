
; ent_r0 dirt counter
; ent_r1 frame wait length
; ent_r2 distance counter
; ent_r3 direction
;        0 right
;        1 left
;        2 up
;        3 down
; ent_r4 animation frame
; ent_r5 animation counter

grub_dir_sprite:
	hex dc fc dc fc bc be bc be
grub_dir_attr:
	hex 02 02 42 42 02 02 82 82

grub_hp                   eqm #$20
grub_default_wait_length  eqm #$07
grub_attacked_wait_length eqm #$01


ent_grub_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_grub_id
	sta ent_type,x
	;position
	lda #$88
	sta ent_x,x
	lda #$00
	sta ent_x_hi,x
	lda #$50
	sta ent_y,x

	lda #grub_hp
	sta ent_hp,x
	lda #$03
	sta ent_r3,x
	lda #grub_default_wait_length
	sta ent_r1,x
.done
	rts


ent_grub_spawn_from_egg: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_grub_id
	sta ent_type,x

	lda #grub_hp
	sta ent_hp,x

	jsr rng_update
	; distance to next turn
	lda rng_val0
	and #$1f
	sta ent_r2,x
	; starting direction
	lda rng_val1
	and #$03
	sta ent_r3,x
	; copy position
	ldy ent_slot
	lda ent_x,y
	clc
	adc #$04
	sta ent_x,x
	lda ent_x_hi,y
	adc #$00
	sta ent_x_hi,x
	lda ent_y,y
	sta ent_y,x

	lda #grub_attacked_wait_length
	sta ent_r1,x

	lda #$00
	sta ent_r4,x
	sta ent_r5,x
.done
	ldx ent_slot
	rts


ent_grub_update: subroutine
	; update logic

	inc ent_r5,x
	lda ent_r5,x
	cmp ent_r1,x
	beq .update_grub
	jmp .frame_done

.update_grub

	lda ent_r1,x
	cmp #grub_default_wait_length
	beq .speed_done
	jsr rng_update
	lda rng_val0
	cmp #$40
	bcs .speed_done
	inc ent_r1,x
.speed_done

	inc ent_r4,x
	lda ent_r4,x
	and #$01
	sta ent_r4,x
	lda #$00
	sta ent_r5,x	
	
	; direction
	lda ent_r3,x
	beq .move_right
	cmp #$01
	beq .move_left
	cmp #$02
	beq .move_up
	jmp .move_down
.move_right
	lda ent_x,x
	clc
	adc #$01
	sta ent_x,x
	lda ent_x_hi,x
	adc #$00
	sta ent_x_hi,x
	jmp .dir_done
.move_left
	lda ent_x,x
	sec
	sbc #$01
	sta ent_x,x
	lda ent_x_hi,x
	sbc #$00
	sta ent_x_hi,x
	jmp .dir_done
.move_up
	lda ent_y,x
	sec
	sbc #$01
	sta ent_y,x
	jmp .dir_done
.move_down
	lda ent_y,x
	clc
	adc #$01
	sta ent_y,x
.dir_done

	; bound grub
.check_y_bounds
	lda ent_y,x
	cmp #$38
	bcc .y_too_high
	cmp #$b0
	bcs .y_too_low
	jmp .check_x_bounds
.y_too_high
	lda #$3c
	sta ent_y,x
	lda #$01
	sta ent_r3,x
	jmp .turn_left_or_right
.y_too_low
	lda #$af
	sta ent_y,x
	lda #$00
	sta ent_r3,x
	jmp .turn_left_or_right
.check_x_bounds
	lda ent_x_hi,x
	bmi .check_x_left_escape
	bne .check_x_hi_bound
	lda ent_x,x
	cmp #$05
	bne .bound_check_done
	lda #$06
	sta ent_x,x
	jmp .turn_up_or_down
	jmp .bound_check_done
.check_x_left_escape
	lda #$04
	sta ent_x,x
	lda #$00
	sta ent_x_hi,x
	lda #$03
	sta ent_r3,x
.check_x_hi_bound
	lda ent_x,x
	cmp #$f0
	bcc .bound_check_done
	lda #$eb
	sta ent_x,x
	lda #$02
	sta ent_r3,x
	jmp .turn_up_or_down
.bound_check_done

	; check for turning
	lda ent_r2,x
	bne .not_turning
.do_turn
	jsr rng_update
	lda ent_r3,x
	and #$02
	bne .turn_left_or_right
.turn_up_or_down
	clc
	lda ent_x,x
	adc #$04
	sta ent_x,x
	lda ent_x_hi,x
	adc #$00
	sta ent_x_hi,x
	lda ent_y,x
	clc
	adc #$04
	sta ent_y,x
	; get next dir
	lda rng_val0
	and #$01
	bne .turn_down
.turn_up
	lda #$02
	sta ent_r3,x
	jmp .reset_turn_counter
.turn_down
	lda #$03
	sta ent_r3,x
	jmp .reset_turn_counter
.turn_left_or_right
	sec
	lda ent_x,x
	sbc #$04
	sta ent_x,x
	lda ent_x_hi,x
	sbc #$00
	sta ent_x_hi,x
	lda ent_y,x
	sec
	sbc #$04
	sta ent_y,x
	; get next dir
	lda rng_val0
	and #$01
	bne .turn_right
.turn_left
	lda #$00
	sta ent_r3,x
	jmp .reset_turn_counter
.turn_right
	lda #$01
	sta ent_r3,x
.reset_turn_counter
	lda rng_val1
	and #$1f
	clc
	adc #$1f
	sta ent_r2,x
	jmp .turning_done
.not_turning
	dec ent_r2,x
.turning_done

	inc ent_r0,x
	lda ent_r0,x
	cmp #$03
	bne .skip_tooth_dmg
	lda #$00
	sta ent_r0,x
	ldy #$01
	jsr ent_sully_cell
.skip_tooth_dmg
	ldx ent_slot

.frame_done

	jsr ent_calc_position
	lda ent_visible
	sta ent_coll_visible,x
	lda collision_0_x
	sta ent_coll_x,x
	lda collision_0_y
	sta ent_coll_y,x

	; hitbox adjustments
	lda ent_r3,x
	and #$02
	bne .hitbox_tall
.hitbox_wide
	lda collision_0_x
	clc
	adc #$04
	sta collision_0_x
	jmp .hitbox_adjust_done
.hitbox_tall
	lda #$0a
	sta collision_0_w
.hitbox_adjust_done

.check_brush_collision
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
	lda ent_r3 ; player dir
	and #$01
	sta ent_r3,x
	bne .skitter_left
.skitter_right
	clc
	lda ent_x,x
	adc #$01
	sta ent_x,x
	lda ent_x_hi,x
	adc #$00
	sta ent_x_hi,x
	jmp .skitter_done
.skitter_left
	sec
	lda ent_x,x
	sbc #$01
	sta ent_x,x
	lda ent_x_hi,x
	sbc #$00
	sta ent_x_hi,x
.skitter_done
	lda #grub_attacked_wait_length
	sta ent_r1,x
	lda ent_r5,x
	cmp ent_r1,x
	bcc .dont_reset_r5
	lda #$00
	sta ent_r5,x
.dont_reset_r5
	dec ent_hp,x
	lda ent_hp,x
	bpl .brushing_done
	jsr ent_particle_spawn_from_baddie
.brushing_done
	
	lda ent_y,x
	clc
	adc #$10
	ent_z_calc_sort_vals_9bit

	jmp ent_z_update_return



ent_grub_render: subroutine
	; sprite
	lda ent_r3,x
	asl
	clc
	adc ent_r4,x
	tax
	lda grub_dir_sprite,x
	sta temp00
	; attr
	lda grub_dir_attr,x
	sta temp01

	ldx ent_slot
	lda ent_r3,x
	and #$02
	beq .generic_render
.up_down_single_sprite
	lda ent_coll_visible,x
	and #$01
	cmp #$01
	bne .render_done
	lda ent_coll_x,x
	sta spr_x,y
	lda ent_coll_y,x
	sta spr_y,y
	lda temp00
	sta spr_p,y
	lda temp01
	sta spr_a,y
	inc_y 4
	jmp .render_done
.generic_render
	lda ent_coll_visible,x
	sta ent_visible
	lda ent_coll_x,x
	sta collision_0_x
	lda ent_coll_y,x
	sta collision_0_y
	jsr ent_render_generic_8x16

.render_done
	jmp ent_z_render_return

