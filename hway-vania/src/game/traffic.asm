
traffic_min_slot  eqm #$10
traffic_max_slot  eqm #$20


traffic_find_slot: subroutine
	; returns empty slot in x
	; x = 0xff if none found
	ldx #traffic_min_slot
.loop
	lda ent_type,x
	beq .slot_found
	inx
	cpx #traffic_max_slot
	bcc .loop
	ldx #$ff
.slot_found
	rts


traffic_update: subroutine
	; debug visualization on
	;lda #%00011111 ; b/w
	;lda #%11111110 ; emph
	;sta PPU_MASK
	
	ldx #traffic_min_slot
	stx ent_slot
.traffic_loop
	ldx ent_slot
	lda ent_type,x
	beq .skip_slot
	jsr ents_update_jump
	sty ent_spr_ptr
.skip_slot
	inc ent_slot
	lda ent_slot
	cpx #traffic_max_slot
	bcc .traffic_loop

	; debug visualization off
	;lda #%00011110
	;sta PPU_MASK
	rts
