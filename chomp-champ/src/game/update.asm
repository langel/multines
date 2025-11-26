
state_game_update: subroutine

	jsr render_enable

	inc scroll_x

	jsr player_update

	jsr ents_update

	jmp nmi_update_done
