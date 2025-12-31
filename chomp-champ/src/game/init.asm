
game_palette:
	; bg
	hex 0f
	; til
	hex 15 0c 31
	hex 15 0c 28
	hex 15 0c 18
	hex 15 0c 08
	; spr
	hex 02 11 38 ; player
	hex 0b 19 2a ; germ / broccoli
	hex 06 17 37 ; poop / bird leg
	hex 13 23 34 ; berries?


state_game_init: subroutine

	lda #CTRL_8x16
	sta ppu_ctrl_ora
	jsr render_disable
	
	ldx #state_game_render_id
	jsr state_set_render_routine
	ldx #state_game_update_id
	jsr state_set_update_routine

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
 */
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_germ_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn
	jsr ent_food_spawn

	; load palette
	ldx #$00
.pal_loop
	lda game_palette,x
	sta palette_cache,x
	inx
	cpx #25
	bne .pal_loop

	jsr teeth_init_playfield
	
	jsr render_enable
	
	rts

