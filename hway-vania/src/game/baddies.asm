
baddies_min_slot  eqm #$00
baddies_max_slot  eqm #$10


baddies_find_slot: subroutine
	; returns empty slot in x
	; x = 0xff if none found
	ldx #baddies_min_slot
.loop
	lda ent_type,x
	beq .slot_found
	inx
	cpx #baddies_max_slot
	bne .loop
	ldx #$ff
.slot_found
	rts



baddies_update: subroutine
	; debug visualization on
	;lda #%00011111 ; b/w
	;lda #%11111110 ; emph
	;sta PPU_MASK

	lda ent_slot_start
	clc
	adc #$07
	and #$0f ; XXX hard coded
	sta ent_slot_start
	sta ent_slot

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
	and #$0f ; XXX hard coded
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
	lda #$0f ; XXX hard coded
	sta ent_slot
.dont_reset_ent_slot
	cmp ent_slot_start
	bne .update_backward_loop

.updates_done
	; debug visualization off
	;lda #%00011110
	;sta PPU_MASK
	rts
