

init_new_game: subroutine

	jsr render_disable
	
	jsr chompchamp_new_game
	
	lda #$00
	sta game_level

	jmp state_nextlevel_init
