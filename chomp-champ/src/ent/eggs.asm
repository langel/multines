
; ent_r0 countdowner to hatch
; ent_r1 x shake offset
; ent_r3 sine phase
; ent_r4 x lo shake origin
; ent_r5 x hi shake origin



ent_eggs_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_eggs_id
	sta ent_type,x
	;position
	lda #$f5
	sta ent_x,x
	sta ent_r4,x
	lda #$00
	sta ent_x_hi,x
	sta ent_r5,x
	lda #$a0
	sta ent_y,x
	; shake props
	lda #$40
	sta ent_r4
.done
	rts


ent_eggs_spawn_from_poop: subroutine
	; a holds target ent_slot
	tay
	lda #ent_eggs_id
	sta ent_type,y
	sec
	lda ent_x,y
	sbc #$01
	sta ent_x,y
	sta ent_r4,y
	lda ent_x_hi,y
	sbc #$00
	sta ent_x_hi,y
	sta ent_r5,y
	
	lda #$20
	sta ent_hp,y
	lda #$ff
	sta ent_r1,y
	ent_despawn_2
	rts


ent_eggs_update: subroutine
	; update logic

	; add sine to origin
	clc
	lda ent_r4,x
	adc ent_r1,x
	sta ent_x,x
	lda ent_r5,x
	adc #$00
	sta ent_x_hi,x
	jsr ent_calc_position
	
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
	lda ent_r0,x
	sec
	sbc #$07
	bcc .hatch
	sta ent_r0,x
.brushing_done

	dec ent_r0,x
	bne .dont_hatch
	; transform into grub
.hatch
	jsr ent_grub_spawn_from_egg
	jsr ent_particle_spawn_from_egg
	jmp ent_z_update_return
.dont_hatch

	; shake time
	lda #$00
	sta temp00
	sec
	lda #$ff
	sbc ent_r0,x
	shift_r 2
	clc
	adc ent_r3,x
	sta ent_r3,x
	tay
	lda sine_table,y
	sta temp01
	clc
	adc temp01
	sta temp01
	bcc .added1
	inc temp00
.added1
	clc
	adc temp01
	sta temp01
	bcc .added2
	inc temp00
.added2
	lda temp00
	sta ent_r1,x

	lda ent_y,x
	clc
	adc #$10
	ent_z_calc_sort_vals_9bit



ent_eggs_render: subroutine
	ldy ent_spr_ptr

.left_sprite
	lda ent_visible
	and #$01
	beq .right_sprite
	lda #$30
	sta spr_p,y
	lda #$03
	sta spr_a,y
	lda ent_pos_x
	sta spr_x,y
	lda ent_pos_y
	sta spr_y,y
	inc_y 4
.right_sprite
	lda ent_visible
	and #$02
	beq .sprites_done
	lda #$30
	sta spr_p,y
	lda #$43
	sta spr_a,y
	lda ent_pos_x
	clc
	adc #$08
	sta spr_x,y
	lda ent_pos_y
	sta spr_y,y
	inc_y 4
.sprites_done

	jmp ent_z_update_return

