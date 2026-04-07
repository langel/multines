

init_new_game: subroutine

	jsr render_disable
	
	jsr chompchamp_reset_game
	
	lda #$00
	sta game_level

	lda #$02
	sta continues

	jmp state_nextlevel_init
