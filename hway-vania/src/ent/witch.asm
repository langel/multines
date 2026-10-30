; ent_r0 state
;  0 = flying
;  1 = spinning
;  2 = on road

; flaying state:
; ent_r1 sine counter
; ent_r2 directional offset

; spinning state:
; ent_r1 spin frame
; ent_r2 spin counter
; ent_r3 y vel lo
; ent r4 x vel hi

; on road state:

; ent_r6 y vel lo
; ent r7 x vel hi


ent_witch_spawn: subroutine
	jsr baddies_find_slot
	bmi .done
	lda #ent_witch_id
	sta ent_type,x
.done
	
	; xxx temp witch death spawn
witch_init_spinning_state: subroutine
	lda #$78
	sta ent_x,x
	lda #$78
	sta ent_y,x
	lda #$01
	sta ent_r0,x
	lda #$00
	sta ent_r1,x
	sta ent_r2,x
	; xxx set initial velocity
	rts

	jsr rng_update
	; set x
	;jmp .fly_right
	lda rng_val0
	and #$01
	bne .fly_right
.fly_left
	lda #$ff
	sta ent_x,x
	sta ent_r2,x
	jmp .fly_done
.fly_right
	lda #$ff
	sta ent_x_hi,x
	lda #$f0
	sta ent_x,x
	lda #$01
	sta ent_r2,x
.fly_done
	; set y
	lda rng_val1
	;shift_r 2
	;adc #84
	sta ent_y,x

	rts


ent_witch_update: subroutine

	; check state
	lda ent_r0,x
	bne .not_flying
	jmp witch_flying_by
.not_flying
	cmp #$01
	bne .not_spinning
	jmp witch_spinning
.not_spinning
	jmp witch_on_road


witch_spinning:
	; spin animation
	inc ent_r2,x
	lda ent_r2,x
	cmp #$04
	bne .next_frame_done
	lda #$00
	sta ent_r2,x
	inc ent_r1,x
	lda ent_r1,x
	cmp #$10
	bne .next_frame_done
	and #$00
	sta ent_r1,x
.next_frame_done
	; render
	lda ent_r1,x
	tay
	lda witch_spin_patterns,y
	sta temp00
	lda witch_spin_attributes,y
	sta temp01
	lda ent_x,x
	sta temp02
	lda ent_y,x
	sta temp03
	ldy ent_spr_ptr
	jsr sprite_4_render
	rts
witch_spin_patterns:
	hex 66 68 6a 6c 6e
	hex 6c 6a 68 66
	hex 68 6a 6c 6e
	hex 6c 6a 68 
witch_spin_attributes:
	hex 01 01 01 01 01
	hex 81 81 81 81
	hex c1 c1 c1 c1
	hex 41 41 41

witch_on_road:
	rts

witch_flying_by:

	; update logic
	lda ent_r2,x
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
	rts
.move_done

	; head x pos
	lda wtf
	shift_r 5
	and #$01
	sta temp00
	lda #$00
	sta temp00
	lda ent_r1,x
	bmi .check_headx
	inc temp00
.check_headx
	clc
	lda ent_r2,x
	bpl .headx_done
.headx_left
	lda temp00
	eor #$01
	adc #$07
	sta temp00
	jmp .headx_done
.headx_done

	; y pos
	inc ent_r1,x
	inc ent_r1,x
	ldy ent_r1,x
	lda sine_table,y
	shift_r 4
	clc
	adc ent_y,x
	sta temp01

	; dir facing
	lda #$00
	sta temp03
	lda ent_r2,x
	bmi .facing_done
	lda #$40
	sta temp03
.facing_done

	; render flying
	ldy ent_spr_ptr
	
	lda ent_r2,x
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
	clc
	lda ent_x,x
	adc #$01
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
	adc #$09
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
	sec
	lda ent_x,x
	sbc #$01
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
	adc #$07
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



