



state_chomp_init:
	
	jsr render_disable
	jsr sprites_clear
	lda #$00
	sta scroll_x
	sta scroll_y
	
	; clear screen
	lda #$08
	sta temp00
	lda #$00
	sta temp01
	lda #$20
	jsr nametable_fill
	lda #$24
	jsr nametable_fill
	
	ldx #render_do_nothing_id
	jsr state_set_render_routine
	ldx #state_chomp_update_id
	jsr state_set_update_routine

	jsr apu_init
	jsr apubab_start
	
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
