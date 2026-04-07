
state_game_update: subroutine

	jsr render_enable

	jsr controller_read

	lda controller1_d
	and #BUTTON_START
	beq .no_start_button
	inc is_paused
	ldx #state_hud_render_id
	jsr state_set_render_routine
.no_start_button

	; debug visualization on
	;lda #%00011111 ; b/w
	;lda #%11111110 ; emph
	;lda #%00011000 ; diable left 8 pixels row
	;sta PPU_MASK

	jsr teeth_update
	
	lda player_lives
	bpl .not_gameover
	jsr state_gameover_init
.not_gameover

	; check if same state
	lda state_update_id
	cmp #state_game_update_id
	beq .stay_in_game_state
	jmp nmi_update_done
.stay_in_game_state

	jsr ent_grub_convergence

	jsr apu_update

	jsr hud_sprite0
	
	;lda #%00011111 ; b/w
	;sta PPU_MASK

	; xxx need to check level status
	; game over all teeth gone
	; next level all teeth clean or gone
	lda is_paused
	bne .gameloop_done

	jsr game_player_update
	jsr ent_z_update

	jsr hud_update

	jsr state_game_prerender
.gameloop_done

	; debug visualization off
	;lda #%00011110
	;sta PPU_MASK

	jmp nmi_update_done
