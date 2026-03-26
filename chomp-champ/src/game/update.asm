
state_game_update: subroutine

	jsr render_enable

	jsr controller_read

	; debug visualization on
	;lda #%00011111 ; b/w
	;lda #%11111110 ; emph
	;lda #%00011000 ; diable left 8 pixels row
	;sta PPU_MASK

	jsr teeth_update

	; check if same state
	lda state_update_id
	cmp #state_game_update_id
	beq .stay_in_game_state
	jmp nmi_update_done
.stay_in_game_state

	jsr hud_sprite0
	
	;lda #%00011111 ; b/w
	;sta PPU_MASK

	; xxx need to check level status
	; game over all teeth gone
	; next level all teeth clean or gone

	jsr game_player_update
	jsr ent_z_update

	jsr hud_update

	jsr state_game_prerender

	; debug visualization off
	;lda #%00011110
	;sta PPU_MASK

	jmp nmi_update_done
