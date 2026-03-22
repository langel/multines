
game_palette:
	; bg
	hex 0f
	; til
	hex 15 00 31
	hex 15 18 28
	hex 15 08 18
	hex 15 0f 08
	; spr
	hex 02 11 38 ; player
	hex 0b 19 2a ; germ / broccoli
	hex 06 17 37 ; poop / bird leg
	hex 13 23 34 ; berries?


state_game_init: subroutine

	jsr render_disable

	ldx #state_game_render_id
	jsr state_set_render_routine
	ldx #state_game_update_id
	jsr state_set_update_routine

	lda #CTRL_8x16
	sta ppu_ctrl_ora

	; load palette
	ldx #$00
.pal_loop
	lda game_palette,x
	sta palette_cache,x
	inx
	cpx #25
	bne .pal_loop
	
	jsr ent_z_init

	jsr ent_player_init

/*
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
 */
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	/*
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn_in_gap
	jsr ent_food_spawn_in_gap
	jsr ent_food_spawn_in_gap
	jsr ent_food_spawn_in_gap
	*/
	jsr ent_food_spawn_in_gap
	jsr ent_food_spawn_in_gap
	jsr ent_food_spawn_in_gap
	jsr ent_food_spawn_in_gap
	jsr ent_gnat_spawn
	;jsr ent_poop_spawn
	;jsr ent_grub_spawn
	;jsr ent_eggs_spawn

	ldx game_level
	stx state07
.extra_germs
	jsr ent_germ_spawn
	ldx state07
	dex
	stx state07
	bpl .extra_germs


	; XXX level init should do this
	; create some tooth dirt
	lda #$00
.dirt_loop
	tax
	inc $600,x
	txa
	clc
	adc #$0b
	bcc .dirt_loop

	jsr teeth_init

	jsr teeth_init_playfield
	jsr hud_init
	
	jsr render_enable
	
	rts

