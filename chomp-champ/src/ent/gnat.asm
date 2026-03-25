
; ent_r1 y origin
; ent_r2 poop target
; ent_r3 state
;        b0000000x left or right
;        b000000x0 diving towards poop
;        b00000x00 on poop
;        b0000x000 return to flight
; ent_r4 on poop counter
; ent_r5 sine floatiness counter

gnat_direction  eqm $01
gnat_diving     eqm $02
gnat_on_poop    eqm $04
gnat_ascending  eqm $08

gnat_base_y     eqm $30

ent_gnat_spawn: subroutine
	jsr ent_find_slot
	bmi .done
	lda #ent_gnat_id
	sta ent_type,x
	; set direction
	lda rng_val0
	and #$01
	sta ent_r3,x
	bne .coming_from_left
.coming_from_right
	lda #$ff
	sta ent_x_hi,x
	lda #$f0
	sta ent_x,x
	jmp .dir_done
.coming_from_left
	lda #$02
	sta ent_x_hi,x
	lda #$00
	sta ent_x,x
.dir_done
	lda #gnat_base_y
	sta ent_r1,x
	; set top dog layer
	lda #$ff
	sta ent_r6,x
	sta ent_r7,x
.done
	rts



ent_gnat_update: subroutine

	; state behavours
	; #$02 diving
	; #$04 on poop - no x movement
	; #$08 ascending

	; x movement
	lda ent_r3,x
	and #$04
	bne .move_x_done
	; propel gnat forward
	lda ent_r3,x
	and #$01
	bne .move_right
.move_left
	dec ent_x,x
	lda ent_x,x
	cmp #$ff
	bne .left_not_next_screen
	dec ent_x_hi,x
.left_not_next_screen
	; check for turnaround
	lda ent_x_hi,x
	cmp #$ff
	bne .move_x_done
	lda ent_x,x
	cmp #$e0
	bne .move_x_done
	lda ent_r3,x
	ora #%00000001
	sta ent_r3,x
	jmp .move_x_done
.move_right
	inc ent_x,x
	bne .right_not_next_screen
	inc ent_x_hi,x
.right_not_next_screen
	; check for turnaround
	lda ent_x_hi,x
	cmp #$02
	bne .move_x_done
	lda ent_x,x
	cmp #$10
	bne .move_x_done
	lda ent_r3,x
	and #%11111110
	sta ent_r3,x
.move_x_done

	; looking for poops?
	lda ent_r3,x
	and #%11111110
	bne .poop_search_done
	ldy #$00
.poop_search_loop
	lda ent_type,y
	cmp #ent_poop_id
	bne .next_poop
.poop_to_check
	; x maths
	lda ent_r3,x
	and #gnat_direction
	bne .poop_x_right
.poop_x_left
	sec
	lda ent_x,x
	sbc ent_x,y
	sta temp00
	lda ent_x_hi,x
	sbc ent_x_hi,y
	bne .next_poop
	bmi .next_poop
	jmp .poop_y
.poop_x_right
	sec
	lda ent_x,y
	sbc ent_x,x
	sta temp00
	lda ent_x_hi,y
	sbc ent_x_hi,x
	bne .next_poop
	bmi .next_poop
.poop_y
	sec
	lda ent_y,y
	sbc ent_y,x
	; collision detect
	cmp temp00
	bne .next_poop
	; set poop target
	tya
	sta ent_r2,x
	lda ent_r3,x
	ora #%00000010
	sta ent_r3,x
	jmp .poop_search_done
.next_poop
	iny
	cpy #$20
	bne .poop_search_loop
.poop_search_done

	; check diving
	lda ent_r3,x
	and #%00000010
	beq .diving_done
	inc ent_r1,x
	ldy ent_r2,x
	lda ent_r1,x
	cmp ent_y,y
	bne .diving_done
	; setup next state
	lda ent_r3,x
	and #%00000001
	ora #%00000100
	sta ent_r3,x
	lda #$80
	sta ent_r4,x
	lda ent_r1,x
	sec
	sbc #$02
	sta ent_r1,x
.diving_done

	; check on poop
	lda ent_r3,x
	and #%00000100
	beq .on_poop_done
	; check poop is still there
	ldy ent_r2,x
	lda ent_type,y
	cmp #ent_poop_id
	bne .on_poop_next_state
	; check timer
	dec ent_r4,x
	bne .on_poop_done
.poop_becomes_eggs
	lda ent_r2,x
	jsr ent_eggs_spawn_from_poop
.on_poop_next_state
	; setup next state
	lda ent_r3,x
	and #%00000001
	ora #%00001000
	sta ent_r3,x
	lda #$00
	sta ent_r5,x
.on_poop_done

	; check ascending
	lda ent_r3,x
	and #%00001000
	beq .ascending_done
	dec ent_r1,x
	lda ent_r1,x
	cmp #gnat_base_y
	bne .ascending_done
	; setup next state
	lda ent_r3,x
	and #%00000001
	sta ent_r3,x
.ascending_done

	; y floatiness
	lda ent_r3,x
	and #gnat_on_poop
	bne .poop_dance
.y_sine
	inc ent_r5,x
	ldy ent_r5,x
	lda sine_table,y
	shift_r 6
	clc
	adc ent_r1,x
	sta ent_y,x
	jmp .y_float_done
.poop_dance
	lda wtf
	shift_r 2
	and #$01
	bne .y_float_done
	jsr rng_update
	lda rng_val1
	and #$03
	sta temp00
	lda ent_r1,x
	sec
	sbc temp00
	sta ent_y,x
.y_float_done

	lda ent_y,x
	clc
	adc #$16
	ent_z_calc_sort_vals_9bit
	



ent_gnat_render: subroutine
	ldy ent_spr_ptr
	; RENDER
	jsr ent_calc_position
	; metasprite
	lda wtf
	lsr
	and #$01
	asl
	asl
	clc
	adc #$98
	sta temp00
	; attr
	lda ent_r3,x
	and #%00000001
	eor #%00000001
	shift_l 6
	ora #$03
	sta temp01
	jsr ent_render_generic_8x16

	jmp ent_z_update_return

