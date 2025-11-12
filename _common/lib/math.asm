

shift_divide_7_into_8: subroutine
	; temp00 dividend
	; temp01 divisor
	; RETURNS
	; A = remainder
	; temp00 = result
	; temp01 = remainder
	ldx #$08
	lda #$00
	clc
.loop
	asl temp00
	rol 
	cmp temp01
	bcc .no_sub
	sbc temp01
	inc temp00
.no_sub
	dex
	bne .loop
	sta temp01
	rts


shift_divide_7_into_16: subroutine
	; temp00 dividend lo
	; temp01 dividend hi
	; temp02 divisor
	; RETURNS
	; A = remainder
	; temp00 = result
	; temp01 = remainder
	ldx #16
	lda #0
.loop
	asl temp00
	rol temp01
	rol 
	cmp temp02
	bcc .no_sub
	sbc temp02
	inc temp00
.no_sub
	dex
	bne .loop
	sta temp01
	rts


shift_divide_15_into_16: subroutine
	; temp00 = dividend lo
	; temp01 = dividend hi
	; temp02 = divisor lo
	; temp03 = divisor hi
	; RETURNS
	; temp00 = result (lo only)
	; temp04 = remainder lo
	; temp05 = remainder hi

	lda #0	        ; zero out remainder
	sta temp04
	sta temp05
	ldx #16	        

.loop	
	asl temp00	
	rol temp01	
	rol temp04	
	rol temp05
	lda temp04
	sec
	sbc temp02	; check if divisor fits
	tay	       
	lda temp05
	sbc temp03
	bcc .skip	
	sta temp05	
	sty temp04	
	inc temp00	; XXX could add result hi byte 
.skip	
	dex
	bne .loop	
	rts


shift_multiply: subroutine
	; shift + add multiplication
	; temp00, temp01 in = factors
	; returns little endian 16bit val
	;         at temp01, temp00
	lda #$00
	ldx #$08
	lsr temp00
.loop
	bcc .no_add
	clc
	adc temp01
.no_add
	ror
	ror temp00
	dex
	bne .loop
	sta temp01
	rts        


shift_sine: subroutine
	; returns scaled value of sine table
	; a = sine max
	; x = sine pos
	eor #$ff
	sta temp00
	lda #$00
	lsr temp00
	bcs .no_bit_1
	adc sine_table_bit_1,x
.no_bit_1
	lsr temp00
	bcs .no_bit_2
	adc sine_table_bit_2,x
.no_bit_2
	lsr temp00
	bcs .no_bit_3
	adc sine_table_bit_3,x
.no_bit_3
	lsr temp00
	bcs .no_bit_4
	adc sine_table_bit_4,x
.no_bit_4
	lsr temp00
	bcs .no_bit_5
	adc sine_table_bit_5,x
.no_bit_5
	lsr temp00
	bcs .no_bit_6
	adc sine_table_bit_6,x
.no_bit_6
	lsr temp00
	bcs .no_bit_7
	adc sine_table_bit_7,x
.no_bit_7
	lsr temp00
	bcs .no_bit_8
	adc sine_table_bit_8,x
.no_bit_8
	rts



