
score_add_4_bytes: subroutine
	; big endian
	; temp00..03 score increas
	; max: 99,999,999
.ones
	lda score03
	clc
	adc temp03
	cmp #100
	bcc .ones_no_carry
	inc score02
	sbc #100
.ones_no_carry
	sta score03
.hundreds
	lda score02
	clc
	adc temp02
	cmp #100
	bcc .hundreds_no_carry
	inc score01
	sbc #100
.hundreds_no_carry
	sta score02
.thousands
	lda score01
	clc
	adc temp01
	cmp #100
	bcc .thousands_no_carry
	inc score00
	sbc #100
.thousands_no_carry
	sta score01
.millions
	lda score00
	clc
	adc temp00
	cmp #100
	bcc .millions_no_carry
	lda #99
	sta score03
	sta score02
	sta score01
.millions_no_carry
	sta score00
	rts
