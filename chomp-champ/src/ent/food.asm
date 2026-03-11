
; food behaviors

; static position
; can be behind/between teeth
; has hp against brush/floss
; falls downwards on death
; germs can eat it too

; ent_r0 state
;        #$00 on teeth
;        #$01 between teeth
;        #$80 falling
;             ent_r6 y vel lo
;             ent_r7 y vel hi
; ent_r1 #$0x subtype
;        #$x0 tooth gap
;        #b00000xxx subtype
;        #b0000x000 is in gap
;        #bxxxx0000 gap id
; ent_r2 attacked shake pos
; ent_r3 visible
; ent_r4 collision x
; ent_r5 collision y
; ent_r6 z sort up
; ent_r7 z sort down

ent_food_sprite:
	hex 00 04 08 0c
	hex 20 24 28 2c

ent_food_attr:
	hex 02 01 01 00
	hex 00 03 02 03

ent_food_gap_x_hi_pos:
	hex ff 00 00 00 01 01 01 01
ent_food_gap_x_pos:
	hex f7 37 77 b7 38 78 b8 f8

ent_food_starting_hp   eqm #$10


ent_food_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_food_id
	sta ent_type,x
	stx ent_slot
	jsr ent_random_spawn_pos
	lda ent_slot
	and #$0f
	sta temp00
	lda #$07
	sta temp01
	jsr shift_multiply
	lda temp00
	clc
	adc #$40
	ldx ent_slot
	sta ent_y,x
	; set subtype
	txa
	and #$07
	sta ent_r1,x
	; set state
	lda #$00
	sta ent_r0,x
	; hit points?
	lda #ent_food_starting_hp
	sta ent_hp,x
.done
	rts

ent_food_spawn_in_gap: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_food_id
	sta ent_type,x
	stx ent_slot
	jsr rng_update
	lda rng_val0
	and #$f0
	ora #$08
	sta ent_r1,x
	; set position
	lda ent_r1,x
	and #$70
	shift_r 4
	tay
	ldy #$07
	lda ent_food_gap_x_hi_pos,y
	sta ent_x_hi,x
	lda ent_food_gap_x_pos,y
	sta ent_x,x
	lda ent_r1,x
	and #$80
	bne .bottom_row
.top_row
	lda #$40
	jmp .row_found
.bottom_row
	lda #$b0
.row_found
	sta ent_y,x
	; set subtype
	txa
	and #$07
	ora ent_r1,x
	sta ent_r1,x
	; set state
	lda #$01
	sta ent_r0,x
	; hit points?
	lda #ent_food_starting_hp
	sta ent_hp,x
.done
	rts


ent_food_update: subroutine
	; update logic
	jsr ent_calc_position
	lda ent_visible
	sta ent_r3,x
	lda collision_0_x
	sta ent_r4,x
	lda collision_0_y
	sta ent_r5,x

	lda ent_r0,x
	bpl .standard_behavior

	; FALLING STATE
	clc
	lda ent_r6,x
	adc #$40
	sta ent_r6,x
	lda ent_r7,x
	adc #$00
	sta ent_r7,x
	clc
	lda ent_y_lo,x
	adc ent_r6,x
	sta ent_y_lo,x
	lda ent_y,x
	adc ent_r7,x
	sta ent_y,x
	cmp #$f0
	bcc .dont_despawn
	ent_despawn
.dont_despawn
	jmp ent_z_update_return


.standard_behavior
	lda ent_visible
	bne .get_collision_type
	jmp .collision_checks_done
.get_collision_type
	lda ent_r1,x
	and #$08
	bne .check_floss_collision
	
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
	dec ent_hp,x
	lda wtf
	lsr
	and #$03
	beq .brushing_done
	cmp #$01
	beq .brush_shake_left
	cmp #$02
	beq .brush_shake_right
	jmp .brushing_done
.brush_shake_left
	dec ent_r4,x
	jmp .brushing_done
.brush_shake_right
	inc ent_r4,x
.brushing_done
	jmp .collision_checks_done

.check_floss_collision
	lda floss_status
	and #$40
	bne .floss_check_controller
	jmp .flossing_done
.floss_check_controller
	lda controller1
	and #FLOSS_BUTTON
	bne .floss_check_visible
	jmp .flossing_done
.floss_check_visible
	; prep left edge collisions
	lda ent_visible
	cmp #$02
	bne .standard_collision_box
.left_oob_collision_box
	lda collision_0_w
	clc
	adc collision_0_x
	sta temp01 ; w
	lda #$00
	sta temp00 ; x
	clc
	lda temp00 ; x
	adc collision_0_w
	cmp floss_hit_x
	bcc .flossing_done
	clc
	lda temp00 ; x
	cmp floss_hit_x
	bcs .flossing_done
	clc
	lda collision_0_y
	adc collision_0_h
	cmp floss_hit_y
	bcc .flossing_done
	clc
	lda collision_0_y
	cmp floss_hit_y
	bcs .flossing_done
	jmp .floss_collision
.standard_collision_box
	clc
	lda collision_0_x
	adc collision_0_w
	cmp floss_hit_x
	bcc .flossing_done
	clc
	lda collision_0_x
	cmp floss_hit_x
	bcs .flossing_done
	clc
	lda collision_0_y
	adc collision_0_h
	cmp floss_hit_y
	bcc .flossing_done
	clc
	lda collision_0_y
	cmp floss_hit_y
	bcs .flossing_done
.floss_collision
	dec ent_hp,x
	lda wtf
	lsr
	and #$03
	beq .flossing_done
	cmp #$01
	beq .floss_shake_left
	cmp #$02
	beq .floss_shake_right
	jmp .flossing_done
.floss_shake_left
	dec ent_r4,x
	bpl .dont_fix_shake_left
	inc ent_r4,x
	inc ent_r4,x
.dont_fix_shake_left
	jmp .flossing_done
.floss_shake_right
	inc ent_r4,x
.flossing_done

.collision_checks_done

	; set z position
	lda ent_y,x
	clc
	adc #$10
	ent_z_calc_sort_vals_9bit

	; check hp
	lda ent_hp,x
	bpl .lives
	lda #$80
	sta ent_r0,x
	lda #$fd
	sta ent_r7,x
	lda #$00
	sta ent_r6,x
.lives
	
	jmp ent_z_update_return





ent_food_render: subroutine
	; RENDER
	lda ent_r1,x
	and #$07
	tay
	lda ent_food_sprite,y
	sta temp00
	lda ent_food_attr,y
	sta temp01
	ldy ent_spr_ptr
	; recall ent position
	lda ent_r3,x
	sta ent_visible
	lda ent_r4,x
	sta collision_0_x
	lda ent_r5,x
	sta collision_0_y
	; check if in gap or not
	lda ent_r0,x
	bmi .standard
	beq .standard
.in_gap
	jmp ent_food_gap_render
.standard
	jsr ent_render_generic_8x16

	jmp ent_z_render_return
















	
ent_food_gap_render: subroutine
	; temp00 sprite base id
	; temp01 attribute value
	; needs to check for y
.left
	lda ent_visible
	and #$01
	beq .left_done
.left_x
	lda collision_0_x
	sta spr_x,y
.left_y
	lda collision_0_y
	sta spr_y,y
.left_sprite
	lda temp00
	sta spr_p,y
.left_attribute
	lda ent_r1,x
	and #$70
	cmp #$40
	bcs .left_not_behind
.left_behind
	lda temp01
	ora #$20
	jmp .left_finish
.left_not_behind
	lda temp01
.left_finish
	sta spr_a+$00,y
	inc_y 4
.left_done
.right
	lda ent_visible
	and #$02
	beq .done
.right_x
	lda collision_0_x
	clc
	adc #$08
	sta spr_x,y
.right_y
	lda collision_0_y
	sta spr_y,y
.right_sprite
	lda temp00
	clc
	adc #$02
	sta spr_p,y
.right_attribute
	lda ent_r1,x
	and #$70
	cmp #$40
	bcc .right_not_behind
	lda temp01
.right_behind
	lda temp01
	ora #$20
	jmp .right_finish
.right_not_behind
	lda temp01
.right_finish
	sta spr_a,y
	inc_y 4
.done
	jmp ent_z_render_return
