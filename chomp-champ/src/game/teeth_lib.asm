
; to do
;	update teeth dmg and dirt tiles when loading level

teeth_init: subroutine
	; called after fresh playfield is drawn
	; requires dirt populated in cells
	; adds up total_dmg for each tooth
	; renders all dirt on playfield
	ldx #$00
	stx tooth_index
.each_tooth
	; total dmg and render cells
	lda #$00
	sta temp00 ; dmg

	; render gumline

	; next tooth
	inc tooth_index
	ldx tooth_index
	cpx #$10
	bne .each_tooth
	rts


; xxx need to check for:
;	game over (all teeth gone)
;  level complete (all teeth are clean or gone)
teeth_update: subroutine
	; adds up dirt value of all 16 cells of tooth_index based on frame counter
	; temp00 = addend
	; temp02 = eol
	; destroys x+y
	ldx tooth_index
.next_tooth
	inx
	cpx #$10
	bne .dont_wrap
	ldx #$00
.dont_wrap
	lda tooth_total_dmg,x
	; xxx this bricks
	;beq .next_tooth
	bmi .next_tooth
	stx tooth_index
	; update dmg count
	txa
	shift_l 4
	tax
	clc
	adc #$10
	sta temp02
	clc
	lda #$00
	sta temp00
.tooth_loop
	lda teeth_cell_tables,x
	tay
	lda $600,y
	adc temp00
	sta temp00
	inx
	cpx temp02
	bne .tooth_loop
	ldx tooth_index
	sta tooth_total_dmg,x
.tooth_lost
	rts


; xxx no longer in use
tooth_health_update: subroutine
	; a = tooth id
	; temp00 = addend
	; temp01 = tooth_id
	; destroys x+y
	sta temp01
	shift_l 4
	tax
	ldy #$10
	clc
	lda #$00
	sta temp00
.tooth_loop
	lda tooth_cell_dmg,x
	adc temp00
	sta temp00
	inx 
	dey
	bne .tooth_loop
	ldx temp01
	sta tooth_total_dmg,x
	rts
