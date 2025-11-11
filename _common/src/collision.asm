

collision_detect: subroutine
	; returns true/false in a
	clc
	lda collision_0_x
	adc collision_0_w
	bcs .no_collision ; make sure x+w is not less than x
	cmp collision_1_x
	bcc .no_collision
	clc
	lda collision_1_x
	adc collision_1_w
	cmp collision_0_x
	bcc .no_collision
	clc
	lda collision_0_y
	adc collision_0_h
	cmp collision_1_y
	bcc .no_collision
	clc 
	lda collision_1_y
	adc collision_1_h
	cmp collision_0_y
	bcc .no_collision
.collision
	lda #$ff
	rts
.no_collision
	lda #$00
	rts


