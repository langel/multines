
; ent_r0 spin frame
; ent_r1 spin counter
; ent_r2 arctang dir


ent_broom_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_broom_id
	sta ent_type,x

	lda #$78
	sta ent_x,x
	lda #$78
	sta ent_y,x

	jsr rng_update
	lda rng_val0
	and #$07
	adc #$03
	sta ent_r2,x

.done
	rts


ent_broom_update: subroutine
	; update logic

	; despawn check
	lda ent_x,x
	cmp #$f8
	bcs .despawn
	lda ent_y,x
	cmp #$f0
	bcc .despawn_done
.despawn
	ent_despawn
	jsr ent_broom_spawn
	rts
.despawn_done

	; animation
	inc ent_r1,x
	lda ent_r1,x
	cmp #$03
	bne .next_frame_done
	lda #$00
	sta ent_r1,x
	inc ent_r0,x
	lda ent_r0,x
	cmp #$0d
	bne .next_frame_done
	and #$00
	sta ent_r0,x
.next_frame_done

	; move position
	lda #<arctang_velocity_1.75
	sta arctang_vel_lo
	lda #>arctang_velocity_1.75
	sta arctang_vel_hi
	; x dir
	lda ent_x,x
	sta temp00
	lda ent_x_lo,x
	sta temp01
	lda ent_r2,x
	sta temp02
	jsr arctang_update_x
	ldx ent_slot
	lda temp01
	sta ent_x_lo,x
	lda temp00
	sta ent_x,x
	; y dir
	lda ent_y,x
	sta temp00
	lda ent_y_lo,x
	sta temp01
	lda ent_r2,x
	sta temp02
	jsr arctang_update_y
	ldx ent_slot
	lda temp01
	sta ent_y_lo,x
	lda temp00
	sta ent_y,x


	; render 
	ldy ent_spr_ptr
	; cache x,y
	lda ent_x,x
	sta temp00
	lda ent_y,x
	sta temp01

	lda ent_r0,x
	tax
	; pattern 0
	clc
	lda broom_spin_x_0,x
	adc temp00
	sta spr_x,y
	clc
	lda broom_spin_y_0,x
	adc temp01
	sta spr_y,y
	lda broom_spin_pattern_0,x
	sta spr_p,y
	lda broom_spin_attr,x
	sta spr_a,y
	inc_y 4
	; pattern 1
	clc
	lda broom_spin_x_1,x
	adc temp00
	sta spr_x,y
	clc
	lda broom_spin_y_1,x
	adc temp01
	sta spr_y,y
	lda broom_spin_pattern_1,x
	sta spr_p,y
	lda broom_spin_attr,x
	sta spr_a,y
	inc_y 4
	rts


broom_spin_pattern_0:	
	hex 2a 2c 3b 3c 
	hex 3d 2c 2a
	hex 2c 3b 3c 3d
	hex 2c 2a
broom_spin_x_0:
	hex 00 00 04 04
	hex 04 08 08
	hex 08 04 04 04
	hex 00 00
broom_spin_y_0:
	hex 04 00 00 00 
	hex 00 00 04
	hex 08 08 08 08
	hex 08 04
broom_spin_pattern_1:	
	hex 2b 2d 4b 4c
	hex 4d 2d 2b
	hex 2d 4b 4c 4d
	hex 2d 2b
broom_spin_x_1:
	hex 08 08 04 04
	hex 04 00 00
	hex 00 04 04 04
	hex 08 08
broom_spin_y_1:
	hex 04 08 08 08 
	hex 08 08 04
	hex 00 00 00 00
	hex 00 04
broom_spin_attr:
	hex 02 02 02 02
	hex 02 42 c2
	hex c2 c2 c2 c2
	hex 82 82
