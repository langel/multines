
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
        
