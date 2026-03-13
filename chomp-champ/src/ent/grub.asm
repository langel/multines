
; ent_r1 tooth cell id
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

	lda #$03
	sta ent_r3,x
.done
	rts


ent_grub_spawn_from_egg: subroutine
	lda #ent_grub_id
	sta ent_type,x


	jsr rng_update
	lda rng_val0
	and #$1f
	sta ent_r2,x
	lda rng_val1
	and #$03
	sta ent_r3,x

	lda ent_r3,x
	and #$02
	beq .no_x_offset
	lda ent_x,x
	clc
	adc #$04
	sta ent_x,x
	lda ent_x_hi,x
	adc #$00
	sta ent_x_hi,x
.no_x_offset

	lda #$00
	sta ent_r4,x
	sta ent_r5,x
	rts


ent_grub_update: subroutine
	; update logic

	inc ent_r5,x
	lda ent_r5,x
	cmp #$07
	beq .update_grub
	jmp .frame_done

.update_grub
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
	jmp .turn_left_or_right
.y_too_low
	lda #$af
	sta ent_y,x
	jmp .turn_left_or_right
.check_x_bounds
	lda ent_x_hi,x
	bne .check_x_hi_bound
	lda ent_x,x
	cmp #$02
	bne .bound_check_done
	lda #$03
	sta ent_x,x
	jmp .turn_up_or_down
	jmp .bound_check_done
.check_x_hi_bound
	lda ent_x,x
	cmp #$f0
	bne .bound_check_done
	lda #$eb
	sta ent_x,x
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

	; dirt some tooth
	; (germ_x / 16) 
	; +
	; ((germ_y / 16) * 32)
	lda ent_x_hi,x
	lsr
	lda ent_x,x
	ror
	shift_r 3
	sta temp00
	lda ent_y,x
	sec
	sbc #$37
	shift_r 4
	shift_l 5
	clc
	adc temp00
	sta ent_r1,x ; cell_id
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

.frame_done

	jmp ent_z_update_return



ent_grub_render: subroutine
	; render (reload y?)
	jsr ent_calc_position
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
	lda ent_visible
	beq .render_done
	lda collision_0_x
	sta spr_x,y
	lda collision_0_y
	sta spr_y,y
	lda temp00
	sta spr_p,y
	lda temp01
	sta spr_a,y
	inc_y 4
	jmp .render_done
.generic_render
	jsr ent_render_generic_8x16

.render_done
	jmp ent_z_render_return

