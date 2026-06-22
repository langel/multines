
; OG RNG ROUTINE FROM 8BWorkshop
rng_next subroutine
	lsr
	bcc .no_eor
	eor #$d4
.no_eor:
	rts


rng_prev subroutine
	asl
	bcc .no_eor
	eor #$a9
.no_eor:
	rts




; THESE ARE RIPPED FROM SMB2
rng_seed: subroutine
	lda #$86
	sta rng_seed0
	rts


rng_update: subroutine
	; this was a 2 cycle loop using
	; the y register so now that 
	; loop is unrolled to preserve y

rng_update_val0:
	lda rng_seed0
	asl
	asl
	sec
	adc rng_seed0
	sta rng_seed0
	asl rng_seed1
	lda #$20
	bit rng_seed1
	bcc rng_reverse_val0
	beq rng_eor_val0
	bne rng_inc_eor_val0
rng_reverse_val0:
	bne rng_eor_val0
rng_inc_eor_val0:
	inc rng_seed1
rng_eor_val0:
	lda rng_seed1
	eor rng_seed0
	sta rng_val0

rng_update_val1:
	lda rng_seed0
	asl
	asl
	sec
	adc rng_seed0
	sta rng_seed0
	asl rng_seed1
	lda #$20
	bit rng_seed1
	bcc rng_reverse_val1
	beq rng_eor_val1
	bne rng_inc_eor_val1
rng_reverse_val1:
	bne rng_eor_val1
rng_inc_eor_val1:
	inc rng_seed1
rng_eor_val1:
	lda rng_seed1
	eor rng_seed0
	sta rng_val1

rng_update_done
	rts
