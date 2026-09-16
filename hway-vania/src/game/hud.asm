


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
	jsr decimal_tennis_0to99
	lda temp00
	beq .tennis_no_tens
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
.tennis_no_tens
	lda temp01
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
	; kills x
	; a = value 00..99
	; RETURNS
	; temp00 = tens
	; temp01 = ones
	ldx #$00
	stx temp00 ; tens
	ldx #$50
	stx temp01 ; subtrahend
	ldx #$04
.loop
	cmp temp01 
	rol temp00 
	cmp temp01 
	bcc .sub_10s_done
	sbc temp01 
.sub_10s_done
	lsr temp01 
	dex
	bne .loop
	sta temp01 ; store ones
	rts
