

ent_random_spawn_pos: subroutine
.reroll
	jsr rng_update
	; x
	lda rng_val0
	rol
	sta ent_x,x
	lda #$00
	rol
	sta ent_x_hi,x
	; keep x <= $01f0
	lda ent_x_hi,x
	beq .x_ok
	lda ent_x,x
	cmp #$f1
	bcs .reroll
.x_ok
	; y
	lda rng_val1
	lsr
	adc #$40
	sta ent_y,x
	rts



ent_sully_cell: subroutine
	; dirt some tooth
	; y = amount of dirt
	; (ent_x / 16) 
	; +
	; ((ent_y / 16) * 32)
	lda ent_x_hi,x
	lsr
	lda ent_x,x
	ror
	clc
	adc #$02
	shift_r 3
	sta temp00
	lda ent_y,x
	sec
	sbc #$33
	cmp #$80
	bcc .y_post_sub_ok
	lda #$7f
.y_post_sub_ok
	shift_r 4
	shift_l 5
	clc
	adc temp00
	sta temp01
	; check tooth is present
	tax
	lda tooth_cell2tooth,x
	tax
	lda tooth_total_dmg,x
	; check tooth is missing
	bmi .skip_cell_dmg
	; check tooth is truly clean
	lda tooth_true_clean,x
	beq .tooth_can_be_dirtied
	ldy ent_slot
	lda ent_type,y
	cmp #ent_poop_id
	bne .skip_cell_dmg
.tooth_can_be_dirtied
	; increase tooth damage
	; but it maxes it
	ldx temp01
	tya
	adc $600,x
	cmp #$0f
	bcc .dont_fix_dmg
	lda #$0f
.dont_fix_dmg
	sta $600,x
	; add tooth cell to update queue
	txa
	ldx tooth_update_queue_size
	sta tooth_needs_update,x
	inc tooth_update_queue_size
	; log tooth change
.skip_cell_dmg
	ldx ent_slot
	rts
