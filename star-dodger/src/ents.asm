
ent_type       eqm $0300
ent_xp_hi      eqm $0320
ent_xp_lo      eqm $0340
ent_xv_hi      eqm $0360
ent_xv_lo      eqm $0380
ent_yp_hi      eqm $03a0
ent_yp_lo      eqm $03c0
ent_yv_hi      eqm $03e0
ent_yv_lo      eqm $0400


ents_clear: subroutine
	ldx #$00
	txa
.loop
	sta $0300,x
	inx
	bne .loop
	rts



ents_update: subroutine
	lda #$00
	sta ent_offset
	sta spr_offset
.ent_loop
	ldx ent_offset
	ldy ent_type,x
	jsr ent_method
.next_slop
	inc ent_offset
	lda ent_offset
	cmp #$20
	bne .ent_loop
	rts


ent_methods_lo:
	byte #<do_nothing
	byte #<ent_dingle_update
ent_methods_hi:
	byte #>do_nothing
	byte #>ent_dingle_update

ent_method: subroutine
	lda ent_methods_lo,y
	sta temp00
	lda ent_methods_hi,y
	sta temp01
	jmp (temp00)
