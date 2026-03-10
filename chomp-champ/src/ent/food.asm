
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
; ent_r1 is subtype
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
	lda #$10
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
	adc collision_0_w
	cmp brush_hit_y
	bcc .brushing_done
	clc
	lda collision_0_y
	cmp brush_hit_y
	bcs .brushing_done
.brush_collision
	dec ent_hp,x
	lda wtf
	and #$03
	beq .brushing_done
	cmp #$01
	beq .shake_left
	cmp #$02
	beq .shake_right
	jmp .brushing_done
.shake_left
	dec ent_r4,x
	jmp .brushing_done
.shake_right
	inc ent_r4,x
.brushing_done

	; check floss collision
	; xxx should require state $01
	lda controller1
	and #FLOSS_BUTTON
	beq .skip_flossing
	clc
	lda collision_0_x
	adc collision_0_w
	cmp floss_hit_x
	bcc .no_floss_collision
	clc
	lda collision_0_x
	cmp floss_hit_x
	bcs .no_floss_collision
	clc
	lda collision_0_y
	adc collision_0_w
	cmp floss_hit_y
	bcc .no_floss_collision
	clc
	lda collision_0_y
	cmp floss_hit_y
	bcs .no_floss_collision
.floss_collision
	ent_despawn
.no_floss_collision
.skip_flossing

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
	jsr ent_render_generic_8x16

	jmp ent_z_render_return
