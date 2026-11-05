
; ent_r0 = sine counter lo
; ent_r1 = sine counter hi
; ent_r2 top row anim frame
; ent_r3 top row anim counter
; ent_r4 butt row anim frame
; ent_r5 butt row anim counter


ent_ghost_spawn: subroutine
	jsr baddies_find_slot
	bmi .done
	lda #ent_ghost_id
	sta ent_type,x
	stx temp02
	; set x
	jsr rng_update
	lda rng_val0
	and #$07
	sta temp00
	lda #27
	sta temp01
	jsr shift_multiply
	ldx temp02
	lda temp00
	clc
	adc #10
	sta ent_x,x
	; set y
	lda #$ef
	sta ent_y,x
	; sine pos
	lda rng_val1
	sta ent_r1,x
.done
	rts


ent_ghost_left_0:
	hex 08 09 18 19 28 29
	hex 00 00
ent_ghost_left_1:
	hex 3a 09 18 19 38 39
	hex 00 00
ent_ghost_left_2:
	hex 08 4a 18 19 48 49
	hex 00 00
ent_ghost_center:
	hex 06 07 16 17 26 27
ent_ghost_right_0:
	hex 09 08 19 18 29 28
	hex 00 00
ent_ghost_right_1:
	hex 09 3a 19 18 39 38
	hex 00 00
ent_ghost_right_2:
	hex 4a 08 19 18 49 48
	hex 00 00



ent_ghost_update: subroutine

	; update logic
	dec ent_y,x
	lda ent_y,x
	cmp #$ef
	bne .no_despawn
	ent_despawn
	rts
.no_despawn

	; update anim
	inc ent_r3,x
	lda ent_r3,x
	cmp #$06
	bne .next_frame_done
.next_frame
	lda #$00
	sta ent_r3,x
	inc ent_r2,x
	lda ent_r2,x
	cmp #$03
	bne .next_frame_done
	lda #$00
	sta ent_r2,x
.next_frame_done


	; update sine counter
	clc
	lda ent_r0,x
	adc #$17
	sta ent_r0,x
	lda ent_r1,x
	adc #$02
	sta ent_r1,x
	; set x origin
	tay
	lda sine_table,y
	sta temp01
	shift_r 3
	adc ent_x,x
	sta temp00

	; set pattern table ptr
	lda #$00
	sta temp04 ; lut offset
	sta temp05 ; spr attr

	; check if centered
	lda temp01
	cmp #$03
	bcc .set_ghost_center
	cmp #$fd
	bcs .set_ghost_center
	lda ent_r1,x
	bpl .set_ghost_right
	bmi .set_ghost_left
.set_ghost_center
	lda <#ent_ghost_center
	sta temp02
	lda >#ent_ghost_center
	sta temp03
	jmp .set_ghost_done
.set_ghost_right
	lda ent_r2,x
	shift_l 3
	clc
	adc <#ent_ghost_right_0
	sta temp02
	lda >#ent_ghost_right_0
	adc #$00
	sta temp03
	lda #$40
	sta temp05
	jmp .set_ghost_done
.set_ghost_left
	lda ent_r2,x
	shift_l 3
	clc
	adc <#ent_ghost_left_0
	sta temp02
	lda >#ent_ghost_left_0
	adc #$00
	sta temp03
.set_ghost_done
	
	; setup collision
	lda temp00
	sta collision_1_x
	lda ent_y,x
	sta collision_1_y
	lda #$10
	sta collision_1_w
	lda #$18
	sta collision_1_h
	; palette rotate if hit
	jsr collision_detect
	beq .no_hit
	lda wtf
	shift_r 1
	and #$03
	ora temp05
	sta temp05
.no_hit

	; render (reload y?)
	ldy ent_spr_ptr

	; sprite 0
	lda temp00
	sta spr_x,y
	lda ent_y,x
	sta spr_y,y
	ldy temp04
	inc temp04
	lda (temp02),y
	ldy ent_spr_ptr
	sta spr_p,y
	lda #$00
	ora temp05
	sta spr_a,y
	inc_y 4
	sty ent_spr_ptr
	; sprite 1
	lda temp00
	clc
	adc #$08
	sta spr_x,y
	lda ent_y,x
	sta spr_y,y
	ldy temp04
	inc temp04
	lda (temp02),y
	ldy ent_spr_ptr
	sta spr_p,y
	lda #$00
	ora temp05
	sta spr_a,y
	inc_y 4
	sty ent_spr_ptr
	; sprite 2
	lda temp00
	sta spr_x,y
	lda ent_y,x
	clc
	adc #$08
	sta spr_y,y
	ldy temp04
	inc temp04
	lda (temp02),y
	ldy ent_spr_ptr
	sta spr_p,y
	lda #$00
	ora temp05
	sta spr_a,y
	inc_y 4
	sty ent_spr_ptr
	; sprite 3
	lda temp00
	clc
	adc #$08
	sta spr_x,y
	lda ent_y,x
	clc
	adc #$08
	sta spr_y,y
	ldy temp04
	inc temp04
	lda (temp02),y
	ldy ent_spr_ptr
	sta spr_p,y
	lda #$00
	ora temp05
	sta spr_a,y
	inc_y 4
	sty ent_spr_ptr
	; sprite 4
	lda temp00
	sta spr_x,y
	lda ent_y,x
	clc
	adc #$10
	sta spr_y,y
	ldy temp04
	inc temp04
	lda (temp02),y
	ldy ent_spr_ptr
	sta spr_p,y
	lda #$00
	ora temp05
	sta spr_a,y
	inc_y 4
	sty ent_spr_ptr
	; sprite 5
	lda temp00
	clc
	adc #$08
	sta spr_x,y
	lda ent_y,x
	clc
	adc #$10
	sta spr_y,y
	ldy temp04
	inc temp04
	lda (temp02),y
	ldy ent_spr_ptr
	sta spr_p,y
	lda #$00
	ora temp05
	sta spr_a,y
	inc_y 4
	sty ent_spr_ptr

	rts
