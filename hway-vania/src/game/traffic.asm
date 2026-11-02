
; traffic slots, the slot range is the vehicle limit
traffic_min_slot     eqm $10
traffic_max_slot     eqm $20
traffic_slots        eqm traffic_max_slot-traffic_min_slot
traffic_spawn_frames eqm 20


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


; spawns, then updates every traffic slot from a rotating start
; the start rotates so cars past the sprite limit flicker instead of vanishing
traffic_update: subroutine
	lda traffic_spawn_timer
	beq .spawn
	dec traffic_spawn_timer
	bne .spawn_done
.spawn
	; a rejected spawn tries again next frame
	jsr ent_car_spawn
	bcc .spawn_done
	lda #traffic_spawn_frames
	sta traffic_spawn_timer
.spawn_done

	lda #$00
	sta traffic_oam_full
	lda traffic_rot
	clc
	adc #$07
	and #traffic_slots-1
	sta traffic_rot
	sta traffic_idx
	lda #traffic_slots
	sta traffic_count
.loop
	lda traffic_idx
	ora #traffic_min_slot
	sta ent_slot
	tax
	lda ent_type,x
	beq .next
	jsr ents_update_jump
	sty ent_spr_ptr
.next
	lda traffic_idx
	clc
	adc #$01
	and #traffic_slots-1
	sta traffic_idx
	dec traffic_count
	bne .loop
	rts
