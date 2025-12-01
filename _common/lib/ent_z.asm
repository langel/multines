

ent_z_sortup    eqm $00a0
ent_z_sortdown  eqm $00c0


ent_z_clear_sorts: subroutine
	lda #$00
	ldx #$1f
.loop
	sta ent_z_sortup,x
	sta ent_z_sortdown,x
	dex
	bpl .loop
	rts


ent_z_update: subroutine
	; ents update
	ldx #$00
	ldy #$00
	sta ent_spr_ptr
.ent_update_loop
	stx ent_slot
	lda ent_type,x
	beq .ent_update_next
	tay
	lda ent_update_lo,y
	sta temp00
	lda ent_update_hi,y
	sta temp01
	jmp (temp00)
ent_z_update_return:
	sty ent_spr_ptr
.ent_update_next
	inx
	cpx #ents_max
	bne .ent_update_loop
	; check for despawn in update
	lda ent_type,x
;	beq .ent_update_next
.ent_update_sort
	rts


	MAC ent_z_calc_sort_vals
	; call with z pos in a
	sec
	sbc #$20 ; magic number?
	sta temp00
	lda ent_x,x ; y + (x / 4)
	lsr
	lsr
	sta temp01
	clc
	adc temp00
	sta ent_r6,x
	lda ent_x,x ; y - (x / 4)
	lsr
	lsr
	sta temp01
	lda temp00
	sec
	sbc temp01
	sta ent_r7,x
	ENDM
