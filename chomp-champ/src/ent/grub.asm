
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

grub_hp                   eqm #$0c
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
	; replace egg ent slot
	lda #ent_grub_id
	sta ent_type,x

	lda #grub_hp
	sta ent_hp,x
	; distance to next turn
	jsr rng_update
	lda rng_val0
	and #$1f
	sta ent_r2,x
	; starting direction
	lda rng_val1
	and #$03
	sta ent_r3,x
	; move right only when initial direction is up/down
	lda ent_r3,x
	and #$02
	beq .spawn_pos_done
	lda ent_x,x
	clc
	adc #$06
	sta ent_x,x
	lda ent_x_hi,x
	adc #$00
	sta ent_x_hi,x
.spawn_pos_done

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
	jsr rng_update
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
	jsr rng_update
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

.frame_done

	jsr ent_calc_position
	; hitbox adjustments
	lda ent_r3,x
	and #$02
	bne .hitbox_tall
.hitbox_wide
	lda collision_0_y
	clc
	adc #$06
	sta ent_hitbox_y,x
	lda #$0a
	sta collision_0_h
	jmp .hitbox_adjust_done
.hitbox_tall
	lda #$08
	sta collision_0_w
	lda collision_0_y
	sta ent_hitbox_y,x
.hitbox_adjust_done
	; save hitbox to registers
	lda ent_visible
	sta ent_coll_visible,x
	lda collision_0_x
	sta ent_coll_x,x
	lda collision_0_y
	sta ent_coll_y,x
	lda collision_0_w
	sta ent_coll_w,x
	lda collision_0_h
	sta ent_coll_h,x

	; check player collision
	lda ent_visible
	beq .player_collision_done
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
	jsr ent_particle_spawn_from_baddie
	ldy ent_spr_ptr
	jmp ent_z_update_return
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
	lda ent_hitbox_y,x
	adc collision_0_h
	cmp brush_hit_y
	bcc .brushing_done
	clc
	lda ent_hitbox_y,x
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




ent_grub_render: subroutine
	ldy ent_spr_ptr
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
	jmp ent_z_update_return





ent_grub_convergence: subroutine
	; temp00: start slot
	; temp01: selected grub slot A
	; temp02: search loop counter
	; temp04: |dx|
	; temp05: shared avg y
	; temp06: shared avg x_hi
	; temp07: shared avg x

	lda grub_converge_slot
	and #$1f
	sta temp00
	tax

	lda #$20
	sta temp02
.find_next_grub
	lda ent_type,x
	cmp #ent_grub_id
	beq .grub_found
	inx
	txa
	and #$1f
	tax
	dec temp02
	bne .find_next_grub
	jmp .no_grubs

.grub_found
	stx temp01
	txa
	clc
	adc #$01
	and #$1f
	sta grub_converge_slot

	ldx #$00
.compare_loop
	cpx #$20
	bne .compare_not_done
	jmp .done
.compare_not_done
	cpx temp01
	bne .compare_not_self
	jmp .next_compare
.compare_not_self
	lda ent_type,x
	cmp #ent_grub_id
	beq .compare_is_grub
	jmp .next_compare
.compare_is_grub
	ldy temp01

	; x hi mismatch means distance is definitely >= 256
	lda ent_x_hi,x
	cmp ent_x_hi,y
	beq .x_hi_match
	jmp .next_compare
.x_hi_match

	; |dx|
	sec
	lda ent_x,x
	sbc ent_x,y
	bcs .x_abs_done
	eor #$ff
	clc
	adc #$01
.x_abs_done
	sta temp04
	cmp #$10
	bcc .x_dist_ok
	jmp .next_compare
.x_dist_ok

	; |dy|
	sec
	lda ent_y,x
	sbc ent_y,y
	bcs .y_abs_done
	eor #$ff
	clc
	adc #$01
.y_abs_done
	cmp #$10
	bcc .y_dist_ok
	jmp .next_compare
.y_dist_ok
	clc
	adc temp04
	bcc .distance_no_overflow
	jmp .next_compare
.distance_no_overflow
	cmp #$10
	bcc .distance_ok
	jmp .next_compare
.distance_ok

	; midpoint y = (yA + yB) >> 1
	clc
	lda ent_y,y
	adc ent_y,x
	ror
	sta temp05

	; midpoint x = (xA + xB) >> 1 (9-bit x)
	clc
	lda ent_x,y
	adc ent_x,x
	sta temp07
	lda ent_x_hi,y
	adc ent_x_hi,x
	ror
	sta temp06
	lda temp07
	ror
	sta temp07

	; apply midpoint to selected grub (A)
	ldy temp01
	lda temp07
	sta ent_x,y
	lda temp06
	sta ent_x_hi,y
	lda temp05
	sta ent_y,y

	; apply midpoint to matched grub (B)
	lda temp07
	sta ent_x,x
	lda temp06
	sta ent_x_hi,x
	lda temp05
	sta ent_y,x

	; selected grub becomes germ
	lda #ent_germ_id
	sta ent_type,y
	lda #$40
	sta ent_hp,y
	lda #$ff
	sta ent_r4,y
	jsr rng_update
	ldy temp01
	lda rng_val0
	sta ent_r2,y
	and #$07
	sta ent_r3,y

	; matched grub becomes particle
	jsr ent_particle_spawn_from_baddie
	jmp .done

.next_compare
	inx
	jmp .compare_loop

.no_grubs
	lda temp00
	clc
	adc #$01
	and #$1f
	sta grub_converge_slot

.done
	rts
