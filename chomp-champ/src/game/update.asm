
state_game_update: subroutine

	jsr render_enable

	jsr controller_read

	; debug visualization on
	;lda #%00011111 ; b/w
	;lda #%11111110 ; emph
	lda #%00011000 ; diable left 8 pixels row
	sta PPU_MASK

	jsr hud_sprite0

	; xxx need to check level status
	; game over all teeth gone
	; next level all teeth clean or gone

	jsr ent_z_update

	jsr teeth_update

	jsr hud_update

	jsr state_game_prerender

	; debug visualization off
	lda #%00011110
	sta PPU_MASK

	jmp nmi_update_done
