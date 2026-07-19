



state_chomp_init:
	
	jsr render_disable
	jsr sprites_clear
	lda #$00
	sta scroll_x
	sta scroll_y
	
	jsr teeth_init_playfield
	; load palette
	ldx #$00
.pal_loop
	lda game_palette,x
	sta palette_cache,x
	inx
	cpx #25
	bne .pal_loop

	
	ldx #render_do_nothing_id
	jsr state_set_render_routine
	ldx #state_chomp_update_id
	jsr state_set_update_routine

	jsr apu_init
	ldx #<song_cc_congration
	ldy #>song_cc_congration
	jsr babapu_start
	
	NMI_ENABLE

	rts




state_chomp_update:
	
	jsr render_enable

	jsr apu_update
	jsr controller_read

	lda controller1_d
	and #BUTTON_B
	beq .no_b_butt
	jsr sfx_pewpew
.no_b_butt
	
	lda controller1_d
	and #BUTTON_A
	beq .no_a_butt
	jsr sfx_powerup_1up
.no_a_butt
	
	jmp nmi_update_done
