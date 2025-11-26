
state_game_update: subroutine

	jsr render_enable

	inc scroll_x

	jsr ents_update

	jmp nmi_update_done
