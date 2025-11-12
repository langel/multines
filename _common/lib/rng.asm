
rng_next subroutine
	lsr
	bcc .NoEor
	eor #$d4
.NoEor:
	rts


rng_prev subroutine
	asl
	bcc .NoEor
	eor #$a9
.NoEor:
	rts

rand: subroutine
	lda rng00
	lsr
	bcc .no_ex_or
	eor #$d4
.no_ex_or:
	sta rng00
	rts
        

; THESE ARE RIPPED FROM SMB2
rng_seed: subroutine
	lda #$86
	sta rng_seed0
	rts

rng_update: subroutine
	; destroys Y
	ldy #$00
	jsr rng_update_inner
	iny
rng_update_inner:
	lda rng_seed0
	asl
	asl
	sec
	adc rng_seed0
	sta rng_seed0
	asl rng_seed1
	lda #$20
	bit rng_seed1
	bcc rng_reverse
	beq rng_eor
	bne rng_inc_eor
rng_reverse:
	bne rng_eor
rng_inc_eor:
	inc rng_seed1
rng_eor:
	lda rng_seed1
	eor rng_seed0
	sta rng_val0,y
	rts
