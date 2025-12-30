
; to do
;	render system for dirt tiles
;  queue system for render system


teeth_update: subroutine
	; adds up dirt value of all 16 cells of tooth_id based on frame counter
	; temp00 = addend
	; temp01 = tooth_id
	; temp02 = eol
	; destroys x+y
	lda wtf
	and #$0f
	sta tooth_index
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
	rts


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
