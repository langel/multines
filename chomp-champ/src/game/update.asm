
state_game_update: subroutine

	jsr render_enable

	inc scroll_x

	jsr ents_update

	; maybe render last and 
	; update before ents?
	jsr player_update

	jmp nmi_update_done
