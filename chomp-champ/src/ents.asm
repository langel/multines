ent_nothing_id     eqm #$00
ent_big_teef_id    eqm #$01
ent_food_id        eqm #$02
ent_germ_id        eqm #$03
ent_poop_id        eqm #$04


ent_update_lo:
	byte <do_nothing
	byte <ent_big_teef_update
	byte <ent_food_update
	byte <ent_germ_update
	byte <ent_poop_update
ent_update_hi:
	byte >do_nothing
	byte >ent_big_teef_update
	byte >ent_food_update
	byte >ent_germ_update
	byte >ent_poop_update


ent_random_spawn_pos: subroutine
.reroll
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
	cmp #$d0
	bcs .reroll
	cmp #$30
	bcc .reroll
	sta ent_y,x
	rts
