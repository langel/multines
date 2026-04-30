
; ent_r0 animation counter
; ent_r1 animation frame
; ent_r2 poop clock
; ent_r3 direction
;        polar coordinates

; ent_r4 food target


; ent_r5 temp tooth cell id
; ent_r6 z pos sort up
; ent_r7 z pos sort down


ent_germ_x_dir_vel_lo:
	hex 6a 00 00 00 97 00 00 00
ent_germ_x_dir_vel:
	hex 01 01 00 ff fe ff 00 01
ent_germ_x_dir_vel_hi:
	hex 00 00 00 ff ff ff 00 00
ent_germ_y_dir_vel_lo:
	hex 00 00 97 00 00 00 6a 00
ent_germ_y_dir_vel:
	hex 00 ff fe ff 00 01 01 01

ent_germ_mirror_x:
	hex 03 05 04 04 ; 00
	hex 04 03 03 03 ; 01
	hex 00 04 00 04 ; 02
	hex 00 01 01 01 ; 03
	hex 01 07 00 00 ; 04
	hex 00 07 07 07 ; 05
	hex 04 00 04 00 ; 06
	hex 05 04 05 05 ; 07
ent_germ_mirror_y:
	hex 02 06 02 06 ; 00
	hex 06 07 07 07 ; 01
	hex 05 07 06 06 ; 02
	hex 05 06 05 05 ; 03
	hex 06 02 02 06 ; 04
	hex 03 02 03 03 ; 05
	hex 03 01 02 02 ; 06
	hex 01 02 01 01 ; 07

ent_germ_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_germ_id
	sta ent_type,x
	jsr ent_random_spawn_pos
	; setup ppo clock
	jsr rng_update
	lda rng_val0
	sta ent_r2,x
	; set direction
	lda rng_val0
	and #$07
	sta ent_r3,x
	; hp
	lda #$40
	sta ent_hp,x
	; clear food target
	lda #$ff
	sta ent_r4,x
.done
	rts


ent_germ_update: subroutine

	jsr ent_calc_position
	lda collision_0_w
	sta ent_coll_w,x
	lda collision_0_h
	sta ent_coll_h,x
	lda collision_0_x
	sta ent_coll_x,x
	lda collision_0_y
	sta ent_coll_y,x

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
	jmp ent_z_update_return
.player_collision_done
	
	; check brush collision
	lda ent_visible
	sta ent_coll_visible,x
	beq .brushing_done
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
	; take hit points
	dec ent_hp,x
	lda ent_hp,x
	bpl .dont_despawn
	jsr ent_particle_spawn_from_baddie
	jmp ent_z_update_return
.dont_despawn
	; set germs on offensive
	lda #$7f
	sta germ_attacked
	stx germ_attackee
	; randomize facing direction
	lda wtf
	and #$03
	bne .rando_dir_done
	jsr rng_update
	lda rng_val0
	and #$07
	sta ent_r3,x
.rando_dir_done
	; move germ towards player
	lda wtf
	and #$03
	bne .germ_attacked_done
	lda ent_r3 ; player dir
	bmi .germ_brushed_right
.germ_brushed_left
	dec ent_x,x
	jmp .germ_attacked_done
.germ_brushed_right
	inc ent_x,x
.germ_attacked_done
	jmp .movement_done
.brushing_done

; states
;    0 = wandering
;    1 = food targetted
;    2 = eating food
;    3 = on offensive
;    4 = under attack


	; check germs_attack
	lda germ_attacked
	beq .update_position
	sec
	lda germ_attacked
	sbc #$10
	sta germ_attacked
	bcs .mode_offense
	lda #$00
	sta germ_attacked
	lda #$ff
	sta germ_attackee
	jmp .update_position
	; target player
.mode_offense
	lda germ_attackee
	cmp ent_slot
	beq .update_position
	lda wtf
	and #$03
	sta temp00
	txa
	and #$03
	cmp temp00
	bne .update_position
	; germ is within shouting distance
	lda ent_x,x
	sta collision_0_x
	lda ent_x_hi,x
	lsr
	ror collision_0_x
	ldy germ_attackee
	lda ent_x,y
	sta collision_1_x
	lda ent_x_hi,y
	lsr
	ror collision_1_x
	lda collision_0_y
	lsr
	sta collision_0_y
	lda ent_y,y
	lsr
	sta collision_1_y
	jsr distance_calc
	cmp #$50
	bcs .update_position
	; germs position for arctang24
	lda ent_x_hi,x
	lsr
	lda ent_x,x
	ror
	sta collision_1_x
	lda ent_y,x
	lsr
	sta collision_1_y
	jsr arctang24
	tax
	lda arctang24_to_dir8,x
	ldx ent_slot
	sta ent_r3,x

.update_position
	; move according to dir
	ldy ent_r3,x
	clc
	lda ent_x_lo,x
	adc ent_germ_x_dir_vel_lo,y
	sta ent_x_lo,x
	lda ent_x,x
	adc ent_germ_x_dir_vel,y
	sta ent_x,x
	lda ent_x_hi,x
	adc ent_germ_x_dir_vel_hi,y
	sta ent_x_hi,x
	clc
	lda ent_y_lo,x
	adc ent_germ_y_dir_vel_lo,y
	sta ent_y_lo,x
	lda ent_y,x
	adc ent_germ_y_dir_vel,y
	sta ent_y,x
	jmp .movement_done

.movement_done

	; spawn poop?
	lda ent_r2,x
	cmp wtf
	bne .no_poop
	jsr rng_update
	lda rng_val0
	cmp #$40
	bcs .no_poop
	jsr ent_poop_from_germ
.no_poop

	; bound x
	lda ent_x_hi,x
	and #$01
	sta ent_x_hi,x
	bne .bound_x_far_right
.bound_x_far_left
	lda ent_x,x
	cmp #$02
	bcs .bound_x_done
	lda #$04
	sta ent_x,x
	jmp .turn_x
.bound_x_far_right
	lda ent_x,x
	cmp #$ee
	bcc .bound_x_done
	lda #$ec
	sta ent_x,x
.turn_x
	lda ent_r3,x
	shift_l 2
	sta temp00
	jsr rng_update
	lda rng_val0
	and #$03
	clc
	adc temp00
	tay
	lda ent_germ_mirror_x,y
	sta ent_r3,x
.bound_x_done

	; bound y
	lda ent_y,x
	cmp #$39
	bcs .y_high_enough
	lda #$3b
	sta ent_y,x
	jmp .turn_y
.y_high_enough
	cmp #$b5
	bcc .bound_y_done
	lda #$b3
	sta ent_y,x
.turn_y
	lda ent_r3,x
	shift_l 2
	sta temp00
	jsr rng_update
	lda rng_val0
	and #$03
	clc
	adc temp00
	tay
	lda ent_germ_mirror_y,y
	sta ent_r3,x
.bound_y_done


	; calc tooth position
	lda wtf
	and #$0f
	sta temp00
	cpx temp00
	bne .skip_tooth_dmg
	ldy #$01
	jsr ent_sully_cell
.skip_tooth_dmg

	; update animation frame
	inc ent_r0,x
	lda ent_r0,x
	cmp #$06
	bne .not_next_frame
	lda #$00
	sta ent_r0,x
	inc ent_r1,x
	lda ent_r1,x
	and #$03
	sta ent_r1,x
.not_next_frame
	
	; set z position
	lda ent_y,x
	clc
	adc #$10
	jsr ent_z_calc_sort_vals_9bit
	
	jmp ent_germ_render



ent_germ_frame_table:
	hex 58 5c 58 60
	hex 4c 50 4c 54
	hex 40 44 40 48
	hex 4c 50 4c 54
	hex 58 5c 58 60
	hex 64 68 64 6c
	hex 70 74 70 74
	hex 64 68 64 6c

ent_germ_attr_table:
	hex 01 01 01 41 41 41 01 01

ent_germ_render: subroutine
	ldy ent_spr_ptr
	; RENDER
	;jsr ent_calc_position
	; metasprite
	ldx ent_slot
	lda ent_r3,x
	shift_l 2
	clc
	adc ent_r1,x
	tax
	lda ent_germ_frame_table,x
	sta temp00
	cpx #$1b
	bne .attr_normal
	lda #$41
	bne .attr_found
	; attr
.attr_normal
	ldx ent_slot
	lda ent_r3,x
	tax
	lda ent_germ_attr_table,x
.attr_found
	ldx ent_slot
	; setup generic renderer
	sta temp01
	jsr ent_render_generic_8x16

	jmp ent_z_update_return

