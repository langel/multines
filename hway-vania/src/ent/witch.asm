
; ent_r0 sine counter
; ent_r1 directional offset


ent_witch_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_witch_id
	sta ent_type,x
.done
	jsr rng_update
	; set x
	;jmp .fly_right
	lda rng_val0
	and #$01
	bne .fly_right
.fly_left
	lda #$ff
	sta ent_x,x
	sta ent_r1,x
	jmp .fly_done
.fly_right
	lda #$ff
	sta ent_x_hi,x
	lda #$f0
	sta ent_x,x
	lda #$01
	sta ent_r1,x
.fly_done
	; set y
	lda rng_val1
	;shift_r 2
	;adc #84
	sta ent_y,x

	rts


ent_witch_update: subroutine

	; update logic
	lda ent_r1,x
	bmi .move_left
.move_right
	inc ent_x,x
	bne .move_done
	inc ent_x_hi,x
	lda ent_x_hi,x
	cmp #$01
	bne .move_done
	beq .despawn
.move_left
	sec
	lda ent_x,x
	sbc #$01
	sta ent_x,x
	lda ent_x_hi,x
	sbc #$00
	sta ent_x_hi,x
	cmp #$ff
	bne .move_done
	lda ent_x,x
	cmp #$f0
	bne .move_done
.despawn
	ent_despawn
.move_done

	; head x pos
	lda wtf
	shift_r 5
	and #$01
	sta temp00
	clc
	lda ent_r1,x
	bpl .head_right
.head_left
	lda temp00
	adc #$07
	sta temp00
	jmp .headx_done
.head_right
	lda temp00
	adc #$02
	sta temp00
.headx_done

	; y pos
	inc ent_r0,x
	inc ent_r0,x
	ldy ent_r0,x
	lda sine_table,y
	shift_r 4
	clc
	adc ent_y,x
	sta temp01

	; dir facing
	lda #$00
	sta temp03
	lda ent_r1,x
	bmi .facing_done
	lda #$40
	sta temp03
.facing_done

	; render
	ldy ent_spr_ptr

	lda ent_r1,x
	bmi witch_facing_left
	jmp witch_facing_right

witch_facing_left: subroutine
	; head
	clc
	lda ent_x,x
	adc temp00
	sta spr_x,y
	lda ent_x_hi,x
	adc #$00
	bne .head_done
	lda temp01
	sta spr_y,y
	lda #$0b
	sta spr_p,y
	lda #$01
	sta spr_a,y
	inc_y 4
.head_done
	; body left
	lda ent_x_hi,x
	bne .body_left_done
	lda ent_x,x
	sta spr_x,y
	lda temp01
	clc
	adc #$08
	sta spr_y,y
	lda #$1a
	sta spr_p,y
	lda #$01
	sta spr_a,y
	inc_y 4
.body_left_done
	; body right
	clc
	lda ent_x,x
	adc #$08
	sta spr_x,y
	lda ent_x_hi,x
	adc #$00
	bne .body_right_done
	lda temp01
	clc
	adc #$08
	sta spr_y,y
	lda #$1b
	sta spr_p,y
	lda #$01
	sta spr_a,y
	inc_y 4
.body_right_done
	; broom left
	lda ent_x_hi,x
	bne .broom_left_done
	lda ent_x,x
	sta spr_x,y
	lda temp01
	clc
	adc #$0a
	sta spr_y,y
	lda #$2a
	sta spr_p,y
	lda #$02
	sta spr_a,y
	inc_y 4
.broom_left_done
	; broom right
	clc
	lda ent_x,x
	adc #$08
	sta spr_x,y
	lda ent_x_hi,x
	adc #$00
	bne .broom_right_done
	lda temp01
	clc
	adc #$0a
	sta spr_y,y
	lda #$2b
	sta spr_p,y
	lda #$02
	sta spr_a,y
	inc_y 4
.broom_right_done

	rts


witch_facing_right: subroutine
	; head
	clc
	lda ent_x,x
	adc temp00
	sta spr_x,y
	lda ent_x_hi,x
	adc #$00
	bne .head_done
	lda temp01
	sta spr_y,y
	lda #$0b
	sta spr_p,y
	lda #$41
	sta spr_a,y
	inc_y 4
.head_done
	; body left
	lda ent_x_hi,x
	bne .body_left_done
	lda ent_x,x
	sta spr_x,y
	lda temp01
	clc
	adc #$08
	sta spr_y,y
	lda #$1b
	sta spr_p,y
	lda #$41
	sta spr_a,y
	inc_y 4
.body_left_done
	; body right
	clc
	lda ent_x,x
	adc #$08
	sta spr_x,y
	lda ent_x_hi,x
	adc #$00
	bne .body_right_done
	lda temp01
	clc
	adc #$08
	sta spr_y,y
	lda #$1a
	sta spr_p,y
	lda #$41
	sta spr_a,y
	inc_y 4
.body_right_done
	; broom left
	lda ent_x_hi,x
	bne .broom_left_done
	lda ent_x,x
	sta spr_x,y
	lda temp01
	clc
	adc #$0a
	sta spr_y,y
	lda #$2b
	sta spr_p,y
	lda #$42
	sta spr_a,y
	inc_y 4
.broom_left_done
	; broom right
	clc
	lda ent_x,x
	adc #$08
	sta spr_x,y
	lda ent_x_hi,x
	adc #$00
	bne .broom_right_done
	lda temp01
	clc
	adc #$0a
	sta spr_y,y
	lda #$2a
	sta spr_p,y
	lda #$42
	sta spr_a,y
	inc_y 4
.broom_right_done

	rts
