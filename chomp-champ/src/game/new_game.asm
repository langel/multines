

init_new_game: subroutine

	jsr render_disable
	
	; clear some ram
	lda #$00
	ldx <#end_of_common_ram
.clear_zp
	sta #$00,x
	inx
	bne .clear_zp
.clear_most_ram
	sta $300,x
	sta $400,x
	sta $500,x
	sta $600,x
	sta $700,x
	inx
	bne .clear_most_ram
	
	jsr ent_z_init

	lda #$04
	sta player_lives
	
	lda #$00
	sta game_level

	jmp state_nextlevel_init
