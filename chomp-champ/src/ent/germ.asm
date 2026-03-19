
; ent_r0 animation counter
; ent_r1 animation frame
; ent_r2 poop clock
; ent_r3 direction
;  polar coordinates

;	000000x0 left/right
;	0000000x up/down

;  0000000x up
;  000000x0 right
;  00000x00 down
;  0000x000 left

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
	hex 04 03 06 01 00 07 02 05
ent_germ_mirror_y:
	hex 04 07 06 05 00 03 02 01

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
	and #$03
	sta ent_r3,x
	; hp
	lda #$10
	sta ent_hp,x
.done
	rts


ent_germ_update: subroutine

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

	jsr ent_calc_position
	lda ent_visible
	sta ent_coll_visible,x
	lda collision_0_x
	sta ent_coll_x,x
	lda collision_0_y
	sta ent_coll_y,x
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
	; take hit points
	dec ent_hp,x
	lda ent_hp,x
	; set germs on offensive
	lda #$7f
	sta germ_attacked
	bpl .brushing_done
	jsr ent_particle_spawn_from_baddie
	jmp ent_z_update_return
.brushing_done

	; check germs_attack
	lda germ_attacked
	;beq .passive_mode
	beq .testing
	sec
	lda germ_attacked
	sbc #$10
	bcs .stay_offensive
	lda #$00
	sta germ_attacked
.stay_offensive
	jmp .offense_mode

.testing
/*
	lda wtf
	and #$0f
	bne .turning_done
	inc ent_r3,x
	lda ent_r3,x
	cmp #$08
	bne .turning_done
	lda #$00
	sta ent_r3,x
.turning_done
*/
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

.passive_mode
/*
	; movement left/right
	lda ent_r3,x
	and #$02
	beq .move_left
.move_right
	inc ent_x,x
	bne .no_right_carry
	inc ent_x_hi,x
.no_right_carry
	jmp .right_left_done
.move_left
	lda ent_x,x
	sec
	sbc #$01
	sta ent_x,x
	lda ent_x_hi,x
	sbc #$00
	sta ent_x_hi,x
.right_left_done
	; movement up/down
	lda ent_r3,x
	and #$01
	beq .move_up
.move_down
	inc ent_y,x
	jmp .down_up_done
.move_up
	dec ent_y,x
.down_up_done
	jmp .movement_done
*/

.offense_mode

.movement_done


	; bound x
	lda ent_x_hi,x
	bne .bound_x_far_right
.bound_x_far_left
	lda ent_x,x
	cmp #$02
	bcs .bound_x_done
	lda #$02
	sta ent_x,x
	lda #$00
	jmp .turn_x
.bound_x_far_right
	lda ent_x,x
	cmp #$ee
	bcc .bound_x_done
.turn_x
	lda ent_r3,x
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
	; (germ_x / 16) 
	; +
	; ((germ_y / 16) * 32)
	lda ent_x_hi,x
	lsr
	lda ent_x,x
	ror
	clc
	adc #$04
	shift_r 3
	sta temp00
	lda ent_y,x
	sec
	sbc #$37
	shift_r 4
	shift_l 5
	clc
	adc temp00
	sta ent_r5,x ; cell_id
	sta temp01
	; check tooth is present
	tax
	lda tooth_cell2tooth,x
	tax
	lda tooth_total_dmg,x
	bmi .skip_tooth_dmg
	; xxx check tooth is cleared
	beq .skip_tooth_dmg
	; increase tooth damage
	; but it maxes it
	ldx temp01
	lda $600,x
	cmp #$0f
	beq .skip_tooth_dmg
	inc $600,x
	; add tooth cell to update queue
	txa
	ldx tooth_update_queue_size
	sta tooth_needs_update,x
	inc tooth_update_queue_size
	; log tooth change
.skip_tooth_dmg
	ldx ent_slot

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
	ent_z_calc_sort_vals
	
	jmp ent_z_update_return



ent_germ_frame_table:
	hex 58 5c 58 60
	hex 4c 50 4c 54
	hex 40 44 40 48
	hex 4c 50 4c 54
	hex 58 5c 60 5c
	hex 64 68 64 6c
	hex 70 74 70 78
	hex 64 68 64 6c

ent_germ_attr_table:
	hex 01 01 01 41 41 41 01 01

ent_germ_render: subroutine
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
	; attr
	ldx ent_slot
	lda ent_r3,x
	tax
	lda ent_germ_attr_table,x
	ldx ent_slot
	; setup generic renderer
	sta temp01
	lda ent_coll_visible,x
	sta ent_visible
	lda ent_coll_x,x
	sta collision_0_x
	lda ent_coll_y,x
	sta collision_0_y
	jsr ent_render_generic_8x16

	jmp ent_z_render_return

