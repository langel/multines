
big_teef_sprites:
	; upper mandible
	hex 16 18 1a 3a 1c 1e
	; lower mandible
	hex 36 38 3a 1a 3c 3e
	; connective tissue
	hex 14

big_teef_attrs:
	; upper mandible
	hex 03 03 03 83 03 03
	; lower mandible
	hex 03 03 43 c3 03 03
	; connective tissue
	hex 03

big_teef_y_offset:
	; upper mandible
	hex 02 03 06 07 05 05
	; lower mandible
	hex 03 03 05 04 06 05

ent_big_teef_spawn: subroutine
	ldx #$1f
	lda #ent_big_teef_id
	sta ent_type,x

	; big teef palette
	lda #$16
	sta palette_cache+22
	lda #$14
	sta palette_cache+23
	lda #$27
	sta palette_cache+24
.done
	rts


ent_big_teef_update: subroutine

	; xxx TO DO
	;     upper mandible should go up and down instead of lower manidble going down and up
	;     sine movement should be upward hald sine so it looks like its bouncing (or maybe even use gravity instead)

	ldx ent_slot

	; forward the animation counter
	inc ent_x,x
	lda ent_r4,x
	tax
	lda sine_table,x
	shift_r 5
	clc
	adc #$9e
	ldx ent_slot
	sta ent_y,x
	inc ent_r4,x
	inc ent_r4,x
	inc ent_r4,x

	; for z sort
	lda player_x_hi
	sta ent_x_hi,x
	; ^ this sucks


ent_big_teef_render: subroutine

	; upper mandible
	lda ent_x,x
	sta temp00
	lda ent_y,x
	sta temp01
	lda #$16
	sta temp02 ; sprite pattern
	ldx #$00
.upper_loop
	lda big_teef_sprites,x
	sta spr_p,y
	lda big_teef_attrs,x
	sta spr_a,y
	; x
	lda temp00
	sta spr_x,y
	clc 
	adc #$08
	sta temp00
	; y
	sec
	lda temp01
	sbc big_teef_y_offset,x
	sta spr_y,y
	inc_y 4
	inx
	cpx #$06
	bne .upper_loop

	; lower mandible
	ldx ent_slot
	lda ent_x,x
	sta temp00
	; y pos
	lda ent_r4,x
	tax
	lda sine_table,x
	SHIFT_R 5
	clc
	adc temp01 ; y origin
	adc #$08
	sta temp01
	ldx #$06
.lower_loop
	lda big_teef_sprites,x
	sta spr_p,y
	lda big_teef_attrs,x
	sta spr_a,y
	; x
	lda temp00
	sta spr_x,y
	clc 
	adc #$08
	sta temp00
	; y
	clc
	lda temp01
	adc big_teef_y_offset,x
	sta spr_y,y
	inc_y 4
	inx
	cpx #$0c
	bne .lower_loop

	; define floor point
	clc
	adc #$09
	ldx ent_slot
	jsr ent_z_calc_sort_vals_9bit
	
	; connective tissue
	; x pos
	ldx ent_slot
	lda ent_x,x
	sta spr_x,y
	; y pos
	ldx ent_slot
	lda ent_y,x
	sta temp01
	lda ent_r4,x
	tax
	lda sine_table,x
	SHIFT_R 6
	clc
	adc #$04
	adc temp01
	sta spr_y,y
	; pattern
	lda #$14
	sta spr_p,y
	lda #$03
	sta spr_a,y
	inc_y 4	

	lda state_update_id
	cmp #state_title_update_id
	bne .dont_rts
	rts
.dont_rts
	

	jmp ent_z_update_return
