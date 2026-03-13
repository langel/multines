
; ent_r0 countdowner to hatch
; ent_r1 x shake offset
; ent_r2 y shake offset
; ent_r3 sine phase



ent_eggs_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_eggs_id
	sta ent_type,x
	;position
	lda #$f5
	sta ent_x,x
	lda #$00
	sta ent_x_hi,x
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
	lda ent_x_hi,y
	sbc #$00
	sta ent_x_hi,y
	
	lda #$20
	sta ent_hp,y
	lda #$ff
	sta ent_r1,y
	rts


ent_eggs_update: subroutine
	; update logic

	dec ent_r0,x
	bne .dont_hatch
	; transform into grub
	jmp ent_grub_spawn_from_egg
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



	jmp ent_z_update_return


ent_eggs_render: subroutine
	; render (reload y?)
	jsr ent_calc_position

	; shake adjust
	lda collision_0_x
	clc
	adc ent_r1,x
	sta collision_0_x

.left_sprite
	lda ent_visible
	and #$01
	beq .right_sprite
	lda #$30
	sta spr_p,y
	lda #$03
	sta spr_a,y
	lda collision_0_x
	sta spr_x,y
	lda collision_0_y
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
	lda collision_0_x
	clc
	adc #$08
	sta spr_x,y
	lda collision_0_y
	sta spr_y,y
	inc_y 4
.sprites_done

	jmp ent_z_render_return

