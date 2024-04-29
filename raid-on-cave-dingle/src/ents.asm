
ent_type       eqm $0300
ent_direction  eqm $0301
ent_x_grid     eqm $0302
ent_y_grid     eqm $0303
ent_x_pos      eqm $0304
ent_y_pos      eqm $0305
ent_sub_travel eqm $0306
ent_speed      eqm $0307


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
	lda #$08
	clc
	adc ent_offset
	sta ent_offset
	lsr
	sta spr_offset
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
