


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
	sta mph

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

	; test decimal conversion
	lda mph
	sta temp00
	jsr decimal_tennis_0to99
	lda temp04
	sta $80
	clc
	adc #$f0
	sta $90
	sta spr_p,y
	lda #$00
	sta spr_a,y
	lda #$d0
	sta spr_x,y
	lda #$30
	sta spr_y,y
	inc_y 4
	lda temp05
	sta $81
	clc
	adc #$f0
	sta $91
	sta spr_p,y
	lda #$00
	sta spr_a,y
	lda #$d8
	sta spr_x,y
	lda #$30
	sta spr_y,y
	inc_y 4


	rts




decimal_tennis_0to99: subroutine
	; temp00 holds n
	; uses temp01-temp03
	; temp04 = tens results
	; temp05 = ones results

	lda #$00
	sta temp01 ; tens
	lda #$50
	sta temp02 ; subtrahend
	lda #$04
	sta temp03 ; loop counter
	lda temp00 ; n
.loop
	cmp temp02 ; subtrahend
	rol temp01 ; tens
	cmp temp02 ; subtrahend
	bcc .sub_10s_done
	sbc temp02 ; subtrahend
.sub_10s_done
	lsr temp02 ; subtrahend
	dec temp03
	bne .loop
	sta temp02 ; store n
	lda temp01 ; tens
	bne .blank_10s_done
	lda #$00 ; blank chr pattern
.blank_10s_done
	sta temp04 ; tens storage
	lda temp02 ; n result
	sta temp05 ; ones storage
	rts
