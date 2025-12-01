

ent_z_sortup    eqm $00a0
ent_z_sortdown  eqm $00c0


ent_z_init: subroutine
	ldy #$00
	tax
.loop
	stx ent_z_sortup,y
	stx ent_z_sortdown,y
	inx
	iny
	cpy #ents_max+1
	bne .loop
	rts


ent_z_update: subroutine
	; ents update
	ldx #$00
.ent_update_loop
	stx ent_slot
	lda ent_type,x
	beq .ent_update_next
	tay
	lda ent_update_lo,y
	sta temp00
	lda ent_update_hi,y
	sta temp01
	ldy ent_spr_ptr
	jmp (temp00)
ent_z_update_return:
.ent_update_next
	inx
	cpx #ents_max+1
	bne .ent_update_loop
	; sortup
	ldy #$00
.sortup_loop
	lda ent_z_sortup,y
	tax
	lda ent_r6,x
	sta temp00
	lda ent_z_sortup+1,y
	tax
	lda ent_r6,x
	sta temp01
	cmp temp00
	bcc .sortup_lesser
.sortup_greater
	lda ent_z_sortup,y
	ldx ent_z_sortup+1,y
	sta ent_z_sortup+1,y
	txa
	sta ent_z_sortup,y
.sortup_lesser
.sortup_loop_end
	iny
	cpy #ents_max
	bne .sortup_loop
	; sortdown
	ldy #$00
.sortdown_loop
	lda ent_z_sortdown,y
	tax
	lda ent_r7,x
	sta temp00
	lda ent_z_sortdown+1,y
	tax
	lda ent_r7,x
	sta temp01
	cmp temp00
	bcc .sortdown_lesser
.sortdown_greater
	lda ent_z_sortdown,y
	ldx ent_z_sortdown+1,y
	sta ent_z_sortdown+1,y
	txa
	sta ent_z_sortdown,y
.sortdown_lesser
.sortdown_loop_end
	iny
	cpy #ents_max
	bne .sortdown_loop

	; ents render
	ldx #$00
	stx ent_z_slot
	ldy #$00
	sty ent_spr_ptr
.sort_direction
	lda wtf
	lsr
	and #$01
	shift_l 5
	clc
	adc #$a0
	sta ent_z_ptr_lo
.ent_render_loop
	ldy ent_z_slot
	lda (ent_z_ptr_lo),y
	tax
	stx ent_slot
	lda ent_type,x
	beq .ent_render_next
	tay
	lda ent_render_lo,y
	sta temp00
	lda ent_render_hi,y
	sta temp01
	ldy ent_spr_ptr
	jmp (temp00)
ent_z_render_return:
	sty ent_spr_ptr
.ent_render_next
	inc ent_z_slot
	ldx ent_z_slot
	cpx #ents_max-12
	bne .ent_render_loop



	; clear remaining sprites
	lda #$ff
.sprite_clear_loop
	cpy #$00
	beq .sprite_clear_done
	sta OAM_RAM,y
	inc_y 4
	jmp .sprite_clear_loop
.sprite_clear_done
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
