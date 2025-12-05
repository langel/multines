
ents_max   eqm #$1f

ent_type   eqm $0400
ent_hp     eqm $0420
ent_x_hi   eqm $0440
ent_x      eqm $0460
ent_x_lo   eqm $0480
ent_y_hi   eqm $04a0
ent_y      eqm $04c0
ent_y_lo   eqm $04e0
ent_r0     eqm $0500
ent_r1     eqm $0520
ent_r2     eqm $0540
ent_r3     eqm $0560
ent_r4     eqm $0580
ent_r5     eqm $05a0
ent_r6     eqm $05c0
ent_r7     eqm $05e0


ent_find_slot: subroutine
	; returns empty slot in x
	; x = 0xff if none found
	ldx #$00
.loop
	lda ent_type,x
	beq .slot_found
	inx
	cpx #ents_max+1
	bne .loop
	ldx #$ff
.slot_found
	rts



ents_update: subroutine
	; debug visualization on
	;lda #%00011111 ; b/w
	;lda #%11111110 ; emph
	;sta PPU_MASK

	; don't corrupt y in ent render functions
	ldy #$00
	sty ent_spr_ptr

	lda ent_slot_start
	clc
	adc #$07
	and #$1f
	sta ent_slot_start
	sta ent_slot

	; sprites_clear
	lda #$ff
	ldx #$00
.loop
	sta $0200,x
	inx
	inx
	inx
	inx
	bne .loop

	lda wtf
	lsr
	and #$01
	beq .update_forward_loop
	bne .update_backward_loop

.update_forward_loop
	ldx ent_slot
	lda ent_type,x
	beq .skip_forward_ent_slot
	jsr ents_update_jump
	sty ent_spr_ptr
.skip_forward_ent_slot
	inc ent_slot
	lda ent_slot
	and #ents_max
	sta ent_slot
	cmp ent_slot_start
	bne .update_forward_loop
	jmp .updates_done

.update_backward_loop
	ldx ent_slot
	lda ent_type,x
	beq .skip_backward_ent_slot
	jsr ents_update_jump
	sty ent_spr_ptr
.skip_backward_ent_slot
	dec ent_slot
	lda ent_slot
	bpl .dont_reset_ent_slot
	lda #ents_max
	sta ent_slot
.dont_reset_ent_slot
	cmp ent_slot_start
	bne .update_backward_loop

.updates_done
	; debug visualization off
	;lda #%00011110
	;sta PPU_MASK
	rts


ents_update_jump: subroutine
	tax
	lda ent_update_lo,x
	sta temp00
	lda ent_update_hi,x
	sta temp01
	ldx ent_slot
	ldy ent_spr_ptr
	jmp (temp00)
	


	MAC ent_despawn
	lda #$00
	sta ent_type,x
	sta ent_hp,x
	sta ent_x_hi,x
	sta ent_x,x
	sta ent_x_lo,x
	sta ent_y_hi,x
	sta ent_y,x
	sta ent_y_lo,x
	sta ent_r0,x
	sta ent_r1,x
	sta ent_r2,x
	sta ent_r3,x
	sta ent_r4,x
	sta ent_r5,x
	sta ent_r6,x
	sta ent_r7,x
	ENDM


ent_calc_position: subroutine
	; calculate ent screen position and size
	; accounts for sprite columns off screen
	; sets up collision_0 with ent data
	; reset visibility
	lda #$00
	sta ent_visible
	; check y position
	lda ent_y,x
	sta collision_0_y
	cmp #240 ; screen height
	bcc .y_safe
	cmp #$f0
	bcs .y_safe
	rts
.y_safe
	; check x columns
	sec
	lda ent_x,x
	sbc scroll_x
	sta collision_0_x
	lda ent_x_hi,x
	sbc scroll_x_hi
	beq .left_visible
	cmp #$ff
	bne .left_done
	lda collision_0_x
	cmp #$f8
	bcs .right_visible
	bcc .left_done
.left_visible
	lda ent_visible
	ora #$01
	sta ent_visible
	lda collision_0_x
	cmp #$f8
	bcc .right_visible
	bcs .left_done
.right_visible
	lda ent_visible
	ora #$02
	sta ent_visible
.left_done
	lda ent_visible
	beq .collision_done
	and #$03
	cmp #$03
	beq .collision_full
.check_left
	cmp #$01
	bne .check_right
	sec
	lda #$ff
	sbc collision_0_x
	sta collision_0_w
	lda #$08
	sta collision_0_h
	rts
.check_right
	clc
	lda collision_0_x
	adc #$10
	sta collision_0_w
	lda #$08
	sta collision_0_h
	rts
.collision_full
	; XXX not checking for y off screen
	lda #$10
	sta collision_0_w
	sta collision_0_h
.collision_done
	rts


ent_render_generic: subroutine
	; temp00 sprite base id
	; temp01 attribute value
	; needs to check for y
ent_render_generic_left:
.left
	lda ent_visible
	and #$01
	beq .left_done
.left_x
	lda collision_0_x
	sta spr_x+$00,y
	sta spr_x+$04,y
.left_y
	lda collision_0_y
	sta spr_y+$00,y
	clc
	adc #$08
	sta spr_y+$04,y
	; sprite mirror check
	lda temp01
	and #$40
	bne .left_pite_mirror
.left_pite
	lda temp00
	sta spr_p+$00,y
	clc
	adc #$10
	sta spr_p+$04,y
	jmp .left_pite_done
.left_pite_mirror
	lda temp00
	clc
	adc #$01
	sta spr_p+$00,y
	clc
	adc #$10
	sta spr_p+$04,y
.left_pite_done
.left_aribute
	lda temp01
	sta spr_a+$00,y
	sta spr_a+$04,y
.left_increment_p_ptr
	tya
	clc
	adc #$08
	tay
.left_done
.right
	lda ent_visible
	and #$02
	beq .done
.right_x
	lda collision_0_x
	clc
	adc #$08
	sta spr_x+$00,y
	sta spr_x+$04,y
.right_y
	lda collision_0_y
	sta spr_y+$00,y
	clc
	adc #$08
	sta spr_y+$04,y
	; sprite mirror check
	lda temp01
	and #%01000000
	bne .right_pite_mirror
.right_pite
	lda temp00
	clc
	adc #$01
	sta spr_p+$00,y
	adc #$10
	sta spr_p+$04,y
	jmp .right_pite_done
.right_pite_mirror
	lda temp00
	sta spr_p+$00,y
	adc #$10
	sta spr_p+$04,y
.right_pite_done
.right_aribute
	lda temp01
	sta spr_a+$00,y
	sta spr_a+$04,y
.right_increment_p_ptr
	tya
	clc
	adc #$08
	tay
.done
	rts


ent_render_generic_8x16: subroutine
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
	; sprite mirror check
	lda temp01
	and #$40
	bne .left_sprite_mirror
.left_sprite
	lda temp00
	sta spr_p,y
	jmp .left_sprite_done
.left_sprite_mirror
	lda temp00
	clc
	adc #$02
	sta spr_p,y
.left_sprite_done
.left_aribute
	lda temp01
	sta spr_a+$00,y
.left_increment_p_ptr
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
	; sprite mirror check
	lda temp01
	and #%01000000
	bne .right_sprite_mirror
.right_sprite
	lda temp00
	clc
	adc #$02
	sta spr_p,y
	jmp .right_sprite_done
.right_sprite_mirror
	lda temp00
	sta spr_p,y
.right_sprite_done
.right_aribute
	lda temp01
	sta spr_a,y
.right_increment_p_ptr
	inc_y 4
.done
	rts
