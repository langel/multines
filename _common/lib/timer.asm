
timer_init: subroutine
	lda #$00
	sta timer_hours
	sta timer_minutes
	sta timer_seconds
	sta timer_frames
	rts


timer_update: subroutine
	; destroys x
.frames
	ldx #$00
	inc timer_frames
	lda timer_frames
	cmp #60
	beq .seconds
	rts
.seconds
	stx timer_frames
	inc timer_seconds
	lda timer_seconds
	cmp #60
	beq .minutes
	rts
.minutes
	stx timer_seconds
	inc timer_minutes
	lda .minutes
	cmp #60
	beq .hours
	rts
.hours
	stx timer_minutes
	inc timer_hours
	rts


timer_prerender: subroutine
	; temp00,01 pointer for output
	; temp02 number tiles offset
	; temp03 colon tile id
	; temp04 period tile id
	; destroys x and y
	ldy #$00

	ldx timer_hours
	lda zero_pad_10s_table,x
	clc
	adc temp02
	sta (temp00),y
	iny
	lda zero_pad_01s_table,x
	clc
	adc temp02
	sta (temp00),y
	iny
	lda temp03
	sta (temp00),y
	iny

	ldx timer_minutes
	lda zero_pad_10s_table,x
	clc
	adc temp02
	sta (temp00),y
	iny
	lda zero_pad_01s_table,x
	clc
	adc temp02
	sta (temp00),y
	iny
	lda temp03
	sta (temp00),y
	iny
	
	ldx timer_seconds
	lda zero_pad_10s_table,x
	clc
	adc temp02
	sta (temp00),y
	iny
	lda zero_pad_01s_table,x
	clc
	adc temp02
	sta (temp00),y
	iny
	lda temp04
	sta (temp00),y
	iny

	ldx timer_frames
	lda zero_pad_10s_table,x
	clc
	adc temp02
	sta (temp00),y
	iny
	lda zero_pad_01s_table,x
	clc
	adc temp02
	sta (temp00),y

	rts
