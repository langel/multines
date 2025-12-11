
; to do
;	render system for dirt tiles
;  queue system for render system


tooth_update: subroutine
	; adds up dirt value of all 16 cells
	; temp00 = accumulator
	; temp01 = tooth id
	; temp02 = eol
	lda wtf
	and #$0f
	sta temp01
	shift_l 4
	tax
	clc
	adc #$10
	sta temp02
	clc
	lda #$00
	sta temp00
.tooth_loop
	lda tooth_cell_tables,x
	tay
	lda $600,y
	adc temp00
	sta temp00
	inx
	cpx temp02
	bne .tooth_loop
	ldx temp01
	sta tooth_health_0,x
	rts
