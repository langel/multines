
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
	sta ents_offset
	sta sprite_offset
.ent_loop
	ldx ents_offset
	ldy $0303,x
	jsr ent_method
.next_slop
	lda #$08
	clc
	adc ents_offset
	sta ents_offset
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
