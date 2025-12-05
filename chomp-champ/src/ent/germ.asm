
; ent_r0 animation counter
; ent_r1 frame counter
; ent_r2 poop clock
; ent_r3 direction
;	000000x0 left/right
;	0000000x up/down
; ent_r6 z pos sort up
; ent_r7 z pos sort down


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
.done
	rts

ent_germ_update: subroutine

	; spawn poop?
	lda ent_r2,x
	cmp wtf
	bne .no_poop
	;jsr ent_poop_from_germ
.no_poop

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

	; bound x
	lda ent_x_hi,x
	bne .bound_x_far_right
.bound_x_far_left
	lda ent_x,x
	cmp #$02
	bcc .turn_x
	jmp .bound_x_done
.bound_x_far_right
	lda ent_x,x
	cmp #$ee
	bcc .bound_x_done
.turn_x
	lda ent_r3,x
	eor #%00000010
	sta ent_r3,x
.bound_x_done

	; bound y
	lda ent_y,x
	cmp #$40
	bcs .y_high_enough
	lda ent_r3,x
	ora #%00000001
	sta ent_r3,x
	jmp .y_low_enough
.y_high_enough
	cmp #$b0
	bcc .y_low_enough
	lda ent_r3,x
	and #%11111110
	sta ent_r3,x
.y_low_enough

	; set z position
	lda ent_y,x
	clc
	adc #$10
	ent_z_calc_sort_vals

	; update animation frame
	inc ent_r0,x
	lda ent_r0,x
	cmp #$0b
	bne .not_next_frame
	lda #$00
	sta ent_r0,x
	inc ent_r1,x
	lda ent_r1,x
	and #$01
	sta ent_r1,x
.not_next_frame
	
	jmp ent_z_update_return


ent_germ_render: subroutine
	; RENDER
	jsr ent_calc_position
	lda ent_r1,x
	asl
	asl
	clc
	adc #$60
	sta temp00
	lda #$01
	sta temp01
	jsr ent_render_generic_8x16

	jmp ent_z_render_return

