

ent_random_spawn_pos: subroutine
.reroll
	lda #$00
	sta ent_x_hi,x
	jsr rng_update
	lda rng_val0
	rol
	sta ent_x,x
	bcc .not_nm2
	cmp #$f0
	bcs .reroll
	lda #$01
	sta ent_x_hi,x
.not_nm2
	lda rng_val1
	cmp #$b0
	bcs .reroll
	cmp #$40
	bcc .reroll
	sta ent_y,x
	rts
