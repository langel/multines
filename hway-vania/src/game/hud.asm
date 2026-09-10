


game_hud_update: subroutine

	lda speed_hi
	bpl .speed_ready
	eor #$ff
	sta temp00
	lda speed_lo
	eor #$ff
	sta temp01
.speed_ready

	lda speed_lo
	eor #$ff
	sta temp00
	lda speed_hi
	eor #$ff
	sta temp01
	lda #$05
	sta temp02
	jsr shift_divide_7_into_16

	lda temp00
	sta $0361

	; tens
	ldx temp00
	lda zero_pad_01s_table,x
	clc
	adc #$f0
	sta spr_p,y
	lda #$00
	sta spr_a,y
	lda #$c0
	sta spr_x,y
	lda #$20
	sta spr_y,y
	inc_y 4
	
	; lesser number
	lda temp00
	shift_r 1
	tax
	lda zero_pad_10s_table,x
	clc
	adc #$f0
	sta spr_p,y
	lda #$00
	sta spr_a,y
	lda #$c8
	sta spr_x,y
	lda #$20
	sta spr_y,y
	inc_y 4
	
	; MPH
	lda #$fa
	sta spr_p,y
	lda #$00
	sta spr_a,y
	lda #$d0
	sta spr_x,y
	lda #$20
	sta spr_y,y
	inc_y 4
	lda #$fb
	sta spr_p,y
	lda #$00
	sta spr_a,y
	lda #$d8
	sta spr_x,y
	lda #$20
	sta spr_y,y
	inc_y 4

	rts
